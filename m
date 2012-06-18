Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 1651B6B0068
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 12:47:33 -0400 (EDT)
Received: by ghbg15 with SMTP id g15so447900ghb.2
        for <linux-mm@kvack.org>; Mon, 18 Jun 2012 09:47:32 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V5 1/5] mm: memcg softlimit reclaim rework
Date: Mon, 18 Jun 2012 09:47:27 -0700
Message-Id: <1340038051-29502-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

This patch reverts all the existing softlimit reclaim implementations and
instead integrates the softlimit reclaim into existing global reclaim logic.

The new softlimit reclaim includes the following changes:

1. add function should_reclaim_mem_cgroup()

Add the filter function should_reclaim_mem_cgroup() under the common function
shrink_zone(). The later one is being called both from per-memcg reclaim as
well as global reclaim.

Today the softlimit takes effect only under global memory pressure. The memcgs
get free run above their softlimit until there is a global memory contention.
This patch doesn't change the semantics.

Under the global reclaim, we try to skip reclaiming from a memcg under its
softlimit. To prevent reclaim from trying too hard on hitting memcgs
(above softlimit) w/ only hard-to-reclaim pages, the reclaim priority is used
to skip the softlimit check. This is a trade-off of system performance and
resource isolation.

2. "hierarchical" softlimit reclaim

This is consistant to how softlimit was previously implemented, where the
pressure is put for the whole hiearchy as long as the "root" of the hierarchy
over its softlimit.

This part is not in my previous posts, and is quite different from my
understanding of softlimit reclaim. After quite a lot of discussions with
Johannes and Michal, i decided to go with it for now. And this is designed
to work with both trusted setups and untrusted setups.

What's the trusted and untrusted setups ?

case 1 : Administrator is the only one setting up the limits and also he
expects gurantees of memory under each cgroup's softlimit:

Considering the following:

root (soft: unlimited, use_hierarchy = 1)
  -- A (soft: unlimited, usage 22G)
      -- A1 (soft: 10G, usage 17G)
      -- A2 (soft: 6G, usage 5G)
  -- B (soft: 16G, usage 10G)

So we have A1 above its softlimit and none of its ancestor does, then
global reclaim will only pick A1 to reclaim first.

case 2: Untrusted enviroment where cgroups changes its softlimit or
adminstrator could make mistakes. In that case, we still want to attack the
mis-configured child if its parent is above softlimit.

Considering the following:

root (soft: unlimited, use_hierarchy = 1)
  -- A (soft: 16G, usage 22G)
      -- A1 (soft: 10G, usage 17G)
      -- A2 (soft: 1000G, usage 5G)
  -- B (soft: 16G, usage 10G)

Here A2 would set its softlimit way higher than its parent, but the current
logic makes sure to still attack it when A exceeds its softlimit.

v4..v5:
1. rebase the patchset on memcg-dev tree
2. apply KOSAKI's patch on do_try_to_free_pages()

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |   18 +-
 include/linux/swap.h       |    4 -
 mm/memcontrol.c            |  455 +++-----------------------------------------
 mm/vmscan.c                |   82 ++-------
 4 files changed, 49 insertions(+), 510 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 0e495bc..2b0a4f2 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -124,6 +124,8 @@ extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 extern void mem_cgroup_replace_page_cache(struct page *oldpage,
 					struct page *newpage);
 
+extern bool should_reclaim_mem_cgroup(struct mem_cgroup *memcg);
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
 #endif
@@ -179,9 +181,6 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 	mem_cgroup_update_page_stat(page, idx, -1);
 }
 
-unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-						gfp_t gfp_mask,
-						unsigned long *total_scanned);
 u64 mem_cgroup_get_limit(struct mem_cgroup *memcg);
 
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
@@ -359,14 +358,6 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 }
 
 static inline
-unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-					    gfp_t gfp_mask,
-					    unsigned long *total_scanned)
-{
-	return 0;
-}
-
-static inline
 u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
 {
 	return 0;
@@ -384,6 +375,11 @@ static inline void mem_cgroup_replace_page_cache(struct page *oldpage,
 				struct page *newpage)
 {
 }
+static inline
+bool should_reclaim_mem_cgroup(struct mem_cgroup *memcg)
+{
+	return true;
+}
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 35c545c..8f38222 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -254,10 +254,6 @@ extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
 						  gfp_t gfp_mask, bool noswap);
-extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
-						gfp_t gfp_mask, bool noswap,
-						struct zone *zone,
-						unsigned long *nr_scanned);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c9d897a..dfe8fc3 100644
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
@@ -131,7 +130,6 @@ static const char * const mem_cgroup_events_names[] = {
  */
 enum mem_cgroup_events_target {
 	MEM_CGROUP_TARGET_THRESH,
-	MEM_CGROUP_TARGET_SOFTLIMIT,
 	MEM_CGROUP_TARGET_NUMAINFO,
 	MEM_CGROUP_NTARGETS,
 };
@@ -161,13 +159,6 @@ struct mem_cgroup_per_zone {
 	unsigned long		lru_size[NR_LRU_LISTS];
 
 	struct mem_cgroup_reclaim_iter reclaim_iter[DEF_PRIORITY + 1];
-
-	struct rb_node		tree_node;	/* RB tree node */
-	unsigned long long	usage_in_excess;/* Set to the value by which */
-						/* the soft limit is exceeded*/
-	bool			on_tree;
-	struct mem_cgroup	*memcg;		/* Back pointer, we cannot */
-						/* use container_of	   */
 };
 
 struct mem_cgroup_per_node {
@@ -178,26 +169,6 @@ struct mem_cgroup_lru_info {
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
@@ -383,12 +354,7 @@ static bool move_file(void)
 					&mc.to->move_charge_at_immigrate);
 }
 
-/*
- * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
- * limit reclaim to prevent infinite loops, if they ever occur.
- */
 #define	MEM_CGROUP_MAX_RECLAIM_LOOPS		100
-#define	MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS	2
 
 enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
@@ -425,12 +391,12 @@ enum charge_type {
 static void mem_cgroup_get(struct mem_cgroup *memcg);
 static void mem_cgroup_put(struct mem_cgroup *memcg);
 
+static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
 /* Writing them here to avoid exposing memcg's inner layout */
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
 #include <net/sock.h>
 #include <net/ip.h>
 
-static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
 void sock_update_memcg(struct sock *sk)
 {
 	if (mem_cgroup_sockets_enabled) {
@@ -522,164 +488,6 @@ page_cgroup_zoneinfo(struct mem_cgroup *memcg, struct page *page)
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
-	for_each_node(node) {
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
-	__mem_cgroup_remove_exceeded(mz->memcg, mz, mctz);
-	if (!res_counter_soft_limit_excess(&mz->memcg->res) ||
-		!css_tryget(&mz->memcg->css))
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
@@ -833,9 +641,6 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
 		case MEM_CGROUP_TARGET_THRESH:
 			next = val + THRESHOLDS_EVENTS_TARGET;
 			break;
-		case MEM_CGROUP_TARGET_SOFTLIMIT:
-			next = val + SOFTLIMIT_EVENTS_TARGET;
-			break;
 		case MEM_CGROUP_TARGET_NUMAINFO:
 			next = val + NUMAINFO_EVENTS_TARGET;
 			break;
@@ -858,11 +663,8 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
 	/* threshold event is triggered in finer grain than soft limit */
 	if (unlikely(mem_cgroup_event_ratelimit(memcg,
 						MEM_CGROUP_TARGET_THRESH))) {
-		bool do_softlimit;
 		bool do_numainfo __maybe_unused;
 
-		do_softlimit = mem_cgroup_event_ratelimit(memcg,
-						MEM_CGROUP_TARGET_SOFTLIMIT);
 #if MAX_NUMNODES > 1
 		do_numainfo = mem_cgroup_event_ratelimit(memcg,
 						MEM_CGROUP_TARGET_NUMAINFO);
@@ -870,8 +672,6 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
 		preempt_enable();
 
 		mem_cgroup_threshold(memcg);
-		if (unlikely(do_softlimit))
-			mem_cgroup_update_tree(memcg, page);
 #if MAX_NUMNODES > 1
 		if (unlikely(do_numainfo))
 			atomic_inc(&memcg->numainfo_events);
@@ -922,6 +722,31 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
 	return memcg;
 }
 
+bool should_reclaim_mem_cgroup(struct mem_cgroup *memcg)
+{
+	if (mem_cgroup_disabled())
+		return true;
+
+	/*
+	 * We treat the root cgroup special here to always reclaim pages.
+	 * Now root cgroup has its own lru, and the only chance to reclaim
+	 * pages from it is through global reclaim. note, root cgroup does
+	 * not trigger targeted reclaim.
+	 */
+	if (mem_cgroup_is_root(memcg))
+		return true;
+
+	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
+		/* This is global reclaim, stop at root cgroup */
+		if (mem_cgroup_is_root(memcg))
+			break;
+		if (res_counter_soft_limit_excess(&memcg->res))
+			return true;
+	}
+
+	return false;
+}
+
 /**
  * mem_cgroup_iter - iterate over memory cgroup hierarchy
  * @root: hierarchy root
@@ -1614,106 +1439,13 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
 	return node;
 }
 
-/*
- * Check all nodes whether it contains reclaimable pages or not.
- * For quick scan, we make use of scan_nodes. This will allow us to skip
- * unused nodes. But scan_nodes is lazily updated and may not cotain
- * enough new information. We need to do double check.
- */
-static bool mem_cgroup_reclaimable(struct mem_cgroup *memcg, bool noswap)
-{
-	int nid;
-
-	/*
-	 * quick check...making use of scan_node.
-	 * We can skip unused nodes.
-	 */
-	if (!nodes_empty(memcg->scan_nodes)) {
-		for (nid = first_node(memcg->scan_nodes);
-		     nid < MAX_NUMNODES;
-		     nid = next_node(nid, memcg->scan_nodes)) {
-
-			if (test_mem_cgroup_node_reclaimable(memcg, nid, noswap))
-				return true;
-		}
-	}
-	/*
-	 * Check rest of nodes.
-	 */
-	for_each_node_state(nid, N_HIGH_MEMORY) {
-		if (node_isset(nid, memcg->scan_nodes))
-			continue;
-		if (test_mem_cgroup_node_reclaimable(memcg, nid, noswap))
-			return true;
-	}
-	return false;
-}
-
 #else
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
 {
 	return 0;
 }
-
-static bool mem_cgroup_reclaimable(struct mem_cgroup *memcg, bool noswap)
-{
-	return test_mem_cgroup_node_reclaimable(memcg, 0, noswap);
-}
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
-		total += mem_cgroup_shrink_node_zone(victim, gfp_mask, false,
-						     zone, &nr_scanned);
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
@@ -2547,8 +2279,6 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 
 	/*
 	 * "charge_statistics" updated event counter. Then, check it.
-	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
-	 * if they exceeds softlimit.
 	 */
 	memcg_check_events(memcg, page);
 }
@@ -3702,98 +3432,6 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
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
-		reclaimed = mem_cgroup_soft_reclaim(mz->memcg, zone,
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
-					css_put(&next_mz->memcg->css);
-				else /* next_mz == NULL or other memcg */
-					break;
-			} while (1);
-		}
-		__mem_cgroup_remove_exceeded(mz->memcg, mz, mctz);
-		excess = res_counter_soft_limit_excess(&mz->memcg->res);
-		/*
-		 * One school of thought says that we should not add
-		 * back the node to the tree if reclaim returns 0.
-		 * But our reclaim could return 0, simply because due
-		 * to priority we are exposing a smaller subset of
-		 * memory to reclaim from. Consider this as a longer
-		 * term TODO.
-		 */
-		/* If excess == 0, no tree ops */
-		__mem_cgroup_insert_exceeded(mz->memcg, mz, mctz, excess);
-		spin_unlock(&mctz->lock);
-		css_put(&mz->memcg->css);
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
-		css_put(&next_mz->memcg->css);
-	return nr_reclaimed;
-}
-
 /*
  * This routine traverse page_cgroup in given list and drop them all.
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
@@ -4886,9 +4524,6 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
 		lruvec_init(&mz->lruvec, &NODE_DATA(node)->node_zones[zone]);
-		mz->usage_in_excess = 0;
-		mz->on_tree = false;
-		mz->memcg = memcg;
 	}
 	memcg->info.nodeinfo[node] = pn;
 	return 0;
@@ -4980,7 +4615,6 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 {
 	int node;
 
-	mem_cgroup_remove_from_trees(memcg);
 	free_css_id(&mem_cgroup_subsys, &memcg->css);
 
 	for_each_node(node)
@@ -5033,41 +4667,6 @@ static void __init enable_swap_cgroup(void)
 }
 #endif
 
-static int mem_cgroup_soft_limit_tree_init(void)
-{
-	struct mem_cgroup_tree_per_node *rtpn;
-	struct mem_cgroup_tree_per_zone *rtpz;
-	int tmp, node, zone;
-
-	for_each_node(node) {
-		tmp = node;
-		if (!node_state(node, N_NORMAL_MEMORY))
-			tmp = -1;
-		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, tmp);
-		if (!rtpn)
-			goto err_cleanup;
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
-
-err_cleanup:
-	for_each_node(node) {
-		if (!soft_limit_tree.rb_tree_per_node[node])
-			break;
-		kfree(soft_limit_tree.rb_tree_per_node[node]);
-		soft_limit_tree.rb_tree_per_node[node] = NULL;
-	}
-	return 1;
-
-}
-
 static struct cgroup_subsys_state * __ref
 mem_cgroup_create(struct cgroup *cont)
 {
@@ -5089,8 +4688,6 @@ mem_cgroup_create(struct cgroup *cont)
 		int cpu;
 		enable_swap_cgroup();
 		parent = NULL;
-		if (mem_cgroup_soft_limit_tree_init())
-			goto free_out;
 		root_mem_cgroup = memcg;
 		for_each_possible_cpu(cpu) {
 			struct memcg_stock_pcp *stock =
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b90ec2b..8c367e1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1832,7 +1832,22 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
 	do {
 		struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 
-		shrink_lruvec(lruvec, sc);
+		/*
+		 * Reclaim from mem_cgroup if any of these conditions are met:
+		 * - this is a targetted reclaim ( not global reclaim)
+		 * - reclaim priority is less than  DEF_PRIORITY - 2
+		 * - mem_cgroup or its ancestor ( not including root cgroup)
+		 * exceeds its soft limit
+		 *
+		 * Note: The priority check is a balance of how hard to
+		 * preserve the pages under softlimit. If the memcgs of the
+		 * zone having trouble to reclaim pages above their softlimit,
+		 * we have to reclaim under softlimit instead of burning more
+		 * cpu cycles.
+		 */
+		if (!global_reclaim(sc) || sc->priority < DEF_PRIORITY - 2 ||
+				should_reclaim_mem_cgroup(memcg))
+			shrink_lruvec(lruvec, sc);
 
 		/*
 		 * Limit reclaim has historically picked one memcg and
@@ -1913,8 +1928,6 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 {
 	struct zoneref *z;
 	struct zone *zone;
-	unsigned long nr_soft_reclaimed;
-	unsigned long nr_soft_scanned;
 	bool aborted_reclaim = false;
 
 	/*
@@ -1954,18 +1967,6 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
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
 			/* need some check for avoid more shrink_zone() */
 		}
 
@@ -2143,45 +2144,6 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 
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
-		.priority = 0,
-		.target_mem_cgroup = memcg,
-	};
-	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
-
-	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
-			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
-
-	trace_mm_vmscan_memcg_softlimit_reclaim_begin(sc.order,
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
-	shrink_lruvec(lruvec, &sc);
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
@@ -2352,8 +2314,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 	unsigned long total_scanned;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
-	unsigned long nr_soft_reclaimed;
-	unsigned long nr_soft_scanned;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.may_unmap = 1,
@@ -2455,16 +2415,6 @@ loop_again:
 
 			sc.nr_scanned = 0;
 
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
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
