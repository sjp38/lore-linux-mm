Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 46E40900020
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:57:24 -0400 (EDT)
Received: by wigg3 with SMTP id g3so53418349wig.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:57:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d7si5325396wjn.85.2015.06.08.06.57.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:57:05 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 20/25] mm, page_alloc: Remove fair zone allocation policy
Date: Mon,  8 Jun 2015 14:56:26 +0100
Message-Id: <1433771791-30567-21-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The fair zone allocation policy interleaves allocation requests between
zones to avoid an age inversion problem whereby new pages are reclaimed
to balance a zone. Reclaim is now node-based so this should no longer be
an issue and the fair zone allocation policy is not free. This patch
removes it.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |  2 --
 mm/internal.h          |  1 -
 mm/page_alloc.c        | 69 +-------------------------------------------------
 mm/vmstat.c            |  1 -
 4 files changed, 1 insertion(+), 72 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 34050b012409..c551f70951fa 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -114,7 +114,6 @@ struct zone_padding {
 enum zone_stat_item {
 	/* First 128 byte cacheline (assuming 64 bit words) */
 	NR_FREE_PAGES,
-	NR_ALLOC_BATCH,
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
 	NR_SLAB_RECLAIMABLE,
 	NR_SLAB_UNRECLAIMABLE,
@@ -521,7 +520,6 @@ struct zone {
 enum zone_flags {
 	ZONE_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
 	ZONE_OOM_LOCKED,		/* zone is in OOM killer zonelist */
-	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
 };
 
 enum pgdat_flags {
diff --git a/mm/internal.h b/mm/internal.h
index 2e4cee6a8739..a24c4a50c33f 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -429,6 +429,5 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
 #define ALLOC_CMA		0x80 /* allow allocations from CMA areas */
-#define ALLOC_FAIR		0x100 /* fair zone allocation */
 
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2ca5da938972..6b3a78420a5e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1698,11 +1698,6 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 					  get_freepage_migratetype(page));
 	}
 
-	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
-	if (atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]) <= 0 &&
-	    !test_bit(ZONE_FAIR_DEPLETED, &zone->flags))
-		set_bit(ZONE_FAIR_DEPLETED, &zone->flags);
-
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(preferred_zone, zone, gfp_flags);
 	local_irq_restore(flags);
@@ -1967,11 +1962,6 @@ static void zlc_clear_zones_full(struct zonelist *zonelist)
 	bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
 }
 
-static bool zone_local(struct zone *local_zone, struct zone *zone)
-{
-	return local_zone->node == zone->node;
-}
-
 static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 {
 	return node_distance(zone_to_nid(local_zone), zone_to_nid(zone)) <
@@ -1999,11 +1989,6 @@ static void zlc_clear_zones_full(struct zonelist *zonelist)
 {
 }
 
-static bool zone_local(struct zone *local_zone, struct zone *zone)
-{
-	return true;
-}
-
 static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 {
 	return true;
@@ -2011,18 +1996,6 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 
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
@@ -2040,7 +2013,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 	bool consider_zone_dirty = (alloc_flags & ALLOC_WMARK_LOW) &&
 				(gfp_mask & __GFP_WRITE);
-	int nr_fair_skipped = 0;
 	bool zonelist_rescan;
 	struct pglist_data *last_pgdat = NULL;
 
@@ -2063,20 +2035,6 @@ zonelist_scan:
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
 		 * want to get it from a zone that is within its dirty
 		 * limit, such that no single zone holds more than its
@@ -2186,24 +2144,6 @@ this_zone_full:
 			zlc_mark_zone_full(zonelist, z);
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
 	if (unlikely(IS_ENABLED(CONFIG_NUMA) && zlc_active)) {
 		/* Disable zlc cache for second zonelist scan */
 		zlc_active = 0;
@@ -2808,7 +2748,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	struct zoneref *preferred_zoneref;
 	struct page *page = NULL;
 	unsigned int cpuset_mems_cookie;
-	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
+	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET;
 	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
 	struct alloc_context ac = {
 		.high_zoneidx = gfp_zone(gfp_mask),
@@ -4950,9 +4890,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone_seqlock_init(zone);
 		zone_pcp_init(zone);
 
-		/* For bootup, initialized properly in watermark setup */
-		mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);
-
 		if (!size)
 			continue;
 
@@ -5751,10 +5688,6 @@ static void __setup_per_zone_wmarks(void)
 		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + (tmp >> 2);
 		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + (tmp >> 1);
 
-		__mod_zone_page_state(zone, NR_ALLOC_BATCH,
-			high_wmark_pages(zone) - low_wmark_pages(zone) -
-			atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
-
 		setup_zone_migrate_reserve(zone);
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
diff --git a/mm/vmstat.c b/mm/vmstat.c
index d805df47d3ae..c3fdd88961ff 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -893,7 +893,6 @@ int fragmentation_index(struct zone *zone, unsigned int order)
 const char * const vmstat_text[] = {
 	/* enum zone_stat_item countes */
 	"nr_free_pages",
-	"nr_alloc_batch",
 	"nr_mlock",
 	"nr_slab_reclaimable",
 	"nr_slab_unreclaimable",
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
