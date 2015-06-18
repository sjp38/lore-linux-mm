Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 809416B0083
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 19:00:06 -0400 (EDT)
Received: by igblr2 with SMTP id lr2so2317237igb.0
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 16:00:06 -0700 (PDT)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com. [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id b19si609802igr.21.2015.06.18.16.00.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jun 2015 16:00:05 -0700 (PDT)
Received: by igbzc4 with SMTP id zc4so2499042igb.0
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 16:00:05 -0700 (PDT)
Date: Thu, 18 Jun 2015 16:00:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/3] mm, oom: organize oom context into struct
Message-ID: <alpine.DEB.2.10.1506181555350.13736@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

There are essential elements to an oom context that are passed around to
multiple functions.

Organize these elements into a new struct, struct oom_context, that
specifies the context for an oom condition.

This patch introduces no functional change.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 drivers/tty/sysrq.c |  12 +++++-
 include/linux/oom.h |  25 +++++++-----
 mm/memcontrol.c     |  16 +++++---
 mm/oom_kill.c       | 115 ++++++++++++++++++++++++----------------------------
 mm/page_alloc.c     |  10 ++++-
 5 files changed, 98 insertions(+), 80 deletions(-)

diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -353,9 +353,17 @@ static struct sysrq_key_op sysrq_term_op = {
 
 static void moom_callback(struct work_struct *ignored)
 {
+	const gfp_t gfp_mask = GFP_KERNEL;
+	struct oom_control oc = {
+		.zonelist = node_zonelist(first_memory_node, gfp_mask),
+		.nodemask = NULL,
+		.gfp_mask = gfp_mask,
+		.order = 0,
+		.force_kill = true,
+	};
+
 	mutex_lock(&oom_lock);
-	if (!out_of_memory(node_zonelist(first_memory_node, GFP_KERNEL),
-			   GFP_KERNEL, 0, NULL, true))
+	if (!out_of_memory(&oc))
 		pr_info("OOM request ignored because killer is disabled\n");
 	mutex_unlock(&oom_lock);
 }
diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -12,6 +12,14 @@ struct notifier_block;
 struct mem_cgroup;
 struct task_struct;
 
+struct oom_control {
+	struct zonelist *zonelist;
+	nodemask_t	*nodemask;
+	gfp_t		gfp_mask;
+	int		order;
+	bool		force_kill;
+};
+
 /*
  * Types of limitations to the nodes from which allocations may occur
  */
@@ -57,21 +65,18 @@ extern unsigned long oom_badness(struct task_struct *p,
 
 extern int oom_kills_count(void);
 extern void note_oom_kill(void);
-extern void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
+extern void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			     unsigned int points, unsigned long totalpages,
-			     struct mem_cgroup *memcg, nodemask_t *nodemask,
-			     const char *message);
+			     struct mem_cgroup *memcg, const char *message);
 
-extern void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
-			       int order, const nodemask_t *nodemask,
+extern void check_panic_on_oom(struct oom_control *oc,
+			       enum oom_constraint constraint,
 			       struct mem_cgroup *memcg);
 
-extern enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
-		unsigned long totalpages, const nodemask_t *nodemask,
-		bool force_kill);
+extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
+		struct task_struct *task, unsigned long totalpages);
 
-extern bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
-		int order, nodemask_t *mask, bool force_kill);
+extern bool out_of_memory(struct oom_control *oc);
 
 extern void exit_oom_victim(void);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1545,6 +1545,13 @@ static unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
 static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 				     int order)
 {
+	struct oom_control oc = {
+		.zonelist = NULL,
+		.nodemask = NULL,
+		.gfp_mask = gfp_mask,
+		.order = order,
+		.force_kill = false,
+	};
 	struct mem_cgroup *iter;
 	unsigned long chosen_points = 0;
 	unsigned long totalpages;
@@ -1563,7 +1570,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		goto unlock;
 	}
 
-	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL, memcg);
+	check_panic_on_oom(&oc, CONSTRAINT_MEMCG, memcg);
 	totalpages = mem_cgroup_get_limit(memcg) ? : 1;
 	for_each_mem_cgroup_tree(iter, memcg) {
 		struct css_task_iter it;
@@ -1571,8 +1578,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 
 		css_task_iter_start(&iter->css, &it);
 		while ((task = css_task_iter_next(&it))) {
-			switch (oom_scan_process_thread(task, totalpages, NULL,
-							false)) {
+			switch (oom_scan_process_thread(&oc, task, totalpages)) {
 			case OOM_SCAN_SELECT:
 				if (chosen)
 					put_task_struct(chosen);
@@ -1610,8 +1616,8 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 
 	if (chosen) {
 		points = chosen_points * 1000 / totalpages;
-		oom_kill_process(chosen, gfp_mask, order, points, totalpages,
-				 memcg, NULL, "Memory cgroup out of memory");
+		oom_kill_process(&oc, chosen, points, totalpages, memcg,
+				 "Memory cgroup out of memory");
 	}
 unlock:
 	mutex_unlock(&oom_lock);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -196,27 +196,26 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
  * Determine the type of allocation constraint.
  */
 #ifdef CONFIG_NUMA
-static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
-				gfp_t gfp_mask, nodemask_t *nodemask,
-				unsigned long *totalpages)
+static enum oom_constraint constrained_alloc(struct oom_control *oc,
+					     unsigned long *totalpages)
 {
 	struct zone *zone;
 	struct zoneref *z;
-	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
+	enum zone_type high_zoneidx = gfp_zone(oc->gfp_mask);
 	bool cpuset_limited = false;
 	int nid;
 
 	/* Default to all available memory */
 	*totalpages = totalram_pages + total_swap_pages;
 
-	if (!zonelist)
+	if (!oc->zonelist)
 		return CONSTRAINT_NONE;
 	/*
 	 * Reach here only when __GFP_NOFAIL is used. So, we should avoid
 	 * to kill current.We have to random task kill in this case.
 	 * Hopefully, CONSTRAINT_THISNODE...but no way to handle it, now.
 	 */
-	if (gfp_mask & __GFP_THISNODE)
+	if (oc->gfp_mask & __GFP_THISNODE)
 		return CONSTRAINT_NONE;
 
 	/*
@@ -224,17 +223,18 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
 	 * the page allocator means a mempolicy is in effect.  Cpuset policy
 	 * is enforced in get_page_from_freelist().
 	 */
-	if (nodemask && !nodes_subset(node_states[N_MEMORY], *nodemask)) {
+	if (oc->nodemask &&
+	    !nodes_subset(node_states[N_MEMORY], *oc->nodemask)) {
 		*totalpages = total_swap_pages;
-		for_each_node_mask(nid, *nodemask)
+		for_each_node_mask(nid, *oc->nodemask)
 			*totalpages += node_spanned_pages(nid);
 		return CONSTRAINT_MEMORY_POLICY;
 	}
 
 	/* Check this allocation failure is caused by cpuset's wall function */
-	for_each_zone_zonelist_nodemask(zone, z, zonelist,
-			high_zoneidx, nodemask)
-		if (!cpuset_zone_allowed(zone, gfp_mask))
+	for_each_zone_zonelist_nodemask(zone, z, oc->zonelist,
+			high_zoneidx, oc->nodemask)
+		if (!cpuset_zone_allowed(zone, oc->gfp_mask))
 			cpuset_limited = true;
 
 	if (cpuset_limited) {
@@ -246,20 +246,18 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
 	return CONSTRAINT_NONE;
 }
 #else
-static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
-				gfp_t gfp_mask, nodemask_t *nodemask,
-				unsigned long *totalpages)
+static enum oom_constraint constrained_alloc(struct oom_control *oc,
+					     unsigned long *totalpages)
 {
 	*totalpages = totalram_pages + total_swap_pages;
 	return CONSTRAINT_NONE;
 }
 #endif
 
-enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
-		unsigned long totalpages, const nodemask_t *nodemask,
-		bool force_kill)
+enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
+			struct task_struct *task, unsigned long totalpages)
 {
-	if (oom_unkillable_task(task, NULL, nodemask))
+	if (oom_unkillable_task(task, NULL, oc->nodemask))
 		return OOM_SCAN_CONTINUE;
 
 	/*
@@ -267,7 +265,7 @@ enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
 	 * Don't allow any other task to have access to the reserves.
 	 */
 	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
-		if (!force_kill)
+		if (!oc->force_kill)
 			return OOM_SCAN_ABORT;
 	}
 	if (!task->mm)
@@ -280,7 +278,7 @@ enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
 	if (oom_task_origin(task))
 		return OOM_SCAN_SELECT;
 
-	if (task_will_free_mem(task) && !force_kill)
+	if (task_will_free_mem(task) && !oc->force_kill)
 		return OOM_SCAN_ABORT;
 
 	return OOM_SCAN_OK;
@@ -289,12 +287,9 @@ enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
 /*
  * Simple selection loop. We chose the process with the highest
  * number of 'points'.  Returns -1 on scan abort.
- *
- * (not docbooked, we don't want this one cluttering up the manual)
  */
-static struct task_struct *select_bad_process(unsigned int *ppoints,
-		unsigned long totalpages, const nodemask_t *nodemask,
-		bool force_kill)
+static struct task_struct *select_bad_process(struct oom_control *oc,
+		unsigned int *ppoints, unsigned long totalpages)
 {
 	struct task_struct *g, *p;
 	struct task_struct *chosen = NULL;
@@ -304,8 +299,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 	for_each_process_thread(g, p) {
 		unsigned int points;
 
-		switch (oom_scan_process_thread(p, totalpages, nodemask,
-						force_kill)) {
+		switch (oom_scan_process_thread(oc, p, totalpages)) {
 		case OOM_SCAN_SELECT:
 			chosen = p;
 			chosen_points = ULONG_MAX;
@@ -318,7 +312,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 		case OOM_SCAN_OK:
 			break;
 		};
-		points = oom_badness(p, NULL, nodemask, totalpages);
+		points = oom_badness(p, NULL, oc->nodemask, totalpages);
 		if (!points || points < chosen_points)
 			continue;
 		/* Prefer thread group leaders for display purposes */
@@ -380,13 +374,13 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 	rcu_read_unlock();
 }
 
-static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
-			struct mem_cgroup *memcg, const nodemask_t *nodemask)
+static void dump_header(struct oom_control *oc, struct task_struct *p,
+			struct mem_cgroup *memcg)
 {
 	task_lock(current);
 	pr_warning("%s invoked oom-killer: gfp_mask=0x%x, order=%d, "
 		"oom_score_adj=%hd\n",
-		current->comm, gfp_mask, order,
+		current->comm, oc->gfp_mask, oc->order,
 		current->signal->oom_score_adj);
 	cpuset_print_task_mems_allowed(current);
 	task_unlock(current);
@@ -396,7 +390,7 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 	else
 		show_mem(SHOW_MEM_FILTER_NODES);
 	if (sysctl_oom_dump_tasks)
-		dump_tasks(memcg, nodemask);
+		dump_tasks(memcg, oc->nodemask);
 }
 
 /*
@@ -487,10 +481,9 @@ void oom_killer_enable(void)
  * Must be called while holding a reference to p, which will be released upon
  * returning.
  */
-void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
+void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		      unsigned int points, unsigned long totalpages,
-		      struct mem_cgroup *memcg, nodemask_t *nodemask,
-		      const char *message)
+		      struct mem_cgroup *memcg, const char *message)
 {
 	struct task_struct *victim = p;
 	struct task_struct *child;
@@ -514,7 +507,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	task_unlock(p);
 
 	if (__ratelimit(&oom_rs))
-		dump_header(p, gfp_mask, order, memcg, nodemask);
+		dump_header(oc, p, memcg);
 
 	task_lock(p);
 	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
@@ -537,7 +530,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			/*
 			 * oom_badness() returns 0 if the thread is unkillable
 			 */
-			child_points = oom_badness(child, memcg, nodemask,
+			child_points = oom_badness(child, memcg, oc->nodemask,
 								totalpages);
 			if (child_points > victim_points) {
 				put_task_struct(victim);
@@ -600,8 +593,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 /*
  * Determines whether the kernel must panic because of the panic_on_oom sysctl.
  */
-void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
-			int order, const nodemask_t *nodemask,
+void check_panic_on_oom(struct oom_control *oc, enum oom_constraint constraint,
 			struct mem_cgroup *memcg)
 {
 	if (likely(!sysctl_panic_on_oom))
@@ -615,7 +607,7 @@ void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
 		if (constraint != CONSTRAINT_NONE)
 			return;
 	}
-	dump_header(NULL, gfp_mask, order, memcg, nodemask);
+	dump_header(oc, NULL, memcg);
 	panic("Out of memory: %s panic_on_oom is enabled\n",
 		sysctl_panic_on_oom == 2 ? "compulsory" : "system-wide");
 }
@@ -635,22 +627,16 @@ int unregister_oom_notifier(struct notifier_block *nb)
 EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 
 /**
- * __out_of_memory - kill the "best" process when we run out of memory
- * @zonelist: zonelist pointer
- * @gfp_mask: memory allocation flags
- * @order: amount of memory being requested as a power of 2
- * @nodemask: nodemask passed to page allocator
- * @force_kill: true if a task must be killed, even if others are exiting
+ * out_of_memory - kill the "best" process when we run out of memory
+ * @oc: pointer to struct oom_control
  *
  * If we run out of memory, we have the choice between either
  * killing a random task (bad), letting the system crash (worse)
  * OR try to be smart about which process to kill. Note that we
  * don't have to be perfect here, we just have to be good.
  */
-bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
-		   int order, nodemask_t *nodemask, bool force_kill)
+bool out_of_memory(struct oom_control *oc)
 {
-	const nodemask_t *mpol_mask;
 	struct task_struct *p;
 	unsigned long totalpages;
 	unsigned long freed = 0;
@@ -684,30 +670,29 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
 	 */
-	constraint = constrained_alloc(zonelist, gfp_mask, nodemask,
-						&totalpages);
-	mpol_mask = (constraint == CONSTRAINT_MEMORY_POLICY) ? nodemask : NULL;
-	check_panic_on_oom(constraint, gfp_mask, order, mpol_mask, NULL);
+	constraint = constrained_alloc(oc, &totalpages);
+	if (constraint != CONSTRAINT_MEMORY_POLICY)
+		oc->nodemask = NULL;
+	check_panic_on_oom(oc, constraint, NULL);
 
 	if (sysctl_oom_kill_allocating_task && current->mm &&
-	    !oom_unkillable_task(current, NULL, nodemask) &&
+	    !oom_unkillable_task(current, NULL, oc->nodemask) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
 		get_task_struct(current);
-		oom_kill_process(current, gfp_mask, order, 0, totalpages, NULL,
-				 nodemask,
+		oom_kill_process(oc, current, 0, totalpages, NULL,
 				 "Out of memory (oom_kill_allocating_task)");
 		goto out;
 	}
 
-	p = select_bad_process(&points, totalpages, mpol_mask, force_kill);
+	p = select_bad_process(oc, &points, totalpages);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p) {
-		dump_header(NULL, gfp_mask, order, NULL, mpol_mask);
+		dump_header(oc, NULL, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
 	if (p != (void *)-1UL) {
-		oom_kill_process(p, gfp_mask, order, points, totalpages, NULL,
-				 nodemask, "Out of memory");
+		oom_kill_process(oc, p, points, totalpages, NULL,
+				 "Out of memory");
 		killed = 1;
 	}
 out:
@@ -728,13 +713,21 @@ out:
  */
 void pagefault_out_of_memory(void)
 {
+	struct oom_control oc = {
+		.zonelist = NULL,
+		.nodemask = NULL,
+		.gfp_mask = 0,
+		.order = 0,
+		.force_kill = false,
+	};
+
 	if (mem_cgroup_oom_synchronize(true))
 		return;
 
 	if (!mutex_trylock(&oom_lock))
 		return;
 
-	if (!out_of_memory(NULL, 0, 0, NULL, false)) {
+	if (!out_of_memory(&oc)) {
 		/*
 		 * There shouldn't be any user tasks runnable while the
 		 * OOM killer is disabled, so the current task has to
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2680,6 +2680,13 @@ static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	const struct alloc_context *ac, unsigned long *did_some_progress)
 {
+	struct oom_control oc = {
+		.zonelist = ac->zonelist,
+		.nodemask = ac->nodemask,
+		.gfp_mask = gfp_mask,
+		.order = order,
+		.force_kill = false,
+	};
 	struct page *page;
 
 	*did_some_progress = 0;
@@ -2731,8 +2738,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			goto out;
 	}
 	/* Exhausted what can be done so it's blamo time */
-	if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false)
-			|| WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
+	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
 		*did_some_progress = 1;
 out:
 	mutex_unlock(&oom_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
