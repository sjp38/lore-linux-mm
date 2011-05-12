Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 58AF490010B
	for <linux-mm@kvack.org>; Thu, 12 May 2011 10:54:47 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [rfc patch 3/6] mm: memcg-aware global reclaim
Date: Thu, 12 May 2011 16:53:55 +0200
Message-Id: <1305212038-15445-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

A page charged to a memcg is linked to a lru list specific to that
memcg.  At the same time, traditional global reclaim is obvlivious to
memcgs, and all the pages are also linked to a global per-zone list.

This patch changes traditional global reclaim to iterate over all
existing memcgs, so that it no longer relies on the global list being
present.

This is one step forward in integrating memcg code better into the
rest of memory management.  It is also a prerequisite to get rid of
the global per-zone lru lists.

RFC:

The algorithm implemented in this patch is very naive.  For each zone
scanned at each priority level, it iterates over all existing memcgs
and considers them for scanning.

This is just a prototype and I did not optimize it yet because I am
unsure about the maximum number of memcgs that still constitute a sane
configuration in comparison to the machine size.

It is perfectly fair since all memcgs are scanned at each priority
level.

On my 4G quadcore laptop with 1000 memcgs, a significant amount of CPU
time was spent just iterating memcgs during reclaim.  But it can not
really be claimed that the old code was much better, either: global
LRU reclaim could mean that a few hundred memcgs would have been
emptied out completely, while others stayed untouched.

I am open to solutions that trade fairness against CPU-time but don't
want to have an extreme in either direction.  Maybe break out early if
a number of memcgs has been successfully reclaimed from and remember
the last one scanned.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |    7 ++
 mm/memcontrol.c            |  148 +++++++++++++++++++++++++++++---------------
 mm/vmscan.c                |   21 +++++--
 3 files changed, 120 insertions(+), 56 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5e9840f5..58728c7 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -104,6 +104,7 @@ extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
 /*
  * For memory reclaim.
  */
+void mem_cgroup_hierarchy_walk(struct mem_cgroup *, struct mem_cgroup **);
 int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
 int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
@@ -289,6 +290,12 @@ static inline bool mem_cgroup_disabled(void)
 	return true;
 }
 
+static inline void mem_cgroup_hierarchy_walk(struct mem_cgroup *start,
+					     struct mem_cgroup **iter)
+{
+	*iter = start;
+}
+
 static inline int
 mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index bf5ab87..edcd55a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -313,7 +313,7 @@ static bool move_file(void)
 }
 
 /*
- * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
+ * Maximum loops in mem_cgroup_soft_reclaim(), used for soft
  * limit reclaim to prevent infinite loops, if they ever occur.
  */
 #define	MEM_CGROUP_MAX_RECLAIM_LOOPS		(100)
@@ -339,16 +339,6 @@ enum charge_type {
 /* Used for OOM nofiier */
 #define OOM_CONTROL		(0)
 
-/*
- * Reclaim flags for mem_cgroup_hierarchical_reclaim
- */
-#define MEM_CGROUP_RECLAIM_NOSWAP_BIT	0x0
-#define MEM_CGROUP_RECLAIM_NOSWAP	(1 << MEM_CGROUP_RECLAIM_NOSWAP_BIT)
-#define MEM_CGROUP_RECLAIM_SHRINK_BIT	0x1
-#define MEM_CGROUP_RECLAIM_SHRINK	(1 << MEM_CGROUP_RECLAIM_SHRINK_BIT)
-#define MEM_CGROUP_RECLAIM_SOFT_BIT	0x2
-#define MEM_CGROUP_RECLAIM_SOFT		(1 << MEM_CGROUP_RECLAIM_SOFT_BIT)
-
 static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
@@ -1381,6 +1371,86 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
 	return min(limit, memsw);
 }
 
+void mem_cgroup_hierarchy_walk(struct mem_cgroup *start,
+			       struct mem_cgroup **iter)
+{
+	struct mem_cgroup *mem = *iter;
+	int id;
+
+	if (!start)
+		start = root_mem_cgroup;
+	/*
+	 * Even without hierarchy explicitely enabled in the root
+	 * memcg, it is the ultimate parent of all memcgs.
+	 */
+	if (!(start == root_mem_cgroup || start->use_hierarchy)) {
+		*iter = start;
+		return;
+	}
+
+	if (!mem)
+		id = css_id(&start->css);
+	else {
+		id = css_id(&mem->css);
+		css_put(&mem->css);
+		mem = NULL;
+	}
+
+	do {
+		struct cgroup_subsys_state *css;
+
+		rcu_read_lock();
+		css = css_get_next(&mem_cgroup_subsys, id+1, &start->css, &id);
+		/*
+		 * The caller must already have a reference to the
+		 * starting point of this hierarchy walk, do not grab
+		 * another one.  This way, the loop can be finished
+		 * when the hierarchy root is returned, without any
+		 * further cleanup required.
+		 */
+		if (css && (css == &start->css || css_tryget(css)))
+			mem = container_of(css, struct mem_cgroup, css);
+		rcu_read_unlock();
+		if (!css)
+			id = 0;
+	} while (!mem);
+
+	if (mem == root_mem_cgroup)
+		mem = NULL;
+
+	*iter = mem;
+}
+
+static unsigned long mem_cgroup_target_reclaim(struct mem_cgroup *mem,
+					       gfp_t gfp_mask,
+					       bool noswap,
+					       bool shrink)
+{
+	unsigned long total = 0;
+	int loop;
+
+	if (mem->memsw_is_minimum)
+		noswap = true;
+
+	for (loop = 0; loop < MEM_CGROUP_MAX_RECLAIM_LOOPS; loop++) {
+		drain_all_stock_async();
+		total += try_to_free_mem_cgroup_pages(mem, gfp_mask, noswap,
+						      get_swappiness(mem));
+		if (total && shrink)
+			break;
+		if (mem_cgroup_margin(mem))
+			break;
+		/*
+		 * If we have not been able to reclaim anything after
+		 * two reclaim attempts, there may be no reclaimable
+		 * pages under this hierarchy.
+		 */
+		if (loop && !total)
+			break;
+	}
+	return total;
+}
+
 /*
  * Visit the first child (need not be the first child as per the ordering
  * of the cgroup list, since we track last_scanned_child) of @mem and use
@@ -1427,21 +1497,16 @@ mem_cgroup_select_victim(struct mem_cgroup *root_mem)
  *
  * We give up and return to the caller when we visit root_mem twice.
  * (other groups can be removed while we're walking....)
- *
- * If shrink==true, for avoiding to free too much, this returns immedieately.
  */
-static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
-						struct zone *zone,
-						gfp_t gfp_mask,
-						unsigned long reclaim_options)
+static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_mem,
+				   struct zone *zone,
+				   gfp_t gfp_mask)
 {
 	struct mem_cgroup *victim;
 	int ret, total = 0;
 	int loop = 0;
-	bool noswap = reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP;
-	bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
-	bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
 	unsigned long excess;
+	bool noswap = false;
 
 	excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;
 
@@ -1461,7 +1526,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 				 * anything, it might because there are
 				 * no reclaimable pages under this hierarchy
 				 */
-				if (!check_soft || !total) {
+				if (!total) {
 					css_put(&victim->css);
 					break;
 				}
@@ -1484,25 +1549,11 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 			continue;
 		}
 		/* we use swappiness of local cgroup */
-		if (check_soft)
-			ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
+		ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
 				noswap, get_swappiness(victim), zone);
-		else
-			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
-						noswap, get_swappiness(victim));
 		css_put(&victim->css);
-		/*
-		 * At shrinking usage, we can't check we should stop here or
-		 * reclaim more. It's depends on callers. last_scanned_child
-		 * will work enough for keeping fairness under tree.
-		 */
-		if (shrink)
-			return ret;
 		total += ret;
-		if (check_soft) {
-			if (!res_counter_soft_limit_excess(&root_mem->res))
-				return total;
-		} else if (mem_cgroup_margin(root_mem))
+		if (!res_counter_soft_limit_excess(&root_mem->res))
 			return total;
 	}
 	return total;
@@ -1897,7 +1948,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
 	unsigned long csize = nr_pages * PAGE_SIZE;
 	struct mem_cgroup *mem_over_limit;
 	struct res_counter *fail_res;
-	unsigned long flags = 0;
+	bool noswap = false;
 	int ret;
 
 	ret = res_counter_charge(&mem->res, csize, &fail_res);
@@ -1911,7 +1962,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
 
 		res_counter_uncharge(&mem->res, csize);
 		mem_over_limit = mem_cgroup_from_res_counter(fail_res, memsw);
-		flags |= MEM_CGROUP_RECLAIM_NOSWAP;
+		noswap = true;
 	} else
 		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
 	/*
@@ -1927,8 +1978,8 @@ static int mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
 	if (!(gfp_mask & __GFP_WAIT))
 		return CHARGE_WOULDBLOCK;
 
-	ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
-					      gfp_mask, flags);
+	ret = mem_cgroup_target_reclaim(mem_over_limit, gfp_mask,
+					noswap, false);
 	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
 		return CHARGE_RETRY;
 	/*
@@ -3085,7 +3136,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
 
 /*
  * A call to try to shrink memory usage on charge failure at shmem's swapin.
- * Calling hierarchical_reclaim is not enough because we should update
+ * Calling target_reclaim is not enough because we should update
  * last_oom_jiffies to prevent pagefault_out_of_memory from invoking global OOM.
  * Moreover considering hierarchy, we should reclaim from the mem_over_limit,
  * not from the memcg which this page would be charged to.
@@ -3167,7 +3218,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 	int enlarge;
 
 	/*
-	 * For keeping hierarchical_reclaim simple, how long we should retry
+	 * For keeping target_reclaim simple, how long we should retry
 	 * is depends on callers. We set our retry-count to be function
 	 * of # of children which we should visit in this loop.
 	 */
@@ -3210,8 +3261,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
-		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
-						MEM_CGROUP_RECLAIM_SHRINK);
+		mem_cgroup_target_reclaim(memcg, GFP_KERNEL, false, false);
 		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
 		/* Usage is reduced ? */
   		if (curusage >= oldusage)
@@ -3269,9 +3319,7 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
-		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
-						MEM_CGROUP_RECLAIM_NOSWAP |
-						MEM_CGROUP_RECLAIM_SHRINK);
+		mem_cgroup_target_reclaim(memcg, GFP_KERNEL, true, false);
 		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
 		/* Usage is reduced ? */
 		if (curusage >= oldusage)
@@ -3311,9 +3359,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 		if (!mz)
 			break;
 
-		reclaimed = mem_cgroup_hierarchical_reclaim(mz->mem, zone,
-						gfp_mask,
-						MEM_CGROUP_RECLAIM_SOFT);
+		reclaimed = mem_cgroup_soft_reclaim(mz->mem, zone, gfp_mask);
 		nr_reclaimed += reclaimed;
 		spin_lock(&mctz->lock);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ceeb2a5..e2a3647 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1900,8 +1900,8 @@ static inline bool should_continue_reclaim(struct zone *zone,
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
-static void shrink_zone(int priority, struct zone *zone,
-				struct scan_control *sc)
+static void do_shrink_zone(int priority, struct zone *zone,
+			   struct scan_control *sc)
 {
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
@@ -1914,8 +1914,6 @@ restart:
 	nr_scanned = sc->nr_scanned;
 	get_scan_count(zone, sc, nr, priority);
 
-	sc->current_memcg = sc->memcg;
-
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
 		for_each_evictable_lru(l) {
@@ -1954,6 +1952,19 @@ restart:
 		goto restart;
 
 	throttle_vm_writeout(sc->gfp_mask);
+}
+
+static void shrink_zone(int priority, struct zone *zone,
+			struct scan_control *sc)
+{
+	struct mem_cgroup *root = sc->memcg;
+	struct mem_cgroup *mem = NULL;
+
+	do {
+		mem_cgroup_hierarchy_walk(root, &mem);
+		sc->current_memcg = mem;
+		do_shrink_zone(priority, zone, sc);
+	} while (mem != root);
 
 	/* For good measure, noone higher up the stack should look at it */
 	sc->current_memcg = NULL;
@@ -2190,7 +2201,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 	 * will pick up pages from other mem cgroup's as well. We hack
 	 * the priority and make it zero.
 	 */
-	shrink_zone(0, zone, &sc);
+	do_shrink_zone(0, zone, &sc);
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
-- 
1.7.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
