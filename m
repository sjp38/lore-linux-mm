Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4D98B6B005A
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 12:57:07 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp08.in.ibm.com (8.13.1/8.13.1) with ESMTP id n69GJgYR026620
	for <linux-mm@kvack.org>; Thu, 9 Jul 2009 21:49:42 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n69HF23O3829970
	for <linux-mm@kvack.org>; Thu, 9 Jul 2009 22:45:02 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n69HF1M2019148
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 03:15:02 +1000
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 09 Jul 2009 22:45:01 +0530
Message-Id: <20090709171501.8080.85138.sendpatchset@balbir-laptop>
In-Reply-To: <20090709171441.8080.85983.sendpatchset@balbir-laptop>
References: <20090709171441.8080.85983.sendpatchset@balbir-laptop>
Subject: [RFC][PATCH 3/5] Memory controller soft limit organize cgroups (v8)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Feature: Organize cgroups over soft limit in a RB-Tree

From: Balbir Singh <balbir@linux.vnet.ibm.com>

Changelog v8...v7
1. Make the data structures per zone per node

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

 include/linux/res_counter.h |    6 +
 kernel/res_counter.c        |   18 ++-
 mm/memcontrol.c             |  304 +++++++++++++++++++++++++++++++++++++------
 3 files changed, 281 insertions(+), 47 deletions(-)


diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index fcb9884..731af71 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -114,7 +114,8 @@ void res_counter_init(struct res_counter *counter, struct res_counter *parent);
 int __must_check res_counter_charge_locked(struct res_counter *counter,
 		unsigned long val);
 int __must_check res_counter_charge(struct res_counter *counter,
-		unsigned long val, struct res_counter **limit_fail_at);
+		unsigned long val, struct res_counter **limit_fail_at,
+		struct res_counter **soft_limit_at);
 
 /*
  * uncharge - tell that some portion of the resource is released
@@ -127,7 +128,8 @@ int __must_check res_counter_charge(struct res_counter *counter,
  */
 
 void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val);
-void res_counter_uncharge(struct res_counter *counter, unsigned long val);
+void res_counter_uncharge(struct res_counter *counter, unsigned long val,
+				bool *was_soft_limit_excess);
 
 static inline bool res_counter_limit_check_locked(struct res_counter *cnt)
 {
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index 4434236..dbdade0 100644
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
+		if (was_soft_limit_excess)
+			*was_soft_limit_excess =
+				!res_counter_soft_limit_check_locked(c);
 		res_counter_uncharge_locked(c, val);
 		spin_unlock(&c->lock);
 	}
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3c9292b..036032b 100644
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
@@ -118,6 +119,11 @@ struct mem_cgroup_per_zone {
 	unsigned long		count[NR_LRU_LISTS];
 
 	struct zone_reclaim_stat reclaim_stat;
+	struct rb_node		tree_node;	/* RB tree node */
+	unsigned long 		last_tree_update;/* Last time the tree was */
+						/* updated in jiffies     */
+	unsigned long long	usage_in_excess;/* Set to the value by which */
+						/* the soft limit is exceeded*/
 };
 /* Macro for accessing counter */
 #define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
@@ -131,6 +137,28 @@ struct mem_cgroup_lru_info {
 };
 
 /*
+ * Cgroups above their limits are maintained in a RB-Tree, independent of
+ * their hierarchy representation
+ */
+
+struct mem_cgroup_soft_limit_tree_per_zone {
+	struct rb_root rb_root;
+	spinlock_t lock;
+};
+
+struct mem_cgroup_soft_limit_tree_per_node {
+	struct mem_cgroup_soft_limit_tree_per_zone
+		rb_tree_per_zone[MAX_NR_ZONES];
+};
+
+struct mem_cgroup_soft_limit_tree {
+	struct mem_cgroup_soft_limit_tree_per_node
+		*rb_tree_per_node[MAX_NUMNODES];
+};
+
+static struct mem_cgroup_soft_limit_tree soft_limit_tree;
+
+/*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
  * statistics based on the statistics developed by Rik Van Riel for clock-pro,
@@ -187,6 +215,8 @@ struct mem_cgroup {
 	struct mem_cgroup_stat stat;
 };
 
+#define	MEM_CGROUP_TREE_UPDATE_INTERVAL		(HZ/4)
+
 enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
 	MEM_CGROUP_CHARGE_TYPE_MAPPED,
@@ -215,6 +245,164 @@ static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
 
+static struct mem_cgroup_per_zone *
+mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
+{
+	return &mem->info.nodeinfo[nid]->zoneinfo[zid];
+}
+
+static struct mem_cgroup_per_zone *
+page_cgroup_zoneinfo(struct page_cgroup *pc)
+{
+	struct mem_cgroup *mem = pc->mem_cgroup;
+	int nid = page_cgroup_nid(pc);
+	int zid = page_cgroup_zid(pc);
+
+	if (!mem)
+		return NULL;
+
+	return mem_cgroup_zoneinfo(mem, nid, zid);
+}
+
+static struct mem_cgroup_soft_limit_tree_per_zone *
+soft_limit_tree_node_zone(int nid, int zid)
+{
+	return &soft_limit_tree.rb_tree_per_node[nid]->rb_tree_per_zone[zid];
+}
+
+static struct mem_cgroup_soft_limit_tree_per_zone *
+page_cgroup_soft_limit_tree(struct page_cgroup *pc)
+{
+	int nid = page_cgroup_nid(pc);
+	int zid = page_cgroup_zid(pc);
+
+	return &soft_limit_tree.rb_tree_per_node[nid]->rb_tree_per_zone[zid];
+}
+
+static void
+mem_cgroup_insert_exceeded(struct mem_cgroup *mem,
+				struct mem_cgroup_per_zone *mz,
+				struct mem_cgroup_soft_limit_tree_per_zone *stz)
+{
+	struct rb_node **p = &stz->rb_root.rb_node;
+	struct rb_node *parent = NULL;
+	struct mem_cgroup_per_zone *mz_node;
+	unsigned long flags;
+
+	spin_lock_irqsave(&stz->lock, flags);
+	mz->usage_in_excess = res_counter_soft_limit_excess(&mem->res);
+	while (*p) {
+		parent = *p;
+		mz_node = rb_entry(parent, struct mem_cgroup_per_zone,
+					tree_node);
+		if (mz->usage_in_excess < mz_node->usage_in_excess)
+			p = &(*p)->rb_left;
+		/*
+		 * We can't avoid mem cgroups that are over their soft
+		 * limit by the same amount
+		 */
+		else if (mz->usage_in_excess >= mz_node->usage_in_excess)
+			p = &(*p)->rb_right;
+	}
+	rb_link_node(&mz->tree_node, parent, p);
+	rb_insert_color(&mz->tree_node, &stz->rb_root);
+	mz->last_tree_update = jiffies;
+	spin_unlock_irqrestore(&stz->lock, flags);
+}
+
+static void
+mem_cgroup_remove_exceeded(struct mem_cgroup *mem,
+				struct mem_cgroup_per_zone *mz,
+				struct mem_cgroup_soft_limit_tree_per_zone *stz)
+{
+	unsigned long flags;
+	spin_lock_irqsave(&stz->lock, flags);
+	rb_erase(&mz->tree_node, &stz->rb_root);
+	spin_unlock_irqrestore(&stz->lock, flags);
+}
+
+static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem,
+					bool over_soft_limit,
+					struct page *page)
+{
+	unsigned long next_update;
+	struct page_cgroup *pc;
+	struct mem_cgroup_per_zone *mz;
+
+	if (!over_soft_limit)
+		return false;
+
+	pc = lookup_page_cgroup(page);
+	if (unlikely(!pc))
+		return false;
+	mz = mem_cgroup_zoneinfo(mem, page_cgroup_nid(pc), page_cgroup_zid(pc));
+
+	next_update = mz->last_tree_update + MEM_CGROUP_TREE_UPDATE_INTERVAL;
+	if (time_after(jiffies, next_update))
+		return true;
+
+	return false;
+}
+
+static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct page *page)
+{
+	unsigned long long prev_usage_in_excess, new_usage_in_excess;
+	bool updated_tree = false;
+	unsigned long flags;
+	struct page_cgroup *pc;
+	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup_soft_limit_tree_per_zone *stz;
+
+	/*
+	 * As long as the page is around, pc's are always
+	 * around and so is the mz, in the remove path
+	 * we are yet to do the css_put(). I don't think
+	 * we need to hold page cgroup lock.
+	 */
+	pc = lookup_page_cgroup(page);
+	if (unlikely(!pc))
+		return;
+	mz = mem_cgroup_zoneinfo(mem, page_cgroup_nid(pc), page_cgroup_zid(pc));
+	stz = page_cgroup_soft_limit_tree(pc);
+
+	/*
+	 * We do updates in lazy mode, mem's are removed
+	 * lazily from the per-zone, per-node rb tree
+	 */
+	prev_usage_in_excess = mz->usage_in_excess;
+
+	new_usage_in_excess = res_counter_soft_limit_excess(&mem->res);
+	if (prev_usage_in_excess) {
+		mem_cgroup_remove_exceeded(mem, mz, stz);
+		updated_tree = true;
+	}
+	if (!new_usage_in_excess)
+		goto done;
+	mem_cgroup_insert_exceeded(mem, mz, stz);
+
+done:
+	if (updated_tree) {
+		spin_lock_irqsave(&stz->lock, flags);
+		mz->usage_in_excess = new_usage_in_excess;
+		spin_unlock_irqrestore(&stz->lock, flags);
+	}
+}
+
+static void mem_cgroup_remove_from_trees(struct mem_cgroup *mem)
+{
+	int node, zone;
+	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup_soft_limit_tree_per_zone *stz;
+
+	for_each_node_state(node, N_POSSIBLE) {
+		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
+			mz = mem_cgroup_zoneinfo(mem, node, zone);
+			stz = soft_limit_tree_node_zone(node, zone);
+			mem_cgroup_remove_exceeded(mem, mz, stz);
+		}
+	}
+}
+
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
 					 struct page_cgroup *pc,
 					 bool charge)
@@ -239,25 +427,6 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
 	put_cpu();
 }
 
-static struct mem_cgroup_per_zone *
-mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
-{
-	return &mem->info.nodeinfo[nid]->zoneinfo[zid];
-}
-
-static struct mem_cgroup_per_zone *
-page_cgroup_zoneinfo(struct page_cgroup *pc)
-{
-	struct mem_cgroup *mem = pc->mem_cgroup;
-	int nid = page_cgroup_nid(pc);
-	int zid = page_cgroup_zid(pc);
-
-	if (!mem)
-		return NULL;
-
-	return mem_cgroup_zoneinfo(mem, nid, zid);
-}
-
 static unsigned long mem_cgroup_get_local_zonestat(struct mem_cgroup *mem,
 					enum lru_list idx)
 {
@@ -972,11 +1141,11 @@ done:
  */
 static int __mem_cgroup_try_charge(struct mm_struct *mm,
 			gfp_t gfp_mask, struct mem_cgroup **memcg,
-			bool oom)
+			bool oom, struct page *page)
 {
-	struct mem_cgroup *mem, *mem_over_limit;
+	struct mem_cgroup *mem, *mem_over_limit, *mem_over_soft_limit;
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
-	struct res_counter *fail_res;
+	struct res_counter *fail_res, *soft_fail_res = NULL;
 
 	if (unlikely(test_thread_flag(TIF_MEMDIE))) {
 		/* Don't account this! */
@@ -1006,16 +1175,17 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
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
@@ -1053,13 +1223,24 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 			goto nomem;
 		}
 	}
+	/*
+	 * Insert just the ancestor, we should trickle down to the correct
+	 * cgroup for reclaim, since the other nodes will be below their
+	 * soft limit
+	 */
+	if (soft_fail_res) {
+		mem_over_soft_limit =
+			mem_cgroup_from_res_counter(soft_fail_res, res);
+		if (mem_cgroup_soft_limit_check(mem_over_soft_limit, true,
+							page))
+			mem_cgroup_update_tree(mem_over_soft_limit, page);
+	}
 	return 0;
 nomem:
 	css_put(&mem->css);
 	return -ENOMEM;
 }
 
-
 /*
  * A helper function to get mem_cgroup from ID. must be called under
  * rcu_read_lock(). The caller must check css_is_removed() or some if
@@ -1126,9 +1307,9 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
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
@@ -1205,7 +1386,7 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
 	if (pc->mem_cgroup != from)
 		goto out;
 
-	res_counter_uncharge(&from->res, PAGE_SIZE);
+	res_counter_uncharge(&from->res, PAGE_SIZE, NULL);
 	mem_cgroup_charge_statistics(from, pc, false);
 
 	page = pc->page;
@@ -1225,7 +1406,7 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
 	}
 
 	if (do_swap_account)
-		res_counter_uncharge(&from->memsw, PAGE_SIZE);
+		res_counter_uncharge(&from->memsw, PAGE_SIZE, NULL);
 	css_put(&from->css);
 
 	css_get(&to->css);
@@ -1259,7 +1440,7 @@ static int mem_cgroup_move_parent(struct page_cgroup *pc,
 	parent = mem_cgroup_from_cont(pcg);
 
 
-	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false);
+	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false, page);
 	if (ret || !parent)
 		return ret;
 
@@ -1289,9 +1470,9 @@ uncharge:
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
 
@@ -1316,7 +1497,7 @@ static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
 	prefetchw(pc);
 
 	mem = memcg;
-	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, true);
+	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, true, page);
 	if (ret || !mem)
 		return ret;
 
@@ -1435,14 +1616,14 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 	if (!mem)
 		goto charge_cur_mm;
 	*ptr = mem;
-	ret = __mem_cgroup_try_charge(NULL, mask, ptr, true);
+	ret = __mem_cgroup_try_charge(NULL, mask, ptr, true, page);
 	/* drop extra refcnt from tryget */
 	css_put(&mem->css);
 	return ret;
 charge_cur_mm:
 	if (unlikely(!mm))
 		mm = &init_mm;
-	return __mem_cgroup_try_charge(mm, mask, ptr, true);
+	return __mem_cgroup_try_charge(mm, mask, ptr, true, page);
 }
 
 static void
@@ -1479,7 +1660,7 @@ __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
 			 * This recorded memcg can be obsolete one. So, avoid
 			 * calling css_tryget
 			 */
-			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
+			res_counter_uncharge(&memcg->memsw, PAGE_SIZE, NULL);
 			mem_cgroup_put(memcg);
 		}
 		rcu_read_unlock();
@@ -1500,9 +1681,9 @@ void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
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
 
@@ -1516,6 +1697,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
 	struct mem_cgroup_per_zone *mz;
+	bool soft_limit_excess = false;
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -1554,9 +1736,9 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 		break;
 	}
 
-	res_counter_uncharge(&mem->res, PAGE_SIZE);
+	res_counter_uncharge(&mem->res, PAGE_SIZE, &soft_limit_excess);
 	if (do_swap_account && (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
-		res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+		res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
 	mem_cgroup_charge_statistics(mem, pc, false);
 
 	ClearPageCgroupUsed(pc);
@@ -1570,6 +1752,8 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	mz = page_cgroup_zoneinfo(pc);
 	unlock_page_cgroup(pc);
 
+	if (mem_cgroup_soft_limit_check(mem, soft_limit_excess, page))
+		mem_cgroup_update_tree(mem, page);
 	/* at swapout, this memcg will be accessed to record to swap */
 	if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
 		css_put(&mem->css);
@@ -1645,7 +1829,7 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
 		 * We uncharge this because swap is freed.
 		 * This memcg can be obsolete one. We avoid calling css_tryget
 		 */
-		res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
+		res_counter_uncharge(&memcg->memsw, PAGE_SIZE, NULL);
 		mem_cgroup_put(memcg);
 	}
 	rcu_read_unlock();
@@ -1674,7 +1858,8 @@ int mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
 	unlock_page_cgroup(pc);
 
 	if (mem) {
-		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);
+		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false,
+						page);
 		css_put(&mem->css);
 	}
 	*ptr = mem;
@@ -2177,6 +2362,7 @@ static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
 			res_counter_reset_failcnt(&mem->memsw);
 		break;
 	}
+
 	return 0;
 }
 
@@ -2472,6 +2658,8 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
 		mz = &pn->zoneinfo[zone];
 		for_each_lru(l)
 			INIT_LIST_HEAD(&mz->lists[l]);
+		mz->last_tree_update = 0;
+		mz->usage_in_excess = 0;
 	}
 	return 0;
 }
@@ -2517,6 +2705,7 @@ static void __mem_cgroup_free(struct mem_cgroup *mem)
 {
 	int node;
 
+	mem_cgroup_remove_from_trees(mem);
 	free_css_id(&mem_cgroup_subsys, &mem->css);
 
 	for_each_node_state(node, N_POSSIBLE)
@@ -2565,6 +2754,31 @@ static void __init enable_swap_cgroup(void)
 }
 #endif
 
+static int mem_cgroup_soft_limit_tree_init(void)
+{
+	struct mem_cgroup_soft_limit_tree_per_node *rtpn;
+	struct mem_cgroup_soft_limit_tree_per_zone *rtpz;
+	int tmp, node, zone;
+
+	for_each_node_state(node, N_POSSIBLE) {
+		tmp = node;
+		if (!node_state(node, N_NORMAL_MEMORY))
+			tmp = -1;
+		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, tmp);
+		if (!rtpn)
+			return 1;
+
+		soft_limit_tree.rb_tree_per_node[node] = rtpn;
+
+		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
+			rtpz = &rtpn->rb_tree_per_zone[zone];
+			rtpz->rb_root = RB_ROOT;
+			spin_lock_init(&rtpz->lock);
+		}
+	}
+	return 0;
+}
+
 static struct cgroup_subsys_state * __ref
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
@@ -2579,11 +2793,15 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	for_each_node_state(node, N_POSSIBLE)
 		if (alloc_mem_cgroup_per_zone_info(mem, node))
 			goto free_out;
+
 	/* root ? */
 	if (cont->parent == NULL) {
 		enable_swap_cgroup();
 		parent = NULL;
 		root_mem_cgroup = mem;
+		if (mem_cgroup_soft_limit_tree_init())
+			goto free_out;
+
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
 		mem->use_hierarchy = parent->use_hierarchy;

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
