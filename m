Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8B815828DF
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 22:34:43 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fy10so3251292pac.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 19:34:43 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id uv2si55489081pac.41.2016.02.16.19.34.42
        for <linux-mm@kvack.org>;
        Tue, 16 Feb 2016 19:34:42 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v3 6/6] block: use dax_do_io() if blkdev_dax_capable()
Date: Tue, 16 Feb 2016 20:34:19 -0700
Message-Id: <1455680059-20126-7-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1455680059-20126-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1455680059-20126-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dan Williams <dan.j.williams@intel.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Jens Axboe <axboe@kernel.dk>, Matthew Wilcox <willy@linux.intel.com>, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Al Viro <viro@ftp.linux.org.uk>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>

From: Dan Williams <dan.j.williams@intel.com>

Setting S_DAX on an inode requires that the inode participate in the
DAX-fsync mechanism which expects to use the pagecache for tracking
potentially dirty cpu cachelines.  However, dax_do_io() participates in
the standard pagecache sync semantics and arranges for dirty pages to be
flushed through the driver when a direct-IO operation accesses the same
ranges.

It should always be valid to use the dax_do_io() path regardless of
whether the block_device inode has S_DAX set.  In either case dirty
pages or dirty cachelines are made durable before the direct-IO
operation proceeds.

Cc: Jan Kara <jack@suse.cz>
Cc: Jens Axboe <axboe@fb.com>
Cc: Al Viro <viro@ftp.linux.org.uk>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 block/ioctl.c      |  1 +
 fs/block_dev.c     |  3 ++-
 include/linux/fs.h | 31 +++++++++++++++++++++----------
 3 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/block/ioctl.c b/block/ioctl.c
index d8996bb..7c64286 100644
--- a/block/ioctl.c
+++ b/block/ioctl.c
@@ -434,6 +434,7 @@ bool blkdev_dax_capable(struct block_device *bdev)
 
 	return true;
 }
+EXPORT_SYMBOL(blkdev_dax_capable);
 #endif
 
 static int blkdev_flushbuf(struct block_device *bdev, fmode_t mode,
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 826b164..0e937dd 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -166,8 +166,9 @@ blkdev_direct_IO(struct kiocb *iocb, struct iov_iter *iter, loff_t offset)
 {
 	struct file *file = iocb->ki_filp;
 	struct inode *inode = bdev_file_inode(file);
+	struct block_device *bdev = I_BDEV(inode);
 
-	if (IS_DAX(inode))
+	if (blkdev_dax_capable(bdev))
 		return dax_do_io(iocb, inode, iter, offset, blkdev_get_block,
 				NULL, DIO_SKIP_DIO_COUNT);
 	return __blockdev_direct_IO(iocb, inode, I_BDEV(inode), iter, offset,
diff --git a/include/linux/fs.h b/include/linux/fs.h
index ae68100..a3f5ee8 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -830,7 +830,14 @@ static inline unsigned imajor(const struct inode *inode)
 	return MAJOR(inode->i_rdev);
 }
 
+#ifdef CONFIG_BLOCK
 extern struct block_device *I_BDEV(struct inode *inode);
+#else
+static inline struct block_device *I_BDEV(struct inode *inode)
+{
+	return NULL;
+}
+#endif
 
 struct fown_struct {
 	rwlock_t lock;          /* protects pid, uid, euid fields */
@@ -2306,15 +2313,6 @@ extern struct super_block *freeze_bdev(struct block_device *);
 extern void emergency_thaw_all(void);
 extern int thaw_bdev(struct block_device *bdev, struct super_block *sb);
 extern int fsync_bdev(struct block_device *);
-#ifdef CONFIG_FS_DAX
-extern bool blkdev_dax_capable(struct block_device *bdev);
-#else
-static inline bool blkdev_dax_capable(struct block_device *bdev)
-{
-	return false;
-}
-#endif
-
 extern struct super_block *blockdev_superblock;
 
 static inline bool sb_is_blkdev_sb(struct super_block *sb)
@@ -2902,9 +2900,22 @@ extern int generic_show_options(struct seq_file *m, struct dentry *root);
 extern void save_mount_options(struct super_block *sb, char *options);
 extern void replace_mount_options(struct super_block *sb, char *options);
 
+#ifdef CONFIG_FS_DAX
+extern bool blkdev_dax_capable(struct block_device *bdev);
+#else
+static inline bool blkdev_dax_capable(struct block_device *bdev)
+{
+	return false;
+}
+#endif
+
 static inline bool io_is_direct(struct file *filp)
 {
-	return (filp->f_flags & O_DIRECT) || IS_DAX(filp->f_mapping->host);
+	struct inode *inode = filp->f_mapping->host;
+
+	return (filp->f_flags & O_DIRECT) || IS_DAX(inode)
+		|| (S_ISBLK(file_inode(filp)->i_mode)
+				&& blkdev_dax_capable(I_BDEV(inode)));
 }
 
 static inline int iocb_flags(struct file *file)
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
