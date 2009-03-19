Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0E2126B005A
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 12:58:10 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2JGw4qK009603
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 22:28:04 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2JGsfpD1065132
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 22:24:41 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2JGw32R019306
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 03:58:03 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 19 Mar 2009 22:27:52 +0530
Message-Id: <20090319165752.27274.36030.sendpatchset@localhost.localdomain>
In-Reply-To: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
Subject: [PATCH 5/5] Memory controller soft limit reclaim on contention (v7)
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Feature: Implement reclaim from groups over their soft limit

From: Balbir Singh <balbir@linux.vnet.ibm.com>

Changelog v7...v6
1. Refactored out reclaim_options patch into a separate patch
2. Added additional checks for all swap off condition in
   mem_cgroup_hierarchical_reclaim()

Changelog v6...v5
1. Reclaim arguments to hierarchical reclaim have been merged into one
   parameter called reclaim_options.
2. Check if we failed to reclaim from one cgroup during soft reclaim, if
   so move on to the next one. This can be very useful if the zonelist
   passed to soft limit reclaim has no allocations from the selected
   memory cgroup
3. Coding style cleanups

Changelog v5...v4

1. Throttling is removed, earlier we throttled tasks over their soft limit
2. Reclaim has been moved back to __alloc_pages_internal, several experiments
   and tests showed that it was the best place to reclaim memory. kswapd has
   a different goal, that does not work with a single soft limit for the memory
   cgroup.
3. Soft limit reclaim is more targetted and the pages reclaim depend on the
   amount by which the soft limit is exceeded.

Changelog v4...v3
1. soft_reclaim is now called from balance_pgdat
2. soft_reclaim is aware of nodes and zones
3. A mem_cgroup will be throttled if it is undergoing soft limit reclaim
   and at the same time trying to allocate pages and exceed its soft limit.
4. A new mem_cgroup_shrink_zone() routine has been added to shrink zones
   particular to a mem cgroup.

Changelog v3...v2
1. Convert several arguments to hierarchical reclaim to flags, thereby
   consolidating them
2. The reclaim for soft limits is now triggered from kswapd
3. try_to_free_mem_cgroup_pages() now accepts an optional zonelist argument


Changelog v2...v1
1. Added support for hierarchical soft limits

This patch allows reclaim from memory cgroups on contention (via the
direct reclaim path).

memory cgroup soft limit reclaim finds the group that exceeds its soft limit
by the largest number of pages and reclaims pages from it and then reinserts the
cgroup into its correct place in the rbtree.

Added additional checks to mem_cgroup_hierarchical_reclaim() to detect
long loops in case all swap is turned off. The code has been refactored
and the loop check (loop < 2) has been enhanced for soft limits. For soft
limits, we try to do more targetted reclaim. Instead of bailing out after
two loops, the routine now reclaims memory proportional to the size by
which the soft limit is exceeded. The proportion has been empirically
determined.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/memcontrol.h |    8 ++
 include/linux/swap.h       |    1 
 mm/memcontrol.c            |  202 +++++++++++++++++++++++++++++++++++++++++---
 mm/page_alloc.c            |    9 ++
 mm/vmscan.c                |    5 +
 5 files changed, 206 insertions(+), 19 deletions(-)


diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 18146c9..faeb358 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -116,6 +116,8 @@ static inline bool mem_cgroup_disabled(void)
 }
 
 extern bool mem_cgroup_oom_called(struct task_struct *task);
+unsigned long mem_cgroup_soft_limit_reclaim(struct zonelist *zl,
+						gfp_t gfp_mask);
 
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
@@ -264,6 +266,12 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
 }
 
+static inline
+unsigned long mem_cgroup_soft_limit_reclaim(struct zonelist *zl, gfp_t gfp_mask)
+{
+	return 0;
+}
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 989eb53..c128337 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -215,6 +215,7 @@ static inline void lru_cache_add_active_file(struct page *page)
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
+						  struct zonelist *zl,
 						  gfp_t gfp_mask, bool noswap,
 						  unsigned int swappiness);
 extern int __isolate_lru_page(struct page *page, int mode, int file);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 992aac8..aeab794 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -191,6 +191,7 @@ struct mem_cgroup {
 	unsigned long last_tree_update;		/* Last time the tree was */
 						/* updated in jiffies     */
 
+	bool on_tree;				/* Is the node on tree? */
 	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
@@ -199,6 +200,13 @@ struct mem_cgroup {
 
 #define	MEM_CGROUP_TREE_UPDATE_INTERVAL		(HZ/4)
 
+/*
+ * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
+ * limit reclaim to prevent infinite loops, if they ever occur.
+ */
+#define	MEM_CGROUP_MAX_RECLAIM_LOOPS		(10000)
+#define	MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS	(2)
+
 enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
 	MEM_CGROUP_CHARGE_TYPE_MAPPED,
@@ -234,19 +242,22 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
 #define MEM_CGROUP_RECLAIM_NOSWAP	(1 << MEM_CGROUP_RECLAIM_NOSWAP_BIT)
 #define MEM_CGROUP_RECLAIM_SHRINK_BIT	0x1
 #define MEM_CGROUP_RECLAIM_SHRINK	(1 << MEM_CGROUP_RECLAIM_SHRINK_BIT)
+#define MEM_CGROUP_RECLAIM_SOFT_BIT	0x2
+#define MEM_CGROUP_RECLAIM_SOFT		(1 << MEM_CGROUP_RECLAIM_SOFT_BIT)
 
 static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
 
-static void mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
+static void __mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
 {
 	struct rb_node **p = &mem_cgroup_soft_limit_tree.rb_node;
 	struct rb_node *parent = NULL;
 	struct mem_cgroup *mem_node;
-	unsigned long flags;
 
-	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
+	if (mem->on_tree)
+		return;
+
 	mem->usage_in_excess = res_counter_soft_limit_excess(&mem->res);
 	while (*p) {
 		parent = *p;
@@ -264,6 +275,23 @@ static void mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
 	rb_insert_color(&mem->mem_cgroup_node,
 			&mem_cgroup_soft_limit_tree);
 	mem->last_tree_update = jiffies;
+	mem->on_tree = true;
+}
+
+static void __mem_cgroup_remove_exceeded(struct mem_cgroup *mem)
+{
+	if (!mem->on_tree)
+		return;
+	rb_erase(&mem->mem_cgroup_node, &mem_cgroup_soft_limit_tree);
+	mem->on_tree = false;
+}
+
+static void mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
+	__mem_cgroup_insert_exceeded(mem);
 	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
 }
 
@@ -271,7 +299,53 @@ static void mem_cgroup_remove_exceeded(struct mem_cgroup *mem)
 {
 	unsigned long flags;
 	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
-	rb_erase(&mem->mem_cgroup_node, &mem_cgroup_soft_limit_tree);
+	__mem_cgroup_remove_exceeded(mem);
+	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
+}
+
+unsigned long mem_cgroup_get_excess(struct mem_cgroup *mem)
+{
+	unsigned long flags;
+	unsigned long long excess;
+
+	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
+	excess = mem->usage_in_excess >> PAGE_SHIFT;
+	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
+	return (excess > ULONG_MAX) ? ULONG_MAX : excess;
+}
+
+static struct mem_cgroup *__mem_cgroup_largest_soft_limit_node(void)
+{
+	struct rb_node *rightmost = NULL;
+	struct mem_cgroup *mem = NULL;
+
+retry:
+	rightmost = rb_last(&mem_cgroup_soft_limit_tree);
+	if (!rightmost)
+		goto done;		/* Nothing to reclaim from */
+
+	mem = rb_entry(rightmost, struct mem_cgroup, mem_cgroup_node);
+	/*
+	 * Remove the node now but someone else can add it back,
+	 * we will to add it back at the end of reclaim to its correct
+	 * position in the tree.
+	 */
+	__mem_cgroup_remove_exceeded(mem);
+	if (!css_tryget(&mem->css) || !res_counter_soft_limit_excess(&mem->res))
+		goto retry;
+done:
+	return mem;
+}
+
+static struct mem_cgroup *mem_cgroup_largest_soft_limit_node(void)
+{
+	struct mem_cgroup *mem;
+	unsigned long flags;
+
+	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
+	mem = __mem_cgroup_largest_soft_limit_node();
+	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
+	return mem;
 	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
 }
 
@@ -897,6 +971,7 @@ mem_cgroup_select_victim(struct mem_cgroup *root_mem)
  * If shrink==true, for avoiding to free too much, this returns immedieately.
  */
 static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
+						struct zonelist *zl,
 						gfp_t gfp_mask,
 						unsigned long reclaim_options)
 {
@@ -905,19 +980,41 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 	int loop = 0;
 	bool noswap = reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP;
 	bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
+	bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
+	unsigned long excess = mem_cgroup_get_excess(root_mem);
 
-	while (loop < 2) {
+	while (1) {
 		victim = mem_cgroup_select_victim(root_mem);
-		if (victim == root_mem)
+		if (victim == root_mem) {
 			loop++;
+			if (loop >= 2) {
+				/*
+				 * If we have not been able to reclaim
+				 * anything, it might because there are
+				 * no reclaimable pages under this hierarchy
+				 */
+				if (!check_soft || !total)
+					break;
+				/*
+				 * We want to do more targetted reclaim.
+				 * excess >> 2 is not to excessive so as to
+				 * reclaim too much, nor too less that we keep
+				 * coming back to reclaim from this cgroup
+				 */
+				if (total >= (excess >> 2) ||
+					(loop > MEM_CGROUP_MAX_RECLAIM_LOOPS))
+					break;
+			}
+		}
 		if (!mem_cgroup_local_usage(&victim->stat)) {
 			/* this cgroup's local usage == 0 */
 			css_put(&victim->css);
 			continue;
 		}
 		/* we use swappiness of local cgroup */
-		ret = try_to_free_mem_cgroup_pages(victim, gfp_mask, noswap,
-						   get_swappiness(victim));
+		ret = try_to_free_mem_cgroup_pages(victim, zl, gfp_mask,
+							noswap,
+							get_swappiness(victim));
 		css_put(&victim->css);
 		/*
 		 * At shrinking usage, we can't check we should stop here or
@@ -927,7 +1024,10 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 		if (shrink)
 			return ret;
 		total += ret;
-		if (mem_cgroup_check_under_limit(root_mem))
+		if (check_soft) {
+			if (res_counter_check_under_soft_limit(&root_mem->res))
+				return total;
+		} else if (mem_cgroup_check_under_limit(root_mem))
 			return 1 + total;
 	}
 	return total;
@@ -1064,8 +1164,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 		if (!(gfp_mask & __GFP_WAIT))
 			goto nomem;
 
-		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
-							flags);
+		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
+							gfp_mask, flags);
 		if (ret)
 			continue;
 
@@ -1776,7 +1876,7 @@ int mem_cgroup_shrink_usage(struct page *page,
 		return 0;
 
 	do {
-		progress = mem_cgroup_hierarchical_reclaim(mem,
+		progress = mem_cgroup_hierarchical_reclaim(mem, NULL,
 					gfp_mask, MEM_CGROUP_RECLAIM_NOSWAP);
 		progress += mem_cgroup_check_under_limit(mem);
 	} while (!progress && --retry);
@@ -1831,8 +1931,9 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
-		progress = mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL,
-						   MEM_CGROUP_RECLAIM_SHRINK);
+		progress = mem_cgroup_hierarchical_reclaim(memcg, NULL,
+						GFP_KERNEL,
+						MEM_CGROUP_RECLAIM_SHRINK);
 		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
 		/* Usage is reduced ? */
   		if (curusage >= oldusage)
@@ -1880,7 +1981,7 @@ int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
-		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL,
+		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
 						MEM_CGROUP_RECLAIM_NOSWAP |
 						MEM_CGROUP_RECLAIM_SHRINK);
 		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
@@ -1893,6 +1994,73 @@ int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 	return ret;
 }
 
+unsigned long mem_cgroup_soft_limit_reclaim(struct zonelist *zl, gfp_t gfp_mask)
+{
+	unsigned long nr_reclaimed = 0;
+	struct mem_cgroup *mem, *next_mem = NULL;
+	unsigned long flags;
+	unsigned long reclaimed;
+	int loop = 0;
+
+	/*
+	 * This loop can run a while, specially if mem_cgroup's continuously
+	 * keep exceeding their soft limit and putting the system under
+	 * pressure
+	 */
+	do {
+		if (next_mem)
+			mem = next_mem;
+		else
+			mem = mem_cgroup_largest_soft_limit_node();
+		if (!mem)
+			break;
+
+		reclaimed = mem_cgroup_hierarchical_reclaim(mem, zl,
+						gfp_mask,
+						MEM_CGROUP_RECLAIM_SOFT);
+		nr_reclaimed += reclaimed;
+		spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
+
+		/*
+		 * If we failed to reclaim anything from this memory cgroup
+		 * it is time to move on to the next cgroup
+		 */
+		next_mem = NULL;
+		if (!reclaimed) {
+			do {
+				/*
+				 * By the time we get the soft_limit lock
+				 * again, someone might have aded the
+				 * group back on the RB tree. Iterate to
+				 * make sure we get a different mem.
+				 * mem_cgroup_largest_soft_limit_node returns
+				 * NULL if no other cgroup is present on
+				 * the tree
+				 */
+				next_mem =
+					__mem_cgroup_largest_soft_limit_node();
+			} while (next_mem == mem);
+		}
+		mem->usage_in_excess = res_counter_soft_limit_excess(&mem->res);
+		__mem_cgroup_remove_exceeded(mem);
+		if (mem->usage_in_excess)
+			__mem_cgroup_insert_exceeded(mem);
+		spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
+		css_put(&mem->css);
+		loop++;
+		/*
+		 * Could not reclaim anything and there are no more
+		 * mem cgroups to try or we seem to be looping without
+		 * reclaiming anything.
+		 */
+		if (!nr_reclaimed &&
+			(next_mem == NULL ||
+			loop > MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS))
+			break;
+	} while (!nr_reclaimed);
+	return nr_reclaimed;
+}
+
 /*
  * This routine traverse page_cgroup in given list and drop them all.
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
@@ -2016,7 +2184,7 @@ try_to_free:
 			ret = -EINTR;
 			goto out;
 		}
-		progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
+		progress = try_to_free_mem_cgroup_pages(mem, NULL, GFP_KERNEL,
 						false, get_swappiness(mem));
 		if (!progress) {
 			nr_retries--;
@@ -2621,6 +2789,8 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	mem->last_scanned_child = 0;
 	mem->usage_in_excess = 0;
 	mem->last_tree_update = 0;	/* Yes, time begins at 0 here */
+	mem->on_tree = false;
+
 	spin_lock_init(&mem->reclaim_param_lock);
 
 	if (parent)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f8fd1e2..5e1a6ca 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1598,7 +1598,14 @@ nofail_alloc:
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
+	/*
+	 * Try to free up some pages from the memory controllers soft
+	 * limit queue.
+	 */
+	did_some_progress = mem_cgroup_soft_limit_reclaim(zonelist, gfp_mask);
+	if (order || !did_some_progress)
+		did_some_progress += try_to_free_pages(zonelist, order,
+							gfp_mask);
 
 	p->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5b560f9..0acd19d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1708,6 +1708,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 
 unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
+					   struct zonelist *zonelist,
 					   gfp_t gfp_mask,
 					   bool noswap,
 					   unsigned int swappiness)
@@ -1721,14 +1722,14 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 		.mem_cgroup = mem_cont,
 		.isolate_pages = mem_cgroup_isolate_pages,
 	};
-	struct zonelist *zonelist;
 
 	if (noswap)
 		sc.may_unmap = 0;
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
-	zonelist = NODE_DATA(numa_node_id())->node_zonelists;
+	if (!zonelist)
+		zonelist = NODE_DATA(numa_node_id())->node_zonelists;
 	return do_try_to_free_pages(zonelist, &sc);
 }
 #endif

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
