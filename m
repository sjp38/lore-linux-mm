Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 555926B009A
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:58:36 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LC500JE631F4A20@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 19 Nov 2010 15:58:27 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LC50014331E14@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 19 Nov 2010 15:58:27 +0000 (GMT)
Date: Fri, 19 Nov 2010 16:58:10 +0100
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [RFCv6 12/13] mm: cma: Migration support added [wip]
In-reply-to: <cover.1290172312.git.m.nazarewicz@samsung.com>
Message-id: 
 <1e9146802598487745b442efb0b129a417972b3d.1290172312.git.m.nazarewicz@samsung.com>
References: <cover.1290172312.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: mina86@mina86.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Bryan Huntsman <bryanh@codeaurora.org>, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Johan Mossberg <johan.xx.mossberg@stericsson.com>, Jonathan Corbet <corbet@lwn.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Marcus LORENTZON <marcus.xm.lorentzon@stericsson.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>, Russell King <linux@arm.linux.org.uk>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, dipankar@in.ibm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This commits adds cma_early_grab_pageblocks() function as well
as makes cma_early_region_reserve() function use the former if
some conditions are met.

Grabbed pageblocks are later given back to page allocator with
migration type set to MIGRATE_CMA.  This guarantees that only
movable and reclaimable pages are allocated from those page
blocks.

* * * THIS COMMIT IS NOT YET FINISHED * * *

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 include/linux/cma.h |   38 +++++++-
 mm/Kconfig          |   15 +++
 mm/cma-best-fit.c   |   12 +++-
 mm/cma.c            |  239 +++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 299 insertions(+), 5 deletions(-)

diff --git a/include/linux/cma.h b/include/linux/cma.h
index 56ed021..6a56e2a 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -310,10 +310,6 @@ struct cma_region {
 	const char *alloc_name;
 	void *private_data;
 
-#ifdef CONFIG_CMA_USE_MIGRATE_CMA
-	unsigned short *isolation_map;
-#endif
-
 	unsigned users;
 	struct list_head list;
 
@@ -327,7 +323,9 @@ struct cma_region {
 	unsigned reserved:1;
 	unsigned copy_name:1;
 	unsigned free_alloc_name:1;
+#ifdef CONFIG_CMA_USE_MIGRATE_CMA
 	unsigned use_isolate:1;
+#endif
 };
 
 /**
@@ -449,6 +447,38 @@ struct cma_allocator {
  */
 int cma_allocator_register(struct cma_allocator *alloc);
 
+/**
+ * __cma_grab() - migrates all pages from range and reserves them for CMA
+ * @reg:	Region this call is made in context of.  If the region is
+ *		not marked needing grabbing the function does nothing.
+ * @start:	Address in bytes of the first byte to free.
+ * @size:	Size of the region to free.
+ *
+ * This function should be used when allocator wants to allocate some
+ * physical memory to make sure that it is not used for any movable or
+ * reclaimable pages (eg. page cache).
+ *
+ * In essence, this function migrates all movable and reclaimable
+ * pages from the range and then removes them from buddy system so
+ * page allocator won't consider them when allocating space.
+ *
+ * The allocator may assume that it is unlikely for this function to fail so
+ * if it fails allocator should just recover and return error.
+ */
+int __cma_grab(struct cma_region *reg, phys_addr_t start, size_t size);
+
+/**
+ * cma_ungrab_range() - frees pages from range back to buddy system.
+ * @reg:	Region this call is made in context of.  If the region is
+ *		not marked needing grabbing the function does nothing.
+ * @start:	Address in bytes of the first byte to free.
+ * @size:	Size of the region to free.
+ *
+ * This is reverse of cma_grab_range().  Allocator should use it when
+ * physical memory is no longer used.
+ */
+void __cma_ungrab(struct cma_region *reg, phys_addr_t start, size_t size);
+
 
 /**************************** Initialisation API ****************************/
 
diff --git a/mm/Kconfig b/mm/Kconfig
index 4aee3c5..80fd6bd 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -363,6 +363,21 @@ config CMA
 	  For more information see <Documentation/contiguous-memory.txt>.
 	  If unsure, say "n".
 
+config CMA_USE_MIGRATE_CMA
+	bool "Use MIGRATE_CMA"
+	depends on CMA
+	default y
+	select MIGRATION
+	select MIGRATE_CMA
+	help
+	  This makes CMA use MIGRATE_CMA migration type for regions
+	  maintained by CMA.  This makes it possible for standard page
+	  allocator to use pages from such regions.  This in turn may
+	  make the whole system run faster as there will be more space
+	  for page caches, etc.
+
+	  If unsure, say "y".
+
 config CMA_DEVELOPEMENT
 	bool "Include CMA developement features"
 	depends on CMA
diff --git a/mm/cma-best-fit.c b/mm/cma-best-fit.c
index 5ed1168..15f4206 100644
--- a/mm/cma-best-fit.c
+++ b/mm/cma-best-fit.c
@@ -145,6 +145,8 @@ static void cma_bf_cleanup(struct cma_region *reg)
 	kfree(prv);
 }
 
+static void __cma_bf_free(struct cma_region *reg, union cma_bf_item *chunk);
+
 struct cma *cma_bf_alloc(struct cma_region *reg,
 			 size_t size, unsigned long alignment)
 {
@@ -281,10 +283,17 @@ case_2:
 
 	item->chunk.phys = start;
 	item->chunk.size = size;
+
+	ret = __cma_grab(reg, start, size);
+	if (ret) {
+		__cma_bf_free(reg, item);
+		return ERR_PTR(ret);
+	}
+
 	return &item->chunk;
 }
 
-static void cma_bf_free(struct cma_chunk *chunk)
+static void __cma_bf_free(struct cma_region *reg, union cma_bf_item *item)
 {
 	struct cma_bf_private *prv = reg->private_data;
 	union cma_bf_item *prev;
@@ -350,6 +359,7 @@ next:
 	}
 }
 
+static void cma_bf_free(struct cma *chunk)
 {
 	__cma_ungrab(chunk->reg, chunk->phys, chunk->size);
 	__cma_bf_free(chunk->reg, 
diff --git a/mm/cma.c b/mm/cma.c
index dfdeeb7..510181a 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -39,6 +39,13 @@
 
 #include <linux/cma.h>
 
+#ifdef CONFIG_CMA_USE_MIGRATE_CMA
+#include <linux/page-isolation.h>
+
+#include <asm/page.h>
+
+#include "internal.h"          /* __free_pageblock_cma() */
+#endif
 
 /*
  * Protects cma_regions, cma_allocators, cma_map, cma_map_length,
@@ -410,6 +417,222 @@ __cma_early_reserve(struct cma_region *reg)
 	return tried ? -ENOMEM : -EOPNOTSUPP;
 }
 
+#ifdef CONFIG_CMA_USE_MIGRATE_CMA
+
+static struct cma_grabbed_early {
+	phys_addr_t start;
+	size_t size;
+} cma_grabbed_early[16] __initdata;
+static unsigned cma_grabbed_early_count __initdata;
+
+/* XXX Revisit */
+#ifdef phys_to_pfn
+/* nothing to do */
+#elif defined __phys_to_pfn
+#  define phys_to_pfn __phys_to_pfn
+#else
+#  warning correct phys_to_pfn implementation needed
+static unsigned long phys_to_pfn(phys_addr_t phys)
+{
+	return virt_to_pfn(phys_to_virt(phys));
+}
+#endif
+
+static unsigned long pfn_to_maxpage(unsigned long pfn)
+{
+	return pfn & ~(MAX_ORDER_NR_PAGES - 1);
+}
+
+static unsigned long pfn_to_maxpage_up(unsigned long pfn)
+{
+	return ALIGN(pfn, MAX_ORDER_NR_PAGES);
+}
+
+static int __init cma_free_grabbed(void)
+{
+	struct cma_grabbed_early *r = cma_grabbed_early;
+	unsigned i = cma_grabbed_early_count;
+
+	for (; i; --i, ++r) {
+		struct page *p = phys_to_page(r->start);
+		unsigned j = r->size >> (PAGE_SHIFT + pageblock_order);
+
+		pr_debug("feeding buddy with: %p + %u * %luM\n",
+			 (void *)r->start,
+			 j, 1ul << (PAGE_SHIFT + pageblock_order - 20));
+
+		do {
+			__free_pageblock_cma(p);
+			p += pageblock_nr_pages;
+		} while (--j);
+	}
+
+	return 0;
+}
+module_init(cma_free_grabbed);
+
+static phys_addr_t
+__cma_early_region_reserve_try_migrate_cma(struct cma_region *reg)
+{
+	int ret;
+
+	if (((reg->start | reg->size) & ((PAGE_SIZE << MAX_ORDER) - 1)))
+		return -EOPNOTSUPP;
+
+	/*
+	 * XXX Revisit: Do we need to check if the region is
+	 * consistent?  For instance, are all pages valid and part of
+	 * the same zone?
+	 */
+
+	if (cma_grabbed_early_count >= ARRAY_SIZE(cma_grabbed_early)) {
+		static bool once = true;
+		if (once) {
+			pr_warn("grabbed too many ranges, not all will be MIGRATE_CMA");
+			once = false;
+		}
+		return -EOPNOTSUPP;
+	}
+
+	pr_debug("init: reserving region as MIGRATE_CMA\n");
+
+	reg->alignment = max(reg->alignment,
+			     (unsigned long)PAGE_SHIFT << MAX_ORDER);
+
+	ret = __cma_early_reserve(reg);
+	if (ret)
+		return ret;
+
+	cma_grabbed_early[cma_grabbed_early_count].start = reg->start;
+	cma_grabbed_early[cma_grabbed_early_count].size  = reg->size;
+	++cma_grabbed_early_count;
+
+	reg->use_isolate = 1;
+
+	return 0;
+}
+
+int __cma_grab(struct cma_region *reg, phys_addr_t start_addr, size_t size)
+{
+	unsigned long start, end, _start, _end;
+	int ret;
+
+	if (!reg->use_isolate)
+		return 0;
+
+	pr_debug("%s\n", __func__);
+
+	/*
+	 * What we do here is we mark all pageblocks in range as
+	 * MIGRATE_ISOLATE.  Because of the way page allocator work, we
+	 * align the range to MAX_ORDER pages so that page allocator
+	 * won't try to merge buddies from different pageblocks and
+	 * change MIGRATE_ISOLATE to some other migration type.
+	 *
+	 * Once the pageblocks are marked as MIGRATE_ISOLATE, we
+	 * migrate the pages from an unaligned range (ie. pages that
+	 * we are interested in).  This will put all the pages in
+	 * range back to page allocator as MIGRATE_ISOLATE.
+	 *
+	 * When this is done, we take the pages in range from page
+	 * allocator removing them from the buddy system.  This way
+	 * page allocator will never consider using them.
+	 *
+	 * This lets us mark the pageblocks back as MIGRATE_CMA so
+	 * that free pages in the MAX_ORDER aligned range but not in
+	 * the unaligned, original range are put back to page
+	 * allocator so that buddy can use them.
+	 */
+
+	start = phys_to_pfn(start_addr);
+	end   = start + (size >> PAGE_SHIFT);
+
+	pr_debug("\tisolate range(%lx, %lx)\n",
+		 pfn_to_maxpage(start), pfn_to_maxpage_up(end));
+	ret = __start_isolate_page_range(pfn_to_maxpage(start),
+					 pfn_to_maxpage_up(end), MIGRATE_CMA);
+	if (ret)
+		goto done;
+
+	pr_debug("\tmigrate range(%lx, %lx)\n", start, end);
+	ret = do_migrate_range(start, end);
+	if (ret)
+		goto done;
+
+	/*
+	 * Pages from [start, end) are within a MAX_ORDER aligned
+	 * blocks that are marked as MIGRATE_ISOLATE.  What's more,
+	 * all pages in [start, end) are free in page allocator.  What
+	 * we are going to do is to allocate all pages from [start,
+	 * end) (that is remove them from page allocater).
+	 *
+	 * The only problem is that pages at the beginning and at the
+	 * end of interesting range may be not aligned with pages that
+	 * page allocator holds, ie. they can be part of higher order
+	 * pages.  Because of this, we reserve the bigger range and
+	 * once this is done free the pages we are not interested in.
+	 */
+
+	pr_debug("\tfinding buddy\n");
+	ret = 0;
+	while (!PageBuddy(pfn_to_page(start & (~0UL << ret))))
+		if (WARN_ON(++ret > MAX_ORDER))
+			return -EINVAL;
+
+	_start = start & (~0UL << ret);
+	pr_debug("\talloc freed(%lx, %lx)\n", _start, end);
+	_end   = alloc_contig_freed_pages(_start, end, 0);
+
+	/* Free head and tail (if any) */
+	pr_debug("\tfree contig(%lx, %lx)\n", _start, start);
+	free_contig_pages(pfn_to_page(_start), start - _start);
+	pr_debug("\tfree contig(%lx, %lx)\n", end, _end);
+	free_contig_pages(pfn_to_page(end), _end - end);
+
+	ret = 0;
+
+done:
+	pr_debug("\tundo isolate range(%lx, %lx)\n",
+		 pfn_to_maxpage(start), pfn_to_maxpage_up(end));
+	__undo_isolate_page_range(pfn_to_maxpage(start),
+				  pfn_to_maxpage_up(end), MIGRATE_CMA);
+
+	pr_debug("ret = %d\n", ret);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(__cma_grab);
+
+void __cma_ungrab(struct cma_region *reg, phys_addr_t start, size_t size)
+{
+	if (reg->use_isolate)
+		free_contig_pages(pfn_to_page(phys_to_pfn(start)),
+				  size >> PAGE_SHIFT);
+}
+EXPORT_SYMBOL_GPL(__cma_ungrab);
+
+#else
+
+static inline phys_addr_t
+__cma_early_region_reserve_try_migrate_cma(struct cma_region *reg)
+{
+	return -EOPNOTSUPP;
+}
+
+int __cma_grab(struct cma_region *reg, phys_addr_t start, size_t size)
+{
+	(void)reg; (void)start; (void)size;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(__cma_grab);
+
+void __cma_ungrab(struct cma_region *reg, phys_addr_t start, size_t size)
+{
+	(void)reg; (void)start; (void)size;
+}
+EXPORT_SYMBOL_GPL(__cma_ungrab);
+
+#endif
+
 int __init cma_early_region_reserve(struct cma_region *reg)
 {
 	int ret;
@@ -420,6 +643,13 @@ int __init cma_early_region_reserve(struct cma_region *reg)
 	    reg->reserved)
 		return -EINVAL;
 
+	/*
+	 * Try using cma_early_grab_maxpages() if the requested
+	 * region's start is aligned to PAGE_SIZE << MAX_ORDER and
+	 * its size is PAGE_SIZE << MAX_ORDER multiple.
+	 */
+	ret = __cma_early_region_reserve_try_migrate_cma(reg);
+	if (ret ==-EOPNOTSUPP)
 	ret = __cma_early_reserve(reg);
 	if (!ret)
 		reg->reserved = 1;
@@ -1393,6 +1623,7 @@ struct cma *cma_gen_alloc(struct cma_region *reg,
 {
 	unsigned long start;
 	struct cma *chunk;
+	int ret;
 
 	chunk = kmalloc(sizeof *chunk, GFP_KERNEL);
 	if (unlikely(!chunk))
@@ -1405,6 +1636,13 @@ struct cma *cma_gen_alloc(struct cma_region *reg,
 		return ERR_PTR(-ENOMEM);
 	}
 
+	ret = __cma_grab(reg, start, size);
+	if (ret) {
+		gen_pool_free(reg->private_data, start, size);
+		kfree(chunk);
+		return ERR_PTR(ret);
+	}
+
 	chunk->phys = start;
 	chunk->size = size;
 	return chunk;
@@ -1413,6 +1651,7 @@ struct cma *cma_gen_alloc(struct cma_region *reg,
 static void cma_gen_free(struct cma *chunk)
 {
 	gen_pool_free(chunk->reg->private_data, chunk->phys, chunk->size);
+	__cma_ungrab(chunk->reg, chunk->phys, chunk->size);
 	kfree(chunk);
 }
 
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
