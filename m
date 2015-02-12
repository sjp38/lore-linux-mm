Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 857DF82905
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 02:30:26 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so9637332pab.3
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 23:30:26 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id rz2si3807302pab.221.2015.02.11.23.30.12
        for <linux-mm@kvack.org>;
        Wed, 11 Feb 2015 23:30:13 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC 10/16] mm/highmem: remove is_highmem_idx()
Date: Thu, 12 Feb 2015 16:32:14 +0900
Message-Id: <1423726340-4084-11-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We can use is_highmem() on every callsites of is_highmem_idx() so
is_highmem_idx() isn't really needed. And, if we introduce a new zone
for CMA, we need to modify it to adapt for new zone, so it's
inconvenient. Therefore, this patch remove it before introducing
a new zone.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mmzone.h |   18 ++++--------------
 lib/show_mem.c         |    2 +-
 mm/page_alloc.c        |    6 +++---
 mm/vmscan.c            |    2 +-
 4 files changed, 9 insertions(+), 19 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ffe66e3..90237f2 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -854,16 +854,6 @@ static inline int zone_movable_is_highmem(void)
 #endif
 }
 
-static inline int is_highmem_idx(enum zone_type idx)
-{
-#ifdef CONFIG_HIGHMEM
-	return (idx == ZONE_HIGHMEM ||
-		(idx == ZONE_MOVABLE && zone_movable_is_highmem()));
-#else
-	return 0;
-#endif
-}
-
 /**
  * is_highmem - helper function to quickly check if a struct zone is a 
  *              highmem zone or not.  This is an attempt to keep references
@@ -873,10 +863,10 @@ static inline int is_highmem_idx(enum zone_type idx)
 static inline int is_highmem(struct zone *zone)
 {
 #ifdef CONFIG_HIGHMEM
-	int zone_off = (char *)zone - (char *)zone->zone_pgdat->node_zones;
-	return zone_off == ZONE_HIGHMEM * sizeof(*zone) ||
-	       (zone_off == ZONE_MOVABLE * sizeof(*zone) &&
-		zone_movable_is_highmem());
+	int idx = zone_idx(zone);
+
+	return (idx == ZONE_HIGHMEM ||
+		(idx == ZONE_MOVABLE && zone_movable_is_highmem()));
 #else
 	return 0;
 #endif
diff --git a/lib/show_mem.c b/lib/show_mem.c
index 5e25627..f336c5b1 100644
--- a/lib/show_mem.c
+++ b/lib/show_mem.c
@@ -30,7 +30,7 @@ void show_mem(unsigned int filter)
 			total += zone->present_pages;
 			reserved += zone->present_pages - zone->managed_pages;
 
-			if (is_highmem_idx(zoneid))
+			if (is_highmem(zone))
 				highmem += zone->present_pages;
 		}
 		pgdat_resize_unlock(pgdat, &flags);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7733663..416e036 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4151,7 +4151,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		INIT_LIST_HEAD(&page->lru);
 #ifdef WANT_PAGE_VIRTUAL
 		/* The shift won't overflow because ZONE_NORMAL is below 4G. */
-		if (!is_highmem_idx(zone))
+		if (!is_highmem(z))
 			set_page_address(page, __va(pfn << PAGE_SHIFT));
 #endif
 	}
@@ -4881,7 +4881,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 					zone_names[0], dma_reserve);
 		}
 
-		if (!is_highmem_idx(j))
+		if (!is_highmem(zone))
 			nr_kernel_pages += freesize;
 		/* Charge for highmem memmap if there are enough kernel pages */
 		else if (nr_kernel_pages > memmap_pages * 2)
@@ -4895,7 +4895,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		 * when the bootmem allocator frees pages into the buddy system.
 		 * And all highmem pages will be managed by the buddy system.
 		 */
-		zone->managed_pages = is_highmem_idx(j) ? realsize : freesize;
+		zone->managed_pages = is_highmem(zone) ? realsize : freesize;
 #ifdef CONFIG_NUMA
 		zone->node = nid;
 		zone->min_unmapped_pages = (freesize*sysctl_min_unmapped_ratio)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index dcb4707..30c34dc 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3074,7 +3074,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 			 * has a highmem zone, force kswapd to reclaim from
 			 * it to relieve lowmem pressure.
 			 */
-			if (buffer_heads_over_limit && is_highmem_idx(i)) {
+			if (buffer_heads_over_limit && is_highmem(zone)) {
 				end_zone = i;
 				break;
 			}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
