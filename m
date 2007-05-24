Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4OB9Ye7013815
	for <linux-mm@kvack.org>; Thu, 24 May 2007 07:09:35 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4OCBfcP530338
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:11:41 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4OCBfke024720
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:11:41 -0400
Date: Thu, 24 May 2007 08:11:41 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20070524121141.13533.97864.sendpatchset@kleikamp.austin.ibm.com>
In-Reply-To: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
References: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
Subject: [RFC:PATCH 002/012] Allow file systems to specify whether to store file tails
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Allow file systems to specify whether to enable page cache tails

This allows us to test and enable each file system independently.  It also
gives the file system the flexibility to have a mount flag enable or disable
page cache tails.

Initially, I am only testing on ext4 & jfs, so as not to damage my root file
system (ext3).

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 fs/ext4/super.c    |    4 ++++
 fs/jfs/super.c     |    3 +++
 include/linux/fs.h |    2 ++
 3 files changed, 9 insertions(+)

diff -Nurp linux001/fs/ext4/super.c linux002/fs/ext4/super.c
--- linux001/fs/ext4/super.c	2007-05-21 15:15:33.000000000 -0500
+++ linux002/fs/ext4/super.c	2007-05-23 22:53:11.000000000 -0500
@@ -1548,6 +1548,10 @@ static int ext4_fill_super (struct super
 
 	sb->s_flags = (sb->s_flags & ~MS_POSIXACL) |
 		((sbi->s_mount_opt & EXT4_MOUNT_POSIX_ACL) ? MS_POSIXACL : 0);
+#ifdef CONFIG_VM_FILE_TAILS
+	/* ToDo: Make this a mount option */
+	sb->s_flags |= MS_FILE_TAIL;
+#endif
 
 	if (le32_to_cpu(es->s_rev_level) == EXT4_GOOD_OLD_REV &&
 	    (EXT4_HAS_COMPAT_FEATURE(sb, ~0U) ||
diff -Nurp linux001/fs/jfs/super.c linux002/fs/jfs/super.c
--- linux001/fs/jfs/super.c	2007-05-21 15:15:34.000000000 -0500
+++ linux002/fs/jfs/super.c	2007-05-23 22:53:11.000000000 -0500
@@ -439,6 +439,9 @@ static int jfs_fill_super(struct super_b
 #ifdef CONFIG_JFS_POSIX_ACL
 	sb->s_flags |= MS_POSIXACL;
 #endif
+#ifdef CONFIG_VM_FILE_TAILS
+	sb->s_flags |= MS_FILE_TAIL;
+#endif
 
 	if (newLVSize) {
 		printk(KERN_ERR "resize option for remount only\n");
diff -Nurp linux001/include/linux/fs.h linux002/include/linux/fs.h
--- linux001/include/linux/fs.h	2007-05-21 15:15:43.000000000 -0500
+++ linux002/include/linux/fs.h	2007-05-23 22:53:11.000000000 -0500
@@ -123,6 +123,7 @@ extern int dir_notify_enable;
 #define MS_SLAVE	(1<<19)	/* change to slave */
 #define MS_SHARED	(1<<20)	/* change to shared */
 #define MS_RELATIME	(1<<21)	/* Update atime relative to mtime/ctime. */
+#define MS_FILE_TAIL	(1<<22)	/* Store file tail efficiently in page cache */
 #define MS_ACTIVE	(1<<30)
 #define MS_NOUSER	(1<<31)
 
@@ -182,6 +183,7 @@ extern int dir_notify_enable;
 #define IS_NOCMTIME(inode)	((inode)->i_flags & S_NOCMTIME)
 #define IS_SWAPFILE(inode)	((inode)->i_flags & S_SWAPFILE)
 #define IS_PRIVATE(inode)	((inode)->i_flags & S_PRIVATE)
+#define IS_FILE_TAIL_CAPABLE(inode)	__IS_FLG(inode, MS_FILE_TAIL)
 
 /* the read-only stuff doesn't really belong here, but any other place is
    probably as bad and I don't want to create yet another include file. */

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
