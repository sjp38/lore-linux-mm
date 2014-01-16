Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id AFFA46B0074
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 20:25:17 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so1872117pde.41
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 17:25:17 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ek3si5333234pbd.115.2014.01.15.17.25.15
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 17:25:16 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v5 19/22] ext4: Add XIP functionality
Date: Wed, 15 Jan 2014 20:24:37 -0500
Message-Id: <3474d9e83bf7e0c479968552c625e8e3b58dfe32.1389779962.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1389779961.git.matthew.r.wilcox@intel.com>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1389779961.git.matthew.r.wilcox@intel.com>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>

From: Ross Zwisler <ross.zwisler@linux.intel.com>

This is a port of the XIP functionality found in the current version of
ext2.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
[heavily tweaked]
Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 Documentation/filesystems/ext4.txt |  2 ++
 Documentation/filesystems/xip.txt  |  1 +
 fs/ext4/ext4.h                     |  2 ++
 fs/ext4/file.c                     | 53 +++++++++++++++++++++++++++----
 fs/ext4/indirect.c                 | 19 +++++++----
 fs/ext4/inode.c                    | 64 +++++++++++++++++++++++++++-----------
 fs/ext4/namei.c                    | 10 ++++--
 fs/ext4/super.c                    | 39 ++++++++++++++++++++++-
 8 files changed, 157 insertions(+), 33 deletions(-)

diff --git a/Documentation/filesystems/ext4.txt b/Documentation/filesystems/ext4.txt
index 919a329..06dab5e 100644
--- a/Documentation/filesystems/ext4.txt
+++ b/Documentation/filesystems/ext4.txt
@@ -386,6 +386,8 @@ max_dir_size_kb=n	This limits the size of directories so that any
 i_version		Enable 64-bit inode version support. This option is
 			off by default.
 
+xip			Use execute in place (no caching) if possible
+
 Data Mode
 =========
 There are 3 different data modes:
diff --git a/Documentation/filesystems/xip.txt b/Documentation/filesystems/xip.txt
index a8bccb6..b158de6 100644
--- a/Documentation/filesystems/xip.txt
+++ b/Documentation/filesystems/xip.txt
@@ -67,6 +67,7 @@ work correctly.
 
 These filesystems may be used for inspiration:
 - ext2: the second extended filesystem, see Documentation/filesystems/ext2.txt
+- ext4: the fourth extended filesystem, see Documentation/filesystems/ext4.txt
 
 
 Shortcomings
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index a48d367..5b160da 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -954,6 +954,7 @@ struct ext4_inode_info {
 #define EXT4_MOUNT_ERRORS_MASK		0x00070
 #define EXT4_MOUNT_MINIX_DF		0x00080	/* Mimics the Minix statfs */
 #define EXT4_MOUNT_NOLOAD		0x00100	/* Don't use existing journal*/
+#define EXT4_MOUNT_XIP			0x00200	/* Execute in place */
 #define EXT4_MOUNT_DATA_FLAGS		0x00C00	/* Mode for data writes: */
 #define EXT4_MOUNT_JOURNAL_DATA		0x00400	/* Write data to journal */
 #define EXT4_MOUNT_ORDERED_DATA		0x00800	/* Flush data before commit */
@@ -2569,6 +2570,7 @@ extern const struct file_operations ext4_dir_operations;
 /* file.c */
 extern const struct inode_operations ext4_file_inode_operations;
 extern const struct file_operations ext4_file_operations;
+extern const struct file_operations ext4_xip_file_operations;
 extern loff_t ext4_llseek(struct file *file, loff_t offset, int origin);
 extern void ext4_unwritten_wait(struct inode *inode);
 
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 3da2194..fb18af0 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -190,7 +190,7 @@ ext4_file_write(struct kiocb *iocb, const struct iovec *iov,
 		}
 	}
 
-	if (unlikely(iocb->ki_filp->f_flags & O_DIRECT))
+	if (io_is_direct(iocb->ki_filp))
 		ret = ext4_file_dio_write(iocb, iov, nr_segs, pos);
 	else
 		ret = generic_file_aio_write(iocb, iov, nr_segs, pos);
@@ -198,6 +198,27 @@ ext4_file_write(struct kiocb *iocb, const struct iovec *iov,
 	return ret;
 }
 
+#ifdef CONFIG_FS_XIP
+static int ext4_xip_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	return xip_fault(vma, vmf, ext4_get_block);
+					/* Is this the right get_block? */
+}
+
+static int ext4_xip_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	return xip_mkwrite(vma, vmf, ext4_get_block);
+}
+
+static const struct vm_operations_struct ext4_xip_vm_ops = {
+	.fault		= ext4_xip_fault,
+	.page_mkwrite	= ext4_xip_mkwrite,
+	.remap_pages	= generic_file_remap_pages,
+};
+#else
+#define ext4_xip_vm_ops	ext4_file_vm_ops
+#endif
+
 static const struct vm_operations_struct ext4_file_vm_ops = {
 	.fault		= filemap_fault,
 	.page_mkwrite   = ext4_page_mkwrite,
@@ -206,12 +227,13 @@ static const struct vm_operations_struct ext4_file_vm_ops = {
 
 static int ext4_file_mmap(struct file *file, struct vm_area_struct *vma)
 {
-	struct address_space *mapping = file->f_mapping;
-
-	if (!mapping->a_ops->readpage)
-		return -ENOEXEC;
 	file_accessed(file);
-	vma->vm_ops = &ext4_file_vm_ops;
+	if (IS_XIP(file_inode(file))) {
+		vma->vm_ops = &ext4_xip_vm_ops;
+		vma->vm_flags |= VM_MIXEDMAP;
+	} else {
+		vma->vm_ops = &ext4_file_vm_ops;
+	}
 	return 0;
 }
 
@@ -609,6 +631,25 @@ const struct file_operations ext4_file_operations = {
 	.fallocate	= ext4_fallocate,
 };
 
+#ifdef CONFIG_FS_XIP
+const struct file_operations ext4_xip_file_operations = {
+	.llseek		= ext4_llseek,
+	.read		= do_sync_read,
+	.write		= do_sync_write,
+	.aio_read	= generic_file_aio_read,
+	.aio_write	= ext4_file_write,
+	.unlocked_ioctl = ext4_ioctl,
+#ifdef CONFIG_COMPAT
+	.compat_ioctl	= ext4_compat_ioctl,
+#endif
+	.mmap		= ext4_file_mmap,
+	.open		= ext4_file_open,
+	.release	= ext4_release_file,
+	.fsync		= ext4_sync_file,
+	.fallocate	= ext4_fallocate,
+};
+#endif
+
 const struct inode_operations ext4_file_inode_operations = {
 	.setattr	= ext4_setattr,
 	.getattr	= ext4_getattr,
diff --git a/fs/ext4/indirect.c b/fs/ext4/indirect.c
index 594009f..ef2bdef 100644
--- a/fs/ext4/indirect.c
+++ b/fs/ext4/indirect.c
@@ -686,15 +686,22 @@ retry:
 			inode_dio_done(inode);
 			goto locked;
 		}
-		ret = __blockdev_direct_IO(rw, iocb, inode,
-				 inode->i_sb->s_bdev, iov,
-				 offset, nr_segs,
-				 ext4_get_block, NULL, NULL, 0);
+		if (IS_XIP(inode))
+			ret = xip_do_io(rw, iocb, inode, iov, offset, nr_segs,
+					ext4_get_block, NULL, 0);
+		else
+			ret = __blockdev_direct_IO(rw, iocb, inode,
+					inode->i_sb->s_bdev, iov, offset,
+					nr_segs, ext4_get_block, NULL, NULL, 0);
 		inode_dio_done(inode);
 	} else {
 locked:
-		ret = blockdev_direct_IO(rw, iocb, inode, iov,
-				 offset, nr_segs, ext4_get_block);
+		if (IS_XIP(inode))
+			ret = xip_do_io(rw, iocb, inode, iov, offset, nr_segs,
+					ext4_get_block, NULL, 0);
+		else
+			ret = blockdev_direct_IO(rw, iocb, inode, iov,
+					offset, nr_segs, ext4_get_block);
 
 		if (unlikely((rw & WRITE) && ret < 0)) {
 			loff_t isize = i_size_read(inode);
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index c767666..8b73d77 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -663,6 +663,18 @@ found:
 			WARN_ON(1);
 		}
 
+		/* this is probably wrong for ext4.  unlike ext2, ext4 supports
+		 * uninitialised extents, so we should probably be hooking
+		 * into the "make it initialised" code instead. */
+		if (IS_XIP(inode)) {
+			ret = xip_clear_blocks(inode, map->m_pblk,
+						map->m_len << inode->i_blkbits);
+			if (ret) {
+				retval = ret;
+				goto has_zeroout;
+			}
+		}
+
 		/*
 		 * If the extent has been zeroed out, we don't need to update
 		 * extent status tree.
@@ -3152,13 +3164,14 @@ static ssize_t ext4_ext_direct_IO(int rw, struct kiocb *iocb,
 		get_block_func = ext4_get_block_write;
 		dio_flags = DIO_LOCKING;
 	}
-	ret = __blockdev_direct_IO(rw, iocb, inode,
-				   inode->i_sb->s_bdev, iov,
-				   offset, nr_segs,
-				   get_block_func,
-				   ext4_end_io_dio,
-				   NULL,
-				   dio_flags);
+	if (IS_XIP(inode))
+		ret = xip_do_io(rw, iocb, inode, iov, offset, nr_segs,
+				get_block_func, ext4_end_io_dio, dio_flags);
+	else
+		ret = __blockdev_direct_IO(rw, iocb, inode,
+					   inode->i_sb->s_bdev, iov, offset,
+					   nr_segs, get_block_func,
+					   ext4_end_io_dio, NULL, dio_flags);
 
 	/*
 	 * Put our reference to io_end. This can free the io_end structure e.g.
@@ -3323,14 +3336,7 @@ void ext4_set_aops(struct inode *inode)
 		inode->i_mapping->a_ops = &ext4_aops;
 }
 
-/*
- * ext4_block_zero_page_range() zeros out a mapping of length 'length'
- * starting from file offset 'from'.  The range to be zero'd must
- * be contained with in one block.  If the specified range exceeds
- * the end of the block it will be shortened to end of the block
- * that cooresponds to 'from'
- */
-static int ext4_block_zero_page_range(handle_t *handle,
+static int __ext4_block_zero_page_range(handle_t *handle,
 		struct address_space *mapping, loff_t from, loff_t length)
 {
 	ext4_fsblk_t index = from >> PAGE_CACHE_SHIFT;
@@ -3421,6 +3427,22 @@ unlock:
 }
 
 /*
+ * ext4_block_zero_page_range() zeros out a mapping of length 'length'
+ * starting from file offset 'from'.  The range to be zero'd must
+ * be contained with in one block.  If the specified range exceeds
+ * the end of the block it will be shortened to end of the block
+ * that cooresponds to 'from'
+ */
+static int ext4_block_zero_page_range(handle_t *handle,
+		struct address_space *mapping, loff_t from, loff_t length)
+{
+	struct inode *inode = mapping->host;
+	if (IS_XIP(inode))
+		return xip_zero_page_range(inode, from, length, ext4_get_block);
+	return __ext4_block_zero_page_range(handle, mapping, from, length);
+}
+
+/*
  * ext4_block_truncate_page() zeroes out a mapping from file offset `from'
  * up to the end of the block which corresponds to `from'.
  * This required during truncate. We need to physically zero the tail end
@@ -3939,7 +3961,8 @@ void ext4_set_inode_flags(struct inode *inode)
 {
 	unsigned int flags = EXT4_I(inode)->i_flags;
 
-	inode->i_flags &= ~(S_SYNC|S_APPEND|S_IMMUTABLE|S_NOATIME|S_DIRSYNC);
+	inode->i_flags &= ~(S_SYNC | S_APPEND | S_IMMUTABLE | S_NOATIME |
+				S_DIRSYNC | S_XIP);
 	if (flags & EXT4_SYNC_FL)
 		inode->i_flags |= S_SYNC;
 	if (flags & EXT4_APPEND_FL)
@@ -3950,6 +3973,8 @@ void ext4_set_inode_flags(struct inode *inode)
 		inode->i_flags |= S_NOATIME;
 	if (flags & EXT4_DIRSYNC_FL)
 		inode->i_flags |= S_DIRSYNC;
+	if (test_opt(inode->i_sb, XIP))
+		inode->i_flags |= S_XIP;
 }
 
 /* Propagate flags from i_flags to EXT4_I(inode)->i_flags */
@@ -4201,7 +4226,10 @@ struct inode *ext4_iget(struct super_block *sb, unsigned long ino)
 
 	if (S_ISREG(inode->i_mode)) {
 		inode->i_op = &ext4_file_inode_operations;
-		inode->i_fop = &ext4_file_operations;
+		if (test_opt(inode->i_sb, XIP))
+			inode->i_fop = &ext4_xip_file_operations;
+		else
+			inode->i_fop = &ext4_file_operations;
 		ext4_set_aops(inode);
 	} else if (S_ISDIR(inode->i_mode)) {
 		inode->i_op = &ext4_dir_inode_operations;
@@ -4653,7 +4681,7 @@ int ext4_setattr(struct dentry *dentry, struct iattr *attr)
 		 * Truncate pagecache after we've waited for commit
 		 * in data=journal mode to make pages freeable.
 		 */
-			truncate_pagecache(inode, inode->i_size);
+		truncate_pagecache(inode, inode->i_size);
 	}
 	/*
 	 * We want to call ext4_truncate() even if attr->ia_size ==
diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index 5a0408d..ac68129 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -2250,7 +2250,10 @@ retry:
 	err = PTR_ERR(inode);
 	if (!IS_ERR(inode)) {
 		inode->i_op = &ext4_file_inode_operations;
-		inode->i_fop = &ext4_file_operations;
+		if (test_opt(inode->i_sb, XIP))
+			inode->i_fop = &ext4_xip_file_operations;
+		else
+			inode->i_fop = &ext4_file_operations;
 		ext4_set_aops(inode);
 		err = ext4_add_nondir(handle, dentry, inode);
 		if (!err && IS_DIRSYNC(dir))
@@ -2314,7 +2317,10 @@ retry:
 	err = PTR_ERR(inode);
 	if (!IS_ERR(inode)) {
 		inode->i_op = &ext4_file_inode_operations;
-		inode->i_fop = &ext4_file_operations;
+		if (test_opt(inode->i_sb, XIP))
+			inode->i_fop = &ext4_xip_file_operations;
+		else
+			inode->i_fop = &ext4_file_operations;
 		ext4_set_aops(inode);
 		d_tmpfile(dentry, inode);
 		err = ext4_orphan_add(handle, inode);
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index c977f4e..309a1a3 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1156,7 +1156,7 @@ enum {
 	Opt_usrjquota, Opt_grpjquota, Opt_offusrjquota, Opt_offgrpjquota,
 	Opt_jqfmt_vfsold, Opt_jqfmt_vfsv0, Opt_jqfmt_vfsv1, Opt_quota,
 	Opt_noquota, Opt_barrier, Opt_nobarrier, Opt_err,
-	Opt_usrquota, Opt_grpquota, Opt_i_version,
+	Opt_usrquota, Opt_grpquota, Opt_i_version, Opt_xip,
 	Opt_stripe, Opt_delalloc, Opt_nodelalloc, Opt_mblk_io_submit,
 	Opt_nomblk_io_submit, Opt_block_validity, Opt_noblock_validity,
 	Opt_inode_readahead_blks, Opt_journal_ioprio,
@@ -1218,6 +1218,7 @@ static const match_table_t tokens = {
 	{Opt_barrier, "barrier"},
 	{Opt_nobarrier, "nobarrier"},
 	{Opt_i_version, "i_version"},
+	{Opt_xip, "xip"},
 	{Opt_stripe, "stripe=%u"},
 	{Opt_delalloc, "delalloc"},
 	{Opt_nodelalloc, "nodelalloc"},
@@ -1400,6 +1401,7 @@ static const struct mount_opts {
 	{Opt_min_batch_time, 0, MOPT_GTE0},
 	{Opt_inode_readahead_blks, 0, MOPT_GTE0},
 	{Opt_init_itable, 0, MOPT_GTE0},
+	{Opt_xip, EXT4_MOUNT_XIP, MOPT_SET},
 	{Opt_stripe, 0, MOPT_GTE0},
 	{Opt_resuid, 0, MOPT_GTE0},
 	{Opt_resgid, 0, MOPT_GTE0},
@@ -1638,6 +1640,11 @@ static int handle_mount_opt(struct super_block *sb, char *opt, int token,
 		}
 		sbi->s_jquota_fmt = m->mount_opt;
 #endif
+#ifndef CONFIG_FS_XIP
+	} else if (token == Opt_xip) {
+		ext4_msg(sb, KERN_INFO, "xip option not supported");
+		return -1;
+#endif
 	} else {
 		if (!args->from)
 			arg = 1;
@@ -3551,6 +3558,11 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 				 "both data=journal and dioread_nolock");
 			goto failed_mount;
 		}
+		if (test_opt(sb, XIP)) {
+			ext4_msg(sb, KERN_ERR, "can't mount with "
+				 "both data=journal and xip");
+			goto failed_mount;
+		}
 		if (test_opt(sb, DELALLOC))
 			clear_opt(sb, DELALLOC);
 	}
@@ -3604,6 +3616,19 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 		goto failed_mount;
 	}
 
+	if (sbi->s_mount_opt & EXT4_MOUNT_XIP) {
+		if (blocksize != PAGE_SIZE) {
+			ext4_msg(sb, KERN_ERR,
+					"error: unsupported blocksize for xip");
+			goto failed_mount;
+		}
+		if (!sb->s_bdev->bd_disk->fops->direct_access) {
+			ext4_msg(sb, KERN_ERR,
+					"error: device does not support xip");
+			goto failed_mount;
+		}
+	}
+
 	if (sb->s_blocksize != blocksize) {
 		/* Validate the filesystem blocksize */
 		if (!sb_set_blocksize(sb, blocksize)) {
@@ -4798,6 +4823,18 @@ static int ext4_remount(struct super_block *sb, int *flags, char *data)
 			err = -EINVAL;
 			goto restore_opts;
 		}
+		if (test_opt(sb, XIP)) {
+			ext4_msg(sb, KERN_ERR, "can't mount with "
+				 "both data=journal and xip");
+			err = -EINVAL;
+			goto restore_opts;
+		}
+	}
+
+	if ((sbi->s_mount_opt ^ old_opts.s_mount_opt) & EXT4_MOUNT_XIP) {
+		ext4_msg(sb, KERN_WARNING, "warning: refusing change of "
+			"xip flag with busy inodes while remounting");
+		sbi->s_mount_opt ^= EXT4_MOUNT_XIP;
 	}
 
 	if (sbi->s_mount_flags & EXT4_MF_FS_ABORTED)
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
