Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 230AA6B0096
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 17:22:05 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id v10so2109215pde.22
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 14:22:04 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id os9si5055556pdb.148.2014.10.24.14.22.03
        for <linux-mm@kvack.org>;
        Fri, 24 Oct 2014 14:22:04 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v12 15/20] vfs,ext2: Remove CONFIG_EXT2_FS_XIP and rename CONFIG_FS_XIP to CONFIG_FS_DAX
Date: Fri, 24 Oct 2014 17:20:47 -0400
Message-Id: <1414185652-28663-16-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>

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
 include/linux/fs.h |  2 +-
 scripts/diffconfig |  1 -
 8 files changed, 21 insertions(+), 26 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index db5dc15..731e702 100644
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
+	bool "Direct Access (DAX) support"
+	depends on MMU
+	help
+	  Direct Access (DAX) can be used on memory-backed block devices.
+	  If the block device supports DAX and the filesystem supports DAX,
+	  then you can avoid using the pagecache to buffer I/Os.  Turning
+	  on this option will compile in support for DAX; you will need to
+	  mount the filesystem using the -o dax option.
+
+	  If you do not have a block device that is capable of using this,
+	  or if unsure, say N.  Saying Y will increase the size of the kernel
+	  by about 5kB.
+
 endif # BLOCK
 
 # Posix ACL utility routines
diff --git a/fs/Makefile b/fs/Makefile
index 0325ec3..df4a4cf 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -28,7 +28,7 @@ obj-$(CONFIG_SIGNALFD)		+= signalfd.o
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
index da8dc64..46b333d 100644
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
 	.splice_write	= iter_file_splice_write,
 };
 
-#ifdef CONFIG_EXT2_FS_XIP
+#ifdef CONFIG_FS_DAX
 const struct file_operations ext2_xip_file_operations = {
 	.llseek		= generic_file_llseek,
 	.read		= new_sync_read,
diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index b1f25f8..60f7b53 100644
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
index 527684e..dad6628 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1586,7 +1586,7 @@ struct super_operations {
 #define S_IMA		1024	/* Inode has an associated IMA struct */
 #define S_AUTOMOUNT	2048	/* Automount/referral quasi-directory */
 #define S_NOSEC		4096	/* no suid or xattr security attributes */
-#ifdef CONFIG_FS_XIP
+#ifdef CONFIG_FS_DAX
 #define S_DAX		8192	/* Direct Access, avoiding the page cache */
 #else
 #define S_DAX		0	/* Make all the DAX code disappear */
diff --git a/scripts/diffconfig b/scripts/diffconfig
index 6d67283..0db267d 100755
--- a/scripts/diffconfig
+++ b/scripts/diffconfig
@@ -28,7 +28,6 @@ If no config files are specified, .config and .config.old are used.
 Example usage:
  $ diffconfig .config config-with-some-changes
 -EXT2_FS_XATTR  n
--EXT2_FS_XIP  n
  CRAMFS  n -> y
  EXT2_FS  y -> n
  LOG_BUF_SHIFT  14 -> 16
-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
