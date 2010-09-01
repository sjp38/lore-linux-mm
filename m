Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 73B656B004D
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 17:27:27 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o81LRLgv025299
	for <linux-mm@kvack.org>; Wed, 1 Sep 2010 14:27:21 -0700
Received: from pzk28 (pzk28.prod.google.com [10.243.19.156])
	by wpaz5.hot.corp.google.com with ESMTP id o81LRJ3V012609
	for <linux-mm@kvack.org>; Wed, 1 Sep 2010 14:27:20 -0700
Received: by pzk28 with SMTP id 28so4042792pzk.37
        for <linux-mm@kvack.org>; Wed, 01 Sep 2010 14:27:19 -0700 (PDT)
Date: Wed, 1 Sep 2010 14:27:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] oom: filter unkillable tasks from tasklist dump
Message-ID: <alpine.DEB.2.00.1009011426260.28408@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

/proc/sys/vm/oom_dump_tasks is enabled by default, so it's necessary to
limit as much information as possible that it should emit.

The tasklist dump should be filtered to only those tasks that are
eligible for oom kill.  This is already done for memcg ooms, but this
patch extends it to both cpuset and mempolicy ooms as well as init.

In addition to suppressing irrelevant information, this also reduces
confusion since users currently don't know which tasks in the tasklist
aren't eligible for kill (such as those attached to cpusets or bound to
mempolicies with a disjoint set of mems or nodes, respectively) since
that information is not shown.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   40 +++++++++++++++++++---------------------
 1 files changed, 19 insertions(+), 21 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -121,8 +121,8 @@ struct task_struct *find_lock_task_mm(struct task_struct *p)
 }
 
 /* return true if the task is not adequate as candidate victim task. */
-static bool oom_unkillable_task(struct task_struct *p, struct mem_cgroup *mem,
-			   const nodemask_t *nodemask)
+static bool oom_unkillable_task(struct task_struct *p,
+		const struct mem_cgroup *mem, const nodemask_t *nodemask)
 {
 	if (is_global_init(p))
 		return true;
@@ -340,26 +340,24 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 /**
  * dump_tasks - dump current memory state of all system tasks
  * @mem: current's memory controller, if constrained
+ * @nodemask: nodemask passed to page allocator for mempolicy ooms
  *
- * Dumps the current memory state of all system tasks, excluding kernel threads.
+ * Dumps the current memory state of all eligible tasks.  Tasks not in the same
+ * memcg, not in the same cpuset, or bound to a disjoint set of mempolicy nodes
+ * are not shown.
  * State information includes task's pid, uid, tgid, vm size, rss, cpu, oom_adj
  * value, oom_score_adj value, and name.
  *
- * If the actual is non-NULL, only tasks that are a member of the mem_cgroup are
- * shown.
- *
  * Call with tasklist_lock read-locked.
  */
-static void dump_tasks(const struct mem_cgroup *mem)
+static void dump_tasks(const struct mem_cgroup *mem, const nodemask_t *nodemask)
 {
 	struct task_struct *p;
 	struct task_struct *task;
 
 	pr_info("[ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name\n");
 	for_each_process(p) {
-		if (p->flags & PF_KTHREAD)
-			continue;
-		if (mem && !task_in_mem_cgroup(p, mem))
+		if (oom_unkillable_task(p, mem, nodemask))
 			continue;
 
 		task = find_lock_task_mm(p);
@@ -382,7 +380,7 @@ static void dump_tasks(const struct mem_cgroup *mem)
 }
 
 static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
-							struct mem_cgroup *mem)
+			struct mem_cgroup *mem, const nodemask_t *nodemask)
 {
 	task_lock(current);
 	pr_warning("%s invoked oom-killer: gfp_mask=0x%x, order=%d, "
@@ -395,7 +393,7 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 	mem_cgroup_print_oom_info(mem, p);
 	show_mem();
 	if (sysctl_oom_dump_tasks)
-		dump_tasks(mem);
+		dump_tasks(mem, nodemask);
 }
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
@@ -461,7 +459,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	unsigned int victim_points = 0;
 
 	if (printk_ratelimit())
-		dump_header(p, gfp_mask, order, mem);
+		dump_header(p, gfp_mask, order, mem, nodemask);
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -507,7 +505,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
  * Determines whether the kernel must panic because of the panic_on_oom sysctl.
  */
 static void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
-				int order)
+				int order, const nodemask_t *nodemask)
 {
 	if (likely(!sysctl_panic_on_oom))
 		return;
@@ -521,7 +519,7 @@ static void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
 			return;
 	}
 	read_lock(&tasklist_lock);
-	dump_header(NULL, gfp_mask, order, NULL);
+	dump_header(NULL, gfp_mask, order, NULL, nodemask);
 	read_unlock(&tasklist_lock);
 	panic("Out of memory: %s panic_on_oom is enabled\n",
 		sysctl_panic_on_oom == 2 ? "compulsory" : "system-wide");
@@ -534,7 +532,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 	unsigned int points = 0;
 	struct task_struct *p;
 
-	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, 0);
+	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, 0, NULL);
 	limit = mem_cgroup_get_limit(mem) >> PAGE_SHIFT;
 	read_lock(&tasklist_lock);
 retry:
@@ -666,6 +664,7 @@ static void clear_system_oom(void)
 void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		int order, nodemask_t *nodemask)
 {
+	const nodemask_t *mpol_mask;
 	struct task_struct *p;
 	unsigned long totalpages;
 	unsigned long freed = 0;
@@ -695,7 +694,8 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 */
 	constraint = constrained_alloc(zonelist, gfp_mask, nodemask,
 						&totalpages);
-	check_panic_on_oom(constraint, gfp_mask, order);
+	mpol_mask = (constraint == CONSTRAINT_MEMORY_POLICY) ? nodemask : NULL;
+	check_panic_on_oom(constraint, gfp_mask, order, mpol_mask);
 
 	read_lock(&tasklist_lock);
 	if (sysctl_oom_kill_allocating_task &&
@@ -713,15 +713,13 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	}
 
 retry:
-	p = select_bad_process(&points, totalpages, NULL,
-			constraint == CONSTRAINT_MEMORY_POLICY ? nodemask :
-								 NULL);
+	p = select_bad_process(&points, totalpages, NULL, mpol_mask);
 	if (PTR_ERR(p) == -1UL)
 		goto out;
 
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p) {
-		dump_header(NULL, gfp_mask, order, NULL);
+		dump_header(NULL, gfp_mask, order, NULL, mpol_mask);
 		read_unlock(&tasklist_lock);
 		panic("Out of memory and no killable processes...\n");
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
