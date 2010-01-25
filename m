Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BBD026B0071
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 01:18:41 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0P6IYRT018852
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 25 Jan 2010 15:18:34 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 41A3245DE5D
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 15:18:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FB0345DE4E
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 15:18:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 027421DB8038
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 15:18:34 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 999241DB803C
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 15:18:33 +0900 (JST)
Date: Mon, 25 Jan 2010 15:15:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
Message-Id: <20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
	<20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Did several tests on x86-32 and I felt that sysctl value should be
printed on oom log... this is v3.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Default oom-killer uses badness calculation based on process's vm_size
and some amounts of heuristics. Some users see proc->oom_score and
proc->oom_adj to control oom-killed tendency under their server.

Now, we know oom-killer don't work ideally in some situaion, in PCs. Some
enhancements are demanded. But such enhancements for oom-killer makes
incomaptibility to oom-controls in enterprise world. So, this patch
adds sysctl for extensions for oom-killer. Main purpose is for
making a chance for wider test for new scheme.

One cause of OOM-Killer is memory shortage in lower zones.
(If memory is enough, lowmem_reserve_ratio works well. but..)
I saw lowmem-oom frequently on x86-32 and sometimes on ia64 in
my cusotmer support jobs. If we just see process's vm_size at oom,
we can never kill a process which has lowmem.
At last, there will be an oom-serial-killer.

Now, we have per-mm lowmem usage counter. We can make use of it
to select a good victim.

This patch does
  - add sysctl for new bahavior.
  - add CONSTRAINT_LOWMEM to oom's constraint type.
  - pass constraint to __badness()
  - change calculation based on constraint. If CONSTRAINT_LOWMEM,
    use low_rss instead of vmsize.

Changelog 2010/01/25
 - showing extension_mask value in OOM kill main log header.
Changelog 2010/01/22:
 - added sysctl
 - fixed !CONFIG_MMU
 - fixed fs/proc/base.c breakacge.

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/sysctl/vm.txt |   16 +++++++
 fs/proc/base.c              |    5 +-
 include/linux/oom.h         |    1 
 kernel/sysctl.c             |   10 ++++
 mm/oom_kill.c               |   92 ++++++++++++++++++++++++++++++++------------
 5 files changed, 97 insertions(+), 27 deletions(-)

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
@@ -34,6 +34,23 @@ int sysctl_oom_dump_tasks;
 static DEFINE_SPINLOCK(zone_scan_lock);
 /* #define DEBUG */
 
+int sysctl_oom_kill_extension_mask;
+enum {
+	EXT_LOWMEM_OOM,
+};
+
+#ifdef CONFIG_MMU
+static int oom_extension(int idx)
+{
+	return sysctl_oom_kill_extension_mask & (1 << idx);
+}
+#else
+static int oom_extension(int idx)
+{
+	return 0;
+}
+#endif
+
 /*
  * Is all threads of the target process nodes overlap ours?
  */
@@ -55,6 +72,7 @@ static int has_intersects_mems_allowed(s
  * badness - calculate a numeric value for how bad this task has been
  * @p: task struct of which task we should calculate
  * @uptime: current uptime in seconds
+ * @constraint: context of badness calculation.
  *
  * The formula used is relatively simple and documented inline in the
  * function. The main rationale is that we want to select a good task
@@ -70,7 +88,8 @@ static int has_intersects_mems_allowed(s
  *    of least surprise ... (be careful when you change it)
  */
 
-unsigned long badness(struct task_struct *p, unsigned long uptime)
+unsigned long badness(struct task_struct *p, unsigned long uptime,
+			int constraint)
 {
 	unsigned long points, cpu_time, run_time;
 	struct mm_struct *mm;
@@ -89,11 +108,16 @@ unsigned long badness(struct task_struct
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
@@ -113,12 +137,17 @@ unsigned long badness(struct task_struct
 	 * machine with an endless amount of children. In case a single
 	 * child is eating the vast majority of memory, adding only half
 	 * to the parents will make the child our kill candidate of choice.
+	 *
+	 * At lowmem shortage, this part is skipped because children's lowmem
+	 * usage is not related to its parent.
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
@@ -212,6 +241,9 @@ static enum oom_constraint constrained_a
 	if (gfp_mask & __GFP_THISNODE)
 		return CONSTRAINT_NONE;
 
+	if (oom_extension(EXT_LOWMEM_OOM) && (high_zoneidx <= lowmem_zone))
+		return CONSTRAINT_LOWMEM;
+
 	/*
 	 * The nodemask here is a nodemask passed to alloc_pages(). Now,
 	 * cpuset doesn't use this nodemask for its hardwall/softwall/hierarchy
@@ -233,6 +265,10 @@ static enum oom_constraint constrained_a
 static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
 				gfp_t gfp_mask, nodemask_t *nodemask)
 {
+	int zone_idx = gfp_zone(gfp_mask);
+
+	if (oom_extension(EXT_LOWMEM_OOM) && (zone_idx <= lowmem_zone))
+		return CONSTRAINT_LOWMEM;
 	return CONSTRAINT_NONE;
 }
 #endif
@@ -244,7 +280,7 @@ static enum oom_constraint constrained_a
  * (not docbooked, we don't want this one cluttering up the manual)
  */
 static struct task_struct *select_bad_process(unsigned long *ppoints,
-						struct mem_cgroup *mem)
+				struct mem_cgroup *mem, int constraint)
 {
 	struct task_struct *p;
 	struct task_struct *chosen = NULL;
@@ -300,7 +336,7 @@ static struct task_struct *select_bad_pr
 		if (p->signal->oom_adj == OOM_DISABLE)
 			continue;
 
-		points = badness(p, uptime.tv_sec);
+		points = badness(p, uptime.tv_sec, constraint);
 		if (points > *ppoints || !chosen) {
 			chosen = p;
 			*ppoints = points;
@@ -360,8 +396,9 @@ static void dump_header(struct task_stru
 							struct mem_cgroup *mem)
 {
 	pr_warning("%s invoked oom-killer: gfp_mask=0x%x, order=%d, "
-		"oom_adj=%d\n",
-		current->comm, gfp_mask, order, current->signal->oom_adj);
+		"oom_adj=%d extesion=%x\n",
+		current->comm, gfp_mask, order,
+		current->signal->oom_adj, sysctl_oom_kill_extension_mask);
 	task_lock(current);
 	cpuset_print_task_mems_allowed(current);
 	task_unlock(current);
@@ -455,7 +492,7 @@ static int oom_kill_process(struct task_
 	}
 
 	printk(KERN_ERR "%s: kill process %d (%s) score %li or a child\n",
-					message, task_pid_nr(p), p->comm, points);
+				message, task_pid_nr(p), p->comm, points);
 
 	/* Try to kill a child first */
 	list_for_each_entry(c, &p->children, sibling) {
@@ -475,7 +512,7 @@ void mem_cgroup_out_of_memory(struct mem
 
 	read_lock(&tasklist_lock);
 retry:
-	p = select_bad_process(&points, mem);
+	p = select_bad_process(&points, mem, CONSTRAINT_NONE);
 	if (PTR_ERR(p) == -1UL)
 		goto out;
 
@@ -557,7 +594,7 @@ void clear_zonelist_oom(struct zonelist 
 /*
  * Must be called with tasklist_lock held for read.
  */
-static void __out_of_memory(gfp_t gfp_mask, int order)
+static void __out_of_memory(gfp_t gfp_mask, int order, int constraint)
 {
 	struct task_struct *p;
 	unsigned long points;
@@ -571,7 +608,7 @@ retry:
 	 * Rambo mode: Shoot down a process and hope it solves whatever
 	 * issues we may have.
 	 */
-	p = select_bad_process(&points, NULL);
+	p = select_bad_process(&points, NULL, constraint);
 
 	if (PTR_ERR(p) == -1UL)
 		return;
@@ -583,9 +620,16 @@ retry:
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
@@ -612,7 +656,7 @@ void pagefault_out_of_memory(void)
 		panic("out of memory from page fault. panic_on_oom is selected.\n");
 
 	read_lock(&tasklist_lock);
-	__out_of_memory(0, 0); /* unknown gfp_mask and order */
+	__out_of_memory(0, 0, CONSTRAINT_NONE); /* unknown gfp_mask and order */
 	read_unlock(&tasklist_lock);
 
 	/*
@@ -663,7 +707,7 @@ void out_of_memory(struct zonelist *zone
 		oom_kill_process(current, gfp_mask, order, 0, NULL,
 				"No available memory (MPOL_BIND)");
 		break;
-
+	case CONSTRAINT_LOWMEM:
 	case CONSTRAINT_NONE:
 		if (sysctl_panic_on_oom) {
 			dump_header(NULL, gfp_mask, order, NULL);
@@ -671,7 +715,7 @@ void out_of_memory(struct zonelist *zone
 		}
 		/* Fall-through */
 	case CONSTRAINT_CPUSET:
-		__out_of_memory(gfp_mask, order);
+		__out_of_memory(gfp_mask, order, constraint);
 		break;
 	}
 
Index: mmotm-2.6.33-Jan15/kernel/sysctl.c
===================================================================
--- mmotm-2.6.33-Jan15.orig/kernel/sysctl.c
+++ mmotm-2.6.33-Jan15/kernel/sysctl.c
@@ -22,7 +22,6 @@
 #include <linux/mm.h>
 #include <linux/swap.h>
 #include <linux/slab.h>
-#include <linux/sysctl.h>
 #include <linux/proc_fs.h>
 #include <linux/security.h>
 #include <linux/ctype.h>
@@ -72,6 +71,7 @@ extern int sysctl_overcommit_ratio;
 extern int sysctl_panic_on_oom;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_oom_dump_tasks;
+extern int sysctl_oom_kill_extension_mask;
 extern int max_threads;
 extern int core_uses_pid;
 extern int suid_dumpable;
@@ -202,6 +202,7 @@ extern struct ctl_table epoll_table[];
 int sysctl_legacy_va_layout;
 #endif
 
+
 extern int prove_locking;
 extern int lock_stat;
 
@@ -1282,6 +1283,13 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 #endif
+	{
+		.procname	= "oom_kill_extension_mask",
+		.data		= &sysctl_oom_kill_extension_mask,
+		.maxlen		= sizeof(sysctl_oom_kill_extension_mask),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 
 /*
  * NOTE: do not add new entries to this table unless you have read
Index: mmotm-2.6.33-Jan15/Documentation/sysctl/vm.txt
===================================================================
--- mmotm-2.6.33-Jan15.orig/Documentation/sysctl/vm.txt
+++ mmotm-2.6.33-Jan15/Documentation/sysctl/vm.txt
@@ -45,6 +45,7 @@ Currently, these files are in /proc/sys/
 - numa_zonelist_order
 - oom_dump_tasks
 - oom_kill_allocating_task
+- oom_kill_extension_mask
 - overcommit_memory
 - overcommit_ratio
 - page-cluster
@@ -511,6 +512,21 @@ The default value is 0.
 
 ==============================================================
 
+oom_kill_extension_mask:
+
+This is a mask for oom-killer extension features.
+Setting these flags may cause incompatibility for proc->oom_score and
+proc->oom_adj controls. So, please set carefully.
+
+bit 0....lowmem aware oom-killing.
+    If set, at lowmem shortage oom killing (for example, exhausting NORMAL_ZONE
+    under x86-32 HIGHMEM host), oom-killer will see lowmem rss usage of
+    processes instead of vmsize. Works only when CONFIG_MMU=y.
+
+The default value is 0
+
+==============================================================
+
 overcommit_memory:
 
 This value contains a flag that enables memory overcommitment.
Index: mmotm-2.6.33-Jan15/fs/proc/base.c
===================================================================
--- mmotm-2.6.33-Jan15.orig/fs/proc/base.c
+++ mmotm-2.6.33-Jan15/fs/proc/base.c
@@ -458,7 +458,8 @@ static const struct file_operations proc
 #endif
 
 /* The badness from the OOM killer */
-unsigned long badness(struct task_struct *p, unsigned long uptime);
+unsigned long badness(struct task_struct *p,
+	unsigned long uptime, int constraint);
 static int proc_oom_score(struct task_struct *task, char *buffer)
 {
 	unsigned long points;
@@ -466,7 +467,7 @@ static int proc_oom_score(struct task_st
 
 	do_posix_clock_monotonic_gettime(&uptime);
 	read_lock(&tasklist_lock);
-	points = badness(task->group_leader, uptime.tv_sec);
+	points = badness(task->group_leader, uptime.tv_sec, CONSTRAINT_NONE);
 	read_unlock(&tasklist_lock);
 	return sprintf(buffer, "%lu\n", points);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
