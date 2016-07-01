Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1E6828E1
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 11:42:26 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id a2so84157868lfe.0
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 08:42:26 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id a133si1263971wmh.127.2016.07.01.08.42.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Jul 2016 08:42:24 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id D4D4298EF0
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 15:42:23 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 26/31] mm, page_alloc: remove fair zone allocation policy
Date: Fri,  1 Jul 2016 16:37:41 +0100
Message-Id: <1467387466-10022-27-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
References: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The fair zone allocation policy interleaves allocation requests between
zones to avoid an age inversion problem whereby new pages are reclaimed to
balance a zone.  Reclaim is now node-based so this should no longer be an
issue and the fair zone allocation policy is not free.  This patch removes
it.

Link: http://lkml.kernel.org/r/1466518566-30034-25-git-send-email-mgorman@techsingularity.net
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@surriel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/mmzone.h |  5 ----
 mm/internal.h          |  1 -
 mm/page_alloc.c        | 75 +-------------------------------------------------
 mm/vmstat.c            |  4 +--
 4 files changed, 2 insertions(+), 83 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index bb6902b73d16..facee6b83440 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -110,7 +110,6 @@ struct zone_padding {
 enum zone_stat_item {
 	/* First 128 byte cacheline (assuming 64 bit words) */
 	NR_FREE_PAGES,
-	NR_ALLOC_BATCH,
 	NR_ZONE_LRU_BASE, /* Used only for compaction and reclaim retry */
 	NR_ZONE_LRU_ANON = NR_ZONE_LRU_BASE,
 	NR_ZONE_LRU_FILE,
@@ -515,10 +514,6 @@ struct zone {
 	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
 } ____cacheline_internodealigned_in_smp;
 
-enum zone_flags {
-	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
-};
-
 enum pgdat_flags {
 	PGDAT_CONGESTED,		/* zone has many dirty pages backed by
 					 * a congested BDI
diff --git a/mm/internal.h b/mm/internal.h
index 1e21b2d3838d..28932cd6a195 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -467,7 +467,6 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
 #define ALLOC_CMA		0x80 /* allow allocations from CMA areas */
-#define ALLOC_FAIR		0x100 /* fair zone allocation */
 
 enum ttu_flags;
 struct tlbflush_unmap_batch;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index eb31f114d0d8..d4815a30965b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2630,7 +2630,6 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 			else
 				page = list_first_entry(list, struct page, lru);
 
-			__dec_zone_state(zone, NR_ALLOC_BATCH);
 			list_del(&page->lru);
 			pcp->count--;
 
@@ -2656,15 +2655,10 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
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
@@ -2875,40 +2869,18 @@ bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
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
@@ -2919,10 +2891,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
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
@@ -2937,23 +2905,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
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
@@ -3024,23 +2975,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
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
 
@@ -3789,7 +3723,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 {
 	struct page *page;
 	unsigned int cpuset_mems_cookie;
-	unsigned int alloc_flags = ALLOC_WMARK_LOW|ALLOC_FAIR;
+	unsigned int alloc_flags = ALLOC_WMARK_LOW;
 	gfp_t alloc_mask = gfp_mask; /* The gfp_t that was actually used for allocation */
 	struct alloc_context ac = {
 		.high_zoneidx = gfp_zone(gfp_mask),
@@ -6001,9 +5935,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		zone_seqlock_init(zone);
 		zone_pcp_init(zone);
 
-		/* For bootup, initialized properly in watermark setup */
-		mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);
-
 		if (!size)
 			continue;
 
@@ -6856,10 +6787,6 @@ static void __setup_per_zone_wmarks(void)
 		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + tmp;
 		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + tmp * 2;
 
-		__mod_zone_page_state(zone, NR_ALLOC_BATCH,
-			high_wmark_pages(zone) - low_wmark_pages(zone) -
-			atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
-
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index e544d7e7d8f0..905ea9ae2d5a 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -908,7 +908,6 @@ int fragmentation_index(struct zone *zone, unsigned int order)
 const char * const vmstat_text[] = {
 	/* enum zone_stat_item countes */
 	"nr_free_pages",
-	"nr_alloc_batch",
 	"nr_zone_anon_lru",
 	"nr_zone_file_lru",
 	"nr_zone_write_pending",
@@ -1619,10 +1618,9 @@ int vmstat_refresh(struct ctl_table *table, int write,
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
