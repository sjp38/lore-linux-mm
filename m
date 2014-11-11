Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 169F6900014
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 09:59:34 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so10840999pab.0
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 06:59:33 -0800 (PST)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id ef7si20290509pac.71.2014.11.11.06.59.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 06:59:32 -0800 (PST)
Received: by mail-pd0-f170.google.com with SMTP id z10so10268237pdj.1
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 06:59:32 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Subject: [RFC v1 1/6] gcma: introduce contiguous memory allocator
Date: Wed, 12 Nov 2014 00:00:05 +0900
Message-Id: <1415718010-18663-2-git-send-email-sj38.park@gmail.com>
In-Reply-To: <1415718010-18663-1-git-send-email-sj38.park@gmail.com>
References: <1415718010-18663-1-git-send-email-sj38.park@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: lauraa@codeaurora.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org, SeongJae Park <sj38.park@gmail.com>

This patch introduces a simple contiguous memory allocator.
It's simple bitmap allocator to manage a contiguos memory.

Signed-off-by: SeongJae Park <sj38.park@gmail.com>
---
 include/linux/gcma.h |  26 ++++++++
 mm/gcma.c            | 173 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 199 insertions(+)
 create mode 100644 include/linux/gcma.h
 create mode 100644 mm/gcma.c

diff --git a/include/linux/gcma.h b/include/linux/gcma.h
new file mode 100644
index 0000000..3016968
--- /dev/null
+++ b/include/linux/gcma.h
@@ -0,0 +1,26 @@
+/*
+ * gcma.h - Guaranteed Contiguous Memory Allocator
+ *
+ * GCMA aims for contiguous memory allocation with success and fast
+ * latency guarantee.
+ * It reserves large amount of memory and let it be allocated to the
+ * contiguous memory request.
+ *
+ * Copyright (C) 2014  LG Electronics Inc.,
+ * Copyright (C) 2014  Minchan Kim <minchan@kernel.org>
+ * Copyright (C) 2014  SeongJae Park <sj38.park@gmail.com>
+ */
+
+#ifndef _LINUX_GCMA_H
+#define _LINUX_GCMA_H
+
+struct gcma;
+
+int gcma_init(unsigned long start_pfn, unsigned long size,
+	      struct gcma **res_gcma);
+int gcma_alloc_contig(struct gcma *gcma,
+		      unsigned long start_pfn, unsigned long size);
+void gcma_free_contig(struct gcma *gcma,
+		      unsigned long start_pfn, unsigned long size);
+
+#endif /* _LINUX_GCMA_H */
diff --git a/mm/gcma.c b/mm/gcma.c
new file mode 100644
index 0000000..20a8473
--- /dev/null
+++ b/mm/gcma.c
@@ -0,0 +1,173 @@
+/*
+ * gcma.c - Guaranteed Contiguous Memory Allocator
+ *
+ * GCMA aims for contiguous memory allocation with success and fast
+ * latency guarantee.
+ * It reserves large amount of memory and let it be allocated to the
+ * contiguous memory request.
+ *
+ * Copyright (C) 2014  LG Electronics Inc.,
+ * Copyright (C) 2014  Minchan Kim <minchan@kernel.org>
+ * Copyright (C) 2014  SeongJae Park <sj38.park@gmail.com>
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/highmem.h>
+#include <linux/gcma.h>
+
+struct gcma {
+	spinlock_t lock;
+	unsigned long *bitmap;
+	unsigned long base_pfn, size;
+	struct list_head list;
+};
+
+struct gcma_info {
+	spinlock_t lock;	/* protect list */
+	struct list_head head;
+};
+
+static struct gcma_info ginfo = {
+	.head = LIST_HEAD_INIT(ginfo.head),
+	.lock = __SPIN_LOCK_UNLOCKED(ginfo.lock),
+};
+
+/*
+ * gcma_init - initializes a contiguous memory area
+ *
+ * @start_pfn	start pfn of contiguous memory area
+ * @size	number of pages in the contiguous memory area
+ * @res_gcma	pointer to store the created gcma region
+ *
+ * Returns 0 on success, error code on failure.
+ */
+int gcma_init(unsigned long start_pfn, unsigned long size,
+		struct gcma **res_gcma)
+{
+	int bitmap_size = BITS_TO_LONGS(size) * sizeof(long);
+	struct gcma *gcma;
+
+	gcma = kmalloc(sizeof(*gcma), GFP_KERNEL);
+	if (!gcma)
+		goto out;
+
+	gcma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
+	if (!gcma->bitmap)
+		goto free_cma;
+
+	gcma->size = size;
+	gcma->base_pfn = start_pfn;
+	spin_lock_init(&gcma->lock);
+
+	spin_lock(&ginfo.lock);
+	list_add(&gcma->list, &ginfo.head);
+	spin_unlock(&ginfo.lock);
+
+	*res_gcma = gcma;
+	pr_info("initialized gcma area [%lu, %lu]\n",
+			start_pfn, start_pfn + size);
+	return 0;
+
+free_cma:
+	kfree(gcma);
+out:
+	return -ENOMEM;
+}
+
+static struct page *gcma_alloc_page(struct gcma *gcma)
+{
+	unsigned long bit;
+	unsigned long *bitmap = gcma->bitmap;
+	struct page *page = NULL;
+
+	spin_lock(&gcma->lock);
+	bit = bitmap_find_next_zero_area(bitmap, gcma->size, 0, 1, 0);
+	if (bit >= gcma->size) {
+		spin_unlock(&gcma->lock);
+		goto out;
+	}
+
+	bitmap_set(bitmap, bit, 1);
+	page = pfn_to_page(gcma->base_pfn + bit);
+	spin_unlock(&gcma->lock);
+
+out:
+	return page;
+}
+
+static void gcma_free_page(struct gcma *gcma, struct page *page)
+{
+	unsigned long pfn, offset;
+
+	pfn = page_to_pfn(page);
+
+	spin_lock(&gcma->lock);
+	offset = pfn - gcma->base_pfn;
+
+	bitmap_clear(gcma->bitmap, offset, 1);
+	spin_unlock(&gcma->lock);
+}
+
+/*
+ * gcma_alloc_contig - allocates contiguous pages
+ *
+ * @start_pfn	start pfn of requiring contiguous memory area
+ * @size	size of the requiring contiguous memory area
+ *
+ * Returns 0 on success, error code on failure.
+ */
+int gcma_alloc_contig(struct gcma *gcma, unsigned long start_pfn,
+			unsigned long size)
+{
+	unsigned long offset;
+
+	spin_lock(&gcma->lock);
+	offset = start_pfn - gcma->base_pfn;
+
+	if (bitmap_find_next_zero_area(gcma->bitmap, gcma->size, offset,
+				size, 0) != 0) {
+		spin_unlock(&gcma->lock);
+		pr_warn("already allocated region required: %lu, %lu",
+				start_pfn, size);
+		return -EINVAL;
+	}
+
+	bitmap_set(gcma->bitmap, offset, size);
+	spin_unlock(&gcma->lock);
+
+	return 0;
+}
+
+/*
+ * gcma_free_contig - free allocated contiguous pages
+ *
+ * @start_pfn	start pfn of freeing contiguous memory area
+ * @size	number of pages in freeing contiguous memory area
+ */
+void gcma_free_contig(struct gcma *gcma,
+		      unsigned long start_pfn, unsigned long size)
+{
+	unsigned long offset;
+
+	spin_lock(&gcma->lock);
+	offset = start_pfn - gcma->base_pfn;
+	bitmap_clear(gcma->bitmap, offset, size);
+	spin_unlock(&gcma->lock);
+}
+
+static int __init init_gcma(void)
+{
+	pr_info("loading gcma\n");
+
+	return 0;
+}
+
+module_init(init_gcma);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Minchan Kim <minchan@kernel.org>");
+MODULE_AUTHOR("SeongJae Park <sj38.park@gmail.com>");
+MODULE_DESCRIPTION("Guaranteed Contiguous Memory Allocator");
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
