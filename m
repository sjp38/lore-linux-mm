Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4OCBwUI001620
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:11:58 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4OCBws7534156
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:11:58 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4OCBw5N024771
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:11:58 -0400
Date: Thu, 24 May 2007 08:11:57 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20070524121157.13533.32213.sendpatchset@kleikamp.austin.ibm.com>
In-Reply-To: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
References: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
Subject: [RFC:PATCH 005/012] Base file tail function
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Base file tail function

This is the code to allocate, free, and unpack the tail into a normal page.

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 include/linux/file_tail.h |   67 ++++++++++
 mm/Makefile               |    1 
 mm/file_tail.c            |  293 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 361 insertions(+)

diff -Nurp linux004/include/linux/file_tail.h linux005/include/linux/file_tail.h
--- linux004/include/linux/file_tail.h	1969-12-31 18:00:00.000000000 -0600
+++ linux005/include/linux/file_tail.h	2007-05-23 22:53:11.000000000 -0500
@@ -0,0 +1,67 @@
+#ifndef FILE_TAIL_H
+#define FILE_TAIL_H
+
+#include <linux/fs.h>
+#include <linux/pagemap.h>
+
+/*
+ * VM File Tails are used to compactly store the data at the end of the
+ * file in a small SLAB-allocated buffer when the base page size is large.
+ */
+
+#ifdef CONFIG_VM_FILE_TAILS
+
+extern struct page *page_cache_alloc_tail(struct address_space *);
+extern void page_cache_free_tail(struct page *);
+extern void __page_cache_free_tail_buffer(struct page *);
+
+static inline void page_cache_free_tail_buffer(struct page *page)
+{
+	if (PageFileTail(page))
+		__page_cache_free_tail_buffer(page);
+}
+
+/*
+ * Caller must hold write_lock_irq(&mapping->tree_lock)
+ */
+extern int __unpack_file_tail(struct address_space *);
+
+static inline int unpack_file_tail(struct address_space *mapping)
+{
+	int rc;
+	write_lock_irq(&mapping->tree_lock);
+	rc = __unpack_file_tail(mapping);
+	write_unlock_irq(&mapping->tree_lock);
+	return rc;
+}
+
+static inline void preallocate_page_cache_tail(struct address_space *mapping,
+					       unsigned long end_index)
+{
+	struct inode *inode = mapping->host;
+	struct page *page;
+
+	if (mapping->tail)
+		return;
+	if (!IS_FILE_TAIL_CAPABLE(inode))
+		return;
+	if (file_tail_index(mapping) != end_index)
+		return;
+	if (file_tail_buf_size(mapping) > PAGE_CACHE_SIZE / 2)
+		return;
+
+	page = page_cache_alloc_tail(mapping);
+	if (page)
+		page_cache_release(page);
+}
+
+#else /* !CONFIG_VM_FILE_TAILS */
+
+#define unpack_file_tail(mapping) 0
+#define page_cache_free_tail(page) do {} while (0)
+#define page_cache_free_tail_buffer(page) do {} while (0)
+#define preallocate_page_cache_tail(page, end_index) do {} while (0)
+
+#endif /* CONFIG_VM_FILE_TAILS */
+
+#endif	/* FILE_TAIL_H */
diff -Nurp linux004/mm/Makefile linux005/mm/Makefile
--- linux004/mm/Makefile	2007-05-21 15:15:48.000000000 -0500
+++ linux005/mm/Makefile	2007-05-23 22:53:11.000000000 -0500
@@ -31,4 +31,5 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
+obj-$(CONFIG_VM_FILE_TAILS) += file_tail.o
 
diff -Nurp linux004/mm/file_tail.c linux005/mm/file_tail.c
--- linux004/mm/file_tail.c	1969-12-31 18:00:00.000000000 -0600
+++ linux005/mm/file_tail.c	2007-05-23 22:53:11.000000000 -0500
@@ -0,0 +1,293 @@
+/*
+ *	linux/mm/file_tail.c
+ *
+ * Copyright (C) International Business Machines  Corp., 2006-2007
+ * Author: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
+ */
+
+/*
+ * VM File Tails are used to compactly store the data at the end of the
+ * file in a small SLAB-allocated buffer when the base page size is large.
+ */
+
+#include <linux/file_tail.h>
+#include <linux/fs.h>
+#include <linux/module.h>
+#include <linux/pagemap.h>
+#include <linux/slab.h>
+#include <linux/buffer_head.h>
+#include <linux/swap.h>
+#include <linux/mm_inline.h>
+#include "internal.h"
+
+static struct kmem_cache *tail_page_cachep;
+
+/*
+ * Maybe this could become more generic, but for now, I need it here
+ */
+static void lru_cache_delete(struct page *page)
+{
+	if (PageLRU(page)) {
+		unsigned long flags;
+		struct zone *zone = page_zone(page);
+
+		spin_lock_irqsave(&zone->lru_lock, flags);
+		BUG_ON(!PageLRU(page));
+		__ClearPageLRU(page);
+		del_page_from_lru(zone, page);
+		spin_unlock_irqrestore(&zone->lru_lock, flags);
+	}
+}
+
+/*
+ * Unpack short_page into full_page.
+ * short_page is locked and has no buffers bound to it.
+ * full_page is newly allocated.
+ */
+static int unpack_tail(struct address_space *mapping, pgoff_t index,
+		       struct page *short_page, struct page *full_page)
+{
+	int error;
+	char *kaddr;
+	char *tail;
+	char *tail_buf;
+	int tail_length;
+
+	/* This is the equivalent of remove_from_page_cache and
+	 * add_to_page_cache_lru, without dropping tree_lock
+	 */
+	error = radix_tree_preload(mapping_gfp_mask(mapping));
+	if (unlikely(error))
+		return error;
+
+	write_lock_irq(&mapping->tree_lock);
+	radix_tree_delete(&mapping->page_tree, index);
+	short_page->mapping = NULL;
+	tail = mapping->tail;
+	tail_buf = mapping->tail_buf;
+	mapping->tail = mapping->tail_buf = NULL;
+
+	error = radix_tree_insert(&mapping->page_tree, index, full_page);
+	if (unlikely(error)) {
+		printk(KERN_ERR "unpack_tail: radix_tree_insert failed!\n");
+		kfree(tail_buf);
+		unlock_page(short_page);
+		page_cache_release(short_page);
+		return error;
+	}
+	page_cache_get(full_page);
+	SetPageLocked(full_page);
+	full_page->mapping = mapping;
+	full_page->index = index;
+
+	write_unlock_irq(&mapping->tree_lock);
+	radix_tree_preload_end();
+	page_cache_release(short_page); /* page cache ref */
+
+	/* Copy data from tail to full page */
+	if (PageUptodate(short_page)) {
+		kaddr = kmap_atomic(full_page, KM_USER0);
+		tail_length = file_tail_buf_size(mapping);
+		memcpy(kaddr, tail, tail_length);
+		memset(kaddr+tail_length, 0, PAGE_CACHE_SIZE - tail_length);
+		kunmap_atomic(kaddr, KM_USER0);
+		SetPageUptodate(full_page);
+	}
+	kfree(tail_buf);
+
+	/* finalize full_page */
+	if (PageUptodate(short_page) && PageDirty(short_page)) {
+		SetPageDirty(full_page);
+		write_lock_irq(&mapping->tree_lock);
+		radix_tree_tag_set(&mapping->page_tree, index,
+				   PAGECACHE_TAG_DIRTY);
+		write_unlock_irq(&mapping->tree_lock);
+	}
+	lru_cache_add(full_page);
+	unlock_page(full_page);
+	page_cache_release(full_page);
+
+	/* release short_page */
+	unlock_page(short_page);
+	page_cache_release(short_page);
+
+	return 0;
+}
+
+/*
+ * Caller must hold write lock on mapping->tree_lock
+ */
+int __unpack_file_tail(struct address_space *mapping)
+{
+	pgoff_t index;
+	struct page *full_page = NULL;
+	int rc = 0;
+	struct page *short_page;
+
+	while (mapping->tail) {
+		write_unlock_irq(&mapping->tree_lock);
+		index = file_tail_index(mapping);
+
+		/* Allocate full page */
+		if (!full_page)
+			full_page = page_cache_alloc(mapping);
+		if (!full_page) {
+			rc = -ENOMEM;
+			write_lock_irq(&mapping->tree_lock);
+			break;
+		}
+
+		/* Get & lock short page */
+		short_page = find_lock_page(mapping, index);
+		if (!short_page || !PageFileTail(short_page)) {
+			if (short_page) {
+				unlock_page(short_page);
+				page_cache_release(short_page);
+			}
+			write_lock_irq(&mapping->tree_lock);
+			continue;
+		}
+		wait_on_page_writeback(short_page);
+		lru_cache_delete(short_page);
+		/* We have the tail page locked, so this shouldn't go away */
+		BUG_ON(!mapping->tail);
+
+		if (page_has_buffers(short_page) &&
+		    !try_to_release_page(short_page,
+					 mapping_gfp_mask(mapping))) {
+			/* How hard to do we need to try? */
+			sync_blockdev(mapping->host->i_sb->s_bdev);
+			if (page_has_buffers(short_page) &&
+			    !try_to_release_page(short_page,
+						 mapping_gfp_mask(mapping))) {
+				printk(KERN_ERR "__unpack_file_tail: "
+						"can't release page\n");
+				page_cache_release(short_page);
+				rc = -EIO; /* What's a good return code? */
+				write_lock_irq(&mapping->tree_lock);
+				break;
+			}
+		}
+
+		rc = unpack_tail(mapping, index, short_page, full_page);
+		if (rc) {
+			write_lock_irq(&mapping->tree_lock);
+			break;
+		}
+		full_page = NULL;
+
+		/*
+		 * unlikely, but check to see if there was no tail added
+		 * back.  We need to return with tree_lock held.
+		 */
+		write_lock_irq(&mapping->tree_lock);
+
+	}
+	if (full_page)
+		page_cache_release(full_page);
+	return rc;
+}
+
+static void init_once(void *ptr, struct kmem_cache *cachep, unsigned long flags)
+{
+	struct page *page = (struct page *)ptr;
+
+	memset(page, 0, sizeof(struct page));
+	reset_page_mapcount(page);
+	INIT_LIST_HEAD(&page->lru);
+	SetPageFileTail(page);
+}
+
+static __init int file_tail_init(void)
+{
+	tail_page_cachep = kmem_cache_create("tail_page_cache",
+					     sizeof(struct page), 0, 0,
+					     init_once, NULL);
+	if (tail_page_cachep == NULL) {
+		printk (KERN_ERR "Failed to create tail_page_cache\n");
+		return -ENOMEM;
+	}
+	return 0;
+}
+__initcall(file_tail_init);
+
+struct page *page_cache_alloc_tail(struct address_space *mapping)
+{
+	int block_size = 1 << mapping->host->i_blkbits;
+	int error;
+	pgoff_t index;
+	struct page *page;
+	int size;
+	void *tail;
+	void *tail_buf;
+
+	size = file_tail_buf_size(mapping);
+	index = file_tail_index(mapping);
+
+	page = find_get_page(mapping, index);
+	if (page)
+		return page;
+
+	page = kmem_cache_alloc(tail_page_cachep, GFP_KERNEL);
+	if (!page)
+		return NULL;
+
+	/*
+	 * For pages up to 1/8 of a page, kmalloc returns well-aligned
+	 * buffers.  For smaller allocations, we need to align it ourselves
+	 */
+	if (size < PAGE_SIZE >> 3) {
+		tail_buf = kmalloc(size + block_size - 1, GFP_KERNEL);
+		tail = (void *)ALIGN((size_t)tail_buf, block_size);
+	} else
+		tail_buf = tail = kmalloc(size, GFP_KERNEL);
+
+	if (!tail) {
+		kmem_cache_free(tail_page_cachep, page);
+		return NULL;
+	}
+	/* Just to make sure */
+	BUG_ON((size_t)tail & (block_size - 1));
+
+	set_page_count(page, 1);
+	page->flags = 0;
+	SetPageFileTail(page);
+
+	error = add_to_page_cache_lru(page, mapping, index,
+				      mapping_gfp_mask(mapping));
+	if (error) {
+		kfree(tail_buf);
+		kmem_cache_free(tail_page_cachep, page);
+		return NULL;
+	}
+	write_lock_irq(&mapping->tree_lock);
+	/*
+	 * Make sure the file size didn't change
+	 */
+	if (mapping->tail || (index != file_tail_index(mapping)) ||
+	    (size != file_tail_buf_size(mapping))) {
+		write_unlock_irq(&mapping->tree_lock);
+		__put_page(page);
+		page_cache_release(page);
+		kfree(tail_buf);
+		return NULL;
+	}
+	mapping->tail = tail;
+	mapping->tail_buf = tail_buf;
+	write_unlock_irq(&mapping->tree_lock);
+	unlock_page(page);
+
+	return page;
+}
+
+void page_cache_free_tail(struct page *page)
+{
+	kmem_cache_free(tail_page_cachep, page);
+}
+
+void __page_cache_free_tail_buffer(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+	kfree(mapping->tail_buf);
+	mapping->tail_buf = mapping->tail = NULL;
+}

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
