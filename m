Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4CB836B0047
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:56:40 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp08.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2CHSNTp006255
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 22:58:23 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2CHubiv4280406
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 23:26:37 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2CHuTiA009536
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 04:56:29 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 12 Mar 2009 23:26:25 +0530
Message-Id: <20090312175625.17890.94795.sendpatchset@localhost.localdomain>
In-Reply-To: <20090312175603.17890.52593.sendpatchset@localhost.localdomain>
References: <20090312175603.17890.52593.sendpatchset@localhost.localdomain>
Subject: [PATCH 3/4] Memory controller soft limit organize cgroups (v5)
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Feature: Organize cgroups over soft limit in a RB-Tree

From: Balbir Singh <balbir@linux.vnet.ibm.com>

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
 mm/memcontrol.c             |  141 ++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 143 insertions(+), 22 deletions(-)


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
index b4f5b15..4e2a79e 100644
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
@@ -214,6 +231,41 @@ static void mem_cgroup_get(struct mem_cgroup *mem);
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
@@ -897,6 +949,40 @@ static void record_last_oom(struct mem_cgroup *mem)
 	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
 }
 
+static void mem_cgroup_check_and_update_tree(struct mem_cgroup *mem,
+						bool time_check)
+{
+	unsigned long long prev_usage_in_excess, new_usage_in_excess;
+	bool updated_tree = false;
+	unsigned long next_update = 0;
+	unsigned long flags;
+
+	prev_usage_in_excess = mem->usage_in_excess;
+
+	if (time_check)
+		next_update = mem->last_tree_update +
+				MEM_CGROUP_TREE_UPDATE_INTERVAL;
+
+	if (!time_check || time_after(jiffies, next_update)) {
+		new_usage_in_excess = res_counter_soft_limit_excess(&mem->res);
+		if (prev_usage_in_excess) {
+			mem_cgroup_remove_exceeded(mem);
+			updated_tree = true;
+		}
+		if (!new_usage_in_excess)
+			goto done;
+		mem_cgroup_insert_exceeded(mem);
+		updated_tree = true;
+	}
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
@@ -906,9 +992,9 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
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
@@ -938,16 +1024,17 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
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
@@ -985,6 +1072,17 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
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
+		mem_cgroup_check_and_update_tree(mem_over_soft_limit, true);
+	}
 	return 0;
 nomem:
 	css_put(&mem->css);
@@ -1045,9 +1143,9 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
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
@@ -1100,10 +1198,10 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
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
@@ -1167,9 +1265,9 @@ uncharge:
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
 
@@ -1298,7 +1396,7 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 			 * Recorded ID can be obsolete. We avoid calling
 			 * css_tryget()
 			 */
-			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+			res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
 			mem_cgroup_put(mem);
 		}
 		rcu_read_unlock();
@@ -1377,7 +1475,7 @@ void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
 			 * This recorded memcg can be obsolete one. So, avoid
 			 * calling css_tryget
 			 */
-			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
+			res_counter_uncharge(&memcg->memsw, PAGE_SIZE, NULL);
 			mem_cgroup_put(memcg);
 		}
 		rcu_read_unlock();
@@ -1392,9 +1490,9 @@ void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
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
 
@@ -1408,6 +1506,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
 	struct mem_cgroup_per_zone *mz;
+	bool soft_limit_excess = false;
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -1445,9 +1544,9 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 		break;
 	}
 
-	res_counter_uncharge(&mem->res, PAGE_SIZE);
+	res_counter_uncharge(&mem->res, PAGE_SIZE, &soft_limit_excess);
 	if (do_swap_account && (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
-		res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+		res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
 	mem_cgroup_charge_statistics(mem, pc, false);
 
 	ClearPageCgroupUsed(pc);
@@ -1461,6 +1560,8 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	mz = page_cgroup_zoneinfo(pc);
 	unlock_page_cgroup(pc);
 
+	if (soft_limit_excess)
+		mem_cgroup_check_and_update_tree(mem, true);
 	/* at swapout, this memcg will be accessed to record to swap */
 	if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
 		css_put(&mem->css);
@@ -1529,7 +1630,7 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
 		 * We uncharge this because swap is freed.
 		 * This memcg can be obsolete one. We avoid calling css_tryget
 		 */
-		res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
+		res_counter_uncharge(&memcg->memsw, PAGE_SIZE, NULL);
 		mem_cgroup_put(memcg);
 	}
 	rcu_read_unlock();
@@ -2393,6 +2494,7 @@ static void __mem_cgroup_free(struct mem_cgroup *mem)
 {
 	int node;
 
+	mem_cgroup_check_and_update_tree(mem, false);
 	free_css_id(&mem_cgroup_subsys, &mem->css);
 
 	for_each_node_state(node, N_POSSIBLE)
@@ -2459,6 +2561,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	if (cont->parent == NULL) {
 		enable_swap_cgroup();
 		parent = NULL;
+		mem_cgroup_soft_limit_tree = RB_ROOT;
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
 		mem->use_hierarchy = parent->use_hierarchy;
@@ -2479,6 +2582,8 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
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
