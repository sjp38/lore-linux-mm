Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 442A190010C
	for <linux-mm@kvack.org>; Thu, 12 May 2011 10:54:49 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [rfc patch 6/6] memcg: rework soft limit reclaim
Date: Thu, 12 May 2011 16:53:58 +0200
Message-Id: <1305212038-15445-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

The current soft limit reclaim algorithm entered from kswapd.  It
selects the memcg that exceeds its soft limit the most in absolute
bytes and reclaims from it most aggressively (priority 0).

This has several disadvantages:

	1. because of the aggressiveness, kswapd can be stalled on a
	memcg that is hard to reclaim for a long time before going for
	other pages.

	2. it only considers the biggest violator (in absolute byes!)
	and does not put extra pressure on other memcgs in excess.

	3. it needs a ton of code to quickly find the target

This patch removes all the explicit soft limit target selection and
instead hooks into the hierarchical memcg walk that is done by direct
reclaim and kswapd balancing.  If it encounters a memcg that exceeds
its soft limit, or contributes to the soft limit excess in one of its
hierarchy parents, it scans the memcg one priority level below the
current reclaim priority.

	1. the primary goal is to reclaim pages, not to punish soft
	limit violators at any price

	2. increased pressure is applied to all violators, not just
	the biggest one

	3. the soft limit is no longer only meaningful on global
	memory pressure, but considered for any hierarchical reclaim.
	This means that even for hard limit reclaim, the children in
	excess of their soft limit experience more pressure compared
	to their siblings

	4. direct reclaim now also applies more pressure on memcgs in
	soft limit excess, not only kswapd

	5. the implementation is only a few lines of straight-forward
	code

RFC: since there is no longer a reliable way of counting the pages
reclaimed solely because of an exceeding soft limit, this patch
conflicts with Ying's exporting of exactly this number to userspace.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |   16 +-
 include/linux/swap.h       |    4 -
 mm/memcontrol.c            |  450 +++-----------------------------------------
 mm/vmscan.c                |   48 +-----
 4 files changed, 34 insertions(+), 484 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 65163c2..b0c7323 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -99,6 +99,7 @@ extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
  * For memory reclaim.
  */
 void mem_cgroup_hierarchy_walk(struct mem_cgroup *, struct mem_cgroup **);
+bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *, struct mem_cgroup *);
 void mem_cgroup_count_reclaim(struct mem_cgroup *, bool, bool,
 			      unsigned long, unsigned long);
 int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
@@ -140,8 +141,6 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 	mem_cgroup_update_page_stat(page, idx, -1);
 }
 
-unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-						gfp_t gfp_mask);
 u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -294,6 +293,12 @@ static inline void mem_cgroup_hierarchy_walk(struct mem_cgroup *start,
 	*iter = start;
 }
 
+static inline bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *root,
+						  struct mem_cgroup *mem)
+{
+	return 0;
+}
+
 static inline void mem_cgroup_count_reclaim(struct mem_cgroup *mem,
 					    bool kswapd, bool hierarchy,
 					    unsigned long scanned,
@@ -349,13 +354,6 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 }
 
 static inline
-unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-					    gfp_t gfp_mask)
-{
-	return 0;
-}
-
-static inline
 u64 mem_cgroup_get_limit(struct mem_cgroup *mem)
 {
 	return 0;
diff --git a/include/linux/swap.h b/include/linux/swap.h
index a5c6da5..885cf19 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -254,10 +254,6 @@ extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
 						  gfp_t gfp_mask, bool noswap,
 						  unsigned int swappiness);
-extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
-						gfp_t gfp_mask, bool noswap,
-						unsigned int swappiness,
-						struct zone *zone);
 extern int __isolate_lru_page(struct page *page, int mode, int file);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f5d90ba..b0c6dd5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -34,7 +34,6 @@
 #include <linux/rcupdate.h>
 #include <linux/limits.h>
 #include <linux/mutex.h>
-#include <linux/rbtree.h>
 #include <linux/slab.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
@@ -138,12 +137,6 @@ struct mem_cgroup_per_zone {
 	unsigned long		count[NR_LRU_LISTS];
 
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
@@ -156,26 +149,6 @@ struct mem_cgroup_lru_info {
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
@@ -323,12 +296,7 @@ static bool move_file(void)
 					&mc.to->move_charge_at_immigrate);
 }
 
-/*
- * Maximum loops in mem_cgroup_soft_reclaim(), used for soft
- * limit reclaim to prevent infinite loops, if they ever occur.
- */
 #define	MEM_CGROUP_MAX_RECLAIM_LOOPS		(100)
-#define	MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS	(2)
 
 enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
@@ -375,164 +343,6 @@ page_cgroup_zoneinfo(struct mem_cgroup *mem, struct page *page)
 	return mem_cgroup_zoneinfo(mem, nid, zid);
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
-__mem_cgroup_insert_exceeded(struct mem_cgroup *mem,
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
-__mem_cgroup_remove_exceeded(struct mem_cgroup *mem,
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
-mem_cgroup_remove_exceeded(struct mem_cgroup *mem,
-				struct mem_cgroup_per_zone *mz,
-				struct mem_cgroup_tree_per_zone *mctz)
-{
-	spin_lock(&mctz->lock);
-	__mem_cgroup_remove_exceeded(mem, mz, mctz);
-	spin_unlock(&mctz->lock);
-}
-
-
-static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct page *page)
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
-	for (; mem; mem = parent_mem_cgroup(mem)) {
-		mz = mem_cgroup_zoneinfo(mem, nid, zid);
-		excess = res_counter_soft_limit_excess(&mem->res);
-		/*
-		 * We have to update the tree if mz is on RB-tree or
-		 * mem is over its softlimit.
-		 */
-		if (excess || mz->on_tree) {
-			spin_lock(&mctz->lock);
-			/* if on-tree, remove it */
-			if (mz->on_tree)
-				__mem_cgroup_remove_exceeded(mem, mz, mctz);
-			/*
-			 * Insert again. mz->usage_in_excess will be updated.
-			 * If excess is 0, no tree ops.
-			 */
-			__mem_cgroup_insert_exceeded(mem, mz, mctz, excess);
-			spin_unlock(&mctz->lock);
-		}
-	}
-}
-
-static void mem_cgroup_remove_from_trees(struct mem_cgroup *mem)
-{
-	int node, zone;
-	struct mem_cgroup_per_zone *mz;
-	struct mem_cgroup_tree_per_zone *mctz;
-
-	for_each_node_state(node, N_POSSIBLE) {
-		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
-			mz = mem_cgroup_zoneinfo(mem, node, zone);
-			mctz = soft_limit_tree_node_zone(node, zone);
-			mem_cgroup_remove_exceeded(mem, mz, mctz);
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
@@ -570,15 +380,6 @@ static long mem_cgroup_read_stat(struct mem_cgroup *mem,
 	return val;
 }
 
-static long mem_cgroup_local_usage(struct mem_cgroup *mem)
-{
-	long ret;
-
-	ret = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_RSS);
-	ret += mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_CACHE);
-	return ret;
-}
-
 static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
 					 bool charge)
 {
@@ -699,7 +500,6 @@ static void memcg_check_events(struct mem_cgroup *mem, struct page *page)
 		__mem_cgroup_target_update(mem, MEM_CGROUP_TARGET_THRESH);
 		if (unlikely(__memcg_event_check(mem,
 			MEM_CGROUP_TARGET_SOFTLIMIT))){
-			mem_cgroup_update_tree(mem, page);
 			__mem_cgroup_target_update(mem,
 				MEM_CGROUP_TARGET_SOFTLIMIT);
 		}
@@ -1380,6 +1180,29 @@ void mem_cgroup_hierarchy_walk(struct mem_cgroup *start,
 	*iter = mem;
 }
 
+bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *root,
+				    struct mem_cgroup *mem)
+{
+	/* root_mem_cgroup never exceeds its soft limit */
+	if (!mem)
+		return false;
+	if (!root)
+		root = root_mem_cgroup;
+	/*
+	 * See whether the memcg in question exceeds its soft limit
+	 * directly, or contributes to the soft limit excess in the
+	 * hierarchy below the given root.
+	 */
+	while (mem != root) {
+		if (res_counter_soft_limit_excess(&mem->res))
+			return true;
+		if (!mem->use_hierarchy)
+			break;
+		mem = mem_cgroup_from_cont(mem->css.cgroup->parent);
+	}
+	return false;
+}
+
 static unsigned long mem_cgroup_target_reclaim(struct mem_cgroup *mem,
 					       gfp_t gfp_mask,
 					       bool noswap,
@@ -1411,114 +1234,6 @@ static unsigned long mem_cgroup_target_reclaim(struct mem_cgroup *mem,
 }
 
 /*
- * Visit the first child (need not be the first child as per the ordering
- * of the cgroup list, since we track last_scanned_child) of @mem and use
- * that to reclaim free pages from.
- */
-static struct mem_cgroup *
-mem_cgroup_select_victim(struct mem_cgroup *root_mem)
-{
-	struct mem_cgroup *ret = NULL;
-	struct cgroup_subsys_state *css;
-	int nextid, found;
-
-	if (!root_mem->use_hierarchy) {
-		css_get(&root_mem->css);
-		ret = root_mem;
-	}
-
-	while (!ret) {
-		rcu_read_lock();
-		nextid = root_mem->last_scanned_child + 1;
-		css = css_get_next(&mem_cgroup_subsys, nextid, &root_mem->css,
-				   &found);
-		if (css && css_tryget(css))
-			ret = container_of(css, struct mem_cgroup, css);
-
-		rcu_read_unlock();
-		/* Updates scanning parameter */
-		if (!css) {
-			/* this means start scan from ID:1 */
-			root_mem->last_scanned_child = 0;
-		} else
-			root_mem->last_scanned_child = found;
-	}
-
-	return ret;
-}
-
-/*
- * Scan the hierarchy if needed to reclaim memory. We remember the last child
- * we reclaimed from, so that we don't end up penalizing one child extensively
- * based on its position in the children list.
- *
- * root_mem is the original ancestor that we've been reclaim from.
- *
- * We give up and return to the caller when we visit root_mem twice.
- * (other groups can be removed while we're walking....)
- */
-static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_mem,
-				   struct zone *zone,
-				   gfp_t gfp_mask)
-{
-	struct mem_cgroup *victim;
-	int ret, total = 0;
-	int loop = 0;
-	unsigned long excess;
-	bool noswap = false;
-
-	excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;
-
-	/* If memsw_is_minimum==1, swap-out is of-no-use. */
-	if (root_mem->memsw_is_minimum)
-		noswap = true;
-
-	while (1) {
-		victim = mem_cgroup_select_victim(root_mem);
-		if (victim == root_mem) {
-			loop++;
-			if (loop >= 1)
-				drain_all_stock_async();
-			if (loop >= 2) {
-				/*
-				 * If we have not been able to reclaim
-				 * anything, it might because there are
-				 * no reclaimable pages under this hierarchy
-				 */
-				if (!total) {
-					css_put(&victim->css);
-					break;
-				}
-				/*
-				 * We want to do more targeted reclaim.
-				 * excess >> 2 is not to excessive so as to
-				 * reclaim too much, nor too less that we keep
-				 * coming back to reclaim from this cgroup
-				 */
-				if (total >= (excess >> 2) ||
-					(loop > MEM_CGROUP_MAX_RECLAIM_LOOPS)) {
-					css_put(&victim->css);
-					break;
-				}
-			}
-		}
-		if (!mem_cgroup_local_usage(victim)) {
-			/* this cgroup's local usage == 0 */
-			css_put(&victim->css);
-			continue;
-		}
-		/* we use swappiness of local cgroup */
-		ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
-				noswap, get_swappiness(victim), zone);
-		css_put(&victim->css);
-		total += ret;
-		if (!res_counter_soft_limit_excess(&root_mem->res))
-			return total;
-	}
-	return total;
-}
-
-/*
  * Check OOM-Killer is already running under our hierarchy.
  * If someone is running, return false.
  */
@@ -3291,94 +3006,6 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 	return ret;
 }
 
-unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-					    gfp_t gfp_mask)
-{
-	unsigned long nr_reclaimed = 0;
-	struct mem_cgroup_per_zone *mz, *next_mz = NULL;
-	unsigned long reclaimed;
-	int loop = 0;
-	struct mem_cgroup_tree_per_zone *mctz;
-	unsigned long long excess;
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
-		reclaimed = mem_cgroup_soft_reclaim(mz->mem, zone, gfp_mask);
-		nr_reclaimed += reclaimed;
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
-				if (next_mz == mz) {
-					css_put(&next_mz->mem->css);
-					next_mz = NULL;
-				} else /* next_mz == NULL or other memcg */
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
@@ -4449,9 +4076,6 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
 		mz = &pn->zoneinfo[zone];
 		for_each_lru(l)
 			INIT_LIST_HEAD(&mz->lruvec.lists[l]);
-		mz->usage_in_excess = 0;
-		mz->on_tree = false;
-		mz->mem = mem;
 	}
 	return 0;
 }
@@ -4504,7 +4128,6 @@ static void __mem_cgroup_free(struct mem_cgroup *mem)
 {
 	int node;
 
-	mem_cgroup_remove_from_trees(mem);
 	free_css_id(&mem_cgroup_subsys, &mem->css);
 
 	for_each_node_state(node, N_POSSIBLE)
@@ -4559,31 +4182,6 @@ static void __init enable_swap_cgroup(void)
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
@@ -4605,8 +4203,6 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 		enable_swap_cgroup();
 		parent = NULL;
 		root_mem_cgroup = mem;
-		if (mem_cgroup_soft_limit_tree_init())
-			goto free_out;
 		for_each_possible_cpu(cpu) {
 			struct memcg_stock_pcp *stock =
 						&per_cpu(memcg_stock, cpu);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0381a5d..2b701e0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1937,10 +1937,13 @@ static void shrink_zone(int priority, struct zone *zone,
 	do {
 		unsigned long reclaimed = sc->nr_reclaimed;
 		unsigned long scanned = sc->nr_scanned;
+		int epriority = priority;
 
 		mem_cgroup_hierarchy_walk(root, &mem);
 		sc->current_memcg = mem;
-		do_shrink_zone(priority, zone, sc);
+		if (mem_cgroup_soft_limit_exceeded(root, mem))
+			epriority -= 1;
+		do_shrink_zone(epriority, zone, sc);
 		mem_cgroup_count_reclaim(mem, current_is_kswapd(),
 					 mem != root, /* limit or hierarchy? */
 					 sc->nr_scanned - scanned,
@@ -2153,42 +2156,6 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 }
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
-
-unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
-						gfp_t gfp_mask, bool noswap,
-						unsigned int swappiness,
-						struct zone *zone)
-{
-	struct scan_control sc = {
-		.nr_to_reclaim = SWAP_CLUSTER_MAX,
-		.may_writepage = !laptop_mode,
-		.may_unmap = 1,
-		.may_swap = !noswap,
-		.swappiness = swappiness,
-		.order = 0,
-		.memcg = mem,
-	};
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
-	do_shrink_zone(0, zone, &sc);
-
-	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
-
-	return sc.nr_reclaimed;
-}
-
 unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 					   gfp_t gfp_mask,
 					   bool noswap,
@@ -2418,13 +2385,6 @@ loop_again:
 				continue;
 
 			sc.nr_scanned = 0;
-
-			/*
-			 * Call soft limit reclaim before calling shrink_zone.
-			 * For now we ignore the return value
-			 */
-			mem_cgroup_soft_limit_reclaim(zone, order, sc.gfp_mask);
-
 			/*
 			 * We put equal pressure on every zone, unless
 			 * one zone has way too many pages free
-- 
1.7.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
