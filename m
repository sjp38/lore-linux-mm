Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F366828E5
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 05:41:11 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id a2so27033028lfe.0
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 02:41:11 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id wb8si297627wjc.60.2016.07.08.02.41.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Jul 2016 02:41:10 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id C322999429
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 09:41:09 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 34/34] mm, vmstat: remove zone and node double accounting by approximating retries
Date: Fri,  8 Jul 2016 10:35:10 +0100
Message-Id: <1467970510-21195-35-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The number of LRU pages, dirty pages and writeback pages must be accounted
for on both zones and nodes because of the reclaim retry logic, compaction
retry logic and highmem calculations all depending on per-zone stats.

Many lowmem allocations are immune from OOM kill due to a check in
__alloc_pages_may_oom for (ac->high_zoneidx < ZONE_NORMAL) since commit
03668b3ceb0c ("oom: avoid oom killer for lowmem allocations"). The exception
is costly high-order allocations or allocations that cannot fail. If the
__alloc_pages_may_oom avoids OOM-kill for low-order lowmem allocations
then it would fall through to __alloc_pages_direct_compact.

This patch will blindly retry reclaim for zone-constrained allocations
in should_reclaim_retry up to MAX_RECLAIM_RETRIES. This is not ideal but
without per-zone stats there are not many alternatives. The impact it that
zone-constrained allocations may delay before considering the OOM killer.

As there is no guarantee enough memory can ever be freed to satisfy
compaction, this patch avoids retrying compaction for zone-contrained
allocations.

In combination, that means that the per-node stats can be used when deciding
whether to continue reclaim using a rough approximation.  While it is
possible this will make the wrong decision on occasion, it will not infinite
loop as the number of reclaim attempts is capped by MAX_RECLAIM_RETRIES.

The final step is calculating the number of dirtyable highmem pages. As
those calculations only care about the global count of file pages in
highmem. This patch uses a global counter used instead of per-zone stats
as it is sufficient.

In combination, this allows the per-zone LRU and dirty state counters to
be removed.

Suggested by: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
---
 include/linux/mm_inline.h | 24 +++++++++++++++++++++---
 include/linux/mmzone.h    |  4 ----
 include/linux/swap.h      |  1 -
 mm/compaction.c           | 20 +++++++++++++++++++-
 mm/migrate.c              |  2 --
 mm/page-writeback.c       | 13 +++++--------
 mm/page_alloc.c           | 47 +++++++++++++++++++++++++++++++++++++++--------
 mm/vmscan.c               | 16 ----------------
 mm/vmstat.c               |  3 ---
 9 files changed, 84 insertions(+), 46 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 9aadcc781857..ccd40e357b56 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -4,6 +4,26 @@
 #include <linux/huge_mm.h>
 #include <linux/swap.h>
 
+#ifdef CONFIG_HIGHMEM
+extern atomic_t highmem_file_pages;
+
+static inline void acct_highmem_file_pages(int zid, enum lru_list lru,
+							int nr_pages)
+{
+	if (is_highmem_idx(zid) && is_file_lru(lru)) {
+		if (nr_pages > 0)
+			atomic_add(nr_pages, &highmem_file_pages);
+		else
+			atomic_sub(nr_pages, &highmem_file_pages);
+	}
+}
+#else
+static inline void acct_highmem_file_pages(int zid, enum lru_list lru,
+							int nr_pages)
+{
+}
+#endif
+
 /**
  * page_is_file_cache - should the page be on a file LRU or anon LRU?
  * @page: the page to test
@@ -29,9 +49,7 @@ static __always_inline void __update_lru_size(struct lruvec *lruvec,
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 
 	__mod_node_page_state(pgdat, NR_LRU_BASE + lru, nr_pages);
-	__mod_zone_page_state(&pgdat->node_zones[zid],
-		NR_ZONE_LRU_BASE + !!is_file_lru(lru),
-		nr_pages);
+	acct_highmem_file_pages(zid, lru, nr_pages);
 }
 
 static __always_inline void update_lru_size(struct lruvec *lruvec,
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index bd33e6f1bed0..a3b7f45aac56 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -110,10 +110,6 @@ struct zone_padding {
 enum zone_stat_item {
 	/* First 128 byte cacheline (assuming 64 bit words) */
 	NR_FREE_PAGES,
-	NR_ZONE_LRU_BASE, /* Used only for compaction and reclaim retry */
-	NR_ZONE_LRU_ANON = NR_ZONE_LRU_BASE,
-	NR_ZONE_LRU_FILE,
-	NR_ZONE_WRITE_PENDING,	/* Count of dirty, writeback and unstable pages */
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
 	NR_SLAB_RECLAIMABLE,
 	NR_SLAB_UNRECLAIMABLE,
diff --git a/include/linux/swap.h b/include/linux/swap.h
index b17cc4830fa6..cc753c639e3d 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -307,7 +307,6 @@ extern void lru_cache_add_active_or_unevictable(struct page *page,
 						struct vm_area_struct *vma);
 
 /* linux/mm/vmscan.c */
-extern unsigned long zone_reclaimable_pages(struct zone *zone);
 extern unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat);
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
diff --git a/mm/compaction.c b/mm/compaction.c
index a0bd85712516..640532831b94 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1446,6 +1446,11 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
 {
 	struct zone *zone;
 	struct zoneref *z;
+	pg_data_t *last_pgdat = NULL;
+
+	/* Do not retry compaction for zone-constrained allocations */
+	if (ac->high_zoneidx < ZONE_NORMAL)
+		return false;
 
 	/*
 	 * Make sure at least one zone would pass __compaction_suitable if we continue
@@ -1456,14 +1461,27 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
 		unsigned long available;
 		enum compact_result compact_result;
 
+		if (last_pgdat == zone->zone_pgdat)
+			continue;
+
+		/*
+		 * This over-estimates the number of pages available for
+		 * reclaim/compaction but walking the LRU would take too
+		 * long. The consequences are that compaction may retry
+		 * longer than it should for a zone-constrained allocation
+		 * request.
+		 */
+		last_pgdat = zone->zone_pgdat;
+		available = pgdat_reclaimable_pages(zone->zone_pgdat) / order;
+
 		/*
 		 * Do not consider all the reclaimable memory because we do not
 		 * want to trash just for a single high order allocation which
 		 * is even not guaranteed to appear even if __compaction_suitable
 		 * is happy about the watermark check.
 		 */
-		available = zone_reclaimable_pages(zone) / order;
 		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
+		available = min(zone->managed_pages, available);
 		compact_result = __compaction_suitable(zone, order, alloc_flags,
 				ac_classzone_idx(ac), available);
 		if (compact_result != COMPACT_SKIPPED &&
diff --git a/mm/migrate.c b/mm/migrate.c
index c77997dc6ed7..ed2f85e61de1 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -513,9 +513,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
 		}
 		if (dirty && mapping_cap_account_dirty(mapping)) {
 			__dec_node_state(oldzone->zone_pgdat, NR_FILE_DIRTY);
-			__dec_zone_state(oldzone, NR_ZONE_WRITE_PENDING);
 			__inc_node_state(newzone->zone_pgdat, NR_FILE_DIRTY);
-			__dec_zone_state(newzone, NR_ZONE_WRITE_PENDING);
 		}
 	}
 	local_irq_enable();
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 3c02aa603f5a..0bca2376bd42 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -299,6 +299,9 @@ static unsigned long node_dirtyable_memory(struct pglist_data *pgdat)
 
 	return nr_pages;
 }
+#ifdef CONFIG_HIGHMEM
+atomic_t highmem_file_pages;
+#endif
 
 static unsigned long highmem_dirtyable_memory(unsigned long total)
 {
@@ -306,18 +309,17 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
 	int node;
 	unsigned long x = 0;
 	int i;
+	unsigned long dirtyable = atomic_read(&highmem_file_pages);
 
 	for_each_node_state(node, N_HIGH_MEMORY) {
 		for (i = ZONE_NORMAL + 1; i < MAX_NR_ZONES; i++) {
 			struct zone *z;
-			unsigned long dirtyable;
 
 			if (!is_highmem_idx(i))
 				continue;
 
 			z = &NODE_DATA(node)->node_zones[i];
-			dirtyable = zone_page_state(z, NR_FREE_PAGES) +
-				zone_page_state(z, NR_ZONE_LRU_FILE);
+			dirtyable += zone_page_state(z, NR_FREE_PAGES);
 
 			/* watch for underflows */
 			dirtyable -= min(dirtyable, high_wmark_pages(z));
@@ -2460,7 +2462,6 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 
 		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_DIRTY);
 		__inc_node_page_state(page, NR_FILE_DIRTY);
-		__inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		__inc_node_page_state(page, NR_DIRTIED);
 		__inc_wb_stat(wb, WB_RECLAIMABLE);
 		__inc_wb_stat(wb, WB_DIRTIED);
@@ -2482,7 +2483,6 @@ void account_page_cleaned(struct page *page, struct address_space *mapping,
 	if (mapping_cap_account_dirty(mapping)) {
 		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_DIRTY);
 		dec_node_page_state(page, NR_FILE_DIRTY);
-		dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		dec_wb_stat(wb, WB_RECLAIMABLE);
 		task_io_account_cancelled_write(PAGE_SIZE);
 	}
@@ -2739,7 +2739,6 @@ int clear_page_dirty_for_io(struct page *page)
 		if (TestClearPageDirty(page)) {
 			mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_DIRTY);
 			dec_node_page_state(page, NR_FILE_DIRTY);
-			dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 			dec_wb_stat(wb, WB_RECLAIMABLE);
 			ret = 1;
 		}
@@ -2786,7 +2785,6 @@ int test_clear_page_writeback(struct page *page)
 	if (ret) {
 		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
 		dec_node_page_state(page, NR_WRITEBACK);
-		dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		inc_node_page_state(page, NR_WRITTEN);
 	}
 	unlock_page_memcg(page);
@@ -2841,7 +2839,6 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 	if (!ret) {
 		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
 		inc_node_page_state(page, NR_WRITEBACK);
-		inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 	}
 	unlock_page_memcg(page);
 	return ret;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 030114f55b0e..a702c31d2df4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3445,6 +3445,7 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 {
 	struct zone *zone;
 	struct zoneref *z;
+	pg_data_t *current_pgdat = NULL;
 
 	/*
 	 * Make sure we converge to OOM if we cannot make any progress
@@ -3454,6 +3455,15 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 		return false;
 
 	/*
+	 * Blindly retry lowmem allocation requests that are often ignored by
+	 * the OOM killer up to MAX_RECLAIM_RETRIES as we not have a reliable
+	 * and fast means of calculating reclaimable, dirty and writeback pages
+	 * in eligible zones.
+	 */
+	if (ac->high_zoneidx < ZONE_NORMAL)
+		goto out;
+
+	/*
 	 * Keep reclaiming pages while there is a chance this will lead somewhere.
 	 * If none of the target zones can satisfy our allocation request even
 	 * if all reclaimable pages are considered then we are screwed and have
@@ -3463,18 +3473,38 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 					ac->nodemask) {
 		unsigned long available;
 		unsigned long reclaimable;
+		int zid;
 
-		available = reclaimable = zone_reclaimable_pages(zone);
+		if (current_pgdat == zone->zone_pgdat)
+			continue;
+
+		current_pgdat = zone->zone_pgdat;
+		available = reclaimable = pgdat_reclaimable_pages(current_pgdat);
 		available -= DIV_ROUND_UP(no_progress_loops * available,
 					  MAX_RECLAIM_RETRIES);
-		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
+
+		/* Account for all free pages on eligible zones */
+		for (zid = 0; zid <= zone_idx(zone); zid++) {
+			struct zone *acct_zone = &current_pgdat->node_zones[zid];
+
+			available += zone_page_state_snapshot(acct_zone, NR_FREE_PAGES);
+		}
 
 		/*
 		 * Would the allocation succeed if we reclaimed the whole
-		 * available?
+		 * available? This is approximate because there is no
+		 * accurate count of reclaimable pages per zone.
 		 */
-		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
-				ac_classzone_idx(ac), alloc_flags, available)) {
+		for (zid = 0; zid <= zone_idx(zone); zid++) {
+			struct zone *check_zone = &current_pgdat->node_zones[zid];
+			unsigned long estimate;
+
+			estimate = min(check_zone->managed_pages, available);
+			if (!__zone_watermark_ok(check_zone, order,
+					min_wmark_pages(check_zone), ac_classzone_idx(ac),
+					alloc_flags, estimate))
+				continue;
+
 			/*
 			 * If we didn't make any progress and have a lot of
 			 * dirty + writeback pages then we should wait for
@@ -3484,15 +3514,16 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 			if (!did_some_progress) {
 				unsigned long write_pending;
 
-				write_pending = zone_page_state_snapshot(zone,
-							NR_ZONE_WRITE_PENDING);
+				write_pending =
+					node_page_state(current_pgdat, NR_WRITEBACK) +
+					node_page_state(current_pgdat, NR_FILE_DIRTY);
 
 				if (2 * write_pending > reclaimable) {
 					congestion_wait(BLK_RW_ASYNC, HZ/10);
 					return true;
 				}
 			}
-
+out:
 			/*
 			 * Memory allocation/reclaim might be called from a WQ
 			 * context and the current implementation of the WQ
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a8b432ff0d14..d079210d46ee 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -194,22 +194,6 @@ static bool sane_reclaim(struct scan_control *sc)
 }
 #endif
 
-/*
- * This misses isolated pages which are not accounted for to save counters.
- * As the data only determines if reclaim or compaction continues, it is
- * not expected that isolated pages will be a dominating factor.
- */
-unsigned long zone_reclaimable_pages(struct zone *zone)
-{
-	unsigned long nr;
-
-	nr = zone_page_state_snapshot(zone, NR_ZONE_LRU_FILE);
-	if (get_nr_swap_pages() > 0)
-		nr += zone_page_state_snapshot(zone, NR_ZONE_LRU_ANON);
-
-	return nr;
-}
-
 unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat)
 {
 	unsigned long nr;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 60372f31fee3..7415775faf08 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -921,9 +921,6 @@ int fragmentation_index(struct zone *zone, unsigned int order)
 const char * const vmstat_text[] = {
 	/* enum zone_stat_item countes */
 	"nr_free_pages",
-	"nr_zone_anon_lru",
-	"nr_zone_file_lru",
-	"nr_zone_write_pending",
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
