Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A5A0F6B006A
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 01:02:24 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0L62O6N002508
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 21 Jan 2010 15:02:24 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B266E45DE51
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 15:02:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BE2845DE4F
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 15:02:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 60FCC1DB8037
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 15:02:23 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CE051DB8038
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 15:02:23 +0900 (JST)
Date: Thu, 21 Jan 2010 14:59:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] oom-kill: add lowmem usage aware oom kill handling
Message-Id: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

A patch for avoiding oom-serial-killer at lowmem shortage.
Patch is onto mmotm-2010/01/15 (depends on mm-count-lowmem-rss.patch)
Tested on x86-64/SMP + debug module(to allocated lowmem), works well.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

One cause of OOM-Killer is memory shortage in lower zones.
(If memory is enough, lowmem_reserve_ratio works well. but..)

In lowmem-shortage oom-kill, oom-killer choses a vicitim process
on their vm size. But this kills a process which has lowmem memory
only if it's lucky. At last, there will be an oom-serial-killer.

Now, we have per-mm lowmem usage counter. We can make use of it
to select a good? victim.

This patch does
  - add CONSTRAINT_LOWMEM to oom's constraint type.
  - pass constraint to __badness()
  - change calculation based on constraint. If CONSTRAINT_LOWMEM,
    use low_rss instead of vmsize.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/oom.h |    1 
 mm/oom_kill.c       |   69 +++++++++++++++++++++++++++++++++++-----------------
 2 files changed, 48 insertions(+), 22 deletions(-)

Index: mmotm-2.6.33-Jan15/include/linux/oom.h
===================================================================
--- mmotm-2.6.33-Jan15.orig/include/linux/oom.h
+++ mmotm-2.6.33-Jan15/include/linux/oom.h
@@ -20,6 +20,7 @@ struct notifier_block;
  */
 enum oom_constraint {
 	CONSTRAINT_NONE,
+	CONSTRAINT_LOWMEM,
 	CONSTRAINT_CPUSET,
 	CONSTRAINT_MEMORY_POLICY,
 };
Index: mmotm-2.6.33-Jan15/mm/oom_kill.c
===================================================================
--- mmotm-2.6.33-Jan15.orig/mm/oom_kill.c
+++ mmotm-2.6.33-Jan15/mm/oom_kill.c
@@ -55,6 +55,7 @@ static int has_intersects_mems_allowed(s
  * badness - calculate a numeric value for how bad this task has been
  * @p: task struct of which task we should calculate
  * @uptime: current uptime in seconds
+ * @constraint: context of badness calculation.
  *
  * The formula used is relatively simple and documented inline in the
  * function. The main rationale is that we want to select a good task
@@ -70,7 +71,8 @@ static int has_intersects_mems_allowed(s
  *    of least surprise ... (be careful when you change it)
  */
 
-unsigned long badness(struct task_struct *p, unsigned long uptime)
+unsigned long badness(struct task_struct *p, unsigned long uptime,
+			int constraint)
 {
 	unsigned long points, cpu_time, run_time;
 	struct mm_struct *mm;
@@ -89,11 +91,16 @@ unsigned long badness(struct task_struct
 		task_unlock(p);
 		return 0;
 	}
-
-	/*
-	 * The memory size of the process is the basis for the badness.
-	 */
-	points = mm->total_vm;
+	switch  (constraint) {
+	case CONSTRAINT_LOWMEM:
+		/* use lowmem usage as the basis for the badness */
+		points = get_low_rss(mm);
+		break;
+	default:
+		/* use virtual memory size as the basis for the badness */
+		points = mm->total_vm;
+		break;
+	}
 
 	/*
 	 * After this unlock we can no longer dereference local variable `mm'
@@ -113,12 +120,16 @@ unsigned long badness(struct task_struct
 	 * machine with an endless amount of children. In case a single
 	 * child is eating the vast majority of memory, adding only half
 	 * to the parents will make the child our kill candidate of choice.
+	 *
+	 * At lowmem shortage, ignore this part.
 	 */
-	list_for_each_entry(child, &p->children, sibling) {
-		task_lock(child);
-		if (child->mm != mm && child->mm)
-			points += child->mm->total_vm/2 + 1;
-		task_unlock(child);
+	if (constraint != CONSTRAINT_LOWMEM) {
+		list_for_each_entry(child, &p->children, sibling) {
+			task_lock(child);
+			if (child->mm != mm && child->mm)
+				points += child->mm->total_vm/2 + 1;
+			task_unlock(child);
+		}
 	}
 
 	/*
@@ -212,6 +223,9 @@ static enum oom_constraint constrained_a
 	if (gfp_mask & __GFP_THISNODE)
 		return CONSTRAINT_NONE;
 
+	if (high_zoneidx <= lowmem_zone)
+		return CONSTRAINT_LOWMEM;
+
 	/*
 	 * The nodemask here is a nodemask passed to alloc_pages(). Now,
 	 * cpuset doesn't use this nodemask for its hardwall/softwall/hierarchy
@@ -233,6 +247,10 @@ static enum oom_constraint constrained_a
 static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
 				gfp_t gfp_mask, nodemask_t *nodemask)
 {
+	int zone_idx = gfp_zone(gfp_mask);
+
+	if (zone_idx <= lowmem_zone)
+		return CONSTRAINT_LOWMEM;
 	return CONSTRAINT_NONE;
 }
 #endif
@@ -244,7 +262,7 @@ static enum oom_constraint constrained_a
  * (not docbooked, we don't want this one cluttering up the manual)
  */
 static struct task_struct *select_bad_process(unsigned long *ppoints,
-						struct mem_cgroup *mem)
+				struct mem_cgroup *mem, int constraint)
 {
 	struct task_struct *p;
 	struct task_struct *chosen = NULL;
@@ -300,7 +318,7 @@ static struct task_struct *select_bad_pr
 		if (p->signal->oom_adj == OOM_DISABLE)
 			continue;
 
-		points = badness(p, uptime.tv_sec);
+		points = badness(p, uptime.tv_sec, constraint);
 		if (points > *ppoints || !chosen) {
 			chosen = p;
 			*ppoints = points;
@@ -455,7 +473,7 @@ static int oom_kill_process(struct task_
 	}
 
 	printk(KERN_ERR "%s: kill process %d (%s) score %li or a child\n",
-					message, task_pid_nr(p), p->comm, points);
+				message, task_pid_nr(p), p->comm, points);
 
 	/* Try to kill a child first */
 	list_for_each_entry(c, &p->children, sibling) {
@@ -475,7 +493,7 @@ void mem_cgroup_out_of_memory(struct mem
 
 	read_lock(&tasklist_lock);
 retry:
-	p = select_bad_process(&points, mem);
+	p = select_bad_process(&points, mem, CONSTRAINT_NONE);
 	if (PTR_ERR(p) == -1UL)
 		goto out;
 
@@ -557,7 +575,7 @@ void clear_zonelist_oom(struct zonelist 
 /*
  * Must be called with tasklist_lock held for read.
  */
-static void __out_of_memory(gfp_t gfp_mask, int order)
+static void __out_of_memory(gfp_t gfp_mask, int order, int constraint)
 {
 	struct task_struct *p;
 	unsigned long points;
@@ -571,7 +589,7 @@ retry:
 	 * Rambo mode: Shoot down a process and hope it solves whatever
 	 * issues we may have.
 	 */
-	p = select_bad_process(&points, NULL);
+	p = select_bad_process(&points, NULL, constraint);
 
 	if (PTR_ERR(p) == -1UL)
 		return;
@@ -583,9 +601,16 @@ retry:
 		panic("Out of memory and no killable processes...\n");
 	}
 
-	if (oom_kill_process(p, gfp_mask, order, points, NULL,
+	switch (constraint) {
+	case CONSTRAINT_LOWMEM:
+		if (oom_kill_process(p, gfp_mask, order, points, NULL,
+			"Out of memory (in lowmem)"))
+			goto retry;
+	default:
+		if (oom_kill_process(p, gfp_mask, order, points, NULL,
 			     "Out of memory"))
-		goto retry;
+			goto retry;
+	}
 }
 
 /*
@@ -612,7 +637,7 @@ void pagefault_out_of_memory(void)
 		panic("out of memory from page fault. panic_on_oom is selected.\n");
 
 	read_lock(&tasklist_lock);
-	__out_of_memory(0, 0); /* unknown gfp_mask and order */
+	__out_of_memory(0, 0, CONSTRAINT_NONE); /* unknown gfp_mask and order */
 	read_unlock(&tasklist_lock);
 
 	/*
@@ -663,7 +688,7 @@ void out_of_memory(struct zonelist *zone
 		oom_kill_process(current, gfp_mask, order, 0, NULL,
 				"No available memory (MPOL_BIND)");
 		break;
-
+	case CONSTRAINT_LOWMEM:
 	case CONSTRAINT_NONE:
 		if (sysctl_panic_on_oom) {
 			dump_header(NULL, gfp_mask, order, NULL);
@@ -671,7 +696,7 @@ void out_of_memory(struct zonelist *zone
 		}
 		/* Fall-through */
 	case CONSTRAINT_CPUSET:
-		__out_of_memory(gfp_mask, order);
+		__out_of_memory(gfp_mask, order, constraint);
 		break;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
