Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA8JlQf7000858
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 14:47:26 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA8JlQOg452628
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 14:47:26 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA8JlQcG032412
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 14:47:26 -0500
Date: Thu, 8 Nov 2007 14:47:25 -0500
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20071108194724.17862.6594.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20071108194709.17862.16713.sendpatchset@norville.austin.ibm.com>
References: <20071108194709.17862.16713.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 02/09] Core function for packing, unpacking, and freeing file tails
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Core function for packing, unpacking, and freeing file tails

Cleanups by "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>

---

 include/linux/vm_file_tail.h |   66 ++++++++++++++++
 mm/Makefile                  |    1 
 mm/file_tail.c               |  169 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 236 insertions(+)

diff -Nurp linux001/include/linux/vm_file_tail.h linux002/include/linux/vm_file_tail.h
--- linux001/include/linux/vm_file_tail.h	1969-12-31 18:00:00.000000000 -0600
+++ linux002/include/linux/vm_file_tail.h	2007-11-08 10:49:46.000000000 -0600
@@ -0,0 +1,66 @@
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
+void __vm_file_tail_free(struct address_space *);
+
+static inline void vm_file_tail_free(struct address_space *mapping)
+{
+	if (mapping && mapping->tail)
+		__vm_file_tail_free(mapping);
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
+	if (mapping->tail && index == vm_file_tail_index(mapping))
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
--- linux001/mm/Makefile	2007-11-07 08:14:01.000000000 -0600
+++ linux002/mm/Makefile	2007-11-08 10:49:46.000000000 -0600
@@ -30,4 +30,5 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
+obj-$(CONFIG_VM_FILE_TAILS) += file_tail.o
 
diff -Nurp linux001/mm/file_tail.c linux002/mm/file_tail.c
--- linux001/mm/file_tail.c	1969-12-31 18:00:00.000000000 -0600
+++ linux002/mm/file_tail.c	2007-11-08 10:49:46.000000000 -0600
@@ -0,0 +1,169 @@
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
+ * Free the file tail
+ *
+ * Don't worry about a race.  It's essentially a no-op if mapping->tail
+ * is NULL.
+ */
+void __vm_file_tail_free(struct address_space *mapping)
+{
+	unsigned long flags;
+	void *tail;
+
+	spin_lock_irqsave(&mapping->tail_lock, flags);
+	tail = mapping->tail;
+	mapping->tail = NULL;
+	spin_unlock_irqrestore(&mapping->tail_lock, flags);
+	kfree(tail);
+}
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
+		__vm_file_tail_free(mapping);
+}
+
+static int page_not_eligible(struct page *page)
+{
+	if (!page->mapping || page->mapping->tail)
+		return 1;
+
+	if (PageDirty(page) || !PageUptodate(page) || PageWriteback(page))
+		return 1;
+
+	if ((page_count(page) > 2) || mapping_mapped(page->mapping) ||
+	    PageSwapCache(page))
+		return 1;
+
+	return 0;
+}
+
+/* * Determine if the page is eligible to be packed, and if so, pack it
+ *
+ * Non-fatal if this fails. The page will remain in the page cache.
+ *
+ * Returns 1 if the page was packed, 0 otherwise
+ */
+int vm_file_tail_pack(struct page *page)
+{
+	unsigned long flags;
+	pgoff_t index;
+	void *kaddr;
+	int length, ret = 0;
+	struct address_space *mapping;
+	void *tail;
+
+	if (TestSetPageLocked(page))
+		return 0;
+
+	if (page_not_eligible(page))
+		goto out;
+
+	mapping = page->mapping;
+	index = vm_file_tail_index(mapping);
+	length = vm_file_tail_length(mapping);
+
+	if ((index != page->index) ||
+	    (length > PAGE_CACHE_SIZE / 2))
+		goto out;
+
+	if (PagePrivate(page) && !try_to_release_page(page, 0))
+		goto out;
+
+	tail = kmalloc(length, GFP_NOWAIT);
+	if (!tail)
+		goto out;
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
+		kfree(tail);
+		goto out;
+	}
+
+	mapping->tail = tail;
+
+	spin_unlock_irqrestore(&mapping->tail_lock, flags);
+
+	remove_from_page_cache(page);
+	page_cache_release(page);	/* pagecache ref */
+	ret = 1;
+
+out:
+	unlock_page(page);
+	return ret;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
