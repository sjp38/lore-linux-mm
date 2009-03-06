Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 20A5A6B0102
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 04:24:49 -0500 (EST)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id n269MwQ0001276
	for <linux-mm@kvack.org>; Fri, 6 Mar 2009 20:22:58 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n269OtYt438770
	for <linux-mm@kvack.org>; Fri, 6 Mar 2009 20:24:57 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n269Ob4T025528
	for <linux-mm@kvack.org>; Fri, 6 Mar 2009 20:24:38 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Fri, 06 Mar 2009 14:53:53 +0530
Message-Id: <20090306092353.21063.11068.sendpatchset@localhost.localdomain>
In-Reply-To: <20090306092323.21063.93169.sendpatchset@localhost.localdomain>
References: <20090306092323.21063.93169.sendpatchset@localhost.localdomain>
Subject: [PATCH 4/4] Memory controller soft limit reclaim on contention (v4)
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Feature: Implement reclaim from groups over their soft limit

From: Balbir Singh <balbir@linux.vnet.ibm.com>

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

 include/linux/memcontrol.h |    9 ++
 include/linux/swap.h       |    5 +
 mm/memcontrol.c            |  223 +++++++++++++++++++++++++++++++++++++++++---
 mm/vmscan.c                |   26 +++++
 4 files changed, 245 insertions(+), 18 deletions(-)


diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 18146c9..16343d0 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -116,6 +116,9 @@ static inline bool mem_cgroup_disabled(void)
 }
 
 extern bool mem_cgroup_oom_called(struct task_struct *task);
+unsigned long
+mem_cgroup_soft_limit_reclaim(int priority, struct zone *zone, int nid,
+				gfp_t gfp_mask);
 
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
@@ -264,6 +267,12 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
 }
 
+static inline unsigned long
+mem_cgroup_soft_limit_reclaim(int priority, struct zone *zone, int nid,
+				gfp_t gfp_mask)
+{
+	return 0;
+}
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 989eb53..37bc2a9 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -217,6 +217,11 @@ extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
 						  gfp_t gfp_mask, bool noswap,
 						  unsigned int swappiness);
+extern unsigned long mem_cgroup_shrink_zone(struct mem_cgroup *mem,
+						struct zone *zone,
+						gfp_t gfp_mask,
+						unsigned int swappiness,
+						int priority);
 extern int __isolate_lru_page(struct page *page, int mode, int file);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d548dd2..3be1f27 100644
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
@@ -191,6 +192,14 @@ struct mem_cgroup {
 	unsigned long last_tree_update;		/* Last time the tree was */
 						/* updated in jiffies     */
 
+	bool on_tree;				/* Is the node on tree? */
+	struct completion wait_on_soft_reclaim;
+	/*
+	 * Set to > 0, when reclaim is initiated due to 
+	 * the soft limit being exceeded. It adds an additional atomic
+	 * operation to page fault path.
+	 */
+	int soft_limit_reclaim_count;
 	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
@@ -227,18 +236,29 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
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
@@ -255,6 +275,23 @@ static void mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
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
 
@@ -262,8 +299,34 @@ static void mem_cgroup_remove_exceeded(struct mem_cgroup *mem)
 {
 	unsigned long flags;
 	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
-	rb_erase(&mem->mem_cgroup_node, &mem_cgroup_soft_limit_tree);
+	__mem_cgroup_remove_exceeded(mem);
+	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
+}
+
+static struct mem_cgroup *mem_cgroup_get_largest_soft_limit_exceeding_node(void)
+{
+	struct rb_node *rightmost = NULL;
+	struct mem_cgroup *mem = NULL;
+	unsigned long flags;
+
+	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
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
 	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
+	return mem;
 }
 
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
@@ -324,6 +387,27 @@ static unsigned long mem_cgroup_get_local_zonestat(struct mem_cgroup *mem,
 	return total;
 }
 
+static unsigned long long
+mem_cgroup_get_node_zone_usage(struct mem_cgroup *mem, struct zone *zone,
+				int nid)
+{
+	int l;
+	unsigned long long total = 0;
+	struct mem_cgroup_per_zone *mz;
+	unsigned long flags;
+
+	/*
+	 * Is holding the zone LRU lock being overly protective?
+	 * This routine is not invoked from the hot path anyway.
+	 */
+	spin_lock_irqsave(&zone->lru_lock, flags);
+	mz = mem_cgroup_zoneinfo(mem, nid, zone_idx(zone));
+	for_each_evictable_lru(l)
+		total += MEM_CGROUP_ZSTAT(mz, l);
+	spin_unlock_irqrestore(&zone->lru_lock, flags);
+	return total * PAGE_SIZE;
+}
+
 static struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
 {
 	return container_of(cgroup_subsys_state(cont,
@@ -888,14 +972,30 @@ mem_cgroup_select_victim(struct mem_cgroup *root_mem)
  * If shrink==true, for avoiding to free too much, this returns immedieately.
  */
 static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
-				   gfp_t gfp_mask, bool noswap, bool shrink)
+						struct zone *zone,
+						gfp_t gfp_mask,
+						unsigned long flags,
+						int priority)
 {
 	struct mem_cgroup *victim;
 	int ret, total = 0;
 	int loop = 0;
+	bool noswap = flags & MEM_CGROUP_RECLAIM_NOSWAP;
+	bool shrink = flags & MEM_CGROUP_RECLAIM_SHRINK;
+	bool check_soft = flags & MEM_CGROUP_RECLAIM_SOFT;
 
 	while (loop < 2) {
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
@@ -904,8 +1004,14 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 			continue;
 		}
 		/* we use swappiness of local cgroup */
-		ret = try_to_free_mem_cgroup_pages(victim, gfp_mask, noswap,
-						   get_swappiness(victim));
+		if (!check_soft)
+			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
+							noswap,
+							get_swappiness(victim));
+		else
+			ret = mem_cgroup_shrink_zone(victim, zone, gfp_mask,
+							get_swappiness(victim),
+							priority);
 		css_put(&victim->css);
 		/*
 		 * At shrinking usage, we can't check we should stop here or
@@ -915,7 +1021,10 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
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
@@ -1025,7 +1134,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 
 	while (1) {
 		int ret;
-		bool noswap = false;
+		unsigned long flags = 0;
 
 		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res,
 						&soft_fail_res);
@@ -1038,7 +1147,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 				break;
 			/* mem+swap counter fails */
 			res_counter_uncharge(&mem->res, PAGE_SIZE);
-			noswap = true;
+			flags = MEM_CGROUP_RECLAIM_NOSWAP;
 			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
 									memsw);
 		} else
@@ -1049,8 +1158,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 		if (!(gfp_mask & __GFP_WAIT))
 			goto nomem;
 
-		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
-							noswap, false);
+		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
+							gfp_mask, flags, 0);
 		if (ret)
 			continue;
 
@@ -1082,9 +1191,29 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 	 * soft limit
 	 */
 	if (soft_fail_res) {
+		/*
+		 * Throttle the task here, if it is undergoing soft limit
+		 * reclaim and failing soft limits
+		 */
+		unsigned long flags;
+		bool wait = false;
+
+		spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
+		if (mem->soft_limit_reclaim_count) {
+			INIT_COMPLETION(mem->wait_on_soft_reclaim);
+			wait = true;
+		}
+		spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
 		mem_over_soft_limit =
 			mem_cgroup_from_res_counter(soft_fail_res, res);
 		mem_cgroup_check_and_update_tree(mem_over_soft_limit, true);
+		/*
+		 * We hold the mmap_sem and throttle, I don't think there
+		 * should be corner cases, but this part could use more
+		 * review
+		 */
+		if (wait)
+			wait_for_completion(&mem->wait_on_soft_reclaim);
 	}
 	return 0;
 nomem:
@@ -1695,8 +1824,8 @@ int mem_cgroup_shrink_usage(struct page *page,
 		return 0;
 
 	do {
-		progress = mem_cgroup_hierarchical_reclaim(mem,
-					gfp_mask, true, false);
+		progress = mem_cgroup_hierarchical_reclaim(mem, NULL,
+					gfp_mask, MEM_CGROUP_RECLAIM_NOSWAP, 0);
 		progress += mem_cgroup_check_under_limit(mem);
 	} while (!progress && --retry);
 
@@ -1750,8 +1879,9 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
-		progress = mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL,
-						   false, true);
+		progress = mem_cgroup_hierarchical_reclaim(memcg, NULL,
+						GFP_KERNEL,
+						MEM_CGROUP_RECLAIM_SHRINK, 0);
 		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
 		/* Usage is reduced ? */
   		if (curusage >= oldusage)
@@ -1799,7 +1929,9 @@ int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
-		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL, true, true);
+		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
+						MEM_CGROUP_RECLAIM_NOSWAP |
+						MEM_CGROUP_RECLAIM_SHRINK, 0);
 		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
 		/* Usage is reduced ? */
 		if (curusage >= oldusage)
@@ -1810,6 +1942,59 @@ int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 	return ret;
 }
 
+unsigned long
+mem_cgroup_soft_limit_reclaim(int priority, struct zone *zone, int nid,
+				gfp_t gfp_mask)
+{
+	unsigned long nr_reclaimed = 0;
+	struct mem_cgroup *mem;
+	unsigned long flags;
+	unsigned long long usage;
+
+	/*
+	 * This loop can run a while, specially if mem_cgroup's continuously
+	 * keep exceeding their soft limit and putting the system under
+	 * pressure
+	 */
+	do {
+		mem = mem_cgroup_get_largest_soft_limit_exceeding_node();
+		if (!mem)
+			break;
+		usage = mem_cgroup_get_node_zone_usage(mem, zone, nid);
+		if (!usage)
+			goto skip_reclaim;
+		spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
+		mem->soft_limit_reclaim_count++;
+		spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
+		nr_reclaimed += mem_cgroup_hierarchical_reclaim(mem, zone,
+						gfp_mask,
+						MEM_CGROUP_RECLAIM_SOFT,
+						priority);
+skip_reclaim:
+		spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
+		/*
+		 * Don't wake up throttled tasks unless we reclaimed from
+		 * them
+		 */
+		if (usage)
+			mem->soft_limit_reclaim_count--;
+		mem->usage_in_excess = res_counter_soft_limit_excess(&mem->res);
+		/*
+		 * We need to remove and reinsert the node in its correct
+		 * position
+		 */
+		__mem_cgroup_remove_exceeded(mem);
+		if (mem->usage_in_excess)
+			__mem_cgroup_insert_exceeded(mem);
+		spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
+		if (usage)
+			complete_all(&mem->wait_on_soft_reclaim);
+		css_put(&mem->css);
+		cond_resched();
+	} while (!nr_reclaimed);
+	return nr_reclaimed;
+}
+
 /*
  * This routine traverse page_cgroup in given list and drop them all.
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
@@ -2538,6 +2723,10 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	mem->last_scanned_child = 0;
 	mem->usage_in_excess = 0;
 	mem->last_tree_update = 0;	/* Yes, time begins at 0 here */
+	mem->on_tree = false;
+	init_completion(&mem->wait_on_soft_reclaim);
+	mem->soft_limit_reclaim_count = 0;
+
 	spin_lock_init(&mem->reclaim_param_lock);
 
 	if (parent)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 83f2ca4..2b8cdad 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1737,6 +1737,26 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 	zonelist = NODE_DATA(numa_node_id())->node_zonelists;
 	return do_try_to_free_pages(zonelist, &sc);
 }
+
+unsigned long mem_cgroup_shrink_zone(struct mem_cgroup *mem,
+					struct zone *zone, gfp_t gfp_mask,
+					unsigned int swappiness,
+					int priority)
+{
+	struct scan_control sc = {
+		.may_writepage = !laptop_mode,
+		.may_unmap = 1,
+		.swap_cluster_max = SWAP_CLUSTER_MAX,
+		.swappiness = swappiness,
+		.order = 0,
+		.mem_cgroup = mem,
+		.isolate_pages = mem_cgroup_isolate_pages,
+	};
+	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
+			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
+	shrink_zone(priority, zone, &sc);
+	return sc.nr_reclaimed;
+}
 #endif
 
 /*
@@ -1870,7 +1890,11 @@ loop_again:
 			 */
 			if (!zone_watermark_ok(zone, order, 8*zone->pages_high,
 						end_zone, 0))
-				shrink_zone(priority, zone, &sc);
+				if ((priority >= DEF_PRIORITY/2) ||
+					!mem_cgroup_soft_limit_reclaim(priority,
+						zone, pgdat->node_id,
+						GFP_KERNEL))
+					shrink_zone(priority, zone, &sc);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
 						lru_pages);

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
