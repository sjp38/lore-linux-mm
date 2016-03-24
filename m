Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id EBA7E6B0261
	for <linux-mm@kvack.org>; Thu, 24 Mar 2016 19:18:09 -0400 (EDT)
Received: by mail-pf0-f169.google.com with SMTP id n5so68963515pfn.2
        for <linux-mm@kvack.org>; Thu, 24 Mar 2016 16:18:09 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id tb4si295141pab.121.2016.03.24.16.18.07
        for <linux-mm@kvack.org>;
        Thu, 24 Mar 2016 16:18:07 -0700 (PDT)
From: Vishal Verma <vishal.l.verma@intel.com>
Subject: [PATCH 5/5] dax: handle media errors in dax_do_io
Date: Thu, 24 Mar 2016 17:17:30 -0600
Message-Id: <1458861450-17705-6-git-send-email-vishal.l.verma@intel.com>
In-Reply-To: <1458861450-17705-1-git-send-email-vishal.l.verma@intel.com>
References: <1458861450-17705-1-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Vishal Verma <vishal.l.verma@intel.com>, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew.r.wilcox@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

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
Signed-off-by: Vishal Verma <vishal.l.verma@intel.com>
---
 fs/block_dev.c      |  5 +++--
 fs/dax.c            | 34 ++++++++++++++++++++++++++++++++--
 fs/ext2/inode.c     |  5 +++--
 fs/ext4/indirect.c  | 11 +++++++----
 fs/ext4/inode.c     |  5 +++--
 fs/xfs/xfs_aops.c   |  7 ++++---
 include/linux/dax.h |  6 +++++-
 7 files changed, 57 insertions(+), 16 deletions(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index 9c0765b..f3873ab 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -168,8 +168,9 @@ blkdev_direct_IO(struct kiocb *iocb, struct iov_iter *iter, loff_t offset)
 	struct inode *inode = bdev_file_inode(file);
 
 	if (IS_DAX(inode))
-		return dax_do_io(iocb, inode, iter, offset, blkdev_get_block,
-				NULL, DIO_SKIP_DIO_COUNT);
+		return dax_do_io(iocb, inode, I_BDEV(inode), iter, offset,
+				blkdev_get_block, blkdev_get_block,
+				NULL, NULL, DIO_SKIP_DIO_COUNT);
 	return __blockdev_direct_IO(iocb, inode, I_BDEV(inode), iter, offset,
 				    blkdev_get_block, NULL, NULL,
 				    DIO_SKIP_DIO_COUNT);
diff --git a/fs/dax.c b/fs/dax.c
index a30481e..b90c8e9 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -208,7 +208,7 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
 }
 
 /**
- * dax_do_io - Perform I/O to a DAX file
+ * __dax_do_io - Perform I/O to a DAX file
  * @iocb: The control block for this I/O
  * @inode: The file which the I/O is directed at
  * @iter: The addresses to do I/O from or to
@@ -224,7 +224,7 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
  * As with do_blockdev_direct_IO(), we increment i_dio_count while the I/O
  * is in progress.
  */
-ssize_t dax_do_io(struct kiocb *iocb, struct inode *inode,
+ssize_t __dax_do_io(struct kiocb *iocb, struct inode *inode,
 		  struct iov_iter *iter, loff_t pos, get_block_t get_block,
 		  dio_iodone_t end_io, int flags)
 {
@@ -262,8 +262,38 @@ ssize_t dax_do_io(struct kiocb *iocb, struct inode *inode,
  out:
 	return retval;
 }
+EXPORT_SYMBOL_GPL(__dax_do_io);
+
+/*
+ * This is a library function for use by file systems. It will perform a
+ * fallback to direct_io semantics if the dax_io fails due to a media error.
+ */
+ssize_t dax_do_io(struct kiocb *iocb, struct inode *inode,
+		  struct block_device *bdev, struct iov_iter *iter, loff_t pos,
+		  get_block_t dax_get_block, get_block_t dio_get_block,
+		  dio_iodone_t end_io, dio_submit_t submit_io, int flags)
+{
+	ssize_t retval;
+
+	retval = __dax_do_io(iocb, inode, iter, pos, dax_get_block, end_io,
+				flags);
+	if (iov_iter_rw(iter) == WRITE && retval == -EIO) {
+		/*
+		 * __dax_do_io may have failed a write due to a bad block.
+		 * Retry with direct_io, and if the direct_IO also fails,
+		 * return -EIO as that was the original error that led us
+		 * down the direct_IO path.
+		 */
+		retval = __blockdev_direct_IO(iocb, inode, bdev, iter, pos,
+				dio_get_block, end_io, submit_io, flags);
+		if (retval < 0)
+			return -EIO;
+	}
+	return retval;
+}
 EXPORT_SYMBOL_GPL(dax_do_io);
 
+
 /*
  * The user has performed a load from a hole in the file.  Allocating
  * a new page in the file would cause excessive storage usage for
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 824f249..8a307cf 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -862,8 +862,9 @@ ext2_direct_IO(struct kiocb *iocb, struct iov_iter *iter, loff_t offset)
 	ssize_t ret;
 
 	if (IS_DAX(inode))
-		ret = dax_do_io(iocb, inode, iter, offset, ext2_get_block, NULL,
-				DIO_LOCKING);
+		ret = dax_do_io(iocb, inode, inode->i_sb->s_bdev, iter,
+				offset, ext2_get_block, ext2_get_block,
+				NULL, NULL, DIO_LOCKING | DIO_SKIP_HOLES);
 	else
 		ret = blockdev_direct_IO(iocb, inode, iter, offset,
 					 ext2_get_block);
diff --git a/fs/ext4/indirect.c b/fs/ext4/indirect.c
index 355ef9c..4b087b7 100644
--- a/fs/ext4/indirect.c
+++ b/fs/ext4/indirect.c
@@ -692,8 +692,9 @@ retry:
 			goto locked;
 		}
 		if (IS_DAX(inode))
-			ret = dax_do_io(iocb, inode, iter, offset,
-					ext4_get_block, NULL, 0);
+			ret = dax_do_io(iocb, inode, inode->i_sb->s_bdev, iter,
+					offset, ext4_get_block, ext4_get_block,
+					NULL, NULL, 0);
 		else
 			ret = __blockdev_direct_IO(iocb, inode,
 						   inode->i_sb->s_bdev, iter,
@@ -703,8 +704,10 @@ retry:
 	} else {
 locked:
 		if (IS_DAX(inode))
-			ret = dax_do_io(iocb, inode, iter, offset,
-					ext4_get_block, NULL, DIO_LOCKING);
+			ret = dax_do_io(iocb, inode, inode->i_sb->s_bdev, iter,
+					offset, ext4_get_block, ext4_get_block,
+					NULL, NULL, DIO_LOCKING |
+					DIO_SKIP_HOLES);
 		else
 			ret = blockdev_direct_IO(iocb, inode, iter, offset,
 						 ext4_get_block);
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index aee960b..4220dac 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3315,8 +3315,9 @@ static ssize_t ext4_ext_direct_IO(struct kiocb *iocb, struct iov_iter *iter,
 	BUG_ON(ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode));
 #endif
 	if (IS_DAX(inode))
-		ret = dax_do_io(iocb, inode, iter, offset, get_block_func,
-				ext4_end_io_dio, dio_flags);
+		ret = dax_do_io(iocb, inode, inode->i_sb->s_bdev, iter, offset,
+				get_block_func, get_block_func,
+				ext4_end_io_dio, NULL, dio_flags);
 	else
 		ret = __blockdev_direct_IO(iocb, inode,
 					   inode->i_sb->s_bdev, iter, offset,
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index a9ebabfe..dc4e088 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1682,11 +1682,12 @@ xfs_vm_do_dio(
 					 void		*private),
 	int			flags)
 {
-	struct block_device	*bdev;
+	struct block_device	*bdev = xfs_find_bdev_for_inode(inode);
 
 	if (IS_DAX(inode))
-		return dax_do_io(iocb, inode, iter, offset,
-				 xfs_get_blocks_direct, endio, 0);
+		return dax_do_io(iocb, inode, bdev, iter, offset,
+				 xfs_get_blocks_direct, xfs_get_blocks_direct,
+				 endio, NULL, flags);
 
 	bdev = xfs_find_bdev_for_inode(inode);
 	return  __blockdev_direct_IO(iocb, inode, bdev, iter, offset,
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 933198a..6981076 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -5,8 +5,12 @@
 #include <linux/mm.h>
 #include <asm/pgtable.h>
 
-ssize_t dax_do_io(struct kiocb *, struct inode *, struct iov_iter *, loff_t,
+ssize_t __dax_do_io(struct kiocb *, struct inode *, struct iov_iter *, loff_t,
 		  get_block_t, dio_iodone_t, int flags);
+ssize_t dax_do_io(struct kiocb *iocb, struct inode *inode,
+		  struct block_device *bdev, struct iov_iter *iter, loff_t pos,
+		  get_block_t dax_get_block, get_block_t dio_get_block,
+		  dio_iodone_t end_io, dio_submit_t submit_io, int flags);
 int dax_zero_page_range(struct inode *, loff_t from, unsigned len, get_block_t);
 int dax_truncate_page(struct inode *, loff_t from, get_block_t);
 int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t,
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
