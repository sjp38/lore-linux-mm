Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 83D496B003B
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 00:34:35 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so23960832pdj.36
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 21:34:35 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ff10si7186669pdb.137.2014.08.26.21.34.32
        for <linux-mm@kvack.org>;
        Tue, 26 Aug 2014 21:34:32 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v10 18/21] Get rid of most mentions of XIP in ext2
Date: Tue, 26 Aug 2014 23:45:38 -0400
Message-Id: <94a0151915493e25de600fb552c4fd1daca5ceb9.1409110741.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1409110741.git.matthew.r.wilcox@intel.com>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1409110741.git.matthew.r.wilcox@intel.com>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

To help people transition, accept the 'xip' mount option (and report it
in /proc/mounts), but print a message encouraging people to switch over
to the 'dax' option.
---
 fs/ext2/ext2.h  | 13 +++++++------
 fs/ext2/file.c  |  2 +-
 fs/ext2/inode.c |  6 +++---
 fs/ext2/namei.c |  8 ++++----
 fs/ext2/super.c | 25 ++++++++++++++++---------
 5 files changed, 31 insertions(+), 23 deletions(-)

diff --git a/fs/ext2/ext2.h b/fs/ext2/ext2.h
index b8b1c11..46133a0 100644
--- a/fs/ext2/ext2.h
+++ b/fs/ext2/ext2.h
@@ -380,14 +380,15 @@ struct ext2_inode {
 #define EXT2_MOUNT_NO_UID32		0x000200  /* Disable 32-bit UIDs */
 #define EXT2_MOUNT_XATTR_USER		0x004000  /* Extended user attributes */
 #define EXT2_MOUNT_POSIX_ACL		0x008000  /* POSIX Access Control Lists */
-#ifdef CONFIG_FS_DAX
-#define EXT2_MOUNT_XIP			0x010000  /* Execute in place */
-#else
-#define EXT2_MOUNT_XIP			0
-#endif
+#define EXT2_MOUNT_XIP			0x010000  /* Obsolete, use DAX */
 #define EXT2_MOUNT_USRQUOTA		0x020000  /* user quota */
 #define EXT2_MOUNT_GRPQUOTA		0x040000  /* group quota */
 #define EXT2_MOUNT_RESERVATION		0x080000  /* Preallocation */
+#ifdef CONFIG_FS_DAX
+#define EXT2_MOUNT_DAX			0x100000  /* Direct Access */
+#else
+#define EXT2_MOUNT_DAX			0
+#endif
 
 
 #define clear_opt(o, opt)		o &= ~EXT2_MOUNT_##opt
@@ -789,7 +790,7 @@ extern int ext2_fsync(struct file *file, loff_t start, loff_t end,
 		      int datasync);
 extern const struct inode_operations ext2_file_inode_operations;
 extern const struct file_operations ext2_file_operations;
-extern const struct file_operations ext2_xip_file_operations;
+extern const struct file_operations ext2_dax_file_operations;
 
 /* inode.c */
 extern const struct address_space_operations ext2_aops;
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index 46b333d..5b8cab5 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -110,7 +110,7 @@ const struct file_operations ext2_file_operations = {
 };
 
 #ifdef CONFIG_FS_DAX
-const struct file_operations ext2_xip_file_operations = {
+const struct file_operations ext2_dax_file_operations = {
 	.llseek		= generic_file_llseek,
 	.read		= new_sync_read,
 	.write		= new_sync_write,
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 034fd42..6434bc0 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -1286,7 +1286,7 @@ void ext2_set_inode_flags(struct inode *inode)
 		inode->i_flags |= S_NOATIME;
 	if (flags & EXT2_DIRSYNC_FL)
 		inode->i_flags |= S_DIRSYNC;
-	if (test_opt(inode->i_sb, XIP))
+	if (test_opt(inode->i_sb, DAX))
 		inode->i_flags |= S_DAX;
 }
 
@@ -1388,9 +1388,9 @@ struct inode *ext2_iget (struct super_block *sb, unsigned long ino)
 
 	if (S_ISREG(inode->i_mode)) {
 		inode->i_op = &ext2_file_inode_operations;
-		if (test_opt(inode->i_sb, XIP)) {
+		if (test_opt(inode->i_sb, DAX)) {
 			inode->i_mapping->a_ops = &ext2_aops;
-			inode->i_fop = &ext2_xip_file_operations;
+			inode->i_fop = &ext2_dax_file_operations;
 		} else if (test_opt(inode->i_sb, NOBH)) {
 			inode->i_mapping->a_ops = &ext2_nobh_aops;
 			inode->i_fop = &ext2_file_operations;
diff --git a/fs/ext2/namei.c b/fs/ext2/namei.c
index 0db888c..148f6e3 100644
--- a/fs/ext2/namei.c
+++ b/fs/ext2/namei.c
@@ -104,9 +104,9 @@ static int ext2_create (struct inode * dir, struct dentry * dentry, umode_t mode
 		return PTR_ERR(inode);
 
 	inode->i_op = &ext2_file_inode_operations;
-	if (test_opt(inode->i_sb, XIP)) {
+	if (test_opt(inode->i_sb, DAX)) {
 		inode->i_mapping->a_ops = &ext2_aops;
-		inode->i_fop = &ext2_xip_file_operations;
+		inode->i_fop = &ext2_dax_file_operations;
 	} else if (test_opt(inode->i_sb, NOBH)) {
 		inode->i_mapping->a_ops = &ext2_nobh_aops;
 		inode->i_fop = &ext2_file_operations;
@@ -125,9 +125,9 @@ static int ext2_tmpfile(struct inode *dir, struct dentry *dentry, umode_t mode)
 		return PTR_ERR(inode);
 
 	inode->i_op = &ext2_file_inode_operations;
-	if (test_opt(inode->i_sb, XIP)) {
+	if (test_opt(inode->i_sb, DAX)) {
 		inode->i_mapping->a_ops = &ext2_aops;
-		inode->i_fop = &ext2_xip_file_operations;
+		inode->i_fop = &ext2_dax_file_operations;
 	} else if (test_opt(inode->i_sb, NOBH)) {
 		inode->i_mapping->a_ops = &ext2_nobh_aops;
 		inode->i_fop = &ext2_file_operations;
diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index feb53d8..8b9debf 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -290,6 +290,8 @@ static int ext2_show_options(struct seq_file *seq, struct dentry *root)
 #ifdef CONFIG_FS_DAX
 	if (sbi->s_mount_opt & EXT2_MOUNT_XIP)
 		seq_puts(seq, ",xip");
+	if (sbi->s_mount_opt & EXT2_MOUNT_DAX)
+		seq_puts(seq, ",dax");
 #endif
 
 	if (!test_opt(sb, RESERVATION))
@@ -393,7 +395,7 @@ enum {
 	Opt_resgid, Opt_resuid, Opt_sb, Opt_err_cont, Opt_err_panic,
 	Opt_err_ro, Opt_nouid32, Opt_nocheck, Opt_debug,
 	Opt_oldalloc, Opt_orlov, Opt_nobh, Opt_user_xattr, Opt_nouser_xattr,
-	Opt_acl, Opt_noacl, Opt_xip, Opt_ignore, Opt_err, Opt_quota,
+	Opt_acl, Opt_noacl, Opt_xip, Opt_dax, Opt_ignore, Opt_err, Opt_quota,
 	Opt_usrquota, Opt_grpquota, Opt_reservation, Opt_noreservation
 };
 
@@ -422,6 +424,7 @@ static const match_table_t tokens = {
 	{Opt_acl, "acl"},
 	{Opt_noacl, "noacl"},
 	{Opt_xip, "xip"},
+	{Opt_dax, "dax"},
 	{Opt_grpquota, "grpquota"},
 	{Opt_ignore, "noquota"},
 	{Opt_quota, "quota"},
@@ -549,10 +552,14 @@ static int parse_options(char *options, struct super_block *sb)
 			break;
 #endif
 		case Opt_xip:
+			ext2_msg(sb, KERN_INFO, "use dax instead of xip");
+			set_opt(sbi->s_mount_opt, XIP);
+			/* Fall through */
+		case Opt_dax:
 #ifdef CONFIG_FS_DAX
-			set_opt (sbi->s_mount_opt, XIP);
+			set_opt(sbi->s_mount_opt, DAX);
 #else
-			ext2_msg(sb, KERN_INFO, "xip option not supported");
+			ext2_msg(sb, KERN_INFO, "dax option not supported");
 #endif
 			break;
 
@@ -896,15 +903,15 @@ static int ext2_fill_super(struct super_block *sb, void *data, int silent)
 
 	blocksize = BLOCK_SIZE << le32_to_cpu(sbi->s_es->s_log_block_size);
 
-	if (sbi->s_mount_opt & EXT2_MOUNT_XIP) {
+	if (sbi->s_mount_opt & EXT2_MOUNT_DAX) {
 		if (blocksize != PAGE_SIZE) {
 			ext2_msg(sb, KERN_ERR,
-					"error: unsupported blocksize for xip");
+					"error: unsupported blocksize for dax");
 			goto failed_mount;
 		}
 		if (!sb->s_bdev->bd_disk->fops->direct_access) {
 			ext2_msg(sb, KERN_ERR,
-					"error: device does not support xip");
+					"error: device does not support dax");
 			goto failed_mount;
 		}
 	}
@@ -1276,10 +1283,10 @@ static int ext2_remount (struct super_block * sb, int * flags, char * data)
 		((sbi->s_mount_opt & EXT2_MOUNT_POSIX_ACL) ? MS_POSIXACL : 0);
 
 	es = sbi->s_es;
-	if ((sbi->s_mount_opt ^ old_opts.s_mount_opt) & EXT2_MOUNT_XIP) {
+	if ((sbi->s_mount_opt ^ old_opts.s_mount_opt) & EXT2_MOUNT_DAX) {
 		ext2_msg(sb, KERN_WARNING, "warning: refusing change of "
-			 "xip flag with busy inodes while remounting");
-		sbi->s_mount_opt ^= EXT2_MOUNT_XIP;
+			 "dax flag with busy inodes while remounting");
+		sbi->s_mount_opt ^= EXT2_MOUNT_DAX;
 	}
 	if ((*flags & MS_RDONLY) == (sb->s_flags & MS_RDONLY)) {
 		spin_unlock(&sbi->s_lock);
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
