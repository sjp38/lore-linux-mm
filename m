Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 150386B0260
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 22:00:31 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id td3so27596747pab.2
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 19:00:31 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id h88si2504247pfh.115.2016.03.29.19.00.22
        for <linux-mm@kvack.org>;
        Tue, 29 Mar 2016 19:00:22 -0700 (PDT)
From: Vishal Verma <vishal.l.verma@intel.com>
Subject: [PATCH v2 5/5] dax: handle media errors in dax_do_io
Date: Tue, 29 Mar 2016 19:59:50 -0600
Message-Id: <1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
In-Reply-To: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Vishal Verma <vishal.l.verma@intel.com>, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew.r.wilcox@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>

dax_do_io (called for read() or write() for a dax file system) may fail
in the presence of bad blocks or media errors. Since we expect that a
write should clear media errors on nvdimms, make dax_do_io fall back to
the direct_IO path, which will send down a bio to the driver, which can
then attempt to clear the error.

Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Jens Axboe <axboe@fb.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Vishal Verma <vishal.l.verma@intel.com>
---
 fs/block_dev.c     | 17 ++++++++++++++---
 fs/ext2/inode.c    | 22 +++++++++++++++-------
 fs/ext4/indirect.c | 18 +++++++++++++-----
 fs/ext4/inode.c    | 21 ++++++++++++++-------
 fs/xfs/xfs_aops.c  | 14 ++++++++++++--
 5 files changed, 68 insertions(+), 24 deletions(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index c5837fa..d6113b9 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -166,13 +166,24 @@ blkdev_direct_IO(struct kiocb *iocb, struct iov_iter *iter, loff_t offset)
 {
 	struct file *file = iocb->ki_filp;
 	struct inode *inode = bdev_file_inode(file);
+	ssize_t ret, ret_saved = 0;
 
-	if (IS_DAX(inode))
-		return dax_do_io(iocb, inode, iter, offset, blkdev_get_block,
+	if (IS_DAX(inode)) {
+		ret = dax_do_io(iocb, inode, iter, offset, blkdev_get_block,
 				NULL, DIO_SKIP_DIO_COUNT);
-	return __blockdev_direct_IO(iocb, inode, I_BDEV(inode), iter, offset,
+		if (ret == -EIO && (iov_iter_rw(iter) == WRITE))
+			ret_saved = ret;
+		else
+			return ret;
+	}
+
+	ret = __blockdev_direct_IO(iocb, inode, I_BDEV(inode), iter, offset,
 				    blkdev_get_block, NULL, NULL,
 				    DIO_SKIP_DIO_COUNT);
+	if (ret < 0 && ret_saved)
+		return ret_saved;
+
+	return ret;
 }
 
 int __sync_blockdev(struct block_device *bdev, int wait)
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 824f249..64792c6 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -859,14 +859,22 @@ ext2_direct_IO(struct kiocb *iocb, struct iov_iter *iter, loff_t offset)
 	struct address_space *mapping = file->f_mapping;
 	struct inode *inode = mapping->host;
 	size_t count = iov_iter_count(iter);
-	ssize_t ret;
+	ssize_t ret, ret_saved = 0;
 
-	if (IS_DAX(inode))
-		ret = dax_do_io(iocb, inode, iter, offset, ext2_get_block, NULL,
-				DIO_LOCKING);
-	else
-		ret = blockdev_direct_IO(iocb, inode, iter, offset,
-					 ext2_get_block);
+	if (IS_DAX(inode)) {
+		ret = dax_do_io(iocb, inode, iter, offset, ext2_get_block,
+				NULL, DIO_LOCKING | DIO_SKIP_HOLES);
+		if (ret == -EIO && iov_iter_rw(iter) == WRITE)
+			ret_saved = ret;
+		else
+			goto out;
+	}
+
+	ret = blockdev_direct_IO(iocb, inode, iter, offset, ext2_get_block);
+	if (ret < 0 && ret_saved)
+		ret = ret_saved;
+
+ out:
 	if (ret < 0 && iov_iter_rw(iter) == WRITE)
 		ext2_write_failed(mapping, offset + count);
 	return ret;
diff --git a/fs/ext4/indirect.c b/fs/ext4/indirect.c
index 3027fa6..798f341 100644
--- a/fs/ext4/indirect.c
+++ b/fs/ext4/indirect.c
@@ -716,14 +716,22 @@ retry:
 						   NULL, NULL, 0);
 		inode_dio_end(inode);
 	} else {
+		ssize_t ret_saved = 0;
+
 locked:
-		if (IS_DAX(inode))
+		if (IS_DAX(inode)) {
 			ret = dax_do_io(iocb, inode, iter, offset,
 					ext4_dio_get_block, NULL, DIO_LOCKING);
-		else
-			ret = blockdev_direct_IO(iocb, inode, iter, offset,
-						 ext4_dio_get_block);
-
+			if (ret == -EIO && iov_iter_rw(iter) == WRITE)
+				ret_saved = ret;
+			else
+				goto skip_dio;
+		}
+		ret = blockdev_direct_IO(iocb, inode, iter, offset,
+					 ext4_get_block);
+		if (ret < 0 && ret_saved)
+			ret = ret_saved;
+skip_dio:
 		if (unlikely(iov_iter_rw(iter) == WRITE && ret < 0)) {
 			loff_t isize = i_size_read(inode);
 			loff_t end = offset + count;
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index dab84a2..27f07c2 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3341,7 +3341,7 @@ static ssize_t ext4_ext_direct_IO(struct kiocb *iocb, struct iov_iter *iter,
 {
 	struct file *file = iocb->ki_filp;
 	struct inode *inode = file->f_mapping->host;
-	ssize_t ret;
+	ssize_t ret, ret_saved = 0;
 	size_t count = iov_iter_count(iter);
 	int overwrite = 0;
 	get_block_t *get_block_func = NULL;
@@ -3401,15 +3401,22 @@ static ssize_t ext4_ext_direct_IO(struct kiocb *iocb, struct iov_iter *iter,
 #ifdef CONFIG_EXT4_FS_ENCRYPTION
 	BUG_ON(ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode));
 #endif
-	if (IS_DAX(inode))
+	if (IS_DAX(inode)) {
 		ret = dax_do_io(iocb, inode, iter, offset, get_block_func,
 				ext4_end_io_dio, dio_flags);
-	else
-		ret = __blockdev_direct_IO(iocb, inode,
-					   inode->i_sb->s_bdev, iter, offset,
-					   get_block_func,
-					   ext4_end_io_dio, NULL, dio_flags);
+		if (ret == -EIO && iov_iter_rw(iter) == WRITE)
+			ret_saved = ret;
+		else
+			goto skip_dio;
+	}
 
+	ret = __blockdev_direct_IO(iocb, inode,
+				   inode->i_sb->s_bdev, iter, offset,
+				   get_block_func,
+				   ext4_end_io_dio, NULL, dio_flags);
+	if (ret < 0 && ret_saved)
+		ret = ret_saved;
+ skip_dio:
 	if (ret > 0 && !overwrite && ext4_test_inode_state(inode,
 						EXT4_STATE_DIO_UNWRITTEN)) {
 		int err;
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index d445a64..7cfcf86 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1413,6 +1413,7 @@ xfs_vm_direct_IO(
 	dio_iodone_t		*endio = NULL;
 	int			flags = 0;
 	struct block_device	*bdev;
+	ssize_t 		ret, ret_saved = 0;
 
 	if (iov_iter_rw(iter) == WRITE) {
 		endio = xfs_end_io_direct_write;
@@ -1420,13 +1421,22 @@ xfs_vm_direct_IO(
 	}
 
 	if (IS_DAX(inode)) {
-		return dax_do_io(iocb, inode, iter, offset,
+		ret = dax_do_io(iocb, inode, iter, offset,
 				 xfs_get_blocks_direct, endio, 0);
+		if (ret == -EIO && iov_iter_rw(iter) == WRITE)
+			ret_saved = ret;
+		else
+			return ret;
 	}
 
 	bdev = xfs_find_bdev_for_inode(inode);
-	return  __blockdev_direct_IO(iocb, inode, bdev, iter, offset,
+	ret = __blockdev_direct_IO(iocb, inode, bdev, iter, offset,
 			xfs_get_blocks_direct, endio, NULL, flags);
+
+	if (ret < 0 && ret_saved)
+		ret = ret_saved;
+
+	return ret;
 }
 
 /*
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
