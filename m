Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 16A756B04E2
	for <linux-mm@kvack.org>; Thu, 17 May 2018 09:00:09 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 89-v6so2779696plb.18
        for <linux-mm@kvack.org>; Thu, 17 May 2018 06:00:09 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id w68-v6si5272242pfb.325.2018.05.17.06.00.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 06:00:07 -0700 (PDT)
From: Ville Syrjala <ville.syrjala@linux.intel.com>
Subject: [PATCH] Revert "mm/cma: manage the memory of the CMA area by using the ZONE_MOVABLE"
Date: Thu, 17 May 2018 15:59:59 +0300
Message-Id: <20180517125959.8095-1-ville.syrjala@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Tony Lindgren <tony@atomide.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, =?UTF-8?q?Ville=20Syrj=C3=A4l=C3=A4?= <ville.syrjala@linux.intel.com>

From: Ville SyrjA?lA? <ville.syrjala@linux.intel.com>

This reverts commit bad8c6c0b1144694ecb0bc5629ede9b8b578b86e.

Make x86 with HIGHMEM=y and CMA=y boot again.

Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Tony Lindgren <tony@atomide.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Laura Abbott <lauraa@codeaurora.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Russell King <linux@armlinux.org.uk>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Ville SyrjA?lA? <ville.syrjala@linux.intel.com>
---
 include/linux/memory_hotplug.h |  3 ++
 include/linux/mm.h             |  1 -
 mm/cma.c                       | 83 ++++++------------------------------------
 mm/internal.h                  |  3 --
 mm/page_alloc.c                | 55 +++-------------------------
 5 files changed, 19 insertions(+), 126 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index e0e49b5b1ee1..2b0265265c28 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -216,6 +216,9 @@ void put_online_mems(void);
 void mem_hotplug_begin(void);
 void mem_hotplug_done(void);
 
+extern void set_zone_contiguous(struct zone *zone);
+extern void clear_zone_contiguous(struct zone *zone);
+
 #else /* ! CONFIG_MEMORY_HOTPLUG */
 #define pfn_to_online_page(pfn)			\
 ({						\
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1ac1f06a4be6..f7f1369e9d99 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2109,7 +2109,6 @@ extern void setup_per_cpu_pageset(void);
 
 extern void zone_pcp_update(struct zone *zone);
 extern void zone_pcp_reset(struct zone *zone);
-extern void setup_zone_pageset(struct zone *zone);
 
 /* page_alloc.c */
 extern int min_free_kbytes;
diff --git a/mm/cma.c b/mm/cma.c
index aa40e6c7b042..5809bbe360d7 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -39,7 +39,6 @@
 #include <trace/events/cma.h>
 
 #include "cma.h"
-#include "internal.h"
 
 struct cma cma_areas[MAX_CMA_AREAS];
 unsigned cma_area_count;
@@ -110,25 +109,23 @@ static int __init cma_activate_area(struct cma *cma)
 	if (!cma->bitmap)
 		return -ENOMEM;
 
+	WARN_ON_ONCE(!pfn_valid(pfn));
+	zone = page_zone(pfn_to_page(pfn));
+
 	do {
 		unsigned j;
 
 		base_pfn = pfn;
-		if (!pfn_valid(base_pfn))
-			goto err;
-
-		zone = page_zone(pfn_to_page(base_pfn));
 		for (j = pageblock_nr_pages; j; --j, pfn++) {
-			if (!pfn_valid(pfn))
-				goto err;
-
+			WARN_ON_ONCE(!pfn_valid(pfn));
 			/*
-			 * In init_cma_reserved_pageblock(), present_pages
-			 * is adjusted with assumption that all pages in
-			 * the pageblock come from a single zone.
+			 * alloc_contig_range requires the pfn range
+			 * specified to be in the same zone. Make this
+			 * simple by forcing the entire CMA resv range
+			 * to be in the same zone.
 			 */
 			if (page_zone(pfn_to_page(pfn)) != zone)
-				goto err;
+				goto not_in_zone;
 		}
 		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
 	} while (--i);
@@ -142,7 +139,7 @@ static int __init cma_activate_area(struct cma *cma)
 
 	return 0;
 
-err:
+not_in_zone:
 	pr_err("CMA area %s could not be activated\n", cma->name);
 	kfree(cma->bitmap);
 	cma->count = 0;
@@ -152,41 +149,6 @@ static int __init cma_activate_area(struct cma *cma)
 static int __init cma_init_reserved_areas(void)
 {
 	int i;
-	struct zone *zone;
-	pg_data_t *pgdat;
-
-	if (!cma_area_count)
-		return 0;
-
-	for_each_online_pgdat(pgdat) {
-		unsigned long start_pfn = UINT_MAX, end_pfn = 0;
-
-		zone = &pgdat->node_zones[ZONE_MOVABLE];
-
-		/*
-		 * In this case, we cannot adjust the zone range
-		 * since it is now maximum node span and we don't
-		 * know original zone range.
-		 */
-		if (populated_zone(zone))
-			continue;
-
-		for (i = 0; i < cma_area_count; i++) {
-			if (pfn_to_nid(cma_areas[i].base_pfn) !=
-				pgdat->node_id)
-				continue;
-
-			start_pfn = min(start_pfn, cma_areas[i].base_pfn);
-			end_pfn = max(end_pfn, cma_areas[i].base_pfn +
-						cma_areas[i].count);
-		}
-
-		if (!end_pfn)
-			continue;
-
-		zone->zone_start_pfn = start_pfn;
-		zone->spanned_pages = end_pfn - start_pfn;
-	}
 
 	for (i = 0; i < cma_area_count; i++) {
 		int ret = cma_activate_area(&cma_areas[i]);
@@ -195,32 +157,9 @@ static int __init cma_init_reserved_areas(void)
 			return ret;
 	}
 
-	/*
-	 * Reserved pages for ZONE_MOVABLE are now activated and
-	 * this would change ZONE_MOVABLE's managed page counter and
-	 * the other zones' present counter. We need to re-calculate
-	 * various zone information that depends on this initialization.
-	 */
-	build_all_zonelists(NULL);
-	for_each_populated_zone(zone) {
-		if (zone_idx(zone) == ZONE_MOVABLE) {
-			zone_pcp_reset(zone);
-			setup_zone_pageset(zone);
-		} else
-			zone_pcp_update(zone);
-
-		set_zone_contiguous(zone);
-	}
-
-	/*
-	 * We need to re-init per zone wmark by calling
-	 * init_per_zone_wmark_min() but doesn't call here because it is
-	 * registered on core_initcall and it will be called later than us.
-	 */
-
 	return 0;
 }
-pure_initcall(cma_init_reserved_areas);
+core_initcall(cma_init_reserved_areas);
 
 /**
  * cma_init_reserved_mem() - create custom contiguous area from reserved memory
diff --git a/mm/internal.h b/mm/internal.h
index 62d8c34e63d5..8679b4fe9e1b 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -168,9 +168,6 @@ extern void post_alloc_hook(struct page *page, unsigned int order,
 					gfp_t gfp_flags);
 extern int user_min_free_kbytes;
 
-extern void set_zone_contiguous(struct zone *zone);
-extern void clear_zone_contiguous(struct zone *zone);
-
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 905db9d7962f..3c2f042e9366 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1743,38 +1743,16 @@ void __init page_alloc_init_late(void)
 }
 
 #ifdef CONFIG_CMA
-static void __init adjust_present_page_count(struct page *page, long count)
-{
-	struct zone *zone = page_zone(page);
-
-	/* We don't need to hold a lock since it is boot-up process */
-	zone->present_pages += count;
-}
-
 /* Free whole pageblock and set its migration type to MIGRATE_CMA. */
 void __init init_cma_reserved_pageblock(struct page *page)
 {
 	unsigned i = pageblock_nr_pages;
-	unsigned long pfn = page_to_pfn(page);
 	struct page *p = page;
-	int nid = page_to_nid(page);
-
-	/*
-	 * ZONE_MOVABLE will steal present pages from other zones by
-	 * changing page links so page_zone() is changed. Before that,
-	 * we need to adjust previous zone's page count first.
-	 */
-	adjust_present_page_count(page, -pageblock_nr_pages);
 
 	do {
 		__ClearPageReserved(p);
 		set_page_count(p, 0);
-
-		/* Steal pages from other zones */
-		set_page_links(p, ZONE_MOVABLE, nid, pfn);
-	} while (++p, ++pfn, --i);
-
-	adjust_present_page_count(page, pageblock_nr_pages);
+	} while (++p, --i);
 
 	set_pageblock_migratetype(page, MIGRATE_CMA);
 
@@ -6204,7 +6182,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 {
 	enum zone_type j;
 	int nid = pgdat->node_id;
-	unsigned long node_end_pfn = 0;
 
 	pgdat_resize_init(pgdat);
 #ifdef CONFIG_NUMA_BALANCING
@@ -6232,13 +6209,9 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		struct zone *zone = pgdat->node_zones + j;
 		unsigned long size, realsize, freesize, memmap_pages;
 		unsigned long zone_start_pfn = zone->zone_start_pfn;
-		unsigned long movable_size = 0;
 
 		size = zone->spanned_pages;
 		realsize = freesize = zone->present_pages;
-		if (zone_end_pfn(zone) > node_end_pfn)
-			node_end_pfn = zone_end_pfn(zone);
-
 
 		/*
 		 * Adjust freesize so that it accounts for how much memory
@@ -6287,30 +6260,12 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		zone_seqlock_init(zone);
 		zone_pcp_init(zone);
 
-		/*
-		 * The size of the CMA area is unknown now so we need to
-		 * prepare the memory for the usemap at maximum.
-		 */
-		if (IS_ENABLED(CONFIG_CMA) && j == ZONE_MOVABLE &&
-			pgdat->node_spanned_pages) {
-			movable_size = node_end_pfn - pgdat->node_start_pfn;
-		}
-
-		if (!size && !movable_size)
+		if (!size)
 			continue;
 
 		set_pageblock_order();
-		if (movable_size) {
-			zone->zone_start_pfn = pgdat->node_start_pfn;
-			zone->spanned_pages = movable_size;
-			setup_usemap(pgdat, zone,
-				pgdat->node_start_pfn, movable_size);
-			init_currently_empty_zone(zone,
-				pgdat->node_start_pfn, movable_size);
-		} else {
-			setup_usemap(pgdat, zone, zone_start_pfn, size);
-			init_currently_empty_zone(zone, zone_start_pfn, size);
-		}
+		setup_usemap(pgdat, zone, zone_start_pfn, size);
+		init_currently_empty_zone(zone, zone_start_pfn, size);
 		memmap_init(size, nid, j, zone_start_pfn);
 	}
 }
@@ -7951,7 +7906,7 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
 }
 #endif
 
-#if defined CONFIG_MEMORY_HOTPLUG || defined CONFIG_CMA
+#ifdef CONFIG_MEMORY_HOTPLUG
 /*
  * The zone indicated has a new number of managed_pages; batch sizes and percpu
  * page high values need to be recalulated.
-- 
2.16.1
