Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id E785D8292A
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 02:30:38 -0500 (EST)
Received: by pdjp10 with SMTP id p10so10196941pdj.3
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 23:30:38 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id sy6si3924216pac.138.2015.02.11.23.30.18
        for <linux-mm@kvack.org>;
        Wed, 11 Feb 2015 23:30:19 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC 13/16] mm/cma: populate ZONE_CMA and use this zone when GFP_HIGHUSERMOVABLE
Date: Thu, 12 Feb 2015 16:32:17 +0900
Message-Id: <1423726340-4084-14-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Until now, reserved pages for CMA are managed altogether with normal
page in the same zone. This approach has numorous problems and fixing
them isn't easy. To fix this situation, ZONE_CMA is introduced in
previous patch, but, not yet populated. This patch implement population
of ZONE_CMA by stealing reserved pages from normal zones. This stealing
break one uncertain assumption on zone, that is, zone isn't overlapped.
In the early of this series, some check is inserted to every zone's span
iterator to handle zone overlap so there would be no problem with
this assumption break.

To utilize this zone, user should use GFP_HIGHUSERMOVABLE, because
these pages are only applicable for movable type and ZONE_CMA could
contain highmem.

Implementation itself is very easy to understand. Do steal when cma
area is initialized and recalculate values for per zone data structure.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/gfp.h |   10 ++++++++--
 include/linux/mm.h  |    1 +
 mm/cma.c            |   23 ++++++++++++++++-------
 mm/page_alloc.c     |   42 +++++++++++++++++++++++++++++++++++++++---
 4 files changed, 64 insertions(+), 12 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 619eb20..d125440 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -186,6 +186,12 @@ static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
 #define OPT_ZONE_DMA32 ZONE_NORMAL
 #endif
 
+#ifdef CONFIG_CMA
+#define OPT_ZONE_CMA ZONE_CMA
+#else
+#define OPT_ZONE_CMA ZONE_MOVABLE
+#endif
+
 /*
  * GFP_ZONE_TABLE is a word size bitstring that is used for looking up the
  * zone to use given the lowest 4 bits of gfp_t. Entries are ZONE_SHIFT long
@@ -226,7 +232,7 @@ static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
 	| ((u64)OPT_ZONE_DMA32 << ___GFP_DMA32 * ZONES_SHIFT)		      \
 	| ((u64)ZONE_NORMAL << ___GFP_MOVABLE * ZONES_SHIFT)		      \
 	| ((u64)OPT_ZONE_DMA << (___GFP_MOVABLE | ___GFP_DMA) * ZONES_SHIFT)  \
-	| ((u64)ZONE_MOVABLE << (___GFP_MOVABLE|___GFP_HIGHMEM) * ZONES_SHIFT)\
+	| ((u64)OPT_ZONE_CMA << (___GFP_MOVABLE|___GFP_HIGHMEM) * ZONES_SHIFT)\
 	| ((u64)OPT_ZONE_DMA32 << (___GFP_MOVABLE|___GFP_DMA32) * ZONES_SHIFT)\
 )
 
@@ -412,7 +418,7 @@ extern int alloc_contig_range(unsigned long start, unsigned long end,
 extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
 
 /* CMA stuff */
-extern void init_cma_reserved_pageblock(struct page *page);
+extern void init_cma_reserved_pageblock(unsigned long pfn);
 
 #endif
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b464611..2d76446 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1731,6 +1731,7 @@ extern __printf(3, 4)
 void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...);
 
 extern void setup_per_cpu_pageset(void);
+extern void recalc_per_cpu_pageset(void);
 
 extern void zone_pcp_update(struct zone *zone);
 extern void zone_pcp_reset(struct zone *zone);
diff --git a/mm/cma.c b/mm/cma.c
index f817b91..267fa14 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -97,7 +97,7 @@ static int __init cma_activate_area(struct cma *cma)
 	int bitmap_size = BITS_TO_LONGS(cma_bitmap_maxno(cma)) * sizeof(long);
 	unsigned long base_pfn = cma->base_pfn, pfn = base_pfn;
 	unsigned i = cma->count >> pageblock_order;
-	struct zone *zone;
+	int nid;
 
 	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
 
@@ -105,7 +105,7 @@ static int __init cma_activate_area(struct cma *cma)
 		return -ENOMEM;
 
 	WARN_ON_ONCE(!pfn_valid(pfn));
-	zone = page_zone(pfn_to_page(pfn));
+	nid = page_to_nid(pfn_to_page(pfn));
 
 	do {
 		unsigned j;
@@ -115,16 +115,25 @@ static int __init cma_activate_area(struct cma *cma)
 			WARN_ON_ONCE(!pfn_valid(pfn));
 			/*
 			 * alloc_contig_range requires the pfn range
-			 * specified to be in the same zone. Make this
-			 * simple by forcing the entire CMA resv range
-			 * to be in the same zone.
+			 * specified to be in the same zone. We will
+			 * achieve this goal by stealing pages from
+			 * oridinary zone to ZONE_CMA. But, we need
+			 * to make sure that entire CMA resv range to
+			 * be in the same node. Otherwise, they could
+			 * be on ZONE_CMA of different node.
 			 */
-			if (page_zone(pfn_to_page(pfn)) != zone)
+			if (page_to_nid(pfn_to_page(pfn)) != nid)
 				goto err;
 		}
-		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
+		init_cma_reserved_pageblock(base_pfn);
 	} while (--i);
 
+	/*
+	 * ZONE_CMA steals some managed pages from other zones,
+	 * so we need to re-calculate pcp count for all zones.
+	 */
+	recalc_per_cpu_pageset();
+
 	mutex_init(&cma->lock);
 	return 0;
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 443f854..f2844f0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -59,6 +59,7 @@
 #include <linux/page-debug-flags.h>
 #include <linux/hugetlb.h>
 #include <linux/sched/rt.h>
+#include <linux/cma.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -807,16 +808,35 @@ void __init __free_pages_bootmem(struct page *page, unsigned int order)
 }
 
 #ifdef CONFIG_CMA
+static void __init adjust_present_page_count(struct page *page, long count)
+{
+	struct zone *zone = page_zone(page);
+
+	zone->present_pages += count;
+}
+
 /* Free whole pageblock and set its migration type to MIGRATE_CMA. */
-void __init init_cma_reserved_pageblock(struct page *page)
+void __init init_cma_reserved_pageblock(unsigned long pfn)
 {
 	unsigned i = pageblock_nr_pages;
+	struct page *page = pfn_to_page(pfn);
 	struct page *p = page;
+	int nid = page_to_nid(page);
+
+	/*
+	 * ZONE_CMA will steal present pages from other zones by changing
+	 * page links, so adjust present_page count before stealing.
+	 */
+	adjust_present_page_count(page, -pageblock_nr_pages);
 
 	do {
 		__ClearPageReserved(p);
 		set_page_count(p, 0);
-	} while (++p, --i);
+
+		/* Steal page from other zones */
+		set_page_links(p, ZONE_CMA, nid, pfn);
+		mminit_verify_page_links(p, ZONE_CMA, nid, pfn);
+	} while (++p, ++pfn, --i);
 
 	set_pageblock_migratetype(page, MIGRATE_CMA);
 
@@ -4341,6 +4361,20 @@ void __init setup_per_cpu_pageset(void)
 		setup_zone_pageset(zone);
 }
 
+void __init recalc_per_cpu_pageset(void)
+{
+	int cpu;
+	struct zone *zone;
+	struct per_cpu_pageset *pcp;
+
+	for_each_populated_zone(zone) {
+		for_each_possible_cpu(cpu) {
+			pcp = per_cpu_ptr(zone->pageset, cpu);
+			pageset_set_high_and_batch(zone, pcp);
+		}
+	}
+}
+
 static noinline __init_refok
 int zone_wait_table_init(struct zone *zone, unsigned long zone_size_pages)
 {
@@ -4880,7 +4914,9 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
 			zone_start_pfn = first_zone_start_pfn;
 			size = last_zone_end_pfn - first_zone_start_pfn;
-			realsize = freesize = 0;
+			realsize = freesize =
+				cma_total_pages(first_zone_start_pfn,
+						last_zone_end_pfn);
 			memmap_pages = 0;
 			goto init_zone;
 		}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
