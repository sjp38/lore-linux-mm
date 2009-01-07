Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 342D86B0047
	for <linux-mm@kvack.org>; Wed,  7 Jan 2009 13:43:00 -0500 (EST)
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id n07IfM0q013693
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 05:41:22 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n07IfZBw091838
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 05:41:38 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n07IfZDk001072
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 05:41:35 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 08 Jan 2009 00:11:35 +0530
Message-Id: <20090107184135.18062.96358.sendpatchset@localhost.localdomain>
In-Reply-To: <20090107184110.18062.41459.sendpatchset@localhost.localdomain>
References: <20090107184110.18062.41459.sendpatchset@localhost.localdomain>
Subject: [RFC][PATCH 4/4] Memory controller soft limit reclaim on contention
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: Balbir Singh <balbir@linux.vnet.ibm.com>

This patch allows reclaim from memory cgroups on contention (via the
__alloc_pages_internal() path). If a order greater than 0 is specified, we
anyway fall back on try_to_free_pages().

memory cgroup soft limit reclaim finds the group that exceeds its soft limit
by the largest amount and reclaims pages from it and then reinserts the
cgroup into its correct place in the rbtree.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/memcontrol.h |    1 
 mm/memcontrol.c            |   82 +++++++++++++++++++++++++++++++++--
 mm/page_alloc.c            |   10 +++-
 3 files changed, 88 insertions(+), 5 deletions(-)

diff -puN mm/memcontrol.c~memcg-soft-limit-reclaim-on-contention mm/memcontrol.c
--- a/mm/memcontrol.c~memcg-soft-limit-reclaim-on-contention
+++ a/mm/memcontrol.c
@@ -177,6 +177,7 @@ struct mem_cgroup {
 	struct rb_node mem_cgroup_node;
 	unsigned long long usage_in_excess;
 	unsigned long last_tree_update;
+	bool on_tree;
 
 	/*
 	 * statistics. This must be placed at the end of memcg.
@@ -184,7 +185,7 @@ struct mem_cgroup {
 	struct mem_cgroup_stat stat;
 };
 
-#define	MEM_CGROUP_TREE_UPDATE_INTERVAL		(HZ)
+#define	MEM_CGROUP_TREE_UPDATE_INTERVAL		(HZ/4)
 
 enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
@@ -217,13 +218,15 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
 static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
 
-static void mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
+static void __mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
 {
 	struct rb_node **p = &mem_cgroup_soft_limit_exceeded_groups.rb_node;
 	struct rb_node *parent = NULL;
 	struct mem_cgroup *mem_node;
 
-	mutex_lock(&memcg_soft_limit_tree_mutex);
+	if (mem->on_tree)
+		return;
+
 	while (*p) {
 		parent = *p;
 		mem_node = rb_entry(parent, struct mem_cgroup, mem_cgroup_node);
@@ -240,16 +243,54 @@ static void mem_cgroup_insert_exceeded(s
 	rb_insert_color(&mem->mem_cgroup_node,
 			&mem_cgroup_soft_limit_exceeded_groups);
 	mem->last_tree_update = jiffies;
+	mem->on_tree = true;
+}
+
+static void __mem_cgroup_remove_exceeded(struct mem_cgroup *mem)
+{
+	if (!mem->on_tree)
+		return;
+	rb_erase(&mem->mem_cgroup_node, &mem_cgroup_soft_limit_exceeded_groups);
+	mem->on_tree = false;
+}
+
+static void mem_cgroup_insert_exceeded(struct mem_cgroup *mem)
+{
+	mutex_lock(&memcg_soft_limit_tree_mutex);
+	__mem_cgroup_insert_exceeded(mem);
 	mutex_unlock(&memcg_soft_limit_tree_mutex);
 }
 
 static void mem_cgroup_remove_exceeded(struct mem_cgroup *mem)
 {
 	mutex_lock(&memcg_soft_limit_tree_mutex);
-	rb_erase(&mem->mem_cgroup_node, &mem_cgroup_soft_limit_exceeded_groups);
+	__mem_cgroup_remove_exceeded(mem);
 	mutex_unlock(&memcg_soft_limit_tree_mutex);
 }
 
+static struct mem_cgroup *mem_cgroup_get_largest_soft_limit_exceeding_node(void)
+{
+	struct rb_node *rightmost = NULL;
+	struct mem_cgroup *mem = NULL;
+
+	mutex_lock(&memcg_soft_limit_tree_mutex);
+	rightmost = rb_last(&mem_cgroup_soft_limit_exceeded_groups);
+	if (!rightmost)
+		goto done;		/* Nothing to reclaim from */
+
+	mem = rb_entry(rightmost, struct mem_cgroup, mem_cgroup_node);
+	mem_cgroup_get(mem);
+	/*
+	 * Remove the node now but someone else can add it back,
+	 * we will to add it back at the end of reclaim to its correct
+	 * position in the tree.
+	 */
+	__mem_cgroup_remove_exceeded(mem);
+done:
+	mutex_unlock(&memcg_soft_limit_tree_mutex);
+	return mem;
+}
+
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
 					 struct page_cgroup *pc,
 					 bool charge)
@@ -1795,6 +1836,37 @@ try_to_free:
 	goto out;
 }
 
+unsigned long mem_cgroup_soft_limit_reclaim(gfp_t gfp_mask)
+{
+	unsigned long nr_reclaimed = 0;
+	struct mem_cgroup *mem;
+
+	do {
+		mem = mem_cgroup_get_largest_soft_limit_exceeding_node();
+		if (!mem)
+			break;
+		if (mem_cgroup_is_obsolete(mem)) {
+			mem_cgroup_put(mem);
+			continue;
+		}
+		nr_reclaimed +=
+			try_to_free_mem_cgroup_pages(mem, gfp_mask, false,
+							get_swappiness(mem));
+		mutex_lock(&memcg_soft_limit_tree_mutex);
+		mem->usage_in_excess = res_counter_soft_limit_excess(&mem->res);
+		/*
+		 * We need to remove and reinsert the node in its correct
+		 * position
+		 */
+		__mem_cgroup_remove_exceeded(mem);
+		if (mem->usage_in_excess)
+			__mem_cgroup_insert_exceeded(mem);
+		mutex_unlock(&memcg_soft_limit_tree_mutex);
+		mem_cgroup_put(mem);
+	} while (!nr_reclaimed);
+	return nr_reclaimed;
+}
+
 int mem_cgroup_force_empty_write(struct cgroup *cont, unsigned int event)
 {
 	return mem_cgroup_force_empty(mem_cgroup_from_cont(cont), true);
@@ -2309,6 +2381,8 @@ mem_cgroup_create(struct cgroup_subsys *
 	mem->last_scanned_child = NULL;
 	mem->usage_in_excess = 0;
 	mem->last_tree_update = 0;	/* Yes, time begins at 0 here */
+	mem->on_tree = false;
+
 	spin_lock_init(&mem->reclaim_param_lock);
 
 	if (parent)
diff -puN mm/vmscan.c~memcg-soft-limit-reclaim-on-contention mm/vmscan.c
diff -puN include/linux/memcontrol.h~memcg-soft-limit-reclaim-on-contention include/linux/memcontrol.h
--- a/include/linux/memcontrol.h~memcg-soft-limit-reclaim-on-contention
+++ a/include/linux/memcontrol.h
@@ -117,6 +117,7 @@ static inline bool mem_cgroup_disabled(v
 }
 
 extern bool mem_cgroup_oom_called(struct task_struct *task);
+extern unsigned long mem_cgroup_soft_limit_reclaim(gfp_t gfp_mask);
 
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
diff -puN mm/page_alloc.c~memcg-soft-limit-reclaim-on-contention mm/page_alloc.c
--- a/mm/page_alloc.c~memcg-soft-limit-reclaim-on-contention
+++ a/mm/page_alloc.c
@@ -1582,7 +1582,15 @@ nofail_alloc:
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
+	did_some_progress = mem_cgroup_soft_limit_reclaim(gfp_mask);
+	/*
+	 * If we made no progress or need higher order allocations
+	 * try_to_free_pages() is still our best bet, since mem_cgroup
+	 * reclaim does not handle freeing pages greater than order 0
+	 */
+	if (!did_some_progress || order)
+		did_some_progress = try_to_free_pages(zonelist, order,
+							gfp_mask);
 
 	p->reclaim_state = NULL;
 	p->flags &= ~PF_MEMALLOC;
_

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
