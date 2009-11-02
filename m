Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 65A046B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 02:26:51 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA27Qm1Y003130
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 2 Nov 2009 16:26:48 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7262745DE6E
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:26:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4934045DE60
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:26:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3026C1DB8037
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:26:47 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D50E1DB803A
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:26:46 +0900 (JST)
Date: Mon, 2 Nov 2009 16:24:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][-mm][PATCH 1/6] oom-killer: updates for classification of OOM
Message-Id: <20091102162412.107ff8ac.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, aarcange@redhat.com, akpm@linux-foundation.org, minchan.kim@gmail.com, rientjes@google.com, vedran.furac@gmail.com, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Rewrite oom constarint to be up to date.

(1). Now, at badness calculation, oom_constraint and other information
   (which is available easily) are ignore. Pass them.

(2)Adds more classes of oom constraint as _MEMCG and _LOWMEM.
   This is just a change for interface and doesn't add new logic, at this stage.

(3) Pass nodemask to oom_kill. Now alloc_pages() are totally rewritten and
  it uses nodemask as its argument. By this, mempolicy doesn't have its own
  private zonelist. So, Passing nodemask to out_of_memory() is necessary.
  But, pagefault_out_of_memory() doesn't have enough information. We should
  visit this again, later.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 drivers/char/sysrq.c |    2 -
 fs/proc/base.c       |    4 +-
 include/linux/oom.h  |    8 +++-
 mm/oom_kill.c        |  101 +++++++++++++++++++++++++++++++++++++++------------
 mm/page_alloc.c      |    2 -
 5 files changed, 88 insertions(+), 29 deletions(-)

Index: mmotm-2.6.32-Nov2/include/linux/oom.h
===================================================================
--- mmotm-2.6.32-Nov2.orig/include/linux/oom.h
+++ mmotm-2.6.32-Nov2/include/linux/oom.h
@@ -10,23 +10,27 @@
 #ifdef __KERNEL__
 
 #include <linux/types.h>
+#include <linux/nodemask.h>
 
 struct zonelist;
 struct notifier_block;
 
 /*
- * Types of limitations to the nodes from which allocations may occur
+ * Types of limitations to zones from which allocations may occur
  */
 enum oom_constraint {
 	CONSTRAINT_NONE,
+	CONSTRAINT_LOWMEM,
 	CONSTRAINT_CPUSET,
 	CONSTRAINT_MEMORY_POLICY,
+	CONSTRAINT_MEMCG
 };
 
 extern int try_set_zone_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 
-extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order);
+extern void out_of_memory(struct zonelist *zonelist,
+		gfp_t gfp_mask, int order, nodemask_t *mask);
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
 
Index: mmotm-2.6.32-Nov2/mm/oom_kill.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/oom_kill.c
+++ mmotm-2.6.32-Nov2/mm/oom_kill.c
@@ -27,6 +27,7 @@
 #include <linux/notifier.h>
 #include <linux/memcontrol.h>
 #include <linux/security.h>
+#include <linux/mempolicy.h>
 
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
@@ -55,6 +56,8 @@ static int has_intersects_mems_allowed(s
  * badness - calculate a numeric value for how bad this task has been
  * @p: task struct of which task we should calculate
  * @uptime: current uptime in seconds
+ * @constraint: type of oom_kill region
+ * @mem: set if called by memory cgroup
  *
  * The formula used is relatively simple and documented inline in the
  * function. The main rationale is that we want to select a good task
@@ -70,7 +73,9 @@ static int has_intersects_mems_allowed(s
  *    of least surprise ... (be careful when you change it)
  */
 
-unsigned long badness(struct task_struct *p, unsigned long uptime)
+static unsigned long __badness(struct task_struct *p,
+		      unsigned long uptime, enum oom_constraint constraint,
+		      struct mem_cgroup *mem)
 {
 	unsigned long points, cpu_time, run_time;
 	struct mm_struct *mm;
@@ -193,30 +198,68 @@ unsigned long badness(struct task_struct
 	return points;
 }
 
+/* for /proc */
+unsigned long global_badness(struct task_struct *p, unsigned long uptime)
+{
+	return __badness(p, uptime, CONSTRAINT_NONE, NULL);
+}
+
+
 /*
  * Determine the type of allocation constraint.
  */
-static inline enum oom_constraint constrained_alloc(struct zonelist *zonelist,
-						    gfp_t gfp_mask)
-{
+
 #ifdef CONFIG_NUMA
+static inline enum oom_constraint guess_oom_context(struct zonelist *zonelist,
+		gfp_t gfp_mask, nodemask_t *nodemask)
+{
 	struct zone *zone;
 	struct zoneref *z;
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
-	nodemask_t nodes = node_states[N_HIGH_MEMORY];
+	enum oom_constraint ret = CONSTRAINT_NONE;
 
-	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
-		if (cpuset_zone_allowed_softwall(zone, gfp_mask))
-			node_clear(zone_to_nid(zone), nodes);
-		else
+	/*
+	 * In numa environ, almost all allocation will be against NORMAL zone.
+	 * But some small area, ex)GFP_DMA for ia64 or GFP_DMA32 for x86-64
+	 * can cause OOM. We can use policy_zone for checking lowmem.
+	 */
+	if (high_zoneidx < policy_zone)
+		return CONSTRAINT_LOWMEM;
+	/*
+	 * Now, only mempolicy specifies nodemask. But if nodemask
+	 * covers all nodes, this oom is global oom.
+	 */
+	if (nodemask && !nodes_equal(node_states[N_HIGH_MEMORY], *nodemask))
+		ret = CONSTRAINT_MEMORY_POLICY;
+	/*
+ 	 * If not __GFP_THISNODE, zonelist containes all nodes. And if
+ 	 * zonelist contains a zone which isn't allowed under cpuset, we assume
+ 	 * this allocation failure is caused by cpuset's constraint.
+ 	 * Note: all nodes are scanned if nodemask=NULL.
+ 	 */
+	for_each_zone_zonelist_nodemask(zone,
+			z, zonelist, high_zoneidx, nodemask) {
+		if (!cpuset_zone_allowed_softwall(zone, gfp_mask))
 			return CONSTRAINT_CPUSET;
+	}
+	return ret;
+}
 
-	if (!nodes_empty(nodes))
-		return CONSTRAINT_MEMORY_POLICY;
-#endif
-
+#elif defined(CONFIG_HIGHMEM)
+static inline enum oom_constraint
+guess_oom_context(struct zonelist *zonelist, gfp_t gfp_mask, nodemask_t *mask)
+{
+	if (gfp_mask & __GFP_HIGHMEM)
+		return CONSIRAINT_NONE;
+	return CONSTRAINT_LOWMEM;
+}
+#else
+static inline enum oom_constraint guess_oom_context(struct zonelist *zonelist,
+					    gfp_t gfp_mask, nodemask_t *mask)
+{
 	return CONSTRAINT_NONE;
 }
+#endif
 
 /*
  * Simple selection loop. We chose the process with the highest
@@ -225,7 +268,8 @@ static inline enum oom_constraint constr
  * (not docbooked, we don't want this one cluttering up the manual)
  */
 static struct task_struct *select_bad_process(unsigned long *ppoints,
-						struct mem_cgroup *mem)
+					      enum oom_constraint constraint,
+					      struct mem_cgroup *mem)
 {
 	struct task_struct *p;
 	struct task_struct *chosen = NULL;
@@ -281,7 +325,7 @@ static struct task_struct *select_bad_pr
 		if (p->signal->oom_adj == OOM_DISABLE)
 			continue;
 
-		points = badness(p, uptime.tv_sec);
+		points = __badness(p, uptime.tv_sec, constraint, mem);
 		if (points > *ppoints || !chosen) {
 			chosen = p;
 			*ppoints = points;
@@ -443,7 +487,7 @@ void mem_cgroup_out_of_memory(struct mem
 
 	read_lock(&tasklist_lock);
 retry:
-	p = select_bad_process(&points, mem);
+	p = select_bad_process(&points, CONSTRAINT_MEMCG, mem);
 	if (PTR_ERR(p) == -1UL)
 		goto out;
 
@@ -525,7 +569,8 @@ void clear_zonelist_oom(struct zonelist 
 /*
  * Must be called with tasklist_lock held for read.
  */
-static void __out_of_memory(gfp_t gfp_mask, int order)
+static void __out_of_memory(gfp_t gfp_mask, enum oom_constraint constraint,
+		int order, nodemask_t *mask)
 {
 	struct task_struct *p;
 	unsigned long points;
@@ -539,7 +584,7 @@ retry:
 	 * Rambo mode: Shoot down a process and hope it solves whatever
 	 * issues we may have.
 	 */
-	p = select_bad_process(&points, NULL);
+	p = select_bad_process(&points, constraint, NULL);
 
 	if (PTR_ERR(p) == -1UL)
 		return;
@@ -580,7 +625,12 @@ void pagefault_out_of_memory(void)
 		panic("out of memory from page fault. panic_on_oom is selected.\n");
 
 	read_lock(&tasklist_lock);
-	__out_of_memory(0, 0); /* unknown gfp_mask and order */
+	/*
+	 * Considering nature of pages required for page-fault,this must be
+	 * global OOM (if not cpuset...). Then, CONSTRAINT_NONE is correct.
+	 * zonelist, nodemasks are unknown...
+	 */
+	__out_of_memory(0, CONSTRAINT_NONE, 0, NULL);
 	read_unlock(&tasklist_lock);
 
 	/*
@@ -597,13 +647,15 @@ rest_and_return:
  * @zonelist: zonelist pointer
  * @gfp_mask: memory allocation flags
  * @order: amount of memory being requested as a power of 2
+ * @nodmask: nodemask which page allocater is called with.
  *
  * If we run out of memory, we have the choice between either
  * killing a random task (bad), letting the system crash (worse)
  * OR try to be smart about which process to kill. Note that we
  * don't have to be perfect here, we just have to be good.
  */
-void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
+void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
+			int order, nodemask_t *nodemask)
 {
 	unsigned long freed = 0;
 	enum oom_constraint constraint;
@@ -622,7 +674,7 @@ void out_of_memory(struct zonelist *zone
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
 	 */
-	constraint = constrained_alloc(zonelist, gfp_mask);
+	constraint = guess_oom_context(zonelist, gfp_mask, nodemask);
 	read_lock(&tasklist_lock);
 
 	switch (constraint) {
@@ -630,7 +682,7 @@ void out_of_memory(struct zonelist *zone
 		oom_kill_process(current, gfp_mask, order, 0, NULL,
 				"No available memory (MPOL_BIND)");
 		break;
-
+	case CONSTRAINT_LOWMEM:
 	case CONSTRAINT_NONE:
 		if (sysctl_panic_on_oom) {
 			dump_header(gfp_mask, order, NULL);
@@ -638,7 +690,10 @@ void out_of_memory(struct zonelist *zone
 		}
 		/* Fall-through */
 	case CONSTRAINT_CPUSET:
-		__out_of_memory(gfp_mask, order);
+		__out_of_memory(gfp_mask, constraint, order, nodemask);
+		break;
+	case CONSTRAINT_MEMCG: /* never happens. but for warning.*/
+		BUG();
 		break;
 	}
 
Index: mmotm-2.6.32-Nov2/fs/proc/base.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/fs/proc/base.c
+++ mmotm-2.6.32-Nov2/fs/proc/base.c
@@ -442,7 +442,7 @@ static const struct file_operations proc
 #endif
 
 /* The badness from the OOM killer */
-unsigned long badness(struct task_struct *p, unsigned long uptime);
+unsigned long global_badness(struct task_struct *p, unsigned long uptime);
 static int proc_oom_score(struct task_struct *task, char *buffer)
 {
 	unsigned long points;
@@ -450,7 +450,7 @@ static int proc_oom_score(struct task_st
 
 	do_posix_clock_monotonic_gettime(&uptime);
 	read_lock(&tasklist_lock);
-	points = badness(task->group_leader, uptime.tv_sec);
+	points = global_badness(task->group_leader, uptime.tv_sec);
 	read_unlock(&tasklist_lock);
 	return sprintf(buffer, "%lu\n", points);
 }
Index: mmotm-2.6.32-Nov2/mm/page_alloc.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/page_alloc.c
+++ mmotm-2.6.32-Nov2/mm/page_alloc.c
@@ -1669,7 +1669,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, un
 		goto out;
 
 	/* Exhausted what can be done so it's blamo time */
-	out_of_memory(zonelist, gfp_mask, order);
+	out_of_memory(zonelist, gfp_mask, order, nodemask);
 
 out:
 	clear_zonelist_oom(zonelist, gfp_mask);
Index: mmotm-2.6.32-Nov2/drivers/char/sysrq.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/drivers/char/sysrq.c
+++ mmotm-2.6.32-Nov2/drivers/char/sysrq.c
@@ -339,7 +339,7 @@ static struct sysrq_key_op sysrq_term_op
 
 static void moom_callback(struct work_struct *ignored)
 {
-	out_of_memory(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0);
+	out_of_memory(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0, NULL);
 }
 
 static DECLARE_WORK(moom_work, moom_callback);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
