Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id D05256B0103
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 09:19:25 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so8188781pad.0
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 06:19:25 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id gk3si20883083pac.176.2014.02.25.06.19.23
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 06:19:24 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v6 15/22] Remove CONFIG_EXT2_FS_XIP and rename CONFIG_FS_XIP to CONFIG_FS_DAX
Date: Tue, 25 Feb 2014 09:18:31 -0500
Message-Id: <1393337918-28265-16-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, willy@linux.intel.com
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>

The fewer Kconfig options we have the better.  Use the generic
CONFIG_FS_DAX to enable XIP support in ext2 as well as in the core.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/Kconfig         | 21 ++++++++++++++-------
 fs/Makefile        |  2 +-
 fs/ext2/Kconfig    | 11 -----------
 fs/ext2/ext2.h     |  2 +-
 fs/ext2/file.c     |  4 ++--
 fs/ext2/super.c    |  4 ++--
 include/linux/fs.h |  4 ++--
 7 files changed, 22 insertions(+), 26 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 7385e54..620ab73 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -13,13 +13,6 @@ if BLOCK
 source "fs/ext2/Kconfig"
 source "fs/ext3/Kconfig"
 source "fs/ext4/Kconfig"
-
-config FS_XIP
-# execute in place
-	bool
-	depends on EXT2_FS_XIP
-	default y
-
 source "fs/jbd/Kconfig"
 source "fs/jbd2/Kconfig"
 
@@ -40,6 +33,20 @@ source "fs/ocfs2/Kconfig"
 source "fs/btrfs/Kconfig"
 source "fs/nilfs2/Kconfig"
 
+config FS_DAX
+	bool "Direct Access support"
+	depends on MMU
+	help
+	  Direct Access (DAX) can be used on memory-backed block devices.
+	  If the block device supports DAX and the filesystem supports DAX,
+	  then you can avoid using the pagecache to buffer I/Os.  Turning
+	  on this option will compile in support for DAX; you will need to
+	  mount the filesystem using the -o xip option.
+
+	  If you do not have a block device that is capable of using this,
+	  or if unsure, say N.  Saying Y will increase the size of the kernel
+	  by about 2kB.
+
 endif # BLOCK
 
 # Posix ACL utility routines
diff --git a/fs/Makefile b/fs/Makefile
index 2f194cd..b7e0a13 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -29,7 +29,7 @@ obj-$(CONFIG_SIGNALFD)		+= signalfd.o
 obj-$(CONFIG_TIMERFD)		+= timerfd.o
 obj-$(CONFIG_EVENTFD)		+= eventfd.o
 obj-$(CONFIG_AIO)               += aio.o
-obj-$(CONFIG_FS_XIP)		+= dax.o
+obj-$(CONFIG_FS_DAX)		+= dax.o
 obj-$(CONFIG_FILE_LOCKING)      += locks.o
 obj-$(CONFIG_COMPAT)		+= compat.o compat_ioctl.o
 obj-$(CONFIG_BINFMT_AOUT)	+= binfmt_aout.o
diff --git a/fs/ext2/Kconfig b/fs/ext2/Kconfig
index 14a6780..c634874e 100644
--- a/fs/ext2/Kconfig
+++ b/fs/ext2/Kconfig
@@ -42,14 +42,3 @@ config EXT2_FS_SECURITY
 
 	  If you are not using a security module that requires using
 	  extended attributes for file security labels, say N.
-
-config EXT2_FS_XIP
-	bool "Ext2 execute in place support"
-	depends on EXT2_FS && MMU
-	help
-	  Execute in place can be used on memory-backed block devices. If you
-	  enable this option, you can select to mount block devices which are
-	  capable of this feature without using the page cache.
-
-	  If you do not use a block device that is capable of using this,
-	  or if unsure, say N.
diff --git a/fs/ext2/ext2.h b/fs/ext2/ext2.h
index 5ecf570..b30c3bd 100644
--- a/fs/ext2/ext2.h
+++ b/fs/ext2/ext2.h
@@ -380,7 +380,7 @@ struct ext2_inode {
 #define EXT2_MOUNT_NO_UID32		0x000200  /* Disable 32-bit UIDs */
 #define EXT2_MOUNT_XATTR_USER		0x004000  /* Extended user attributes */
 #define EXT2_MOUNT_POSIX_ACL		0x008000  /* POSIX Access Control Lists */
-#ifdef CONFIG_FS_XIP
+#ifdef CONFIG_FS_DAX
 #define EXT2_MOUNT_XIP			0x010000  /* Execute in place */
 #else
 #define EXT2_MOUNT_XIP			0
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index e3ce10d..ae7f000 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -25,7 +25,7 @@
 #include "xattr.h"
 #include "acl.h"
 
-#ifdef CONFIG_EXT2_FS_XIP
+#ifdef CONFIG_FS_DAX
 static int ext2_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	return dax_fault(vma, vmf, ext2_get_block);
@@ -109,7 +109,7 @@ const struct file_operations ext2_file_operations = {
 	.splice_write	= generic_file_splice_write,
 };
 
-#ifdef CONFIG_EXT2_FS_XIP
+#ifdef CONFIG_FS_DAX
 const struct file_operations ext2_xip_file_operations = {
 	.llseek		= generic_file_llseek,
 	.read		= do_sync_read,
diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index 752ccb4..fdcacf7 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -287,7 +287,7 @@ static int ext2_show_options(struct seq_file *seq, struct dentry *root)
 		seq_puts(seq, ",grpquota");
 #endif
 
-#if defined(CONFIG_EXT2_FS_XIP)
+#ifdef CONFIG_FS_DAX
 	if (sbi->s_mount_opt & EXT2_MOUNT_XIP)
 		seq_puts(seq, ",xip");
 #endif
@@ -549,7 +549,7 @@ static int parse_options(char *options, struct super_block *sb)
 			break;
 #endif
 		case Opt_xip:
-#ifdef CONFIG_EXT2_FS_XIP
+#ifdef CONFIG_FS_DAX
 			set_opt (sbi->s_mount_opt, XIP);
 #else
 			ext2_msg(sb, KERN_INFO, "xip option not supported");
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 6f7f445..19abdb1 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1677,7 +1677,7 @@ struct super_operations {
 #define IS_IMA(inode)		((inode)->i_flags & S_IMA)
 #define IS_AUTOMOUNT(inode)	((inode)->i_flags & S_AUTOMOUNT)
 #define IS_NOSEC(inode)		((inode)->i_flags & S_NOSEC)
-#ifdef CONFIG_FS_XIP
+#ifdef CONFIG_FS_DAX
 #define IS_DAX(inode)		((inode)->i_flags & S_DAX)
 #else
 #define IS_DAX(inode)		0
@@ -2515,7 +2515,7 @@ extern loff_t fixed_size_llseek(struct file *file, loff_t offset,
 extern int generic_file_open(struct inode * inode, struct file * filp);
 extern int nonseekable_open(struct inode * inode, struct file * filp);
 
-#ifdef CONFIG_FS_XIP
+#ifdef CONFIG_FS_DAX
 int dax_clear_blocks(struct inode *, sector_t block, long size);
 int dax_truncate_page(struct inode *, loff_t from, get_block_t);
 ssize_t dax_do_io(int rw, struct kiocb *, struct inode *, const struct iovec *,
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
