Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f48.google.com (mail-oa0-f48.google.com [209.85.219.48])
	by kanga.kvack.org (Postfix) with ESMTP id E4B816B0035
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 08:05:52 -0400 (EDT)
Received: by mail-oa0-f48.google.com with SMTP id m1so5792539oag.21
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 05:05:52 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id ak10si10685331pbd.169.2014.09.03.05.05.32
        for <linux-mm@kvack.org>;
        Wed, 03 Sep 2014 05:05:34 -0700 (PDT)
Date: Wed, 3 Sep 2014 22:05:12 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 1/1] xfs: add DAX support
Message-ID: <20140903120512.GH20473@dastard>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1409110741.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com


From: Dave Chinner <dchinner@redhat.com>

Add initial DAX support to XFS. This is EXPERIMENTAL, and it *will*
eat your data. You have been warned, and will be repeatedly warned
if you try to use it:

# mount -o dax /dev/ram0 /mnt/test
[ 2539.332402] XFS (ram0): DAX enabled. Warning: EXPERIMENTAL, use
at your own risk
[ 2539.334625] XFS (ram0): Mounting V5 Filesystem
[ 2539.338604] XFS (ram0): Ending clean mount


Notes:
	- uses a temporary mount option to enable. Needs to be able
	  to detect the capability automatically and switch it on
	  on demand. Mount option will go away once pmem devices
	  are in use and detectable.
	- needs per-inode flags to mark inodes as DAX enabled, and
	  an inheritance flag to enable automatic filesystem
	  propagation of the property
	- passes most of xfstests
	- fails occasionally with zero length writes instead of
	  ENOSPC errors, so error propagation inside/from th DAX
	  code need work
	- no performance testing has been done
	- no stress testing has been done
	- no significant data correctness testing has been done
	- no crash recovery testing has been done (outside what
	  xfstests does)

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_aops.c      | 131 ++++++++++++++++++++++++++++++++----------
 fs/xfs/xfs_aops.h      |   7 ++-
 fs/xfs/xfs_bmap_util.c |  23 ++++++--
 fs/xfs/xfs_file.c      | 151 ++++++++++++++++++++++++++++++++++---------------
 fs/xfs/xfs_iops.c      |  34 ++++++-----
 fs/xfs/xfs_iops.h      |   6 ++
 fs/xfs/xfs_mount.h     |   2 +
 fs/xfs/xfs_super.c     |  25 +++++++-
 8 files changed, 280 insertions(+), 99 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index b984647..67b76b8 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1233,13 +1233,44 @@ xfs_vm_releasepage(
 	return try_to_free_buffers(page);
 }
 
+/*
+ * For DAX we need a mapping buffer callback for unwritten extent conversion
+ * when page faults allocation blocks and then zero them.
+ */
+static void
+xfs_dax_unwritten_end_io(
+	struct buffer_head	*bh,
+	int			uptodate)
+{
+	struct xfs_ioend	*ioend = bh->b_private;
+	struct xfs_inode	*ip = XFS_I(ioend->io_inode);
+	int			error;
+
+	ASSERT(IS_DAX(ioend->io_inode));
+
+	/* if there was an error zeroing, then don't convert it */
+	if (!uptodate)
+		goto out_free;
+
+	error = xfs_iomap_write_unwritten(ip, ioend->io_offset, ioend->io_size);
+	if (error)
+		xfs_warn(ip->i_mount,
+"%s: conversion failed, ino 0x%llx, offset 0x%llx, len 0x%lx, error %d\n",
+			__func__, ip->i_ino, ioend->io_offset,
+			ioend->io_size, error);
+out_free:
+	mempool_free(ioend, xfs_ioend_pool);
+
+}
+
 STATIC int
 __xfs_get_blocks(
 	struct inode		*inode,
 	sector_t		iblock,
 	struct buffer_head	*bh_result,
 	int			create,
-	int			direct)
+	bool			direct,
+	bool			clear)
 {
 	struct xfs_inode	*ip = XFS_I(inode);
 	struct xfs_mount	*mp = ip->i_mount;
@@ -1304,6 +1335,7 @@ __xfs_get_blocks(
 			if (error)
 				return error;
 			new = 1;
+
 		} else {
 			/*
 			 * Delalloc reservations do not require a transaction,
@@ -1340,7 +1372,20 @@ __xfs_get_blocks(
 		if (create || !ISUNWRITTEN(&imap))
 			xfs_map_buffer(inode, bh_result, &imap, offset);
 		if (create && ISUNWRITTEN(&imap)) {
-			if (direct) {
+			if (clear) {
+				/*
+				 * DAX needs a special io completion for
+				 * clearing the buffer. Abuse the xfs_ioend for
+				 * this.
+				 */
+				struct xfs_ioend *ioend;
+
+				ioend = xfs_alloc_ioend(inode, XFS_IO_UNWRITTEN);
+				ioend->io_offset = offset;
+				ioend->io_size = size;
+				bh_result->b_end_io = xfs_dax_unwritten_end_io;
+				bh_result->b_private = ioend;
+			} else if (direct) {
 				bh_result->b_private = inode;
 				set_buffer_defer_completion(bh_result);
 			}
@@ -1425,7 +1470,7 @@ xfs_get_blocks(
 	struct buffer_head	*bh_result,
 	int			create)
 {
-	return __xfs_get_blocks(inode, iblock, bh_result, create, 0);
+	return __xfs_get_blocks(inode, iblock, bh_result, create, false, false);
 }
 
 STATIC int
@@ -1435,7 +1480,17 @@ xfs_get_blocks_direct(
 	struct buffer_head	*bh_result,
 	int			create)
 {
-	return __xfs_get_blocks(inode, iblock, bh_result, create, 1);
+	return __xfs_get_blocks(inode, iblock, bh_result, create, true, false);
+}
+
+int
+xfs_get_blocks_dax(
+	struct inode		*inode,
+	sector_t		iblock,
+	struct buffer_head	*bh_result,
+	int			create)
+{
+	return __xfs_get_blocks(inode, iblock, bh_result, create, true, true);
 }
 
 /*
@@ -1482,6 +1537,30 @@ xfs_end_io_direct_write(
 	xfs_finish_ioend_sync(ioend);
 }
 
+static inline ssize_t
+xfs_vm_do_dio(
+	struct inode		*inode,
+	int			rw,
+	struct kiocb		*iocb,
+	struct iov_iter		*iter,
+	loff_t			offset,
+	void			(*endio)(struct kiocb	*iocb,
+					 loff_t		offset,
+					 ssize_t	size,
+					 void		*private),
+	int			flags)
+{
+	struct block_device	*bdev;
+
+	if (IS_DAX(inode))
+		return dax_do_io(rw, iocb, inode, iter, offset,
+				 xfs_get_blocks_direct, endio, 0);
+
+	bdev = xfs_find_bdev_for_inode(inode);
+	return  __blockdev_direct_IO(rw, iocb, inode, bdev, iter, offset,
+				     xfs_get_blocks_direct, endio, NULL, flags);
+}
+
 STATIC ssize_t
 xfs_vm_direct_IO(
 	int			rw,
@@ -1490,39 +1569,29 @@ xfs_vm_direct_IO(
 	loff_t			offset)
 {
 	struct inode		*inode = iocb->ki_filp->f_mapping->host;
-	struct block_device	*bdev = xfs_find_bdev_for_inode(inode);
 	struct xfs_ioend	*ioend = NULL;
 	ssize_t			ret;
+	size_t			size;
 
-	if (rw & WRITE) {
-		size_t size = iov_iter_count(iter);
+	if (rw & READ)
+		return xfs_vm_do_dio(inode, rw, iocb, iter, offset, NULL, 0);
 
-		/*
-		 * We cannot preallocate a size update transaction here as we
-		 * don't know whether allocation is necessary or not. Hence we
-		 * can only tell IO completion that one is necessary if we are
-		 * not doing unwritten extent conversion.
-		 */
-		iocb->private = ioend = xfs_alloc_ioend(inode, XFS_IO_DIRECT);
-		if (offset + size > XFS_I(inode)->i_d.di_size)
-			ioend->io_isdirect = 1;
-
-		ret = __blockdev_direct_IO(rw, iocb, inode, bdev, iter,
-					    offset, xfs_get_blocks_direct,
-					    xfs_end_io_direct_write, NULL,
-					    DIO_ASYNC_EXTEND);
-		if (ret != -EIOCBQUEUED && iocb->private)
-			goto out_destroy_ioend;
-	} else {
-		ret = __blockdev_direct_IO(rw, iocb, inode, bdev, iter,
-					    offset, xfs_get_blocks_direct,
-					    NULL, NULL, 0);
-	}
+	/*
+	 * We cannot preallocate a size update transaction here as we
+	 * don't know whether allocation is necessary or not. Hence we
+	 * can only tell IO completion that one is necessary if we are
+	 * not doing unwritten extent conversion.
+	 */
+	size = iov_iter_count(iter);
+	iocb->private = ioend = xfs_alloc_ioend(inode, XFS_IO_DIRECT);
+	if (offset + size > XFS_I(inode)->i_d.di_size)
+		ioend->io_isdirect = 1;
 
-	return ret;
+	ret = xfs_vm_do_dio(inode, rw, iocb, iter, offset,
+			    xfs_end_io_direct_write, DIO_ASYNC_EXTEND);
 
-out_destroy_ioend:
-	xfs_destroy_ioend(ioend);
+	if (ret != -EIOCBQUEUED && iocb->private)
+		xfs_destroy_ioend(ioend);
 	return ret;
 }
 
diff --git a/fs/xfs/xfs_aops.h b/fs/xfs/xfs_aops.h
index f94dd45..0264bc5 100644
--- a/fs/xfs/xfs_aops.h
+++ b/fs/xfs/xfs_aops.h
@@ -56,8 +56,11 @@ typedef struct xfs_ioend {
 } xfs_ioend_t;
 
 extern const struct address_space_operations xfs_address_space_operations;
-extern int xfs_get_blocks(struct inode *, sector_t, struct buffer_head *, int);
+int	xfs_get_blocks(struct inode *inode, sector_t offset,
+		       struct buffer_head *map_bh, int create);
+int	xfs_get_blocks_dax(struct inode *inode, sector_t offset,
+			   struct buffer_head *map_bh, int create);
 
-extern void xfs_count_page_state(struct page *, int *, int *);
+void xfs_count_page_state(struct page *, int *, int *);
 
 #endif /* __XFS_AOPS_H__ */
diff --git a/fs/xfs/xfs_bmap_util.c b/fs/xfs/xfs_bmap_util.c
index 08979d8..47819a4 100644
--- a/fs/xfs/xfs_bmap_util.c
+++ b/fs/xfs/xfs_bmap_util.c
@@ -1136,14 +1136,29 @@ xfs_zero_remaining_bytes(
 			break;
 		ASSERT(imap.br_blockcount >= 1);
 		ASSERT(imap.br_startoff == offset_fsb);
+		ASSERT(imap.br_startblock != DELAYSTARTBLOCK);
+
+		if (imap.br_startblock == HOLESTARTBLOCK ||
+		    imap.br_state == XFS_EXT_UNWRITTEN) {
+			/* skip the entire extent */
+			lastoffset = XFS_FSB_TO_B(mp, imap.br_startoff +
+						      imap.br_blockcount) - 1;
+			continue;
+		}
+
 		lastoffset = XFS_FSB_TO_B(mp, imap.br_startoff + 1) - 1;
 		if (lastoffset > endoff)
 			lastoffset = endoff;
-		if (imap.br_startblock == HOLESTARTBLOCK)
-			continue;
-		ASSERT(imap.br_startblock != DELAYSTARTBLOCK);
-		if (imap.br_state == XFS_EXT_UNWRITTEN)
+
+		/* DAX can just zero the backing device directly */
+		if (IS_DAX(VFS_I(ip))) {
+			error = dax_zero_page_range(VFS_I(ip), offset,
+						    lastoffset - offset + 1,
+						    xfs_get_blocks_dax);
+			if (error)
+				return error;
 			continue;
+		}
 
 		error = xfs_buf_read_uncached(XFS_IS_REALTIME_INODE(ip) ?
 				mp->m_rtdev_targp : mp->m_ddev_targp,
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index eb596b4..d3d101e 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -99,7 +99,8 @@ xfs_iozero(
 {
 	struct page		*page;
 	struct address_space	*mapping;
-	int			status;
+	int			status = 0;
+
 
 	mapping = VFS_I(ip)->i_mapping;
 	do {
@@ -111,20 +112,25 @@ xfs_iozero(
 		if (bytes > count)
 			bytes = count;
 
-		status = pagecache_write_begin(NULL, mapping, pos, bytes,
-					AOP_FLAG_UNINTERRUPTIBLE,
-					&page, &fsdata);
-		if (status)
-			break;
+		if (IS_DAX(VFS_I(ip)))
+			dax_zero_page_range(VFS_I(ip), pos, bytes,
+						   xfs_get_blocks_dax);
+		else {
+			status = pagecache_write_begin(NULL, mapping, pos, bytes,
+						AOP_FLAG_UNINTERRUPTIBLE,
+						&page, &fsdata);
+			if (status)
+				break;
 
-		zero_user(page, offset, bytes);
+			zero_user(page, offset, bytes);
 
-		status = pagecache_write_end(NULL, mapping, pos, bytes, bytes,
-					page, fsdata);
-		WARN_ON(status <= 0); /* can't return less than zero! */
+			status = pagecache_write_end(NULL, mapping, pos, bytes,
+						bytes, page, fsdata);
+			WARN_ON(status <= 0); /* can't return less than zero! */
+			status = 0;
+		}
 		pos += bytes;
 		count -= bytes;
-		status = 0;
 	} while (count);
 
 	return (-status);
@@ -604,7 +610,7 @@ xfs_file_dio_aio_write(
 					mp->m_rtdev_targp : mp->m_ddev_targp;
 
 	/* DIO must be aligned to device logical sector size */
-	if ((pos | count) & target->bt_logical_sectormask)
+	if (!IS_DAX(inode) && (pos | count) & target->bt_logical_sectormask)
 		return -EINVAL;
 
 	/* "unaligned" here means not aligned to a filesystem block */
@@ -674,8 +680,11 @@ xfs_file_dio_aio_write(
 out:
 	xfs_rw_iunlock(ip, iolock);
 
-	/* No fallback to buffered IO on errors for XFS. */
-	ASSERT(ret < 0 || ret == count);
+	/*
+	 * No fallback to buffered IO on errors for XFS. DAX can result in
+	 * partial writes, but direct IO will either complete fully or fail.
+	 */
+	ASSERT(ret < 0 || ret == count || IS_DAX(VFS_I(ip)));
 	return ret;
 }
 
@@ -760,7 +769,7 @@ xfs_file_write_iter(
 	if (XFS_FORCED_SHUTDOWN(ip->i_mount))
 		return -EIO;
 
-	if (unlikely(file->f_flags & O_DIRECT))
+	if ((file->f_flags & O_DIRECT) || IS_DAX(inode))
 		ret = xfs_file_dio_aio_write(iocb, from);
 	else
 		ret = xfs_file_buffered_aio_write(iocb, from);
@@ -956,31 +965,6 @@ xfs_file_readdir(
 	return 0;
 }
 
-STATIC int
-xfs_file_mmap(
-	struct file	*filp,
-	struct vm_area_struct *vma)
-{
-	vma->vm_ops = &xfs_file_vm_ops;
-
-	file_accessed(filp);
-	return 0;
-}
-
-/*
- * mmap()d file has taken write protection fault and is being made
- * writable. We can set the page state up correctly for a writable
- * page, which means we can do correct delalloc accounting (ENOSPC
- * checking!) and unwritten extent mapping.
- */
-STATIC int
-xfs_vm_page_mkwrite(
-	struct vm_area_struct	*vma,
-	struct vm_fault		*vmf)
-{
-	return block_page_mkwrite(vma, vmf, xfs_get_blocks);
-}
-
 /*
  * This type is designed to indicate the type of offset we would like
  * to search from page cache for xfs_seek_hole_data().
@@ -1356,6 +1340,86 @@ xfs_file_llseek(
 	}
 }
 
+/*
+ * mmap()d file has taken write protection fault and is being made
+ * writable. We can set the page state up correctly for a writable
+ * page, which means we can do correct delalloc accounting (ENOSPC
+ * checking!) and unwritten extent mapping.
+ */
+STATIC int
+xfs_vm_page_mkwrite(
+	struct vm_area_struct	*vma,
+	struct vm_fault		*vmf)
+{
+	return block_page_mkwrite(vma, vmf, xfs_get_blocks);
+}
+
+static const struct vm_operations_struct xfs_file_vm_ops = {
+	.fault		= filemap_fault,
+	.map_pages	= filemap_map_pages,
+	.page_mkwrite	= xfs_vm_page_mkwrite,
+	.remap_pages	= generic_file_remap_pages,
+};
+
+#ifdef CONFIG_FS_DAX
+static int
+xfs_vm_dax_fault(
+	struct vm_area_struct	*vma,
+	struct vm_fault		*vmf)
+{
+	return dax_fault(vma, vmf, xfs_get_blocks_dax);
+}
+
+static int
+xfs_vm_dax_page_mkwrite(
+	struct vm_area_struct	*vma,
+	struct vm_fault		*vmf)
+{
+	return dax_mkwrite(vma, vmf, xfs_get_blocks_dax);
+}
+
+static const struct vm_operations_struct xfs_file_dax_vm_ops = {
+	.fault		= xfs_vm_dax_fault,
+	.page_mkwrite	= xfs_vm_dax_page_mkwrite,
+	.remap_pages	= generic_file_remap_pages,
+};
+#else
+#define xfs_file_dax_operations xfs_file_vm_ops
+#endif /* CONFIG_FS_DAX */
+
+STATIC int
+xfs_file_mmap(
+	struct file	*filp,
+	struct vm_area_struct *vma)
+{
+	file_accessed(filp);
+	if (IS_DAX(file_inode(filp))) {
+		vma->vm_ops = &xfs_file_dax_vm_ops;
+		vma->vm_flags |= VM_MIXEDMAP;
+	} else
+		vma->vm_ops = &xfs_file_vm_ops;
+	return 0;
+}
+
+#ifdef CONFIG_FS_DAX
+const struct file_operations xfs_file_dax_operations = {
+	.llseek		= xfs_file_llseek,
+	.read		= new_sync_read,
+	.write		= new_sync_write,
+	.read_iter	= xfs_file_read_iter,
+	.write_iter	= xfs_file_write_iter,
+	.unlocked_ioctl	= xfs_file_ioctl,
+#ifdef CONFIG_COMPAT
+	.compat_ioctl	= xfs_file_compat_ioctl,
+#endif
+	.mmap		= xfs_file_mmap,
+	.open		= xfs_file_open,
+	.release	= xfs_file_release,
+	.fsync		= xfs_file_fsync,
+	.fallocate	= xfs_file_fallocate,
+};
+#endif /* CONFIG_FS_DAX */
+
 const struct file_operations xfs_file_operations = {
 	.llseek		= xfs_file_llseek,
 	.read		= new_sync_read,
@@ -1386,10 +1450,3 @@ const struct file_operations xfs_dir_file_operations = {
 #endif
 	.fsync		= xfs_dir_fsync,
 };
-
-static const struct vm_operations_struct xfs_file_vm_ops = {
-	.fault		= filemap_fault,
-	.map_pages	= filemap_map_pages,
-	.page_mkwrite	= xfs_vm_page_mkwrite,
-	.remap_pages	= generic_file_remap_pages,
-};
diff --git a/fs/xfs/xfs_iops.c b/fs/xfs/xfs_iops.c
index 7212949..63aeca8 100644
--- a/fs/xfs/xfs_iops.c
+++ b/fs/xfs/xfs_iops.c
@@ -844,7 +844,11 @@ xfs_setattr_size(
 	 * much we can do about this, except to hope that the caller sees ENOMEM
 	 * and retries the truncate operation.
 	 */
-	error = block_truncate_page(inode->i_mapping, newsize, xfs_get_blocks);
+	if (IS_DAX(inode))
+		error = dax_truncate_page(inode, newsize, xfs_get_blocks_dax);
+	else
+		error = block_truncate_page(inode->i_mapping, newsize,
+					    xfs_get_blocks);
 	if (error)
 		return error;
 	truncate_setsize(inode, newsize);
@@ -1176,22 +1180,22 @@ xfs_diflags_to_iflags(
 	struct inode		*inode,
 	struct xfs_inode	*ip)
 {
-	if (ip->i_d.di_flags & XFS_DIFLAG_IMMUTABLE)
+	uint16_t		flags = ip->i_d.di_flags;
+
+	inode->i_flags &= ~(S_IMMUTABLE | S_APPEND | S_SYNC |
+			    S_NOATIME | S_DAX);
+
+	if (flags & XFS_DIFLAG_IMMUTABLE)
 		inode->i_flags |= S_IMMUTABLE;
-	else
-		inode->i_flags &= ~S_IMMUTABLE;
-	if (ip->i_d.di_flags & XFS_DIFLAG_APPEND)
+	if (flags & XFS_DIFLAG_APPEND)
 		inode->i_flags |= S_APPEND;
-	else
-		inode->i_flags &= ~S_APPEND;
-	if (ip->i_d.di_flags & XFS_DIFLAG_SYNC)
+	if (flags & XFS_DIFLAG_SYNC)
 		inode->i_flags |= S_SYNC;
-	else
-		inode->i_flags &= ~S_SYNC;
-	if (ip->i_d.di_flags & XFS_DIFLAG_NOATIME)
+	if (flags & XFS_DIFLAG_NOATIME)
 		inode->i_flags |= S_NOATIME;
-	else
-		inode->i_flags &= ~S_NOATIME;
+	/* XXX: Also needs an on-disk per inode flag! */
+	if (ip->i_mount->m_flags & XFS_MOUNT_DAX)
+		inode->i_flags |= S_DAX;
 }
 
 /*
@@ -1253,6 +1257,10 @@ xfs_setup_inode(
 	case S_IFREG:
 		inode->i_op = &xfs_inode_operations;
 		inode->i_fop = &xfs_file_operations;
+		if (IS_DAX(inode))
+			inode->i_fop = &xfs_file_dax_operations;
+		else
+			inode->i_fop = &xfs_file_operations;
 		inode->i_mapping->a_ops = &xfs_address_space_operations;
 		break;
 	case S_IFDIR:
diff --git a/fs/xfs/xfs_iops.h b/fs/xfs/xfs_iops.h
index 1c34e43..5aeacd2 100644
--- a/fs/xfs/xfs_iops.h
+++ b/fs/xfs/xfs_iops.h
@@ -23,6 +23,12 @@ struct xfs_inode;
 extern const struct file_operations xfs_file_operations;
 extern const struct file_operations xfs_dir_file_operations;
 
+#ifdef CONFIG_FS_DAX
+extern const struct file_operations xfs_file_dax_operations;
+#else
+#define xfs_file_dax_operations xfs_file_operations
+#endif
+
 extern ssize_t xfs_vn_listxattr(struct dentry *, char *data, size_t size);
 
 extern void xfs_setup_inode(struct xfs_inode *);
diff --git a/fs/xfs/xfs_mount.h b/fs/xfs/xfs_mount.h
index 06f16d5..8f15099 100644
--- a/fs/xfs/xfs_mount.h
+++ b/fs/xfs/xfs_mount.h
@@ -208,6 +208,8 @@ typedef struct xfs_mount {
 						   allocator */
 #define XFS_MOUNT_NOATTR2	(1ULL << 25)	/* disable use of attr2 format */
 
+#define XFS_MOUNT_DAX		(1ULL << 62)	/* TEST ONLY! */
+
 
 /*
  * Default minimum read and write sizes.
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index de6dc75..0c86ab4 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -115,6 +115,8 @@ static struct xfs_kobj xfs_dbg_kobj;	/* global debug sysfs attrs */
 #define MNTOPT_DISCARD	   "discard"	/* Discard unused blocks */
 #define MNTOPT_NODISCARD   "nodiscard"	/* Do not discard unused blocks */
 
+#define MNTOPT_DAX	"dax"	/* XXX: TEST ONLY OPTION */
+
 /*
  * Table driven mount option parser.
  *
@@ -362,6 +364,10 @@ xfs_parseargs(
 		} else if (!strcmp(this_char, MNTOPT_GQUOTANOENF)) {
 			mp->m_qflags |= (XFS_GQUOTA_ACCT | XFS_GQUOTA_ACTIVE);
 			mp->m_qflags &= ~XFS_GQUOTA_ENFD;
+#ifdef CONFIG_FS_DAX
+		} else if (!strcmp(this_char, MNTOPT_DAX)) {
+			mp->m_flags |= XFS_MOUNT_DAX;
+#endif
 		} else if (!strcmp(this_char, MNTOPT_DELAYLOG)) {
 			xfs_warn(mp,
 	"delaylog is the default now, option is deprecated.");
@@ -473,8 +479,8 @@ done:
 }
 
 struct proc_xfs_info {
-	int	flag;
-	char	*str;
+	uint64_t	flag;
+	char		*str;
 };
 
 STATIC int
@@ -495,6 +501,7 @@ xfs_showargs(
 		{ XFS_MOUNT_GRPID,		"," MNTOPT_GRPID },
 		{ XFS_MOUNT_DISCARD,		"," MNTOPT_DISCARD },
 		{ XFS_MOUNT_SMALL_INUMS,	"," MNTOPT_32BITINODE },
+		{ XFS_MOUNT_DAX,		"," MNTOPT_DAX },
 		{ 0, NULL }
 	};
 	static struct proc_xfs_info xfs_info_unset[] = {
@@ -1473,6 +1480,20 @@ xfs_fs_fill_super(
 	if (XFS_SB_VERSION_NUM(&mp->m_sb) == XFS_SB_VERSION_5)
 		sb->s_flags |= MS_I_VERSION;
 
+	if (mp->m_flags & XFS_MOUNT_DAX) {
+		xfs_warn(mp,
+	"DAX enabled. Warning: EXPERIMENTAL, use at your own risk");
+		if (sb->s_blocksize != PAGE_SIZE) {
+			xfs_alert(mp,
+		"Filesystem block size invalid for DAX Turning DAX off.");
+			mp->m_flags &= ~XFS_MOUNT_DAX;
+		} else if (!sb->s_bdev->bd_disk->fops->direct_access) {
+			xfs_alert(mp,
+		"Block device does not support DAX Turning DAX off.");
+			mp->m_flags &= ~XFS_MOUNT_DAX;
+		}
+	}
+
 	error = xfs_mountfs(mp);
 	if (error)
 		goto out_filestream_unmount;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
