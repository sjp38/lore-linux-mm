From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: pageable memory allocator (for DRM-GEM?)
Date: Tue, 23 Sep 2008 11:10:17 +0200
Message-ID: <20080923091017.GB29718__13440.0051123977$1222161160$gmane$org@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: keith.packard@intel.com, eric@anholt.net, hugh@veritas.com, hch@infradead.org, airlied@linux.ie, jbarnes@virtuousgeek.org, thomas@tungstengraphics.com, dri-devel@lists.sourceforge.net
List-Id: linux-mm.kvack.org

Hi,

So I promised I would look at this again, because I (and others) have some
issues with exporting shmem_file_setup for DRM-GEM to go off and do things
with.

The rationale for using shmem seems to be that pageable "objects" are needed,
and they can't be created by userspace because that would be ugly for some
reason, and/or they are required before userland is running.

I particularly don't like the idea of exposing these vfs objects to random
drivers because they're likely to get things wrong or become out of synch
or unreviewed if things change. I suggested a simple pageable object allocator
that could live in mm and hide the exact details of how shmem / pagecache
works. So I've coded that up quickly.

Upon actually looking at how "GEM" makes use of its shmem_file_setup filp, I
see something strange... it seems that userspace actually gets some kind of
descriptor, a descriptor to an object backed by this shmem file (let's call it
a "file descriptor"). Anyway, it turns out that userspace sometimes needs to
pread, pwrite, and mmap these objects, but unfortunately it has no direct way
to do that, due to not having open(2)ed the files directly. So what GEM does
is to add some ioctls which take the "file descriptor" things, and derives
the shmem file from them, and then calls into the vfs to perform the operation.

If my cursory reading is correct, then my allocator won't work so well as a
drop in replacement because one isn't allowed to know about the filp behind
the pageable object. It would also indicate some serious crack smoking by
anyone who thinks open(2), pread(2), mmap(2), etc is ugly in comparison...

So please, nobody who worked on that code is allowed to use ugly as an
argument. Technical arguments are fine, so let's try to cover them.

BTW. without knowing much of either the GEM or the SPU subsystems, the
GEM problem seems similar to SPU. Did anyone look at that code? Was it ever
considered to make the object allocator be a filesystem? That way you could
control the backing store to the objects yourself, those that want pageable
memory could use the following allocator, the ioctls could go away,
you could create your own objects if needed before userspace is up...

---

Create a simple memory allocator which can page out objects when they are
not in use. Uses shmem for the main infrastructure (except in the nommu
case where it uses slab). The smallest unit of granularity is a page, so it
is not yet suitable for tiny objects.

The API allows creation and deletion of memory objects, pinning and
unpinning of address ranges within an object, mapping ranges of an object
in KVA, dirtying ranges of an object, and operating on pages within the
object.

Cc: keith.packard@intel.com, eric@anholt.net, hugh@veritas.com, hch@infradead.org, airlied@linux.ie, jbarnes@virtuousgeek.org, thomas@tungstengraphics.com, dri-devel@lists.sourceforge.net

---
Index: linux-2.6/include/linux/pageable_alloc.h
===================================================================
--- /dev/null
+++ linux-2.6/include/linux/pageable_alloc.h
@@ -0,0 +1,112 @@
+#ifndef __MM_PAGEABLE_ALLOC_H__
+#define __MM_PAGEABLE_ALLOC_H__
+
+#include <linux/mm.h>
+
+struct pgobj;
+typedef struct pgobj pgobj_t;
+
+/**
+ * pageable_alloc_object - Allocate a pageable object
+ * @size: size in bytes
+ * @nid: preferred node, or -1 for default policy
+ * Returns: an object pointer, or IS_ERR pointer on fail
+ */
+pgobj_t *pageable_alloc_object(unsigned long size, int nid);
+
+/**
+ * pageable_free_object - Free a pageable object
+ * @object: object pointer
+ */
+void pageable_free_object(pgobj_t *object);
+
+/**
+ * pageable_pin_object - Pin an address range of a pageable object
+ * @object: object pointer
+ * @start: first byte in the object to be pinned
+ * @end: last byte in the object to be pinned (not inclusive)
+ *
+ * pageable_pin_object must be called before the memory range can be used in
+ * any way the pageable object accessor functions. pageable_pin_object may
+ * have to swap pages in from disk. A successful call must be followed (at
+ * some point) by a call to pageable_unpin_object with the same range.
+ *
+ * Note: the end address is not inclusive, so a (0, 1) range is the first byte.
+ */
+int pageable_pin_object(pgobj_t *object, unsigned long start, unsigned long end);
+
+/**
+ * pageable_unpin_object - Unpin an address range of a pageable object
+ * @object: object pointer
+ * @start: first byte in the object to be unpinned
+ * @end: last byte in the object to be unpinned (not inclusive)
+ *
+ * Note: the end address is not inclusive, so a (0, 1) range is the first byte.
+ */
+void pageable_unpin_object(pgobj_t *object, unsigned long start, unsigned long end);
+
+/**
+ * pageable_dirty_object - Dirty an address range of a pageable object
+ * @object: object pointer
+ * @start: first byte in the object to be dirtied
+ * @end: last byte in the object to be dirtied (not inclusive)
+ *
+ * If a part of the memory of a pageable object is written to,
+ * pageable_dirty_object must be called on this range before it is unpinned.
+ *
+ * Note: the end address is not inclusive, so a (0, 1) range is the first byte.
+ */
+void pageable_dirty_object(pgobj_t *object, unsigned long start, unsigned long end);
+
+/**
+ * pageable_get_page - Get one page of a pageable object
+ * @object: object pointer
+ * @off: byte in the object containing the desired page
+ * @Returns: page pointer requested
+ *
+ * Note: this does not increment the page refcount in any way, however the
+ * page refcount would already be pinned by a call to pageable_pin_object.
+ */
+struct page *pageable_get_page(pgobj_t *object, unsigned long off);
+
+/**
+ * pageable_dirty_page - Dirty one page of a pageable object
+ * @object: object pointer
+ * @page: page pointer returned by pageable_get_page
+ *
+ * Like pageable_dirty_object. If the page returned by pageable_get_page
+ * is dirtied, pageable_dirty_page must be called before it is unpinned.
+ */
+void pageable_dirty_page(pgobj_t *object, struct page *page);
+
+/**
+ * pageable_vmap_object - Map an address range of a pageable object
+ * @object: object pointer
+ * @start: first byte in the object to be mapped
+ * @end: last byte in the object to be mapped (not inclusive)
+ * @Returns: kernel virtual address, NULL on memory allocation failure
+ *
+ * This maps a specified range of a pageable object into kernel virtual
+ * memory, where it can be treated and operated on as regular memory. It
+ * must be followed by a call to pageable_vunmap_object.
+ *
+ * Note: the end address is not inclusive, so a (0, 1) range is the first byte.
+ */
+void *pageable_vmap_object(pgobj_t *object, unsigned long start, unsigned long end);
+
+/**
+ * pageable_vunmap_object - Unmap an address range of a pageable object
+ * @object: object pointer
+ * @ptr: pointer returned by pageable_vmap_object
+ * @start: first byte in the object to be mapped
+ * @end: last byte in the object to be mapped (not inclusive)
+ *
+ * This maps a specified range of a pageable object into kernel virtual
+ * memory, where it can be treated and operated on as regular memory. It
+ * must be followed by a call to pageable_vunmap_object.
+ *
+ * Note: the end address is not inclusive, so a (0, 1) range is the first byte.
+ */
+void pageable_vunmap_object(pgobj_t *object, void *ptr, unsigned long start, unsigned long end);
+
+#endif
Index: linux-2.6/mm/Makefile
===================================================================
--- linux-2.6.orig/mm/Makefile
+++ linux-2.6/mm/Makefile
@@ -11,7 +11,7 @@ obj-y			:= bootmem.o filemap.o mempool.o
 			   maccess.o page_alloc.o page-writeback.o pdflush.o \
 			   readahead.o swap.o truncate.o vmscan.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
-			   page_isolation.o mm_init.o $(mmu-y)
+			   page_isolation.o mm_init.o pageable_alloc.o $(mmu-y)
 
 obj-$(CONFIG_PROC_PAGE_MONITOR) += pagewalk.o
 obj-$(CONFIG_BOUNCE)	+= bounce.o
Index: linux-2.6/mm/pageable_alloc.c
===================================================================
--- /dev/null
+++ linux-2.6/mm/pageable_alloc.c
@@ -0,0 +1,260 @@
+/*
+ * Simple pageable memory allocator
+ *
+ * Copyright (C) 2008 Nick Piggin
+ * Copyright (C) 2008 Novell Inc.
+ */
+#include <linux/pageable_alloc.h>
+#include <linux/mm.h>
+#include <linux/fs.h>
+#include <linux/pagemap.h>
+#include <linux/file.h>
+#include <linux/vmalloc.h>
+#include <linux/slab.h>
+#include <linux/radix-tree.h>
+
+#ifdef CONFIG_MMU
+struct pgobj {
+	struct file f;
+};
+
+pgobj_t *pageable_alloc_object(unsigned long size, int nid)
+{
+	struct file *filp;
+
+	filp = shmem_file_setup("pageable object", size, 0);
+
+	return (struct pgobj *)filp;
+}
+
+void pageable_free_object(pgobj_t *object)
+{
+	struct file *filp = (struct file *)object;
+
+	fput(filp);
+}
+
+int pageable_pin_object(pgobj_t *object, unsigned long start, unsigned long end)
+{
+	struct file *filp = (struct file *)object;
+	struct address_space *mapping = filp->f_dentry->d_inode->i_mapping;
+	pgoff_t first, last, i;
+	int err = 0;
+
+	BUG_ON(start >= end);
+
+	first = start / PAGE_SIZE;
+	last = DIV_ROUND_UP(end, PAGE_SIZE);
+
+	for (i = first; i < last; i++) {
+		struct page *page;
+
+		page = read_mapping_page(mapping, i, filp);
+		if (IS_ERR(page)) {
+			err = PTR_ERR(page);
+			goto out_error;
+		}
+	}
+
+	BUG_ON(err);
+	return 0;
+
+out_error:
+	if (i > first)
+		pageable_unpin_object(object, start, start + i*PAGE_SIZE);
+	return err;
+}
+
+void pageable_unpin_object(pgobj_t *object, unsigned long start, unsigned long end)
+{
+	struct file *filp = (struct file *)object;
+	struct address_space *mapping = filp->f_dentry->d_inode->i_mapping;
+	pgoff_t first, last, i;
+
+	BUG_ON(start >= end);
+
+	first = start / PAGE_SIZE;
+	last = DIV_ROUND_UP(end, PAGE_SIZE);
+
+	for (i = first; i < last; i++) {
+		struct page *page;
+
+		rcu_read_lock();
+		page = radix_tree_lookup(&mapping->page_tree, i);
+		rcu_read_unlock();
+		BUG_ON(!page);
+		BUG_ON(page_count(page) < 2);
+		page_cache_release(page);
+	}
+}
+
+void pageable_dirty_object(pgobj_t *object, unsigned long start, unsigned long end)
+{
+	struct file *filp = (struct file *)object;
+	struct address_space *mapping = filp->f_dentry->d_inode->i_mapping;
+	pgoff_t first, last, i;
+
+	BUG_ON(start >= end);
+
+	first = start / PAGE_SIZE;
+	last = DIV_ROUND_UP(end, PAGE_SIZE);
+
+	for (i = first; i < last; i++) {
+		struct page *page;
+
+		rcu_read_lock();
+		page = radix_tree_lookup(&mapping->page_tree, i);
+		rcu_read_unlock();
+		BUG_ON(!page);
+		BUG_ON(page_count(page) < 2);
+		set_page_dirty(page);
+	}
+}
+
+struct page *pageable_get_page(pgobj_t *object, unsigned long off)
+{
+	struct file *filp = (struct file *)object;
+	struct address_space *mapping = filp->f_dentry->d_inode->i_mapping;
+	struct page *page;
+
+	rcu_read_lock();
+	page = radix_tree_lookup(&mapping->page_tree, off / PAGE_SIZE);
+	rcu_read_unlock();
+
+	BUG_ON(!page);
+	BUG_ON(page_count(page) < 2);
+
+	return page;
+}
+
+void pageable_dirty_page(pgobj_t *object, struct page *page)
+{
+	BUG_ON(page_count(page) < 2);
+	set_page_dirty(page);
+}
+
+void *pageable_vmap_object(pgobj_t *object, unsigned long start, unsigned long end)
+{
+	struct file *filp = (struct file *)object;
+	struct address_space *mapping = filp->f_dentry->d_inode->i_mapping;
+	unsigned int offset = start & ~PAGE_CACHE_MASK;
+	pgoff_t first, last, i;
+	struct page **pages;
+	int nr;
+	void *ret;
+
+	BUG_ON(start >= end);
+
+	first = start / PAGE_SIZE;
+	last = DIV_ROUND_UP(end, PAGE_SIZE);
+	nr = last - first;
+
+#ifndef CONFIG_HIGHMEM
+	if (nr == 1) {
+		struct page *page;
+
+		rcu_read_lock();
+		page = radix_tree_lookup(&mapping->page_tree, first);
+		rcu_read_unlock();
+		BUG_ON(!page);
+		BUG_ON(page_count(page) < 2);
+
+		ret = page_address(page);
+
+		goto out;
+	}
+#endif
+
+	pages = kmalloc(sizeof(struct page *) * nr, GFP_KERNEL);
+	if (!pages)
+		return NULL;
+
+	for (i = first; i < last; i++) {
+		struct page *page;
+
+		rcu_read_lock();
+		page = radix_tree_lookup(&mapping->page_tree, i);
+		rcu_read_unlock();
+		BUG_ON(!page);
+		BUG_ON(page_count(page) < 2);
+
+		pages[i] = page;
+	}
+
+	ret = vmap(pages, nr, VM_MAP, PAGE_KERNEL);
+	kfree(pages);
+	if (!ret)
+		return NULL;
+
+out:
+	return ret + offset;
+}
+
+void pageable_vunmap_object(pgobj_t *object, void *ptr, unsigned long start, unsigned long end)
+{
+#ifndef CONFIG_HIGHMEM
+	pgoff_t first, last;
+	int nr;
+
+	BUG_ON(start >= end);
+
+	first = start / PAGE_SIZE;
+	last = DIV_ROUND_UP(end, PAGE_SIZE);
+	nr = last - first;
+	if (nr == 1)
+		return;
+#endif
+
+	vunmap((void *)((unsigned long)ptr & PAGE_CACHE_MASK));
+}
+
+#else
+
+pgobj_t *pageable_alloc_object(unsigned long size, int nid)
+{
+	void *ret;
+
+	ret = kmalloc(size, GFP_KERNEL);
+	if (!ret)
+		return ERR_PTR(-ENOMEM);
+
+	return ret;
+}
+
+void pageable_free_object(pgobj_t *object)
+{
+	kfree(object);
+}
+
+int pageable_pin_object(pgobj_t *object, unsigned long start, unsigned long end){
+	return 0;
+}
+
+void pageable_unpin_object(pgobj_t *object, unsigned long start, unsigned long end)
+{
+}
+
+void pageable_dirty_object(pgobj_t *object, unsigned long start, unsigned long end)
+{
+}
+
+struct page *pageable_get_page(pgobj_t *object, unsigned long off)
+{
+	void *ptr = object;
+	return virt_to_page(ptr + off);
+}
+
+void pageable_dirty_page(pgobj_t *object, struct page *page)
+{
+}
+
+void *pageable_vmap_object(pgobj_t *object, unsigned long start, unsigned long end)
+{
+	void *ptr = object;
+	return ptr + start;
+}
+
+void pageable_vunmap_object(pgobj_t *object, void *ptr, unsigned long start, unsigned long end)
+{
+}
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
