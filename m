Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 091D06B0082
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 01:36:39 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0R6aaI3015465
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 27 Jan 2010 15:36:36 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 184BF45DE51
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 15:36:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DD24345DE52
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 15:36:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B7B74E38002
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 15:36:35 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id ECDF8E08002
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 15:36:34 +0900 (JST)
Date: Wed, 27 Jan 2010 15:33:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v4 2/2] oom-kill: add lowmem usage aware oom kill handling
 v4
Message-Id: <20100127153316.5cfb3913.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100127153053.b8a8a1a1.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
	<20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>
	<20100126151202.75bd9347.akpm@linux-foundation.org>
	<20100127085355.f5306e78.kamezawa.hiroyu@jp.fujitsu.com>
	<20100126161952.ee267d1c.akpm@linux-foundation.org>
	<20100127095812.d7493a8f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100127153053.b8a8a1a1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

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

(*) Lowmem is small zones in archs for special purpose.
   for example
   ZONE_DMA32 .. in x86-64 4G+ memmory
   ZONE_DMA   .. in ia64 4G+ memory 
   ZONE_NORMAL ..in x86-32 with highmemory.

Now, we have per-mm lowmem usage counter. We can make use of it
to select a good victim.

This patch does
 - add sysctl for new bahavior.
 - add CONSTRAINT_LOWMEM to oom's constraint type.
 - pass constraint to __badness()
 - change calculation based on constraint. If CONSTRAINT_LOWMEM,
   use low_rss instead of vmsize.

[excuse]
Why sysctl is added is because this feature breaks assumption
in oom_score/oom_adj, a knob from users. Even if oom_adj is enough
high, it the process is the only user of lowmem, it will be killed.
and oom_score can't show this special situaion. I think this patch is for
users who don't tweak oom_adj etc...making default behavior better.
(If sysctl is set)

[a side effect]
 Now, the kernel panics if oom killer can't find a process to be killed.
 So, if lowmem-oom occurs and there is no process which has no lowmem,
 the kerenl panics before killing tasks after this patch.
 Anyway, only we can do in such case is killing innocent processes
 at random and gamble on freed kernel memory by process kill will help
 oom situaion.....But oom-killer is not a gamble logic.
 So, panic is okay in such extreme situation, I think.

[test result]
A test case and output sample in /var/log/messages.
  (test on x86-64)
    1. do swap off. (for easy test)
    2. use up memory > 4G by some logic(I used hugepage.)
    3. run an memory-consume program with 800M memory.
    4. run an kernel module which alloc memory with GFP_DMA32
       repeatedly.

 (Before patch)
[  739.620583] cat invoked oom-killer: gfp_mask=0xd4, order=3, oom_adj=0
[  739.620588] cat cpuset=/ mems_allowed=0
[  739.620591] Pid: 12875, comm: cat Tainted: P           2.6.33-rc4-mm1 #10
<snip>
...
[  739.739887] 28184 pages shared
[  739.739890] 494948 pages non-shared
[  739.739895] Out of memory: kill process 2716 (gnome-session)
score 191570 or a child
[  739.739901] Killed process 2726 (gnome-power-man) vsz:319232kB
anon-rss:8156kB, file-rss:2764kB lowmem 0kB

A process of no lowmem usage  is killed. And some innocent ones
were killed in the sequence of oom-killer.

 (After patch)
At 1st oom killer,
[  579.384021] cat invoked oom-killer: gfp_mask=0xd4, order=3, oom_adj=0
[  579.384026] cat cpuset=/ mems_allowed=0 extension=1
[  579.384029] Pid: 11438, comm: cat Tainted: P           2.6.33-rc4-mm1
<snip>
[  579.384008] Out of memory (in lowmem): kill process 2919 (malloc)
	       score 4323 or a child
[  579.384012] Killed process 2919 (malloc) vsz:1442976kB, anon-
rss:312kB, file-rss:1439004kB lowmem 1383556kB

Then, lowmem memory eater (malloc) was killed. And no more oom-kill.

Changelog 2010/01/27
 - removed declaraiont of badness() from fs/proc/base.c and added a
   oom_badness() declaration in oom.h
 - plarecment of sysctl_oom_kill_extenstion_mask declaration was
   moved to oom.h
 - updated patch description.
 - fixed spell miss.
 - fixed bug of lacked "break" in switch().
 - added printk before panic.

Changelog 2010/01/25
 - showing extension value in OOM kill main log header.

Changelog 2010/01/22:
 - added sysctl
 - fixed !CONFIG_MMU
 - fixed fs/proc/base.c breakacge.

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/sysctl/vm.txt |   16 +++++++
 fs/proc/base.c              |    4 -
 include/linux/oom.h         |    7 +++
 kernel/sysctl.c             |    7 +++
 mm/oom_kill.c               |   97 ++++++++++++++++++++++++++++++++------------
 5 files changed, 104 insertions(+), 27 deletions(-)

Index: mmotm-2.6.33-Jan15-2/include/linux/oom.h
===================================================================
--- mmotm-2.6.33-Jan15-2.orig/include/linux/oom.h
+++ mmotm-2.6.33-Jan15-2/include/linux/oom.h
@@ -11,6 +11,7 @@
 
 #include <linux/types.h>
 #include <linux/nodemask.h>
+#include <linux/sched.h>
 
 struct zonelist;
 struct notifier_block;
@@ -20,6 +21,7 @@ struct notifier_block;
  */
 enum oom_constraint {
 	CONSTRAINT_NONE,
+	CONSTRAINT_LOWMEM,
 	CONSTRAINT_CPUSET,
 	CONSTRAINT_MEMORY_POLICY,
 };
@@ -47,6 +49,11 @@ static inline void oom_killer_enable(voi
 extern int sysctl_panic_on_oom;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_oom_dump_tasks;
+extern int sysctl_oom_kill_extension_mask;
+
+/* Called by fs/proc/base.c */
+unsigned long oom_badness(struct task_struct *p,
+		unsigned long uptime, int constraint);
 
 #endif /* __KERNEL__*/
 #endif /* _INCLUDE_LINUX_OOM_H */
Index: mmotm-2.6.33-Jan15-2/mm/oom_kill.c
===================================================================
--- mmotm-2.6.33-Jan15-2.orig/mm/oom_kill.c
+++ mmotm-2.6.33-Jan15-2/mm/oom_kill.c
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
@@ -52,9 +69,10 @@ static int has_intersects_mems_allowed(s
 }
 
 /**
- * badness - calculate a numeric value for how bad this task has been
+ * oom_badness - calculate a numeric value for how bad this task has been
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
+unsigned long oom_badness(struct task_struct *p, unsigned long uptime,
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
+		points = oom_badness(p, uptime.tv_sec, constraint);
 		if (points > *ppoints || !chosen) {
 			chosen = p;
 			*ppoints = points;
@@ -360,8 +396,9 @@ static void dump_header(struct task_stru
 							struct mem_cgroup *mem)
 {
 	pr_warning("%s invoked oom-killer: gfp_mask=0x%x, order=%d, "
-		"oom_adj=%d\n",
-		current->comm, gfp_mask, order, current->signal->oom_adj);
+		"oom_adj=%d extension=%x\n",
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
@@ -579,13 +616,23 @@ retry:
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p) {
 		read_unlock(&tasklist_lock);
+		if (constraint == CONSTRAINT_LOWMEM)
+			printk("Lowmem is exhausted and no process has lowmem\n");
 		dump_header(NULL, gfp_mask, order, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
 
-	if (oom_kill_process(p, gfp_mask, order, points, NULL,
+	switch (constraint) {
+	case CONSTRAINT_LOWMEM:
+		if (oom_kill_process(p, gfp_mask, order, points, NULL,
+			"Out of memory (in lowmem)"))
+			goto retry;
+		break;
+	default:
+		if (oom_kill_process(p, gfp_mask, order, points, NULL,
 			     "Out of memory"))
-		goto retry;
+			goto retry;
+	}
 }
 
 /*
@@ -612,7 +659,7 @@ void pagefault_out_of_memory(void)
 		panic("out of memory from page fault. panic_on_oom is selected.\n");
 
 	read_lock(&tasklist_lock);
-	__out_of_memory(0, 0); /* unknown gfp_mask and order */
+	__out_of_memory(0, 0, CONSTRAINT_NONE); /* unknown gfp_mask and order */
 	read_unlock(&tasklist_lock);
 
 	/*
@@ -663,7 +710,7 @@ void out_of_memory(struct zonelist *zone
 		oom_kill_process(current, gfp_mask, order, 0, NULL,
 				"No available memory (MPOL_BIND)");
 		break;
-
+	case CONSTRAINT_LOWMEM:
 	case CONSTRAINT_NONE:
 		if (sysctl_panic_on_oom) {
 			dump_header(NULL, gfp_mask, order, NULL);
@@ -671,7 +718,7 @@ void out_of_memory(struct zonelist *zone
 		}
 		/* Fall-through */
 	case CONSTRAINT_CPUSET:
-		__out_of_memory(gfp_mask, order);
+		__out_of_memory(gfp_mask, order, constraint);
 		break;
 	}
 
Index: mmotm-2.6.33-Jan15-2/kernel/sysctl.c
===================================================================
--- mmotm-2.6.33-Jan15-2.orig/kernel/sysctl.c
+++ mmotm-2.6.33-Jan15-2/kernel/sysctl.c
@@ -1270,6 +1270,13 @@ static struct ctl_table vm_table[] = {
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
Index: mmotm-2.6.33-Jan15-2/Documentation/sysctl/vm.txt
===================================================================
--- mmotm-2.6.33-Jan15-2.orig/Documentation/sysctl/vm.txt
+++ mmotm-2.6.33-Jan15-2/Documentation/sysctl/vm.txt
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
Index: mmotm-2.6.33-Jan15-2/fs/proc/base.c
===================================================================
--- mmotm-2.6.33-Jan15-2.orig/fs/proc/base.c
+++ mmotm-2.6.33-Jan15-2/fs/proc/base.c
@@ -458,7 +458,6 @@ static const struct file_operations proc
 #endif
 
 /* The badness from the OOM killer */
-unsigned long badness(struct task_struct *p, unsigned long uptime);
 static int proc_oom_score(struct task_struct *task, char *buffer)
 {
 	unsigned long points;
@@ -466,7 +465,8 @@ static int proc_oom_score(struct task_st
 
 	do_posix_clock_monotonic_gettime(&uptime);
 	read_lock(&tasklist_lock);
-	points = badness(task->group_leader, uptime.tv_sec);
+	points = oom_badness(task->group_leader,
+			uptime.tv_sec, CONSTRAINT_NONE);
 	read_unlock(&tasklist_lock);
 	return sprintf(buffer, "%lu\n", points);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
