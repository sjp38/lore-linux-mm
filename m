Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 745816B0261
	for <linux-mm@kvack.org>; Sat, 23 Apr 2016 15:14:06 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id vv3so205885204pab.2
        for <linux-mm@kvack.org>; Sat, 23 Apr 2016 12:14:06 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id dy1si2633102pab.117.2016.04.23.12.14.05
        for <linux-mm@kvack.org>;
        Sat, 23 Apr 2016 12:14:05 -0700 (PDT)
From: Vishal Verma <vishal.l.verma@intel.com>
Subject: [PATCH v3 5/7] dax: handle media errors in dax_do_io
Date: Sat, 23 Apr 2016 13:13:40 -0600
Message-Id: <1461438822-3592-6-git-send-email-vishal.l.verma@intel.com>
In-Reply-To: <1461438822-3592-1-git-send-email-vishal.l.verma@intel.com>
References: <1461438822-3592-1-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Vishal Verma <vishal.l.verma@intel.com>, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew.r.wilcox@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

dax_do_io (called for read() or write() for a dax file system) may fail
in the presence of bad blocks or media errors. Since we expect that a
write should clear media errors on nvdimms, make dax_do_io fall back to
the direct_IO path, which will send down a bio to the driver, which can
then attempt to clear the error.

Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Jens Axboe <axboe@fb.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Vishal Verma <vishal.l.verma@intel.com>
---
 fs/block_dev.c      |  5 +++--
 fs/ext2/inode.c     |  5 +++--
 fs/ext4/inode.c     |  5 +++--
 fs/xfs/xfs_aops.c   |  8 ++++----
 include/linux/dax.h | 30 ++++++++++++++++++++++++++++++
 5 files changed, 43 insertions(+), 10 deletions(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index 79defba..7c90516 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -168,8 +168,9 @@ blkdev_direct_IO(struct kiocb *iocb, struct iov_iter *iter, loff_t offset)
 	struct inode *inode = bdev_file_inode(file);
 
 	if (IS_DAX(inode))
-		return dax_do_io(iocb, inode, iter, offset, blkdev_get_block,
-				NULL, DIO_SKIP_DIO_COUNT);
+		return dax_io_fallback(iocb, inode, I_BDEV(inode), iter, offset,
+				blkdev_get_block, blkdev_get_block,
+				NULL, NULL, DIO_SKIP_DIO_COUNT);
 	return __blockdev_direct_IO(iocb, inode, I_BDEV(inode), iter, offset,
 				    blkdev_get_block, NULL, NULL,
 				    DIO_SKIP_DIO_COUNT);
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 35f2b0bf..1cec54b 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -862,8 +862,9 @@ ext2_direct_IO(struct kiocb *iocb, struct iov_iter *iter, loff_t offset)
 	ssize_t ret;
 
 	if (IS_DAX(inode))
-		ret = dax_do_io(iocb, inode, iter, offset, ext2_get_block, NULL,
-				DIO_LOCKING);
+		ret = dax_io_fallback(iocb, inode, inode->i_sb->s_bdev, iter,
+				offset, ext2_get_block, ext2_get_block,
+				NULL, NULL, DIO_LOCKING | DIO_SKIP_HOLES);
 	else
 		ret = blockdev_direct_IO(iocb, inode, iter, offset,
 					 ext2_get_block);
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 6d5d5c1..d29848b 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3411,8 +3411,9 @@ static ssize_t ext4_direct_IO_write(struct kiocb *iocb, struct iov_iter *iter,
 	BUG_ON(ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode));
 #endif
 	if (IS_DAX(inode)) {
-		ret = dax_do_io(iocb, inode, iter, offset, get_block_func,
-				ext4_end_io_dio, dio_flags);
+		ret = dax_io_fallback(iocb, inode, inode->i_sb->s_bdev, iter,
+				offset, get_block_func, get_block_func,
+				ext4_end_io_dio, NULL, dio_flags);
 	} else
 		ret = __blockdev_direct_IO(iocb, inode,
 					   inode->i_sb->s_bdev, iter, offset,
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index e49b240..48fe10a 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1412,7 +1412,7 @@ xfs_vm_direct_IO(
 	struct inode		*inode = iocb->ki_filp->f_mapping->host;
 	dio_iodone_t		*endio = NULL;
 	int			flags = 0;
-	struct block_device	*bdev;
+	struct block_device     *bdev = xfs_find_bdev_for_inode(inode);
 
 	if (iov_iter_rw(iter) == WRITE) {
 		endio = xfs_end_io_direct_write;
@@ -1420,11 +1420,11 @@ xfs_vm_direct_IO(
 	}
 
 	if (IS_DAX(inode)) {
-		return dax_do_io(iocb, inode, iter, offset,
-				 xfs_get_blocks_direct, endio, 0);
+		return dax_io_fallback(iocb, inode, bdev, iter, offset,
+				xfs_get_blocks_direct, xfs_get_blocks_direct,
+				endio, NULL, flags);
 	}
 
-	bdev = xfs_find_bdev_for_inode(inode);
 	return  __blockdev_direct_IO(iocb, inode, bdev, iter, offset,
 			xfs_get_blocks_direct, endio, NULL, flags);
 }
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 426841a..7200e6f 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -3,6 +3,7 @@
 
 #include <linux/fs.h>
 #include <linux/mm.h>
+#include <linux/uio.h>
 #include <linux/radix-tree.h>
 #include <asm/pgtable.h>
 
@@ -64,4 +65,33 @@ static inline bool dax_mapping(struct address_space *mapping)
 struct writeback_control;
 int dax_writeback_mapping_range(struct address_space *mapping,
 		struct block_device *bdev, struct writeback_control *wbc);
+/*
+ * This is a wrapper for dax_do_io which may be used for writes, and will
+ * perform a fallback to direct_io semantics if the dax_io fails due to a
+ * media error.
+ */
+static inline ssize_t dax_io_fallback(struct kiocb *iocb, struct inode *inode,
+		struct block_device *bdev, struct iov_iter *iter, loff_t pos,
+		get_block_t dax_get_block, get_block_t dio_get_block,
+		dio_iodone_t end_io, dio_submit_t submit_io, int flags)
+{
+	ssize_t retval;
+
+	retval = dax_do_io(iocb, inode, iter, pos, dax_get_block, end_io,
+			flags);
+	if (iov_iter_rw(iter) == WRITE && retval == -EIO) {
+		/*
+		 * __dax_do_io may have failed a write due to a bad block.
+		 * Retry with direct_io, and if the direct_IO also fails
+		 * (with the exception of -EIOCBQUEUED), return -EIO as
+		 * that was the original error that led us down the
+		 * direct_IO path.
+		 */
+		retval = __blockdev_direct_IO(iocb, inode, bdev, iter, pos,
+				dio_get_block, end_io, submit_io, flags);
+		if (retval < 0 && retval != -EIOCBQUEUED)
+			return -EIO;
+	}
+	return retval;
+}
 #endif
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
