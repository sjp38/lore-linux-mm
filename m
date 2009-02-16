Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D65B46B005D
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 06:09:16 -0500 (EST)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id n1GB7OM0021804
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 22:07:24 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1GB9CvD962722
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 22:09:12 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1GB9BSA026433
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 22:09:12 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Mon, 16 Feb 2009 16:39:06 +0530
Message-Id: <20090216110906.29795.74208.sendpatchset@localhost.localdomain>
In-Reply-To: <20090216110844.29795.17804.sendpatchset@localhost.localdomain>
References: <20090216110844.29795.17804.sendpatchset@localhost.localdomain>
Subject: [RFC][PATCH 3/4] Memory controller soft limit organize cgroups (v2)
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


From: Balbir Singh <balbir@linux.vnet.ibm.com>

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

 include/linux/res_counter.h |    3 +
 kernel/res_counter.c        |   12 +++++
 mm/memcontrol.c             |  104 +++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 113 insertions(+), 6 deletions(-)


diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index b5f14fa..e526ab6 100644
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
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index 4e6dafe..08b7614 100644
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
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 75a7b1a..a2617ac 100644
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
+static struct rb_root mem_cgroup_soft_limit_exceeded_groups;
+static DEFINE_SPINLOCK(memcg_soft_limit_tree_lock);
+
+/*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
  * statistics based on the statistics developed by Rik Van Riel for clock-pro,
@@ -176,12 +185,18 @@ struct mem_cgroup {
 
 	unsigned int	swappiness;
 
+	struct rb_node mem_cgroup_node;
+	unsigned long long usage_in_excess;
+	unsigned long last_tree_update;
+
 	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
 	struct mem_cgroup_stat stat;
 };
 
+#define	MEM_CGROUP_TREE_UPDATE_INTERVAL		(HZ)
+
 enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
 	MEM_CGROUP_CHARGE_TYPE_MAPPED,
@@ -214,6 +229,41 @@ static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
 
+static void mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
+{
+	struct rb_node **p = &mem_cgroup_soft_limit_exceeded_groups.rb_node;
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
+			&mem_cgroup_soft_limit_exceeded_groups);
+	mem->last_tree_update = jiffies;
+	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
+}
+
+static void mem_cgroup_remove_exceeded(struct mem_cgroup *mem)
+{
+	unsigned long flags;
+	spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
+	rb_erase(&mem->mem_cgroup_node, &mem_cgroup_soft_limit_exceeded_groups);
+	spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
+}
+
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
 					 struct page_cgroup *pc,
 					 bool charge)
@@ -897,6 +947,39 @@ static void record_last_oom(struct mem_cgroup *mem)
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
+	mem_cgroup_get(mem);
+	prev_usage_in_excess = mem->usage_in_excess;
+	new_usage_in_excess = res_counter_soft_limit_excess(&mem->res);
+
+	if (time_check)
+		next_update = mem->last_tree_update +
+				MEM_CGROUP_TREE_UPDATE_INTERVAL;
+	if (new_usage_in_excess && time_after(jiffies, next_update)) {
+		if (prev_usage_in_excess)
+			mem_cgroup_remove_exceeded(mem);
+		mem_cgroup_insert_exceeded(mem);
+		updated_tree = true;
+	} else if (prev_usage_in_excess && !new_usage_in_excess) {
+		mem_cgroup_remove_exceeded(mem);
+		updated_tree = true;
+	}
+
+	if (updated_tree) {
+		spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
+		mem->last_tree_update = jiffies;
+		mem->usage_in_excess = new_usage_in_excess;
+		spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
+	}
+	mem_cgroup_put(mem);
+}
 
 /*
  * Unlike exported interface, "oom" parameter is added. if oom==true,
@@ -906,9 +989,9 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
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
@@ -938,12 +1021,13 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
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
@@ -985,6 +1069,13 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 			goto nomem;
 		}
 	}
+
+	if (soft_fail_res) {
+		mem_over_soft_limit =
+			mem_cgroup_from_res_counter(soft_fail_res, res);
+		mem_cgroup_check_and_update_tree(mem_over_soft_limit, true);
+	}
+	mem_cgroup_check_and_update_tree(mem, true);
 	return 0;
 nomem:
 	css_put(&mem->css);
@@ -1422,6 +1513,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	mz = page_cgroup_zoneinfo(pc);
 	unlock_page_cgroup(pc);
 
+	mem_cgroup_check_and_update_tree(mem, true);
 	/* at swapout, this memcg will be accessed to record to swap */
 	if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
 		css_put(&mem->css);
@@ -2346,6 +2438,7 @@ static void __mem_cgroup_free(struct mem_cgroup *mem)
 {
 	int node;
 
+	mem_cgroup_check_and_update_tree(mem, false);
 	free_css_id(&mem_cgroup_subsys, &mem->css);
 
 	for_each_node_state(node, N_POSSIBLE)
@@ -2412,6 +2505,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	if (cont->parent == NULL) {
 		enable_swap_cgroup();
 		parent = NULL;
+		mem_cgroup_soft_limit_exceeded_groups = RB_ROOT;
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
 		mem->use_hierarchy = parent->use_hierarchy;
@@ -2432,6 +2526,8 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
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
