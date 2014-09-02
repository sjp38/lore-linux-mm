Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4E1176B0036
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 10:28:01 -0400 (EDT)
Received: by mail-lb0-f180.google.com with SMTP id w7so7554714lbi.25
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 07:28:00 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id pt1si5106354lbc.117.2014.09.02.07.27.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 02 Sep 2014 07:27:59 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: clean up zone flags
Date: Tue,  2 Sep 2014 10:27:54 -0400
Message-Id: <1409668074-16875-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Page reclaim tests zone_is_reclaim_dirty(), but the site that actually
sets this state does zone_set_flag(zone, ZONE_TAIL_LRU_DIRTY), sending
the reader through layers indirection just to track down a simple bit.

Remove all zone flag wrappers and just use bitops against zone->flags
directly.  It's just as readable and the lines are barely any longer.

Also rename ZONE_TAIL_LRU_DIRTY to ZONE_DIRTY to match ZONE_WRITEBACK,
and remove the zone_flags_t typedef.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mmzone.h | 51 +++-----------------------------------------------
 mm/backing-dev.c       |  2 +-
 mm/oom_kill.c          |  6 +++---
 mm/page_alloc.c        |  8 ++++----
 mm/vmscan.c            | 28 +++++++++++++--------------
 5 files changed, 25 insertions(+), 70 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 318df7051850..48bf12ef6620 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -521,13 +521,13 @@ struct zone {
 	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
 } ____cacheline_internodealigned_in_smp;
 
-typedef enum {
+enum zone_flags {
 	ZONE_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
 	ZONE_OOM_LOCKED,		/* zone is in OOM killer zonelist */
 	ZONE_CONGESTED,			/* zone has many dirty pages backed by
 					 * a congested BDI
 					 */
-	ZONE_TAIL_LRU_DIRTY,		/* reclaim scanning has recently found
+	ZONE_DIRTY,			/* reclaim scanning has recently found
 					 * many dirty file pages at the tail
 					 * of the LRU.
 					 */
@@ -535,52 +535,7 @@ typedef enum {
 					 * many pages under writeback
 					 */
 	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
-} zone_flags_t;
-
-static inline void zone_set_flag(struct zone *zone, zone_flags_t flag)
-{
-	set_bit(flag, &zone->flags);
-}
-
-static inline int zone_test_and_set_flag(struct zone *zone, zone_flags_t flag)
-{
-	return test_and_set_bit(flag, &zone->flags);
-}
-
-static inline void zone_clear_flag(struct zone *zone, zone_flags_t flag)
-{
-	clear_bit(flag, &zone->flags);
-}
-
-static inline int zone_is_reclaim_congested(const struct zone *zone)
-{
-	return test_bit(ZONE_CONGESTED, &zone->flags);
-}
-
-static inline int zone_is_reclaim_dirty(const struct zone *zone)
-{
-	return test_bit(ZONE_TAIL_LRU_DIRTY, &zone->flags);
-}
-
-static inline int zone_is_reclaim_writeback(const struct zone *zone)
-{
-	return test_bit(ZONE_WRITEBACK, &zone->flags);
-}
-
-static inline int zone_is_reclaim_locked(const struct zone *zone)
-{
-	return test_bit(ZONE_RECLAIM_LOCKED, &zone->flags);
-}
-
-static inline int zone_is_fair_depleted(const struct zone *zone)
-{
-	return test_bit(ZONE_FAIR_DEPLETED, &zone->flags);
-}
-
-static inline int zone_is_oom_locked(const struct zone *zone)
-{
-	return test_bit(ZONE_OOM_LOCKED, &zone->flags);
-}
+};
 
 static inline unsigned long zone_end_pfn(const struct zone *zone)
 {
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 1706cbbdf5f0..d7a9051a6db5 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -631,7 +631,7 @@ long wait_iff_congested(struct zone *zone, int sync, long timeout)
 	 * of sleeping on the congestion queue
 	 */
 	if (atomic_read(&nr_bdi_congested[sync]) == 0 ||
-			!zone_is_reclaim_congested(zone)) {
+	    test_bit(ZONE_CONGESTED, &zone->flags)) {
 		cond_resched();
 
 		/* In case we scheduled, work out time remaining */
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1e11df8fa7ec..bbf405a3a18f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -565,7 +565,7 @@ bool oom_zonelist_trylock(struct zonelist *zonelist, gfp_t gfp_mask)
 
 	spin_lock(&zone_scan_lock);
 	for_each_zone_zonelist(zone, z, zonelist, gfp_zone(gfp_mask))
-		if (zone_is_oom_locked(zone)) {
+		if (test_bit(ZONE_OOM_LOCKED, &zone->flags)) {
 			ret = false;
 			goto out;
 		}
@@ -575,7 +575,7 @@ bool oom_zonelist_trylock(struct zonelist *zonelist, gfp_t gfp_mask)
 	 * call to oom_zonelist_trylock() doesn't succeed when it shouldn't.
 	 */
 	for_each_zone_zonelist(zone, z, zonelist, gfp_zone(gfp_mask))
-		zone_set_flag(zone, ZONE_OOM_LOCKED);
+		set_bit(ZONE_OOM_LOCKED, &zone->flags);
 
 out:
 	spin_unlock(&zone_scan_lock);
@@ -594,7 +594,7 @@ void oom_zonelist_unlock(struct zonelist *zonelist, gfp_t gfp_mask)
 
 	spin_lock(&zone_scan_lock);
 	for_each_zone_zonelist(zone, z, zonelist, gfp_zone(gfp_mask))
-		zone_clear_flag(zone, ZONE_OOM_LOCKED);
+		clear_bit(ZONE_OOM_LOCKED, &zone->flags);
 	spin_unlock(&zone_scan_lock);
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 18cee0d4c8a2..f0eb97de6cad 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1613,8 +1613,8 @@ again:
 
 	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
 	if (zone_page_state(zone, NR_ALLOC_BATCH) == 0 &&
-	    !zone_is_fair_depleted(zone))
-		zone_set_flag(zone, ZONE_FAIR_DEPLETED);
+	    !test_bit(ZONE_FAIR_DEPLETED, &zone->flags))
+		set_bit(ZONE_FAIR_DEPLETED, &zone->flags);
 
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(preferred_zone, zone, gfp_flags);
@@ -1934,7 +1934,7 @@ static void reset_alloc_batches(struct zone *preferred_zone)
 		mod_zone_page_state(zone, NR_ALLOC_BATCH,
 			high_wmark_pages(zone) - low_wmark_pages(zone) -
 			atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
-		zone_clear_flag(zone, ZONE_FAIR_DEPLETED);
+		clear_bit(ZONE_FAIR_DEPLETED, &zone->flags);
 	} while (zone++ != preferred_zone);
 }
 
@@ -1985,7 +1985,7 @@ zonelist_scan:
 		if (alloc_flags & ALLOC_FAIR) {
 			if (!zone_local(preferred_zone, zone))
 				break;
-			if (zone_is_fair_depleted(zone)) {
+			if (test_bit(ZONE_FAIR_DEPLETED, &zone->flags)) {
 				nr_fair_skipped++;
 				continue;
 			}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2836b5373b2e..590a92bec6a4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -920,7 +920,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			/* Case 1 above */
 			if (current_is_kswapd() &&
 			    PageReclaim(page) &&
-			    zone_is_reclaim_writeback(zone)) {
+			    test_bit(ZONE_WRITEBACK, &zone->flags)) {
 				nr_immediate++;
 				goto keep_locked;
 
@@ -1002,7 +1002,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			 */
 			if (page_is_file_cache(page) &&
 					(!current_is_kswapd() ||
-					 !zone_is_reclaim_dirty(zone))) {
+					 test_bit(ZONE_DIRTY, &zone->flags))) {
 				/*
 				 * Immediately reclaim when written back.
 				 * Similar in principal to deactivate_page()
@@ -1563,7 +1563,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	 * are encountered in the nr_immediate check below.
 	 */
 	if (nr_writeback && nr_writeback == nr_taken)
-		zone_set_flag(zone, ZONE_WRITEBACK);
+		set_bit(ZONE_WRITEBACK, &zone->flags);
 
 	/*
 	 * memcg will stall in page writeback so only consider forcibly
@@ -1575,16 +1575,16 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		 * backed by a congested BDI and wait_iff_congested will stall.
 		 */
 		if (nr_dirty && nr_dirty == nr_congested)
-			zone_set_flag(zone, ZONE_CONGESTED);
+			set_bit(ZONE_CONGESTED, &zone->flags);
 
 		/*
 		 * If dirty pages are scanned that are not queued for IO, it
 		 * implies that flushers are not keeping up. In this case, flag
-		 * the zone ZONE_TAIL_LRU_DIRTY and kswapd will start writing
-		 * pages from reclaim context.
+		 * the zone ZONE_DIRTY and kswapd will start writing pages from
+		 * reclaim context.
 		 */
 		if (nr_unqueued_dirty == nr_taken)
-			zone_set_flag(zone, ZONE_TAIL_LRU_DIRTY);
+			set_bit(ZONE_DIRTY, &zone->flags);
 
 		/*
 		 * If kswapd scans pages marked marked for immediate
@@ -2978,7 +2978,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
 	/* Account for the number of pages attempted to reclaim */
 	*nr_attempted += sc->nr_to_reclaim;
 
-	zone_clear_flag(zone, ZONE_WRITEBACK);
+	clear_bit(ZONE_WRITEBACK, &zone->flags);
 
 	/*
 	 * If a zone reaches its high watermark, consider it to be no longer
@@ -2988,8 +2988,8 @@ static bool kswapd_shrink_zone(struct zone *zone,
 	 */
 	if (zone_reclaimable(zone) &&
 	    zone_balanced(zone, testorder, 0, classzone_idx)) {
-		zone_clear_flag(zone, ZONE_CONGESTED);
-		zone_clear_flag(zone, ZONE_TAIL_LRU_DIRTY);
+		clear_bit(ZONE_CONGESTED, &zone->flags);
+		clear_bit(ZONE_DIRTY, &zone->flags);
 	}
 
 	return sc->nr_scanned >= sc->nr_to_reclaim;
@@ -3080,8 +3080,8 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 				 * If balanced, clear the dirty and congested
 				 * flags
 				 */
-				zone_clear_flag(zone, ZONE_CONGESTED);
-				zone_clear_flag(zone, ZONE_TAIL_LRU_DIRTY);
+				clear_bit(ZONE_CONGESTED, &zone->flags);
+				clear_bit(ZONE_DIRTY, &zone->flags);
 			}
 		}
 
@@ -3708,11 +3708,11 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	if (node_state(node_id, N_CPU) && node_id != numa_node_id())
 		return ZONE_RECLAIM_NOSCAN;
 
-	if (zone_test_and_set_flag(zone, ZONE_RECLAIM_LOCKED))
+	if (test_and_set_bit(ZONE_RECLAIM_LOCKED, &zone->flags))
 		return ZONE_RECLAIM_NOSCAN;
 
 	ret = __zone_reclaim(zone, gfp_mask, order);
-	zone_clear_flag(zone, ZONE_RECLAIM_LOCKED);
+	clear_bit(ZONE_RECLAIM_LOCKED, &zone->flags);
 
 	if (!ret)
 		count_vm_event(PGSCAN_ZONE_RECLAIM_FAILED);
-- 
2.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
