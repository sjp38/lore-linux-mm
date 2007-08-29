Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7TKrbTR030107
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 16:53:37 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7TKrbIi619908
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 16:53:37 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7TKrbje011700
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 16:53:37 -0400
Date: Wed, 29 Aug 2007 16:53:36 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20070829205336.28328.58040.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20070829205325.28328.67953.sendpatchset@norville.austin.ibm.com>
References: <20070829205325.28328.67953.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 02/07] Core function for packing, unpacking, and freeing file tails
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Core function for packing, unpacking, and freeing file tails

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>

---

 include/linux/vm_file_tail.h |   71 ++++++++++++++++++++
 mm/Makefile                  |    1 
 mm/file_tail.c               |  148 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 220 insertions(+)

diff -Nurp linux001/include/linux/vm_file_tail.h linux002/include/linux/vm_file_tail.h
--- linux001/include/linux/vm_file_tail.h	1969-12-31 18:00:00.000000000 -0600
+++ linux002/include/linux/vm_file_tail.h	2007-08-29 13:27:46.000000000 -0500
@@ -0,0 +1,71 @@
+#ifndef FILE_TAIL_H
+#define FILE_TAIL_H
+
+#include <linux/fs.h>
+#include <linux/pagemap.h>
+
+/*
+ * This file deals with storing tails of files in buffers smaller than a page.
+ *
+ * FIXME: The contents of the file could possibly go into linux/pagemap.h.
+ */
+
+#ifdef CONFIG_VM_FILE_TAILS
+
+static inline int vm_file_tail_packed(struct address_space *mapping)
+{
+	return (mapping->tail != NULL);
+}
+
+static inline unsigned long vm_file_tail_index(struct address_space *mapping)
+{
+	return (unsigned long) (i_size_read(mapping->host) >> PAGE_CACHE_SHIFT);
+}
+
+static inline int vm_file_tail_length(struct address_space *mapping)
+{
+	return (int) (i_size_read(mapping->host) & (PAGE_CACHE_SIZE - 1));
+}
+
+static inline void vm_file_tail_free(struct address_space *mapping)
+{
+	unsigned long flags;
+	void *tail;
+	if (mapping && mapping->tail) {
+		spin_lock_irqsave(&mapping->tail_lock, flags);
+		tail = mapping->tail;
+		mapping->tail = NULL;
+		spin_unlock_irqrestore(&mapping->tail_lock, flags);
+		kfree(tail);
+	}
+}
+
+/*
+ * vm_file_tail_pack() returns 1 on success, 0 otherwise
+ *
+ * The caller must hold a reference on the page
+ */
+int vm_file_tail_pack(struct page *);
+void vm_file_tail_unpack(struct address_space *);
+
+/*
+ * Unpack the tail if it's at the specified index
+ */
+static inline void vm_file_tail_unpack_index(struct address_space *mapping,
+					     unsigned long index)
+{
+	if (index == vm_file_tail_index(mapping) && mapping->tail)
+		vm_file_tail_unpack(mapping);
+}
+
+#else /* !CONFIG_VM_FILE_TAILS */
+
+#define vm_file_tail_packed(mapping) 0
+#define vm_file_tail_free(mapping) do {} while (0)
+#define vm_file_tail_pack(page) 0
+#define vm_file_tail_unpack(mapping) do {} while (0)
+#define vm_file_tail_unpack_index(mapping, index) do {} while (0)
+
+#endif /* CONFIG_VM_FILE_TAILS */
+
+#endif	/* FILE_TAIL_H */
diff -Nurp linux001/mm/Makefile linux002/mm/Makefile
--- linux001/mm/Makefile	2007-08-28 09:57:20.000000000 -0500
+++ linux002/mm/Makefile	2007-08-29 13:27:46.000000000 -0500
@@ -29,4 +29,5 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
+obj-$(CONFIG_VM_FILE_TAILS) += file_tail.o
 
diff -Nurp linux001/mm/file_tail.c linux002/mm/file_tail.c
--- linux001/mm/file_tail.c	1969-12-31 18:00:00.000000000 -0600
+++ linux002/mm/file_tail.c	2007-08-29 13:27:46.000000000 -0500
@@ -0,0 +1,148 @@
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
+#include <linux/buffer_head.h>
+#include <linux/fs.h>
+#include <linux/hardirq.h>
+#include <linux/vm_file_tail.h>
+
+/*
+ * Unpack tail into page cache.
+ *
+ * The tail is never modfied, and can be safely discarded on error
+ */
+void vm_file_tail_unpack(struct address_space *mapping)
+{
+	unsigned int flags;
+	gfp_t gfp_mask;
+	pgoff_t index;
+	void *kaddr;
+	int length;
+	struct page *page;
+	void *tail;
+
+	if (!mapping->tail)
+		return;
+
+	/* Allocate page */
+
+	if (in_atomic())
+		gfp_mask = GFP_NOWAIT;
+	else
+		gfp_mask = mapping_gfp_mask(mapping);
+
+	page = __page_cache_alloc(gfp_mask);
+
+	/* Copy data from tail to new page */
+	if (page) {
+		spin_lock_irqsave(&mapping->tail_lock, flags);
+		index = vm_file_tail_index(mapping);
+		length = vm_file_tail_length(mapping);
+		tail = mapping->tail;
+		mapping->tail = NULL;
+		spin_unlock_irqrestore(&mapping->tail_lock, flags);
+
+		if (!tail) {	/* someone else freed the tail */
+			page_cache_release(page);
+			return;
+		}
+
+		kaddr = kmap_atomic(page, KM_USER0);
+		memcpy(kaddr, tail, length);
+		memset(kaddr + length, 0, PAGE_CACHE_SIZE - length);
+		kunmap_atomic(kaddr, KM_USER0);
+
+		kfree(tail);
+
+		add_to_page_cache_lru(page, mapping, index, gfp_mask);
+		unlock_page(page);
+		page_cache_release(page);
+	} else
+		/* Free the tail */
+		vm_file_tail_free(mapping);
+}
+
+/* * Determine if the page is eligible to be packed, and if so, pack it
+ *
+ * Non-fatal if this fails.  The page will remain in the page cache.
+ */
+int vm_file_tail_pack(struct page *page)
+{
+	unsigned long flags;
+	pgoff_t index;
+	void *kaddr;
+	int length;
+	struct address_space *mapping;
+	void *tail;
+
+	if (TestSetPageLocked(page))
+		return 0;
+
+	mapping = page->mapping;
+
+	if (!mapping ||
+	    mapping->tail ||
+	    PageDirty(page) ||
+	    !PageUptodate(page) ||
+	    PageWriteback(page) ||
+	    (page_count(page) > 2) ||
+	    mapping_mapped(mapping) ||
+	    PageSwapCache(page)) {
+		unlock_page(page);
+		return 0;
+	}
+
+	index = vm_file_tail_index(mapping);
+	length = vm_file_tail_length(mapping);
+
+	if ((index != page->index) ||
+	    (length > PAGE_CACHE_SIZE / 2)) {
+		unlock_page(page);
+		return 0;
+	}
+
+	if (PagePrivate(page) && !try_to_release_page(page, 0)) {
+		unlock_page(page);
+		return 0;
+	}
+
+	tail = kmalloc(length, GFP_NOWAIT);
+	if (!tail) {
+		unlock_page(page);
+		return 0;
+	}
+
+	kaddr = kmap_atomic(page, KM_USER0);
+	memcpy(tail, kaddr, length);
+	kunmap_atomic(kaddr, KM_USER0);
+
+	spin_lock_irqsave(&mapping->tail_lock, flags);
+
+	/* Check again under spinlock */
+	if (mapping->tail || (index != vm_file_tail_index(mapping)) ||
+	   (length != vm_file_tail_length(mapping))) {
+		/* File size must have changed */
+		spin_unlock_irqrestore(&mapping->tail_lock, flags);
+		unlock_page(page);
+		return 0;
+	}
+
+	mapping->tail = tail;
+
+	spin_unlock_irqrestore(&mapping->tail_lock, flags);
+
+	remove_from_page_cache(page);
+	page_cache_release(page);	/* pagecache ref */
+	unlock_page(page);
+
+	return 1;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
