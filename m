Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1D2386B0072
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 17:21:19 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id z10so2127543pdj.29
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 14:21:18 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id p5si5173993pdb.8.2014.10.24.14.21.17
        for <linux-mm@kvack.org>;
        Fri, 24 Oct 2014 14:21:17 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v12 06/20] dax,ext2: Replace XIP read and write with DAX I/O
Date: Fri, 24 Oct 2014 17:20:38 -0400
Message-Id: <1414185652-28663-7-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>

Use the generic AIO infrastructure instead of custom read and write
methods.  In addition to giving us support for AIO, this adds the missing
locking between read() and truncate().

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 MAINTAINERS        |   6 ++
 fs/Makefile        |   1 +
 fs/dax.c           | 186 ++++++++++++++++++++++++++++++++++++++++++
 fs/ext2/file.c     |   6 +-
 fs/ext2/inode.c    |   8 +-
 include/linux/fs.h |  12 ++-
 mm/filemap.c       |   6 +-
 mm/filemap_xip.c   | 234 -----------------------------------------------------
 8 files changed, 214 insertions(+), 245 deletions(-)
 create mode 100644 fs/dax.c

diff --git a/MAINTAINERS b/MAINTAINERS
index a20df9b..20c28f2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3006,6 +3006,12 @@ L:	linux-i2c@vger.kernel.org
 S:	Maintained
 F:	drivers/i2c/busses/i2c-diolan-u2c.c
 
+DIRECT ACCESS (DAX)
+M:	Matthew Wilcox <willy@linux.intel.com>
+L:	linux-fsdevel@vger.kernel.org
+S:	Supported
+F:	fs/dax.c
+
 DIRECTORY NOTIFICATION (DNOTIFY)
 M:	Eric Paris <eparis@parisplace.org>
 S:	Maintained
diff --git a/fs/Makefile b/fs/Makefile
index 90c8852..0325ec3 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -28,6 +28,7 @@ obj-$(CONFIG_SIGNALFD)		+= signalfd.o
 obj-$(CONFIG_TIMERFD)		+= timerfd.o
 obj-$(CONFIG_EVENTFD)		+= eventfd.o
 obj-$(CONFIG_AIO)               += aio.o
+obj-$(CONFIG_FS_XIP)		+= dax.o
 obj-$(CONFIG_FILE_LOCKING)      += locks.o
 obj-$(CONFIG_COMPAT)		+= compat.o compat_ioctl.o
 obj-$(CONFIG_BINFMT_AOUT)	+= binfmt_aout.o
diff --git a/fs/dax.c b/fs/dax.c
new file mode 100644
index 0000000..1a2bdbf
--- /dev/null
+++ b/fs/dax.c
@@ -0,0 +1,186 @@
+/*
+ * fs/dax.c - Direct Access filesystem code
+ * Copyright (c) 2013-2014 Intel Corporation
+ * Author: Matthew Wilcox <matthew.r.wilcox@intel.com>
+ * Author: Ross Zwisler <ross.zwisler@linux.intel.com>
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
+static long dax_get_addr(struct buffer_head *bh, void **addr, unsigned blkbits)
+{
+	unsigned long pfn;
+	sector_t sector = bh->b_blocknr << (blkbits - 9);
+	return bdev_direct_access(bh->b_bdev, sector, addr, &pfn, bh->b_size);
+}
+
+static void dax_new_buf(void *addr, unsigned size, unsigned first, loff_t pos,
+			loff_t end)
+{
+	loff_t final = end - pos + first; /* The final byte of the buffer */
+
+	if (first > 0)
+		memset(addr, 0, first);
+	if (final < size)
+		memset(addr + final, 0, size - final);
+}
+
+static bool buffer_written(struct buffer_head *bh)
+{
+	return buffer_mapped(bh) && !buffer_unwritten(bh);
+}
+
+/*
+ * When ext4 encounters a hole, it returns without modifying the buffer_head
+ * which means that we can't trust b_size.  To cope with this, we set b_state
+ * to 0 before calling get_block and, if any bit is set, we know we can trust
+ * b_size.  Unfortunate, really, since ext4 knows precisely how long a hole is
+ * and would save us time calling get_block repeatedly.
+ */
+static bool buffer_size_valid(struct buffer_head *bh)
+{
+	return bh->b_state != 0;
+}
+
+static ssize_t dax_io(int rw, struct inode *inode, struct iov_iter *iter,
+			loff_t start, loff_t end, get_block_t get_block,
+			struct buffer_head *bh)
+{
+	ssize_t retval = 0;
+	loff_t pos = start;
+	loff_t max = start;
+	loff_t bh_max = start;
+	void *addr;
+	bool hole = false;
+
+	if (rw != WRITE)
+		end = min(end, i_size_read(inode));
+
+	while (pos < end) {
+		unsigned len;
+		if (pos == max) {
+			unsigned blkbits = inode->i_blkbits;
+			sector_t block = pos >> blkbits;
+			unsigned first = pos - (block << blkbits);
+			long size;
+
+			if (pos == bh_max) {
+				bh->b_size = PAGE_ALIGN(end - pos);
+				bh->b_state = 0;
+				retval = get_block(inode, block, bh,
+								rw == WRITE);
+				if (retval)
+					break;
+				if (!buffer_size_valid(bh))
+					bh->b_size = 1 << blkbits;
+				bh_max = pos - first + bh->b_size;
+			} else {
+				unsigned done = bh->b_size -
+						(bh_max - (pos - first));
+				bh->b_blocknr += done >> blkbits;
+				bh->b_size -= done;
+			}
+
+			hole = (rw != WRITE) && !buffer_written(bh);
+			if (hole) {
+				addr = NULL;
+				size = bh->b_size - first;
+			} else {
+				retval = dax_get_addr(bh, &addr, blkbits);
+				if (retval < 0)
+					break;
+				if (buffer_unwritten(bh) || buffer_new(bh))
+					dax_new_buf(addr, retval, first, pos,
+									end);
+				addr += first;
+				size = retval - first;
+			}
+			max = min(pos + size, end);
+		}
+
+		if (rw == WRITE)
+			len = copy_from_iter(addr, max - pos, iter);
+		else if (!hole)
+			len = copy_to_iter(addr, max - pos, iter);
+		else
+			len = iov_iter_zero(max - pos, iter);
+
+		if (!len)
+			break;
+
+		pos += len;
+		addr += len;
+	}
+
+	return (pos == start) ? retval : pos - start;
+}
+
+/**
+ * dax_do_io - Perform I/O to a DAX file
+ * @rw: READ to read or WRITE to write
+ * @iocb: The control block for this I/O
+ * @inode: The file which the I/O is directed at
+ * @iter: The addresses to do I/O from or to
+ * @pos: The file offset where the I/O starts
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
+ssize_t dax_do_io(int rw, struct kiocb *iocb, struct inode *inode,
+			struct iov_iter *iter, loff_t pos,
+			get_block_t get_block, dio_iodone_t end_io, int flags)
+{
+	struct buffer_head bh;
+	ssize_t retval = -EINVAL;
+	loff_t end = pos + iov_iter_count(iter);
+
+	memset(&bh, 0, sizeof(bh));
+
+	if ((flags & DIO_LOCKING) && (rw == READ)) {
+		struct address_space *mapping = inode->i_mapping;
+		mutex_lock(&inode->i_mutex);
+		retval = filemap_write_and_wait_range(mapping, pos, end - 1);
+		if (retval) {
+			mutex_unlock(&inode->i_mutex);
+			goto out;
+		}
+	}
+
+	/* Protects against truncate */
+	atomic_inc(&inode->i_dio_count);
+
+	retval = dax_io(rw, inode, iter, pos, end, get_block, &bh);
+
+	if ((flags & DIO_LOCKING) && (rw == READ))
+		mutex_unlock(&inode->i_mutex);
+
+	if ((retval > 0) && end_io)
+		end_io(iocb, pos, retval, bh.b_private);
+
+	inode_dio_done(inode);
+ out:
+	return retval;
+}
+EXPORT_SYMBOL_GPL(dax_do_io);
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index 7c87b22..a247123 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -81,8 +81,10 @@ const struct file_operations ext2_file_operations = {
 #ifdef CONFIG_EXT2_FS_XIP
 const struct file_operations ext2_xip_file_operations = {
 	.llseek		= generic_file_llseek,
-	.read		= xip_file_read,
-	.write		= xip_file_write,
+	.read		= new_sync_read,
+	.write		= new_sync_write,
+	.read_iter	= generic_file_read_iter,
+	.write_iter	= generic_file_write_iter,
 	.unlocked_ioctl = ext2_ioctl,
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= ext2_compat_ioctl,
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 0cb0448..3ccd5fd 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -859,7 +859,12 @@ ext2_direct_IO(int rw, struct kiocb *iocb, struct iov_iter *iter,
 	size_t count = iov_iter_count(iter);
 	ssize_t ret;
 
-	ret = blockdev_direct_IO(rw, iocb, inode, iter, offset, ext2_get_block);
+	if (IS_DAX(inode))
+		ret = dax_do_io(rw, iocb, inode, iter, offset, ext2_get_block,
+				NULL, DIO_LOCKING);
+	else
+		ret = blockdev_direct_IO(rw, iocb, inode, iter, offset,
+					 ext2_get_block);
 	if (ret < 0 && (rw & WRITE))
 		ext2_write_failed(mapping, offset + count);
 	return ret;
@@ -888,6 +893,7 @@ const struct address_space_operations ext2_aops = {
 const struct address_space_operations ext2_aops_xip = {
 	.bmap			= ext2_bmap,
 	.get_xip_mem		= ext2_get_xip_mem,
+	.direct_IO		= ext2_direct_IO,
 };
 
 const struct address_space_operations ext2_nobh_aops = {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index ff0acb2..e024dc3 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2472,12 +2472,11 @@ extern loff_t fixed_size_llseek(struct file *file, loff_t offset,
 extern int generic_file_open(struct inode * inode, struct file * filp);
 extern int nonseekable_open(struct inode * inode, struct file * filp);
 
+ssize_t dax_do_io(int rw, struct kiocb *, struct inode *, struct iov_iter *,
+		loff_t, get_block_t, dio_iodone_t, int flags);
+
 #ifdef CONFIG_FS_XIP
-extern ssize_t xip_file_read(struct file *filp, char __user *buf, size_t len,
-			     loff_t *ppos);
 extern int xip_file_mmap(struct file * file, struct vm_area_struct * vma);
-extern ssize_t xip_file_write(struct file *filp, const char __user *buf,
-			      size_t len, loff_t *ppos);
 extern int xip_truncate_page(struct address_space *mapping, loff_t from);
 #else
 static inline int xip_truncate_page(struct address_space *mapping, loff_t from)
@@ -2641,6 +2640,11 @@ extern int generic_show_options(struct seq_file *m, struct dentry *root);
 extern void save_mount_options(struct super_block *sb, char *options);
 extern void replace_mount_options(struct super_block *sb, char *options);
 
+static inline bool io_is_direct(struct file *filp)
+{
+	return (filp->f_flags & O_DIRECT) || IS_DAX(file_inode(filp));
+}
+
 static inline ino_t parent_ino(struct dentry *dentry)
 {
 	ino_t res;
diff --git a/mm/filemap.c b/mm/filemap.c
index 2b13a4a..743278a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1699,8 +1699,7 @@ generic_file_read_iter(struct kiocb *iocb, struct iov_iter *iter)
 	loff_t *ppos = &iocb->ki_pos;
 	loff_t pos = *ppos;
 
-	/* coalesce the iovecs and go direct-to-BIO for O_DIRECT */
-	if (file->f_flags & O_DIRECT) {
+	if (io_is_direct(file)) {
 		struct address_space *mapping = file->f_mapping;
 		struct inode *inode = mapping->host;
 		size_t count = iov_iter_count(iter);
@@ -2590,8 +2589,7 @@ ssize_t __generic_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	if (err)
 		goto out;
 
-	/* coalesce the iovecs and go direct-to-BIO for O_DIRECT */
-	if (unlikely(file->f_flags & O_DIRECT)) {
+	if (io_is_direct(file)) {
 		loff_t endbyte;
 
 		written = generic_file_direct_write(iocb, from, pos);
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
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
