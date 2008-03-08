Received: by rv-out-0910.google.com with SMTP id f1so499544rvb.26
        for <linux-mm@kvack.org>; Fri, 07 Mar 2008 20:33:42 -0800 (PST)
Message-ID: <6934efce0803072033m5efd4d1o1ca8526f94649bb5@mail.gmail.com>
Date: Fri, 7 Mar 2008 20:33:42 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: [RFC][PATCH 1/3] xip: no struct pages -- get_xip_mem
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Maxim Shchetynin <maxim@de.ibm.com>
List-ID: <linux-mm.kvack.org>

[RFC][PATCH 1/3] xip: no struct pages -- get_xip_mem

Convert XIP to support non-struct page backed memory.
The get_xip_page API is changed from a page based to an address/pfn based one.

(Eventually needs Nicks SOB)
Signed-off-by: Jared Hulbert <jaredeh@gmail.com>
---

 fs/open.c          |    2
 include/linux/fs.h |    4 -
 mm/fadvise.c       |    2
 mm/filemap_xip.c   |  204 ++++++++++++++++++++++++-----------------------------
 mm/madvise.c       |    2
 5 files changed, 101 insertions(+), 113 deletions(-)

---
diff --git a/fs/open.c b/fs/open.c
index 5419853..9a2d5f6 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -774,7 +774,7 @@ static struct file *__dentry_open(struct dentry
*dentry, struct vfsmount *mnt,
 	if (f->f_flags & O_DIRECT) {
 		if (!f->f_mapping->a_ops ||
 		    ((!f->f_mapping->a_ops->direct_IO) &&
-		    (!f->f_mapping->a_ops->get_xip_page))) {
+		    (!f->f_mapping->a_ops->get_xip_mem))) {
 			fput(f);
 			f = ERR_PTR(-EINVAL);
 		}
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b84b848..ac671bc 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -475,8 +475,8 @@ struct address_space_operations {
 	int (*releasepage) (struct page *, gfp_t);
 	ssize_t (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
 			loff_t offset, unsigned long nr_segs);
-	struct page* (*get_xip_page)(struct address_space *, sector_t,
-			int);
+	int (*get_xip_mem)(struct address_space *, pgoff_t, int, void **,
+			unsigned long *);
 	/* migrate the contents of a page to the specified target */
 	int (*migratepage) (struct address_space *,
 			struct page *, struct page *);
diff --git a/mm/fadvise.c b/mm/fadvise.c
index 3c0f1e9..343cfdf 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -49,7 +49,7 @@ asmlinkage long sys_fadvise64_64(int fd, loff_t
offset, loff_t len, int advice)
 		goto out;
 	}

-	if (mapping->a_ops->get_xip_page) {
+	if (mapping->a_ops->get_xip_mem) {
 		switch (advice) {
 		case POSIX_FADV_NORMAL:
 		case POSIX_FADV_RANDOM:
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index 5e598c4..2cd8ad0 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -15,6 +15,7 @@
 #include <linux/rmap.h>
 #include <linux/sched.h>
 #include <asm/tlbflush.h>
+#include <asm/io.h>

 /*
  * We do use our own empty page to avoid interference with other users
@@ -42,25 +43,26 @@ static struct page *xip_sparse_page(void)

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
 		    loff_t *ppos,
-		    read_descriptor_t *desc,
-		    read_actor_t actor)
+		    char __user *buf,
+		    size_t len)
 {
 	struct inode *inode = mapping->host;
 	pgoff_t index, end_index;
 	unsigned long offset;
 	loff_t isize;
+	size_t copied = 0, error = 0;

-	BUG_ON(!mapping->a_ops->get_xip_page);
+	BUG_ON(!mapping->a_ops->get_xip_mem);

 	index = *ppos >> PAGE_CACHE_SHIFT;
 	offset = *ppos & ~PAGE_CACHE_MASK;
@@ -70,10 +72,10 @@ do_xip_mapping_read(struct address_space *mapping,
 		goto out;

 	end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
-	for (;;) {
-		struct page *page;
-		unsigned long nr, ret;
-
+	do {
+		unsigned long nr, left, pfn;
+		void *kaddr;
+		int zero = 0;
 		/* nr is the maximum number of bytes to copy from this page */
 		nr = PAGE_CACHE_SIZE;
 		if (index >= end_index) {
@@ -85,19 +87,16 @@ do_xip_mapping_read(struct address_space *mapping,
 			}
 		}
 		nr = nr - offset;
+		if (nr > len)
+			nr = len;

-		page = mapping->a_ops->get_xip_page(mapping,
-			index*(PAGE_SIZE/512), 0);
-		if (!page)
-			goto no_xip_page;
-		if (unlikely(IS_ERR(page))) {
-			if (PTR_ERR(page) == -ENODATA) {
-				/* sparse */
-				page = ZERO_PAGE(0);
-			} else {
-				desc->error = PTR_ERR(page);
+		error = mapping->a_ops->get_xip_mem(mapping, index, 0, &kaddr,
+						    &pfn);
+		if (error) {
+			if (error != -ENODATA)
 				goto out;
-			}
+			/* sparse */
+			zero = 1;
 		}

 		/* If users can be writing to this page using arbitrary
@@ -105,10 +104,10 @@ do_xip_mapping_read(struct address_space *mapping,
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
@@ -116,47 +115,38 @@ do_xip_mapping_read(struct address_space *mapping,
 		 * "pos" here (the actor routine has to update the user buffer
 		 * pointers and the remaining count).
 		 */
-		ret = actor(desc, page, offset, nr);
-		offset += ret;
-		index += offset >> PAGE_CACHE_SHIFT;
-		offset &= ~PAGE_CACHE_MASK;
+		if (!zero)
+			left = __copy_to_user(buf + copied, kaddr + offset, nr);
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
+	*ppos += copied;
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
+				   ppos, buf, len);
 }
 EXPORT_SYMBOL_GPL(xip_file_read);

@@ -211,13 +201,16 @@ __xip_unmap (struct address_space * mapping,
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
 	struct page *page;
 	pgoff_t size;
+	void *kaddr;
+	unsigned long pfn;
+	int err;

 	/* XXX: are VM_FAULT_ codes OK? */

@@ -225,35 +218,39 @@ static int xip_file_fault(struct vm_area_struct
*area, struct vm_fault *vmf)
 	if (vmf->pgoff >= size)
 		return VM_FAULT_SIGBUS;

-	page = mapping->a_ops->get_xip_page(mapping,
-					vmf->pgoff*(PAGE_SIZE/512), 0);
-	if (!IS_ERR(page))
-		goto out;
-	if (PTR_ERR(page) != -ENODATA)
+	err = mapping->a_ops->get_xip_mem(mapping, vmf->pgoff, 0, &kaddr, &pfn);
+	if (!err)
+		goto found;
+
+	if (err != -ENODATA)
 		return VM_FAULT_OOM;

-	/* sparse block */
-	if ((area->vm_flags & (VM_WRITE | VM_MAYWRITE)) &&
-	    (area->vm_flags & (VM_SHARED| VM_MAYSHARE)) &&
-	    (!(mapping->host->i_sb->s_flags & MS_RDONLY))) {
-		/* maybe shared writable, allocate new block */
-		page = mapping->a_ops->get_xip_page(mapping,
-					vmf->pgoff*(PAGE_SIZE/512), 1);
-		if (IS_ERR(page))
-			return VM_FAULT_SIGBUS;
-		/* unmap page at pgoff from all other vmas */
-		__xip_unmap(mapping, vmf->pgoff);
-	} else {
+	if ((!(vma->vm_flags & (VM_WRITE | VM_MAYWRITE))) &&
+	    (!(vma->vm_flags & (VM_SHARED| VM_MAYSHARE))) &&
+	    (mapping->host->i_sb->s_flags & MS_RDONLY)) {
 		/* not shared and writable, use xip_sparse_page() */
 		page = xip_sparse_page();
 		if (!page)
 			return VM_FAULT_OOM;
+
+		page_cache_get(page);
+		vmf->page = page;
+		return 0;
 	}

-out:
-	page_cache_get(page);
-	vmf->page = page;
-	return 0;
+	/* maybe shared writable, allocate new block */
+	err = mapping->a_ops->get_xip_mem(mapping,vmf->pgoff, 1, &kaddr, &pfn);
+	if (err)
+		return VM_FAULT_SIGBUS;
+	/* unmap sparse mappings at pgoff from all other vmas */
+	__xip_unmap(mapping, vmf->pgoff);
+
+ found:
+	err = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address, pfn);
+	if (err == -ENOMEM)
+		return VM_FAULT_OOM;
+	BUG_ON(err);
+	return VM_FAULT_NOPAGE;
 }

 static struct vm_operations_struct xip_file_vm_ops = {
@@ -262,11 +259,11 @@ static struct vm_operations_struct xip_file_vm_ops = {

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
@@ -279,17 +276,16 @@ __xip_file_write(struct file *filp, const char
__user *buf,
 	const struct address_space_operations *a_ops = mapping->a_ops;
 	struct inode 	*inode = mapping->host;
 	long		status = 0;
-	struct page	*page;
 	size_t		bytes;
 	ssize_t		written = 0;

-	BUG_ON(!mapping->a_ops->get_xip_page);
+	BUG_ON(!mapping->a_ops->get_xip_mem);

 	do {
-		unsigned long index;
-		unsigned long offset;
+		unsigned long index, offset, pfn;
 		size_t copied;
-		char *kaddr;
+		void *kaddr;
+		int err;

 		offset = (pos & (PAGE_CACHE_SIZE -1)); /* Within page */
 		index = pos >> PAGE_CACHE_SHIFT;
@@ -297,28 +293,23 @@ __xip_file_write(struct file *filp, const char
__user *buf,
 		if (bytes > count)
 			bytes = count;

-		page = a_ops->get_xip_page(mapping,
-					   index*(PAGE_SIZE/512), 0);
-		if (IS_ERR(page) && (PTR_ERR(page) == -ENODATA)) {
+		err = a_ops->get_xip_mem(mapping, index, 0, &kaddr, &pfn);
+		if (err && (err == -ENODATA)) {
 			/* we allocate a new page unmap it */
-			page = a_ops->get_xip_page(mapping,
-						   index*(PAGE_SIZE/512), 1);
-			if (!IS_ERR(page))
+			err = a_ops->get_xip_mem(mapping, index, 1, &kaddr,
+						 &pfn);
+			if (!err)
 				/* unmap page at pgoff from all other vmas */
 				__xip_unmap(mapping, index);
 		}

-		if (IS_ERR(page)) {
-			status = PTR_ERR(page);
+		if (err) {
+			status = err;
 			break;
 		}

-		fault_in_pages_readable(buf, bytes);
-		kaddr = kmap_atomic(page, KM_USER0);
-		copied = bytes -
-			__copy_from_user_inatomic_nocache(kaddr + offset, buf, bytes);
-		kunmap_atomic(kaddr, KM_USER0);
-		flush_dcache_page(page);
+		copied = bytes;
+		copied -= __copy_from_user_nocache(kaddr + offset, buf, bytes);

 		if (likely(copied > 0)) {
 			status = copied;
@@ -398,7 +389,7 @@ EXPORT_SYMBOL_GPL(xip_file_write);

 /*
  * truncate a page used for execute in place
- * functionality is analog to block_truncate_page but does use get_xip_page
+ * functionality is analog to block_truncate_page but does use get_xip_mem
  * to get the page instead of page cache
  */
 int
@@ -408,9 +399,11 @@ xip_truncate_page(struct address_space *mapping,
loff_t from)
 	unsigned offset = from & (PAGE_CACHE_SIZE-1);
 	unsigned blocksize;
 	unsigned length;
-	struct page *page;
+	void *kaddr;
+	unsigned long pfn;
+	int err;

-	BUG_ON(!mapping->a_ops->get_xip_page);
+	BUG_ON(!mapping->a_ops->get_xip_mem);

 	blocksize = 1 << mapping->host->i_blkbits;
 	length = offset & (blocksize - 1);
@@ -421,18 +414,13 @@ xip_truncate_page(struct address_space *mapping,
loff_t from)

 	length = blocksize - length;

-	page = mapping->a_ops->get_xip_page(mapping,
-					    index*(PAGE_SIZE/512), 0);
-	if (!page)
-		return -ENOMEM;
-	if (unlikely(IS_ERR(page))) {
-		if (PTR_ERR(page) == -ENODATA)
-			/* Hole? No need to truncate */
-			return 0;
-		else
-			return PTR_ERR(page);
+	err = mapping->a_ops->get_xip_mem(mapping, index, 0, &kaddr, &pfn);
+	if (!err) {
+		memset(kaddr + offset, 0, length);
+	} else if (err == -ENODATA) {
+		/* Hole? No need to truncate */
+		return 0;
 	}
-	zero_user(page, offset, length);
-	return 0;
+	return err;
 }
 EXPORT_SYMBOL_GPL(xip_truncate_page);
diff --git a/mm/madvise.c b/mm/madvise.c
index 93ee375..23a0ec3 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -112,7 +112,7 @@ static long madvise_willneed(struct vm_area_struct * vma,
 	if (!file)
 		return -EBADF;

-	if (file->f_mapping->a_ops->get_xip_page) {
+	if (file->f_mapping->a_ops->get_xip_mem) {
 		/* no bad return value, but ignore advice */
 		return 0;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
