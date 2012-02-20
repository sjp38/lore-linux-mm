Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 688236B007E
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 12:22:42 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so6268158bkt.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:22:41 -0800 (PST)
Subject: [PATCH v2 01/22] memcg: rework inactive_ratio logic
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 20 Feb 2012 21:22:39 +0400
Message-ID: <20120220172238.22196.95469.stgit@zurg>
In-Reply-To: <20120220171138.22196.65847.stgit@zurg>
References: <20120220171138.22196.65847.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch adds mem_cgroup->inactive_ratio calculated from hierarchical memory limit.
It updated at each limit change before shrinking cgroup to this new limit.
Ratios for all child cgroups are updated too, because parent limit can affect them.
Update precedure can be greatly optimized if its performance becomes the problem.
Inactive ratio for unlimited or huge limit does not matter, because we'll never hit it.

At global reclaim always use global ratio from zone->inactive_ratio.
At mem-cgroup reclaim use inactive_ratio from target memory cgroup,
this is cgroup which hit its limit and cause this reclaimer invocation.

Thus, global memory reclaimer will try to keep ratio for all lru lists in zone
above one mark, this guarantee that total ratio in this zone will be above too.
Meanwhile mem-cgroup will do the same thing for its lru lists in all zones, and
for all lru lists in all sub-cgroups in hierarchy.

Also this patch removes some redundant code.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/memcontrol.h |   16 ++------
 mm/memcontrol.c            |   85 ++++++++++++++++++++++++--------------------
 mm/vmscan.c                |   82 +++++++++++++++++++++++-------------------
 3 files changed, 93 insertions(+), 90 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index bf4e1f4..4fbe18a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -113,10 +113,7 @@ void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
 /*
  * For memory reclaim.
  */
-int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg,
-				    struct zone *zone);
-int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg,
-				    struct zone *zone);
+unsigned int mem_cgroup_inactive_ratio(struct mem_cgroup *memcg);
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
 					int nid, int zid, unsigned int lrumask);
@@ -319,16 +316,9 @@ static inline bool mem_cgroup_disabled(void)
 	return true;
 }
 
-static inline int
-mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *zone)
-{
-	return 1;
-}
-
-static inline int
-mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg, struct zone *zone)
+static inline unsigned int mem_cgroup_inactive_ratio(struct mem_cgroup *memcg)
 {
-	return 1;
+	return 0;
 }
 
 static inline unsigned long
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ab315ab..fe0b8fb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -210,6 +210,8 @@ struct mem_cgroup_eventfd_list {
 
 static void mem_cgroup_threshold(struct mem_cgroup *memcg);
 static void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
+static void memcg_get_hierarchical_limit(struct mem_cgroup *memcg,
+		unsigned long long *mem_limit, unsigned long long *memsw_limit);
 
 /*
  * The memory controller data structure. The memory controller controls both
@@ -254,6 +256,10 @@ struct mem_cgroup {
 	atomic_t	refcnt;
 
 	int	swappiness;
+
+	/* The target ratio of ACTIVE_ANON to INACTIVE_ANON pages */
+	unsigned int inactive_ratio;
+
 	/* OOM-Killer disable */
 	int		oom_kill_disable;
 
@@ -1157,44 +1163,6 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg)
 	return ret;
 }
 
-int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *zone)
-{
-	unsigned long inactive_ratio;
-	int nid = zone_to_nid(zone);
-	int zid = zone_idx(zone);
-	unsigned long inactive;
-	unsigned long active;
-	unsigned long gb;
-
-	inactive = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
-						BIT(LRU_INACTIVE_ANON));
-	active = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
-					      BIT(LRU_ACTIVE_ANON));
-
-	gb = (inactive + active) >> (30 - PAGE_SHIFT);
-	if (gb)
-		inactive_ratio = int_sqrt(10 * gb);
-	else
-		inactive_ratio = 1;
-
-	return inactive * inactive_ratio < active;
-}
-
-int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg, struct zone *zone)
-{
-	unsigned long active;
-	unsigned long inactive;
-	int zid = zone_idx(zone);
-	int nid = zone_to_nid(zone);
-
-	inactive = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
-						BIT(LRU_INACTIVE_FILE));
-	active = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
-					      BIT(LRU_ACTIVE_FILE));
-
-	return (active > inactive);
-}
-
 struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
 						      struct zone *zone)
 {
@@ -3374,6 +3342,32 @@ void mem_cgroup_print_bad_page(struct page *page)
 
 static DEFINE_MUTEX(set_limit_mutex);
 
+/*
+ * Update inactive_ratio accoring to new memory limit
+ */
+static void mem_cgroup_update_inactive_ratio(struct mem_cgroup *memcg,
+					     unsigned long long target)
+{
+	unsigned long long mem_limit, memsw_limit, gb;
+	struct mem_cgroup *iter;
+
+	for_each_mem_cgroup_tree(iter, memcg) {
+		memcg_get_hierarchical_limit(iter, &mem_limit, &memsw_limit);
+		mem_limit = min(mem_limit, target);
+
+		gb = mem_limit >> 30;
+		if (gb && 10 * gb < INT_MAX)
+			iter->inactive_ratio = int_sqrt(10 * gb);
+		else
+			iter->inactive_ratio = 1;
+	}
+}
+
+unsigned int mem_cgroup_inactive_ratio(struct mem_cgroup *memcg)
+{
+	return memcg->inactive_ratio;
+}
+
 static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 				unsigned long long val)
 {
@@ -3423,6 +3417,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 			else
 				memcg->memsw_is_minimum = false;
 		}
+		mem_cgroup_update_inactive_ratio(memcg, val);
 		mutex_unlock(&set_limit_mutex);
 
 		if (!ret)
@@ -3440,6 +3435,12 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 	if (!ret && enlarge)
 		memcg_oom_recover(memcg);
 
+	if (ret) {
+		mutex_lock(&set_limit_mutex);
+		mem_cgroup_update_inactive_ratio(memcg, RESOURCE_MAX);
+		mutex_unlock(&set_limit_mutex);
+	}
+
 	return ret;
 }
 
@@ -4155,6 +4156,8 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 	}
 
 #ifdef CONFIG_DEBUG_VM
+	cb->fill(cb, "inactive_ratio", memcg->inactive_ratio);
+
 	{
 		int nid, zid;
 		struct mem_cgroup_per_zone *mz;
@@ -4934,8 +4937,12 @@ mem_cgroup_create(struct cgroup *cont)
 	memcg->last_scanned_node = MAX_NUMNODES;
 	INIT_LIST_HEAD(&memcg->oom_notify);
 
-	if (parent)
+	if (parent) {
 		memcg->swappiness = mem_cgroup_swappiness(parent);
+		memcg->inactive_ratio = parent->inactive_ratio;
+	} else
+		memcg->inactive_ratio = 1;
+
 	atomic_set(&memcg->refcnt, 1);
 	memcg->move_charge_at_immigrate = 0;
 	mutex_init(&memcg->thresholds_lock);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 87e4d6a..ee4d87a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1779,19 +1779,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
 }
 
 #ifdef CONFIG_SWAP
-static int inactive_anon_is_low_global(struct zone *zone)
-{
-	unsigned long active, inactive;
-
-	active = zone_page_state(zone, NR_ACTIVE_ANON);
-	inactive = zone_page_state(zone, NR_INACTIVE_ANON);
-
-	if (inactive * zone->inactive_ratio < active)
-		return 1;
-
-	return 0;
-}
-
 /**
  * inactive_anon_is_low - check if anonymous pages need to be deactivated
  * @zone: zone to check
@@ -1800,8 +1787,12 @@ static int inactive_anon_is_low_global(struct zone *zone)
  * Returns true if the zone does not have enough inactive anon pages,
  * meaning some active anon pages need to be deactivated.
  */
-static int inactive_anon_is_low(struct mem_cgroup_zone *mz)
+static int inactive_anon_is_low(struct mem_cgroup_zone *mz,
+				struct scan_control *sc)
 {
+	unsigned long active, inactive;
+	unsigned int ratio;
+
 	/*
 	 * If we don't have swap space, anonymous page deactivation
 	 * is pointless.
@@ -1809,29 +1800,33 @@ static int inactive_anon_is_low(struct mem_cgroup_zone *mz)
 	if (!total_swap_pages)
 		return 0;
 
-	if (!scanning_global_lru(mz))
-		return mem_cgroup_inactive_anon_is_low(mz->mem_cgroup,
-						       mz->zone);
+	if (global_reclaim(sc))
+		ratio = mz->zone->inactive_ratio;
+	else
+		ratio = mem_cgroup_inactive_ratio(sc->target_mem_cgroup);
 
-	return inactive_anon_is_low_global(mz->zone);
+	if (scanning_global_lru(mz)) {
+		active = zone_page_state(mz->zone, NR_ACTIVE_ANON);
+		inactive = zone_page_state(mz->zone, NR_INACTIVE_ANON);
+	} else {
+		active = mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
+				zone_to_nid(mz->zone), zone_idx(mz->zone),
+				BIT(LRU_ACTIVE_ANON));
+		inactive = mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
+				zone_to_nid(mz->zone), zone_idx(mz->zone),
+				BIT(LRU_INACTIVE_ANON));
+	}
+
+	return inactive * ratio < active;
 }
 #else
-static inline int inactive_anon_is_low(struct mem_cgroup_zone *mz)
+static inline int inactive_anon_is_low(struct mem_cgroup_zone *mz,
+				       struct scan_control *sc)
 {
 	return 0;
 }
 #endif
 
-static int inactive_file_is_low_global(struct zone *zone)
-{
-	unsigned long active, inactive;
-
-	active = zone_page_state(zone, NR_ACTIVE_FILE);
-	inactive = zone_page_state(zone, NR_INACTIVE_FILE);
-
-	return (active > inactive);
-}
-
 /**
  * inactive_file_is_low - check if file pages need to be deactivated
  * @mz: memory cgroup and zone to check
@@ -1848,19 +1843,30 @@ static int inactive_file_is_low_global(struct zone *zone)
  */
 static int inactive_file_is_low(struct mem_cgroup_zone *mz)
 {
-	if (!scanning_global_lru(mz))
-		return mem_cgroup_inactive_file_is_low(mz->mem_cgroup,
-						       mz->zone);
+	unsigned long active, inactive;
+
+	if (scanning_global_lru(mz)) {
+		active = zone_page_state(mz->zone, NR_ACTIVE_FILE);
+		inactive = zone_page_state(mz->zone, NR_INACTIVE_FILE);
+	} else {
+		active = mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
+				zone_to_nid(mz->zone), zone_idx(mz->zone),
+				BIT(LRU_ACTIVE_FILE));
+		inactive = mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
+				zone_to_nid(mz->zone), zone_idx(mz->zone),
+				BIT(LRU_INACTIVE_FILE));
+	}
 
-	return inactive_file_is_low_global(mz->zone);
+	return inactive < active;
 }
 
-static int inactive_list_is_low(struct mem_cgroup_zone *mz, int file)
+static int inactive_list_is_low(struct mem_cgroup_zone *mz,
+				struct scan_control *sc, int file)
 {
 	if (file)
 		return inactive_file_is_low(mz);
 	else
-		return inactive_anon_is_low(mz);
+		return inactive_anon_is_low(mz, sc);
 }
 
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
@@ -1870,7 +1876,7 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 	int file = is_file_lru(lru);
 
 	if (is_active_lru(lru)) {
-		if (inactive_list_is_low(mz, file))
+		if (inactive_list_is_low(mz, sc, file))
 			shrink_active_list(nr_to_scan, mz, sc, priority, file);
 		return 0;
 	}
@@ -2125,7 +2131,7 @@ restart:
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (inactive_anon_is_low(mz))
+	if (inactive_anon_is_low(mz, sc))
 		shrink_active_list(SWAP_CLUSTER_MAX, mz, sc, priority, 0);
 
 	/* reclaim/compaction might need reclaim to continue */
@@ -2558,7 +2564,7 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc,
 			.zone = zone,
 		};
 
-		if (inactive_anon_is_low(&mz))
+		if (inactive_anon_is_low(&mz, sc))
 			shrink_active_list(SWAP_CLUSTER_MAX, &mz,
 					   sc, priority, 0);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
