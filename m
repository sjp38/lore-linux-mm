Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 369EE6B0260
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 23:03:20 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 128so97881802pfz.1
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 20:03:20 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id hd7si14006941pac.71.2016.10.13.20.03.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 20:03:19 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id i85so2813892pfa.0
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 20:03:19 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v6 3/6] mm/cma: populate ZONE_CMA
Date: Fri, 14 Oct 2016 12:03:13 +0900
Message-Id: <1476414196-3514-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1476414196-3514-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1476414196-3514-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Until now, reserved pages for CMA are managed in the ordinary zones
where page's pfn are belong to. This approach has numorous problems
and fixing them isn't easy. (It is mentioned on previous patch.)
To fix this situation, ZONE_CMA is introduced in previous patch, but,
not yet populated. This patch implement population of ZONE_CMA
by stealing reserved pages from the ordinary zones.

Unlike previous implementation that kernel allocation request with
__GFP_MOVABLE could be serviced from CMA region, allocation request only
with GFP_HIGHUSER_MOVABLE can be serviced from CMA region in the new
approach. This is an inevitable design decision to use the zone
implementation because ZONE_CMA could contain highmem. Due to this
decision, ZONE_CMA will work like as ZONE_HIGHMEM or ZONE_MOVABLE.

I don't think it would be a problem because most of file cache pages
and anonymous pages are requested with GFP_HIGHUSER_MOVABLE. It could
be proved by the fact that there are many systems with ZONE_HIGHMEM and
they work fine. Notable disadvantage is that we cannot use these pages
for blockdev file cache page, because it usually has __GFP_MOVABLE but
not __GFP_HIGHMEM and __GFP_USER. But, in this case, there is pros and
cons. In my experience, blockdev file cache pages are one of the top
reason that causes cma_alloc() to fail temporarily. So, we can get more
guarantee of cma_alloc() success by discarding that case.

Implementation itself is very easy to understand. Steal when cma area is
initialized and recalculate various per zone stat/threshold.

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/memory_hotplug.h |  3 --
 include/linux/mm.h             |  1 +
 mm/cma.c                       | 63 ++++++++++++++++++++++++++++++++++++++----
 mm/internal.h                  |  3 ++
 mm/page_alloc.c                | 29 ++++++++++++++++---
 5 files changed, 87 insertions(+), 12 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 01033fa..ea5af47 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -198,9 +198,6 @@ extern void get_page_bootmem(unsigned long ingo, struct page *page,
 void mem_hotplug_begin(void);
 void mem_hotplug_done(void);
 
-extern void set_zone_contiguous(struct zone *zone);
-extern void clear_zone_contiguous(struct zone *zone);
-
 #else /* ! CONFIG_MEMORY_HOTPLUG */
 /*
  * Stub functions for when hotplug is off
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e9caec6..6348d35 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1923,6 +1923,7 @@ extern __printf(2, 3)
 
 extern void zone_pcp_update(struct zone *zone);
 extern void zone_pcp_reset(struct zone *zone);
+extern void setup_zone_pageset(struct zone *zone);
 
 /* page_alloc.c */
 extern int min_free_kbytes;
diff --git a/mm/cma.c b/mm/cma.c
index 384c2cb..ba7c340 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -38,6 +38,7 @@
 #include <trace/events/cma.h>
 
 #include "cma.h"
+#include "internal.h"
 
 struct cma cma_areas[MAX_CMA_AREAS];
 unsigned cma_area_count;
@@ -116,10 +117,9 @@ static int __init cma_activate_area(struct cma *cma)
 		for (j = pageblock_nr_pages; j; --j, pfn++) {
 			WARN_ON_ONCE(!pfn_valid(pfn));
 			/*
-			 * alloc_contig_range requires the pfn range
-			 * specified to be in the same zone. Make this
-			 * simple by forcing the entire CMA resv range
-			 * to be in the same zone.
+			 * In init_cma_reserved_pageblock(), present_pages is
+			 * adjusted with assumption that all pages come from
+			 * a single zone. It could be fixed but not yet done.
 			 */
 			if (page_zone(pfn_to_page(pfn)) != zone)
 				goto err;
@@ -145,6 +145,35 @@ static int __init cma_activate_area(struct cma *cma)
 static int __init cma_init_reserved_areas(void)
 {
 	int i;
+	struct zone *zone;
+	pg_data_t *pgdat;
+
+	if (!cma_area_count)
+		return 0;
+
+	for_each_online_pgdat(pgdat) {
+		unsigned long start_pfn = UINT_MAX, end_pfn = 0;
+
+		for (i = 0; i < cma_area_count; i++) {
+			if (pfn_to_nid(cma_areas[i].base_pfn) !=
+				pgdat->node_id)
+				continue;
+
+			start_pfn = min(start_pfn, cma_areas[i].base_pfn);
+			end_pfn = max(end_pfn, cma_areas[i].base_pfn +
+						cma_areas[i].count);
+		}
+
+		if (!end_pfn)
+			continue;
+
+		zone = &pgdat->node_zones[ZONE_CMA];
+
+		/* ZONE_CMA doesn't need to exceed CMA region */
+		zone->zone_start_pfn = max(zone->zone_start_pfn, start_pfn);
+		zone->spanned_pages = min(zone_end_pfn(zone), end_pfn) -
+					zone->zone_start_pfn;
+	}
 
 	for (i = 0; i < cma_area_count; i++) {
 		int ret = cma_activate_area(&cma_areas[i]);
@@ -153,9 +182,33 @@ static int __init cma_init_reserved_areas(void)
 			return ret;
 	}
 
+	/*
+	 * Reserved pages for ZONE_CMA are now activated and this would change
+	 * ZONE_CMA's managed page counter and other zone's present counter.
+	 * We need to re-calculate various zone information that depends on
+	 * this initialization.
+	 */
+	build_all_zonelists(NULL, NULL);
+	for_each_populated_zone(zone) {
+		zone_pcp_update(zone);
+		set_zone_contiguous(zone);
+	}
+
+	/*
+	 * We need to re-init per zone wmark by calling
+	 * init_per_zone_wmark_min() but doesn't call here because it is
+	 * registered on core_initcall and it will be called later than us.
+	 */
+	for_each_populated_zone(zone) {
+		if (!is_zone_cma(zone))
+			continue;
+
+		setup_zone_pageset(zone);
+	}
+
 	return 0;
 }
-core_initcall(cma_init_reserved_areas);
+pure_initcall(cma_init_reserved_areas);
 
 /**
  * cma_init_reserved_mem() - create custom contiguous area from reserved memory
diff --git a/mm/internal.h b/mm/internal.h
index 537ac99..bb7317d 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -156,6 +156,9 @@ extern void post_alloc_hook(struct page *page, unsigned int order,
 					gfp_t gfp_flags);
 extern int user_min_free_kbytes;
 
+extern void set_zone_contiguous(struct zone *zone);
+extern void clear_zone_contiguous(struct zone *zone);
+
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ac44b01..39d1311 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1610,16 +1610,38 @@ void __init page_alloc_init_late(void)
 }
 
 #ifdef CONFIG_CMA
+static void __init adjust_present_page_count(struct page *page, long count)
+{
+	struct zone *zone = page_zone(page);
+
+	/* We don't need to hold a lock since it is boot-up process */
+	zone->present_pages += count;
+}
+
 /* Free whole pageblock and set its migration type to MIGRATE_CMA. */
 void __init init_cma_reserved_pageblock(struct page *page)
 {
 	unsigned i = pageblock_nr_pages;
+	unsigned long pfn = page_to_pfn(page);
 	struct page *p = page;
+	int nid = page_to_nid(page);
+
+	/*
+	 * ZONE_CMA will steal present pages from other zones by changing
+	 * page links so page_zone() is changed. Before that,
+	 * we need to adjust previous zone's page count first.
+	 */
+	adjust_present_page_count(page, -pageblock_nr_pages);
 
 	do {
 		__ClearPageReserved(p);
 		set_page_count(p, 0);
-	} while (++p, --i);
+
+		/* Steal pages from other zones */
+		set_page_links(p, ZONE_CMA, nid, pfn);
+	} while (++p, ++pfn, --i);
+
+	adjust_present_page_count(page, pageblock_nr_pages);
 
 	set_pageblock_migratetype(page, MIGRATE_CMA);
 
@@ -4886,7 +4908,6 @@ static void build_zonelists(pg_data_t *pgdat)
  */
 static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch);
 static DEFINE_PER_CPU(struct per_cpu_pageset, boot_pageset);
-static void setup_zone_pageset(struct zone *zone);
 
 /*
  * Global mutex to protect against size modification of zonelists
@@ -5316,7 +5337,7 @@ static void __meminit zone_pageset_init(struct zone *zone, int cpu)
 	pageset_set_high_and_batch(zone, pcp);
 }
 
-static void __meminit setup_zone_pageset(struct zone *zone)
+void __meminit setup_zone_pageset(struct zone *zone)
 {
 	int cpu;
 	zone->pageset = alloc_percpu(struct per_cpu_pageset);
@@ -7503,7 +7524,7 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
 }
 #endif
 
-#ifdef CONFIG_MEMORY_HOTPLUG
+#if defined CONFIG_MEMORY_HOTPLUG || defined CONFIG_CMA
 /*
  * The zone indicated has a new number of managed_pages; batch sizes and percpu
  * page high values need to be recalulated.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
