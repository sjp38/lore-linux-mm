Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3CDAB6B00C5
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 05:08:11 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8I98BYY003896
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 18 Sep 2009 18:08:12 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 80BB145DE5D
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 18:08:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F92345DE4F
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 18:08:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 33095E78002
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 18:08:11 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D46611DB803C
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 18:08:10 +0900 (JST)
Date: Fri, 18 Sep 2009 18:06:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 11/11][mmotm] memcg: more commentary and clean up
Message-Id: <20090918180606.8ca94758.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090918174757.672f1e8e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090909173903.afc86d85.kamezawa.hiroyu@jp.fujitsu.com>
	<20090918174757.672f1e8e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch itself should be sorted out ;)
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch does
  - move mem_cgroup_move_lists() before swap-cache special LRU functions.
  - move get_swappiness() around functions related to vmscan logic.
  - grouping oom-killer functions.
  - adds some commentary

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |  144 +++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 85 insertions(+), 59 deletions(-)

Index: mmotm-2.6.31-Sep17/mm/memcontrol.c
===================================================================
--- mmotm-2.6.31-Sep17.orig/mm/memcontrol.c
+++ mmotm-2.6.31-Sep17/mm/memcontrol.c
@@ -853,6 +853,15 @@ void mem_cgroup_add_lru_list(struct page
 	list_add(&pc->lru, &mz->lists[lru]);
 }
 
+void mem_cgroup_move_lists(struct page *page,
+			   enum lru_list from, enum lru_list to)
+{
+	if (mem_cgroup_disabled())
+		return;
+	mem_cgroup_del_lru_list(page, from);
+	mem_cgroup_add_lru_list(page, to);
+}
+
 /*
  * At handling SwapCache, pc->mem_cgroup may be changed while it's linked to
  * lru because the page may.be reused after it's fully uncharged (because of
@@ -889,15 +898,10 @@ static void mem_cgroup_lru_add_after_com
 	spin_unlock_irqrestore(&zone->lru_lock, flags);
 }
 
-
-void mem_cgroup_move_lists(struct page *page,
-			   enum lru_list from, enum lru_list to)
-{
-	if (mem_cgroup_disabled())
-		return;
-	mem_cgroup_del_lru_list(page, from);
-	mem_cgroup_add_lru_list(page, to);
-}
+/*
+ * Check a task is under a mem_cgroup. Because we do hierarchical accounting,
+ * we have to check whether one of ancestors is "mem" or not.
+ */
 
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
 {
@@ -920,7 +924,7 @@ int task_in_mem_cgroup(struct task_struc
 }
 
 /*
- * prev_priority control...this will be used in memory reclaim path.
+ * Functions for LRU managenet called by vmscan.c
  */
 int mem_cgroup_get_reclaim_priority(struct mem_cgroup *mem)
 {
@@ -948,7 +952,13 @@ void mem_cgroup_record_reclaim_priority(
 	spin_unlock(&mem->reclaim_param_lock);
 }
 
-static int calc_inactive_ratio(struct mem_cgroup *memcg, unsigned long *present_pages)
+/*
+ * Inactive ratio is a parameter for what ratio of pages should be in
+ * inactive list. This is used by memory reclaim codes.(see vmscan.c)
+ * generic zone's inactive_ratio is calculated in page_alloc.c
+ */
+static int
+calc_inactive_ratio(struct mem_cgroup *memcg, unsigned long *present_pages)
 {
 	unsigned long active;
 	unsigned long inactive;
@@ -971,7 +981,10 @@ static int calc_inactive_ratio(struct me
 
 	return inactive_ratio;
 }
-
+/*
+ * If inactive_xxx is in short, active_xxx will be scanned. And
+ * rotation occurs.
+ */
 int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
 {
 	unsigned long active;
@@ -1037,6 +1050,28 @@ mem_cgroup_get_reclaim_stat_from_page(st
 	return &mz->reclaim_stat;
 }
 
+
+static unsigned int get_swappiness(struct mem_cgroup *memcg)
+{
+	struct cgroup *cgrp = memcg->css.cgroup;
+	unsigned int swappiness;
+
+	/* root ? */
+	if (cgrp->parent == NULL)
+		return vm_swappiness;
+
+	spin_lock(&memcg->reclaim_param_lock);
+	swappiness = memcg->swappiness;
+	spin_unlock(&memcg->reclaim_param_lock);
+
+	return swappiness;
+}
+
+/*
+ * Called by shrink_xxxx_list functions for grabbing pages as reclaim target.
+ * please see isolate_lru_pages() in mm/vmscan.c
+ */
+
 unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
@@ -1092,7 +1127,7 @@ unsigned long mem_cgroup_isolate_pages(u
 	return nr_taken;
 }
 
-
+/* check we hit mem->res or mem->memsw hard-limit or not */
 static bool mem_cgroup_check_under_limit(struct mem_cgroup *mem)
 {
 	if (do_swap_account) {
@@ -1104,32 +1139,41 @@ static bool mem_cgroup_check_under_limit
 			return true;
 	return false;
 }
-
-static unsigned int get_swappiness(struct mem_cgroup *memcg)
+/*
+ * OOM-Killer related stuff.
+ */
+bool mem_cgroup_oom_called(struct task_struct *task)
 {
-	struct cgroup *cgrp = memcg->css.cgroup;
-	unsigned int swappiness;
-
-	/* root ? */
-	if (cgrp->parent == NULL)
-		return vm_swappiness;
-
-	spin_lock(&memcg->reclaim_param_lock);
-	swappiness = memcg->swappiness;
-	spin_unlock(&memcg->reclaim_param_lock);
+	bool ret = false;
+	struct mem_cgroup *mem;
+	struct mm_struct *mm;
 
-	return swappiness;
+	rcu_read_lock();
+	mm = task->mm;
+	if (!mm)
+		mm = &init_mm;
+	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
+	if (mem && time_before(jiffies, mem->last_oom_jiffies + HZ/10))
+		ret = true;
+	rcu_read_unlock();
+	return ret;
 }
 
-static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void *data)
+static int record_last_oom_cb(struct mem_cgroup *mem, void *data)
 {
-	int *val = data;
-	(*val)++;
+	mem->last_oom_jiffies = jiffies;
 	return 0;
 }
 
+static void record_last_oom(struct mem_cgroup *mem)
+{
+	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
+}
+
+
 /**
- * mem_cgroup_print_mem_info: Called from OOM with tasklist_lock held in read mode.
+ * mem_cgroup_print_mem_info: Called from OOM with tasklist_lock held in
+ * read mode.
  * @memcg: The memory cgroup that went over limit
  * @p: Task that is going to be killed
  *
@@ -1195,6 +1239,14 @@ done:
 		res_counter_read_u64(&memcg->memsw, RES_FAILCNT));
 }
 
+
+
+static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void *data)
+{
+	int *val = data;
+	(*val)++;
+	return 0;
+}
 /*
  * This function returns the number of memcg under hierarchy tree. Returns
  * 1(self count) if no children.
@@ -1338,35 +1390,9 @@ static int mem_cgroup_hierarchical_recla
 	return total;
 }
 
-bool mem_cgroup_oom_called(struct task_struct *task)
-{
-	bool ret = false;
-	struct mem_cgroup *mem;
-	struct mm_struct *mm;
-
-	rcu_read_lock();
-	mm = task->mm;
-	if (!mm)
-		mm = &init_mm;
-	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
-	if (mem && time_before(jiffies, mem->last_oom_jiffies + HZ/10))
-		ret = true;
-	rcu_read_unlock();
-	return ret;
-}
-
-static int record_last_oom_cb(struct mem_cgroup *mem, void *data)
-{
-	mem->last_oom_jiffies = jiffies;
-	return 0;
-}
-
-static void record_last_oom(struct mem_cgroup *mem)
-{
-	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
-}
-
-
+/*
+ * For Batch charge.
+ */
 #define CHARGE_SIZE	(64 * PAGE_SIZE)
 struct memcg_stock_pcp {
 	struct mem_cgroup *cached;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
