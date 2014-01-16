Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6B5086B004D
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 20:25:08 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so1945719pab.33
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 17:25:08 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ez5si5304758pab.251.2014.01.15.17.25.06
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 17:25:06 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v5 06/22] Treat XIP like O_DIRECT
Date: Wed, 15 Jan 2014 20:24:24 -0500
Message-Id: <8bf2f9014e3d7abecb7b6a46c537b6371557936c.1389779961.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1389779961.git.matthew.r.wilcox@intel.com>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1389779961.git.matthew.r.wilcox@intel.com>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>

Instead of separate read and write methods, use the generic AIO
infrastructure.  In addition to giving us support for AIO, this adds
the locking between read() and truncate() that was missing.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/Makefile        |   1 +
 fs/ext2/file.c     |   6 +-
 fs/ext2/inode.c    |   7 +-
 fs/xip.c           | 156 +++++++++++++++++++++++++++++++++++
 include/linux/fs.h |  18 ++++-
 mm/filemap.c       |   6 +-
 mm/filemap_xip.c   | 234 -----------------------------------------------------
 7 files changed, 183 insertions(+), 245 deletions(-)
 create mode 100644 fs/xip.c

diff --git a/fs/Makefile b/fs/Makefile
index 4fe6df3..96061f2 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -29,6 +29,7 @@ obj-$(CONFIG_SIGNALFD)		+= signalfd.o
 obj-$(CONFIG_TIMERFD)		+= timerfd.o
 obj-$(CONFIG_EVENTFD)		+= eventfd.o
 obj-$(CONFIG_AIO)               += aio.o
+obj-$(CONFIG_FS_XIP)		+= xip.o
 obj-$(CONFIG_FILE_LOCKING)      += locks.o
 obj-$(CONFIG_COMPAT)		+= compat.o compat_ioctl.o
 obj-$(CONFIG_BINFMT_AOUT)	+= binfmt_aout.o
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index a5b3a5d..b0eb1d4 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -81,8 +81,10 @@ const struct file_operations ext2_file_operations = {
 #ifdef CONFIG_EXT2_FS_XIP
 const struct file_operations ext2_xip_file_operations = {
 	.llseek		= generic_file_llseek,
-	.read		= xip_file_read,
-	.write		= xip_file_write,
+	.read		= do_sync_read,
+	.write		= do_sync_write,
+	.aio_read	= generic_file_aio_read,
+	.aio_write	= generic_file_aio_write,
 	.unlocked_ioctl = ext2_ioctl,
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= ext2_compat_ioctl,
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 9b494ab..3d11f1d 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -858,7 +858,11 @@ ext2_direct_IO(int rw, struct kiocb *iocb, const struct iovec *iov,
 	struct inode *inode = mapping->host;
 	ssize_t ret;
 
-	ret = blockdev_direct_IO(rw, iocb, inode, iov, offset, nr_segs,
+	if (IS_XIP(inode))
+		ret = xip_do_io(rw, iocb, inode, iov, offset, nr_segs,
+				ext2_get_block, NULL, DIO_LOCKING);
+	else
+		ret = blockdev_direct_IO(rw, iocb, inode, iov, offset, nr_segs,
 				 ext2_get_block);
 	if (ret < 0 && (rw & WRITE))
 		ext2_write_failed(mapping, offset + iov_length(iov, nr_segs));
@@ -888,6 +892,7 @@ const struct address_space_operations ext2_aops = {
 const struct address_space_operations ext2_aops_xip = {
 	.bmap			= ext2_bmap,
 	.get_xip_mem		= ext2_get_xip_mem,
+	.direct_IO		= ext2_direct_IO,
 };
 
 const struct address_space_operations ext2_nobh_aops = {
diff --git a/fs/xip.c b/fs/xip.c
new file mode 100644
index 0000000..0f0f15b
--- /dev/null
+++ b/fs/xip.c
@@ -0,0 +1,156 @@
+/*
+ * fs/xip.c - Execute In Place filesystem code
+ * Copyright (c) 2013 Intel Corporation
+ * Author: Matthew Wilcox <matthew.r.wilcox@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+
+#include <linux/atomic.h>
+#include <linux/blkdev.h>
+#include <linux/buffer_head.h>
+#include <linux/fs.h>
+#include <linux/genhd.h>
+#include <linux/mutex.h>
+#include <linux/uio.h>
+
+static long xip_get_addr(struct inode *inode, struct buffer_head *bh,
+								void **addr)
+{
+	struct block_device *bdev = bh->b_bdev;
+	const struct block_device_operations *ops = bdev->bd_disk->fops;
+	unsigned long pfn;
+	sector_t sector = bh->b_blocknr << (inode->i_blkbits - 9);
+	return ops->direct_access(bdev, sector, addr, &pfn, bh->b_size);
+}
+
+static ssize_t xip_io(int rw, struct inode *inode, const struct iovec *iov,
+			loff_t start, loff_t end, unsigned nr_segs,
+			get_block_t get_block, struct buffer_head *bh)
+{
+	ssize_t retval = 0;
+	unsigned seg = 0;
+	unsigned len;
+	unsigned copied = 0;
+	loff_t offset = start;
+	loff_t max = start;
+	void *addr;
+	bool hole = false;
+
+	while (offset < end) {
+		void __user *buf = iov[seg].iov_base + copied;
+
+		if (max == offset) {
+			sector_t block = offset >> inode->i_blkbits;
+			long size;
+			memset(bh, 0, sizeof(*bh));
+			bh->b_size = ALIGN(end - offset, PAGE_SIZE);
+			retval = get_block(inode, block, bh, rw == WRITE);
+			if (retval)
+				break;
+			if (buffer_mapped(bh)) {
+				retval = xip_get_addr(inode, bh, &addr);
+				if (retval < 0)
+					break;
+				addr += offset - (block << inode->i_blkbits);
+				hole = false;
+				size = retval;
+			} else {
+				if (rw == WRITE) {
+					retval = -EIO;
+					break;
+				}
+				addr = NULL;
+				hole = true;
+				size = bh->b_size;
+			}
+			max = offset + size;
+		}
+
+		len = min_t(unsigned, iov[seg].iov_len - copied, max - offset);
+
+		if (rw == WRITE)
+			len -= __copy_from_user_nocache(addr, buf, len);
+		else if (!hole)
+			len -= __copy_to_user(buf, addr, len);
+		else
+			len -= __clear_user(buf, len);
+
+		if (!len)
+			break;
+
+		offset += len;
+		copied += len;
+		if (copied == iov[seg].iov_len) {
+			seg++;
+			copied = 0;
+		}
+	}
+
+	return (offset == start) ? retval : offset - start;
+}
+
+/**
+ * xip_do_io - Perform I/O to an XIP file
+ * @rw: READ to read or WRITE to write
+ * @iocb: The control block for this I/O
+ * @inode: The file which the I/O is directed at
+ * @iov: The user addresses to do I/O from or to
+ * @offset: The file offset where the I/O starts
+ * @nr_segs: The length of the iov array
+ * @get_block: The filesystem method used to translate file offsets to blocks
+ * @end_io: A filesystem callback for I/O completion
+ * @flags: See below
+ *
+ * This function uses the same locking scheme as do_blockdev_direct_IO:
+ * If @flags has DIO_LOCKING set, we assume that the i_mutex is held by the
+ * caller for writes.  For reads, we take and release the i_mutex ourselves.
+ * If DIO_LOCKING is not set, the filesystem takes care of its own locking.
+ * As with do_blockdev_direct_IO(), we increment i_dio_count while the I/O
+ * is in progress.
+ */
+ssize_t xip_do_io(int rw, struct kiocb *iocb, struct inode *inode,
+		const struct iovec *iov, loff_t offset, unsigned nr_segs,
+		get_block_t get_block, dio_iodone_t end_io, int flags)
+{
+	struct buffer_head bh;
+	unsigned seg;
+	ssize_t retval = -EINVAL;
+	loff_t end = offset;
+
+	for (seg = 0; seg < nr_segs; seg++)
+		end += iov[seg].iov_len;
+
+	if ((flags & DIO_LOCKING) && (rw == READ)) {
+		struct address_space *mapping = inode->i_mapping;
+		mutex_lock(&inode->i_mutex);
+		retval = filemap_write_and_wait_range(mapping, offset, end - 1);
+		if (retval) {
+			mutex_unlock(&inode->i_mutex);
+			goto out;
+		}
+	}
+
+	/* Protects against truncate */
+	atomic_inc(&inode->i_dio_count);
+
+	retval = xip_io(rw, inode, iov, offset, end, nr_segs, get_block, &bh);
+
+	if ((flags & DIO_LOCKING) && (rw == READ))
+		mutex_unlock(&inode->i_mutex);
+
+	inode_dio_done(inode);
+
+	if ((retval > 0) && end_io)
+		end_io(iocb, offset, retval, bh.b_private);
+ out:
+	return retval;
+}
+EXPORT_SYMBOL_GPL(xip_do_io);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 80cfb42..7cc5bf7 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2509,17 +2509,22 @@ extern int generic_file_open(struct inode * inode, struct file * filp);
 extern int nonseekable_open(struct inode * inode, struct file * filp);
 
 #ifdef CONFIG_FS_XIP
-extern ssize_t xip_file_read(struct file *filp, char __user *buf, size_t len,
-			     loff_t *ppos);
 extern int xip_file_mmap(struct file * file, struct vm_area_struct * vma);
-extern ssize_t xip_file_write(struct file *filp, const char __user *buf,
-			      size_t len, loff_t *ppos);
 extern int xip_truncate_page(struct address_space *mapping, loff_t from);
+ssize_t xip_do_io(int rw, struct kiocb *, struct inode *, const struct iovec *,
+		loff_t, unsigned segs, get_block_t, dio_iodone_t, int flags);
 #else
 static inline int xip_truncate_page(struct address_space *mapping, loff_t from)
 {
 	return 0;
 }
+
+static inline ssize_t xip_do_io(int rw, struct kiocb *iocb, struct inode *inode,
+		const struct iovec *iov, loff_t offset, unsigned nr_segs,
+		get_block_t get_block, dio_iodone_t end_io, int flags)
+{
+	return -ENOTTY;
+}
 #endif
 
 #ifdef CONFIG_BLOCK
@@ -2669,6 +2674,11 @@ extern int generic_show_options(struct seq_file *m, struct dentry *root);
 extern void save_mount_options(struct super_block *sb, char *options);
 extern void replace_mount_options(struct super_block *sb, char *options);
 
+static inline bool io_is_direct(struct file *filp)
+{
+	return (filp->f_flags & O_DIRECT) || IS_XIP(file_inode(filp));
+}
+
 static inline ino_t parent_ino(struct dentry *dentry)
 {
 	ino_t res;
diff --git a/mm/filemap.c b/mm/filemap.c
index b7749a9..61a31f0 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1417,8 +1417,7 @@ generic_file_aio_read(struct kiocb *iocb, const struct iovec *iov,
 	if (retval)
 		return retval;
 
-	/* coalesce the iovecs and go direct-to-BIO for O_DIRECT */
-	if (filp->f_flags & O_DIRECT) {
+	if (io_is_direct(filp)) {
 		loff_t size;
 		struct address_space *mapping;
 		struct inode *inode;
@@ -2470,8 +2469,7 @@ ssize_t __generic_file_aio_write(struct kiocb *iocb, const struct iovec *iov,
 	if (err)
 		goto out;
 
-	/* coalesce the iovecs and go direct-to-BIO for O_DIRECT */
-	if (unlikely(file->f_flags & O_DIRECT)) {
+	if (io_is_direct(file)) {
 		loff_t endbyte;
 		ssize_t written_buffered;
 
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index c8d23e9..f7c37a1 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -42,119 +42,6 @@ static struct page *xip_sparse_page(void)
 }
 
 /*
- * This is a file read routine for execute in place files, and uses
- * the mapping->a_ops->get_xip_mem() function for the actual low-level
- * stuff.
- *
- * Note the struct file* is not used at all.  It may be NULL.
- */
-static ssize_t
-do_xip_mapping_read(struct address_space *mapping,
-		    struct file_ra_state *_ra,
-		    struct file *filp,
-		    char __user *buf,
-		    size_t len,
-		    loff_t *ppos)
-{
-	struct inode *inode = mapping->host;
-	pgoff_t index, end_index;
-	unsigned long offset;
-	loff_t isize, pos;
-	size_t copied = 0, error = 0;
-
-	BUG_ON(!mapping->a_ops->get_xip_mem);
-
-	pos = *ppos;
-	index = pos >> PAGE_CACHE_SHIFT;
-	offset = pos & ~PAGE_CACHE_MASK;
-
-	isize = i_size_read(inode);
-	if (!isize)
-		goto out;
-
-	end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
-	do {
-		unsigned long nr, left;
-		void *xip_mem;
-		unsigned long xip_pfn;
-		int zero = 0;
-
-		/* nr is the maximum number of bytes to copy from this page */
-		nr = PAGE_CACHE_SIZE;
-		if (index >= end_index) {
-			if (index > end_index)
-				goto out;
-			nr = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
-			if (nr <= offset) {
-				goto out;
-			}
-		}
-		nr = nr - offset;
-		if (nr > len - copied)
-			nr = len - copied;
-
-		error = mapping->a_ops->get_xip_mem(mapping, index, 0,
-							&xip_mem, &xip_pfn);
-		if (unlikely(error)) {
-			if (error == -ENODATA) {
-				/* sparse */
-				zero = 1;
-			} else
-				goto out;
-		}
-
-		/* If users can be writing to this page using arbitrary
-		 * virtual addresses, take care about potential aliasing
-		 * before reading the page on the kernel side.
-		 */
-		if (mapping_writably_mapped(mapping))
-			/* address based flush */ ;
-
-		/*
-		 * Ok, we have the mem, so now we can copy it to user space...
-		 *
-		 * The actor routine returns how many bytes were actually used..
-		 * NOTE! This may not be the same as how much of a user buffer
-		 * we filled up (we may be padding etc), so we can only update
-		 * "pos" here (the actor routine has to update the user buffer
-		 * pointers and the remaining count).
-		 */
-		if (!zero)
-			left = __copy_to_user(buf+copied, xip_mem+offset, nr);
-		else
-			left = __clear_user(buf + copied, nr);
-
-		if (left) {
-			error = -EFAULT;
-			goto out;
-		}
-
-		copied += (nr - left);
-		offset += (nr - left);
-		index += offset >> PAGE_CACHE_SHIFT;
-		offset &= ~PAGE_CACHE_MASK;
-	} while (copied < len);
-
-out:
-	*ppos = pos + copied;
-	if (filp)
-		file_accessed(filp);
-
-	return (copied ? copied : error);
-}
-
-ssize_t
-xip_file_read(struct file *filp, char __user *buf, size_t len, loff_t *ppos)
-{
-	if (!access_ok(VERIFY_WRITE, buf, len))
-		return -EFAULT;
-
-	return do_xip_mapping_read(filp->f_mapping, &filp->f_ra, filp,
-			    buf, len, ppos);
-}
-EXPORT_SYMBOL_GPL(xip_file_read);
-
-/*
  * __xip_unmap is invoked from xip_unmap and
  * xip_write
  *
@@ -340,127 +227,6 @@ int xip_file_mmap(struct file * file, struct vm_area_struct * vma)
 }
 EXPORT_SYMBOL_GPL(xip_file_mmap);
 
-static ssize_t
-__xip_file_write(struct file *filp, const char __user *buf,
-		  size_t count, loff_t pos, loff_t *ppos)
-{
-	struct address_space * mapping = filp->f_mapping;
-	const struct address_space_operations *a_ops = mapping->a_ops;
-	struct inode 	*inode = mapping->host;
-	long		status = 0;
-	size_t		bytes;
-	ssize_t		written = 0;
-
-	BUG_ON(!mapping->a_ops->get_xip_mem);
-
-	do {
-		unsigned long index;
-		unsigned long offset;
-		size_t copied;
-		void *xip_mem;
-		unsigned long xip_pfn;
-
-		offset = (pos & (PAGE_CACHE_SIZE -1)); /* Within page */
-		index = pos >> PAGE_CACHE_SHIFT;
-		bytes = PAGE_CACHE_SIZE - offset;
-		if (bytes > count)
-			bytes = count;
-
-		status = a_ops->get_xip_mem(mapping, index, 0,
-						&xip_mem, &xip_pfn);
-		if (status == -ENODATA) {
-			/* we allocate a new page unmap it */
-			mutex_lock(&xip_sparse_mutex);
-			status = a_ops->get_xip_mem(mapping, index, 1,
-							&xip_mem, &xip_pfn);
-			mutex_unlock(&xip_sparse_mutex);
-			if (!status)
-				/* unmap page at pgoff from all other vmas */
-				__xip_unmap(mapping, index);
-		}
-
-		if (status)
-			break;
-
-		copied = bytes -
-			__copy_from_user_nocache(xip_mem + offset, buf, bytes);
-
-		if (likely(copied > 0)) {
-			status = copied;
-
-			if (status >= 0) {
-				written += status;
-				count -= status;
-				pos += status;
-				buf += status;
-			}
-		}
-		if (unlikely(copied != bytes))
-			if (status >= 0)
-				status = -EFAULT;
-		if (status < 0)
-			break;
-	} while (count);
-	*ppos = pos;
-	/*
-	 * No need to use i_size_read() here, the i_size
-	 * cannot change under us because we hold i_mutex.
-	 */
-	if (pos > inode->i_size) {
-		i_size_write(inode, pos);
-		mark_inode_dirty(inode);
-	}
-
-	return written ? written : status;
-}
-
-ssize_t
-xip_file_write(struct file *filp, const char __user *buf, size_t len,
-	       loff_t *ppos)
-{
-	struct address_space *mapping = filp->f_mapping;
-	struct inode *inode = mapping->host;
-	size_t count;
-	loff_t pos;
-	ssize_t ret;
-
-	mutex_lock(&inode->i_mutex);
-
-	if (!access_ok(VERIFY_READ, buf, len)) {
-		ret=-EFAULT;
-		goto out_up;
-	}
-
-	pos = *ppos;
-	count = len;
-
-	/* We can write back this queue in page reclaim */
-	current->backing_dev_info = mapping->backing_dev_info;
-
-	ret = generic_write_checks(filp, &pos, &count, S_ISBLK(inode->i_mode));
-	if (ret)
-		goto out_backing;
-	if (count == 0)
-		goto out_backing;
-
-	ret = file_remove_suid(filp);
-	if (ret)
-		goto out_backing;
-
-	ret = file_update_time(filp);
-	if (ret)
-		goto out_backing;
-
-	ret = __xip_file_write (filp, buf, count, pos, ppos);
-
- out_backing:
-	current->backing_dev_info = NULL;
- out_up:
-	mutex_unlock(&inode->i_mutex);
-	return ret;
-}
-EXPORT_SYMBOL_GPL(xip_file_write);
-
 /*
  * truncate a page used for execute in place
  * functionality is analog to block_truncate_page but does use get_xip_mem
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
