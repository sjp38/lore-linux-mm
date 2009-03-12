Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 97C316B004D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:56:43 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp09.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2CHVXoJ014995
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 23:01:33 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2CHrNwC4030590
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 23:23:23 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2CHuZYf032371
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 23:26:35 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 12 Mar 2009 23:26:31 +0530
Message-Id: <20090312175631.17890.30427.sendpatchset@localhost.localdomain>
In-Reply-To: <20090312175603.17890.52593.sendpatchset@localhost.localdomain>
References: <20090312175603.17890.52593.sendpatchset@localhost.localdomain>
Subject: [PATCH 4/4] Memory controller soft limit reclaim on contention (v5)
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Feature: Implement reclaim from groups over their soft limit

From: Balbir Singh <balbir@linux.vnet.ibm.com>

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
kswapd() path) only if the order is 0.

memory cgroup soft limit reclaim finds the group that exceeds its soft limit
by the largest amount and reclaims pages from it and then reinserts the
cgroup into its correct place in the rbtree.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/memcontrol.h |    7 +-
 include/linux/swap.h       |    1 
 mm/memcontrol.c            |  180 +++++++++++++++++++++++++++++++++++++++-----
 mm/page_alloc.c            |    9 ++
 mm/vmscan.c                |    5 +
 5 files changed, 179 insertions(+), 23 deletions(-)


diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 18146c9..c0aeab9 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -116,7 +116,8 @@ static inline bool mem_cgroup_disabled(void)
 }
 
 extern bool mem_cgroup_oom_called(struct task_struct *task);
-
+unsigned long mem_cgroup_soft_limit_reclaim(struct zonelist *zl,
+						gfp_t gfp_mask);
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 
@@ -264,6 +265,10 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
 }
 
+unsigned long mem_cgroup_soft_limit_reclaim(struct zonelist *zl, gfp_t gfp_mask)
+{
+	return 0;
+}
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
index 4e2a79e..941d57e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -20,6 +20,7 @@
 #include <linux/res_counter.h>
 #include <linux/memcontrol.h>
 #include <linux/cgroup.h>
+#include <linux/completion.h>
 #include <linux/mm.h>
 #include <linux/pagemap.h>
 #include <linux/smp.h>
@@ -191,6 +192,7 @@ struct mem_cgroup {
 	unsigned long last_tree_update;		/* Last time the tree was */
 						/* updated in jiffies     */
 
+	bool on_tree;				/* Is the node on tree? */
 	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
@@ -227,18 +229,29 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
 #define MEMFILE_TYPE(val)	(((val) >> 16) & 0xffff)
 #define MEMFILE_ATTR(val)	((val) & 0xffff)
 
+/*
+ * Bits used for hierarchical reclaim bits
+ */
+#define MEM_CGROUP_RECLAIM_NOSWAP_BIT	0x0
+#define MEM_CGROUP_RECLAIM_NOSWAP	(1 << MEM_CGROUP_RECLAIM_NOSWAP_BIT)
+#define MEM_CGROUP_RECLAIM_SHRINK_BIT	0x1
+#define MEM_CGROUP_RECLAIM_SHRINK	(1 << MEM_CGROUP_RECLAIM_SHRINK_BIT)
+#define MEM_CGROUP_RECLAIM_SOFT_BIT	0x2
+#define MEM_CGROUP_RECLAIM_SOFT		(1 << MEM_CGROUP_RECLAIM_SOFT_BIT)
+
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
 	while (*p) {
 		parent = *p;
 		mem_node = rb_entry(parent, struct mem_cgroup, mem_cgroup_node);
@@ -255,6 +268,23 @@ static void mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
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
 
@@ -262,8 +292,53 @@ static void mem_cgroup_remove_exceeded(struct mem_cgroup *mem)
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
 	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
+	return mem;
 }
 
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
@@ -888,14 +963,39 @@ mem_cgroup_select_victim(struct mem_cgroup *root_mem)
  * If shrink==true, for avoiding to free too much, this returns immedieately.
  */
 static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
-				   gfp_t gfp_mask, bool noswap, bool shrink)
+						struct zonelist *zl,
+						gfp_t gfp_mask,
+						unsigned long flags)
 {
 	struct mem_cgroup *victim;
 	int ret, total = 0;
 	int loop = 0;
+	bool noswap = flags & MEM_CGROUP_RECLAIM_NOSWAP;
+	bool shrink = flags & MEM_CGROUP_RECLAIM_SHRINK;
+	bool check_soft = flags & MEM_CGROUP_RECLAIM_SOFT;
+	unsigned long excess = mem_cgroup_get_excess(root_mem);
 
-	while (loop < 2) {
+	while (1) {
+		if (loop >= 2) {
+			/*
+			 * With soft limits, do more targetted reclaim
+			 */
+			if (check_soft && (total >= (excess >> 4)))
+				break;
+			else if (!check_soft)
+				break;
+		}
 		victim = mem_cgroup_select_victim(root_mem);
+		/*
+		 * In the first loop, don't reclaim from victims below
+		 * their soft limit
+		 */
+		if (!loop && res_counter_check_under_soft_limit(&victim->res)) {
+			if (victim == root_mem)
+				loop++;
+			css_put(&victim->css);
+			continue;
+		}
 		if (victim == root_mem)
 			loop++;
 		if (!mem_cgroup_local_usage(&victim->stat)) {
@@ -904,8 +1004,9 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
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
@@ -915,7 +1016,10 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
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
@@ -1022,7 +1126,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 
 	while (1) {
 		int ret;
-		bool noswap = false;
+		unsigned long flags = 0;
 
 		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res,
 						&soft_fail_res);
@@ -1035,7 +1139,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 				break;
 			/* mem+swap counter fails */
 			res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
-			noswap = true;
+			flags = MEM_CGROUP_RECLAIM_NOSWAP;
 			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
 									memsw);
 		} else
@@ -1046,8 +1150,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 		if (!(gfp_mask & __GFP_WAIT))
 			goto nomem;
 
-		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
-							noswap, false);
+		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
+							gfp_mask, flags);
 		if (ret)
 			continue;
 
@@ -1741,8 +1845,8 @@ int mem_cgroup_shrink_usage(struct page *page,
 		return 0;
 
 	do {
-		progress = mem_cgroup_hierarchical_reclaim(mem,
-					gfp_mask, true, false);
+		progress = mem_cgroup_hierarchical_reclaim(mem, NULL,
+					gfp_mask, MEM_CGROUP_RECLAIM_NOSWAP);
 		progress += mem_cgroup_check_under_limit(mem);
 	} while (!progress && --retry);
 
@@ -1796,8 +1900,9 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
-		progress = mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL,
-						   false, true);
+		progress = mem_cgroup_hierarchical_reclaim(memcg, NULL,
+						GFP_KERNEL,
+						MEM_CGROUP_RECLAIM_SHRINK);
 		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
 		/* Usage is reduced ? */
   		if (curusage >= oldusage)
@@ -1845,7 +1950,9 @@ int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
-		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL, true, true);
+		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
+						MEM_CGROUP_RECLAIM_NOSWAP |
+						MEM_CGROUP_RECLAIM_SHRINK);
 		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
 		/* Usage is reduced ? */
 		if (curusage >= oldusage)
@@ -1856,6 +1963,39 @@ int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 	return ret;
 }
 
+unsigned long mem_cgroup_soft_limit_reclaim(struct zonelist *zl, gfp_t gfp_mask)
+{
+	unsigned long nr_reclaimed = 0;
+	struct mem_cgroup *mem;
+	unsigned long flags;
+	unsigned long reclaimed;
+
+	/*
+	 * This loop can run a while, specially if mem_cgroup's continuously
+	 * keep exceeding their soft limit and putting the system under
+	 * pressure
+	 */
+	do {
+		mem = mem_cgroup_largest_soft_limit_node();
+		if (!mem)
+			break;
+
+		reclaimed = mem_cgroup_hierarchical_reclaim(mem, zl,
+						gfp_mask,
+						MEM_CGROUP_RECLAIM_SOFT);
+		nr_reclaimed += reclaimed;
+		spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
+		mem->usage_in_excess = res_counter_soft_limit_excess(&mem->res);
+		__mem_cgroup_remove_exceeded(mem);
+		if (mem->usage_in_excess)
+			__mem_cgroup_insert_exceeded(mem);
+		spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
+		css_put(&mem->css);
+		cond_resched();
+	} while (!nr_reclaimed);
+	return nr_reclaimed;
+}
+
 /*
  * This routine traverse page_cgroup in given list and drop them all.
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
@@ -1979,7 +2119,7 @@ try_to_free:
 			ret = -EINTR;
 			goto out;
 		}
-		progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
+		progress = try_to_free_mem_cgroup_pages(mem, NULL, GFP_KERNEL,
 						false, get_swappiness(mem));
 		if (!progress) {
 			nr_retries--;
@@ -2584,6 +2724,8 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	mem->last_scanned_child = 0;
 	mem->usage_in_excess = 0;
 	mem->last_tree_update = 0;	/* Yes, time begins at 0 here */
+	mem->on_tree = false;
+
 	spin_lock_init(&mem->reclaim_param_lock);
 
 	if (parent)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 46bd24c..b49c90f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1583,7 +1583,14 @@ nofail_alloc:
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
+	/*
+	 * Try to free up some pages from the memory controllers soft
+	 * limit queue.
+	 */
+	did_some_progress = mem_cgroup_soft_limit_reclaim(zonelist, gfp_mask);
+	if (!order || !did_some_progress)
+		did_some_progress += try_to_free_pages(zonelist, order,
+							gfp_mask);
 
 	p->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
diff --git a/mm/vmscan.c b/mm/vmscan.c
index bfd853b..f212b30 100644
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
