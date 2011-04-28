Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C12116B0022
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 00:04:19 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3S3hqwk006360
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 23:43:52 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3S43jBw428660
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 00:03:45 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3S43fIV028814
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 00:03:42 -0400
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 3/3] comm: ext4: Protect task->comm access by using get_task_comm()
Date: Wed, 27 Apr 2011 21:03:31 -0700
Message-Id: <1303963411-2064-4-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1303963411-2064-1-git-send-email-john.stultz@linaro.org>
References: <1303963411-2064-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Converts ext4 comm access to use the safe get_task_comm accessor.

CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: David Rientjes <rientjes@google.com>
CC: Dave Hansen <dave@linux.vnet.ibm.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: linux-mm@kvack.org
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 fs/ext4/file.c  |    8 ++++++--
 fs/ext4/super.c |   13 ++++++++++---
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 7b80d54..d37414e 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -124,11 +124,15 @@ ext4_file_write(struct kiocb *iocb, const struct iovec *iov,
 		static unsigned long unaligned_warn_time;
 
 		/* Warn about this once per day */
-		if (printk_timed_ratelimit(&unaligned_warn_time, 60*60*24*HZ))
+		if (printk_timed_ratelimit(&unaligned_warn_time, 60*60*24*HZ)) {
+			char comm[TASK_COMM_LEN];
+
+			get_task_comm(comm, current);
 			ext4_msg(inode->i_sb, KERN_WARNING,
 				 "Unaligned AIO/DIO on inode %ld by %s; "
 				 "performance will be poor.",
-				 inode->i_ino, current->comm);
+				 inode->i_ino, comm);
+		}
 		mutex_lock(ext4_aio_mutex(inode));
 		ext4_aiodio_wait(inode);
 	}
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 8553dfb..6c9151f 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -409,12 +409,15 @@ void __ext4_error(struct super_block *sb, const char *function,
 {
 	struct va_format vaf;
 	va_list args;
+	char comm[TASK_COMM_LEN];
 
 	va_start(args, fmt);
 	vaf.fmt = fmt;
 	vaf.va = &args;
+
+	get_task_comm(comm, current);
 	printk(KERN_CRIT "EXT4-fs error (device %s): %s:%d: comm %s: %pV\n",
-	       sb->s_id, function, line, current->comm, &vaf);
+	       sb->s_id, function, line, comm, &vaf);
 	va_end(args);
 
 	ext4_handle_error(sb);
@@ -427,6 +430,7 @@ void ext4_error_inode(struct inode *inode, const char *function,
 	va_list args;
 	struct va_format vaf;
 	struct ext4_super_block *es = EXT4_SB(inode->i_sb)->s_es;
+	char comm[TASK_COMM_LEN];
 
 	es->s_last_error_ino = cpu_to_le32(inode->i_ino);
 	es->s_last_error_block = cpu_to_le64(block);
@@ -438,7 +442,8 @@ void ext4_error_inode(struct inode *inode, const char *function,
 	       inode->i_sb->s_id, function, line, inode->i_ino);
 	if (block)
 		printk(KERN_CONT "block %llu: ", block);
-	printk(KERN_CONT "comm %s: %pV\n", current->comm, &vaf);
+	get_task_comm(comm, current);
+	printk(KERN_CONT "comm %s: %pV\n", comm, &vaf);
 	va_end(args);
 
 	ext4_handle_error(inode->i_sb);
@@ -453,6 +458,7 @@ void ext4_error_file(struct file *file, const char *function,
 	struct ext4_super_block *es;
 	struct inode *inode = file->f_dentry->d_inode;
 	char pathname[80], *path;
+	char comm[TASK_COMM_LEN];
 
 	es = EXT4_SB(inode->i_sb)->s_es;
 	es->s_last_error_ino = cpu_to_le32(inode->i_ino);
@@ -468,7 +474,8 @@ void ext4_error_file(struct file *file, const char *function,
 	va_start(args, fmt);
 	vaf.fmt = fmt;
 	vaf.va = &args;
-	printk(KERN_CONT "comm %s: path %s: %pV\n", current->comm, path, &vaf);
+	get_task_comm(comm, current);
+	printk(KERN_CONT "comm %s: path %s: %pV\n", comm, path, &vaf);
 	va_end(args);
 
 	ext4_handle_error(inode->i_sb);
-- 
1.7.3.2.146.gca209

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
