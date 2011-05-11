Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 13B5F6B0012
	for <linux-mm@kvack.org>; Tue, 10 May 2011 20:23:16 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4B06Khx016893
	for <linux-mm@kvack.org>; Tue, 10 May 2011 18:06:20 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4B0OMik140174
	for <linux-mm@kvack.org>; Tue, 10 May 2011 18:24:22 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4AIN9YF014644
	for <linux-mm@kvack.org>; Tue, 10 May 2011 12:23:10 -0600
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 3/3] comm: ext4: Protect task->comm access by using %ptc
Date: Tue, 10 May 2011 17:23:06 -0700
Message-Id: <1305073386-4810-4-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1305073386-4810-1-git-send-email-john.stultz@linaro.org>
References: <1305073386-4810-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Converts ext4 comm access to use the safe printk %ptc accessor.

CC: Ted Ts'o <tytso@mit.edu>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: David Rientjes <rientjes@google.com>
CC: Dave Hansen <dave@linux.vnet.ibm.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: linux-mm@kvack.org
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 fs/ext4/file.c  |    4 ++--
 fs/ext4/super.c |    8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 7b80d54..31438a0 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -126,9 +126,9 @@ ext4_file_write(struct kiocb *iocb, const struct iovec *iov,
 		/* Warn about this once per day */
 		if (printk_timed_ratelimit(&unaligned_warn_time, 60*60*24*HZ))
 			ext4_msg(inode->i_sb, KERN_WARNING,
-				 "Unaligned AIO/DIO on inode %ld by %s; "
+				 "Unaligned AIO/DIO on inode %ld by %ptc; "
 				 "performance will be poor.",
-				 inode->i_ino, current->comm);
+				 inode->i_ino, current);
 		mutex_lock(ext4_aio_mutex(inode));
 		ext4_aiodio_wait(inode);
 	}
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 8553dfb..d4ab4c0 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -413,8 +413,8 @@ void __ext4_error(struct super_block *sb, const char *function,
 	va_start(args, fmt);
 	vaf.fmt = fmt;
 	vaf.va = &args;
-	printk(KERN_CRIT "EXT4-fs error (device %s): %s:%d: comm %s: %pV\n",
-	       sb->s_id, function, line, current->comm, &vaf);
+	printk(KERN_CRIT "EXT4-fs error (device %s): %s:%d: comm %ptc: %pV\n",
+	       sb->s_id, function, line, current, &vaf);
 	va_end(args);
 
 	ext4_handle_error(sb);
@@ -438,7 +438,7 @@ void ext4_error_inode(struct inode *inode, const char *function,
 	       inode->i_sb->s_id, function, line, inode->i_ino);
 	if (block)
 		printk(KERN_CONT "block %llu: ", block);
-	printk(KERN_CONT "comm %s: %pV\n", current->comm, &vaf);
+	printk(KERN_CONT "comm %ptc: %pV\n", current, &vaf);
 	va_end(args);
 
 	ext4_handle_error(inode->i_sb);
@@ -468,7 +468,7 @@ void ext4_error_file(struct file *file, const char *function,
 	va_start(args, fmt);
 	vaf.fmt = fmt;
 	vaf.va = &args;
-	printk(KERN_CONT "comm %s: path %s: %pV\n", current->comm, path, &vaf);
+	printk(KERN_CONT "comm %ptc: path %s: %pV\n", current, path, &vaf);
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
