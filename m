Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0D3076B006E
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 04:45:14 -0400 (EDT)
Received: by wgin8 with SMTP id n8so48488446wgi.0
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 01:45:13 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id eh5si8931029wic.102.2015.04.07.01.45.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Apr 2015 01:45:13 -0700 (PDT)
Received: by widjs5 with SMTP id js5so5553290wid.1
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 01:45:12 -0700 (PDT)
Message-ID: <55239915.7030003@plexistor.com>
Date: Tue, 07 Apr 2015 11:45:09 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [PATCH 3/3] dax: Unify ext2/4_{dax,}_file_operations
References: <55239645.9000507@plexistor.com>
In-Reply-To: <55239645.9000507@plexistor.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>, Christoph Hellwig <hch@infradead.org>
Cc: Stable Tree <stable@vger.kernel.org>


The original dax patchset split the ext2/4_file_operations
because of the two NULL splice_read/splice_write in the dax
case.

At vfs if splice_read/splice_write are NULL would then call
default_splice_read/write.

What we do here is make generic_file_splice_read aware of
IS_DAX() so the original ext2/4_file_operations can be used
as is.

For write it appears that iter_file_splice_write is just fine.
It uses the regular f_op->write(file,..) or new_sync_write(file, ...).

CC: Dave Chinner <dchinner@redhat.com>
CC: Matthew Wilcox <willy@linux.intel.com>
Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
---
 fs/ext2/ext2.h  |  1 -
 fs/ext2/file.c  | 18 ------------------
 fs/ext2/inode.c |  5 +----
 fs/ext2/namei.c | 10 ++--------
 fs/ext4/ext4.h  |  1 -
 fs/ext4/file.c  | 20 --------------------
 fs/ext4/inode.c |  5 +----
 fs/ext4/namei.c | 10 ++--------
 fs/splice.c     |  3 +++
 9 files changed, 9 insertions(+), 64 deletions(-)

diff --git a/fs/ext2/ext2.h b/fs/ext2/ext2.h
index 678f9ab..8d15feb 100644
--- a/fs/ext2/ext2.h
+++ b/fs/ext2/ext2.h
@@ -793,7 +793,6 @@ extern int ext2_fsync(struct file *file, loff_t start, loff_t end,
 		      int datasync);
 extern const struct inode_operations ext2_file_inode_operations;
 extern const struct file_operations ext2_file_operations;
-extern const struct file_operations ext2_dax_file_operations;
 
 /* inode.c */
 extern const struct address_space_operations ext2_aops;
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index 866a3ce..19cac93 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -109,24 +109,6 @@ const struct file_operations ext2_file_operations = {
 	.splice_write	= iter_file_splice_write,
 };
 
-#ifdef CONFIG_FS_DAX
-const struct file_operations ext2_dax_file_operations = {
-	.llseek		= generic_file_llseek,
-	.read		= new_sync_read,
-	.write		= new_sync_write,
-	.read_iter	= generic_file_read_iter,
-	.write_iter	= generic_file_write_iter,
-	.unlocked_ioctl = ext2_ioctl,
-#ifdef CONFIG_COMPAT
-	.compat_ioctl	= ext2_compat_ioctl,
-#endif
-	.mmap		= ext2_file_mmap,
-	.open		= dquot_file_open,
-	.release	= ext2_release_file,
-	.fsync		= ext2_fsync,
-};
-#endif
-
 const struct inode_operations ext2_file_inode_operations = {
 #ifdef CONFIG_EXT2_FS_XATTR
 	.setxattr	= generic_setxattr,
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index df9d6af..b29eb67 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -1388,10 +1388,7 @@ struct inode *ext2_iget (struct super_block *sb, unsigned long ino)
 
 	if (S_ISREG(inode->i_mode)) {
 		inode->i_op = &ext2_file_inode_operations;
-		if (test_opt(inode->i_sb, DAX)) {
-			inode->i_mapping->a_ops = &ext2_aops;
-			inode->i_fop = &ext2_dax_file_operations;
-		} else if (test_opt(inode->i_sb, NOBH)) {
+		if (test_opt(inode->i_sb, NOBH)) {
 			inode->i_mapping->a_ops = &ext2_nobh_aops;
 			inode->i_fop = &ext2_file_operations;
 		} else {
diff --git a/fs/ext2/namei.c b/fs/ext2/namei.c
index 148f6e3..ce42293 100644
--- a/fs/ext2/namei.c
+++ b/fs/ext2/namei.c
@@ -104,10 +104,7 @@ static int ext2_create (struct inode * dir, struct dentry * dentry, umode_t mode
 		return PTR_ERR(inode);
 
 	inode->i_op = &ext2_file_inode_operations;
-	if (test_opt(inode->i_sb, DAX)) {
-		inode->i_mapping->a_ops = &ext2_aops;
-		inode->i_fop = &ext2_dax_file_operations;
-	} else if (test_opt(inode->i_sb, NOBH)) {
+	if (test_opt(inode->i_sb, NOBH)) {
 		inode->i_mapping->a_ops = &ext2_nobh_aops;
 		inode->i_fop = &ext2_file_operations;
 	} else {
@@ -125,10 +122,7 @@ static int ext2_tmpfile(struct inode *dir, struct dentry *dentry, umode_t mode)
 		return PTR_ERR(inode);
 
 	inode->i_op = &ext2_file_inode_operations;
-	if (test_opt(inode->i_sb, DAX)) {
-		inode->i_mapping->a_ops = &ext2_aops;
-		inode->i_fop = &ext2_dax_file_operations;
-	} else if (test_opt(inode->i_sb, NOBH)) {
+	if (test_opt(inode->i_sb, NOBH)) {
 		inode->i_mapping->a_ops = &ext2_nobh_aops;
 		inode->i_fop = &ext2_file_operations;
 	} else {
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index f63c3d5..8a3981e 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -2593,7 +2593,6 @@ extern const struct file_operations ext4_dir_operations;
 /* file.c */
 extern const struct inode_operations ext4_file_inode_operations;
 extern const struct file_operations ext4_file_operations;
-extern const struct file_operations ext4_dax_file_operations;
 extern loff_t ext4_llseek(struct file *file, loff_t offset, int origin);
 
 /* inline.c */
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index aa78c70..e6d4280 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -625,26 +625,6 @@ const struct file_operations ext4_file_operations = {
 	.fallocate	= ext4_fallocate,
 };
 
-#ifdef CONFIG_FS_DAX
-const struct file_operations ext4_dax_file_operations = {
-	.llseek		= ext4_llseek,
-	.read		= new_sync_read,
-	.write		= new_sync_write,
-	.read_iter	= generic_file_read_iter,
-	.write_iter	= ext4_file_write_iter,
-	.unlocked_ioctl = ext4_ioctl,
-#ifdef CONFIG_COMPAT
-	.compat_ioctl	= ext4_compat_ioctl,
-#endif
-	.mmap		= ext4_file_mmap,
-	.open		= ext4_file_open,
-	.release	= ext4_release_file,
-	.fsync		= ext4_sync_file,
-	/* Splice not yet supported with DAX */
-	.fallocate	= ext4_fallocate,
-};
-#endif
-
 const struct inode_operations ext4_file_inode_operations = {
 	.setattr	= ext4_setattr,
 	.getattr	= ext4_getattr,
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index a3f4513..035b7a0 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4090,10 +4090,7 @@ struct inode *ext4_iget(struct super_block *sb, unsigned long ino)
 
 	if (S_ISREG(inode->i_mode)) {
 		inode->i_op = &ext4_file_inode_operations;
-		if (test_opt(inode->i_sb, DAX))
-			inode->i_fop = &ext4_dax_file_operations;
-		else
-			inode->i_fop = &ext4_file_operations;
+		inode->i_fop = &ext4_file_operations;
 		ext4_set_aops(inode);
 	} else if (S_ISDIR(inode->i_mode)) {
 		inode->i_op = &ext4_dir_inode_operations;
diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index 28fe71a..2291923 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -2235,10 +2235,7 @@ retry:
 	err = PTR_ERR(inode);
 	if (!IS_ERR(inode)) {
 		inode->i_op = &ext4_file_inode_operations;
-		if (test_opt(inode->i_sb, DAX))
-			inode->i_fop = &ext4_dax_file_operations;
-		else
-			inode->i_fop = &ext4_file_operations;
+		inode->i_fop = &ext4_file_operations;
 		ext4_set_aops(inode);
 		err = ext4_add_nondir(handle, dentry, inode);
 		if (!err && IS_DIRSYNC(dir))
@@ -2302,10 +2299,7 @@ retry:
 	err = PTR_ERR(inode);
 	if (!IS_ERR(inode)) {
 		inode->i_op = &ext4_file_inode_operations;
-		if (test_opt(inode->i_sb, DAX))
-			inode->i_fop = &ext4_dax_file_operations;
-		else
-			inode->i_fop = &ext4_file_operations;
+		inode->i_fop = &ext4_file_operations;
 		ext4_set_aops(inode);
 		d_tmpfile(dentry, inode);
 		err = ext4_orphan_add(handle, inode);
diff --git a/fs/splice.c b/fs/splice.c
index 41cbb16..476024b 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -523,6 +523,9 @@ ssize_t generic_file_splice_read(struct file *in, loff_t *ppos,
 	loff_t isize, left;
 	int ret;
 
+	if (IS_DAX(in->f_mapping->host))
+		return default_file_splice_read(in, ppos, pipe, len, flags);
+
 	isize = i_size_read(in->f_mapping->host);
 	if (unlikely(*ppos >= isize))
 		return 0;
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
