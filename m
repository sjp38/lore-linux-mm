Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 448BB6B04A7
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 11:30:57 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a186so14404078wmh.9
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 08:30:57 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id c18si13127876ede.55.2017.07.27.08.30.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 27 Jul 2017 08:30:54 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 3/3] mm/sched: memdelay: memory health interface for systems and workloads
Date: Thu, 27 Jul 2017 11:30:10 -0400
Message-Id: <20170727153010.23347-4-hannes@cmpxchg.org>
In-Reply-To: <20170727153010.23347-1-hannes@cmpxchg.org>
References: <20170727153010.23347-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Linux doesn't have a useful metric to describe the memory health of a
system, a cgroup container, or individual tasks.

When workloads are bigger than available memory, they spend a certain
amount of their time inside page reclaim, waiting on thrashing cache,
and swapping in. This has impact on latency, and depending on the CPU
capacity in the system can also translate to a decrease in throughput.

While Linux exports some stats and counters for these events, it does
not quantify the true impact they have on throughput and latency. How
much of the execution time is spent unproductively? This is important
to know when sizing workloads to systems and containers. It also comes
in handy when evaluating the effectiveness and efficiency of the
kernel's memory management policies and heuristics.

This patch implements a metric that quantifies memory pressure in a
unit that matters most to applications and does not rely on hardware
aspects to be meaningful: wallclock time lost while waiting on memory.

Whenever a task is blocked on refaults, swapins, or direct reclaim,
the time it spends is accounted on the task level and aggregated into
a domain state along with other tasks on the system and cgroup level.

Each task has a /proc/<pid>/memdelay file that lists the microseconds
the task has been delayed since it's been forked. That file can be
sampled periodically for recent delays, or before and after certain
operations to measure their memory-related latencies.

On the system and cgroup-level, there are /proc/memdelay and
memory.memdelay, respectively, and their format is as such:

$ cat /proc/memdelay
2489084
41.61 47.28 29.66
0.00 0.00 0.00

The first line shows the cumulative delay times of all tasks in the
domain - in this case, all tasks in the system cumulatively lost 2.49
seconds due to memory delays.

The second and third line show percentages spent in aggregate states
for the domain - system or cgroup - in a load average type format as
decaying averages over the last 1m, 5m, and 15m:

The second line indicates the share of wall-time the domain spends in
a state where SOME tasks are delayed by memory while others are still
productive (runnable or iowait). This indicates a latency problem for
individual tasks, but since the CPU/IO capacity is still used, adding
more memory might not necessarily improve the domain's throughput.

The third line indicates the share of wall-time the domain spends in a
state where ALL non-idle tasks are delayed by memory. In this state,
the domain is entirely unproductive due to a lack of memory.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/proc/array.c            |   8 ++
 fs/proc/base.c             |   2 +
 fs/proc/internal.h         |   2 +
 include/linux/cgroup.h     |  14 +++
 include/linux/memcontrol.h |  14 +++
 include/linux/memdelay.h   | 174 +++++++++++++++++++++++++++
 include/linux/sched.h      |  10 +-
 kernel/cgroup/cgroup.c     |   4 +-
 kernel/fork.c              |   4 +
 kernel/sched/Makefile      |   2 +-
 kernel/sched/core.c        |  20 ++++
 kernel/sched/memdelay.c    | 112 ++++++++++++++++++
 mm/Makefile                |   2 +-
 mm/compaction.c            |   4 +
 mm/filemap.c               |   9 ++
 mm/memcontrol.c            |  25 ++++
 mm/memdelay.c              | 289 +++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c            |  11 +-
 mm/vmscan.c                |   9 ++
 19 files changed, 709 insertions(+), 6 deletions(-)
 create mode 100644 include/linux/memdelay.h
 create mode 100644 kernel/sched/memdelay.c
 create mode 100644 mm/memdelay.c

diff --git a/fs/proc/array.c b/fs/proc/array.c
index 88c355574aa0..00e0e9aa3e70 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -611,6 +611,14 @@ int proc_pid_statm(struct seq_file *m, struct pid_namespace *ns,
 	return 0;
 }
 
+int proc_pid_memdelay(struct seq_file *m, struct pid_namespace *ns,
+		      struct pid *pid, struct task_struct *task)
+{
+	seq_put_decimal_ull(m, "", task->memdelay_total);
+	seq_putc(m, '\n');
+	return 0;
+}
+
 #ifdef CONFIG_PROC_CHILDREN
 static struct pid *
 get_children_pid(struct inode *inode, struct pid *pid_prev, loff_t pos)
diff --git a/fs/proc/base.c b/fs/proc/base.c
index f1e1927ccd48..cd653729b0c6 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2873,6 +2873,7 @@ static const struct pid_entry tgid_base_stuff[] = {
 	REG("cmdline",    S_IRUGO, proc_pid_cmdline_ops),
 	ONE("stat",       S_IRUGO, proc_tgid_stat),
 	ONE("statm",      S_IRUGO, proc_pid_statm),
+	ONE("memdelay",   S_IRUGO, proc_pid_memdelay),
 	REG("maps",       S_IRUGO, proc_pid_maps_operations),
 #ifdef CONFIG_NUMA
 	REG("numa_maps",  S_IRUGO, proc_pid_numa_maps_operations),
@@ -3263,6 +3264,7 @@ static const struct pid_entry tid_base_stuff[] = {
 	REG("cmdline",   S_IRUGO, proc_pid_cmdline_ops),
 	ONE("stat",      S_IRUGO, proc_tid_stat),
 	ONE("statm",     S_IRUGO, proc_pid_statm),
+	ONE("memdelay",  S_IRUGO, proc_pid_memdelay),
 	REG("maps",      S_IRUGO, proc_tid_maps_operations),
 #ifdef CONFIG_PROC_CHILDREN
 	REG("children",  S_IRUGO, proc_tid_children_operations),
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index c5ae09b6c726..49eba8f0cc7c 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -146,6 +146,8 @@ extern int proc_pid_status(struct seq_file *, struct pid_namespace *,
 			   struct pid *, struct task_struct *);
 extern int proc_pid_statm(struct seq_file *, struct pid_namespace *,
 			  struct pid *, struct task_struct *);
+extern int proc_pid_memdelay(struct seq_file *, struct pid_namespace *,
+			     struct pid *, struct task_struct *);
 
 /*
  * base.c
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 710a005c6b7a..7283439043d9 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -102,6 +102,17 @@ int cgroupstats_build(struct cgroupstats *stats, struct dentry *dentry);
 int proc_cgroup_show(struct seq_file *m, struct pid_namespace *ns,
 		     struct pid *pid, struct task_struct *tsk);
 
+/* caller must have irqs disabled */
+static inline void lock_task_cgroup(struct task_struct *p)
+{
+	spin_lock(&p->cgroups_lock);
+}
+
+static inline void unlock_task_cgroup(struct task_struct *p)
+{
+	spin_unlock(&p->cgroups_lock);
+}
+
 void cgroup_fork(struct task_struct *p);
 extern int cgroup_can_fork(struct task_struct *p);
 extern void cgroup_cancel_fork(struct task_struct *p);
@@ -620,6 +631,9 @@ static inline int cgroup_attach_task_all(struct task_struct *from,
 static inline int cgroupstats_build(struct cgroupstats *stats,
 				    struct dentry *dentry) { return -EINVAL; }
 
+static inline void lock_task_cgroup(struct task_struct *p) {}
+static inline void unlock_task_cgroup(struct task_struct *p) {}
+
 static inline void cgroup_fork(struct task_struct *p) {}
 static inline int cgroup_can_fork(struct task_struct *p) { return 0; }
 static inline void cgroup_cancel_fork(struct task_struct *p) {}
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 899949bbb2f9..579a28e84f3b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -29,6 +29,7 @@
 #include <linux/mmzone.h>
 #include <linux/writeback.h>
 #include <linux/page-flags.h>
+#include <linux/memdelay.h>
 
 struct mem_cgroup;
 struct page;
@@ -179,6 +180,9 @@ struct mem_cgroup {
 
 	unsigned long soft_limit;
 
+	/* Memory delay measurement domain */
+	struct memdelay_domain *memdelay_domain;
+
 	/* vmpressure notifications */
 	struct vmpressure vmpressure;
 
@@ -632,6 +636,11 @@ static inline struct lruvec *mem_cgroup_page_lruvec(struct page *page,
 	return &pgdat->lruvec;
 }
 
+static inline struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg)
+{
+	return NULL;
+}
+
 static inline bool mm_match_cgroup(struct mm_struct *mm,
 		struct mem_cgroup *memcg)
 {
@@ -644,6 +653,11 @@ static inline bool task_in_mem_cgroup(struct task_struct *task,
 	return true;
 }
 
+static inline struct mem_cgroup *mem_cgroup_from_task(struct task_struct *task)
+{
+	return NULL;
+}
+
 static inline struct mem_cgroup *
 mem_cgroup_iter(struct mem_cgroup *root,
 		struct mem_cgroup *prev,
diff --git a/include/linux/memdelay.h b/include/linux/memdelay.h
new file mode 100644
index 000000000000..7187fdb49204
--- /dev/null
+++ b/include/linux/memdelay.h
@@ -0,0 +1,174 @@
+#ifndef _LINUX_MEMDELAY_H
+#define _LINUX_MEMDELAY_H
+
+#include <linux/spinlock_types.h>
+#include <linux/sched.h>
+
+struct seq_file;
+struct css_set;
+
+/*
+ * Task productivity states tracked by the scheduler
+ */
+enum memdelay_task_state {
+	MTS_NONE,		/* Idle/unqueued/untracked */
+	MTS_WORKING,		/* Runnable or waiting for IO */
+	MTS_DELAYED,		/* Memory delayed, not running */
+	MTS_DELAYED_ACTIVE,	/* Memory delayed, actively running */
+	NR_MEMDELAY_TASK_STATES,
+};
+
+/*
+ * System/cgroup delay state tracked by the VM, composed of the
+ * productivity states of all tasks inside the domain.
+ */
+enum memdelay_domain_state {
+	MDS_NONE,		/* No delayed tasks */
+	MDS_SOME,		/* Delayed tasks, working tasks */
+	MDS_FULL,		/* Delayed tasks, no working tasks */
+	NR_MEMDELAY_DOMAIN_STATES,
+};
+
+struct memdelay_domain_cpu {
+	spinlock_t lock;
+
+	/* Task states of the domain on this CPU */
+	int tasks[NR_MEMDELAY_TASK_STATES];
+
+	/* Delay state of the domain on this CPU */
+	enum memdelay_domain_state state;
+
+	/* Time of last state change */
+	unsigned long state_start;
+};
+
+struct memdelay_domain {
+	/* Aggregate delayed time of all domain tasks */
+	unsigned long aggregate;
+
+	/* Per-CPU delay states in the domain */
+	struct memdelay_domain_cpu __percpu *mdcs;
+
+	/* Cumulative state times from all CPUs */
+	unsigned long times[NR_MEMDELAY_DOMAIN_STATES];
+
+	/* Decaying state time averages over 1m, 5m, 15m */
+	unsigned long period_expires;
+	unsigned long avg_full[3];
+	unsigned long avg_some[3];
+};
+
+/* mm/memdelay.c */
+extern struct memdelay_domain memdelay_global_domain;
+void memdelay_init(void);
+void memdelay_task_change(struct task_struct *task, int old, int new);
+struct memdelay_domain *memdelay_domain_alloc(void);
+void memdelay_domain_free(struct memdelay_domain *md);
+int memdelay_domain_show(struct seq_file *s, struct memdelay_domain *md);
+
+/* kernel/sched/memdelay.c */
+void memdelay_enter(unsigned long *flags);
+void memdelay_leave(unsigned long *flags);
+
+/**
+ * memdelay_schedule - note a context switch
+ * @prev: task scheduling out
+ * @next: task scheduling in
+ *
+ * A task switch doesn't affect the balance between delayed and
+ * productive tasks, but we have to update whether the delay is
+ * actively using the CPU or not.
+ */
+static inline void memdelay_schedule(struct task_struct *prev,
+				     struct task_struct *next)
+{
+	if (prev->flags & PF_MEMDELAY)
+		memdelay_task_change(prev, MTS_DELAYED_ACTIVE, MTS_DELAYED);
+
+	if (next->flags & PF_MEMDELAY)
+		memdelay_task_change(next, MTS_DELAYED, MTS_DELAYED_ACTIVE);
+}
+
+/**
+ * memdelay_wakeup - note a task waking up
+ * @task: the task
+ *
+ * Notes an idle task becoming productive. Delayed tasks remain
+ * delayed even when they become runnable; tasks in iowait are
+ * considered productive.
+ */
+static inline void memdelay_wakeup(struct task_struct *task)
+{
+	if (task->flags & PF_MEMDELAY || task->in_iowait)
+		return;
+
+	memdelay_task_change(task, MTS_NONE, MTS_WORKING);
+}
+
+/**
+ * memdelay_wakeup - note a task going to sleep
+ * @task: the task
+ *
+ * Notes a working tasks becoming unproductive. Delayed tasks remain
+ * delayed; tasks sleeping in an iowait remain productive.
+ */
+static inline void memdelay_sleep(struct task_struct *task)
+{
+	if (task->flags & PF_MEMDELAY || task->in_iowait)
+		return;
+
+	memdelay_task_change(task, MTS_WORKING, MTS_NONE);
+}
+
+/**
+ * memdelay_del_add - track task movement between runqueues
+ * @task: the task
+ * @runnable: a runnable task is moved if %true, unqueued otherwise
+ * @add: task is being added if %true, removed otherwise
+ *
+ * Update the memdelay domain per-cpu states as tasks are being moved
+ * around the runqueues.
+ */
+static inline void memdelay_del_add(struct task_struct *task,
+				    bool runnable, bool add)
+{
+	int state;
+
+	if (task->flags & PF_MEMDELAY)
+		state = MTS_DELAYED;
+	else if (runnable || task->in_iowait)
+		state = MTS_WORKING;
+	else
+		return; /* already MTS_NONE */
+
+	if (add)
+		memdelay_task_change(task, MTS_NONE, state);
+	else
+		memdelay_task_change(task, state, MTS_NONE);
+}
+
+static inline void memdelay_del_runnable(struct task_struct *task)
+{
+	memdelay_del_add(task, true, false);
+}
+
+static inline void memdelay_add_runnable(struct task_struct *task)
+{
+	memdelay_del_add(task, true, true);
+}
+
+static inline void memdelay_del_sleeping(struct task_struct *task)
+{
+	memdelay_del_add(task, false, false);
+}
+
+static inline void memdelay_add_sleeping(struct task_struct *task)
+{
+	memdelay_del_add(task, false, true);
+}
+
+#ifdef CONFIG_CGROUPS
+void cgroup_move_task(struct task_struct *task, struct css_set *to);
+#endif
+
+#endif /* _LINUX_MEMDELAY_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 2b69fc650201..c5da04c260e1 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -837,6 +837,12 @@ struct task_struct {
 
 	struct io_context		*io_context;
 
+	unsigned long			memdelay_start;
+	unsigned long			memdelay_total;
+#ifdef CONFIG_DEBUG_VM
+	int				memdelay_state;
+#endif
+
 	/* Ptrace state: */
 	unsigned long			ptrace_message;
 	siginfo_t			*last_siginfo;
@@ -859,7 +865,8 @@ struct task_struct {
 	int				cpuset_slab_spread_rotor;
 #endif
 #ifdef CONFIG_CGROUPS
-	/* Control Group info protected by css_set_lock: */
+	spinlock_t			cgroups_lock;
+	/* Control Group info protected by cgroups_lock: */
 	struct css_set __rcu		*cgroups;
 	/* cg_list protected by css_set_lock and tsk->alloc_lock: */
 	struct list_head		cg_list;
@@ -1231,6 +1238,7 @@ extern struct pid *cad_pid;
 #define PF_KTHREAD		0x00200000	/* I am a kernel thread */
 #define PF_RANDOMIZE		0x00400000	/* Randomize virtual address space */
 #define PF_SWAPWRITE		0x00800000	/* Allowed to write to swap */
+#define PF_MEMDELAY		0x01000000	/* Delayed due to lack of memory */
 #define PF_NO_SETAFFINITY	0x04000000	/* Userland is not allowed to meddle with cpus_allowed */
 #define PF_MCE_EARLY		0x08000000      /* Early kill for mce process policy */
 #define PF_MUTEX_TESTER		0x20000000	/* Thread belongs to the rt mutex tester */
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 8d4e85eae42c..f442e16911bc 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -694,7 +694,8 @@ static void css_set_move_task(struct task_struct *task,
 		 */
 		WARN_ON_ONCE(task->flags & PF_EXITING);
 
-		rcu_assign_pointer(task->cgroups, to_cset);
+		cgroup_move_task(task, to_cset);
+
 		list_add_tail(&task->cg_list, use_mg_tasks ? &to_cset->mg_tasks :
 							     &to_cset->tasks);
 	}
@@ -4693,6 +4694,7 @@ int proc_cgroup_show(struct seq_file *m, struct pid_namespace *ns,
  */
 void cgroup_fork(struct task_struct *child)
 {
+	spin_lock_init(&child->cgroups_lock);
 	RCU_INIT_POINTER(child->cgroups, &init_css_set);
 	INIT_LIST_HEAD(&child->cg_list);
 }
diff --git a/kernel/fork.c b/kernel/fork.c
index e53770d2bf95..73b8dae7b34e 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1201,6 +1201,10 @@ static int copy_mm(unsigned long clone_flags, struct task_struct *tsk)
 	int retval;
 
 	tsk->min_flt = tsk->maj_flt = 0;
+	tsk->memdelay_total = 0;
+#ifdef CONFIG_DEBUG_VM
+	tsk->memdelay_state = 0;
+#endif
 	tsk->nvcsw = tsk->nivcsw = 0;
 #ifdef CONFIG_DETECT_HUNG_TASK
 	tsk->last_switch_count = tsk->nvcsw + tsk->nivcsw;
diff --git a/kernel/sched/Makefile b/kernel/sched/Makefile
index 89ab6758667b..5efb0fddc3d3 100644
--- a/kernel/sched/Makefile
+++ b/kernel/sched/Makefile
@@ -17,7 +17,7 @@ endif
 
 obj-y += core.o loadavg.o clock.o cputime.o
 obj-y += idle_task.o fair.o rt.o deadline.o stop_task.o
-obj-y += wait.o swait.o completion.o idle.o
+obj-y += wait.o swait.o completion.o idle.o memdelay.o
 obj-$(CONFIG_SMP) += cpupri.o cpudeadline.o topology.o
 obj-$(CONFIG_SCHED_AUTOGROUP) += autogroup.o
 obj-$(CONFIG_SCHEDSTATS) += stats.o
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 326d4f88e2b1..a90399a5473f 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -25,6 +25,7 @@
 #include <linux/profile.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
+#include <linux/memdelay.h>
 
 #include <asm/switch_to.h>
 #include <asm/tlb.h>
@@ -758,6 +759,11 @@ static inline void enqueue_task(struct rq *rq, struct task_struct *p, int flags)
 	if (!(flags & ENQUEUE_RESTORE))
 		sched_info_queued(rq, p);
 
+	if (flags & ENQUEUE_WAKEUP)
+		memdelay_wakeup(p);
+	else
+		memdelay_add_runnable(p);
+
 	p->sched_class->enqueue_task(rq, p, flags);
 }
 
@@ -769,6 +775,11 @@ static inline void dequeue_task(struct rq *rq, struct task_struct *p, int flags)
 	if (!(flags & DEQUEUE_SAVE))
 		sched_info_dequeued(rq, p);
 
+	if (flags & DEQUEUE_SLEEP)
+		memdelay_sleep(p);
+	else
+		memdelay_del_runnable(p);
+
 	p->sched_class->dequeue_task(rq, p, flags);
 }
 
@@ -2053,7 +2064,12 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
 	cpu = select_task_rq(p, p->wake_cpu, SD_BALANCE_WAKE, wake_flags);
 	if (task_cpu(p) != cpu) {
 		wake_flags |= WF_MIGRATED;
+
+		memdelay_del_sleeping(p);
+
 		set_task_cpu(p, cpu);
+
+		memdelay_add_sleeping(p);
 	}
 
 #else /* CONFIG_SMP */
@@ -3434,6 +3450,8 @@ static void __sched notrace __schedule(bool preempt)
 		rq->curr = next;
 		++*switch_count;
 
+		memdelay_schedule(prev, next);
+
 		trace_sched_switch(preempt, prev, next);
 
 		/* Also unlocks the rq: */
@@ -6210,6 +6228,8 @@ void __init sched_init(void)
 
 	init_schedstats();
 
+	memdelay_init();
+
 	scheduler_running = 1;
 }
 
diff --git a/kernel/sched/memdelay.c b/kernel/sched/memdelay.c
new file mode 100644
index 000000000000..971f45a0b946
--- /dev/null
+++ b/kernel/sched/memdelay.c
@@ -0,0 +1,112 @@
+/*
+ * Memory delay metric
+ *
+ * Copyright (c) 2017 Facebook, Johannes Weiner
+ *
+ * This code quantifies and reports to userspace the wall-time impact
+ * of memory pressure on the system and memory-controlled cgroups.
+ */
+
+#include <linux/memdelay.h>
+#include <linux/cgroup.h>
+#include <linux/sched.h>
+
+#include "sched.h"
+
+/**
+ * memdelay_enter - mark the beginning of a memory delay section
+ * @flags: flags to handle nested memdelay sections
+ *
+ * Marks the calling task as being delayed due to a lack of memory,
+ * such as waiting for a workingset refault or performing reclaim.
+ */
+void memdelay_enter(unsigned long *flags)
+{
+	*flags = current->flags & PF_MEMDELAY;
+	if (*flags)
+		return;
+	/*
+	 * PF_MEMDELAY & accounting needs to be atomic wrt changes to
+	 * the task's scheduling state (hence IRQ disabling) and its
+	 * domain association (hence lock_task_cgroup). Otherwise we
+	 * could race with CPU or cgroup migration and misaccount.
+	 */
+	WARN_ON_ONCE(irqs_disabled());
+	local_irq_disable();
+	lock_task_cgroup(current);
+
+	current->flags |= PF_MEMDELAY;
+	memdelay_task_change(current, MTS_WORKING, MTS_DELAYED_ACTIVE);
+
+	unlock_task_cgroup(current);
+	local_irq_enable();
+}
+
+/**
+ * memdelay_leave - mark the end of a memory delay section
+ * @flags: flags to handle nested memdelay sections
+ *
+ * Marks the calling task as no longer delayed due to memory.
+ */
+void memdelay_leave(unsigned long *flags)
+{
+	if (*flags)
+		return;
+	/*
+	 * PF_MEMDELAY & accounting needs to be atomic wrt changes to
+	 * the task's scheduling state (hence IRQ disabling) and its
+	 * domain association (hence lock_task_cgroup). Otherwise we
+	 * could race with CPU or cgroup migration and misaccount.
+	 */
+	WARN_ON_ONCE(irqs_disabled());
+	local_irq_disable();
+	lock_task_cgroup(current);
+
+	current->flags &= ~PF_MEMDELAY;
+	memdelay_task_change(current, MTS_DELAYED_ACTIVE, MTS_WORKING);
+
+	unlock_task_cgroup(current);
+	local_irq_enable();
+}
+
+#ifdef CONFIG_CGROUPS
+/**
+ * cgroup_move_task - move task to a different cgroup
+ * @task: the task
+ * @to: the target css_set
+ *
+ * Move task to a new cgroup and safely migrate its associated
+ * delayed/working state between the different domains.
+ *
+ * This function acquires the task's rq lock and lock_task_cgroup() to
+ * lock out concurrent changes to the task's scheduling state and - in
+ * case the task is running - concurrent changes to its delay state.
+ */
+void cgroup_move_task(struct task_struct *task, struct css_set *to)
+{
+	struct rq_flags rf;
+	struct rq *rq;
+	int state;
+
+	lock_task_cgroup(task);
+	rq = task_rq_lock(task, &rf);
+
+	if (task->flags & PF_MEMDELAY)
+		state = MTS_DELAYED + task_current(rq, task);
+	else if (task_on_rq_queued(task) || task->in_iowait)
+		state = MTS_WORKING;
+	else
+		state = MTS_NONE;
+
+	/*
+	 * Lame to do this here, but the scheduler cannot be locked
+	 * from the outside, so we move cgroups from inside sched/.
+	 */
+	memdelay_task_change(task, state, MTS_NONE);
+	rcu_assign_pointer(task->cgroups, to);
+	memdelay_task_change(task, MTS_NONE, state);
+
+	task_rq_unlock(rq, task, &rf);
+	unlock_task_cgroup(task);
+}
+#endif /* CONFIG_CGROUPS */
diff --git a/mm/Makefile b/mm/Makefile
index 026f6a828a50..ac020693031d 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -39,7 +39,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
 			   compaction.o vmacache.o swap_slots.o \
 			   interval_tree.o list_lru.o workingset.o \
-			   debug.o $(mmu-y)
+			   memdelay.o debug.o $(mmu-y)
 
 obj-y += init-mm.o
 
diff --git a/mm/compaction.c b/mm/compaction.c
index 613c59e928cb..d4b81318d1d7 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -2041,11 +2041,15 @@ static int kcompactd(void *p)
 	pgdat->kcompactd_classzone_idx = pgdat->nr_zones - 1;
 
 	while (!kthread_should_stop()) {
+		unsigned long mdflags;
+
 		trace_mm_compaction_kcompactd_sleep(pgdat->node_id);
 		wait_event_freezable(pgdat->kcompactd_wait,
 				kcompactd_work_requested(pgdat));
 
+		memdelay_enter(&mdflags);
 		kcompactd_do_work(pgdat);
+		memdelay_leave(&mdflags);
 	}
 
 	return 0;
diff --git a/mm/filemap.c b/mm/filemap.c
index 5c592e925805..12869768e2e4 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -36,6 +36,7 @@
 #include <linux/memcontrol.h>
 #include <linux/cleancache.h>
 #include <linux/rmap.h>
+#include <linux/memdelay.h>
 #include "internal.h"
 
 #define CREATE_TRACE_POINTS
@@ -830,10 +831,15 @@ static void wake_up_page(struct page *page, int bit)
 static inline int wait_on_page_bit_common(wait_queue_head_t *q,
 		struct page *page, int bit_nr, int state, bool lock)
 {
+	bool refault = bit_nr == PG_locked && PageWorkingset(page);
 	struct wait_page_queue wait_page;
 	wait_queue_t *wait = &wait_page.wait;
+	unsigned long mdflags;
 	int ret = 0;
 
+	if (refault)
+		memdelay_enter(&mdflags);
+
 	init_wait(wait);
 	wait->func = wake_page_function;
 	wait_page.page = page;
@@ -873,6 +879,9 @@ static inline int wait_on_page_bit_common(wait_queue_head_t *q,
 
 	finish_wait(q, wait);
 
+	if (refault)
+		memdelay_leave(&mdflags);
+
 	/*
 	 * A signal could leave PageWaiters set. Clearing it here if
 	 * !waitqueue_active would be possible (by open-coding finish_wait),
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 94172089f52f..5d1ebe329c48 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -65,6 +65,7 @@
 #include <linux/lockdep.h>
 #include <linux/file.h>
 #include <linux/tracehook.h>
+#include <linux/memdelay.h>
 #include "internal.h"
 #include <net/sock.h>
 #include <net/ip.h>
@@ -3907,6 +3908,8 @@ static ssize_t memcg_write_event_control(struct kernfs_open_file *of,
 	return ret;
 }
 
+static int memory_memdelay_show(struct seq_file *m, void *v);
+
 static struct cftype mem_cgroup_legacy_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -3974,6 +3977,10 @@ static struct cftype mem_cgroup_legacy_files[] = {
 	{
 		.name = "pressure_level",
 	},
+	{
+		.name = "memdelay",
+		.seq_show = memory_memdelay_show,
+	},
 #ifdef CONFIG_NUMA
 	{
 		.name = "numa_stat",
@@ -4142,6 +4149,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 
 	for_each_node(node)
 		free_mem_cgroup_per_node_info(memcg, node);
+	memdelay_domain_free(memcg->memdelay_domain);
 	free_percpu(memcg->stat);
 	kfree(memcg);
 }
@@ -4247,10 +4255,15 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 
 	/* The following stuff does not apply to the root */
 	if (!parent) {
+		memcg->memdelay_domain = &memdelay_global_domain;
 		root_mem_cgroup = memcg;
 		return &memcg->css;
 	}
 
+	memcg->memdelay_domain = memdelay_domain_alloc();
+	if (!memcg->memdelay_domain)
+		goto fail;
+
 	error = memcg_online_kmem(memcg);
 	if (error)
 		goto fail;
@@ -5241,6 +5254,13 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	return 0;
 }
 
+static int memory_memdelay_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+
+	return memdelay_domain_show(m, memcg->memdelay_domain);
+}
+
 static struct cftype memory_files[] = {
 	{
 		.name = "current",
@@ -5276,6 +5296,11 @@ static struct cftype memory_files[] = {
 		.flags = CFTYPE_NOT_ON_ROOT,
 		.seq_show = memory_stat_show,
 	},
+	{
+		.name = "memdelay",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.seq_show = memory_memdelay_show,
+	},
 	{ }	/* terminate */
 };
 
diff --git a/mm/memdelay.c b/mm/memdelay.c
new file mode 100644
index 000000000000..337a6bca9ee8
--- /dev/null
+++ b/mm/memdelay.c
@@ -0,0 +1,289 @@
+/*
+ * Memory delay metric
+ *
+ * Copyright (c) 2017 Facebook, Johannes Weiner
+ *
+ * This code quantifies and reports to userspace the wall-time impact
+ * of memory pressure on the system and memory-controlled cgroups.
+ */
+
+#include <linux/sched/loadavg.h>
+#include <linux/memcontrol.h>
+#include <linux/memdelay.h>
+#include <linux/seq_file.h>
+#include <linux/proc_fs.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/fs.h>
+
+static DEFINE_PER_CPU(struct memdelay_domain_cpu, global_domain_cpus);
+
+/* System-level keeping of memory delay statistics */
+struct memdelay_domain memdelay_global_domain = {
+	.mdcs = &global_domain_cpus,
+};
+
+static void domain_init(struct memdelay_domain *md)
+{
+	int cpu;
+
+	md->period_expires = jiffies + LOAD_FREQ;
+	for_each_possible_cpu(cpu) {
+		struct memdelay_domain_cpu *mdc;
+
+		mdc = per_cpu_ptr(md->mdcs, cpu);
+		spin_lock_init(&mdc->lock);
+	}
+}
+
+/**
+ * memdelay_init - initialize the memdelay subsystem
+ *
+ * This needs to run before the scheduler starts queuing and
+ * scheduling tasks.
+ */
+void __init memdelay_init(void)
+{
+	domain_init(&memdelay_global_domain);
+}
+
+static void domain_move_clock(struct memdelay_domain *md)
+{
+	unsigned long expires = READ_ONCE(md->period_expires);
+	unsigned long none, some, full;
+	int missed_periods;
+	unsigned long next;
+	int i;
+
+	if (time_before(jiffies, expires))
+		return;
+
+	missed_periods = 1 + (jiffies - expires) / LOAD_FREQ;
+	next = expires + (missed_periods * LOAD_FREQ);
+
+	if (cmpxchg(&md->period_expires, expires, next) != expires)
+		return;
+
+	none = xchg(&md->times[MDS_NONE], 0);
+	some = xchg(&md->times[MDS_SOME], 0);
+	full = xchg(&md->times[MDS_FULL], 0);
+
+	for (i = 0; i < missed_periods; i++) {
+		unsigned long pct;
+
+		pct = some * 100 / max(none + some + full, 1UL);
+		pct *= FIXED_1;
+		CALC_LOAD(md->avg_some[0], EXP_1, pct);
+		CALC_LOAD(md->avg_some[1], EXP_5, pct);
+		CALC_LOAD(md->avg_some[2], EXP_15, pct);
+
+		pct = full * 100 / max(none + some + full, 1UL);
+		pct *= FIXED_1;
+		CALC_LOAD(md->avg_full[0], EXP_1, pct);
+		CALC_LOAD(md->avg_full[1], EXP_5, pct);
+		CALC_LOAD(md->avg_full[2], EXP_15, pct);
+
+		none = some = full = 0;
+	}
+}
+
+static void domain_cpu_update(struct memdelay_domain *md, int cpu,
+			      int old, int new)
+{
+	enum memdelay_domain_state state;
+	struct memdelay_domain_cpu *mdc;
+	unsigned long now, delta;
+	unsigned long flags;
+
+	mdc = per_cpu_ptr(md->mdcs, cpu);
+	spin_lock_irqsave(&mdc->lock, flags);
+
+	if (old) {
+		WARN_ONCE(!mdc->tasks[old], "cpu=%d old=%d new=%d counter=%d\n",
+			  cpu, old, new, mdc->tasks[old]);
+		mdc->tasks[old] -= 1;
+	}
+	if (new)
+		mdc->tasks[new] += 1;
+
+	/*
+	 * The domain is somewhat delayed when a number of tasks are
+	 * delayed but there are still others running the workload.
+	 *
+	 * The domain is fully delayed when all non-idle tasks on the
+	 * CPU are delayed, or when a delayed task is actively running
+	 * and preventing productive tasks from making headway.
+	 *
+	 * The state times then add up over all CPUs in the domain: if
+	 * the domain is fully blocked on one CPU and there is another
+	 * one running the workload, the domain is considered fully
+	 * blocked 50% of the time.
+	 */
+	if (!mdc->tasks[MTS_DELAYED_ACTIVE] && !mdc->tasks[MTS_DELAYED])
+		state = MDS_NONE;
+	else if (mdc->tasks[MTS_WORKING])
+		state = MDS_SOME;
+	else
+		state = MDS_FULL;
+
+	if (mdc->state == state)
+		goto unlock;
+
+	now = ktime_to_ns(ktime_get());
+	delta = now - mdc->state_start;
+
+	domain_move_clock(md);
+	md->times[mdc->state] += delta;
+
+	mdc->state = state;
+	mdc->state_start = now;
+unlock:
+	spin_unlock_irqrestore(&mdc->lock, flags);
+}
+
+static struct memdelay_domain *memcg_domain(struct mem_cgroup *memcg)
+{
+#ifdef CONFIG_MEMCG
+	if (!mem_cgroup_disabled())
+		return memcg->memdelay_domain;
+#endif
+	return &memdelay_global_domain;
+}
+
+/**
+ * memdelay_task_change - note a task changing its delay/work state
+ * @task: the task changing state
+ * @delayed: 1 when task enters delayed state, -1 when it leaves
+ * @working: 1 when task enters working state, -1 when it leaves
+ * @active_delay: 1 when task enters active delay, -1 when it leaves
+ *
+ * Updates the task's domain counters to reflect a change in the
+ * task's delayed/working state.
+ */
+void memdelay_task_change(struct task_struct *task, int old, int new)
+{
+	int cpu = task_cpu(task);
+	struct mem_cgroup *memcg;
+	unsigned long delay = 0;
+
+#ifdef CONFIG_DEBUG_VM
+	WARN_ONCE(task->memdelay_state != old,
+		  "cpu=%d task=%p state=%d (in_iowait=%d PF_MEMDELAYED=%d) old=%d new=%d\n",
+		  cpu, task, task->memdelay_state, task->in_iowait,
+		  !!(task->flags & PF_MEMDELAY), old, new);
+	task->memdelay_state = new;
+#endif
+
+	/* Account when tasks are entering and leaving delays */
+	if (old < MTS_DELAYED && new >= MTS_DELAYED) {
+		task->memdelay_start = ktime_to_ms(ktime_get());
+	} else if (old >= MTS_DELAYED && new < MTS_DELAYED) {
+		delay = ktime_to_ms(ktime_get()) - task->memdelay_start;
+		task->memdelay_total += delay;
+	}
+
+	/* Account domain state changes */
+	rcu_read_lock();
+	memcg = mem_cgroup_from_task(task);
+	do {
+		struct memdelay_domain *md;
+
+		md = memcg_domain(memcg);
+		md->aggregate += delay;
+		domain_cpu_update(md, cpu, old, new);
+	} while (memcg && (memcg = parent_mem_cgroup(memcg)));
+	rcu_read_unlock();
+};
+
+/**
+ * memdelay_domain_alloc - allocate a cgroup memory delay domain
+ */
+struct memdelay_domain *memdelay_domain_alloc(void)
+{
+	struct memdelay_domain *md;
+
+	md = kzalloc(sizeof(*md), GFP_KERNEL);
+	if (!md)
+		return NULL;
+	md->mdcs = alloc_percpu(struct memdelay_domain_cpu);
+	if (!md->mdcs) {
+		kfree(md);
+		return NULL;
+	}
+	domain_init(md);
+	return md;
+}
+
+/**
+ * memdelay_domain_free - free a cgroup memory delay domain
+ */
+void memdelay_domain_free(struct memdelay_domain *md)
+{
+	if (md) {
+		free_percpu(md->mdcs);
+		kfree(md);
+	}
+}
+
+/**
+ * memdelay_domain_show - format memory delay domain stats to a seq_file
+ * @s: the seq_file
+ * @md: the memory domain
+ */
+int memdelay_domain_show(struct seq_file *s, struct memdelay_domain *md)
+{
+	int cpu;
+
+	domain_move_clock(md);
+
+	seq_printf(s, "%lu\n", md->aggregate);
+
+	seq_printf(s, "%lu.%02lu %lu.%02lu %lu.%02lu\n",
+		   LOAD_INT(md->avg_some[0]), LOAD_FRAC(md->avg_some[0]),
+		   LOAD_INT(md->avg_some[1]), LOAD_FRAC(md->avg_some[1]),
+		   LOAD_INT(md->avg_some[2]), LOAD_FRAC(md->avg_some[2]));
+
+	seq_printf(s, "%lu.%02lu %lu.%02lu %lu.%02lu\n",
+		   LOAD_INT(md->avg_full[0]), LOAD_FRAC(md->avg_full[0]),
+		   LOAD_INT(md->avg_full[1]), LOAD_FRAC(md->avg_full[1]),
+		   LOAD_INT(md->avg_full[2]), LOAD_FRAC(md->avg_full[2]));
+
+#ifdef CONFIG_DEBUG_VM
+	for_each_online_cpu(cpu) {
+		struct memdelay_domain_cpu *mdc;
+
+		mdc = per_cpu_ptr(md->mdcs, cpu);
+		seq_printf(s, "%d %d %d\n",
+			   mdc->tasks[MTS_WORKING],
+			   mdc->tasks[MTS_DELAYED],
+			   mdc->tasks[MTS_DELAYED_ACTIVE]);
+	}
+#endif
+
+	return 0;
+}
+
+static int memdelay_show(struct seq_file *m, void *v)
+{
+	return memdelay_domain_show(m, &memdelay_global_domain);
+}
+
+static int memdelay_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, memdelay_show, NULL);
+}
+
+static const struct file_operations memdelay_fops = {
+	.open           = memdelay_open,
+	.read           = seq_read,
+	.llseek         = seq_lseek,
+	.release        = single_release,
+};
+
+static int __init memdelay_proc_init(void)
+{
+	proc_create("memdelay", 0, NULL, &memdelay_fops);
+	return 0;
+}
+module_init(memdelay_proc_init);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2302f250d6b1..bec5e96f3b88 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -66,6 +66,7 @@
 #include <linux/kthread.h>
 #include <linux/memcontrol.h>
 #include <linux/ftrace.h>
+#include <linux/memdelay.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -3293,16 +3294,19 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
 		enum compact_priority prio, enum compact_result *compact_result)
 {
-	struct page *page;
 	unsigned int noreclaim_flag;
+	unsigned long mdflags;
+	struct page *page;
 
 	if (!order)
 		return NULL;
 
+	memdelay_enter(&mdflags);
 	noreclaim_flag = memalloc_noreclaim_save();
 	*compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
 									prio);
 	memalloc_noreclaim_restore(noreclaim_flag);
+	memdelay_leave(&mdflags);
 
 	if (*compact_result <= COMPACT_INACTIVE)
 		return NULL;
@@ -3448,13 +3452,15 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 					const struct alloc_context *ac)
 {
 	struct reclaim_state reclaim_state;
-	int progress;
 	unsigned int noreclaim_flag;
+	unsigned long mdflags;
+	int progress;
 
 	cond_resched();
 
 	/* We now go into synchronous reclaim */
 	cpuset_memory_pressure_bump();
+	memdelay_enter(&mdflags);
 	noreclaim_flag = memalloc_noreclaim_save();
 	lockdep_set_current_reclaim_state(gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
@@ -3466,6 +3472,7 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 	current->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
 	memalloc_noreclaim_restore(noreclaim_flag);
+	memdelay_leave(&mdflags);
 
 	cond_resched();
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 285db147d013..f44651b49670 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -48,6 +48,7 @@
 #include <linux/prefetch.h>
 #include <linux/printk.h>
 #include <linux/dax.h>
+#include <linux/memdelay.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -3045,6 +3046,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 {
 	struct zonelist *zonelist;
 	unsigned long nr_reclaimed;
+	unsigned long mdflags;
 	int nid;
 	unsigned int noreclaim_flag;
 	struct scan_control sc = {
@@ -3073,9 +3075,11 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 					    sc.gfp_mask,
 					    sc.reclaim_idx);
 
+	memdelay_enter(&mdflags);
 	noreclaim_flag = memalloc_noreclaim_save();
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 	memalloc_noreclaim_restore(noreclaim_flag);
+	memdelay_leave(&mdflags);
 
 	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
 
@@ -3497,6 +3501,7 @@ static int kswapd(void *p)
 	pgdat->kswapd_order = 0;
 	pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
 	for ( ; ; ) {
+		unsigned long mdflags;
 		bool ret;
 
 		alloc_order = reclaim_order = pgdat->kswapd_order;
@@ -3533,7 +3538,11 @@ static int kswapd(void *p)
 		 */
 		trace_mm_vmscan_kswapd_wake(pgdat->node_id, classzone_idx,
 						alloc_order);
+
+		memdelay_enter(&mdflags);
 		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx);
+		memdelay_leave(&mdflags);
+
 		if (reclaim_order < alloc_order)
 			goto kswapd_try_sleep;
 	}
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
