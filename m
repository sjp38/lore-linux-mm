Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 770526B0279
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 07:24:02 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id n3so58431687wmn.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 04:24:02 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id k74si15192501wmc.97.2016.04.06.04.24.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 04:24:01 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 1A7751C1CE0
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 12:24:01 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 24/27] mm, page_alloc: Remove fair zone allocation policy
Date: Wed,  6 Apr 2016 12:22:13 +0100
Message-Id: <1459941736-3633-25-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1459941736-3633-23-git-send-email-mgorman@techsingularity.net>
References: <1459941736-3633-23-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The fair zone allocation policy interleaves allocation requests between
zones to avoid an age inversion problem whereby new pages are reclaimed
to balance a zone. Reclaim is now node-based so this should no longer be
an issue and the fair zone allocation policy is not free. This patch
removes it.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mmzone.h |  2 --
 mm/internal.h          |  1 -
 mm/page_alloc.c        | 76 +-------------------------------------------------
 mm/vmstat.c            |  1 -
 4 files changed, 1 insertion(+), 79 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 8c4aa4e98783..258d4a11b062 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -117,7 +117,6 @@ struct zone_padding {
 enum zone_stat_item {
 	/* First 128 byte cacheline (assuming 64 bit words) */
 	NR_FREE_PAGES,
-	NR_ALLOC_BATCH,
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
 	NR_SLAB_RECLAIMABLE,
 	NR_SLAB_UNRECLAIMABLE,
@@ -515,7 +514,6 @@ struct zone {
 
 enum zone_flags {
 	ZONE_OOM_LOCKED,		/* zone is in OOM killer zonelist */
-	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
 };
 
 enum pgdat_flags {
diff --git a/mm/internal.h b/mm/internal.h
index 5417545fd86e..8726c5acddc7 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -460,7 +460,6 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
 #define ALLOC_CMA		0x80 /* allow allocations from CMA areas */
-#define ALLOC_FAIR		0x100 /* fair zone allocation */
 
 enum ttu_flags;
 struct tlbflush_unmap_batch;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 46c6a76cacb6..54cfe26dcc66 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2399,11 +2399,6 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 					  get_pcppage_migratetype(page));
 	}
 
-	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
-	if (atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]) <= 0 &&
-	    !test_bit(ZONE_FAIR_DEPLETED, &zone->flags))
-		set_bit(ZONE_FAIR_DEPLETED, &zone->flags);
-
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(preferred_zone, zone, gfp_flags);
 	local_irq_restore(flags);
@@ -2588,40 +2583,18 @@ bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
 }
 
 #ifdef CONFIG_NUMA
-static bool zone_local(struct zone *local_zone, struct zone *zone)
-{
-	return local_zone->node == zone->node;
-}
-
 static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 {
 	return node_distance(zone_to_nid(local_zone), zone_to_nid(zone)) <
 				RECLAIM_DISTANCE;
 }
 #else	/* CONFIG_NUMA */
-static bool zone_local(struct zone *local_zone, struct zone *zone)
-{
-	return true;
-}
-
 static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 {
 	return true;
 }
 #endif	/* CONFIG_NUMA */
 
-static void reset_alloc_batches(struct zone *preferred_zone)
-{
-	struct zone *zone = preferred_zone->zone_pgdat->node_zones;
-
-	do {
-		mod_zone_page_state(zone, NR_ALLOC_BATCH,
-			high_wmark_pages(zone) - low_wmark_pages(zone) -
-			atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
-		clear_bit(ZONE_FAIR_DEPLETED, &zone->flags);
-	} while (zone++ != preferred_zone);
-}
-
 /*
  * get_page_from_freelist goes through the zonelist trying to allocate
  * a page.
@@ -2634,11 +2607,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	struct zoneref *z;
 	struct page *page = NULL;
 	struct zone *zone;
-	int nr_fair_skipped = 0;
-	bool zonelist_rescan;
-
-zonelist_scan:
-	zonelist_rescan = false;
 
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
@@ -2653,20 +2621,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 			!cpuset_zone_allowed(zone, gfp_mask))
 				continue;
 		/*
-		 * Distribute pages in proportion to the individual
-		 * zone size to ensure fair page aging.  The zone a
-		 * page was allocated in should have no effect on the
-		 * time the page has in memory before being reclaimed.
-		 */
-		if (alloc_flags & ALLOC_FAIR) {
-			if (!zone_local(ac->preferred_zone, zone))
-				break;
-			if (test_bit(ZONE_FAIR_DEPLETED, &zone->flags)) {
-				nr_fair_skipped++;
-				continue;
-			}
-		}
-		/*
 		 * When allocating a page cache page for writing, we
 		 * want to get it from a node that is within its dirty
 		 * limit, such that no single node holds more than its
@@ -2738,27 +2692,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		}
 	}
 
-	/*
-	 * The first pass makes sure allocations are spread fairly within the
-	 * local node.  However, the local node might have free pages left
-	 * after the fairness batches are exhausted, and remote zones haven't
-	 * even been considered yet.  Try once more without fairness, and
-	 * include remote zones now, before entering the slowpath and waking
-	 * kswapd: prefer spilling to a remote zone over swapping locally.
-	 */
-	if (alloc_flags & ALLOC_FAIR) {
-		alloc_flags &= ~ALLOC_FAIR;
-		if (nr_fair_skipped) {
-			zonelist_rescan = true;
-			reset_alloc_batches(ac->preferred_zone);
-		}
-		if (nr_online_nodes > 1)
-			zonelist_rescan = true;
-	}
-
-	if (zonelist_rescan)
-		goto zonelist_scan;
-
 	return NULL;
 }
 
@@ -3312,7 +3245,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	struct zoneref *preferred_zoneref;
 	struct page *page = NULL;
 	unsigned int cpuset_mems_cookie;
-	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
+	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET;
 	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
 	struct alloc_context ac = {
 		.high_zoneidx = gfp_zone(gfp_mask),
@@ -5530,9 +5463,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		zone_seqlock_init(zone);
 		zone_pcp_init(zone);
 
-		/* For bootup, initialized properly in watermark setup */
-		mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);
-
 		if (!size)
 			continue;
 
@@ -6377,10 +6307,6 @@ static void __setup_per_zone_wmarks(void)
 		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + tmp;
 		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + tmp * 2;
 
-		__mod_zone_page_state(zone, NR_ALLOC_BATCH,
-			high_wmark_pages(zone) - low_wmark_pages(zone) -
-			atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
-
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 45ecff0f9f9f..2de1f3790548 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -937,7 +937,6 @@ int fragmentation_index(struct zone *zone, unsigned int order)
 const char * const vmstat_text[] = {
 	/* enum zone_stat_item countes */
 	"nr_free_pages",
-	"nr_alloc_batch",
 	"nr_mlock",
 	"nr_slab_reclaimable",
 	"nr_slab_unreclaimable",
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
