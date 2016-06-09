Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 22079828EA
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 14:09:01 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id rs7so18618897lbb.2
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 11:09:01 -0700 (PDT)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id fc7si9201817wjb.96.2016.06.09.11.08.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 11:08:59 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 6A3CC1C1ADF
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 19:08:59 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 24/27] mm, page_alloc: Remove fair zone allocation policy
Date: Thu,  9 Jun 2016 19:04:40 +0100
Message-Id: <1465495483-11855-25-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
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
 mm/page_alloc.c        | 75 +-------------------------------------------------
 mm/vmstat.c            |  4 +--
 4 files changed, 2 insertions(+), 80 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d826d203185e..347a13a62d55 100644
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
@@ -511,7 +510,6 @@ struct zone {
 
 enum zone_flags {
 	ZONE_OOM_LOCKED,		/* zone is in OOM killer zonelist */
-	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
 };
 
 enum pgdat_flags {
diff --git a/mm/internal.h b/mm/internal.h
index 5231344a9e52..51505914d7c9 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -468,7 +468,6 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
 #define ALLOC_CMA		0x80 /* allow allocations from CMA areas */
-#define ALLOC_FAIR		0x100 /* fair zone allocation */
 
 enum ttu_flags;
 struct tlbflush_unmap_batch;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a249128999a8..17fa3f361f01 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2592,7 +2592,6 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 			else
 				page = list_first_entry(list, struct page, lru);
 
-			__dec_zone_state(zone, NR_ALLOC_BATCH);
 			list_del(&page->lru);
 			pcp->count--;
 
@@ -2618,15 +2617,10 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
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
@@ -2837,40 +2831,18 @@ bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
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
@@ -2881,10 +2853,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
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
@@ -2899,23 +2867,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
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
@@ -2986,23 +2937,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
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
-		z = ac->preferred_zoneref;
-		goto zonelist_scan;
-	}
-
 	return NULL;
 }
 
@@ -3758,7 +3692,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 {
 	struct page *page;
 	unsigned int cpuset_mems_cookie;
-	unsigned int alloc_flags = ALLOC_WMARK_LOW|ALLOC_FAIR;
+	unsigned int alloc_flags = ALLOC_WMARK_LOW;
 	gfp_t alloc_mask = gfp_mask; /* The gfp_t that was actually used for allocation */
 	struct alloc_context ac = {
 		.high_zoneidx = gfp_zone(gfp_mask),
@@ -5959,9 +5893,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		zone_seqlock_init(zone);
 		zone_pcp_init(zone);
 
-		/* For bootup, initialized properly in watermark setup */
-		mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);
-
 		if (!size)
 			continue;
 
@@ -6814,10 +6745,6 @@ static void __setup_per_zone_wmarks(void)
 		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + tmp;
 		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + tmp * 2;
 
-		__mod_zone_page_state(zone, NR_ALLOC_BATCH,
-			high_wmark_pages(zone) - low_wmark_pages(zone) -
-			atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
-
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 26e9873be7a2..dd60fa3ca66b 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -920,7 +920,6 @@ int fragmentation_index(struct zone *zone, unsigned int order)
 const char * const vmstat_text[] = {
 	/* enum zone_stat_item countes */
 	"nr_free_pages",
-	"nr_alloc_batch",
 	"nr_mlock",
 	"nr_slab_reclaimable",
 	"nr_slab_unreclaimable",
@@ -1624,10 +1623,9 @@ int vmstat_refresh(struct ctl_table *table, int write,
 		val = atomic_long_read(&vm_zone_stat[i]);
 		if (val < 0) {
 			switch (i) {
-			case NR_ALLOC_BATCH:
 			case NR_PAGES_SCANNED:
 				/*
-				 * These are often seen to go negative in
+				 * This is often seen to go negative in
 				 * recent kernels, but not to go permanently
 				 * negative.  Whilst it would be nicer not to
 				 * have exceptions, rooting them out would be
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
