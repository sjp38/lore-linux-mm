Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9ED586B009F
	for <linux-mm@kvack.org>; Sun,  1 Mar 2009 01:30:54 -0500 (EST)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp09.au.ibm.com (8.13.1/8.13.1) with ESMTP id n216K9mJ029771
	for <linux-mm@kvack.org>; Sun, 1 Mar 2009 17:20:09 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n216V8vA381306
	for <linux-mm@kvack.org>; Sun, 1 Mar 2009 17:31:08 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n216UoqA011060
	for <linux-mm@kvack.org>; Sun, 1 Mar 2009 17:30:51 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Sun, 01 Mar 2009 12:00:41 +0530
Message-Id: <20090301063041.31557.86588.sendpatchset@localhost.localdomain>
In-Reply-To: <20090301062959.31557.31079.sendpatchset@localhost.localdomain>
References: <20090301062959.31557.31079.sendpatchset@localhost.localdomain>
Subject: [PATCH 4/4] Memory controller soft limit reclaim on contention (v3)
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


From: Balbir Singh <balbir@linux.vnet.ibm.com>

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

 include/linux/memcontrol.h |    2 +
 include/linux/swap.h       |    1 
 mm/memcontrol.c            |  134 ++++++++++++++++++++++++++++++++++++++------
 mm/vmscan.c                |    8 ++-
 4 files changed, 125 insertions(+), 20 deletions(-)


diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 18146c9..bf12451 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -116,6 +116,8 @@ static inline bool mem_cgroup_disabled(void)
 }
 
 extern bool mem_cgroup_oom_called(struct task_struct *task);
+extern unsigned long mem_cgroup_soft_limit_reclaim(struct zonelist *zonelist,
+							gfp_t gfp_mask);
 
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 989eb53..d8c1c76 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -215,6 +215,7 @@ static inline void lru_cache_add_active_file(struct page *page)
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
+						  struct zonelist *zonelist,
 						  gfp_t gfp_mask, bool noswap,
 						  unsigned int swappiness);
 extern int __isolate_lru_page(struct page *page, int mode, int file);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0a2f855..06a4c68 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -191,6 +191,7 @@ struct mem_cgroup {
 	unsigned long last_tree_update;		/* Last time the tree was */
 						/* updated in jiffies     */
 
+	bool on_tree;				/* Is the node on tree? */
 	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
@@ -227,18 +228,29 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
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
@@ -255,6 +267,23 @@ static void mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
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
 
@@ -262,10 +291,36 @@ static void mem_cgroup_remove_exceeded(struct mem_cgroup *mem)
 {
 	unsigned long flags;
 	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
-	rb_erase(&mem->mem_cgroup_node, &mem_cgroup_soft_limit_tree);
+	__mem_cgroup_remove_exceeded(mem);
 	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
 }
 
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
+	if (!css_tryget(&mem->css))
+		goto retry;
+done:
+	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
+	return mem;
+}
+
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
 					 struct page_cgroup *pc,
 					 bool charge)
@@ -888,11 +943,16 @@ mem_cgroup_select_victim(struct mem_cgroup *root_mem)
  * If shrink==true, for avoiding to free too much, this returns immedieately.
  */
 static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
-				   gfp_t gfp_mask, bool noswap, bool shrink)
+						struct zonelist *zonelist,
+						gfp_t gfp_mask,
+						unsigned long flags)
 {
 	struct mem_cgroup *victim;
 	int ret, total = 0;
 	int loop = 0;
+	bool noswap = flags & MEM_CGROUP_RECLAIM_NOSWAP;
+	bool shrink = flags & MEM_CGROUP_RECLAIM_SHRINK;
+	bool check_soft = flags & MEM_CGROUP_RECLAIM_SOFT;
 
 	while (loop < 2) {
 		victim = mem_cgroup_select_victim(root_mem);
@@ -904,8 +964,9 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 			continue;
 		}
 		/* we use swappiness of local cgroup */
-		ret = try_to_free_mem_cgroup_pages(victim, gfp_mask, noswap,
-						   get_swappiness(victim));
+		ret = try_to_free_mem_cgroup_pages(victim, zonelist, gfp_mask,
+							noswap,
+							get_swappiness(victim));
 		css_put(&victim->css);
 		/*
 		 * At shrinking usage, we can't check we should stop here or
@@ -915,7 +976,10 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 		if (shrink)
 			return ret;
 		total += ret;
-		if (mem_cgroup_check_under_limit(root_mem))
+		if (check_soft) {
+			if (res_counter_soft_limit_excess(&root_mem->res))
+				return total;
+		} else if (mem_cgroup_check_under_limit(root_mem))
 			return 1 + total;
 	}
 	return total;
@@ -1022,7 +1086,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 
 	while (1) {
 		int ret;
-		bool noswap = false;
+		unsigned long flags = 0;
 
 		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res,
 						&soft_fail_res);
@@ -1035,7 +1099,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 				break;
 			/* mem+swap counter fails */
 			res_counter_uncharge(&mem->res, PAGE_SIZE);
-			noswap = true;
+			flags = MEM_CGROUP_RECLAIM_NOSWAP;
 			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
 									memsw);
 		} else
@@ -1046,8 +1110,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 		if (!(gfp_mask & __GFP_WAIT))
 			goto nomem;
 
-		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
-							noswap, false);
+		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
+							gfp_mask, flags);
 		if (ret)
 			continue;
 
@@ -1692,8 +1756,8 @@ int mem_cgroup_shrink_usage(struct page *page,
 		return 0;
 
 	do {
-		progress = mem_cgroup_hierarchical_reclaim(mem,
-					gfp_mask, true, false);
+		progress = mem_cgroup_hierarchical_reclaim(mem, NULL,
+					gfp_mask, MEM_CGROUP_RECLAIM_NOSWAP);
 		progress += mem_cgroup_check_under_limit(mem);
 	} while (!progress && --retry);
 
@@ -1747,8 +1811,9 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
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
@@ -1796,7 +1861,9 @@ int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
-		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL, true, true);
+		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
+						MEM_CGROUP_RECLAIM_NOSWAP |
+						MEM_CGROUP_RECLAIM_SHRINK);
 		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
 		/* Usage is reduced ? */
 		if (curusage >= oldusage)
@@ -1807,6 +1874,35 @@ int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 	return ret;
 }
 
+unsigned long mem_cgroup_soft_limit_reclaim(struct zonelist *zonelist,
+						gfp_t gfp_mask)
+{
+	unsigned long nr_reclaimed = 0;
+	struct mem_cgroup *mem;
+	unsigned long flags;
+
+	do {
+		mem = mem_cgroup_get_largest_soft_limit_exceeding_node();
+		if (!mem)
+			break;
+		nr_reclaimed += mem_cgroup_hierarchical_reclaim(mem, zonelist,
+						gfp_mask,
+						MEM_CGROUP_RECLAIM_SOFT);
+		spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
+		mem->usage_in_excess = res_counter_soft_limit_excess(&mem->res);
+		/*
+		 * We need to remove and reinsert the node in its correct
+		 * position
+		 */
+		__mem_cgroup_remove_exceeded(mem);
+		if (mem->usage_in_excess)
+			__mem_cgroup_insert_exceeded(mem);
+		spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
+		css_put(&mem->css);
+	} while (!nr_reclaimed);
+	return nr_reclaimed;
+}
+
 /*
  * This routine traverse page_cgroup in given list and drop them all.
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
@@ -1930,7 +2026,7 @@ try_to_free:
 			ret = -EINTR;
 			goto out;
 		}
-		progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
+		progress = try_to_free_mem_cgroup_pages(mem, NULL, GFP_KERNEL,
 						false, get_swappiness(mem));
 		if (!progress) {
 			nr_retries--;
@@ -2535,6 +2631,8 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	mem->last_scanned_child = 0;
 	mem->usage_in_excess = 0;
 	mem->last_tree_update = 0;	/* Yes, time begins at 0 here */
+	mem->on_tree = false;
+
 	spin_lock_init(&mem->reclaim_param_lock);
 
 	if (parent)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 83f2ca4..0c28596 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1714,6 +1714,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 
 unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
+					   struct zonelist *zonelist,
 					   gfp_t gfp_mask,
 					   bool noswap,
 					   unsigned int swappiness)
@@ -1727,14 +1728,14 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
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
@@ -2015,9 +2016,12 @@ static int kswapd(void *p)
 		finish_wait(&pgdat->kswapd_wait, &wait);
 
 		if (!try_to_freeze()) {
+			struct zonelist *zl = pgdat->node_zonelists;
 			/* We can speed up thawing tasks if we don't call
 			 * balance_pgdat after returning from the refrigerator
 			 */
+			if (!order)
+				mem_cgroup_soft_limit_reclaim(zl, GFP_KERNEL);
 			balance_pgdat(pgdat, order);
 		}
 	}

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
