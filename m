Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9F7DE6B010B
	for <linux-mm@kvack.org>; Sun, 23 Mar 2014 15:09:23 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id fb1so4516351pad.15
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 12:09:23 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id f1si7623998pbn.16.2014.03.23.12.09.22
        for <linux-mm@kvack.org>;
        Sun, 23 Mar 2014 12:09:22 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v7 17/22] Get rid of most mentions of XIP in ext2
Date: Sun, 23 Mar 2014 15:08:43 -0400
Message-Id: <0b13a744db9bfca33938bc1576f7eb7bfc9c41c2.1395591795.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1395591795.git.matthew.r.wilcox@intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1395591795.git.matthew.r.wilcox@intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

The only remaining usage is userspace's 'xip' option.
---
 fs/ext2/ext2.h  |  6 +++---
 fs/ext2/file.c  |  2 +-
 fs/ext2/inode.c |  6 +++---
 fs/ext2/namei.c |  8 ++++----
 fs/ext2/super.c | 16 ++++++++--------
 5 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/fs/ext2/ext2.h b/fs/ext2/ext2.h
index b8b1c11..0e1fe9d 100644
--- a/fs/ext2/ext2.h
+++ b/fs/ext2/ext2.h
@@ -381,9 +381,9 @@ struct ext2_inode {
 #define EXT2_MOUNT_XATTR_USER		0x004000  /* Extended user attributes */
 #define EXT2_MOUNT_POSIX_ACL		0x008000  /* POSIX Access Control Lists */
 #ifdef CONFIG_FS_DAX
-#define EXT2_MOUNT_XIP			0x010000  /* Execute in place */
+#define EXT2_MOUNT_DAX			0x010000  /* Direct Access */
 #else
-#define EXT2_MOUNT_XIP			0
+#define EXT2_MOUNT_DAX			0
 #endif
 #define EXT2_MOUNT_USRQUOTA		0x020000  /* user quota */
 #define EXT2_MOUNT_GRPQUOTA		0x040000  /* group quota */
@@ -789,7 +789,7 @@ extern int ext2_fsync(struct file *file, loff_t start, loff_t end,
 		      int datasync);
 extern const struct inode_operations ext2_file_inode_operations;
 extern const struct file_operations ext2_file_operations;
-extern const struct file_operations ext2_xip_file_operations;
+extern const struct file_operations ext2_dax_file_operations;
 
 /* inode.c */
 extern const struct address_space_operations ext2_aops;
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index ae7f000..f9bcb9b 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -110,7 +110,7 @@ const struct file_operations ext2_file_operations = {
 };
 
 #ifdef CONFIG_FS_DAX
-const struct file_operations ext2_xip_file_operations = {
+const struct file_operations ext2_dax_file_operations = {
 	.llseek		= generic_file_llseek,
 	.read		= do_sync_read,
 	.write		= do_sync_write,
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 7ca76da..3776063 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -1285,7 +1285,7 @@ void ext2_set_inode_flags(struct inode *inode)
 		inode->i_flags |= S_NOATIME;
 	if (flags & EXT2_DIRSYNC_FL)
 		inode->i_flags |= S_DIRSYNC;
-	if (test_opt(inode->i_sb, XIP))
+	if (test_opt(inode->i_sb, DAX))
 		inode->i_flags |= S_DAX;
 }
 
@@ -1387,9 +1387,9 @@ struct inode *ext2_iget (struct super_block *sb, unsigned long ino)
 
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
index fdcacf7..8062373 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -288,7 +288,7 @@ static int ext2_show_options(struct seq_file *seq, struct dentry *root)
 #endif
 
 #ifdef CONFIG_FS_DAX
-	if (sbi->s_mount_opt & EXT2_MOUNT_XIP)
+	if (sbi->s_mount_opt & EXT2_MOUNT_DAX)
 		seq_puts(seq, ",xip");
 #endif
 
@@ -393,7 +393,7 @@ enum {
 	Opt_resgid, Opt_resuid, Opt_sb, Opt_err_cont, Opt_err_panic,
 	Opt_err_ro, Opt_nouid32, Opt_nocheck, Opt_debug,
 	Opt_oldalloc, Opt_orlov, Opt_nobh, Opt_user_xattr, Opt_nouser_xattr,
-	Opt_acl, Opt_noacl, Opt_xip, Opt_ignore, Opt_err, Opt_quota,
+	Opt_acl, Opt_noacl, Opt_dax, Opt_ignore, Opt_err, Opt_quota,
 	Opt_usrquota, Opt_grpquota, Opt_reservation, Opt_noreservation
 };
 
@@ -421,7 +421,7 @@ static const match_table_t tokens = {
 	{Opt_nouser_xattr, "nouser_xattr"},
 	{Opt_acl, "acl"},
 	{Opt_noacl, "noacl"},
-	{Opt_xip, "xip"},
+	{Opt_dax, "xip"},
 	{Opt_grpquota, "grpquota"},
 	{Opt_ignore, "noquota"},
 	{Opt_quota, "quota"},
@@ -548,9 +548,9 @@ static int parse_options(char *options, struct super_block *sb)
 				"(no)acl options not supported");
 			break;
 #endif
-		case Opt_xip:
+		case Opt_dax:
 #ifdef CONFIG_FS_DAX
-			set_opt (sbi->s_mount_opt, XIP);
+			set_opt (sbi->s_mount_opt, DAX);
 #else
 			ext2_msg(sb, KERN_INFO, "xip option not supported");
 #endif
@@ -896,7 +896,7 @@ static int ext2_fill_super(struct super_block *sb, void *data, int silent)
 
 	blocksize = BLOCK_SIZE << le32_to_cpu(sbi->s_es->s_log_block_size);
 
-	if (sbi->s_mount_opt & EXT2_MOUNT_XIP) {
+	if (sbi->s_mount_opt & EXT2_MOUNT_DAX) {
 		if (blocksize != PAGE_SIZE) {
 			ext2_msg(sb, KERN_ERR,
 					"error: unsupported blocksize for xip");
@@ -1275,10 +1275,10 @@ static int ext2_remount (struct super_block * sb, int * flags, char * data)
 		((sbi->s_mount_opt & EXT2_MOUNT_POSIX_ACL) ? MS_POSIXACL : 0);
 
 	es = sbi->s_es;
-	if ((sbi->s_mount_opt ^ old_opts.s_mount_opt) & EXT2_MOUNT_XIP) {
+	if ((sbi->s_mount_opt ^ old_opts.s_mount_opt) & EXT2_MOUNT_DAX) {
 		ext2_msg(sb, KERN_WARNING, "warning: refusing change of "
 			 "xip flag with busy inodes while remounting");
-		sbi->s_mount_opt ^= EXT2_MOUNT_XIP;
+		sbi->s_mount_opt ^= EXT2_MOUNT_DAX;
 	}
 	if ((*flags & MS_RDONLY) == (sb->s_flags & MS_RDONLY)) {
 		spin_unlock(&sbi->s_lock);
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
