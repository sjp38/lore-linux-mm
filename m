Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A67A56B00BC
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 05:01:05 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8I90xbO032640
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 18 Sep 2009 18:01:00 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F30A45DE55
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 18:00:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EEAD545DE51
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 18:00:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CF2991DB8037
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 18:00:58 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 78422E08001
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 18:00:58 +0900 (JST)
Date: Fri, 18 Sep 2009 17:58:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 7/11] memcg: rename from_cont to from_cgroup
Message-Id: <20090918175854.2815f8e7.kamezawa.hiroyu@jp.fujitsu.com>
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


Rename mem_cgroup_from_cont() to mem_cgroup_from_cgroup()
And moves functions for accessing mem_cgroup to the top of the file.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |  127 +++++++++++++++++++++++++++++---------------------------
 1 file changed, 67 insertions(+), 60 deletions(-)

Index: mmotm-2.6.31-Sep17/mm/memcontrol.c
===================================================================
--- mmotm-2.6.31-Sep17.orig/mm/memcontrol.c
+++ mmotm-2.6.31-Sep17/mm/memcontrol.c
@@ -237,6 +237,57 @@ static struct mem_cgroup *parent_mem_cgr
 static void drain_all_stock_async(void);
 
 /*
+ * Utitily for accessing mem_cgroup via various objects.
+ */
+#define mem_cgroup_from_res_counter(counter, member)	\
+	container_of(counter, struct mem_cgroup, member)
+
+
+static struct mem_cgroup *mem_cgroup_from_cgroup(struct cgroup *cont)
+{
+	return container_of(cgroup_subsys_state(cont,
+				mem_cgroup_subsys_id), struct mem_cgroup,
+				css);
+}
+
+/* we get task's mem_cgroup from mm->owner, not this task */
+struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
+{
+	/*
+	 * mm_update_next_owner() may clear mm->owner to NULL
+	 * if it races with swapoff, page migration, etc.
+	 * So this can be called with p == NULL.
+	 */
+	if (unlikely(!p))
+		return NULL;
+
+	return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
+				struct mem_cgroup, css);
+}
+
+/* get mem_cgroup from mm_struct and increment css->refcnt */
+static struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
+{
+	struct mem_cgroup *mem = NULL;
+
+	if (!mm)
+		return NULL;
+	/*
+	 * Because we have no locks, mm->owner's may be being moved to other
+	 * cgroup. We use css_tryget() here even if this looks
+	 * pessimistic (rather than adding locks here).
+	 */
+	rcu_read_lock();
+	do {
+		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
+		if (unlikely(!mem))
+			break;
+	} while (!css_tryget(&mem->css));
+	rcu_read_unlock();
+	return mem;
+}
+
+/*
  * Functions for acceccing cpu local statistics. modification should be
  * done under preempt disabled. __mem_cgroup_xxx functions are for low level.
  */
@@ -571,48 +622,6 @@ static unsigned long mem_cgroup_get_loca
 	return total;
 }
 
-static struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
-{
-	return container_of(cgroup_subsys_state(cont,
-				mem_cgroup_subsys_id), struct mem_cgroup,
-				css);
-}
-
-struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
-{
-	/*
-	 * mm_update_next_owner() may clear mm->owner to NULL
-	 * if it races with swapoff, page migration, etc.
-	 * So this can be called with p == NULL.
-	 */
-	if (unlikely(!p))
-		return NULL;
-
-	return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
-				struct mem_cgroup, css);
-}
-
-static struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
-{
-	struct mem_cgroup *mem = NULL;
-
-	if (!mm)
-		return NULL;
-	/*
-	 * Because we have no locks, mm->owner's may be being moved to other
-	 * cgroup. We use css_tryget() here even if this looks
-	 * pessimistic (rather than adding locks here).
-	 */
-	rcu_read_lock();
-	do {
-		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
-		if (unlikely(!mem))
-			break;
-	} while (!css_tryget(&mem->css));
-	rcu_read_unlock();
-	return mem;
-}
-
 /*
  * Call callback function against all cgroup under hierarchy tree.
  */
@@ -992,8 +1001,6 @@ unsigned long mem_cgroup_isolate_pages(u
 	return nr_taken;
 }
 
-#define mem_cgroup_from_res_counter(counter, member)	\
-	container_of(counter, struct mem_cgroup, member)
 
 static bool mem_cgroup_check_under_limit(struct mem_cgroup *mem)
 {
@@ -1712,7 +1719,7 @@ static int mem_cgroup_move_parent(struct
 		return -EINVAL;
 
 
-	parent = mem_cgroup_from_cont(pcg);
+	parent = mem_cgroup_from_cgroup(pcg);
 
 
 	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false, page);
@@ -2660,25 +2667,25 @@ try_to_free:
 
 int mem_cgroup_force_empty_write(struct cgroup *cont, unsigned int event)
 {
-	return mem_cgroup_force_empty(mem_cgroup_from_cont(cont), true);
+	return mem_cgroup_force_empty(mem_cgroup_from_cgroup(cont), true);
 }
 
 
 static u64 mem_cgroup_hierarchy_read(struct cgroup *cont, struct cftype *cft)
 {
-	return mem_cgroup_from_cont(cont)->use_hierarchy;
+	return mem_cgroup_from_cgroup(cont)->use_hierarchy;
 }
 
 static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
 					u64 val)
 {
 	int retval = 0;
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *mem = mem_cgroup_from_cgroup(cont);
 	struct cgroup *parent = cont->parent;
 	struct mem_cgroup *parent_mem = NULL;
 
 	if (parent)
-		parent_mem = mem_cgroup_from_cont(parent);
+		parent_mem = mem_cgroup_from_cgroup(parent);
 
 	cgroup_lock();
 	/*
@@ -2728,7 +2735,7 @@ mem_cgroup_get_recursive_idx_stat(struct
 
 static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
 {
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *mem = mem_cgroup_from_cgroup(cont);
 	u64 idx_val, val;
 	int type, name;
 
@@ -2774,7 +2781,7 @@ static u64 mem_cgroup_read(struct cgroup
 static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 			    const char *buffer)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_cgroup(cont);
 	int type, name;
 	unsigned long long val;
 	int ret;
@@ -2831,7 +2838,7 @@ static void memcg_get_hierarchical_limit
 
 	while (cgroup->parent) {
 		cgroup = cgroup->parent;
-		memcg = mem_cgroup_from_cont(cgroup);
+		memcg = mem_cgroup_from_cgroup(cgroup);
 		if (!memcg->use_hierarchy)
 			break;
 		tmp = res_counter_read_u64(&memcg->res, RES_LIMIT);
@@ -2850,7 +2857,7 @@ static int mem_cgroup_reset(struct cgrou
 	struct mem_cgroup *mem;
 	int type, name;
 
-	mem = mem_cgroup_from_cont(cont);
+	mem = mem_cgroup_from_cgroup(cont);
 	type = MEMFILE_TYPE(event);
 	name = MEMFILE_ATTR(event);
 	switch (name) {
@@ -2954,7 +2961,7 @@ mem_cgroup_get_total_stat(struct mem_cgr
 static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 				 struct cgroup_map_cb *cb)
 {
-	struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *mem_cont = mem_cgroup_from_cgroup(cont);
 	struct mcs_total_stat mystat;
 	int i;
 
@@ -3018,7 +3025,7 @@ static int mem_control_stat_show(struct 
 
 static u64 mem_cgroup_swappiness_read(struct cgroup *cgrp, struct cftype *cft)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *memcg = mem_cgroup_from_cgroup(cgrp);
 
 	return get_swappiness(memcg);
 }
@@ -3026,7 +3033,7 @@ static u64 mem_cgroup_swappiness_read(st
 static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
 				       u64 val)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *memcg = mem_cgroup_from_cgroup(cgrp);
 	struct mem_cgroup *parent;
 
 	if (val > 100)
@@ -3035,7 +3042,7 @@ static int mem_cgroup_swappiness_write(s
 	if (cgrp->parent == NULL)
 		return -EINVAL;
 
-	parent = mem_cgroup_from_cont(cgrp->parent);
+	parent = mem_cgroup_from_cgroup(cgrp->parent);
 
 	cgroup_lock();
 
@@ -3321,7 +3328,7 @@ mem_cgroup_create(struct cgroup_subsys *
 		hotcpu_notifier(memcg_stock_cpu_callback, 0);
 
 	} else {
-		parent = mem_cgroup_from_cont(cont->parent);
+		parent = mem_cgroup_from_cgroup(cont->parent);
 		mem->use_hierarchy = parent->use_hierarchy;
 	}
 
@@ -3355,7 +3362,7 @@ free_out:
 static int mem_cgroup_pre_destroy(struct cgroup_subsys *ss,
 					struct cgroup *cont)
 {
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *mem = mem_cgroup_from_cgroup(cont);
 
 	return mem_cgroup_force_empty(mem, false);
 }
@@ -3363,7 +3370,7 @@ static int mem_cgroup_pre_destroy(struct
 static void mem_cgroup_destroy(struct cgroup_subsys *ss,
 				struct cgroup *cont)
 {
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *mem = mem_cgroup_from_cgroup(cont);
 
 	mem_cgroup_put(mem);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
