Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6I48OM0015784
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 18 Jul 2006 00:08:24 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6I48NER158308
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Mon, 17 Jul 2006 22:08:24 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6I48NJU010364
	for <linux-mm@kvack.org>; Mon, 17 Jul 2006 22:08:23 -0600
Date: Mon, 17 Jul 2006 22:08:21 -0600
From: Dave Kleikamp <shaggy@austin.ibm.com>
Message-Id: <20060718040820.11926.12387.sendpatchset@kleikamp.austin.ibm.com>
In-Reply-To: <20060718040804.11926.76333.sendpatchset@kleikamp.austin.ibm.com>
References: <20060718040804.11926.76333.sendpatchset@kleikamp.austin.ibm.com>
Subject: [RFC:PATCH 002/008] Base file tail function
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Dave Kleikamp <shaggy@austin.ibm.com>, Dave McCracken <dmccr@us.ibm.com>, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Base file tail function

Signed-off-by: Dave Kleikamp <shaggy@austin.ibm.com>
---
diff -Nurp linux001/include/linux/file_tail.h linux002/include/linux/file_tail.h
--- linux001/include/linux/file_tail.h	1969-12-31 18:00:00.000000000 -0600
+++ linux002/include/linux/file_tail.h	2006-07-17 23:04:37.000000000 -0500
@@ -0,0 +1,48 @@
+#ifndef FILE_TAIL_H
+#define FILE_TAIL_H
+
+#include <linux/fs.h>
+#include <linux/pagemap.h>
+
+/*
+ * This file deals with storing tails of files in buffers smaller than a page
+ */
+
+#ifdef CONFIG_FILE_TAILS
+
+#define FILE_TAIL_INDEX(mapping) \
+	(i_size_read((mapping)->host) >> PAGE_CACHE_SHIFT)
+#define FILE_TAIL_LENGTH(mapping) \
+	(i_size_read((mapping)->host) & (PAGE_CACHE_SIZE - 1))
+
+static inline int page_data_size(struct page *page)
+{
+	if (PageTail(page))
+		return FILE_TAIL_LENGTH(page->mapping);
+	else
+		return PAGE_CACHE_SIZE;
+}
+
+extern struct page *page_cache_alloc_tail(struct address_space *);
+void page_cache_free_tail(struct page *);
+void pack_file_tail(struct page *);
+/*
+ * Called holding write_lock_irq(&mapping->tree_lock)
+ */
+extern void __unpack_file_tail(struct address_space *);
+
+static inline void unpack_file_tail(struct address_space *mapping)
+{
+	write_lock_irq(&mapping->tree_lock);
+	__unpack_file_tail(mapping);
+	write_unlock_irq(&mapping->tree_lock);
+}
+
+#else /* !CONFIG_FILE_TAILS */
+
+#define page_data_size(page) PAGE_CACHE_SIZE
+#define unpack_file_tail(mapping) do {} while (0)
+
+#endif /* CONFIG_FILE_TAILS */
+
+#endif	/* FILE_TAIL_H */
diff -Nurp linux001/mm/Makefile linux002/mm/Makefile
--- linux001/mm/Makefile	2006-06-17 20:49:35.000000000 -0500
+++ linux002/mm/Makefile	2006-07-17 23:04:37.000000000 -0500
@@ -23,4 +23,5 @@ obj-$(CONFIG_SLAB) += slab.o
 obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
 obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
+obj-$(CONFIG_FILE_TAILS) += file_tail.o
 
diff -Nurp linux001/mm/file_tail.c linux002/mm/file_tail.c
--- linux001/mm/file_tail.c	1969-12-31 18:00:00.000000000 -0600
+++ linux002/mm/file_tail.c	2006-07-17 23:04:37.000000000 -0500
@@ -0,0 +1,305 @@
+/*
+ *	linux/mm/file_tail.c
+ *
+ * Copyright (C) International Business Machines  Corp., 2006
+ */
+
+/*
+ * This file deals with storing tails of files in buffers smaller than a page
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
+ * Caller must hold write lock on mapping->tree_lock
+ */
+void __unpack_file_tail(struct address_space *mapping)
+{
+	int error;
+	unsigned long index;
+	char *kaddr;
+	struct page *full_page = NULL, *short_page;
+	char *tail;
+	int tail_length;
+
+	while(mapping->tail) {
+		index = FILE_TAIL_INDEX(mapping);
+		write_unlock_irq(&mapping->tree_lock);
+
+		/* Allocate full page */
+		if (!full_page)
+			full_page = page_cache_alloc(mapping);
+		BUG_ON(!full_page);	
+
+		/* Get & lock short page */
+		short_page = find_lock_page(mapping, index);
+		if (!short_page || !PageTail(short_page)) {
+			if (short_page) {
+				unlock_page(short_page);
+				page_cache_release(short_page);
+			}
+			/* anything can happen since we released the lock */
+			write_lock_irq(&mapping->tree_lock);
+			continue;
+		}
+		/* We have the tail page locked, so this shouldn't go away */
+		BUG_ON(!mapping->tail);
+
+		BUG_ON(page_has_buffers(short_page) || PageDirty(short_page));
+
+		/* This is the equivalent of remove_from_page_cache and
+		 * add_to_page_cache_lru, without dropping tree_lock
+		 */
+		error = radix_tree_preload(mapping_gfp_mask(mapping));
+		BUG_ON(error);
+		write_lock_irq(&mapping->tree_lock);
+		lru_cache_delete(short_page);
+		radix_tree_delete(&mapping->page_tree, index);
+		short_page->mapping = NULL;
+		tail = mapping->tail;
+		mapping->tail = NULL;
+
+		error = radix_tree_insert(&mapping->page_tree, index,
+					  full_page);
+		BUG_ON(error);
+		page_cache_get(full_page);
+		SetPageLocked(full_page);
+		full_page->mapping = mapping;
+		full_page->index = index;
+
+		write_unlock_irq(&mapping->tree_lock);
+		radix_tree_preload_end();
+		page_cache_release(short_page); /* page cache ref */
+
+		/*
+		 * Now that the short page has been replaced by the full
+		 * page in the radix tree, we need to wait until all of
+		 * the references on the short page are gone.
+		 */
+		unlock_page(short_page);
+
+		/*
+		 * This still needs work.  We occasionally get caught in 
+		 * this loop.
+		 */
+		while (page_count(short_page) > 1)
+			schedule();
+		/*
+		 * ToDo: Figure out where this is getting added back to
+		 * lru
+		 */
+		lru_cache_delete(short_page);
+
+		/* Copy data from tail to full page */
+		if (PageUptodate(short_page)) {
+			kaddr = kmap_atomic(full_page, KM_USER0);
+			tail_length = FILE_TAIL_LENGTH(mapping);
+			memcpy(kaddr, tail, tail_length);
+			memset(kaddr+tail_length, 0,
+			       PAGE_CACHE_SIZE - tail_length);
+			kunmap_atomic(kaddr, KM_USER0);
+			SetPageUptodate(full_page);
+		}
+		kfree(tail);
+
+		/* finalize full_page */
+		lru_cache_add(full_page);
+		unlock_page(full_page);
+		page_cache_release(full_page);
+		full_page = NULL;
+
+		/* free short_page */
+		WARN_ON(PageLRU(short_page));
+		kmem_cache_free(tail_page_cachep, short_page);
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
+	return;
+}
+EXPORT_SYMBOL(__unpack_file_tail);
+
+void i_size_write(struct inode *inode, loff_t i_size)
+{
+	struct address_space *mapping = inode->i_mapping;
+
+	write_lock_irq(&mapping->tree_lock);
+	if (mapping->tail && (i_size > i_size_read(inode)))
+		__unpack_file_tail(mapping);
+	_i_size_write(inode, i_size);
+	write_unlock_irq(&mapping->tree_lock);
+}
+EXPORT_SYMBOL(i_size_write);
+
+static void init_once(void *ptr, kmem_cache_t *cachep, unsigned long flags)
+{
+	struct page *page = (struct page *)ptr;
+
+	if ((flags & (SLAB_CTOR_VERIFY | SLAB_CTOR_CONSTRUCTOR)) ==
+	    SLAB_CTOR_CONSTRUCTOR) {
+		memset(page, 0, sizeof(struct page));
+		reset_page_mapcount(page);
+		INIT_LIST_HEAD(&page->lru);
+		SetPageTail(page);
+	}
+}
+
+static __init int file_tail_init(void)
+{
+	tail_page_cachep = kmem_cache_create("tail_page_cache",
+					     sizeof(struct page), 0, 0,
+					     init_once, NULL);
+	if (tail_page_cachep == NULL)
+		return -ENOMEM;
+	return 0;
+}
+__initcall(file_tail_init);
+
+/*
+ * If the page is clean, in use by no one else, and the data is sufficiently
+ * small, allocate a tail page, copy it's data, and replace the page with
+ * the tail page in the page cache.
+ *
+ * Caller must hold reference on the page.
+ */
+void pack_file_tail(struct page *full_page)
+{
+	int error;
+	pgoff_t index;
+	void *kaddr;
+	struct address_space *mapping = full_page->mapping;
+	struct page *short_page;
+	int size;
+	void *tail;
+
+	if (!mapping)
+		return;
+
+	if (TestSetPageLocked(full_page))
+		return;
+
+	size = FILE_TAIL_LENGTH(mapping);
+	index = FILE_TAIL_INDEX(mapping);
+
+	if ((size > PAGE_CACHE_SIZE / 2) || PageDirty(full_page) ||
+	    !PageUptodate(full_page) || mapping_mapped(mapping) ||
+	    (page_count(full_page) > 2) || page_has_buffers(full_page) ||
+	    PageWriteback(full_page)) {
+		unlock_page(full_page);
+		return;
+	}
+
+	short_page = kmem_cache_alloc(tail_page_cachep, SLAB_KERNEL);
+	if (!short_page) {
+		unlock_page(full_page);
+		return;
+	}
+
+	tail = kmalloc(size, SLAB_KERNEL);
+
+	if (!tail) {
+		kmem_cache_free(tail_page_cachep, short_page);
+		unlock_page(full_page);
+		return;
+	}
+	set_page_count(short_page, 1);
+	short_page->flags = 0;
+	SetPageTail(short_page);
+
+	/* Copy the data into the tail */
+	kaddr = kmap_atomic(full_page, KM_USER0);
+	memcpy(tail, kaddr, size);
+	kunmap_atomic(kaddr,KM_USER0);
+	SetPageUptodate(short_page);
+
+	error = radix_tree_preload(mapping_gfp_mask(mapping));
+	if (error) {
+		kfree(tail);
+		kmem_cache_free(tail_page_cachep, short_page);
+		unlock_page(full_page);
+		return;
+	}
+	/*
+	 * Take tree lock.  Recheck that nobody else is using full_page,
+	 * remove it from the page cache and add short page, all while holding
+	 * the lock
+	 */
+	write_lock_irq(&mapping->tree_lock);
+	/*
+	 * Make sure the file size didn't change
+	 */
+	if (mapping->tail || (full_page->index != FILE_TAIL_INDEX(mapping)) ||
+	    (size != FILE_TAIL_LENGTH(mapping)) || mapping_mapped(mapping) ||
+	    page_count(full_page) > 2) {
+		write_unlock_irq(&mapping->tree_lock);
+		radix_tree_preload_end();
+		kfree(tail);
+		kmem_cache_free(tail_page_cachep, short_page);
+		unlock_page(full_page);
+		return;
+	}
+	/* out with the old */
+	lru_cache_delete(full_page);
+	radix_tree_delete(&mapping->page_tree, index);
+	full_page->mapping = NULL;
+
+	/* in with the new */
+	mapping->tail = tail;
+	error = radix_tree_insert(&mapping->page_tree, index, short_page);
+	BUG_ON(error);
+	page_cache_get(short_page);
+	SetPageLocked(short_page);
+	short_page->mapping = mapping;
+	short_page->index = index;
+
+	write_unlock_irq(&mapping->tree_lock);
+	radix_tree_preload_end();
+
+	unlock_page(full_page);
+	page_cache_release(full_page); /* page cache reference */
+
+	/* We're done with this now */
+	lru_cache_add(short_page);
+	unlock_page(short_page);
+	page_cache_release(short_page);
+
+	return;
+}
+
+void page_cache_free_tail(struct page *page)
+{
+	kmem_cache_free(tail_page_cachep, page);
+}

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
