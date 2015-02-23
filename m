Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0FB6B0072
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 14:52:19 -0500 (EST)
Received: by pabkq14 with SMTP id kq14so30034122pab.3
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 11:52:19 -0800 (PST)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com. [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id o7si11694480pdr.52.2015.02.23.11.52.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Feb 2015 11:52:18 -0800 (PST)
Received: by pdjy10 with SMTP id y10so27761763pdj.6
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 11:52:18 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Subject: [RFC v2 5/5] gcma: integrate gcma under cma interface
Date: Tue, 24 Feb 2015 04:54:23 +0900
Message-Id: <1424721263-25314-6-git-send-email-sj38.park@gmail.com>
In-Reply-To: <1424721263-25314-1-git-send-email-sj38.park@gmail.com>
References: <1424721263-25314-1-git-send-email-sj38.park@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: lauraa@codeaurora.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, SeongJae Park <sj38.park@gmail.com>

This commit let cma clients to be able to use gcma easily using familiar
cma interface by integrating gcma under cma interface.

With this commit, clients can decalre a contiguous memory area to be
managed in gcma way instead of cma way internally by using
gcma_declare_contiguous() function call. After declaration, clients can
use the area using familiar cma interface while it works in gcma way.

For example, you can use following code snippet to make two contiguous
regions: one region will work as cma and the other will work as gcma.

```
struct cma *cma, *gcma;

cma_declare_contiguous(base, size, limit, 0, 0, fixed, &cma);
gcma_declare_contiguous(gcma_base, size, gcma_limit, 0, 0, fixed,
&gcma);

cma_alloc(cma, 1024, 0);	/* alloc in cma way */
cma_alloc(gcma, 1024, 0);	/* alloc in gcma way */
```

Signed-off-by: SeongJae Park <sj38.park@gmail.com>
---
 include/linux/cma.h  |   4 ++
 include/linux/gcma.h |  21 ++++++++++
 mm/Kconfig           |  24 +++++++++++
 mm/Makefile          |   1 +
 mm/cma.c             | 113 ++++++++++++++++++++++++++++++++++++++++++---------
 5 files changed, 144 insertions(+), 19 deletions(-)

diff --git a/include/linux/cma.h b/include/linux/cma.h
index a93438b..6173cff 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -22,6 +22,10 @@ extern int __init cma_declare_contiguous(phys_addr_t base,
 			phys_addr_t size, phys_addr_t limit,
 			phys_addr_t alignment, unsigned int order_per_bit,
 			bool fixed, struct cma **res_cma);
+extern int __init gcma_declare_contiguous(phys_addr_t base,
+			phys_addr_t size, phys_addr_t limit,
+			phys_addr_t alignment, unsigned int order_per_bit,
+			bool fixed, struct cma **res_cma);
 extern int cma_init_reserved_mem(phys_addr_t base,
 					phys_addr_t size, int order_per_bit,
 					struct cma **res_cma);
diff --git a/include/linux/gcma.h b/include/linux/gcma.h
index 12e4431..c8f8c32 100644
--- a/include/linux/gcma.h
+++ b/include/linux/gcma.h
@@ -33,6 +33,25 @@
 
 struct gcma;
 
+#ifndef CONFIG_GCMA
+
+inline int gcma_init(unsigned long start_pfn, unsigned long size,
+		     struct gcma **res_gcma)
+{
+	return 0;
+}
+
+inline int gcma_alloc_contig(struct gcma *gcma,
+			     unsigned long start, unsigned long end)
+{
+	return 0;
+}
+
+void gcma_free_contig(struct gcma *gcma,
+		      unsigned long pfn, unsigned long nr_pages) { }
+
+#else
+
 int gcma_init(unsigned long start_pfn, unsigned long size,
 	      struct gcma **res_gcma);
 int gcma_alloc_contig(struct gcma *gcma,
@@ -40,4 +59,6 @@ int gcma_alloc_contig(struct gcma *gcma,
 void gcma_free_contig(struct gcma *gcma,
 		      unsigned long start_pfn, unsigned long size);
 
+#endif
+
 #endif /* _LINUX_GCMA_H */
diff --git a/mm/Kconfig b/mm/Kconfig
index 1d1ae6b..cceef9a 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -527,6 +527,30 @@ config CMA_AREAS
 
 	  If unsure, leave the default value "7".
 
+config GCMA
+	bool "Guaranteed Contiguous Memory Allocator (EXPERIMENTAL)"
+	default n
+	select FRONTSWAP
+	select CLEANCACHE
+	select CMA
+	help
+	  A contiguous memory allocator which guarantees success and
+	  predictable latency for allocation request.
+	  It carves out large amount of memory and let them be allocated
+	  to the contiguous memory request while it can be used as backend
+	  for frontswap.
+
+	  This is marked experimental because it is a new feature that
+	  interacts heavily with memory reclaim.
+
+config GCMA_DEFAULT
+	bool "Set GCMA as default CMA facility (EXPERIMENTA)"
+	default n
+	depends on GCMA
+	help
+	  Set older CMA interfaces to work as GCMA rather than CMA without any
+	  client code change.
+
 config MEM_SOFT_DIRTY
 	bool "Track memory changes"
 	depends on CHECKPOINT_RESTORE && HAVE_ARCH_SOFT_DIRTY && PROC_FS
diff --git a/mm/Makefile b/mm/Makefile
index 8405eb0..e79cb70 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -68,4 +68,5 @@ obj-$(CONFIG_ZBUD)	+= zbud.o
 obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
 obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
 obj-$(CONFIG_CMA)	+= cma.o
+obj-$(CONFIG_GCMA)	+= gcma.o
 obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
diff --git a/mm/cma.c b/mm/cma.c
index fde706e..0e1a32c 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -32,14 +32,18 @@
 #include <linux/slab.h>
 #include <linux/log2.h>
 #include <linux/cma.h>
+#include <linux/gcma.h>
 #include <linux/highmem.h>
 
+#define IS_GCMA ((struct gcma *)(void *)0xFF)
+
 struct cma {
 	unsigned long	base_pfn;
 	unsigned long	count;
 	unsigned long	*bitmap;
 	unsigned int order_per_bit; /* Order of pages represented by one bit */
 	struct mutex	lock;
+	struct gcma	*gcma;
 };
 
 static struct cma cma_areas[MAX_CMA_AREAS];
@@ -86,26 +90,25 @@ static void cma_clear_bitmap(struct cma *cma, unsigned long pfn, int count)
 	mutex_unlock(&cma->lock);
 }
 
-static int __init cma_activate_area(struct cma *cma)
+/*
+ * Return reserved pages for CMA to buddy allocator for using those pages
+ * as movable pages.
+ * Return 0 if it's called successfully. Otherwise, non-zero.
+ */
+static int free_reserved_pages(unsigned long pfn, unsigned long count)
 {
-	int bitmap_size = BITS_TO_LONGS(cma_bitmap_maxno(cma)) * sizeof(long);
-	unsigned long base_pfn = cma->base_pfn, pfn = base_pfn;
-	unsigned i = cma->count >> pageblock_order;
+	int ret = 0;
+	unsigned long base_pfn;
 	struct zone *zone;
 
-	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
-
-	if (!cma->bitmap)
-		return -ENOMEM;
-
-	WARN_ON_ONCE(!pfn_valid(pfn));
+	count = count >> pageblock_order;
 	zone = page_zone(pfn_to_page(pfn));
 
 	do {
-		unsigned j;
+		unsigned i;
 
 		base_pfn = pfn;
-		for (j = pageblock_nr_pages; j; --j, pfn++) {
+		for (i = pageblock_nr_pages; i; --i, pfn++) {
 			WARN_ON_ONCE(!pfn_valid(pfn));
 			/*
 			 * alloc_contig_range requires the pfn range
@@ -113,12 +116,38 @@ static int __init cma_activate_area(struct cma *cma)
 			 * simple by forcing the entire CMA resv range
 			 * to be in the same zone.
 			 */
-			if (page_zone(pfn_to_page(pfn)) != zone)
-				goto err;
+			if (page_zone(pfn_to_page(pfn)) != zone) {
+				ret = -EINVAL;
+				break;
+			}
 		}
 		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
-	} while (--i);
+	} while (--count);
+
+	return ret;
+}
+
+static int __init cma_activate_area(struct cma *cma)
+{
+	int bitmap_size = BITS_TO_LONGS(cma_bitmap_maxno(cma)) * sizeof(long);
+	unsigned long base_pfn = cma->base_pfn, pfn = base_pfn;
+	int fail;
+
+	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
+
+	if (!cma->bitmap)
+		return -ENOMEM;
+
+	WARN_ON_ONCE(!pfn_valid(pfn));
 
+	if (cma->gcma == IS_GCMA)
+		fail = gcma_init(cma->base_pfn, cma->count, &cma->gcma);
+	else
+		fail = free_reserved_pages(cma->base_pfn, cma->count);
+	if (fail != 0) {
+		kfree(cma->bitmap);
+		return -EINVAL;
+	}
 	mutex_init(&cma->lock);
 	return 0;
 
@@ -192,7 +221,7 @@ int __init cma_init_reserved_mem(phys_addr_t base, phys_addr_t size,
 }
 
 /**
- * cma_declare_contiguous() - reserve custom contiguous area
+ * __declare_contiguous() - reserve custom contiguous area
  * @base: Base address of the reserved area optional, use 0 for any
  * @size: Size of the reserved area (in bytes),
  * @limit: End address of the reserved memory (optional, 0 for any).
@@ -209,7 +238,7 @@ int __init cma_init_reserved_mem(phys_addr_t base, phys_addr_t size,
  * If @fixed is true, reserve contiguous area at exactly @base.  If false,
  * reserve in range from @base to @limit.
  */
-int __init cma_declare_contiguous(phys_addr_t base,
+int __init __declare_contiguous(phys_addr_t base,
 			phys_addr_t size, phys_addr_t limit,
 			phys_addr_t alignment, unsigned int order_per_bit,
 			bool fixed, struct cma **res_cma)
@@ -318,6 +347,43 @@ err:
 }
 
 /**
+ * gcma_declare_contiguous() - same as cma_declare_contiguous() except result
+ * cma's is_gcma field setting.
+ */
+int __init gcma_declare_contiguous(phys_addr_t base,
+			phys_addr_t size, phys_addr_t limit,
+			phys_addr_t alignment, unsigned int order_per_bit,
+			bool fixed, struct cma **res_cma)
+{
+	int ret = 0;
+
+	ret = __declare_contiguous(base, size, limit, alignment,
+			order_per_bit, fixed, res_cma);
+	if (ret >= 0)
+		(*res_cma)->gcma = IS_GCMA;
+
+	return ret;
+}
+
+int __init cma_declare_contiguous(phys_addr_t base,
+			phys_addr_t size, phys_addr_t limit,
+			phys_addr_t alignment, unsigned int order_per_bit,
+			bool fixed, struct cma **res_cma)
+{
+#ifdef CONFIG_GCMA_DEFAULT
+	return gcma_declare_contiguous(base, size, limit, alignment,
+			order_per_bit, fixed, res_cma);
+#else
+	int ret = 0;
+
+	ret = __declare_contiguous(base, size, limit, alignment,
+			order_per_bit, fixed, res_cma);
+
+	return ret;
+#endif
+}
+
+/**
  * cma_alloc() - allocate pages from contiguous area
  * @cma:   Contiguous memory region for which the allocation is performed.
  * @count: Requested number of pages.
@@ -364,7 +430,12 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
 
 		pfn = cma->base_pfn + (bitmap_no << cma->order_per_bit);
 		mutex_lock(&cma_mutex);
-		ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA);
+
+		if (cma->gcma)
+			ret = gcma_alloc_contig(cma->gcma, pfn, count);
+		else
+			ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA);
+
 		mutex_unlock(&cma_mutex);
 		if (ret == 0) {
 			page = pfn_to_page(pfn);
@@ -411,7 +482,11 @@ bool cma_release(struct cma *cma, struct page *pages, int count)
 
 	VM_BUG_ON(pfn + count > cma->base_pfn + cma->count);
 
-	free_contig_range(pfn, count);
+	if (cma->gcma)
+		gcma_free_contig(cma->gcma, pfn, count);
+	else
+		free_contig_range(pfn, count);
+
 	cma_clear_bitmap(cma, pfn, count);
 
 	return true;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
