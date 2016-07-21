Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9DED26B025F
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 10:11:10 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id p126so179648302qke.0
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 07:11:10 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id m129si1695201vkh.158.2016.07.21.07.11.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jul 2016 07:11:04 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 484261C1F80
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 15:11:03 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 3/5] mm: Remove reclaim and compaction retry approximations
Date: Thu, 21 Jul 2016 15:10:59 +0100
Message-Id: <1469110261-7365-4-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1469110261-7365-1-git-send-email-mgorman@techsingularity.net>
References: <1469110261-7365-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

If per-zone LRU accounting is available then there is no point
approximating whether reclaim and compaction should retry based on pgdat
statistics. This is effectively a revert of "mm, vmstat: remove zone and
node double accounting by approximating retries" with the difference that
inactive/active stats are still available. This preserves the history of
why the approximation was retried and why it had to be reverted to handle
OOM kills on 32-bit systems.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mmzone.h |  1 +
 include/linux/swap.h   |  1 +
 mm/compaction.c        | 20 +-------------------
 mm/migrate.c           |  2 ++
 mm/page-writeback.c    |  5 +++++
 mm/page_alloc.c        | 49 ++++++++++---------------------------------------
 mm/vmscan.c            | 18 ++++++++++++++++++
 mm/vmstat.c            |  1 +
 8 files changed, 39 insertions(+), 58 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 72625b04e9ba..f2e4e90621ec 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -116,6 +116,7 @@ enum zone_stat_item {
 	NR_ZONE_INACTIVE_FILE,
 	NR_ZONE_ACTIVE_FILE,
 	NR_ZONE_UNEVICTABLE,
+	NR_ZONE_WRITE_PENDING,	/* Count of dirty, writeback and unstable pages */
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
 	NR_SLAB_RECLAIMABLE,
 	NR_SLAB_UNRECLAIMABLE,
diff --git a/include/linux/swap.h b/include/linux/swap.h
index cc753c639e3d..b17cc4830fa6 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -307,6 +307,7 @@ extern void lru_cache_add_active_or_unevictable(struct page *page,
 						struct vm_area_struct *vma);
 
 /* linux/mm/vmscan.c */
+extern unsigned long zone_reclaimable_pages(struct zone *zone);
 extern unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat);
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
diff --git a/mm/compaction.c b/mm/compaction.c
index cd93ea24c565..e5995f38d677 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1438,11 +1438,6 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
 {
 	struct zone *zone;
 	struct zoneref *z;
-	pg_data_t *last_pgdat = NULL;
-
-	/* Do not retry compaction for zone-constrained allocations */
-	if (ac->high_zoneidx < ZONE_NORMAL)
-		return false;
 
 	/*
 	 * Make sure at least one zone would pass __compaction_suitable if we continue
@@ -1453,27 +1448,14 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
 		unsigned long available;
 		enum compact_result compact_result;
 
-		if (last_pgdat == zone->zone_pgdat)
-			continue;
-
-		/*
-		 * This over-estimates the number of pages available for
-		 * reclaim/compaction but walking the LRU would take too
-		 * long. The consequences are that compaction may retry
-		 * longer than it should for a zone-constrained allocation
-		 * request.
-		 */
-		last_pgdat = zone->zone_pgdat;
-		available = pgdat_reclaimable_pages(zone->zone_pgdat) / order;
-
 		/*
 		 * Do not consider all the reclaimable memory because we do not
 		 * want to trash just for a single high order allocation which
 		 * is even not guaranteed to appear even if __compaction_suitable
 		 * is happy about the watermark check.
 		 */
+		available = zone_reclaimable_pages(zone) / order;
 		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
-		available = min(zone->managed_pages, available);
 		compact_result = __compaction_suitable(zone, order, alloc_flags,
 				ac_classzone_idx(ac), available);
 		if (compact_result != COMPACT_SKIPPED &&
diff --git a/mm/migrate.c b/mm/migrate.c
index ed2f85e61de1..ed0268268e93 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -513,7 +513,9 @@ int migrate_page_move_mapping(struct address_space *mapping,
 		}
 		if (dirty && mapping_cap_account_dirty(mapping)) {
 			__dec_node_state(oldzone->zone_pgdat, NR_FILE_DIRTY);
+			__dec_zone_state(oldzone, NR_ZONE_WRITE_PENDING);
 			__inc_node_state(newzone->zone_pgdat, NR_FILE_DIRTY);
+			__inc_zone_state(newzone, NR_ZONE_WRITE_PENDING);
 		}
 	}
 	local_irq_enable();
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index cfa78124c3c2..7e9061ec040b 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2462,6 +2462,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 
 		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_DIRTY);
 		__inc_node_page_state(page, NR_FILE_DIRTY);
+		__inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		__inc_node_page_state(page, NR_DIRTIED);
 		__inc_wb_stat(wb, WB_RECLAIMABLE);
 		__inc_wb_stat(wb, WB_DIRTIED);
@@ -2483,6 +2484,7 @@ void account_page_cleaned(struct page *page, struct address_space *mapping,
 	if (mapping_cap_account_dirty(mapping)) {
 		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_DIRTY);
 		dec_node_page_state(page, NR_FILE_DIRTY);
+		dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		dec_wb_stat(wb, WB_RECLAIMABLE);
 		task_io_account_cancelled_write(PAGE_SIZE);
 	}
@@ -2739,6 +2741,7 @@ int clear_page_dirty_for_io(struct page *page)
 		if (TestClearPageDirty(page)) {
 			mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_DIRTY);
 			dec_node_page_state(page, NR_FILE_DIRTY);
+			dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 			dec_wb_stat(wb, WB_RECLAIMABLE);
 			ret = 1;
 		}
@@ -2785,6 +2788,7 @@ int test_clear_page_writeback(struct page *page)
 	if (ret) {
 		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
 		dec_node_page_state(page, NR_WRITEBACK);
+		dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		inc_node_page_state(page, NR_WRITTEN);
 	}
 	unlock_page_memcg(page);
@@ -2839,6 +2843,7 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 	if (!ret) {
 		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
 		inc_node_page_state(page, NR_WRITEBACK);
+		inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 	}
 	unlock_page_memcg(page);
 	return ret;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b44c9a8d879a..afb254e22235 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3434,7 +3434,6 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 {
 	struct zone *zone;
 	struct zoneref *z;
-	pg_data_t *current_pgdat = NULL;
 
 	/*
 	 * Make sure we converge to OOM if we cannot make any progress
@@ -3444,15 +3443,6 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 		return false;
 
 	/*
-	 * Blindly retry lowmem allocation requests that are often ignored by
-	 * the OOM killer up to MAX_RECLAIM_RETRIES as we not have a reliable
-	 * and fast means of calculating reclaimable, dirty and writeback pages
-	 * in eligible zones.
-	 */
-	if (ac->high_zoneidx < ZONE_NORMAL)
-		goto out;
-
-	/*
 	 * Keep reclaiming pages while there is a chance this will lead somewhere.
 	 * If none of the target zones can satisfy our allocation request even
 	 * if all reclaimable pages are considered then we are screwed and have
@@ -3462,38 +3452,18 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 					ac->nodemask) {
 		unsigned long available;
 		unsigned long reclaimable;
-		int zid;
 
-		if (current_pgdat == zone->zone_pgdat)
-			continue;
-
-		current_pgdat = zone->zone_pgdat;
-		available = reclaimable = pgdat_reclaimable_pages(current_pgdat);
+		available = reclaimable = zone_reclaimable_pages(zone);
 		available -= DIV_ROUND_UP(no_progress_loops * available,
 					  MAX_RECLAIM_RETRIES);
-
-		/* Account for all free pages on eligible zones */
-		for (zid = 0; zid <= zone_idx(zone); zid++) {
-			struct zone *acct_zone = &current_pgdat->node_zones[zid];
-
-			available += zone_page_state_snapshot(acct_zone, NR_FREE_PAGES);
-		}
+		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
 
 		/*
 		 * Would the allocation succeed if we reclaimed the whole
-		 * available? This is approximate because there is no
-		 * accurate count of reclaimable pages per zone.
+		 * available?
 		 */
-		for (zid = 0; zid <= zone_idx(zone); zid++) {
-			struct zone *check_zone = &current_pgdat->node_zones[zid];
-			unsigned long estimate;
-
-			estimate = min(check_zone->managed_pages, available);
-			if (!__zone_watermark_ok(check_zone, order,
-					min_wmark_pages(check_zone), ac_classzone_idx(ac),
-					alloc_flags, estimate))
-				continue;
-
+		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
+				ac_classzone_idx(ac), alloc_flags, available)) {
 			/*
 			 * If we didn't make any progress and have a lot of
 			 * dirty + writeback pages then we should wait for
@@ -3503,16 +3473,15 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 			if (!did_some_progress) {
 				unsigned long write_pending;
 
-				write_pending =
-					node_page_state(current_pgdat, NR_WRITEBACK) +
-					node_page_state(current_pgdat, NR_FILE_DIRTY);
+				write_pending = zone_page_state_snapshot(zone,
+							NR_ZONE_WRITE_PENDING);
 
 				if (2 * write_pending > reclaimable) {
 					congestion_wait(BLK_RW_ASYNC, HZ/10);
 					return true;
 				}
 			}
-out:
+
 			/*
 			 * Memory allocation/reclaim might be called from a WQ
 			 * context and the current implementation of the WQ
@@ -4393,6 +4362,7 @@ void show_free_areas(unsigned int filter)
 			" active_file:%lukB"
 			" inactive_file:%lukB"
 			" unevictable:%lukB"
+			" writepending:%lukB"
 			" present:%lukB"
 			" managed:%lukB"
 			" mlocked:%lukB"
@@ -4415,6 +4385,7 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_ZONE_ACTIVE_FILE)),
 			K(zone_page_state(zone, NR_ZONE_INACTIVE_FILE)),
 			K(zone_page_state(zone, NR_ZONE_UNEVICTABLE)),
+			K(zone_page_state(zone, NR_ZONE_WRITE_PENDING)),
 			K(zone->present_pages),
 			K(zone->managed_pages),
 			K(zone_page_state(zone, NR_MLOCK)),
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 222d5403dd4b..134381a20099 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -194,6 +194,24 @@ static bool sane_reclaim(struct scan_control *sc)
 }
 #endif
 
+/*
+ * This misses isolated pages which are not accounted for to save counters.
+ * As the data only determines if reclaim or compaction continues, it is
+ * not expected that isolated pages will be a dominating factor.
+ */
+unsigned long zone_reclaimable_pages(struct zone *zone)
+{
+	unsigned long nr;
+
+	nr = zone_page_state_snapshot(zone, NR_ZONE_INACTIVE_FILE) +
+		zone_page_state_snapshot(zone, NR_ZONE_ACTIVE_FILE);
+	if (get_nr_swap_pages() > 0)
+		nr += zone_page_state_snapshot(zone, NR_ZONE_INACTIVE_ANON) +
+			zone_page_state_snapshot(zone, NR_ZONE_ACTIVE_ANON);
+
+	return nr;
+}
+
 unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat)
 {
 	unsigned long nr;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index f10aad81a9a3..e1a46906c61b 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -926,6 +926,7 @@ const char * const vmstat_text[] = {
 	"nr_inactive_file",
 	"nr_active_file",
 	"nr_unevictable",
+	"nr_zone_write_pending",
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
