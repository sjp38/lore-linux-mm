Message-Id: <20080328015422.347175000@nick.local0.net>
References: <20080328015238.519230000@nick.local0.net>
Date: Fri, 28 Mar 2008 12:52:43 +1100
From: npiggin@suse.de
Subject: [patch 5/7] xip: support non-struct page backed memory
Content-Disposition: inline; filename=xip-get_xip_addr.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jared Hulbert <jaredeh@gmail.com>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Convert XIP to support non-struct page backed memory, using VM_MIXEDMAP
for the user mappings.

This requires the get_xip_page API to be changed to an address based one.
Improve the API layering a little bit too, while we're here.

This is required in order to support XIP filesystems on memory that isn't
backed with struct page (but memory with struct page is still supported too).

Signed-off-by: Nick Piggin <npiggin@suse.de>
Acked-by: Carsten Otte <cotte@de.ibm.com>
Cc: Jared Hulbert <jaredeh@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org
---
 fs/ext2/inode.c    |    2 
 fs/ext2/xip.c      |   36 ++++-----
 fs/ext2/xip.h      |    8 +-
 fs/open.c          |    2 
 include/linux/fs.h |    3 
 mm/fadvise.c       |    2 
 mm/filemap_xip.c   |  191 ++++++++++++++++++++++++++---------------------------
 mm/madvise.c       |    2 
 8 files changed, 122 insertions(+), 124 deletions(-)

Index: linux-2.6/fs/ext2/inode.c
===================================================================
--- linux-2.6.orig/fs/ext2/inode.c
+++ linux-2.6/fs/ext2/inode.c
@@ -795,7 +795,7 @@ const struct address_space_operations ex
 
 const struct address_space_operations ext2_aops_xip = {
 	.bmap			= ext2_bmap,
-	.get_xip_page		= ext2_get_xip_page,
+	.get_xip_mem		= ext2_get_xip_mem,
 };
 
 const struct address_space_operations ext2_nobh_aops = {
Index: linux-2.6/fs/ext2/xip.c
===================================================================
--- linux-2.6.orig/fs/ext2/xip.c
+++ linux-2.6/fs/ext2/xip.c
@@ -15,26 +15,28 @@
 #include "xip.h"
 
 static inline int
-__inode_direct_access(struct inode *inode, sector_t sector,
+__inode_direct_access(struct inode *inode, sector_t block,
 		      void **kaddr, unsigned long *pfn)
 {
 	struct block_device *bdev = inode->i_sb->s_bdev;
 	struct block_device_operations *ops = bdev->bd_disk->fops;
+	sector_t sector;
+
+	sector = block * (PAGE_SIZE / 512); /* ext2 block to bdev sector */
 
 	BUG_ON(!ops->direct_access);
 	return ops->direct_access(bdev, sector, kaddr, pfn);
 }
 
 static inline int
-__ext2_get_sector(struct inode *inode, sector_t offset, int create,
+__ext2_get_block(struct inode *inode, pgoff_t pgoff, int create,
 		   sector_t *result)
 {
 	struct buffer_head tmp;
 	int rc;
 
 	memset(&tmp, 0, sizeof(struct buffer_head));
-	rc = ext2_get_block(inode, offset/ (PAGE_SIZE/512), &tmp,
-			    create);
+	rc = ext2_get_block(inode, pgoff, &tmp, create);
 	*result = tmp.b_blocknr;
 
 	/* did we get a sparse block (hole in the file)? */
@@ -47,14 +49,13 @@ __ext2_get_sector(struct inode *inode, s
 }
 
 int
-ext2_clear_xip_target(struct inode *inode, int block)
+ext2_clear_xip_target(struct inode *inode, sector_t block)
 {
-	sector_t sector = block * (PAGE_SIZE/512);
 	void *kaddr;
 	unsigned long pfn;
 	int rc;
 
-	rc = __inode_direct_access(inode, sector, &kaddr, &pfn);
+	rc = __inode_direct_access(inode, block, &kaddr, &pfn);
 	if (!rc)
 		clear_page(kaddr);
 	return rc;
@@ -72,26 +73,18 @@ void ext2_xip_verify_sb(struct super_blo
 	}
 }
 
-struct page *
-ext2_get_xip_page(struct address_space *mapping, sector_t offset,
-		   int create)
+int ext2_get_xip_mem(struct address_space *mapping, pgoff_t pgoff, int create,
+				void **kmem, unsigned long *pfn)
 {
 	int rc;
-	void *kaddr;
-	unsigned long pfn;
-	sector_t sector;
+	sector_t block;
 
 	/* first, retrieve the sector number */
-	rc = __ext2_get_sector(mapping->host, offset, create, &sector);
+	rc = __ext2_get_block(mapping->host, pgoff, create, &block);
 	if (rc)
-		goto error;
+		return rc;
 
 	/* retrieve address of the target data */
-	rc = __inode_direct_access
-		(mapping->host, sector * (PAGE_SIZE/512), &kaddr, &pfn);
-	if (!rc)
-		return pfn_to_page(pfn);
-
- error:
-	return ERR_PTR(rc);
+	rc = __inode_direct_access(mapping->host, block, kmem, pfn);
+	return rc;
 }
Index: linux-2.6/fs/ext2/xip.h
===================================================================
--- linux-2.6.orig/fs/ext2/xip.h
+++ linux-2.6/fs/ext2/xip.h
@@ -7,19 +7,20 @@
 
 #ifdef CONFIG_EXT2_FS_XIP
 extern void ext2_xip_verify_sb (struct super_block *);
-extern int ext2_clear_xip_target (struct inode *, int);
+extern int ext2_clear_xip_target (struct inode *, sector_t);
 
 static inline int ext2_use_xip (struct super_block *sb)
 {
 	struct ext2_sb_info *sbi = EXT2_SB(sb);
 	return (sbi->s_mount_opt & EXT2_MOUNT_XIP);
 }
-struct page* ext2_get_xip_page (struct address_space *, sector_t, int);
-#define mapping_is_xip(map) unlikely(map->a_ops->get_xip_page)
+int ext2_get_xip_mem(struct address_space *, pgoff_t, int,
+				void **, unsigned long *);
+#define mapping_is_xip(map) unlikely(map->a_ops->get_xip_mem)
 #else
 #define mapping_is_xip(map)			0
 #define ext2_xip_verify_sb(sb)			do { } while (0)
 #define ext2_use_xip(sb)			0
 #define ext2_clear_xip_target(inode, chain)	0
-#define ext2_get_xip_page			NULL
+#define ext2_get_xip_mem			NULL
 #endif
Index: linux-2.6/fs/open.c
===================================================================
--- linux-2.6.orig/fs/open.c
+++ linux-2.6/fs/open.c
@@ -837,7 +837,7 @@ static struct file *__dentry_open(struct
 	if (f->f_flags & O_DIRECT) {
 		if (!f->f_mapping->a_ops ||
 		    ((!f->f_mapping->a_ops->direct_IO) &&
-		    (!f->f_mapping->a_ops->get_xip_page))) {
+		    (!f->f_mapping->a_ops->get_xip_mem))) {
 			fput(f);
 			f = ERR_PTR(-EINVAL);
 		}
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -475,8 +475,8 @@ struct address_space_operations {
 	int (*releasepage) (struct page *, gfp_t);
 	ssize_t (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
 			loff_t offset, unsigned long nr_segs);
-	struct page* (*get_xip_page)(struct address_space *, sector_t,
-			int);
+	int (*get_xip_mem)(struct address_space *, pgoff_t, int,
+						void **, unsigned long *);
 	/* migrate the contents of a page to the specified target */
 	int (*migratepage) (struct address_space *,
 			struct page *, struct page *);
Index: linux-2.6/mm/fadvise.c
===================================================================
--- linux-2.6.orig/mm/fadvise.c
+++ linux-2.6/mm/fadvise.c
@@ -49,7 +49,7 @@ asmlinkage long sys_fadvise64_64(int fd,
 		goto out;
 	}
 
-	if (mapping->a_ops->get_xip_page) {
+	if (mapping->a_ops->get_xip_mem) {
 		switch (advice) {
 		case POSIX_FADV_NORMAL:
 		case POSIX_FADV_RANDOM:
Index: linux-2.6/mm/filemap_xip.c
===================================================================
--- linux-2.6.orig/mm/filemap_xip.c
+++ linux-2.6/mm/filemap_xip.c
@@ -15,6 +15,7 @@
 #include <linux/rmap.h>
 #include <linux/sched.h>
 #include <asm/tlbflush.h>
+#include <asm/io.h>
 
 /*
  * We do use our own empty page to avoid interference with other users
@@ -42,37 +43,41 @@ static struct page *xip_sparse_page(void
 
 /*
  * This is a file read routine for execute in place files, and uses
- * the mapping->a_ops->get_xip_page() function for the actual low-level
+ * the mapping->a_ops->get_xip_mem() function for the actual low-level
  * stuff.
  *
  * Note the struct file* is not used at all.  It may be NULL.
  */
-static void
+static ssize_t
 do_xip_mapping_read(struct address_space *mapping,
 		    struct file_ra_state *_ra,
 		    struct file *filp,
-		    loff_t *ppos,
-		    read_descriptor_t *desc,
-		    read_actor_t actor)
+		    char __user *buf,
+		    size_t len,
+		    loff_t *ppos)
 {
 	struct inode *inode = mapping->host;
 	pgoff_t index, end_index;
 	unsigned long offset;
-	loff_t isize;
+	loff_t isize, pos;
+	size_t copied = 0, error = 0;
 
-	BUG_ON(!mapping->a_ops->get_xip_page);
+	BUG_ON(!mapping->a_ops->get_xip_mem);
 
-	index = *ppos >> PAGE_CACHE_SHIFT;
-	offset = *ppos & ~PAGE_CACHE_MASK;
+	pos = *ppos;
+	index = pos >> PAGE_CACHE_SHIFT;
+	offset = pos & ~PAGE_CACHE_MASK;
 
 	isize = i_size_read(inode);
 	if (!isize)
 		goto out;
 
 	end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
-	for (;;) {
-		struct page *page;
-		unsigned long nr, ret;
+	do {
+		unsigned long nr, left;
+		void *xip_mem;
+		unsigned long xip_pfn;
+		int zero = 0;
 
 		/* nr is the maximum number of bytes to copy from this page */
 		nr = PAGE_CACHE_SIZE;
@@ -85,19 +90,17 @@ do_xip_mapping_read(struct address_space
 			}
 		}
 		nr = nr - offset;
+		if (nr > len)
+			nr = len;
 
-		page = mapping->a_ops->get_xip_page(mapping,
-			index*(PAGE_SIZE/512), 0);
-		if (!page)
-			goto no_xip_page;
-		if (IS_ERR(page)) {
-			if (PTR_ERR(page) == -ENODATA) {
+		error = mapping->a_ops->get_xip_mem(mapping, index, 0,
+							&xip_mem, &xip_pfn);
+		if (unlikely(error)) {
+			if (error == -ENODATA) {
 				/* sparse */
-				page = ZERO_PAGE(0);
-			} else {
-				desc->error = PTR_ERR(page);
+				zero = 1;
+			} else
 				goto out;
-			}
 		}
 
 		/* If users can be writing to this page using arbitrary
@@ -105,10 +108,10 @@ do_xip_mapping_read(struct address_space
 		 * before reading the page on the kernel side.
 		 */
 		if (mapping_writably_mapped(mapping))
-			flush_dcache_page(page);
+			/* address based flush */ ;
 
 		/*
-		 * Ok, we have the page, so now we can copy it to user space...
+		 * Ok, we have the mem, so now we can copy it to user space...
 		 *
 		 * The actor routine returns how many bytes were actually used..
 		 * NOTE! This may not be the same as how much of a user buffer
@@ -116,47 +119,38 @@ do_xip_mapping_read(struct address_space
 		 * "pos" here (the actor routine has to update the user buffer
 		 * pointers and the remaining count).
 		 */
-		ret = actor(desc, page, offset, nr);
-		offset += ret;
-		index += offset >> PAGE_CACHE_SHIFT;
-		offset &= ~PAGE_CACHE_MASK;
+		if (!zero)
+			left = __copy_to_user(buf+copied, xip_mem+offset, nr);
+		else
+			left = __clear_user(buf + copied, nr);
 
-		if (ret == nr && desc->count)
-			continue;
-		goto out;
+		if (left) {
+			error = -EFAULT;
+			goto out;
+		}
 
-no_xip_page:
-		/* Did not get the page. Report it */
-		desc->error = -EIO;
-		goto out;
-	}
+		copied += (nr - left);
+		offset += (nr - left);
+		index += offset >> PAGE_CACHE_SHIFT;
+		offset &= ~PAGE_CACHE_MASK;
+	} while (copied < len);
 
 out:
-	*ppos = ((loff_t) index << PAGE_CACHE_SHIFT) + offset;
+	*ppos = pos + copied;
 	if (filp)
 		file_accessed(filp);
+
+	return (copied ? copied : error);
 }
 
 ssize_t
 xip_file_read(struct file *filp, char __user *buf, size_t len, loff_t *ppos)
 {
-	read_descriptor_t desc;
-
 	if (!access_ok(VERIFY_WRITE, buf, len))
 		return -EFAULT;
 
-	desc.written = 0;
-	desc.arg.buf = buf;
-	desc.count = len;
-	desc.error = 0;
-
-	do_xip_mapping_read(filp->f_mapping, &filp->f_ra, filp,
-			    ppos, &desc, file_read_actor);
-
-	if (desc.written)
-		return desc.written;
-	else
-		return desc.error;
+	return do_xip_mapping_read(filp->f_mapping, &filp->f_ra, filp,
+			    buf, len, ppos);
 }
 EXPORT_SYMBOL_GPL(xip_file_read);
 
@@ -211,13 +205,16 @@ __xip_unmap (struct address_space * mapp
  *
  * This function is derived from filemap_fault, but used for execute in place
  */
-static int xip_file_fault(struct vm_area_struct *area, struct vm_fault *vmf)
+static int xip_file_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	struct file *file = area->vm_file;
+	struct file *file = vma->vm_file;
 	struct address_space *mapping = file->f_mapping;
 	struct inode *inode = mapping->host;
-	struct page *page;
 	pgoff_t size;
+	void *xip_mem;
+	unsigned long xip_pfn;
+	struct page *page;
+	int error;
 
 	/* XXX: are VM_FAULT_ codes OK? */
 
@@ -225,35 +222,44 @@ static int xip_file_fault(struct vm_area
 	if (vmf->pgoff >= size)
 		return VM_FAULT_SIGBUS;
 
-	page = mapping->a_ops->get_xip_page(mapping,
-					vmf->pgoff*(PAGE_SIZE/512), 0);
-	if (!IS_ERR(page))
-		goto out;
-	if (PTR_ERR(page) != -ENODATA)
+	error = mapping->a_ops->get_xip_mem(mapping, vmf->pgoff, 0,
+						&xip_mem, &xip_pfn);
+	if (likely(!error))
+		goto found;
+	if (error != -ENODATA)
 		return VM_FAULT_OOM;
 
 	/* sparse block */
-	if ((area->vm_flags & (VM_WRITE | VM_MAYWRITE)) &&
-	    (area->vm_flags & (VM_SHARED| VM_MAYSHARE)) &&
+	if ((vma->vm_flags & (VM_WRITE | VM_MAYWRITE)) &&
+	    (vma->vm_flags & (VM_SHARED | VM_MAYSHARE)) &&
 	    (!(mapping->host->i_sb->s_flags & MS_RDONLY))) {
+		int err;
+
 		/* maybe shared writable, allocate new block */
-		page = mapping->a_ops->get_xip_page(mapping,
-					vmf->pgoff*(PAGE_SIZE/512), 1);
-		if (IS_ERR(page))
+		error = mapping->a_ops->get_xip_mem(mapping, vmf->pgoff, 1,
+							&xip_mem, &xip_pfn);
+		if (error)
 			return VM_FAULT_SIGBUS;
-		/* unmap page at pgoff from all other vmas */
+		/* unmap sparse mappings at pgoff from all other vmas */
 		__xip_unmap(mapping, vmf->pgoff);
+
+found:
+		err = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address,
+							xip_pfn);
+		if (err == -ENOMEM)
+			return VM_FAULT_OOM;
+		BUG_ON(err);
+		return VM_FAULT_NOPAGE;
 	} else {
 		/* not shared and writable, use xip_sparse_page() */
 		page = xip_sparse_page();
 		if (!page)
 			return VM_FAULT_OOM;
-	}
 
-out:
-	page_cache_get(page);
-	vmf->page = page;
-	return 0;
+		page_cache_get(page);
+		vmf->page = page;
+		return 0;
+	}
 }
 
 static struct vm_operations_struct xip_file_vm_ops = {
@@ -262,11 +268,11 @@ static struct vm_operations_struct xip_f
 
 int xip_file_mmap(struct file * file, struct vm_area_struct * vma)
 {
-	BUG_ON(!file->f_mapping->a_ops->get_xip_page);
+	BUG_ON(!file->f_mapping->a_ops->get_xip_mem);
 
 	file_accessed(file);
 	vma->vm_ops = &xip_file_vm_ops;
-	vma->vm_flags |= VM_CAN_NONLINEAR;
+	vma->vm_flags |= VM_CAN_NONLINEAR | VM_MIXEDMAP;
 	return 0;
 }
 EXPORT_SYMBOL_GPL(xip_file_mmap);
@@ -279,17 +285,17 @@ __xip_file_write(struct file *filp, cons
 	const struct address_space_operations *a_ops = mapping->a_ops;
 	struct inode 	*inode = mapping->host;
 	long		status = 0;
-	struct page	*page;
 	size_t		bytes;
 	ssize_t		written = 0;
 
-	BUG_ON(!mapping->a_ops->get_xip_page);
+	BUG_ON(!mapping->a_ops->get_xip_mem);
 
 	do {
 		unsigned long index;
 		unsigned long offset;
 		size_t copied;
-		char *kaddr;
+		void *xip_mem;
+		unsigned long xip_pfn;
 
 		offset = (pos & (PAGE_CACHE_SIZE -1)); /* Within page */
 		index = pos >> PAGE_CACHE_SHIFT;
@@ -297,28 +303,22 @@ __xip_file_write(struct file *filp, cons
 		if (bytes > count)
 			bytes = count;
 
-		page = a_ops->get_xip_page(mapping,
-					   index*(PAGE_SIZE/512), 0);
-		if (IS_ERR(page) && (PTR_ERR(page) == -ENODATA)) {
+		status = a_ops->get_xip_mem(mapping, index, 0,
+						&xip_mem, &xip_pfn);
+		if (status == -ENODATA) {
 			/* we allocate a new page unmap it */
-			page = a_ops->get_xip_page(mapping,
-						   index*(PAGE_SIZE/512), 1);
-			if (!IS_ERR(page))
+			status = a_ops->get_xip_mem(mapping, index, 1,
+							&xip_mem, &xip_pfn);
+			if (!status)
 				/* unmap page at pgoff from all other vmas */
 				__xip_unmap(mapping, index);
 		}
 
-		if (IS_ERR(page)) {
-			status = PTR_ERR(page);
+		if (status)
 			break;
-		}
 
-		fault_in_pages_readable(buf, bytes);
-		kaddr = kmap_atomic(page, KM_USER0);
 		copied = bytes -
-			__copy_from_user_inatomic_nocache(kaddr + offset, buf, bytes);
-		kunmap_atomic(kaddr, KM_USER0);
-		flush_dcache_page(page);
+			__copy_from_user_nocache(xip_mem + offset, buf, bytes);
 
 		if (likely(copied > 0)) {
 			status = copied;
@@ -398,7 +398,7 @@ EXPORT_SYMBOL_GPL(xip_file_write);
 
 /*
  * truncate a page used for execute in place
- * functionality is analog to block_truncate_page but does use get_xip_page
+ * functionality is analog to block_truncate_page but does use get_xip_mem
  * to get the page instead of page cache
  */
 int
@@ -408,9 +408,11 @@ xip_truncate_page(struct address_space *
 	unsigned offset = from & (PAGE_CACHE_SIZE-1);
 	unsigned blocksize;
 	unsigned length;
-	struct page *page;
+	void *xip_mem;
+	unsigned long xip_pfn;
+	int err;
 
-	BUG_ON(!mapping->a_ops->get_xip_page);
+	BUG_ON(!mapping->a_ops->get_xip_mem);
 
 	blocksize = 1 << mapping->host->i_blkbits;
 	length = offset & (blocksize - 1);
@@ -421,18 +423,16 @@ xip_truncate_page(struct address_space *
 
 	length = blocksize - length;
 
-	page = mapping->a_ops->get_xip_page(mapping,
-					    index*(PAGE_SIZE/512), 0);
-	if (!page)
-		return -ENOMEM;
-	if (IS_ERR(page)) {
-		if (PTR_ERR(page) == -ENODATA)
+	err = mapping->a_ops->get_xip_mem(mapping, index, 0,
+						&xip_mem, &xip_pfn);
+	if (unlikely(err)) {
+		if (err == -ENODATA)
 			/* Hole? No need to truncate */
 			return 0;
 		else
-			return PTR_ERR(page);
+			return err;
 	}
-	zero_user(page, offset, length);
+	memset(xip_mem + offset, 0, length);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(xip_truncate_page);
Index: linux-2.6/mm/madvise.c
===================================================================
--- linux-2.6.orig/mm/madvise.c
+++ linux-2.6/mm/madvise.c
@@ -112,7 +112,7 @@ static long madvise_willneed(struct vm_a
 	if (!file)
 		return -EBADF;
 
-	if (file->f_mapping->a_ops->get_xip_page) {
+	if (file->f_mapping->a_ops->get_xip_mem) {
 		/* no bad return value, but ignore advice */
 		return 0;
 	}

-- 
