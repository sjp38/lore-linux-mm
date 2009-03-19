Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 551736B005A
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 12:57:54 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp09.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2JGh2Sq012138
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 03:43:02 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2JGw7GS1110254
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 03:58:07 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2JGvnoK030364
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 03:57:49 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 19 Mar 2009 22:27:35 +0530
Message-Id: <20090319165735.27274.96091.sendpatchset@localhost.localdomain>
In-Reply-To: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
Subject: [PATCH 3/5] Memory controller soft limit organize cgroups (v7)
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Feature: Organize cgroups over soft limit in a RB-Tree

From: Balbir Singh <balbir@linux.vnet.ibm.com>

Changelog v7...v6
1. Refactor the check and update logic. The goal is to allow the
   check logic to be modular, so that it can be revisited in the future
   if something more appropriate is found to be useful.

Changelog v6...v5
1. Update the key before inserting into RB tree. Without the current change
   it could take an additional iteration to get the key correct.

Changelog v5...v4
1. res_counter_uncharge has an additional parameter to indicate if the
   counter was over its soft limit, before uncharge.

Changelog v4...v3
1. Optimizations to ensure we don't uncessarily get res_counter values
2. Fixed a bug in usage of time_after()

Changelog v3...v2
1. Add only the ancestor to the RB-Tree
2. Use css_tryget/css_put instead of mem_cgroup_get/mem_cgroup_put

Changelog v2...v1
1. Add support for hierarchies
2. The res_counter that is highest in the hierarchy is returned on soft
   limit being exceeded. Since we do hierarchical reclaim and add all
   groups exceeding their soft limits, this approach seems to work well
   in practice.

This patch introduces a RB-Tree for storing memory cgroups that are over their
soft limit. The overall goal is to

1. Add a memory cgroup to the RB-Tree when the soft limit is exceeded.
   We are careful about updates, updates take place only after a particular
   time interval has passed
2. We remove the node from the RB-Tree when the usage goes below the soft
   limit

The next set of patches will exploit the RB-Tree to get the group that is
over its soft limit by the largest amount and reclaim from it, when we
face memory contention.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/res_counter.h |    6 +-
 kernel/res_counter.c        |   18 +++++
 mm/memcontrol.c             |  149 ++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 151 insertions(+), 22 deletions(-)


diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index 5c821fd..5bbf8b1 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -112,7 +112,8 @@ void res_counter_init(struct res_counter *counter, struct res_counter *parent);
 int __must_check res_counter_charge_locked(struct res_counter *counter,
 		unsigned long val);
 int __must_check res_counter_charge(struct res_counter *counter,
-		unsigned long val, struct res_counter **limit_fail_at);
+		unsigned long val, struct res_counter **limit_fail_at,
+		struct res_counter **soft_limit_at);
 
 /*
  * uncharge - tell that some portion of the resource is released
@@ -125,7 +126,8 @@ int __must_check res_counter_charge(struct res_counter *counter,
  */
 
 void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val);
-void res_counter_uncharge(struct res_counter *counter, unsigned long val);
+void res_counter_uncharge(struct res_counter *counter, unsigned long val,
+				bool *was_soft_limit_excess);
 
 static inline bool res_counter_limit_check_locked(struct res_counter *cnt)
 {
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index 4e6dafe..51ec438 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -37,17 +37,27 @@ int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
 }
 
 int res_counter_charge(struct res_counter *counter, unsigned long val,
-			struct res_counter **limit_fail_at)
+			struct res_counter **limit_fail_at,
+			struct res_counter **soft_limit_fail_at)
 {
 	int ret;
 	unsigned long flags;
 	struct res_counter *c, *u;
 
 	*limit_fail_at = NULL;
+	if (soft_limit_fail_at)
+		*soft_limit_fail_at = NULL;
 	local_irq_save(flags);
 	for (c = counter; c != NULL; c = c->parent) {
 		spin_lock(&c->lock);
 		ret = res_counter_charge_locked(c, val);
+		/*
+		 * With soft limits, we return the highest ancestor
+		 * that exceeds its soft limit
+		 */
+		if (soft_limit_fail_at &&
+			!res_counter_soft_limit_check_locked(c))
+			*soft_limit_fail_at = c;
 		spin_unlock(&c->lock);
 		if (ret < 0) {
 			*limit_fail_at = c;
@@ -75,7 +85,8 @@ void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val)
 	counter->usage -= val;
 }
 
-void res_counter_uncharge(struct res_counter *counter, unsigned long val)
+void res_counter_uncharge(struct res_counter *counter, unsigned long val,
+				bool *was_soft_limit_excess)
 {
 	unsigned long flags;
 	struct res_counter *c;
@@ -83,6 +94,9 @@ void res_counter_uncharge(struct res_counter *counter, unsigned long val)
 	local_irq_save(flags);
 	for (c = counter; c != NULL; c = c->parent) {
 		spin_lock(&c->lock);
+		if (c == counter && was_soft_limit_excess)
+			*was_soft_limit_excess =
+				!res_counter_soft_limit_check_locked(c);
 		res_counter_uncharge_locked(c, val);
 		spin_unlock(&c->lock);
 	}
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 70bc992..f5b61b8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -29,6 +29,7 @@
 #include <linux/rcupdate.h>
 #include <linux/limits.h>
 #include <linux/mutex.h>
+#include <linux/rbtree.h>
 #include <linux/slab.h>
 #include <linux/swap.h>
 #include <linux/spinlock.h>
@@ -129,6 +130,14 @@ struct mem_cgroup_lru_info {
 };
 
 /*
+ * Cgroups above their limits are maintained in a RB-Tree, independent of
+ * their hierarchy representation
+ */
+
+static struct rb_root mem_cgroup_soft_limit_tree;
+static DEFINE_SPINLOCK(memcg_soft_limit_tree_lock);
+
+/*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
  * statistics based on the statistics developed by Rik Van Riel for clock-pro,
@@ -176,12 +185,20 @@ struct mem_cgroup {
 
 	unsigned int	swappiness;
 
+	struct rb_node mem_cgroup_node;		/* RB tree node */
+	unsigned long long usage_in_excess;	/* Set to the value by which */
+						/* the soft limit is exceeded*/
+	unsigned long last_tree_update;		/* Last time the tree was */
+						/* updated in jiffies     */
+
 	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
 	struct mem_cgroup_stat stat;
 };
 
+#define	MEM_CGROUP_TREE_UPDATE_INTERVAL		(HZ/4)
+
 enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
 	MEM_CGROUP_CHARGE_TYPE_MAPPED,
@@ -214,6 +231,42 @@ static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
 
+static void mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
+{
+	struct rb_node **p = &mem_cgroup_soft_limit_tree.rb_node;
+	struct rb_node *parent = NULL;
+	struct mem_cgroup *mem_node;
+	unsigned long flags;
+
+	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
+	mem->usage_in_excess = res_counter_soft_limit_excess(&mem->res);
+	while (*p) {
+		parent = *p;
+		mem_node = rb_entry(parent, struct mem_cgroup, mem_cgroup_node);
+		if (mem->usage_in_excess < mem_node->usage_in_excess)
+			p = &(*p)->rb_left;
+		/*
+		 * We can't avoid mem cgroups that are over their soft
+		 * limit by the same amount
+		 */
+		else if (mem->usage_in_excess >= mem_node->usage_in_excess)
+			p = &(*p)->rb_right;
+	}
+	rb_link_node(&mem->mem_cgroup_node, parent, p);
+	rb_insert_color(&mem->mem_cgroup_node,
+			&mem_cgroup_soft_limit_tree);
+	mem->last_tree_update = jiffies;
+	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
+}
+
+static void mem_cgroup_remove_exceeded(struct mem_cgroup *mem)
+{
+	unsigned long flags;
+	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
+	rb_erase(&mem->mem_cgroup_node, &mem_cgroup_soft_limit_tree);
+	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
+}
+
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
 					 struct page_cgroup *pc,
 					 bool charge)
@@ -897,6 +950,46 @@ static void record_last_oom(struct mem_cgroup *mem)
 	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
 }
 
+static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem,
+					bool over_soft_limit)
+{
+	unsigned long next_update;
+
+	if (!over_soft_limit)
+		return false;
+
+	next_update = mem->last_tree_update + MEM_CGROUP_TREE_UPDATE_INTERVAL;
+	if (time_after(jiffies, next_update))
+		return true;
+
+	return false;
+}
+
+static void mem_cgroup_update_tree(struct mem_cgroup *mem)
+{
+	unsigned long long prev_usage_in_excess, new_usage_in_excess;
+	bool updated_tree = false;
+	unsigned long flags;
+
+	prev_usage_in_excess = mem->usage_in_excess;
+
+	new_usage_in_excess = res_counter_soft_limit_excess(&mem->res);
+	if (prev_usage_in_excess) {
+		mem_cgroup_remove_exceeded(mem);
+		updated_tree = true;
+	}
+	if (!new_usage_in_excess)
+		goto done;
+	mem_cgroup_insert_exceeded(mem);
+
+done:
+	if (updated_tree) {
+		spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
+		mem->last_tree_update = jiffies;
+		mem->usage_in_excess = new_usage_in_excess;
+		spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
+	}
+}
 
 /*
  * Unlike exported interface, "oom" parameter is added. if oom==true,
@@ -906,9 +999,9 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 			gfp_t gfp_mask, struct mem_cgroup **memcg,
 			bool oom)
 {
-	struct mem_cgroup *mem, *mem_over_limit;
+	struct mem_cgroup *mem, *mem_over_limit, *mem_over_soft_limit;
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
-	struct res_counter *fail_res;
+	struct res_counter *fail_res, *soft_fail_res = NULL;
 
 	if (unlikely(test_thread_flag(TIF_MEMDIE))) {
 		/* Don't account this! */
@@ -938,16 +1031,17 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 		int ret;
 		bool noswap = false;
 
-		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res);
+		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res,
+						&soft_fail_res);
 		if (likely(!ret)) {
 			if (!do_swap_account)
 				break;
 			ret = res_counter_charge(&mem->memsw, PAGE_SIZE,
-							&fail_res);
+							&fail_res, NULL);
 			if (likely(!ret))
 				break;
 			/* mem+swap counter fails */
-			res_counter_uncharge(&mem->res, PAGE_SIZE);
+			res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
 			noswap = true;
 			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
 									memsw);
@@ -985,6 +1079,18 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 			goto nomem;
 		}
 	}
+
+	/*
+	 * Insert just the ancestor, we should trickle down to the correct
+	 * cgroup for reclaim, since the other nodes will be below their
+	 * soft limit
+	 */
+	if (soft_fail_res) {
+		mem_over_soft_limit =
+			mem_cgroup_from_res_counter(soft_fail_res, res);
+		if (mem_cgroup_soft_limit_check(mem_over_soft_limit, true))
+			mem_cgroup_update_tree(mem_over_soft_limit);
+	}
 	return 0;
 nomem:
 	css_put(&mem->css);
@@ -1061,9 +1167,9 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
 	lock_page_cgroup(pc);
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
-		res_counter_uncharge(&mem->res, PAGE_SIZE);
+		res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
 		if (do_swap_account)
-			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+			res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
 		css_put(&mem->css);
 		return;
 	}
@@ -1116,10 +1222,10 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
 	if (pc->mem_cgroup != from)
 		goto out;
 
-	res_counter_uncharge(&from->res, PAGE_SIZE);
+	res_counter_uncharge(&from->res, PAGE_SIZE, NULL);
 	mem_cgroup_charge_statistics(from, pc, false);
 	if (do_swap_account)
-		res_counter_uncharge(&from->memsw, PAGE_SIZE);
+		res_counter_uncharge(&from->memsw, PAGE_SIZE, NULL);
 	css_put(&from->css);
 
 	css_get(&to->css);
@@ -1183,9 +1289,9 @@ uncharge:
 	/* drop extra refcnt by try_charge() */
 	css_put(&parent->css);
 	/* uncharge if move fails */
-	res_counter_uncharge(&parent->res, PAGE_SIZE);
+	res_counter_uncharge(&parent->res, PAGE_SIZE, NULL);
 	if (do_swap_account)
-		res_counter_uncharge(&parent->memsw, PAGE_SIZE);
+		res_counter_uncharge(&parent->memsw, PAGE_SIZE, NULL);
 	return ret;
 }
 
@@ -1314,7 +1420,7 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 			 * Recorded ID can be obsolete. We avoid calling
 			 * css_tryget()
 			 */
-			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+			res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
 			mem_cgroup_put(mem);
 		}
 		rcu_read_unlock();
@@ -1393,7 +1499,7 @@ void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
 			 * This recorded memcg can be obsolete one. So, avoid
 			 * calling css_tryget
 			 */
-			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
+			res_counter_uncharge(&memcg->memsw, PAGE_SIZE, NULL);
 			mem_cgroup_put(memcg);
 		}
 		rcu_read_unlock();
@@ -1408,9 +1514,9 @@ void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
 		return;
 	if (!mem)
 		return;
-	res_counter_uncharge(&mem->res, PAGE_SIZE);
+	res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
 	if (do_swap_account)
-		res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+		res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
 	css_put(&mem->css);
 }
 
@@ -1424,6 +1530,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
 	struct mem_cgroup_per_zone *mz;
+	bool soft_limit_excess = false;
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -1461,9 +1568,9 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 		break;
 	}
 
-	res_counter_uncharge(&mem->res, PAGE_SIZE);
+	res_counter_uncharge(&mem->res, PAGE_SIZE, &soft_limit_excess);
 	if (do_swap_account && (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
-		res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+		res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
 	mem_cgroup_charge_statistics(mem, pc, false);
 
 	ClearPageCgroupUsed(pc);
@@ -1477,6 +1584,8 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	mz = page_cgroup_zoneinfo(pc);
 	unlock_page_cgroup(pc);
 
+	if (mem_cgroup_soft_limit_check(mem, soft_limit_excess))
+		mem_cgroup_update_tree(mem);
 	/* at swapout, this memcg will be accessed to record to swap */
 	if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
 		css_put(&mem->css);
@@ -1545,7 +1654,7 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
 		 * We uncharge this because swap is freed.
 		 * This memcg can be obsolete one. We avoid calling css_tryget
 		 */
-		res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
+		res_counter_uncharge(&memcg->memsw, PAGE_SIZE, NULL);
 		mem_cgroup_put(memcg);
 	}
 	rcu_read_unlock();
@@ -2409,6 +2518,7 @@ static void __mem_cgroup_free(struct mem_cgroup *mem)
 {
 	int node;
 
+	mem_cgroup_update_tree(mem);
 	free_css_id(&mem_cgroup_subsys, &mem->css);
 
 	for_each_node_state(node, N_POSSIBLE)
@@ -2475,6 +2585,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	if (cont->parent == NULL) {
 		enable_swap_cgroup();
 		parent = NULL;
+		mem_cgroup_soft_limit_tree = RB_ROOT;
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
 		mem->use_hierarchy = parent->use_hierarchy;
@@ -2495,6 +2606,8 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 		res_counter_init(&mem->memsw, NULL);
 	}
 	mem->last_scanned_child = 0;
+	mem->usage_in_excess = 0;
+	mem->last_tree_update = 0;	/* Yes, time begins at 0 here */
 	spin_lock_init(&mem->reclaim_param_lock);
 
 	if (parent)

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
