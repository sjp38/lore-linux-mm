Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6C4B66B0263
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 02:39:23 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w128so8001758pfd.3
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 23:39:23 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id bf8si17658355pad.59.2016.08.08.23.39.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Aug 2016 23:39:22 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id cf3so422003pad.2
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 23:39:22 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v4 2/5] mm/cma: populate ZONE_CMA
Date: Tue,  9 Aug 2016 15:39:16 +0900
Message-Id: <1470724759-855-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1470724759-855-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1470724759-855-1-git-send-email-iamjoonsoo.kim@lge.com>
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

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/memory_hotplug.h |  3 ---
 mm/cma.c                       | 48 ++++++++++++++++++++++++++++++++++++++----
 mm/internal.h                  |  3 +++
 mm/page_alloc.c                | 26 +++++++++++++++++++++--
 4 files changed, 71 insertions(+), 9 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 01033fa..ea5af47 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -198,9 +198,6 @@ void put_online_mems(void);
 void mem_hotplug_begin(void);
 void mem_hotplug_done(void);
 
-extern void set_zone_contiguous(struct zone *zone);
-extern void clear_zone_contiguous(struct zone *zone);
-
 #else /* ! CONFIG_MEMORY_HOTPLUG */
 /*
  * Stub functions for when hotplug is off
diff --git a/mm/cma.c b/mm/cma.c
index bd0e141..5fc425f 100644
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
@@ -145,6 +145,28 @@ err:
 static int __init cma_init_reserved_areas(void)
 {
 	int i;
+	struct zone *zone;
+	unsigned long start_pfn = UINT_MAX, end_pfn = 0;
+
+	if (!cma_area_count)
+		return 0;
+
+	for (i = 0; i < cma_area_count; i++) {
+		if (start_pfn > cma_areas[i].base_pfn)
+			start_pfn = cma_areas[i].base_pfn;
+		if (end_pfn < cma_areas[i].base_pfn + cma_areas[i].count)
+			end_pfn = cma_areas[i].base_pfn + cma_areas[i].count;
+	}
+
+	for_each_populated_zone(zone) {
+		if (!is_zone_cma(zone))
+			continue;
+
+		/* ZONE_CMA doesn't need to exceed CMA region */
+		zone->zone_start_pfn = max(zone->zone_start_pfn, start_pfn);
+		zone->spanned_pages = min(zone_end_pfn(zone), end_pfn) -
+					zone->zone_start_pfn;
+	}
 
 	for (i = 0; i < cma_area_count; i++) {
 		int ret = cma_activate_area(&cma_areas[i]);
@@ -153,6 +175,24 @@ static int __init cma_init_reserved_areas(void)
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
+	 * registered on module_init and it will be called later than us.
+	 */
+
 	return 0;
 }
 core_initcall(cma_init_reserved_areas);
diff --git a/mm/internal.h b/mm/internal.h
index 1501304..d04255a 100644
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
index f6c4358..352096e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1600,16 +1600,38 @@ void __init page_alloc_init_late(void)
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
 
@@ -7478,7 +7500,7 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
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
