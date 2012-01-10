Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id D8FF86B0068
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 10:03:14 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/2] mm: memcg: hierarchical soft limit reclaim
Date: Tue, 10 Jan 2012 16:02:52 +0100
Message-Id: <1326207772-16762-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1326207772-16762-1-git-send-email-hannes@cmpxchg.org>
References: <1326207772-16762-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Right now, memcg soft limits are implemented by having a sorted tree
of memcgs that are in excess of their limits.  Under global memory
pressure, kswapd first reclaims from the biggest excessor and then
proceeds to do regular global reclaim.  The result of this is that
pages are reclaimed from all memcgs, but more scanning happens against
those above their soft limit.

With global reclaim doing memcg-aware hierarchical reclaim by default,
this is a lot easier to implement: everytime a memcg is reclaimed
from, scan more aggressively (per tradition with a priority of 0) if
it's above its soft limit.  With the same end result of scanning
everybody, but soft limit excessors a bit more.

Advantages:

  o smoother reclaim: soft limit reclaim is a separate stage before
    global reclaim, whose result is not communicated down the line and
    so overreclaim of the groups in excess is very likely.  After this
    patch, soft limit reclaim is fully integrated into regular reclaim
    and each memcg is considered exactly once per cycle.

  o true hierarchy support: soft limits are only considered when
    kswapd does global reclaim, but after this patch, targetted
    reclaim of a memcg will mind the soft limit settings of its child
    groups.

  o code size: soft limit reclaim requires a lot of code to maintain
    the per-node per-zone rb-trees to quickly find the biggest
    offender, dedicated paths for soft limit reclaim etc. while this
    new implementation gets away without all that.

Test:

The test consists of two concurrent kernel build jobs in separate
source trees, the master and the slave.  The two jobs get along nicely
on 600MB of available memory, so this is the zero overcommit control
case.  When available memory is decreased, the overcommit is
compensated by decreasing the soft limit of the slave by the same
amount, in the hope that the slave takes the hit and the master stays
unaffected.

                                    600M-0M-vanilla         600M-0M-patched
Master walltime (s)               552.65 (  +0.00%)       552.38 (  -0.05%)
Master walltime (stddev)            1.25 (  +0.00%)         0.92 ( -14.66%)
Master major faults               204.38 (  +0.00%)       205.38 (  +0.49%)
Master major faults (stddev)       27.16 (  +0.00%)        13.80 ( -47.43%)
Master reclaim                     31.88 (  +0.00%)        37.75 ( +17.87%)
Master reclaim (stddev)            34.01 (  +0.00%)        75.88 (+119.59%)
Master scan                        31.88 (  +0.00%)        37.75 ( +17.87%)
Master scan (stddev)               34.01 (  +0.00%)        75.88 (+119.59%)
Master kswapd reclaim           33922.12 (  +0.00%)     33887.12 (  -0.10%)
Master kswapd reclaim (stddev)    969.08 (  +0.00%)       492.22 ( -49.16%)
Master kswapd scan              34085.75 (  +0.00%)     33985.75 (  -0.29%)
Master kswapd scan (stddev)      1101.07 (  +0.00%)       563.33 ( -48.79%)
Slave walltime (s)                552.68 (  +0.00%)       552.12 (  -0.10%)
Slave walltime (stddev)             0.79 (  +0.00%)         1.05 ( +14.76%)
Slave major faults                212.50 (  +0.00%)       204.50 (  -3.75%)
Slave major faults (stddev)        26.90 (  +0.00%)        13.17 ( -49.20%)
Slave reclaim                      26.12 (  +0.00%)        35.00 ( +32.72%)
Slave reclaim (stddev)             29.42 (  +0.00%)        74.91 (+149.55%)
Slave scan                         31.38 (  +0.00%)        35.00 ( +11.20%)
Slave scan (stddev)                33.31 (  +0.00%)        74.91 (+121.24%)
Slave kswapd reclaim            34259.00 (  +0.00%)     33469.88 (  -2.30%)
Slave kswapd reclaim (stddev)     925.15 (  +0.00%)       565.07 ( -38.88%)
Slave kswapd scan               34354.62 (  +0.00%)     33555.75 (  -2.33%)
Slave kswapd scan (stddev)        969.62 (  +0.00%)       581.70 ( -39.97%)

In the control case, the differences in elapsed time, number of major
faults taken, and reclaim statistics are within the noise for both the
master and the slave job.

                                     600M-280M-vanilla      600M-280M-patched
Master walltime (s)                  595.13 (  +0.00%)      553.19 (  -7.04%)
Master walltime (stddev)               8.31 (  +0.00%)        2.57 ( -61.64%)
Master major faults                 3729.75 (  +0.00%)      783.25 ( -78.98%)
Master major faults (stddev)         258.79 (  +0.00%)      226.68 ( -12.36%)
Master reclaim                       705.00 (  +0.00%)       29.50 ( -95.68%)
Master reclaim (stddev)              232.87 (  +0.00%)       44.72 ( -80.45%)
Master scan                          714.88 (  +0.00%)       30.00 ( -95.67%)
Master scan (stddev)                 237.44 (  +0.00%)       45.39 ( -80.54%)
Master kswapd reclaim                114.75 (  +0.00%)       50.00 ( -55.94%)
Master kswapd reclaim (stddev)       128.51 (  +0.00%)        9.45 ( -91.93%)
Master kswapd scan                   115.75 (  +0.00%)       50.00 ( -56.32%)
Master kswapd scan (stddev)          130.31 (  +0.00%)        9.45 ( -92.04%)
Slave walltime (s)                   631.18 (  +0.00%)      577.68 (  -8.46%)
Slave walltime (stddev)                9.89 (  +0.00%)        3.63 ( -57.47%)
Slave major faults                 28401.75 (  +0.00%)    14656.75 ( -48.39%)
Slave major faults (stddev)         2629.97 (  +0.00%)     1911.81 ( -27.30%)
Slave reclaim                      65400.62 (  +0.00%)     1479.62 ( -97.74%)
Slave reclaim (stddev)             11623.02 (  +0.00%)     1482.13 ( -87.24%)
Slave scan                       9050047.88 (  +0.00%)    95968.25 ( -98.94%)
Slave scan (stddev)              1912786.94 (  +0.00%)    93390.71 ( -95.12%)
Slave kswapd reclaim              327894.50 (  +0.00%)   227099.88 ( -30.74%)
Slave kswapd reclaim (stddev)      22289.43 (  +0.00%)    16113.14 ( -27.71%)
Slave kswapd scan               34987335.75 (  +0.00%)  1362367.12 ( -96.11%)
Slave kswapd scan (stddev)       2523642.98 (  +0.00%)   156754.74 ( -93.79%)

Here, the available memory is limited to 320 MB, the machine is
overcommitted by 280 MB.  The soft limit of the master is 300 MB, that
of the slave merely 20 MB.

Looking at the slave job first, it is much better off with the patched
kernel: direct reclaim is almost gone, kswapd reclaim is decreased by
a third.  The result is much fewer major faults taken, which in turn
lets the job finish quicker.

It would be a zero-sum game if the improvement happened at the cost of
the master but looking at the numbers, even the master performs better
with the patched kernel.  In fact, the master job is almost unaffected
on the patched kernel compared to the control case.

This is an odd phenomenon, as the patch does not directly change how
the master is reclaimed.  An explanation for this is that the severe
overreclaim of the slave in the unpatched kernel results in the master
growing bigger than in the patched case.  Combining the fact that
memcgs are scanned according to their size with the increased refault
rate of the overreclaimed slave triggering global reclaim more often
means that overall pressure on the master job is higher in the
unpatched kernel.

At any rate, the patched kernel seems to do a much better job at both
overall resource allocation under soft limit overcommit as well as the
requested prioritization of the master job.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |   18 +--
 mm/memcontrol.c            |  412 ++++----------------------------------------
 mm/vmscan.c                |   80 +--------
 3 files changed, 48 insertions(+), 462 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6c1d69e..72368b7 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -121,6 +121,7 @@ struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
 						      struct zone *zone);
 struct zone_reclaim_stat*
 mem_cgroup_get_reclaim_stat_from_page(struct page *page);
+bool mem_cgroup_over_softlimit(struct mem_cgroup *, struct mem_cgroup *);
 void mem_cgroup_account_reclaim(struct mem_cgroup *, struct mem_cgroup *,
 				unsigned long, unsigned long, bool);
 extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
@@ -155,9 +156,6 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 	mem_cgroup_update_page_stat(page, idx, -1);
 }
 
-unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-						gfp_t gfp_mask,
-						unsigned long *total_scanned);
 u64 mem_cgroup_get_limit(struct mem_cgroup *memcg);
 
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
@@ -362,22 +360,20 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
 }
 
-static inline void mem_cgroup_inc_page_stat(struct page *page,
-					    enum mem_cgroup_page_stat_item idx)
+static inline bool
+mem_cgroup_over_softlimit(struct mem_cgroup *root, struct mem_cgroup *memcg)
 {
+	return false;
 }
 
-static inline void mem_cgroup_dec_page_stat(struct page *page,
+static inline void mem_cgroup_inc_page_stat(struct page *page,
 					    enum mem_cgroup_page_stat_item idx)
 {
 }
 
-static inline
-unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-					    gfp_t gfp_mask,
-					    unsigned long *total_scanned)
+static inline void mem_cgroup_dec_page_stat(struct page *page,
+					    enum mem_cgroup_page_stat_item idx)
 {
-	return 0;
 }
 
 static inline
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 170dff4..d4f7ae5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -35,7 +35,6 @@
 #include <linux/limits.h>
 #include <linux/export.h>
 #include <linux/mutex.h>
-#include <linux/rbtree.h>
 #include <linux/slab.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
@@ -118,12 +117,10 @@ enum mem_cgroup_events_index {
  */
 enum mem_cgroup_events_target {
 	MEM_CGROUP_TARGET_THRESH,
-	MEM_CGROUP_TARGET_SOFTLIMIT,
 	MEM_CGROUP_TARGET_NUMAINFO,
 	MEM_CGROUP_NTARGETS,
 };
 #define THRESHOLDS_EVENTS_TARGET (128)
-#define SOFTLIMIT_EVENTS_TARGET (1024)
 #define NUMAINFO_EVENTS_TARGET	(1024)
 
 struct mem_cgroup_stat_cpu {
@@ -149,12 +146,6 @@ struct mem_cgroup_per_zone {
 	struct mem_cgroup_reclaim_iter reclaim_iter[DEF_PRIORITY + 1];
 
 	struct zone_reclaim_stat reclaim_stat;
-	struct rb_node		tree_node;	/* RB tree node */
-	unsigned long long	usage_in_excess;/* Set to the value by which */
-						/* the soft limit is exceeded*/
-	bool			on_tree;
-	struct mem_cgroup	*mem;		/* Back pointer, we cannot */
-						/* use container_of	   */
 };
 /* Macro for accessing counter */
 #define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
@@ -167,26 +158,6 @@ struct mem_cgroup_lru_info {
 	struct mem_cgroup_per_node *nodeinfo[MAX_NUMNODES];
 };
 
-/*
- * Cgroups above their limits are maintained in a RB-Tree, independent of
- * their hierarchy representation
- */
-
-struct mem_cgroup_tree_per_zone {
-	struct rb_root rb_root;
-	spinlock_t lock;
-};
-
-struct mem_cgroup_tree_per_node {
-	struct mem_cgroup_tree_per_zone rb_tree_per_zone[MAX_NR_ZONES];
-};
-
-struct mem_cgroup_tree {
-	struct mem_cgroup_tree_per_node *rb_tree_per_node[MAX_NUMNODES];
-};
-
-static struct mem_cgroup_tree soft_limit_tree __read_mostly;
-
 struct mem_cgroup_threshold {
 	struct eventfd_ctx *eventfd;
 	u64 threshold;
@@ -343,7 +314,6 @@ static bool move_file(void)
  * limit reclaim to prevent infinite loops, if they ever occur.
  */
 #define	MEM_CGROUP_MAX_RECLAIM_LOOPS		(100)
-#define	MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS	(2)
 
 enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
@@ -398,164 +368,6 @@ page_cgroup_zoneinfo(struct mem_cgroup *memcg, struct page *page)
 	return mem_cgroup_zoneinfo(memcg, nid, zid);
 }
 
-static struct mem_cgroup_tree_per_zone *
-soft_limit_tree_node_zone(int nid, int zid)
-{
-	return &soft_limit_tree.rb_tree_per_node[nid]->rb_tree_per_zone[zid];
-}
-
-static struct mem_cgroup_tree_per_zone *
-soft_limit_tree_from_page(struct page *page)
-{
-	int nid = page_to_nid(page);
-	int zid = page_zonenum(page);
-
-	return &soft_limit_tree.rb_tree_per_node[nid]->rb_tree_per_zone[zid];
-}
-
-static void
-__mem_cgroup_insert_exceeded(struct mem_cgroup *memcg,
-				struct mem_cgroup_per_zone *mz,
-				struct mem_cgroup_tree_per_zone *mctz,
-				unsigned long long new_usage_in_excess)
-{
-	struct rb_node **p = &mctz->rb_root.rb_node;
-	struct rb_node *parent = NULL;
-	struct mem_cgroup_per_zone *mz_node;
-
-	if (mz->on_tree)
-		return;
-
-	mz->usage_in_excess = new_usage_in_excess;
-	if (!mz->usage_in_excess)
-		return;
-	while (*p) {
-		parent = *p;
-		mz_node = rb_entry(parent, struct mem_cgroup_per_zone,
-					tree_node);
-		if (mz->usage_in_excess < mz_node->usage_in_excess)
-			p = &(*p)->rb_left;
-		/*
-		 * We can't avoid mem cgroups that are over their soft
-		 * limit by the same amount
-		 */
-		else if (mz->usage_in_excess >= mz_node->usage_in_excess)
-			p = &(*p)->rb_right;
-	}
-	rb_link_node(&mz->tree_node, parent, p);
-	rb_insert_color(&mz->tree_node, &mctz->rb_root);
-	mz->on_tree = true;
-}
-
-static void
-__mem_cgroup_remove_exceeded(struct mem_cgroup *memcg,
-				struct mem_cgroup_per_zone *mz,
-				struct mem_cgroup_tree_per_zone *mctz)
-{
-	if (!mz->on_tree)
-		return;
-	rb_erase(&mz->tree_node, &mctz->rb_root);
-	mz->on_tree = false;
-}
-
-static void
-mem_cgroup_remove_exceeded(struct mem_cgroup *memcg,
-				struct mem_cgroup_per_zone *mz,
-				struct mem_cgroup_tree_per_zone *mctz)
-{
-	spin_lock(&mctz->lock);
-	__mem_cgroup_remove_exceeded(memcg, mz, mctz);
-	spin_unlock(&mctz->lock);
-}
-
-
-static void mem_cgroup_update_tree(struct mem_cgroup *memcg, struct page *page)
-{
-	unsigned long long excess;
-	struct mem_cgroup_per_zone *mz;
-	struct mem_cgroup_tree_per_zone *mctz;
-	int nid = page_to_nid(page);
-	int zid = page_zonenum(page);
-	mctz = soft_limit_tree_from_page(page);
-
-	/*
-	 * Necessary to update all ancestors when hierarchy is used.
-	 * because their event counter is not touched.
-	 */
-	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
-		mz = mem_cgroup_zoneinfo(memcg, nid, zid);
-		excess = res_counter_soft_limit_excess(&memcg->res);
-		/*
-		 * We have to update the tree if mz is on RB-tree or
-		 * mem is over its softlimit.
-		 */
-		if (excess || mz->on_tree) {
-			spin_lock(&mctz->lock);
-			/* if on-tree, remove it */
-			if (mz->on_tree)
-				__mem_cgroup_remove_exceeded(memcg, mz, mctz);
-			/*
-			 * Insert again. mz->usage_in_excess will be updated.
-			 * If excess is 0, no tree ops.
-			 */
-			__mem_cgroup_insert_exceeded(memcg, mz, mctz, excess);
-			spin_unlock(&mctz->lock);
-		}
-	}
-}
-
-static void mem_cgroup_remove_from_trees(struct mem_cgroup *memcg)
-{
-	int node, zone;
-	struct mem_cgroup_per_zone *mz;
-	struct mem_cgroup_tree_per_zone *mctz;
-
-	for_each_node_state(node, N_POSSIBLE) {
-		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
-			mz = mem_cgroup_zoneinfo(memcg, node, zone);
-			mctz = soft_limit_tree_node_zone(node, zone);
-			mem_cgroup_remove_exceeded(memcg, mz, mctz);
-		}
-	}
-}
-
-static struct mem_cgroup_per_zone *
-__mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
-{
-	struct rb_node *rightmost = NULL;
-	struct mem_cgroup_per_zone *mz;
-
-retry:
-	mz = NULL;
-	rightmost = rb_last(&mctz->rb_root);
-	if (!rightmost)
-		goto done;		/* Nothing to reclaim from */
-
-	mz = rb_entry(rightmost, struct mem_cgroup_per_zone, tree_node);
-	/*
-	 * Remove the node now but someone else can add it back,
-	 * we will to add it back at the end of reclaim to its correct
-	 * position in the tree.
-	 */
-	__mem_cgroup_remove_exceeded(mz->mem, mz, mctz);
-	if (!res_counter_soft_limit_excess(&mz->mem->res) ||
-		!css_tryget(&mz->mem->css))
-		goto retry;
-done:
-	return mz;
-}
-
-static struct mem_cgroup_per_zone *
-mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
-{
-	struct mem_cgroup_per_zone *mz;
-
-	spin_lock(&mctz->lock);
-	mz = __mem_cgroup_largest_soft_limit_node(mctz);
-	spin_unlock(&mctz->lock);
-	return mz;
-}
-
 /*
  * Implementation Note: reading percpu statistics for memcg.
  *
@@ -696,9 +508,6 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
 		case MEM_CGROUP_TARGET_THRESH:
 			next = val + THRESHOLDS_EVENTS_TARGET;
 			break;
-		case MEM_CGROUP_TARGET_SOFTLIMIT:
-			next = val + SOFTLIMIT_EVENTS_TARGET;
-			break;
 		case MEM_CGROUP_TARGET_NUMAINFO:
 			next = val + NUMAINFO_EVENTS_TARGET;
 			break;
@@ -718,13 +527,11 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
 static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
 {
 	preempt_disable();
-	/* threshold event is triggered in finer grain than soft limit */
+	/* threshold event is triggered in finer grain than numa info */
 	if (unlikely(mem_cgroup_event_ratelimit(memcg,
 						MEM_CGROUP_TARGET_THRESH))) {
-		bool do_softlimit, do_numainfo;
+		bool do_numainfo;
 
-		do_softlimit = mem_cgroup_event_ratelimit(memcg,
-						MEM_CGROUP_TARGET_SOFTLIMIT);
 #if MAX_NUMNODES > 1
 		do_numainfo = mem_cgroup_event_ratelimit(memcg,
 						MEM_CGROUP_TARGET_NUMAINFO);
@@ -732,8 +539,6 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
 		preempt_enable();
 
 		mem_cgroup_threshold(memcg);
-		if (unlikely(do_softlimit))
-			mem_cgroup_update_tree(memcg, page);
 #if MAX_NUMNODES > 1
 		if (unlikely(do_numainfo))
 			atomic_inc(&memcg->numainfo_events);
@@ -1318,6 +1123,36 @@ static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
 	return margin >> PAGE_SHIFT;
 }
 
+/**
+ * mem_cgroup_over_softlimit
+ * @root: hierarchy root
+ * @memcg: child of @root to test
+ *
+ * Returns %true if @memcg exceeds its own soft limit or contributes
+ * to the soft limit excess of one of its parents up to and including
+ * @root.
+ */
+bool mem_cgroup_over_softlimit(struct mem_cgroup *root,
+			       struct mem_cgroup *memcg)
+{
+	if (mem_cgroup_disabled())
+		return false;
+
+	if (!root)
+		root = root_mem_cgroup;
+
+	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
+		/* root_mem_cgroup does not have a soft limit */
+		if (memcg == root_mem_cgroup)
+			break;
+		if (res_counter_soft_limit_excess(&memcg->res))
+			return true;
+		if (memcg == root)
+			break;
+	}
+	return false;
+}
+
 int mem_cgroup_swappiness(struct mem_cgroup *memcg)
 {
 	struct cgroup *cgrp = memcg->css.cgroup;
@@ -1687,64 +1522,6 @@ bool mem_cgroup_reclaimable(struct mem_cgroup *memcg, bool noswap)
 }
 #endif
 
-static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
-				   struct zone *zone,
-				   gfp_t gfp_mask,
-				   unsigned long *total_scanned)
-{
-	struct mem_cgroup *victim = NULL;
-	int total = 0;
-	int loop = 0;
-	unsigned long excess;
-	unsigned long nr_scanned;
-	struct mem_cgroup_reclaim_cookie reclaim = {
-		.zone = zone,
-		.priority = 0,
-	};
-
-	excess = res_counter_soft_limit_excess(&root_memcg->res) >> PAGE_SHIFT;
-
-	while (1) {
-		unsigned long nr_reclaimed;
-
-		victim = mem_cgroup_iter(root_memcg, victim, &reclaim);
-		if (!victim) {
-			loop++;
-			if (loop >= 2) {
-				/*
-				 * If we have not been able to reclaim
-				 * anything, it might because there are
-				 * no reclaimable pages under this hierarchy
-				 */
-				if (!total)
-					break;
-				/*
-				 * We want to do more targeted reclaim.
-				 * excess >> 2 is not to excessive so as to
-				 * reclaim too much, nor too less that we keep
-				 * coming back to reclaim from this cgroup
-				 */
-				if (total >= (excess >> 2) ||
-					(loop > MEM_CGROUP_MAX_RECLAIM_LOOPS))
-					break;
-			}
-			continue;
-		}
-		if (!mem_cgroup_reclaimable(victim, false))
-			continue;
-		nr_reclaimed = mem_cgroup_shrink_node_zone(victim, gfp_mask, false,
-							   zone, &nr_scanned);
-		mem_cgroup_account_reclaim(root_mem_cgroup, victim, nr_reclaimed,
-					   nr_scanned, current_is_kswapd());
-		total += nr_reclaimed;
-		*total_scanned += nr_scanned;
-		if (!res_counter_soft_limit_excess(&root_memcg->res))
-			break;
-	}
-	mem_cgroup_iter_break(root_memcg, victim);
-	return total;
-}
-
 /*
  * Check OOM-Killer is already running under our hierarchy.
  * If someone is running, return false.
@@ -2507,8 +2284,6 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 	unlock_page_cgroup(pc);
 	/*
 	 * "charge_statistics" updated event counter. Then, check it.
-	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
-	 * if they exceeds softlimit.
 	 */
 	memcg_check_events(memcg, page);
 }
@@ -3578,98 +3353,6 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 	return ret;
 }
 
-unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-					    gfp_t gfp_mask,
-					    unsigned long *total_scanned)
-{
-	unsigned long nr_reclaimed = 0;
-	struct mem_cgroup_per_zone *mz, *next_mz = NULL;
-	unsigned long reclaimed;
-	int loop = 0;
-	struct mem_cgroup_tree_per_zone *mctz;
-	unsigned long long excess;
-	unsigned long nr_scanned;
-
-	if (order > 0)
-		return 0;
-
-	mctz = soft_limit_tree_node_zone(zone_to_nid(zone), zone_idx(zone));
-	/*
-	 * This loop can run a while, specially if mem_cgroup's continuously
-	 * keep exceeding their soft limit and putting the system under
-	 * pressure
-	 */
-	do {
-		if (next_mz)
-			mz = next_mz;
-		else
-			mz = mem_cgroup_largest_soft_limit_node(mctz);
-		if (!mz)
-			break;
-
-		nr_scanned = 0;
-		reclaimed = mem_cgroup_soft_reclaim(mz->mem, zone,
-						    gfp_mask, &nr_scanned);
-		nr_reclaimed += reclaimed;
-		*total_scanned += nr_scanned;
-		spin_lock(&mctz->lock);
-
-		/*
-		 * If we failed to reclaim anything from this memory cgroup
-		 * it is time to move on to the next cgroup
-		 */
-		next_mz = NULL;
-		if (!reclaimed) {
-			do {
-				/*
-				 * Loop until we find yet another one.
-				 *
-				 * By the time we get the soft_limit lock
-				 * again, someone might have aded the
-				 * group back on the RB tree. Iterate to
-				 * make sure we get a different mem.
-				 * mem_cgroup_largest_soft_limit_node returns
-				 * NULL if no other cgroup is present on
-				 * the tree
-				 */
-				next_mz =
-				__mem_cgroup_largest_soft_limit_node(mctz);
-				if (next_mz == mz)
-					css_put(&next_mz->mem->css);
-				else /* next_mz == NULL or other memcg */
-					break;
-			} while (1);
-		}
-		__mem_cgroup_remove_exceeded(mz->mem, mz, mctz);
-		excess = res_counter_soft_limit_excess(&mz->mem->res);
-		/*
-		 * One school of thought says that we should not add
-		 * back the node to the tree if reclaim returns 0.
-		 * But our reclaim could return 0, simply because due
-		 * to priority we are exposing a smaller subset of
-		 * memory to reclaim from. Consider this as a longer
-		 * term TODO.
-		 */
-		/* If excess == 0, no tree ops */
-		__mem_cgroup_insert_exceeded(mz->mem, mz, mctz, excess);
-		spin_unlock(&mctz->lock);
-		css_put(&mz->mem->css);
-		loop++;
-		/*
-		 * Could not reclaim anything and there are no more
-		 * mem cgroups to try or we seem to be looping without
-		 * reclaiming anything.
-		 */
-		if (!nr_reclaimed &&
-			(next_mz == NULL ||
-			loop > MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS))
-			break;
-	} while (!nr_reclaimed);
-	if (next_mz)
-		css_put(&next_mz->mem->css);
-	return nr_reclaimed;
-}
-
 /*
  * This routine traverse page_cgroup in given list and drop them all.
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
@@ -4816,9 +4499,6 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 		mz = &pn->zoneinfo[zone];
 		for_each_lru(l)
 			INIT_LIST_HEAD(&mz->lruvec.lists[l]);
-		mz->usage_in_excess = 0;
-		mz->on_tree = false;
-		mz->mem = memcg;
 	}
 	memcg->info.nodeinfo[node] = pn;
 	return 0;
@@ -4872,7 +4552,6 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 {
 	int node;
 
-	mem_cgroup_remove_from_trees(memcg);
 	free_css_id(&mem_cgroup_subsys, &memcg->css);
 
 	for_each_node_state(node, N_POSSIBLE)
@@ -4927,31 +4606,6 @@ static void __init enable_swap_cgroup(void)
 }
 #endif
 
-static int mem_cgroup_soft_limit_tree_init(void)
-{
-	struct mem_cgroup_tree_per_node *rtpn;
-	struct mem_cgroup_tree_per_zone *rtpz;
-	int tmp, node, zone;
-
-	for_each_node_state(node, N_POSSIBLE) {
-		tmp = node;
-		if (!node_state(node, N_NORMAL_MEMORY))
-			tmp = -1;
-		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, tmp);
-		if (!rtpn)
-			return 1;
-
-		soft_limit_tree.rb_tree_per_node[node] = rtpn;
-
-		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
-			rtpz = &rtpn->rb_tree_per_zone[zone];
-			rtpz->rb_root = RB_ROOT;
-			spin_lock_init(&rtpz->lock);
-		}
-	}
-	return 0;
-}
-
 static struct cgroup_subsys_state * __ref
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
@@ -4973,8 +4627,6 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 		enable_swap_cgroup();
 		parent = NULL;
 		root_mem_cgroup = memcg;
-		if (mem_cgroup_soft_limit_tree_init())
-			goto free_out;
 		for_each_possible_cpu(cpu) {
 			struct memcg_stock_pcp *stock =
 						&per_cpu(memcg_stock, cpu);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e3fd8a7..4279549 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2121,8 +2121,16 @@ static void shrink_zone(int priority, struct zone *zone,
 			.mem_cgroup = memcg,
 			.zone = zone,
 		};
+		int epriority = priority;
+		/*
+		 * Put more pressure on hierarchies that exceed their
+		 * soft limit, to push them back harder than their
+		 * well-behaving siblings.
+		 */
+		if (mem_cgroup_over_softlimit(root, memcg))
+			epriority = 0;
 
-		shrink_mem_cgroup_zone(priority, &mz, sc);
+		shrink_mem_cgroup_zone(epriority, &mz, sc);
 
 		mem_cgroup_account_reclaim(root, memcg,
 					   sc->nr_reclaimed - nr_reclaimed,
@@ -2171,8 +2179,6 @@ static bool shrink_zones(int priority, struct zonelist *zonelist,
 {
 	struct zoneref *z;
 	struct zone *zone;
-	unsigned long nr_soft_reclaimed;
-	unsigned long nr_soft_scanned;
 	bool should_abort_reclaim = false;
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
@@ -2205,19 +2211,6 @@ static bool shrink_zones(int priority, struct zonelist *zonelist,
 					continue;
 				}
 			}
-			/*
-			 * This steals pages from memory cgroups over softlimit
-			 * and returns the number of reclaimed pages and
-			 * scanned pages. This works for global memory pressure
-			 * and balancing, not for a memcg's limit.
-			 */
-			nr_soft_scanned = 0;
-			nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
-						sc->order, sc->gfp_mask,
-						&nr_soft_scanned);
-			sc->nr_reclaimed += nr_soft_reclaimed;
-			sc->nr_scanned += nr_soft_scanned;
-			/* need some check for avoid more shrink_zone() */
 		}
 
 		shrink_zone(priority, zone, sc);
@@ -2393,48 +2386,6 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 }
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
-
-unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
-						gfp_t gfp_mask, bool noswap,
-						struct zone *zone,
-						unsigned long *nr_scanned)
-{
-	struct scan_control sc = {
-		.nr_scanned = 0,
-		.nr_to_reclaim = SWAP_CLUSTER_MAX,
-		.may_writepage = !laptop_mode,
-		.may_unmap = 1,
-		.may_swap = !noswap,
-		.order = 0,
-		.target_mem_cgroup = memcg,
-	};
-	struct mem_cgroup_zone mz = {
-		.mem_cgroup = memcg,
-		.zone = zone,
-	};
-
-	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
-			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
-
-	trace_mm_vmscan_memcg_softlimit_reclaim_begin(0,
-						      sc.may_writepage,
-						      sc.gfp_mask);
-
-	/*
-	 * NOTE: Although we can get the priority field, using it
-	 * here is not a good idea, since it limits the pages we can scan.
-	 * if we don't reclaim here, the shrink_zone from balance_pgdat
-	 * will pick up pages from other mem cgroup's as well. We hack
-	 * the priority and make it zero.
-	 */
-	shrink_mem_cgroup_zone(0, &mz, &sc);
-
-	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
-
-	*nr_scanned = sc.nr_scanned;
-	return sc.nr_reclaimed;
-}
-
 unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 					   gfp_t gfp_mask,
 					   bool noswap)
@@ -2609,8 +2560,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 	unsigned long total_scanned;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
-	unsigned long nr_soft_reclaimed;
-	unsigned long nr_soft_scanned;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.may_unmap = 1,
@@ -2701,17 +2650,6 @@ loop_again:
 				continue;
 
 			sc.nr_scanned = 0;
-
-			nr_soft_scanned = 0;
-			/*
-			 * Call soft limit reclaim before calling shrink_zone.
-			 */
-			nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
-							order, sc.gfp_mask,
-							&nr_soft_scanned);
-			sc.nr_reclaimed += nr_soft_reclaimed;
-			total_scanned += nr_soft_scanned;
-
 			/*
 			 * We put equal pressure on every zone, unless
 			 * one zone has way too many pages free
-- 
1.7.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
