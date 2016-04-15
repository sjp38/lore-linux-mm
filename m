Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D059882F66
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:17:50 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a125so13327098wmd.0
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:17:50 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id ld8si49515252wjc.77.2016.04.15.02.17.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 02:17:49 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 4E2841DC2A3
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:17:49 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 24/27] mm, page_alloc: Remove fair zone allocation policy
Date: Fri, 15 Apr 2016 10:13:30 +0100
Message-Id: <1460711613-2761-25-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460711613-2761-1-git-send-email-mgorman@techsingularity.net>
References: <1460711613-2761-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The fair zone allocation policy interleaves allocation requests between
zones to avoid an age inversion problem whereby new pages are reclaimed
to balance a zone. Reclaim is now node-based so this should no longer be
an issue and the fair zone allocation policy is not free. This patch
removes it.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mmzone.h |  2 --
 mm/internal.h          |  1 -
 mm/page_alloc.c        | 74 +-------------------------------------------------
 mm/vmstat.c            |  1 -
 4 files changed, 1 insertion(+), 77 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 53dd1a6aa444..4d183ac329ed 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -110,7 +110,6 @@ struct zone_padding {
 enum zone_stat_item {
 	/* First 128 byte cacheline (assuming 64 bit words) */
 	NR_FREE_PAGES,
-	NR_ALLOC_BATCH,
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
 	NR_SLAB_RECLAIMABLE,
 	NR_SLAB_UNRECLAIMABLE,
@@ -508,7 +507,6 @@ struct zone {
 
 enum zone_flags {
 	ZONE_OOM_LOCKED,		/* zone is in OOM killer zonelist */
-	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
 };
 
 enum pgdat_flags {
diff --git a/mm/internal.h b/mm/internal.h
index ec08fdfc04fe..7f9c6fba9c35 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -461,7 +461,6 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
 #define ALLOC_CMA		0x80 /* allow allocations from CMA areas */
-#define ALLOC_FAIR		0x100 /* fair zone allocation */
 
 enum ttu_flags;
 struct tlbflush_unmap_batch;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fa6534bc4e98..125f344ff105 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2629,7 +2629,6 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 				page = list_first_entry(list, struct page, lru);
 		} while (page && check_new_pcp(page));
 
-		__dec_zone_state(zone, NR_ALLOC_BATCH);
 		list_del(&page->lru);
 		pcp->count--;
 	} else {
@@ -2653,15 +2652,10 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 		spin_unlock(&zone->lock);
 		if (!page)
 			goto failed;
-		__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
 		__mod_zone_freepage_state(zone, -(1 << order),
 					  get_pcppage_migratetype(page));
 	}
 
-	if (atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]) <= 0 &&
-	    !test_bit(ZONE_FAIR_DEPLETED, &zone->flags))
-		set_bit(ZONE_FAIR_DEPLETED, &zone->flags);
-
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(preferred_zone, zone, gfp_flags);
 	local_irq_restore(flags);
@@ -2873,40 +2867,18 @@ bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
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
@@ -2917,10 +2889,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 {
 	struct zoneref *z = ac->preferred_zoneref;
 	struct zone *zone;
-	bool fair_skipped = false;
-	bool apply_fair = (alloc_flags & ALLOC_FAIR);
-
-zonelist_scan:
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also __cpuset_node_allowed() comment in kernel/cpuset.c.
@@ -2935,23 +2903,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 			!__cpuset_zone_allowed(zone, gfp_mask))
 				continue;
 		/*
-		 * Distribute pages in proportion to the individual
-		 * zone size to ensure fair page aging.  The zone a
-		 * page was allocated in should have no effect on the
-		 * time the page has in memory before being reclaimed.
-		 */
-		if (apply_fair) {
-			if (test_bit(ZONE_FAIR_DEPLETED, &zone->flags)) {
-				fair_skipped = true;
-				continue;
-			}
-			if (!zone_local(ac->preferred_zoneref->zone, zone)) {
-				if (fair_skipped)
-					goto reset_fair;
-				apply_fair = false;
-			}
-		}
-		/*
 		 * When allocating a page cache page for writing, we
 		 * want to get it from a node that is within its dirty
 		 * limit, such that no single node holds more than its
@@ -3022,22 +2973,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
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
-	if (fair_skipped) {
-reset_fair:
-		apply_fair = false;
-		fair_skipped = false;
-		reset_alloc_batches(ac->preferred_zoneref->zone);
-		goto zonelist_scan;
-	}
-
 	return NULL;
 }
 
@@ -3582,7 +3517,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 {
 	struct page *page;
 	unsigned int cpuset_mems_cookie;
-	unsigned int alloc_flags = ALLOC_WMARK_LOW|ALLOC_FAIR;
+	unsigned int alloc_flags = ALLOC_WMARK_LOW;
 	gfp_t alloc_mask = gfp_mask; /* The gfp_t that was actually used for allocation */
 	struct alloc_context ac = {
 		.high_zoneidx = gfp_zone(gfp_mask),
@@ -5791,9 +5726,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		zone_seqlock_init(zone);
 		zone_pcp_init(zone);
 
-		/* For bootup, initialized properly in watermark setup */
-		mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);
-
 		if (!size)
 			continue;
 
@@ -6638,10 +6570,6 @@ static void __setup_per_zone_wmarks(void)
 		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + tmp;
 		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + tmp * 2;
 
-		__mod_zone_page_state(zone, NR_ALLOC_BATCH,
-			high_wmark_pages(zone) - low_wmark_pages(zone) -
-			atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
-
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index c42ab4d9fa2b..7ae67218d675 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -914,7 +914,6 @@ int fragmentation_index(struct zone *zone, unsigned int order)
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
