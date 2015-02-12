Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9290B82905
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 02:30:28 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id rd3so2869220pab.4
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 23:30:28 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id vk9si3817729pbc.206.2015.02.11.23.30.13
        for <linux-mm@kvack.org>;
        Wed, 11 Feb 2015 23:30:14 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC 11/16] mm/page_alloc: clean-up free_area_init_core()
Date: Thu, 12 Feb 2015 16:32:15 +0900
Message-Id: <1423726340-4084-12-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Some of initialization step can be done without any further information.
If ZONE_CMA is introduced, it should be handled specially in
free_area_init_core() since it has not enough zone information. But,
some of data structure for ZONE_CMA should be initialized in this function
so this patch moves up these steps for preparation of ZONE_CMA.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 416e036..6030525f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4845,11 +4845,19 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 	init_waitqueue_head(&pgdat->kswapd_wait);
 	init_waitqueue_head(&pgdat->pfmemalloc_wait);
 	pgdat_page_cgroup_init(pgdat);
+	set_pageblock_order();
 
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
 		unsigned long size, realsize, freesize, memmap_pages;
 
+		zone->name = zone_names[j];
+		spin_lock_init(&zone->lock);
+		spin_lock_init(&zone->lru_lock);
+		zone_seqlock_init(zone);
+		zone->zone_pgdat = pgdat;
+		lruvec_init(&zone->lruvec);
+
 		size = zone_spanned_pages_in_node(nid, j, node_start_pfn,
 						  node_end_pfn, zones_size);
 		realsize = freesize = size - zone_absent_pages_in_node(nid, j,
@@ -4902,21 +4910,14 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 						/ 100;
 		zone->min_slab_pages = (freesize * sysctl_min_slab_ratio) / 100;
 #endif
-		zone->name = zone_names[j];
-		spin_lock_init(&zone->lock);
-		spin_lock_init(&zone->lru_lock);
-		zone_seqlock_init(zone);
-		zone->zone_pgdat = pgdat;
 		zone_pcp_init(zone);
 
 		/* For bootup, initialized properly in watermark setup */
 		mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);
 
-		lruvec_init(&zone->lruvec);
 		if (!size)
 			continue;
 
-		set_pageblock_order();
 		setup_usemap(pgdat, zone, zone_start_pfn, size);
 		ret = init_currently_empty_zone(zone, zone_start_pfn,
 						size, MEMMAP_EARLY);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
