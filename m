Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6BF696B0073
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 20:25:16 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id uo5so1956013pbc.1
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 17:25:16 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ek3si5333234pbd.115.2014.01.15.17.25.14
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 17:25:15 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v5 15/22] Remove CONFIG_EXT2_FS_XIP
Date: Wed, 15 Jan 2014 20:24:33 -0500
Message-Id: <60722af77e7717463464cc6b2d7b6b2967c742f1.1389779962.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1389779961.git.matthew.r.wilcox@intel.com>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1389779961.git.matthew.r.wilcox@intel.com>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>

The fewer Kconfig options we have the better.  Use the generic CONFIG_FS_XIP
to enable XIP support in ext2 as well as in the core.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/Kconfig      | 21 ++++++++++++++-------
 fs/ext2/Kconfig | 11 -----------
 fs/ext2/file.c  |  4 ++--
 fs/ext2/super.c |  4 ++--
 4 files changed, 18 insertions(+), 22 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index c229f82..1e01dda 100644
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
 
+config FS_XIP
+	bool "Execute in place support"
+	depends on MMU
+	help
+	  Execute in place (XIP) can be used on memory-backed block devices.
+	  If the block device supports XIP and the filesystem supports XIP,
+	  then you can avoid using the pagecache to buffer I/Os.  Turning
+	  on this option will compile in support for XIP; you will need to
+	  mount the filesystem using the -o xip option.
+
+	  If you do not have a block device that is capable of using this,
+	  or if unsure, say N.  Saying Y will increase the size of the kernel
+	  by about 2kB.
+
 endif # BLOCK
 
 # Posix ACL utility routines
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
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index 9e88388..8cf2c5f 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -25,7 +25,7 @@
 #include "xattr.h"
 #include "acl.h"
 
-#ifdef CONFIG_EXT2_FS_XIP
+#ifdef CONFIG_FS_XIP
 static int ext2_xip_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	return xip_fault(vma, vmf, ext2_get_block);
@@ -109,7 +109,7 @@ const struct file_operations ext2_file_operations = {
 	.splice_write	= generic_file_splice_write,
 };
 
-#ifdef CONFIG_EXT2_FS_XIP
+#ifdef CONFIG_FS_XIP
 const struct file_operations ext2_xip_file_operations = {
 	.llseek		= generic_file_llseek,
 	.read		= do_sync_read,
diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index fd62082..a2caffd 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -287,7 +287,7 @@ static int ext2_show_options(struct seq_file *seq, struct dentry *root)
 		seq_puts(seq, ",grpquota");
 #endif
 
-#if defined(CONFIG_EXT2_FS_XIP)
+#ifdef CONFIG_FS_XIP
 	if (sbi->s_mount_opt & EXT2_MOUNT_XIP)
 		seq_puts(seq, ",xip");
 #endif
@@ -549,7 +549,7 @@ static int parse_options(char *options, struct super_block *sb)
 			break;
 #endif
 		case Opt_xip:
-#ifdef CONFIG_EXT2_FS_XIP
+#ifdef CONFIG_FS_XIP
 			set_opt (sbi->s_mount_opt, XIP);
 #else
 			ext2_msg(sb, KERN_INFO, "xip option not supported");
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
