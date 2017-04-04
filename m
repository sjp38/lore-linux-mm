Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3B5AF6B0390
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 18:01:12 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x89so2903094wma.0
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 15:01:12 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 205si15100638wme.109.2017.04.04.15.01.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 15:01:10 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: vmscan: fix IO/refault regression in cache workingset transition
Date: Tue,  4 Apr 2017 18:00:52 -0400
Message-Id: <20170404220052.27593-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Since 59dc76b0d4df ("mm: vmscan: reduce size of inactive file list")
we noticed bigger IO spikes during changes in cache access patterns.

The patch in question shrunk the inactive list size to leave more room
for the current workingset in the presence of streaming IO. However,
workingset transitions that previously happened on the inactive list
are now pushed out of memory and incur more refaults to complete.

This patch disables active list protection when refaults are being
observed. This accelerates workingset transitions, and allows more of
the new set to establish itself from memory, without eating into the
ability to protect the established workingset during stable periods.

Fixes: 59dc76b0d4df ("mm: vmscan: reduce size of inactive file list")
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: <stable@vger.kernel.org> # 4.7+
---
 include/linux/memcontrol.h | 64 +++++++++++++++++++++++++++++--
 include/linux/mmzone.h     |  2 +
 mm/memcontrol.c            | 24 ++++--------
 mm/vmscan.c                | 94 ++++++++++++++++++++++++++++++++++++----------
 mm/workingset.c            |  7 +++-
 5 files changed, 150 insertions(+), 41 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index c5ebb32fef49..cfa91a3ca0ca 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -57,6 +57,9 @@ enum mem_cgroup_stat_index {
 	MEMCG_SLAB_RECLAIMABLE,
 	MEMCG_SLAB_UNRECLAIMABLE,
 	MEMCG_SOCK,
+	MEMCG_WORKINGSET_REFAULT,
+	MEMCG_WORKINGSET_ACTIVATE,
+	MEMCG_WORKINGSET_NODERECLAIM,
 	MEMCG_NR_STAT,
 };
 
@@ -495,6 +498,40 @@ extern int do_swap_account;
 void lock_page_memcg(struct page *page);
 void unlock_page_memcg(struct page *page);
 
+static inline unsigned long mem_cgroup_read_stat(struct mem_cgroup *memcg,
+						 enum mem_cgroup_stat_index idx)
+{
+	long val = 0;
+	int cpu;
+
+	for_each_possible_cpu(cpu)
+		val += per_cpu(memcg->stat->count[idx], cpu);
+
+	if (val < 0)
+		val = 0;
+
+	return val;
+}
+
+static inline void mem_cgroup_update_stat(struct mem_cgroup *memcg,
+				   enum mem_cgroup_stat_index idx, int val)
+{
+	if (!mem_cgroup_disabled())
+		this_cpu_add(memcg->stat->count[idx], val);
+}
+
+static inline void mem_cgroup_inc_stat(struct mem_cgroup *memcg,
+				   enum mem_cgroup_stat_index idx)
+{
+	mem_cgroup_update_stat(memcg, idx, 1);
+}
+
+static inline void mem_cgroup_dec_stat(struct mem_cgroup *memcg,
+				   enum mem_cgroup_stat_index idx)
+{
+	mem_cgroup_update_stat(memcg, idx, -1);
+}
+
 /**
  * mem_cgroup_update_page_stat - update page state statistics
  * @page: the page
@@ -509,14 +546,14 @@ void unlock_page_memcg(struct page *page);
  *   if (TestClearPageState(page))
  *     mem_cgroup_update_page_stat(page, state, -1);
  *   unlock_page(page) or unlock_page_memcg(page)
+ *
+ * Kernel pages are an exception to this, since they'll never move.
  */
 static inline void mem_cgroup_update_page_stat(struct page *page,
 				 enum mem_cgroup_stat_index idx, int val)
 {
-	VM_BUG_ON(!(rcu_read_lock_held() || PageLocked(page)));
-
 	if (page->mem_cgroup)
-		this_cpu_add(page->mem_cgroup->stat->count[idx], val);
+		mem_cgroup_update_stat(page->mem_cgroup, idx, val);
 }
 
 static inline void mem_cgroup_inc_page_stat(struct page *page,
@@ -741,6 +778,27 @@ static inline bool mem_cgroup_oom_synchronize(bool wait)
 	return false;
 }
 
+static inline unsigned long mem_cgroup_read_stat(struct mem_cgroup *memcg,
+						 enum mem_cgroup_stat_index idx)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_update_stat(struct mem_cgroup *memcg,
+				   enum mem_cgroup_stat_index idx, int val)
+{
+}
+
+static inline void mem_cgroup_inc_stat(struct mem_cgroup *memcg,
+				   enum mem_cgroup_stat_index idx)
+{
+}
+
+static inline void mem_cgroup_dec_stat(struct mem_cgroup *memcg,
+				   enum mem_cgroup_stat_index idx)
+{
+}
+
 static inline void mem_cgroup_update_page_stat(struct page *page,
 					       enum mem_cgroup_stat_index idx,
 					       int nr)
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 618499159a7c..ebaccd4e7d8c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -230,6 +230,8 @@ struct lruvec {
 	struct zone_reclaim_stat	reclaim_stat;
 	/* Evictions & activations on the inactive file list */
 	atomic_long_t			inactive_age;
+	/* Refaults at the time of last reclaim cycle */
+	unsigned long			refaults;
 #ifdef CONFIG_MEMCG
 	struct pglist_data *pgdat;
 #endif
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 490d5b4676c1..108d5b097db1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -569,23 +569,6 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_node *mctz)
  * common workload, threshold and synchronization as vmstat[] should be
  * implemented.
  */
-static unsigned long
-mem_cgroup_read_stat(struct mem_cgroup *memcg, enum mem_cgroup_stat_index idx)
-{
-	long val = 0;
-	int cpu;
-
-	/* Per-cpu values can be negative, use a signed accumulator */
-	for_each_possible_cpu(cpu)
-		val += per_cpu(memcg->stat->count[idx], cpu);
-	/*
-	 * Summing races with updates, so val may be negative.  Avoid exposing
-	 * transient negative values.
-	 */
-	if (val < 0)
-		val = 0;
-	return val;
-}
 
 static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
 					    enum mem_cgroup_events_index idx)
@@ -5244,6 +5227,13 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	seq_printf(m, "pgmajfault %lu\n",
 		   events[MEM_CGROUP_EVENTS_PGMAJFAULT]);
 
+	seq_printf(m, "workingset_refault %lu\n",
+		   stat[MEMCG_WORKINGSET_REFAULT]);
+	seq_printf(m, "workingset_activate %lu\n",
+		   stat[MEMCG_WORKINGSET_ACTIVATE]);
+	seq_printf(m, "workingset_nodereclaim %lu\n",
+		   stat[MEMCG_WORKINGSET_NODERECLAIM]);
+
 	return 0;
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 58615bb27f2f..b3f62cf37097 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2006,6 +2006,8 @@ static void shrink_active_list(unsigned long nr_to_scan,
  * Both inactive lists should also be large enough that each inactive
  * page has a chance to be referenced again before it is reclaimed.
  *
+ * If that fails and refaulting is observed, the inactive list grows.
+ *
  * The inactive_ratio is the target ratio of ACTIVE to INACTIVE pages
  * on this LRU, maintained by the pageout code. A zone->inactive_ratio
  * of 3 means 3:1 or 25% of the pages are kept on the inactive list.
@@ -2022,12 +2024,15 @@ static void shrink_active_list(unsigned long nr_to_scan,
  *   10TB     320        32GB
  */
 static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
-						struct scan_control *sc, bool trace)
+				 struct mem_cgroup *memcg,
+				 struct scan_control *sc, bool actual_reclaim)
 {
-	unsigned long inactive_ratio;
-	unsigned long inactive, active;
-	enum lru_list inactive_lru = file * LRU_FILE;
 	enum lru_list active_lru = file * LRU_FILE + LRU_ACTIVE;
+	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
+	enum lru_list inactive_lru = file * LRU_FILE;
+	unsigned long inactive, active;
+	unsigned long inactive_ratio;
+	unsigned long refaults;
 	unsigned long gb;
 
 	/*
@@ -2040,27 +2045,43 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	inactive = lruvec_lru_size(lruvec, inactive_lru, sc->reclaim_idx);
 	active = lruvec_lru_size(lruvec, active_lru, sc->reclaim_idx);
 
-	gb = (inactive + active) >> (30 - PAGE_SHIFT);
-	if (gb)
-		inactive_ratio = int_sqrt(10 * gb);
+	if (memcg)
+		refaults = mem_cgroup_read_stat(memcg,
+						MEMCG_WORKINGSET_ACTIVATE);
 	else
-		inactive_ratio = 1;
+		refaults = node_page_state(pgdat, WORKINGSET_ACTIVATE);
+
+	/*
+	 * When refaults are being observed, it means a new workingset
+	 * is being established. Disable active list protection to get
+	 * rid of the stale workingset quickly.
+	 */
+	if (file && actual_reclaim && lruvec->refaults != refaults) {
+		inactive_ratio = 0;
+	} else {
+		gb = (inactive + active) >> (30 - PAGE_SHIFT);
+		if (gb)
+			inactive_ratio = int_sqrt(10 * gb);
+		else
+			inactive_ratio = 1;
+	}
 
-	if (trace)
-		trace_mm_vmscan_inactive_list_is_low(lruvec_pgdat(lruvec)->node_id,
-				sc->reclaim_idx,
-				lruvec_lru_size(lruvec, inactive_lru, MAX_NR_ZONES), inactive,
-				lruvec_lru_size(lruvec, active_lru, MAX_NR_ZONES), active,
-				inactive_ratio, file);
+	if (actual_reclaim)
+		trace_mm_vmscan_inactive_list_is_low(pgdat->node_id, sc->reclaim_idx,
+			lruvec_lru_size(lruvec, inactive_lru, MAX_NR_ZONES), inactive,
+			lruvec_lru_size(lruvec, active_lru, MAX_NR_ZONES), active,
+			inactive_ratio, file);
 
 	return inactive * inactive_ratio < active;
 }
 
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
-				 struct lruvec *lruvec, struct scan_control *sc)
+				 struct lruvec *lruvec, struct mem_cgroup *memcg,
+				 struct scan_control *sc)
 {
 	if (is_active_lru(lru)) {
-		if (inactive_list_is_low(lruvec, is_file_lru(lru), sc, true))
+		if (inactive_list_is_low(lruvec, is_file_lru(lru),
+					 memcg, sc, true))
 			shrink_active_list(nr_to_scan, lruvec, sc, lru);
 		return 0;
 	}
@@ -2169,7 +2190,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * lruvec even if it has plenty of old anonymous pages unless the
 	 * system is under heavy pressure.
 	 */
-	if (!inactive_list_is_low(lruvec, true, sc, false) &&
+	if (!inactive_list_is_low(lruvec, true, memcg, sc, false) &&
 	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, sc->reclaim_idx) >> sc->priority) {
 		scan_balance = SCAN_FILE;
 		goto out;
@@ -2320,7 +2341,7 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 				nr[lru] -= nr_to_scan;
 
 				nr_reclaimed += shrink_list(lru, nr_to_scan,
-							    lruvec, sc);
+							    lruvec, memcg, sc);
 			}
 		}
 
@@ -2387,7 +2408,7 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (inactive_list_is_low(lruvec, false, sc, true))
+	if (inactive_list_is_low(lruvec, false, memcg, sc, true))
 		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 				   sc, LRU_ACTIVE_ANON);
 }
@@ -2710,6 +2731,26 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	sc->gfp_mask = orig_mask;
 }
 
+static void snapshot_refaults(struct mem_cgroup *root_memcg, pg_data_t *pgdat)
+{
+	struct mem_cgroup *memcg;
+
+	memcg = mem_cgroup_iter(root_memcg, NULL, NULL);
+	do {
+		unsigned long refaults;
+		struct lruvec *lruvec;
+
+		if (memcg)
+			refaults = mem_cgroup_read_stat(memcg,
+						MEMCG_WORKINGSET_ACTIVATE);
+		else
+			refaults = node_page_state(pgdat, WORKINGSET_ACTIVATE);
+
+		lruvec = mem_cgroup_lruvec(pgdat, memcg);
+		lruvec->refaults = refaults;
+	} while ((memcg = mem_cgroup_iter(root_memcg, memcg, NULL)));
+}
+
 /*
  * This is the main entry point to direct page reclaim.
  *
@@ -2730,6 +2771,9 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 					  struct scan_control *sc)
 {
 	int initial_priority = sc->priority;
+	pg_data_t *last_pgdat;
+	struct zoneref *z;
+	struct zone *zone;
 retry:
 	delayacct_freepages_start();
 
@@ -2756,6 +2800,15 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 			sc->may_writepage = 1;
 	} while (--sc->priority >= 0);
 
+	last_pgdat = NULL;
+	for_each_zone_zonelist_nodemask(zone, z, zonelist, sc->reclaim_idx,
+					sc->nodemask) {
+		if (zone->zone_pgdat == last_pgdat)
+			continue;
+		last_pgdat = zone->zone_pgdat;
+		snapshot_refaults(sc->target_mem_cgroup, zone->zone_pgdat);
+	}
+
 	delayacct_freepages_end();
 
 	if (sc->nr_reclaimed)
@@ -3040,7 +3093,7 @@ static void age_active_anon(struct pglist_data *pgdat,
 	do {
 		struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, memcg);
 
-		if (inactive_list_is_low(lruvec, false, sc, true))
+		if (inactive_list_is_low(lruvec, false, memcg, sc, true))
 			shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 					   sc, LRU_ACTIVE_ANON);
 
@@ -3287,6 +3340,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		pgdat->kswapd_failures++;
 
 out:
+	snapshot_refaults(NULL, pgdat);
 	/*
 	 * Return the order kswapd stopped reclaiming at as
 	 * prepare_kswapd_sleep() takes it into account. If another caller
diff --git a/mm/workingset.c b/mm/workingset.c
index eda05c71fa49..51c6f61d4cea 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -269,7 +269,6 @@ bool workingset_refault(void *shadow)
 	lruvec = mem_cgroup_lruvec(pgdat, memcg);
 	refault = atomic_long_read(&lruvec->inactive_age);
 	active_file = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE, MAX_NR_ZONES);
-	rcu_read_unlock();
 
 	/*
 	 * The unsigned subtraction here gives an accurate distance
@@ -290,11 +289,15 @@ bool workingset_refault(void *shadow)
 	refault_distance = (refault - eviction) & EVICTION_MASK;
 
 	inc_node_state(pgdat, WORKINGSET_REFAULT);
+	mem_cgroup_inc_stat(memcg, MEMCG_WORKINGSET_REFAULT);
 
 	if (refault_distance <= active_file) {
 		inc_node_state(pgdat, WORKINGSET_ACTIVATE);
+		mem_cgroup_inc_stat(memcg, MEMCG_WORKINGSET_ACTIVATE);
+		rcu_read_unlock();
 		return true;
 	}
+	rcu_read_unlock();
 	return false;
 }
 
@@ -472,6 +475,8 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 	if (WARN_ON_ONCE(node->exceptional))
 		goto out_invalid;
 	inc_node_state(page_pgdat(virt_to_page(node)), WORKINGSET_NODERECLAIM);
+	mem_cgroup_inc_page_stat(virt_to_page(node),
+				 MEMCG_WORKINGSET_NODERECLAIM);
 	__radix_tree_delete_node(&mapping->page_tree, node,
 				 workingset_update_node, mapping);
 
-- 
2.12.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
