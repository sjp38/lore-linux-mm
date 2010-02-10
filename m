Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 243D96B0082
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 11:33:04 -0500 (EST)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o1AGWISc011337
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 08:32:18 -0800
Received: from qyk14 (qyk14.prod.google.com [10.241.83.142])
	by kpbe14.cbf.corp.google.com with ESMTP id o1AGW1CL025867
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 08:32:17 -0800
Received: by qyk14 with SMTP id 14so153743qyk.9
        for <linux-mm@kvack.org>; Wed, 10 Feb 2010 08:32:16 -0800 (PST)
Date: Wed, 10 Feb 2010 08:32:14 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 4/7 -mm] oom: badness heuristic rewrite
In-Reply-To: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1002100228540.8001@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This a complete rewrite of the oom killer's badness() heuristic which is
used to determine which task to kill in oom conditions.  The goal is to
make it as simple and predictable as possible so the results are better
understood and we end up killing the task which will lead to the most
memory freeing while still respecting the fine-tuning from userspace.

The baseline for the heuristic is a proportion of memory that each task
is currently using in memory plus swap compared to the amount of
"allowable" memory.  "Allowable," in this sense, means the system-wide
resources for unconstrained oom conditions, the set of mempolicy nodes,
the mems attached to current's cpuset, or a memory controller's limit.
The proportion is given on a scale of 0 (never kill) to 1000 (always
kill), roughly meaning that if a task has a badness() score of 500 that
the task consumes approximately 50% of allowable memory resident in RAM
or in swap space.

The proportion is always relative to the amount of "allowable" memory and
not the total amount of RAM systemwide so that mempolicies and cpusets
may operate in isolation; they shall not need to know the true size of
the machine on which they are running if they are bound to a specific set
of nodes or mems, respectively.

Forkbomb detection is done in a completely different way: a threshold is
configurable from userspace to determine how many first-generation execve
children (those with their own address spaces) a task may have before it
is considered a forkbomb.  This can be tuned by altering the value in
/proc/sys/vm/oom_forkbomb_thres, which defaults to 1000.

When a task has more than 1000 first-generation children with different
address spaces than itself, a penalty of

	(average rss of children) * (# of 1st generation execve children)
	-----------------------------------------------------------------
			oom_forkbomb_thres

is assessed.  So, for example, using the default oom_forkbomb_thres of
1000, the penalty is twice the average rss of all its execve children if
there are 2000 such tasks.  A task is considered to count toward the
threshold if its total runtime is less than one second; for 1000 of such
tasks to exist, the parent process must be forking at an extremely high
rate either erroneously or maliciously.

Even though a particular task may be designated a forkbomb and selected
as the victim, the oom killer will still kill the 1st generation execve
child with the highest badness() score in its place.  The avoids killing
important servers or system daemons.

Root tasks are given 3% extra memory just like __vm_enough_memory()
provides in LSMs.  In the event of two tasks consuming similar amounts of
memory, it is generally better to save root's task.

Because of the change in the badness() heuristic's baseline, a change
must also be made to the user interface used to tune it.  Instead of a
scale from -16 to +15 to indicate a bitshift on the point value given to
a task, which was very difficult to tune accurately or with any degree of
precision, /proc/pid/oom_adj now ranges from -1000 to +1000.  That is, it
can be used to polarize the heuristic such that certain tasks are never
considered for oom kill while others are always considered.  The value is
added directly into the badness() score so a value of -500, for example,
means to discount 50% of its memory consumption in comparison to other
tasks either on the system, bound to the mempolicy, or in the cpuset.

OOM_ADJUST_MIN and OOM_ADJUST_MAX have been exported to userspace since
2006 via include/linux/oom.h.  This alters their values from -16 to -1000
and from +15 to +1000, respectively.  OOM_DISABLE is now the equivalent
of the lowest possible value, OOM_ADJUST_MIN.  Adding its value, -1000,
to any badness score will always return 0.

Although redefining these values may be controversial, it is much easier
to understand when the units are fully understood as described above.
In the short-term, there may be userspace breakage for tasks that
hardcode -17 meaning OOM_DISABLE, for example, but the long-term will
make the semantics much easier to understand and oom killing much more
effective.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/filesystems/proc.txt |   78 ++++++----
 Documentation/sysctl/vm.txt        |   21 +++
 fs/proc/base.c                     |   13 +-
 include/linux/oom.h                |   15 ++-
 kernel/sysctl.c                    |    8 +
 mm/oom_kill.c                      |  298 +++++++++++++++++++----------------
 6 files changed, 256 insertions(+), 177 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -1195,39 +1195,51 @@ CHAPTER 3: PER-PROCESS PARAMETERS
 3.1 /proc/<pid>/oom_adj - Adjust the oom-killer score
 ------------------------------------------------------
 
-This file can be used to adjust the score used to select which processes
-should be killed in an  out-of-memory  situation.  Giving it a high score will
-increase the likelihood of this process being killed by the oom-killer.  Valid
-values are in the range -16 to +15, plus the special value -17, which disables
-oom-killing altogether for this process.
-
-The process to be killed in an out-of-memory situation is selected among all others
-based on its badness score. This value equals the original memory size of the process
-and is then updated according to its CPU time (utime + stime) and the
-run time (uptime - start time). The longer it runs the smaller is the score.
-Badness score is divided by the square root of the CPU time and then by
-the double square root of the run time.
-
-Swapped out tasks are killed first. Half of each child's memory size is added to
-the parent's score if they do not share the same memory. Thus forking servers
-are the prime candidates to be killed. Having only one 'hungry' child will make
-parent less preferable than the child.
-
-/proc/<pid>/oom_score shows process' current badness score.
-
-The following heuristics are then applied:
- * if the task was reniced, its score doubles
- * superuser or direct hardware access tasks (CAP_SYS_ADMIN, CAP_SYS_RESOURCE
- 	or CAP_SYS_RAWIO) have their score divided by 4
- * if oom condition happened in one cpuset and checked process does not belong
- 	to it, its score is divided by 8
- * the resulting score is multiplied by two to the power of oom_adj, i.e.
-	points <<= oom_adj when it is positive and
-	points >>= -(oom_adj) otherwise
-
-The task with the highest badness score is then selected and its children
-are killed, process itself will be killed in an OOM situation when it does
-not have children or some of them disabled oom like described above.
+This file can be used to adjust the badness heuristic used to select which
+process gets killed in out of memory conditions.
+
+The badness heuristic assigns a value to each candidate task ranging from 0
+(never kill) to 1000 (always kill) to determine which process is targeted.  The
+units are roughly a proportion along that range of allowed memory the process
+may allocate from based on an estimation of its current memory and swap use.
+For example, if a task is using all allowed memory, its badness score will be
+1000.  If it is using half of its allowed memory, its score will be 500.
+
+There are a couple of additional factors included in the badness score: root
+processes are given 3% extra memory over other tasks, and tasks which forkbomb
+an excessive number of child processes are penalized by their average size.
+The number of child processes considered to be a forkbomb is configurable
+via /proc/sys/vm/oom_forkbomb_thres (see Documentation/sysctl/vm.txt).
+
+The amount of "allowed" memory depends on the context in which the oom killer
+was called.  If it is due to the memory assigned to the allocating task's cpuset
+being exhausted, the allowed memory represents the set of mems assigned to that
+cpuset.  If it is due to a mempolicy's node(s) being exhausted, the allowed
+memory represents the set of mempolicy nodes.  If it is due to a memory
+limit (or swap limit) being reached, the allowed memory is that configured
+limit.  Finally, if it is due to the entire system being out of memory, the
+allowed memory represents all allocatable resources.
+
+The value of /proc/<pid>/oom_adj is added to the badness score before it is used
+to determine which task to kill.  Acceptable values range from -1000
+(OOM_MIN_ADJUST) to +1000 (OOM_MAX_ADJUST).  This allows userspace to polarize
+the preference for oom killing either by always preferring a certain task or
+completely disabling it.  OOM_DISABLE is equivalent to the lowest possible
+value, -1000, since such tasks will always report a badness score of 0.
+
+Consequently, it is very simple for userspace to define the amount of memory to
+consider for each task.  Setting a /proc/<pid>/oom_adj value of +500, for
+example, is roughly equivalent to allowing the remainder of tasks sharing the
+same system, cpuset, mempolicy, or memory controller resources to use at least
+50% more memory.  A value of -500, on the other hand, would be roughly
+equivalent to discounting 50% of the task's allowed memory from being considered
+as scoring against the task.
+
+Caveat: when a parent task is selected, the oom killer will sacrifice any first
+generation children with seperate address spaces instead, if possible.  This
+avoids servers and important system daemons from being killed and loses the
+minimal amount of work.
+
 
 3.2 /proc/<pid>/oom_score - Display current oom-killer score
 -------------------------------------------------------------
diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -44,6 +44,7 @@ Currently, these files are in /proc/sys/vm:
 - nr_trim_pages         (only if CONFIG_MMU=n)
 - numa_zonelist_order
 - oom_dump_tasks
+- oom_forkbomb_thres
 - oom_kill_allocating_task
 - overcommit_memory
 - overcommit_ratio
@@ -490,6 +491,26 @@ The default value is 0.
 
 ==============================================================
 
+oom_forkbomb_thres
+
+This value defines how many children with a seperate address space a specific
+task may have before being considered as a possible forkbomb.  Tasks with more
+children not sharing the same address space as the parent will be penalized by a
+quantity of memory equaling
+
+	(average rss of execve children) * (# of 1st generation execve children)
+	------------------------------------------------------------------------
+				oom_forkbomb_thres
+
+in the oom killer's badness heuristic.  Such tasks may be protected with a lower
+oom_adj value (see Documentation/filesystems/proc.txt) if necessary.
+
+A value of 0 will disable forkbomb detection.
+
+The default value is 1000.
+
+==============================================================
+
 oom_kill_allocating_task
 
 This enables or disables killing the OOM-triggering task in
diff --git a/fs/proc/base.c b/fs/proc/base.c
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -81,6 +81,7 @@
 #include <linux/elf.h>
 #include <linux/pid_namespace.h>
 #include <linux/fs_struct.h>
+#include <linux/swap.h>
 #include "internal.h"
 
 /* NOTE:
@@ -458,7 +459,6 @@ static const struct file_operations proc_lstats_operations = {
 #endif
 
 /* The badness from the OOM killer */
-unsigned long badness(struct task_struct *p, unsigned long uptime);
 static int proc_oom_score(struct task_struct *task, char *buffer)
 {
 	unsigned long points;
@@ -466,7 +466,13 @@ static int proc_oom_score(struct task_struct *task, char *buffer)
 
 	do_posix_clock_monotonic_gettime(&uptime);
 	read_lock(&tasklist_lock);
-	points = badness(task->group_leader, uptime.tv_sec);
+	points = oom_badness(task->group_leader,
+				global_page_state(NR_INACTIVE_ANON) +
+				global_page_state(NR_ACTIVE_ANON) +
+				global_page_state(NR_INACTIVE_FILE) +
+				global_page_state(NR_ACTIVE_FILE) +
+				total_swap_pages,
+				uptime.tv_sec);
 	read_unlock(&tasklist_lock);
 	return sprintf(buffer, "%lu\n", points);
 }
@@ -1137,8 +1143,7 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
 	err = strict_strtol(strstrip(buffer), 0, &oom_adjust);
 	if (err)
 		return -EINVAL;
-	if ((oom_adjust < OOM_ADJUST_MIN || oom_adjust > OOM_ADJUST_MAX) &&
-	     oom_adjust != OOM_DISABLE)
+	if (oom_adjust < OOM_ADJUST_MIN || oom_adjust > OOM_ADJUST_MAX)
 		return -EINVAL;
 
 	task = get_proc_task(file->f_path.dentry->d_inode);
diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -1,14 +1,18 @@
 #ifndef __INCLUDE_LINUX_OOM_H
 #define __INCLUDE_LINUX_OOM_H
 
-/* /proc/<pid>/oom_adj set to -17 protects from the oom-killer */
-#define OOM_DISABLE (-17)
+/* /proc/<pid>/oom_adj set to -1000 disables OOM killing for pid */
+#define OOM_DISABLE			(-1000)
 /* inclusive */
-#define OOM_ADJUST_MIN (-16)
-#define OOM_ADJUST_MAX 15
+#define OOM_ADJUST_MIN			OOM_DISABLE
+#define OOM_ADJUST_MAX			1000
+
+/* See Documentation/sysctl/vm.txt */
+#define DEFAULT_OOM_FORKBOMB_THRES	1000
 
 #ifdef __KERNEL__
 
+#include <linux/sched.h>
 #include <linux/types.h>
 #include <linux/nodemask.h>
 
@@ -24,6 +28,8 @@ enum oom_constraint {
 	CONSTRAINT_MEMORY_POLICY,
 };
 
+extern unsigned int oom_badness(struct task_struct *p,
+			unsigned long totalpages, unsigned long uptime);
 extern int try_set_zone_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 
@@ -47,6 +53,7 @@ static inline void oom_killer_enable(void)
 extern int sysctl_panic_on_oom;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_oom_dump_tasks;
+extern int sysctl_oom_forkbomb_thres;
 
 #endif /* __KERNEL__*/
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -963,6 +963,14 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "oom_forkbomb_thres",
+		.data		= &sysctl_oom_forkbomb_thres,
+		.maxlen		= sizeof(sysctl_oom_forkbomb_thres),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+	},
+	{
 		.procname	= "overcommit_ratio",
 		.data		= &sysctl_overcommit_ratio,
 		.maxlen		= sizeof(sysctl_overcommit_ratio),
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -4,6 +4,8 @@
  *  Copyright (C)  1998,2000  Rik van Riel
  *	Thanks go out to Claus Fischer for some serious inspiration and
  *	for goading me into coding this file...
+ *  Copyright (C)  2010  Google, Inc
+ *	Rewritten by David Rientjes
  *
  *  The routines in this file are used to kill a process when
  *  we're seriously out of memory. This gets called from __alloc_pages()
@@ -32,8 +34,8 @@
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks;
+int sysctl_oom_forkbomb_thres = DEFAULT_OOM_FORKBOMB_THRES;
 static DEFINE_SPINLOCK(zone_scan_lock);
-/* #define DEBUG */
 
 /*
  * Do all threads of the target process overlap our allowed nodes?
@@ -68,138 +70,125 @@ static bool has_intersects_mems_allowed(struct task_struct *tsk,
 	return false;
 }
 
-/**
- * badness - calculate a numeric value for how bad this task has been
- * @p: task struct of which task we should calculate
- * @uptime: current uptime in seconds
+/*
+ * Tasks that fork a very large number of children with seperate address spaces
+ * may be the result of a bug, user error, or a malicious application.  The oom
+ * killer assesses a penalty equaling
  *
- * The formula used is relatively simple and documented inline in the
- * function. The main rationale is that we want to select a good task
- * to kill when we run out of memory.
+ *	(average rss of children) * (# of 1st generation execve children)
+ *	-----------------------------------------------------------------
+ *			sysctl_oom_forkbomb_thres
  *
- * Good in this context means that:
- * 1) we lose the minimum amount of work done
- * 2) we recover a large amount of memory
- * 3) we don't kill anything innocent of eating tons of memory
- * 4) we want to kill the minimum amount of processes (one)
- * 5) we try to kill the process the user expects us to kill, this
- *    algorithm has been meticulously tuned to meet the principle
- *    of least surprise ... (be careful when you change it)
+ * for such tasks to target the parent.  oom_kill_process() will attempt to
+ * first kill a child, so there's no risk of killing an important system daemon
+ * via this method.  The goal is to give the user a chance to recover from the
+ * error rather than deplete all memory.
  */
-
-unsigned long badness(struct task_struct *p, unsigned long uptime)
+static unsigned long oom_forkbomb_penalty(struct task_struct *tsk)
 {
-	unsigned long points, cpu_time, run_time;
-	struct mm_struct *mm;
 	struct task_struct *child;
-	int oom_adj = p->signal->oom_adj;
-	struct task_cputime task_time;
-	unsigned long utime;
-	unsigned long stime;
+	unsigned long child_rss = 0;
+	int forkcount = 0;
 
-	if (oom_adj == OOM_DISABLE)
+	if (!sysctl_oom_forkbomb_thres)
 		return 0;
+	list_for_each_entry(child, &tsk->children, sibling) {
+		struct task_cputime task_time;
+		unsigned long runtime;
 
-	task_lock(p);
-	mm = p->mm;
-	if (!mm) {
-		task_unlock(p);
-		return 0;
+		task_lock(child);
+		if (!child->mm || child->mm == tsk->mm) {
+			task_unlock(child);
+			continue;
+		}
+		thread_group_cputime(child, &task_time);
+		runtime = cputime_to_jiffies(task_time.utime) +
+			  cputime_to_jiffies(task_time.stime);
+		/*
+		 * Only threads that have run for less than a second are
+		 * considered toward the forkbomb penalty, these threads rarely
+		 * get to execute at all in such cases anyway.
+		 */
+		if (runtime < HZ) {
+			child_rss += get_mm_rss(child->mm);
+			forkcount++;
+		}
+		task_unlock(child);
 	}
 
 	/*
-	 * The memory size of the process is the basis for the badness.
+	 * Forkbombs get penalized by:
+	 *
+	 * (average rss of children) * (# of first-generation execve children) /
+	 *			sysctl_oom_forkbomb_thres
 	 */
-	points = mm->total_vm;
+	return forkcount > sysctl_oom_forkbomb_thres ?
+				(child_rss / sysctl_oom_forkbomb_thres) : 0;
+}
+
+/**
+ * oom_badness - heuristic function to determine which candidate task to kill
+ * @p: task struct of which task we should calculate
+ * @totalpages: total present RAM allowed for page allocation
+ * @uptime: current uptime in seconds
+ *
+ * The heuristic for determining which task to kill is made to be as simple and
+ * predictable as possible.  The goal is to return the highest value for the
+ * task consuming the most memory to avoid subsequent oom conditions.
+ */
+unsigned int oom_badness(struct task_struct *p, unsigned long totalpages,
+							unsigned long uptime)
+{
+	struct mm_struct *mm;
+	int points;
 
 	/*
-	 * After this unlock we can no longer dereference local variable `mm'
+	 * Shortcut check for OOM_DISABLE so the entire heuristic doesn't need
+	 * to be executed for something that can't be killed.
 	 */
-	task_unlock(p);
+	if (p->signal->oom_adj == OOM_DISABLE)
+		return 0;
 
 	/*
-	 * swapoff can easily use up all memory, so kill those first.
+	 * When the PF_OOM_ORIGIN bit is set, it indicates the task should have
+	 * priority for oom killing.
 	 */
 	if (p->flags & PF_OOM_ORIGIN)
-		return ULONG_MAX;
+		return 1000;
 
-	/*
-	 * Processes which fork a lot of child processes are likely
-	 * a good choice. We add half the vmsize of the children if they
-	 * have an own mm. This prevents forking servers to flood the
-	 * machine with an endless amount of children. In case a single
-	 * child is eating the vast majority of memory, adding only half
-	 * to the parents will make the child our kill candidate of choice.
-	 */
-	list_for_each_entry(child, &p->children, sibling) {
-		task_lock(child);
-		if (child->mm != mm && child->mm)
-			points += child->mm->total_vm/2 + 1;
-		task_unlock(child);
+	task_lock(p);
+	mm = p->mm;
+	if (!mm) {
+		task_unlock(p);
+		return 0;
 	}
 
 	/*
-	 * CPU time is in tens of seconds and run time is in thousands
-         * of seconds. There is no particular reason for this other than
-         * that it turned out to work very well in practice.
-	 */
-	thread_group_cputime(p, &task_time);
-	utime = cputime_to_jiffies(task_time.utime);
-	stime = cputime_to_jiffies(task_time.stime);
-	cpu_time = (utime + stime) >> (SHIFT_HZ + 3);
-
-
-	if (uptime >= p->start_time.tv_sec)
-		run_time = (uptime - p->start_time.tv_sec) >> 10;
-	else
-		run_time = 0;
-
-	if (cpu_time)
-		points /= int_sqrt(cpu_time);
-	if (run_time)
-		points /= int_sqrt(int_sqrt(run_time));
-
-	/*
-	 * Niced processes are most likely less important, so double
-	 * their badness points.
+	 * The baseline for the badness score is the proportion of RAM that each
+	 * task's rss and swap space use.
 	 */
-	if (task_nice(p) > 0)
-		points *= 2;
-
-	/*
-	 * Superuser processes are usually more important, so we make it
-	 * less likely that we kill those.
-	 */
-	if (has_capability_noaudit(p, CAP_SYS_ADMIN) ||
-	    has_capability_noaudit(p, CAP_SYS_RESOURCE))
-		points /= 4;
+	points = (get_mm_rss(mm) + get_mm_counter(mm, MM_SWAPENTS)) * 1000 /
+			totalpages;
+	task_unlock(p);
+	points += oom_forkbomb_penalty(p);
 
 	/*
-	 * We don't want to kill a process with direct hardware access.
-	 * Not only could that mess up the hardware, but usually users
-	 * tend to only have this flag set on applications they think
-	 * of as important.
+	 * Root processes get 3% bonus, just like the __vm_enough_memory() used
+	 * by LSMs.
 	 */
-	if (has_capability_noaudit(p, CAP_SYS_RAWIO))
-		points /= 4;
+	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
+		points -= 30;
 
 	/*
-	 * Adjust the score by oom_adj.
+	 * /proc/pid/oom_adj ranges from -1000 to +1000 such that the range
+	 * may either completely disable oom killing or always prefer a certain
+	 * task.
 	 */
-	if (oom_adj) {
-		if (oom_adj > 0) {
-			if (!points)
-				points = 1;
-			points <<= oom_adj;
-		} else
-			points >>= -(oom_adj);
-	}
+	points += p->signal->oom_adj;
 
-#ifdef DEBUG
-	printk(KERN_DEBUG "OOMkill: task %d (%s) got %lu points\n",
-	p->pid, p->comm, points);
-#endif
-	return points;
+	if (points < 0)
+		return 0;
+	return (points <= 1000) ? points : 1000;
 }
 
 /*
@@ -207,11 +196,21 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
  */
 #ifdef CONFIG_NUMA
 static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
-				    gfp_t gfp_mask, nodemask_t *nodemask)
+				gfp_t gfp_mask, nodemask_t *nodemask,
+				unsigned long *totalpages)
 {
 	struct zone *zone;
 	struct zoneref *z;
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
+	bool cpuset_limited = false;
+	int nid;
+
+	/* Default to all anonymous memory, page cache, and swap */
+	*totalpages = global_page_state(NR_INACTIVE_ANON) +
+			global_page_state(NR_ACTIVE_ANON) +
+			global_page_state(NR_INACTIVE_FILE) +
+			global_page_state(NR_ACTIVE_FILE) +
+			total_swap_pages;
 
 	/*
 	 * Reach here only when __GFP_NOFAIL is used. So, we should avoid
@@ -222,25 +221,41 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
 		return CONSTRAINT_NONE;
 
 	/*
-	 * The nodemask here is a nodemask passed to alloc_pages(). Now,
-	 * cpuset doesn't use this nodemask for its hardwall/softwall/hierarchy
-	 * feature. mempolicy is an only user of nodemask here.
-	 * check mempolicy's nodemask contains all N_HIGH_MEMORY
+	 * This is not a __GFP_THISNODE allocation, so a truncated nodemask in
+	 * the page allocator means a mempolicy is in effect.  Cpuset policy
+	 * is enforced in get_page_from_freelist().
 	 */
-	if (nodemask && !nodes_subset(node_states[N_HIGH_MEMORY], *nodemask))
+	if (nodemask && !nodes_subset(node_states[N_HIGH_MEMORY], *nodemask)) {
+		*totalpages = total_swap_pages;
+		for_each_node_mask(nid, *nodemask)
+			*totalpages += node_page_state(nid, NR_INACTIVE_ANON) +
+					node_page_state(nid, NR_ACTIVE_ANON) +
+					node_page_state(nid, NR_INACTIVE_FILE) +
+					node_page_state(nid, NR_ACTIVE_FILE);
 		return CONSTRAINT_MEMORY_POLICY;
+	}
 
 	/* Check this allocation failure is caused by cpuset's wall function */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 			high_zoneidx, nodemask)
 		if (!cpuset_zone_allowed_softwall(zone, gfp_mask))
-			return CONSTRAINT_CPUSET;
-
+			cpuset_limited = true;
+
+	if (cpuset_limited) {
+		*totalpages = total_swap_pages;
+		for_each_node_mask(nid, cpuset_current_mems_allowed)
+			*totalpages += node_page_state(nid, NR_INACTIVE_ANON) +
+					node_page_state(nid, NR_ACTIVE_ANON) +
+					node_page_state(nid, NR_INACTIVE_FILE) +
+					node_page_state(nid, NR_ACTIVE_FILE);
+		return CONSTRAINT_CPUSET;
+	}
 	return CONSTRAINT_NONE;
 }
 #else
 static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
-				gfp_t gfp_mask, nodemask_t *nodemask)
+				gfp_t gfp_mask, nodemask_t *nodemask,
+				unsigned long *totalpages)
 {
 	return CONSTRAINT_NONE;
 }
@@ -252,9 +267,9 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
  *
  * (not docbooked, we don't want this one cluttering up the manual)
  */
-static struct task_struct *select_bad_process(unsigned long *ppoints,
-		struct mem_cgroup *mem, enum oom_constraint constraint,
-		const nodemask_t *mask)
+static struct task_struct *select_bad_process(unsigned int *ppoints,
+		unsigned long totalpages, struct mem_cgroup *mem,
+		enum oom_constraint constraint, const nodemask_t *mask)
 {
 	struct task_struct *p;
 	struct task_struct *chosen = NULL;
@@ -263,7 +278,7 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 
 	do_posix_clock_monotonic_gettime(&uptime);
 	for_each_process(p) {
-		unsigned long points;
+		unsigned int points;
 
 		/*
 		 * skip kernel threads and tasks which have already released
@@ -308,13 +323,13 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 				return ERR_PTR(-1UL);
 
 			chosen = p;
-			*ppoints = ULONG_MAX;
+			*ppoints = 1000;
 		}
 
 		if (p->signal->oom_adj == OOM_DISABLE)
 			continue;
 
-		points = badness(p, uptime.tv_sec);
+		points = oom_badness(p, totalpages, uptime.tv_sec);
 		if (points > *ppoints || !chosen) {
 			chosen = p;
 			*ppoints = points;
@@ -449,12 +464,12 @@ static int oom_kill_task(struct task_struct *p)
 }
 
 static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
-			    unsigned long points, struct mem_cgroup *mem,
-			    const char *message)
+			    unsigned int points, unsigned long totalpages,
+			    struct mem_cgroup *mem, const char *message)
 {
 	struct task_struct *victim = p;
 	struct task_struct *c;
-	unsigned long victim_points = 0;
+	unsigned int victim_points = 0;
 	struct timespec uptime;
 
 	if (printk_ratelimit())
@@ -469,19 +484,19 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		return 0;
 	}
 
-	pr_err("%s: Kill process %d (%s) with score %lu or sacrifice child\n",
+	pr_err("%s: Kill process %d (%s) with score %d or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);
 
 	/* Try to sacrifice the worst child first */
 	do_posix_clock_monotonic_gettime(&uptime);
 	list_for_each_entry(c, &p->children, sibling) {
-		unsigned long cpoints;
+		unsigned int cpoints;
 
 		if (c->mm == p->mm)
 			continue;
 
-		/* badness() returns 0 if the thread is unkillable */
-		cpoints = badness(c, uptime.tv_sec);
+		/* oom_badness() returns 0 if the thread is unkillable */
+		cpoints = oom_badness(c, totalpages, uptime.tv_sec);
 		if (cpoints > victim_points) {
 			victim = c;
 			victim_points = cpoints;
@@ -493,19 +508,22 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 {
-	unsigned long points = 0;
+	unsigned int points = 0;
 	struct task_struct *p;
+	unsigned long limit;
 
+	limit = (res_counter_read_u64(&mem->res, RES_LIMIT) >> PAGE_SHIFT) +
+		   (res_counter_read_u64(&mem->memsw, RES_LIMIT) >> PAGE_SHIFT);
 	read_lock(&tasklist_lock);
 retry:
-	p = select_bad_process(&points, mem, CONSTRAINT_NONE, NULL);
+	p = select_bad_process(&points, limit, mem, CONSTRAINT_NONE, NULL);
 	if (PTR_ERR(p) == -1UL)
 		goto out;
 
 	if (!p)
 		p = current;
 
-	if (oom_kill_process(p, gfp_mask, 0, points, mem,
+	if (oom_kill_process(p, gfp_mask, 0, points, limit, mem,
 				"Memory cgroup out of memory"))
 		goto retry;
 out:
@@ -580,22 +598,22 @@ void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_mask)
 /*
  * Must be called with tasklist_lock held for read.
  */
-static void __out_of_memory(gfp_t gfp_mask, int order,
+static void __out_of_memory(gfp_t gfp_mask, int order, unsigned long totalpages,
 			enum oom_constraint constraint, const nodemask_t *mask)
 {
 	struct task_struct *p;
-	unsigned long points;
+	unsigned int points;
 
 	if (sysctl_oom_kill_allocating_task)
-		if (!oom_kill_process(current, gfp_mask, order, 0, NULL,
-				"Out of memory (oom_kill_allocating_task)"))
+		if (!oom_kill_process(current, gfp_mask, order, 0, totalpages,
+			NULL, "Out of memory (oom_kill_allocating_task)"))
 			return;
 retry:
 	/*
 	 * Rambo mode: Shoot down a process and hope it solves whatever
 	 * issues we may have.
 	 */
-	p = select_bad_process(&points, NULL, constraint, mask);
+	p = select_bad_process(&points, totalpages, NULL, constraint, mask);
 
 	if (PTR_ERR(p) == -1UL)
 		return;
@@ -607,7 +625,7 @@ retry:
 		panic("Out of memory and no killable processes...\n");
 	}
 
-	if (oom_kill_process(p, gfp_mask, order, points, NULL,
+	if (oom_kill_process(p, gfp_mask, order, points, totalpages, NULL,
 			     "Out of memory"))
 		goto retry;
 }
@@ -618,6 +636,7 @@ retry:
  */
 void pagefault_out_of_memory(void)
 {
+	unsigned long totalpages;
 	unsigned long freed = 0;
 
 	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
@@ -635,9 +654,14 @@ void pagefault_out_of_memory(void)
 	if (sysctl_panic_on_oom)
 		panic("out of memory from page fault. panic_on_oom is selected.\n");
 
+	totalpages = global_page_state(NR_INACTIVE_ANON) +
+			global_page_state(NR_ACTIVE_ANON) +
+			global_page_state(NR_INACTIVE_FILE) +
+			global_page_state(NR_ACTIVE_FILE) +
+			total_swap_pages;
 	read_lock(&tasklist_lock);
 	/* unknown gfp_mask and order */
-	__out_of_memory(0, 0, CONSTRAINT_NONE, NULL);
+	__out_of_memory(0, 0, totalpages, CONSTRAINT_NONE, NULL);
 	read_unlock(&tasklist_lock);
 
 	/*
@@ -665,6 +689,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		int order, nodemask_t *nodemask)
 {
 	unsigned long freed = 0;
+	unsigned long totalpages = 0;
 	enum oom_constraint constraint;
 
 	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
@@ -681,7 +706,8 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
 	 */
-	constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
+	constraint = constrained_alloc(zonelist, gfp_mask, nodemask,
+								&totalpages);
 	read_lock(&tasklist_lock);
 	if (unlikely(sysctl_panic_on_oom)) {
 		/*
@@ -694,7 +720,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 			panic("Out of memory: panic_on_oom is enabled\n");
 		}
 	}
-	__out_of_memory(gfp_mask, order, constraint, nodemask);
+	__out_of_memory(gfp_mask, order, totalpages, constraint, nodemask);
 	read_unlock(&tasklist_lock);
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
