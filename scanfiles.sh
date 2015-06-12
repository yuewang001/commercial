#!/bin/sh
#set -x 
DAYS=30
DEL_DAY=3
MAIL_SERVER=135.252.181.127
#MAIL_SENDER=ascm_admin@sdm.cn.alcatel-lucent.com
#MAIL_SENDER=do.not.reply@sdm.cn.alcatel-lucent.com
MAIL_SENDER=yuewang@alcatel-lucent.com
BCC_MAIL_SENDER=yuewang@alcatel-lucent.com
CC_LIST=Yunxiang.Tian@alcatel-lucent.com
HOST_NAME=`hostname`
MAIL_TITLE=""
MAIL_FILE=/tmp/file_tmp_$date.txt
PATH_AUDIT=/local
RAW_DATA=YES
FULL_DATA=""
#$ASCM_HOME/bin/sendEmail -f $MAIL_SENDER -s $MAIL_SERVER -t $MAIL_RECEIVER -o message-file=$MAIL_FILE -u $MAIL_TITLE
message="Attention: your folders on LincasePC: $HOST_NAME have not been changed for more than $DAYS days, please delete them asap "
ALL_ACCOUNT=`cat /home/yuewang/bin/sdm_cc_list.txt`
ACCOUNTS=/home/yuewang/bin/account_list.txt
function get_email_add()
{ 
   for id_email in $ALL_ACCOUNT
   do
      id_=`echo $id_email|cut -d ";" -f 1`
      email_=`echo $id_email|cut -d ';' -f 2`
      if [ "$1" = "$id_" ]; then
	    echo $email_
	 MAIL_RECEIVER=$MAIL_RECEIVER" "$email_
         return 0
      fi
   done

}
get_receiver_list()
{

#acque receeiver list
#receiver_list=`ls -l $PATH_AUDIT|sed -n '2,$p'|awk '{print $3}'|sort -u`
#receiver_list=`ls -l $PATH_AUDIT|sed -n '2,$p'|awk '{print $3"@lucent.com"}'|sort -u`
#echo $receiver_list
#MAIL_RECEIVER=$receiver_list
echo "begin to loop"
for id in $receiver_list
do
   get_email_add $id
   MAIL_RECEIVER=$MAIL_RECEIVER" "$_email
done

}

construct_mail_title()
{
MAIL_TITLE=$message 

}

find_rawdata()
{
	Find_CMD="find $PATH_AUDIT  -maxdepth 1 -ctime +$DAYS -printf '%p;%u\n'"
	RAW_DATA=`$Find_CMD|grep -v "lost+found"`
	if [ ! "$RAW_DATA" ]; then
      exit 0
    fi
}

construct_mail_mainbody()
{
        #echo "---------------------------------------------------------" >> $MAIL_FILE
        echo " Folder                                              ID               Email ">>$MAIL_FILE
	echo "-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" >> $MAIL_FILE
	 

	
	for line in $RAW_DATA
	do	
		id_=`echo $line|cut -d ";" -f 2`
	 	echo $id_
		folder_=`echo $line|cut -d ";" -f 1`
		email_=$(get_email_add $id_)
		MAIL_RECEIVER=$MAIL_RECEIVER" "$email_
		echo "$folder_               $id_                   $email_"
	 	echo "$folder_;$id_;$email_"|awk -F ';' '{printf ("%-50s %-15s %-15s\n",$1,$2,$3)}' >> $MAIL_FILE
 
	done

}
construct_mail_file()
{
   rm -rf $MAIL_FILE
   touch $MAIL_FILE
   echo "THIS EMAIL IS GENERATED AUTOMATICALY, DO NOT REPLY!" >> $MAIL_FILE
   echo >> $MAIL_FILE
   echo >> $MAIL_FILE
   echo $message  >>$MAIL_FILE 
   echo " " >>$MAIL_FILE
   echo " " >>$MAIL_FILE
   echo " " >>$MAIL_FILE
   construct_mail_mainbody


}
find_rawdata
#get_receiver_list
construct_mail_title
construct_mail_file
if [ $? = 1 ]; then 
    exit 0
fi
ASCM_HOME=/home/ascm
if [ -z  "$RAW_DATA" ]; then 
  exit 0
fi

#MAIL_RECEIVER=`echo $MAIL_RECEIVER|sed -n 's/ /\n/g'|sort -u|sed -n 's/\n/ /g'`
MAIL_RECEIVER=`cat  $MAIL_FILE| awk '{print $3}' | grep alcatel|sort -u`
$ASCM_HOME/bin/sendEmail -f $MAIL_SENDER -s $MAIL_SERVER -t $MAIL_RECEIVER -o message-file=$MAIL_FILE -u $MAIL_TITLE -bcc $BCC_MAIL_SENDER -cc $CC_LIST
