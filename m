Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0E5B06B04B8
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 02:36:52 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t193so31910030pgc.0
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 23:36:52 -0700 (PDT)
Received: from mail-pg0-x231.google.com (mail-pg0-x231.google.com. [2607:f8b0:400e:c05::231])
        by mx.google.com with ESMTPS id r70si2314150pfe.5.2017.08.23.23.36.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 23:36:50 -0700 (PDT)
Received: by mail-pg0-x231.google.com with SMTP id 83so12199674pgb.3
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 23:36:50 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 1/3] mm/cma: manage the memory of the CMA area by using the ZONE_MOVABLE
Date: Thu, 24 Aug 2017 15:36:31 +0900
Message-Id: <1503556593-10720-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1503556593-10720-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1503556593-10720-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

0. History

This patchset is the follow-up of the discussion about the
"Introduce ZONE_CMA (v7)" [1]. Please reference it if more information
is needed.

1. What does this patch do?

This patch changes the management way for the memory of the CMA area
in the MM subsystem. Currently, The memory of the CMA area is managed
by the zone where their pfn is belong to. However, this approach has
some problems since MM subsystem doesn't have enough logic to handle
the situation that different characteristic memories are in a single zone.
To solve this issue, this patch try to manage all the memory of
the CMA area by using the MOVABLE zone. In MM subsystem's point of view,
characteristic of the memory on the MOVABLE zone and the memory of
the CMA area are the same. So, managing the memory of the CMA area
by using the MOVABLE zone will not have any problem.

2. Motivation

There are some problems with current approach. See following.
Although these problem would not be inherent and it could be fixed without
this conception change, it requires many hooks addition in various
code path and it would be intrusive to core MM and would be really
error-prone. Therefore, I try to solve them with this new approach.
Anyway, following is the problems of the current implementation.

o CMA memory utilization

First, following is the freepage calculation logic in MM.

- For movable allocation: freepage = total freepage
- For unmovable allocation: freepage = total freepage - CMA freepage

Freepages on the CMA area is used after the normal freepages in the zone
where the memory of the CMA area is belong to are exhausted. At that moment
that the number of the normal freepages is zero, so

- For movable allocation: freepage = total freepage = CMA freepage
- For unmovable allocation: freepage = 0

If unmovable allocation comes at this moment, allocation request would
fail to pass the watermark check and reclaim is started. After reclaim,
there would exist the normal freepages so freepages on the CMA areas
would not be used.

FYI, there is another attempt [2] trying to solve this problem in lkml.
And, as far as I know, Qualcomm also has out-of-tree solution for this
problem.

o useless reclaim

There is no logic to distinguish CMA pages in the reclaim path. Hence,
CMA page is reclaimed even if the system just needs the page that can
be usable for the kernel allocation.

o atomic allocation failure

This is also related to the fallback allocation policy for the memory
of the CMA area. Consider the situation that the number of the normal
freepages is *zero* since the bunch of the movable allocation requests
come. Kswapd would not be woken up due to following freepage calculation
logic.

- For movable allocation: freepage = total freepage = CMA freepage

If atomic unmovable allocation request comes at this moment, it would
fails due to following logic.

- For unmovable allocation: freepage = total freepage - CMA freepage = 0

It was reported by Aneesh [3].

o useless compaction

Usual high-order allocation request is unmovable allocation request and
it cannot be served from the memory of the CMA area. In compaction,
migration scanner try to migrate the page in the CMA area and make
high-order page there. As mentioned above, it cannot be usable
for the unmovable allocation request so it's just waste.

3. Current approach and new approach

Current approach is that the memory of the CMA area is managed by the zone
where their pfn is belong to. However, these memory should be
distinguishable since they have a strong limitation. So, they are marked
as MIGRATE_CMA in pageblock flag and handled specially. However,
as mentioned in section 2, the MM subsystem doesn't have enough logic
to deal with this special pageblock so many problems raised.

New approach is that the memory of the CMA area is managed by
the MOVABLE zone. MM already have enough logic to deal with special zone
like as HIGHMEM and MOVABLE zone. So, managing the memory of the CMA area
by the MOVABLE zone just naturally work well because constraints
for the memory of the CMA area that the memory should always be migratable
is the same with the constraint for the MOVABLE zone.

There is one side-effect for the usability of the memory of the CMA area.
The use of MOVABLE zone is only allowed for a request with GFP_HIGHMEM &&
GFP_MOVABLE so now the memory of the CMA area is also only allowed for
this gfp flag. Before this patchset, a request with GFP_MOVABLE can use
them. IMO, It would not be a big issue since most of GFP_MOVABLE request
also has GFP_HIGHMEM flag. For example, file cache page and anonymous page.
However, file cache page for blockdev file is an exception. Request for it
has no GFP_HIGHMEM flag. There is pros and cons on this exception.
In my experience, blockdev file cache pages are one of the top reason
that causes cma_alloc() to fail temporarily. So, we can get more guarantee
of cma_alloc() success by discarding this case.

Note that there is no change in admin POV since this patchset is just
for internal implementation change in MM subsystem. Just one minor
difference for admin is that the memory stat for CMA area will be printed
in the MOVABLE zone. That's all.

4. Result

Following is the experimental result related to utilization problem.

8 CPUs, 1024 MB, VIRTUAL MACHINE
make -j16

<Before>
CMA area:               0 MB            512 MB
Elapsed-time:           92.4		186.5
pswpin:                 82		18647
pswpout:                160		69839

<After>
CMA        :            0 MB            512 MB
Elapsed-time:           93.1		93.4
pswpin:                 84		46
pswpout:                183		92

[1]: lkml.kernel.org/r/1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com
[2]: https://lkml.org/lkml/2014/10/15/623
[3]: http://www.spinics.net/lists/linux-mm/msg100562.html

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/memory_hotplug.h |  3 --
 include/linux/mm.h             |  1 +
 mm/cma.c                       | 83 ++++++++++++++++++++++++++++++++++++------
 mm/internal.h                  |  3 ++
 mm/page_alloc.c                | 55 +++++++++++++++++++++++++---
 5 files changed, 126 insertions(+), 19 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 0995e1a..fb94608 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -230,9 +230,6 @@ void put_online_mems(void);
 void mem_hotplug_begin(void);
 void mem_hotplug_done(void);
 
-extern void set_zone_contiguous(struct zone *zone);
-extern void clear_zone_contiguous(struct zone *zone);
-
 #else /* ! CONFIG_MEMORY_HOTPLUG */
 #define pfn_to_online_page(pfn)			\
 ({						\
diff --git a/include/linux/mm.h b/include/linux/mm.h
index deb9c70..d4daadc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2049,6 +2049,7 @@ extern void setup_per_cpu_pageset(void);
 
 extern void zone_pcp_update(struct zone *zone);
 extern void zone_pcp_reset(struct zone *zone);
+extern void setup_zone_pageset(struct zone *zone);
 
 /* page_alloc.c */
 extern int min_free_kbytes;
diff --git a/mm/cma.c b/mm/cma.c
index c0da318..a8ababb 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -38,6 +38,7 @@
 #include <trace/events/cma.h>
 
 #include "cma.h"
+#include "internal.h"
 
 struct cma cma_areas[MAX_CMA_AREAS];
 unsigned cma_area_count;
@@ -108,23 +109,25 @@ static int __init cma_activate_area(struct cma *cma)
 	if (!cma->bitmap)
 		return -ENOMEM;
 
-	WARN_ON_ONCE(!pfn_valid(pfn));
-	zone = page_zone(pfn_to_page(pfn));
-
 	do {
 		unsigned j;
 
 		base_pfn = pfn;
+		if (!pfn_valid(base_pfn))
+			goto err;
+
+		zone = page_zone(pfn_to_page(base_pfn));
 		for (j = pageblock_nr_pages; j; --j, pfn++) {
-			WARN_ON_ONCE(!pfn_valid(pfn));
+			if (!pfn_valid(pfn))
+				goto err;
+
 			/*
-			 * alloc_contig_range requires the pfn range
-			 * specified to be in the same zone. Make this
-			 * simple by forcing the entire CMA resv range
-			 * to be in the same zone.
+			 * In init_cma_reserved_pageblock(), present_pages
+			 * is adjusted with assumption that all pages in
+			 * the pageblock come from a single zone.
 			 */
 			if (page_zone(pfn_to_page(pfn)) != zone)
-				goto not_in_zone;
+				goto err;
 		}
 		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
 	} while (--i);
@@ -138,7 +141,7 @@ static int __init cma_activate_area(struct cma *cma)
 
 	return 0;
 
-not_in_zone:
+err:
 	pr_err("CMA area %s could not be activated\n", cma->name);
 	kfree(cma->bitmap);
 	cma->count = 0;
@@ -148,6 +151,41 @@ static int __init cma_activate_area(struct cma *cma)
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
+		zone = &pgdat->node_zones[ZONE_MOVABLE];
+
+		/*
+		 * In this case, we cannot adjust the zone range
+		 * since it is now maximum node span and we don't
+		 * know original zone range.
+		 */
+		if (populated_zone(zone))
+			continue;
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
+		zone->zone_start_pfn = start_pfn;
+		zone->spanned_pages = end_pfn - start_pfn;
+	}
 
 	for (i = 0; i < cma_area_count; i++) {
 		int ret = cma_activate_area(&cma_areas[i]);
@@ -156,9 +194,32 @@ static int __init cma_init_reserved_areas(void)
 			return ret;
 	}
 
+	/*
+	 * Reserved pages for ZONE_MOVABLE are now activated and
+	 * this would change ZONE_MOVABLE's managed page counter and
+	 * the other zones' present counter. We need to re-calculate
+	 * various zone information that depends on this initialization.
+	 */
+	build_all_zonelists(NULL);
+	for_each_populated_zone(zone) {
+		if (zone_idx(zone) == ZONE_MOVABLE) {
+			zone_pcp_reset(zone);
+			setup_zone_pageset(zone);
+		} else
+			zone_pcp_update(zone);
+
+		set_zone_contiguous(zone);
+	}
+
+	/*
+	 * We need to re-init per zone wmark by calling
+	 * init_per_zone_wmark_min() but doesn't call here because it is
+	 * registered on core_initcall and it will be called later than us.
+	 */
+
 	return 0;
 }
-core_initcall(cma_init_reserved_areas);
+pure_initcall(cma_init_reserved_areas);
 
 /**
  * cma_init_reserved_mem() - create custom contiguous area from reserved memory
diff --git a/mm/internal.h b/mm/internal.h
index 1df011f..b4f9ebc 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -168,6 +168,9 @@ extern void post_alloc_hook(struct page *page, unsigned int order,
 					gfp_t gfp_flags);
 extern int user_min_free_kbytes;
 
+extern void set_zone_contiguous(struct zone *zone);
+extern void clear_zone_contiguous(struct zone *zone);
+
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index eb094b1..bbd00f1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1596,16 +1596,38 @@ void __init page_alloc_init_late(void)
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
+	 * ZONE_MOVABLE will steal present pages from other zones by
+	 * changing page links so page_zone() is changed. Before that,
+	 * we need to adjust previous zone's page count first.
+	 */
+	adjust_present_page_count(page, -pageblock_nr_pages);
 
 	do {
 		__ClearPageReserved(p);
 		set_page_count(p, 0);
-	} while (++p, --i);
+
+		/* Steal pages from other zones */
+		set_page_links(p, ZONE_MOVABLE, nid, pfn);
+	} while (++p, ++pfn, --i);
+
+	adjust_present_page_count(page, pageblock_nr_pages);
 
 	set_pageblock_migratetype(page, MIGRATE_CMA);
 
@@ -6023,6 +6045,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 {
 	enum zone_type j;
 	int nid = pgdat->node_id;
+	unsigned long node_end_pfn = 0;
 
 	pgdat_resize_init(pgdat);
 #ifdef CONFIG_NUMA_BALANCING
@@ -6050,9 +6073,13 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		struct zone *zone = pgdat->node_zones + j;
 		unsigned long size, realsize, freesize, memmap_pages;
 		unsigned long zone_start_pfn = zone->zone_start_pfn;
+		unsigned long movable_size = 0;
 
 		size = zone->spanned_pages;
 		realsize = freesize = zone->present_pages;
+		if (zone_end_pfn(zone) > node_end_pfn)
+			node_end_pfn = zone_end_pfn(zone);
+
 
 		/*
 		 * Adjust freesize so that it accounts for how much memory
@@ -6101,12 +6128,30 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		zone_seqlock_init(zone);
 		zone_pcp_init(zone);
 
-		if (!size)
+		/*
+		 * The size of the CMA area is unknown now so we need to
+		 * prepare the memory for the usemap at maximum.
+		 */
+		if (IS_ENABLED(CONFIG_CMA) && j == ZONE_MOVABLE &&
+			pgdat->node_spanned_pages) {
+			movable_size = node_end_pfn - pgdat->node_start_pfn;
+		}
+
+		if (!size && !movable_size)
 			continue;
 
 		set_pageblock_order();
-		setup_usemap(pgdat, zone, zone_start_pfn, size);
-		init_currently_empty_zone(zone, zone_start_pfn, size);
+		if (movable_size) {
+			zone->zone_start_pfn = pgdat->node_start_pfn;
+			zone->spanned_pages = movable_size;
+			setup_usemap(pgdat, zone,
+				pgdat->node_start_pfn, movable_size);
+			init_currently_empty_zone(zone,
+				pgdat->node_start_pfn, movable_size);
+		} else {
+			setup_usemap(pgdat, zone, zone_start_pfn, size);
+			init_currently_empty_zone(zone, zone_start_pfn, size);
+		}
 		memmap_init(size, nid, j, zone_start_pfn);
 	}
 }
@@ -7657,7 +7702,7 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
 }
 #endif
 
-#ifdef CONFIG_MEMORY_HOTPLUG
+#if defined CONFIG_MEMORY_HOTPLUG || defined CONFIG_CMA
 /*
  * The zone indicated has a new number of managed_pages; batch sizes and percpu
  * page high values need to be recalulated.
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
