Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5ED886B0272
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 13:27:49 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p7-v6so931427eds.19
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 10:27:49 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id q23-v6si2274749edc.335.2018.07.12.10.27.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 12 Jul 2018 10:27:46 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 08/10] psi: pressure stall information for CPU, memory, and IO
Date: Thu, 12 Jul 2018 13:29:40 -0400
Message-Id: <20180712172942.10094-9-hannes@cmpxchg.org>
In-Reply-To: <20180712172942.10094-1-hannes@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

When systems are overcommitted and resources become contended, it's
hard to tell exactly the impact this has on workload productivity, or
how close the system is to lockups and OOM kills. In particular, when
machines work multiple jobs concurrently, the impact of overcommit in
terms of latency and throughput on the individual job can be enormous.

In order to maximize hardware utilization without sacrificing
individual job health or risk complete machine lockups, this patch
implements a way to quantify resource pressure in the system.

A kernel built with CONFIG_PSI=y creates files in /proc/pressure/ that
expose the percentage of time the system is stalled on CPU, memory, or
IO, respectively. Stall states are aggregate versions of the per-task
delay accounting delays:

       cpu: some tasks are runnable but not executing on a CPU
       memory: tasks are reclaiming, or waiting for swapin or thrashing cache
       io: tasks are waiting for io completions

These percentages of walltime can be thought of as pressure
percentages, and they give a general sense of system health and
productivity loss incurred by resource overcommit. They can also
indicate when the system is approaching lockup scenarios and OOMs.

To do this, psi keeps track of the task states associated with each
CPU and samples the time they spend in stall states. Every 2 seconds,
the samples are averaged across CPUs - weighted by the CPUs' non-idle
time to eliminate artifacts from unused CPUs - and translated into
percentages of walltime. A running average of those percentages is
maintained over 10s, 1m, and 5m periods (similar to the loadaverage).

v2:
- stable clock tick, as per Peter
- data structure layout optimization, as per Peter
- fix u64 divisions on 32 bit, as per Peter
- outermost psi_disabled checks, as per Peter
- coding style fixes, as per Peter
- just-in-time stats aggregation, as per Suren
- fix task state corruption with CONFIG_PREEMPT, as per Suren
- CONFIG_PSI=n build error
- avoid writing p->sched_psi_wake_requeue unnecessarily
- documentation & comment updates

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/accounting/psi.txt |  64 ++++
 include/linux/psi.h              |  27 ++
 include/linux/psi_types.h        |  90 +++++
 include/linux/sched.h            |  10 +
 include/linux/sched/stat.h       |  10 +-
 init/Kconfig                     |  16 +
 kernel/fork.c                    |   4 +
 kernel/sched/Makefile            |   1 +
 kernel/sched/core.c              |   7 +-
 kernel/sched/psi.c               | 585 +++++++++++++++++++++++++++++++
 kernel/sched/sched.h             |   2 +
 kernel/sched/stats.h             | 102 +++++-
 mm/compaction.c                  |   5 +
 mm/filemap.c                     |  15 +-
 mm/page_alloc.c                  |  10 +
 mm/vmscan.c                      |  13 +
 16 files changed, 946 insertions(+), 15 deletions(-)
 create mode 100644 Documentation/accounting/psi.txt
 create mode 100644 include/linux/psi.h
 create mode 100644 include/linux/psi_types.h
 create mode 100644 kernel/sched/psi.c

diff --git a/Documentation/accounting/psi.txt b/Documentation/accounting/psi.txt
new file mode 100644
index 000000000000..51e7ef14142e
--- /dev/null
+++ b/Documentation/accounting/psi.txt
@@ -0,0 +1,64 @@
+================================
+PSI - Pressure Stall Information
+================================
+
+:Date: April, 2018
+:Author: Johannes Weiner <hannes@cmpxchg.org>
+
+When CPU, memory or IO devices are contended, workloads experience
+latency spikes, throughput losses, and run the risk of OOM kills.
+
+Without an accurate measure of such contention, users are forced to
+either play it safe and under-utilize their hardware resources, or
+roll the dice and frequently suffer the disruptions resulting from
+excessive overcommit.
+
+The psi feature identifies and quantifies the disruptions caused by
+such resource crunches and the time impact it has on complex workloads
+or even entire systems.
+
+Having an accurate measure of productivity losses caused by resource
+scarcity aids users in sizing workloads to hardware--or provisioning
+hardware according to workload demand.
+
+As psi aggregates this information in realtime, systems can be managed
+dynamically using techniques such as load shedding, migrating jobs to
+other systems or data centers, or strategically pausing or killing low
+priority or restartable batch jobs.
+
+This allows maximizing hardware utilization without sacrificing
+workload health or risking major disruptions such as OOM kills.
+
+Pressure interface
+==================
+
+Pressure information for each resource is exported through the
+respective file in /proc/pressure/ -- cpu, memory, and io.
+
+In both cases, the format for CPU is as such:
+
+some avg10=0.00 avg60=0.00 avg300=0.00 total=0
+
+and for memory and IO:
+
+some avg10=0.00 avg60=0.00 avg300=0.00 total=0
+full avg10=0.00 avg60=0.00 avg300=0.00 total=0
+
+The "some" line indicates the share of time in which at least some
+tasks are stalled on a given resource.
+
+The "full" line indicates the share of time in which all non-idle
+tasks are stalled on a given resource simultaneously. In this state
+actual CPU cycles are going to waste, and a workload that spends
+extended time in this state is considered to be thrashing. This has
+severe impact on performance, and it's useful to distinguish this
+situation from a state where some tasks are stalled but the CPU is
+still doing productive work. As such, time spent in this subset of the
+stall state is tracked separately and exported in the "full" averages.
+
+The ratios are tracked as recent trends over ten, sixty, and three
+hundred second windows, which gives insight into short term events as
+well as medium and long term trends. The total absolute stall time is
+tracked and exported as well, to allow detection of latency spikes
+which wouldn't necessarily make a dent in the time averages, or to
+average trends over custom time frames.
diff --git a/include/linux/psi.h b/include/linux/psi.h
new file mode 100644
index 000000000000..371af1479699
--- /dev/null
+++ b/include/linux/psi.h
@@ -0,0 +1,27 @@
+#ifndef _LINUX_PSI_H
+#define _LINUX_PSI_H
+
+#include <linux/psi_types.h>
+#include <linux/sched.h>
+
+#ifdef CONFIG_PSI
+
+extern bool psi_disabled;
+
+void psi_init(void);
+
+void psi_task_change(struct task_struct *task, u64 now, int clear, int set);
+
+void psi_memstall_enter(unsigned long *flags);
+void psi_memstall_leave(unsigned long *flags);
+
+#else /* CONFIG_PSI */
+
+static inline void psi_init(void) {}
+
+static inline void psi_memstall_enter(unsigned long *flags) {}
+static inline void psi_memstall_leave(unsigned long *flags) {}
+
+#endif /* CONFIG_PSI */
+
+#endif /* _LINUX_PSI_H */
diff --git a/include/linux/psi_types.h b/include/linux/psi_types.h
new file mode 100644
index 000000000000..0ac74bb496e6
--- /dev/null
+++ b/include/linux/psi_types.h
@@ -0,0 +1,90 @@
+#ifndef _LINUX_PSI_TYPES_H
+#define _LINUX_PSI_TYPES_H
+
+#include <linux/types.h>
+
+#ifdef CONFIG_PSI
+
+/* Tracked task states */
+enum psi_task_count {
+	NR_RUNNING,
+	NR_IOWAIT,
+	NR_MEMSTALL,
+	NR_PSI_TASK_COUNTS,
+};
+
+/* Task state bitmasks */
+#define TSK_RUNNING	(1 << NR_RUNNING)
+#define TSK_IOWAIT	(1 << NR_IOWAIT)
+#define TSK_MEMSTALL	(1 << NR_MEMSTALL)
+
+/* Resources that workloads could be stalled on */
+enum psi_res {
+	PSI_CPU,
+	PSI_MEM,
+	PSI_IO,
+	NR_PSI_RESOURCES,
+};
+
+/* Pressure states for a group of tasks */
+enum psi_state {
+	PSI_NONE,		/* No stalled tasks */
+	PSI_SOME,		/* Stalled tasks & working tasks */
+	PSI_FULL,		/* Stalled tasks & no working tasks */
+	NR_PSI_STATES,
+};
+
+struct psi_resource {
+	/* Current pressure state for this resource */
+	enum psi_state state;
+
+	/* Start of current state (rq_clock) */
+	u64 state_start;
+
+	/* Time sampling buckets for pressure states SOME and FULL (ns) */
+	u64 times[2];
+};
+
+struct psi_group_cpu {
+	/* States of the tasks belonging to this group */
+	unsigned int tasks[NR_PSI_TASK_COUNTS];
+
+	/* There are runnable or D-state tasks */
+	int nonidle;
+
+	/* Start of current non-idle state (rq_clock) */
+	u64 nonidle_start;
+
+	/* Time sampling bucket for non-idle state (ns) */
+	u64 nonidle_time;
+
+	/* Per-resource pressure tracking in this group */
+	struct psi_resource res[NR_PSI_RESOURCES];
+};
+
+struct psi_group {
+	struct psi_group_cpu *cpus;
+
+	struct mutex stat_lock;
+
+	u64 some[NR_PSI_RESOURCES];
+	u64 full[NR_PSI_RESOURCES];
+
+	unsigned long period_expires;
+
+	u64 last_some[NR_PSI_RESOURCES];
+	u64 last_full[NR_PSI_RESOURCES];
+
+	unsigned long avg_some[NR_PSI_RESOURCES][3];
+	unsigned long avg_full[NR_PSI_RESOURCES][3];
+
+	struct delayed_work clock_work;
+};
+
+#else /* CONFIG_PSI */
+
+struct psi_group { };
+
+#endif /* CONFIG_PSI */
+
+#endif /* _LINUX_PSI_TYPES_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index ca3f3eae8980..d5e4ee234114 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -25,6 +25,7 @@
 #include <linux/latencytop.h>
 #include <linux/sched/prio.h>
 #include <linux/signal_types.h>
+#include <linux/psi_types.h>
 #include <linux/mm_types_task.h>
 #include <linux/task_io_accounting.h>
 
@@ -709,6 +710,10 @@ struct task_struct {
 	unsigned			sched_contributes_to_load:1;
 	unsigned			sched_migrated:1;
 	unsigned			sched_remote_wakeup:1;
+#ifdef CONFIG_PSI
+	unsigned			sched_psi_wake_requeue:1;
+#endif
+
 	/* Force alignment to the next boundary: */
 	unsigned			:0;
 
@@ -956,6 +961,10 @@ struct task_struct {
 	siginfo_t			*last_siginfo;
 
 	struct task_io_accounting	ioac;
+#ifdef CONFIG_PSI
+	/* Pressure stall state */
+	unsigned int			psi_flags;
+#endif
 #ifdef CONFIG_TASK_XACCT
 	/* Accumulated RSS usage: */
 	u64				acct_rss_mem1;
@@ -1385,6 +1394,7 @@ extern struct pid *cad_pid;
 #define PF_KTHREAD		0x00200000	/* I am a kernel thread */
 #define PF_RANDOMIZE		0x00400000	/* Randomize virtual address space */
 #define PF_SWAPWRITE		0x00800000	/* Allowed to write to swap */
+#define PF_MEMSTALL		0x01000000	/* Stalled due to lack of memory */
 #define PF_NO_SETAFFINITY	0x04000000	/* Userland is not allowed to meddle with cpus_allowed */
 #define PF_MCE_EARLY		0x08000000      /* Early kill for mce process policy */
 #define PF_MUTEX_TESTER		0x20000000	/* Thread belongs to the rt mutex tester */
diff --git a/include/linux/sched/stat.h b/include/linux/sched/stat.h
index 04f1321d14c4..ac39435d1521 100644
--- a/include/linux/sched/stat.h
+++ b/include/linux/sched/stat.h
@@ -28,10 +28,14 @@ static inline int sched_info_on(void)
 	return 1;
 #elif defined(CONFIG_TASK_DELAY_ACCT)
 	extern int delayacct_on;
-	return delayacct_on;
-#else
-	return 0;
+	if (delayacct_on)
+		return 1;
+#elif defined(CONFIG_PSI)
+	extern int psi_disabled;
+	if (!psi_disabled)
+		return 1;
 #endif
+	return 0;
 }
 
 #ifdef CONFIG_SCHEDSTATS
diff --git a/init/Kconfig b/init/Kconfig
index 18b151f0ddc1..e34859bda33e 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -457,6 +457,22 @@ config TASK_IO_ACCOUNTING
 
 	  Say N if unsure.
 
+config PSI
+	bool "Pressure stall information tracking"
+	select SCHED_INFO
+	help
+	  Collect metrics that indicate how overcommitted the CPU, memory,
+	  and IO capacity are in the system.
+
+	  If you say Y here, the kernel will create /proc/pressure/ with the
+	  pressure statistics files cpu, memory, and io. These will indicate
+	  the share of walltime in which some or all tasks in the system are
+	  delayed due to contention of the respective resource.
+
+	  For more details see Documentation/accounting/psi.txt.
+
+	  Say N if unsure.
+
 endmenu # "CPU/Task time and stats accounting"
 
 config CPU_ISOLATION
diff --git a/kernel/fork.c b/kernel/fork.c
index a5d21c42acfc..067aa5c28526 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1704,6 +1704,10 @@ static __latent_entropy struct task_struct *copy_process(
 
 	p->default_timer_slack_ns = current->timer_slack_ns;
 
+#ifdef CONFIG_PSI
+	p->psi_flags = 0;
+#endif
+
 	task_io_accounting_init(&p->ioac);
 	acct_clear_integrals(p);
 
diff --git a/kernel/sched/Makefile b/kernel/sched/Makefile
index d9a02b318108..b29bc18f2704 100644
--- a/kernel/sched/Makefile
+++ b/kernel/sched/Makefile
@@ -29,3 +29,4 @@ obj-$(CONFIG_CPU_FREQ) += cpufreq.o
 obj-$(CONFIG_CPU_FREQ_GOV_SCHEDUTIL) += cpufreq_schedutil.o
 obj-$(CONFIG_MEMBARRIER) += membarrier.o
 obj-$(CONFIG_CPU_ISOLATION) += isolation.o
+obj-$(CONFIG_PSI) += psi.o
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 9586a8141f16..16e8c8c8f432 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -744,7 +744,7 @@ static inline void enqueue_task(struct rq *rq, struct task_struct *p, int flags)
 		update_rq_clock(rq);
 
 	if (!(flags & ENQUEUE_RESTORE))
-		sched_info_queued(rq, p);
+		sched_info_queued(rq, p, flags & ENQUEUE_WAKEUP);
 
 	p->sched_class->enqueue_task(rq, p, flags);
 }
@@ -755,7 +755,7 @@ static inline void dequeue_task(struct rq *rq, struct task_struct *p, int flags)
 		update_rq_clock(rq);
 
 	if (!(flags & DEQUEUE_SAVE))
-		sched_info_dequeued(rq, p);
+		sched_info_dequeued(rq, p, flags & DEQUEUE_SLEEP);
 
 	p->sched_class->dequeue_task(rq, p, flags);
 }
@@ -2058,6 +2058,7 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
 	cpu = select_task_rq(p, p->wake_cpu, SD_BALANCE_WAKE, wake_flags);
 	if (task_cpu(p) != cpu) {
 		wake_flags |= WF_MIGRATED;
+		psi_ttwu_dequeue(p);
 		set_task_cpu(p, cpu);
 	}
 
@@ -6124,6 +6125,8 @@ void __init sched_init(void)
 
 	init_schedstats();
 
+	psi_init();
+
 	scheduler_running = 1;
 }
 
diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
new file mode 100644
index 000000000000..ef8e20383e4c
--- /dev/null
+++ b/kernel/sched/psi.c
@@ -0,0 +1,585 @@
+/*
+ * Pressure stall information for CPU, memory and IO
+ *
+ * Copyright (c) 2018 Facebook, Inc.
+ * Author: Johannes Weiner <hannes@cmpxchg.org>
+ *
+ * When CPU, memory and IO are contended, tasks experience delays that
+ * reduce throughput and introduce latencies into the workload. Memory
+ * and IO contention, in addition, can cause a full loss of forward
+ * progress in which the CPU goes idle.
+ *
+ * This code aggregates individual task delays into resource pressure
+ * metrics that indicate problems with both workload health and
+ * resource utilization.
+ *
+ *			Model
+ *
+ * The time in which a task can execute on a CPU is our baseline for
+ * productivity. Pressure expresses the amount of time in which this
+ * potential cannot be realized due to resource contention.
+ *
+ * This concept of productivity has two components: the workload and
+ * the CPU. To measure the impact of pressure on both, we define two
+ * contention states for a resource: SOME and FULL.
+ *
+ * In the SOME state of a given resource, one or more tasks are
+ * delayed on that resource. This affects the workload's ability to
+ * perform work, but the CPU may still be executing other tasks.
+ *
+ * In the FULL state of a given resource, all non-idle tasks are
+ * delayed on that resource such that nobody is advancing and the CPU
+ * goes idle. This leaves both workload and CPU unproductive.
+ *
+ * (Naturally, the FULL state doesn't exist for the CPU resource.)
+ *
+ *	SOME = nr_delayed_tasks != 0
+ *	FULL = nr_delayed_tasks != 0 && nr_running_tasks == 0
+ *
+ * The percentage of wallclock time spent in those compound stall
+ * states gives pressure numbers between 0 and 100 for each resource,
+ * where the SOME percentage indicates workload slowdowns and the FULL
+ * percentage indicates reduced CPU utilization:
+ *
+ *	%SOME = time(SOME) / period
+ *	%FULL = time(FULL) / period
+ *
+ *			Multiple CPUs
+ *
+ * The more tasks and available CPUs there are, the more work can be
+ * performed concurrently. This means that the potential that can go
+ * unrealized due to resource contention *also* scales with non-idle
+ * tasks and CPUs.
+ *
+ * Consider a scenario where 257 number crunching tasks are trying to
+ * run concurrently on 256 CPUs. If we simply aggregated the task
+ * states, we would have to conclude a CPU SOME pressure number of
+ * 100%, since *somebody* is waiting on a runqueue at all
+ * times. However, that is clearly not the amount of contention the
+ * workload is experiencing: only one out of 256 possible exceution
+ * threads will be contended at any given time, or about 0.4%.
+ *
+ * Conversely, consider a scenario of 4 tasks and 4 CPUs where at any
+ * given time *one* of the tasks is delayed due to a lack of memory.
+ * Again, looking purely at the task state would yield a memory FULL
+ * pressure number of 0%, since *somebody* is always making forward
+ * progress. But again this wouldn't capture the amount of execution
+ * potential lost, which is 1 out of 4 CPUs, or 25%.
+ *
+ * To calculate wasted potential (pressure) with multiple processors,
+ * we have to base our calculation on the number of non-idle tasks in
+ * conjunction with the number of available CPUs, which is the number
+ * of potential execution threads. SOME becomes then the proportion of
+ * delayed tasks to possibe threads, and FULL is the share of possible
+ * threads that are unproductive due to delays:
+ *
+ *	threads = min(nr_nonidle_tasks, nr_cpus)
+ *	   SOME = min(nr_delayed_tasks / threads, 1)
+ *	   FULL = (threads - min(nr_running_tasks, threads)) / threads
+ *
+ * For the 257 number crunchers on 256 CPUs, this yields:
+ *
+ *	threads = min(257, 256)
+ *	   SOME = min(1 / 256, 1)             = 0.4%
+ *	   FULL = (256 - min(257, 256)) / 256 = 0%
+ *
+ * For the 1 out of 4 memory-delayed tasks, this yields:
+ *
+ *	threads = min(4, 4)
+ *	   SOME = min(1 / 4, 1)               = 25%
+ *	   FULL = (4 - min(3, 4)) / 4         = 25%
+ *
+ * [ Substitute nr_cpus with 1, and you can see that it's a natural
+ *   extension of the single-CPU model. ]
+ *
+ *			Implementation
+ *
+ * To assess the precise time spent in each such state, we would have
+ * to freeze the system on task changes and start/stop the state
+ * clocks accordingly. Obviously that doesn't scale in practice.
+ *
+ * Because the scheduler aims to distribute the compute load evenly
+ * among the available CPUs, we can track task state locally to each
+ * CPU and, at much lower frequency, extrapolate the global state for
+ * the cumulative stall times and the running averages.
+ *
+ * For each runqueue, we track:
+ *
+ *	   tSOME[cpu] = time(nr_delayed_tasks[cpu] != 0)
+ *	   tFULL[cpu] = time(nr_delayed_tasks[cpu] && !nr_running_tasks[cpu])
+ *	tNONIDLE[cpu] = time(nr_nonidle_tasks[cpu] != 0)
+ *
+ * and then periodically aggregate:
+ *
+ *	tNONIDLE = sum(tNONIDLE[i])
+ *
+ *	   tSOME = sum(tSOME[i] * tNONIDLE[i]) / tNONIDLE
+ *	   tFULL = sum(tFULL[i] * tNONIDLE[i]) / tNONIDLE
+ *
+ *	   %SOME = tSOME / period
+ *	   %FULL = tFULL / period
+ *
+ * This gives us an approximation of pressure that is practical
+ * cost-wise, yet way more sensitive and accurate than periodic
+ * sampling of the aggregate task states would be.
+ */
+
+#include <linux/sched/loadavg.h>
+#include <linux/seq_file.h>
+#include <linux/proc_fs.h>
+#include <linux/cgroup.h>
+#include <linux/module.h>
+#include <linux/sched.h>
+#include <linux/psi.h>
+#include "sched.h"
+
+static int psi_bug __read_mostly;
+
+bool psi_disabled __read_mostly;
+core_param(psi_disabled, psi_disabled, bool, 0644);
+
+/* Running averages - we need to be higher-res than loadavg */
+#define PSI_FREQ	(2*HZ+1)	/* 2 sec intervals */
+#define EXP_10s		1677		/* 1/exp(2s/10s) as fixed-point */
+#define EXP_60s		1981		/* 1/exp(2s/60s) */
+#define EXP_300s	2034		/* 1/exp(2s/300s) */
+
+/* Sampling frequency in nanoseconds */
+static u64 psi_period __read_mostly;
+
+/* System-level pressure and stall tracking */
+static DEFINE_PER_CPU(struct psi_group_cpu, system_group_cpus);
+static struct psi_group psi_system = {
+	.cpus = &system_group_cpus,
+};
+
+static void psi_clock(struct work_struct *work);
+
+static void psi_group_init(struct psi_group *group)
+{
+	group->period_expires = jiffies + PSI_FREQ;
+	INIT_DELAYED_WORK(&group->clock_work, psi_clock);
+	mutex_init(&group->stat_lock);
+}
+
+void __init psi_init(void)
+{
+	if (psi_disabled)
+		return;
+
+	psi_period = jiffies_to_nsecs(PSI_FREQ);
+	psi_group_init(&psi_system);
+}
+
+static void calc_avgs(unsigned long avg[3], u64 time, int missed_periods)
+{
+	unsigned long pct;
+
+	/* Sample the most recent active period */
+	pct = time * 100 / psi_period;
+	pct *= FIXED_1;
+	avg[0] = calc_load(avg[0], EXP_10s, pct);
+	avg[1] = calc_load(avg[1], EXP_60s, pct);
+	avg[2] = calc_load(avg[2], EXP_300s, pct);
+
+	/* Fill in zeroes for periods of no activity */
+	if (missed_periods) {
+		avg[0] = calc_load_n(avg[0], EXP_10s, 0, missed_periods);
+		avg[1] = calc_load_n(avg[1], EXP_60s, 0, missed_periods);
+		avg[2] = calc_load_n(avg[2], EXP_300s, 0, missed_periods);
+	}
+}
+
+static bool psi_update_stats(struct psi_group *group)
+{
+	u64 some[NR_PSI_RESOURCES] = { 0, };
+	u64 full[NR_PSI_RESOURCES] = { 0, };
+	unsigned long nonidle_total = 0;
+	unsigned long missed_periods;
+	unsigned long expires;
+	int cpu;
+	int r;
+
+	mutex_lock(&group->stat_lock);
+
+	/*
+	 * Collect the per-cpu time buckets and average them into a
+	 * single time sample that is normalized to wallclock time.
+	 *
+	 * For averaging, each CPU is weighted by its non-idle time in
+	 * the sampling period. This eliminates artifacts from uneven
+	 * loading, or even entirely idle CPUs.
+	 *
+	 * We could pin the online CPUs here, but the noise introduced
+	 * by missing up to one sample period from CPUs that are going
+	 * away shouldn't matter in practice - just like the noise of
+	 * previously offlined CPUs returning with a non-zero sample.
+	 */
+	for_each_online_cpu(cpu) {
+		struct psi_group_cpu *groupc = per_cpu_ptr(group->cpus, cpu);
+		unsigned long nonidle;
+
+		if (!groupc->nonidle_time)
+			continue;
+
+		nonidle = nsecs_to_jiffies(groupc->nonidle_time);
+		groupc->nonidle_time = 0;
+		nonidle_total += nonidle;
+
+		for (r = 0; r < NR_PSI_RESOURCES; r++) {
+			struct psi_resource *res = &groupc->res[r];
+
+			some[r] += (res->times[0] + res->times[1]) * nonidle;
+			full[r] += res->times[1] * nonidle;
+
+			/* It's racy, but we can tolerate some error */
+			res->times[0] = 0;
+			res->times[1] = 0;
+		}
+	}
+
+	/*
+	 * Integrate the sample into the running statistics that are
+	 * reported to userspace: the cumulative stall times and the
+	 * decaying averages.
+	 *
+	 * Pressure percentages are sampled at PSI_FREQ. We might be
+	 * called more often when the user polls more frequently than
+	 * that; we might be called less often when there is no task
+	 * activity, thus no data, and clock ticks are sporadic. The
+	 * below handles both.
+	 */
+
+	/* total= */
+	for (r = 0; r < NR_PSI_RESOURCES; r++) {
+		do_div(some[r], max(nonidle_total, 1UL));
+		do_div(full[r], max(nonidle_total, 1UL));
+
+		group->some[r] += some[r];
+		group->full[r] += full[r];
+	}
+
+	/* avgX= */
+	expires = group->period_expires;
+	if (time_before(jiffies, expires))
+		goto out;
+
+	missed_periods = (jiffies - expires) / PSI_FREQ;
+	group->period_expires = expires + ((1 + missed_periods) * PSI_FREQ);
+
+	for (r = 0; r < NR_PSI_RESOURCES; r++) {
+		u64 some, full;
+
+		some = group->some[r] - group->last_some[r];
+		full = group->full[r] - group->last_full[r];
+
+		calc_avgs(group->avg_some[r], some, missed_periods);
+		calc_avgs(group->avg_full[r], full, missed_periods);
+
+		group->last_some[r] = group->some[r];
+		group->last_full[r] = group->full[r];
+	}
+out:
+	mutex_unlock(&group->stat_lock);
+	return nonidle_total;
+}
+
+static void psi_clock(struct work_struct *work)
+{
+	struct delayed_work *dwork;
+	struct psi_group *group;
+	bool nonidle;
+
+	dwork = to_delayed_work(work);
+	group = container_of(dwork, struct psi_group, clock_work);
+
+	/*
+	 * If there is task activity, periodically fold the per-cpu
+	 * times and feed samples into the running averages. If things
+	 * are idle and there is no data to process, stop the clock.
+	 * Once restarted, we'll catch up the running averages in one
+	 * go - see calc_avgs() and missed_periods.
+	 */
+
+	nonidle = psi_update_stats(group);
+
+	if (nonidle) {
+		unsigned long delay = 0;
+		unsigned long now;
+
+		now = READ_ONCE(jiffies);
+		if (time_after(group->period_expires, now))
+			delay = group->period_expires - now;
+		schedule_delayed_work(dwork, delay);
+	}
+}
+
+static void time_state(struct psi_resource *res, int state, u64 now)
+{
+	if (res->state != PSI_NONE) {
+		bool was_full = res->state == PSI_FULL;
+
+		res->times[was_full] += now - res->state_start;
+	}
+	if (res->state != state)
+		res->state = state;
+	if (res->state != PSI_NONE)
+		res->state_start = now;
+}
+
+static void psi_group_change(struct psi_group *group, int cpu, u64 now,
+			     unsigned int clear, unsigned int set)
+{
+	enum psi_state state = PSI_NONE;
+	struct psi_group_cpu *groupc;
+	unsigned int *tasks;
+	unsigned int to, bo;
+
+	groupc = per_cpu_ptr(group->cpus, cpu);
+	tasks = groupc->tasks;
+
+	/* Update task counts according to the set/clear bitmasks */
+	for (to = 0; (bo = ffs(clear)); to += bo, clear >>= bo) {
+		int idx = to + (bo - 1);
+
+		if (tasks[idx] == 0 && !psi_bug) {
+			printk_deferred(KERN_ERR "psi: task underflow! cpu=%d idx=%d tasks=[%u %u %u] clear=%x set=%x\n",
+					cpu, idx, tasks[0], tasks[1], tasks[2],
+					clear, set);
+			psi_bug = 1;
+		}
+		tasks[idx]--;
+	}
+	for (to = 0; (bo = ffs(set)); to += bo, set >>= bo)
+		tasks[to + (bo - 1)]++;
+
+	/* Time in which tasks wait for the CPU */
+	state = PSI_NONE;
+	if (tasks[NR_RUNNING] > 1)
+		state = PSI_SOME;
+	time_state(&groupc->res[PSI_CPU], state, now);
+
+	/* Time in which tasks wait for memory */
+	state = PSI_NONE;
+	if (tasks[NR_MEMSTALL]) {
+		if (!tasks[NR_RUNNING] ||
+		    (cpu_curr(cpu)->flags & PF_MEMSTALL))
+			state = PSI_FULL;
+		else
+			state = PSI_SOME;
+	}
+	time_state(&groupc->res[PSI_MEM], state, now);
+
+	/* Time in which tasks wait for IO */
+	state = PSI_NONE;
+	if (tasks[NR_IOWAIT]) {
+		if (!tasks[NR_RUNNING])
+			state = PSI_FULL;
+		else
+			state = PSI_SOME;
+	}
+	time_state(&groupc->res[PSI_IO], state, now);
+
+	/* Time in which tasks are non-idle, to weigh the CPU in summaries */
+	if (groupc->nonidle)
+		groupc->nonidle_time += now - groupc->nonidle_start;
+	groupc->nonidle = tasks[NR_RUNNING] ||
+		tasks[NR_IOWAIT] || tasks[NR_MEMSTALL];
+	if (groupc->nonidle)
+		groupc->nonidle_start = now;
+
+	/* Kick the stats aggregation worker if it's gone to sleep */
+	if (!delayed_work_pending(&group->clock_work))
+		schedule_delayed_work(&group->clock_work, PSI_FREQ);
+}
+
+void psi_task_change(struct task_struct *task, u64 now, int clear, int set)
+{
+	int cpu = task_cpu(task);
+
+	if (psi_disabled)
+		return;
+
+	if (!task->pid)
+		return;
+
+	if (((task->psi_flags & set) ||
+	     (task->psi_flags & clear) != clear) &&
+	    !psi_bug) {
+		printk_deferred(KERN_ERR "psi: inconsistent task state! task=%d:%s cpu=%d psi_flags=%x clear=%x set=%x\n",
+				task->pid, task->comm, cpu,
+				task->psi_flags, clear, set);
+		psi_bug = 1;
+	}
+
+	task->psi_flags &= ~clear;
+	task->psi_flags |= set;
+
+	psi_group_change(&psi_system, cpu, now, clear, set);
+}
+
+/**
+ * psi_memstall_enter - mark the beginning of a memory stall section
+ * @flags: flags to handle nested sections
+ *
+ * Marks the calling task as being stalled due to a lack of memory,
+ * such as waiting for a refault or performing reclaim.
+ */
+void psi_memstall_enter(unsigned long *flags)
+{
+	struct rq_flags rf;
+	struct rq *rq;
+
+	if (psi_disabled)
+		return;
+
+	*flags = current->flags & PF_MEMSTALL;
+	if (*flags)
+		return;
+	/*
+	 * PF_MEMSTALL setting & accounting needs to be atomic wrt
+	 * changes to the task's scheduling state, otherwise we can
+	 * race with CPU migration.
+	 */
+	rq = this_rq_lock_irq(&rf);
+
+	update_rq_clock(rq);
+
+	current->flags |= PF_MEMSTALL;
+	psi_task_change(current, rq_clock(rq), 0, TSK_MEMSTALL);
+
+	rq_unlock_irq(rq, &rf);
+}
+
+/**
+ * psi_memstall_leave - mark the end of an memory stall section
+ * @flags: flags to handle nested memdelay sections
+ *
+ * Marks the calling task as no longer stalled due to lack of memory.
+ */
+void psi_memstall_leave(unsigned long *flags)
+{
+	struct rq_flags rf;
+	struct rq *rq;
+
+	if (psi_disabled)
+		return;
+
+	if (*flags)
+		return;
+	/*
+	 * PF_MEMSTALL clearing & accounting needs to be atomic wrt
+	 * changes to the task's scheduling state, otherwise we could
+	 * race with CPU migration.
+	 */
+	rq = this_rq_lock_irq(&rf);
+
+	update_rq_clock(rq);
+
+	current->flags &= ~PF_MEMSTALL;
+	psi_task_change(current, rq_clock(rq), TSK_MEMSTALL, 0);
+
+	rq_unlock_irq(rq, &rf);
+}
+
+static int psi_show(struct seq_file *m, struct psi_group *group,
+		    enum psi_res res)
+{
+	unsigned long avg[2][3];
+	u64 some, full;
+	int w;
+
+	if (psi_disabled)
+		return -EOPNOTSUPP;
+
+	psi_update_stats(group);
+
+	for (w = 0; w < 3; w++) {
+		avg[0][w] = group->avg_some[res][w];
+		avg[1][w] = group->avg_full[res][w];
+	}
+
+	some = group->some[res];
+	do_div(some, NSEC_PER_USEC);
+
+	seq_printf(m, "some avg10=%lu.%02lu avg60=%lu.%02lu avg300=%lu.%02lu total=%llu\n",
+		   LOAD_INT(avg[0][0]), LOAD_FRAC(avg[0][0]),
+		   LOAD_INT(avg[0][1]), LOAD_FRAC(avg[0][1]),
+		   LOAD_INT(avg[0][2]), LOAD_FRAC(avg[0][2]),
+		   some);
+
+	if (res == PSI_CPU)
+                return 0;
+
+	full = group->full[res];
+	do_div(full, NSEC_PER_USEC);
+
+	seq_printf(m, "full avg10=%lu.%02lu avg60=%lu.%02lu avg300=%lu.%02lu total=%llu\n",
+		   LOAD_INT(avg[1][0]), LOAD_FRAC(avg[1][0]),
+		   LOAD_INT(avg[1][1]), LOAD_FRAC(avg[1][1]),
+		   LOAD_INT(avg[1][2]), LOAD_FRAC(avg[1][2]),
+		   full);
+
+	return 0;
+}
+
+static int psi_cpu_show(struct seq_file *m, void *v)
+{
+	return psi_show(m, &psi_system, PSI_CPU);
+}
+
+static int psi_memory_show(struct seq_file *m, void *v)
+{
+	return psi_show(m, &psi_system, PSI_MEM);
+}
+
+static int psi_io_show(struct seq_file *m, void *v)
+{
+	return psi_show(m, &psi_system, PSI_IO);
+}
+
+static int psi_cpu_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, psi_cpu_show, NULL);
+}
+
+static int psi_memory_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, psi_memory_show, NULL);
+}
+
+static int psi_io_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, psi_io_show, NULL);
+}
+
+static const struct file_operations psi_cpu_fops = {
+	.open           = psi_cpu_open,
+	.read           = seq_read,
+	.llseek         = seq_lseek,
+	.release        = single_release,
+};
+
+static const struct file_operations psi_memory_fops = {
+	.open           = psi_memory_open,
+	.read           = seq_read,
+	.llseek         = seq_lseek,
+	.release        = single_release,
+};
+
+static const struct file_operations psi_io_fops = {
+	.open           = psi_io_open,
+	.read           = seq_read,
+	.llseek         = seq_lseek,
+	.release        = single_release,
+};
+
+static int __init psi_proc_init(void)
+{
+	proc_mkdir("pressure", NULL);
+	proc_create("pressure/cpu", 0, NULL, &psi_cpu_fops);
+	proc_create("pressure/memory", 0, NULL, &psi_memory_fops);
+	proc_create("pressure/io", 0, NULL, &psi_io_fops);
+	return 0;
+}
+module_init(psi_proc_init);
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index bc798c7cb4d4..e798491ff329 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -54,6 +54,7 @@
 #include <linux/proc_fs.h>
 #include <linux/prefetch.h>
 #include <linux/profile.h>
+#include <linux/psi.h>
 #include <linux/rcupdate_wait.h>
 #include <linux/security.h>
 #include <linux/stackprotector.h>
@@ -320,6 +321,7 @@ extern bool dl_cpu_busy(unsigned int cpu);
 #ifdef CONFIG_CGROUP_SCHED
 
 #include <linux/cgroup.h>
+#include <linux/psi.h>
 
 struct cfs_rq;
 struct rt_rq;
diff --git a/kernel/sched/stats.h b/kernel/sched/stats.h
index 8aea199a39b4..15b858cbbcb0 100644
--- a/kernel/sched/stats.h
+++ b/kernel/sched/stats.h
@@ -55,25 +55,111 @@ static inline void rq_sched_info_depart  (struct rq *rq, unsigned long long delt
 # define   schedstat_val_or_zero(var)	0
 #endif /* CONFIG_SCHEDSTATS */
 
+#ifdef CONFIG_PSI
+/*
+ * PSI tracks state that persists across sleeps, such as iowaits and
+ * memory stalls. As a result, it has to distinguish between sleeps,
+ * where a task's runnable state changes, and requeues, where a task
+ * and its state are being moved between CPUs and runqueues.
+ */
+static inline void psi_enqueue(struct task_struct *p, u64 now, bool wakeup)
+{
+	int clear = 0, set = TSK_RUNNING;
+
+	if (psi_disabled)
+		return;
+
+	if (!wakeup || p->sched_psi_wake_requeue) {
+		if (p->flags & PF_MEMSTALL)
+			set |= TSK_MEMSTALL;
+		if (p->sched_psi_wake_requeue)
+			p->sched_psi_wake_requeue = 0;
+	} else {
+		if (p->in_iowait)
+			clear |= TSK_IOWAIT;
+	}
+
+	psi_task_change(p, now, clear, set);
+}
+
+static inline void psi_dequeue(struct task_struct *p, u64 now, bool sleep)
+{
+	int clear = TSK_RUNNING, set = 0;
+
+	if (psi_disabled)
+		return;
+
+	if (!sleep) {
+		if (p->flags & PF_MEMSTALL)
+			clear |= TSK_MEMSTALL;
+	} else {
+		if (p->in_iowait)
+			set |= TSK_IOWAIT;
+	}
+
+	psi_task_change(p, now, clear, set);
+}
+
+static inline void psi_ttwu_dequeue(struct task_struct *p)
+{
+	if (psi_disabled)
+		return;
+	/*
+	 * Is the task being migrated during a wakeup? Make sure to
+	 * deregister its sleep-persistent psi states from the old
+	 * queue, and let psi_enqueue() know it has to requeue.
+	 */
+	if (unlikely(p->in_iowait || (p->flags & PF_MEMSTALL))) {
+		struct rq_flags rf;
+		struct rq *rq;
+		int clear = 0;
+
+		if (p->in_iowait)
+			clear |= TSK_IOWAIT;
+		if (p->flags & PF_MEMSTALL)
+			clear |= TSK_MEMSTALL;
+
+		rq = __task_rq_lock(p, &rf);
+		update_rq_clock(rq);
+		psi_task_change(p, rq_clock(rq), clear, 0);
+		p->sched_psi_wake_requeue = 1;
+		__task_rq_unlock(rq, &rf);
+	}
+}
+#else /* CONFIG_PSI */
+static inline void psi_enqueue(struct task_struct *p, u64 now, bool wakeup) {}
+static inline void psi_dequeue(struct task_struct *p, u64 now, bool sleep) {}
+static inline void psi_ttwu_dequeue(struct task_struct *p) {}
+#endif /* CONFIG_PSI */
+
 #ifdef CONFIG_SCHED_INFO
 static inline void sched_info_reset_dequeued(struct task_struct *t)
 {
 	t->sched_info.last_queued = 0;
 }
 
+static inline void sched_info_reset_queued(struct task_struct *t, u64 now)
+{
+	if (!t->sched_info.last_queued)
+		t->sched_info.last_queued = now;
+}
+
 /*
  * We are interested in knowing how long it was from the *first* time a
  * task was queued to the time that it finally hit a CPU, we call this routine
  * from dequeue_task() to account for possible rq->clock skew across CPUs. The
  * delta taken on each CPU would annul the skew.
  */
-static inline void sched_info_dequeued(struct rq *rq, struct task_struct *t)
+static inline void sched_info_dequeued(struct rq *rq, struct task_struct *t,
+				       bool sleep)
 {
 	unsigned long long now = rq_clock(rq), delta = 0;
 
-	if (unlikely(sched_info_on()))
+	if (unlikely(sched_info_on())) {
 		if (t->sched_info.last_queued)
 			delta = now - t->sched_info.last_queued;
+		psi_dequeue(t, now, sleep);
+	}
 	sched_info_reset_dequeued(t);
 	t->sched_info.run_delay += delta;
 
@@ -104,11 +190,14 @@ static void sched_info_arrive(struct rq *rq, struct task_struct *t)
  * the timestamp if it is already not set.  It's assumed that
  * sched_info_dequeued() will clear that stamp when appropriate.
  */
-static inline void sched_info_queued(struct rq *rq, struct task_struct *t)
+static inline void sched_info_queued(struct rq *rq, struct task_struct *t,
+				     bool wakeup)
 {
 	if (unlikely(sched_info_on())) {
-		if (!t->sched_info.last_queued)
-			t->sched_info.last_queued = rq_clock(rq);
+		unsigned long long now = rq_clock(rq);
+
+		sched_info_reset_queued(t, now);
+		psi_enqueue(t, now, wakeup);
 	}
 }
 
@@ -127,7 +216,8 @@ static inline void sched_info_depart(struct rq *rq, struct task_struct *t)
 	rq_sched_info_depart(rq, delta);
 
 	if (t->state == TASK_RUNNING)
-		sched_info_queued(rq, t);
+		if (unlikely(sched_info_on()))
+			sched_info_reset_queued(t, rq_clock(rq));
 }
 
 /*
diff --git a/mm/compaction.c b/mm/compaction.c
index 29bd1df18b98..8f9566745902 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -22,6 +22,7 @@
 #include <linux/kthread.h>
 #include <linux/freezer.h>
 #include <linux/page_owner.h>
+#include <linux/psi.h>
 #include "internal.h"
 
 #ifdef CONFIG_COMPACTION
@@ -2068,11 +2069,15 @@ static int kcompactd(void *p)
 	pgdat->kcompactd_classzone_idx = pgdat->nr_zones - 1;
 
 	while (!kthread_should_stop()) {
+		unsigned long pflags;
+
 		trace_mm_compaction_kcompactd_sleep(pgdat->node_id);
 		wait_event_freezable(pgdat->kcompactd_wait,
 				kcompactd_work_requested(pgdat));
 
+		psi_memstall_enter(&pflags);
 		kcompactd_do_work(pgdat);
+		psi_memstall_leave(&pflags);
 	}
 
 	return 0;
diff --git a/mm/filemap.c b/mm/filemap.c
index e49961e13dd9..eee06145b997 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -37,6 +37,7 @@
 #include <linux/shmem_fs.h>
 #include <linux/rmap.h>
 #include <linux/delayacct.h>
+#include <linux/psi.h>
 #include "internal.h"
 
 #define CREATE_TRACE_POINTS
@@ -1075,11 +1076,14 @@ static inline int wait_on_page_bit_common(wait_queue_head_t *q,
 	struct wait_page_queue wait_page;
 	wait_queue_entry_t *wait = &wait_page.wait;
 	bool thrashing = false;
+	unsigned long pflags;
 	int ret = 0;
 
-	if (bit_nr == PG_locked && !PageSwapBacked(page) &&
+	if (bit_nr == PG_locked &&
 	    !PageUptodate(page) && PageWorkingset(page)) {
-		delayacct_thrashing_start();
+		if (!PageSwapBacked(page))
+			delayacct_thrashing_start();
+		psi_memstall_enter(&pflags);
 		thrashing = true;
 	}
 
@@ -1121,8 +1125,11 @@ static inline int wait_on_page_bit_common(wait_queue_head_t *q,
 
 	finish_wait(q, wait);
 
-	if (thrashing)
-		delayacct_thrashing_end();
+	if (thrashing) {
+		if (!PageSwapBacked(page))
+			delayacct_thrashing_end();
+		psi_memstall_leave(&pflags);
+	}
 
 	/*
 	 * A signal could leave PageWaiters set. Clearing it here if
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 22320ea27489..8469f34e6731 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -67,6 +67,7 @@
 #include <linux/ftrace.h>
 #include <linux/lockdep.h>
 #include <linux/nmi.h>
+#include <linux/psi.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -3552,15 +3553,20 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		enum compact_priority prio, enum compact_result *compact_result)
 {
 	struct page *page;
+	unsigned long pflags;
 	unsigned int noreclaim_flag;
 
 	if (!order)
 		return NULL;
 
+	psi_memstall_enter(&pflags);
 	noreclaim_flag = memalloc_noreclaim_save();
+
 	*compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
 									prio);
+
 	memalloc_noreclaim_restore(noreclaim_flag);
+	psi_memstall_leave(&pflags);
 
 	if (*compact_result <= COMPACT_INACTIVE)
 		return NULL;
@@ -3749,11 +3755,14 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 	struct reclaim_state reclaim_state;
 	int progress;
 	unsigned int noreclaim_flag;
+	unsigned long pflags;
 
 	cond_resched();
 
 	/* We now go into synchronous reclaim */
 	cpuset_memory_pressure_bump();
+
+	psi_memstall_enter(&pflags);
 	noreclaim_flag = memalloc_noreclaim_save();
 	fs_reclaim_acquire(gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
@@ -3765,6 +3774,7 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 	current->reclaim_state = NULL;
 	fs_reclaim_release(gfp_mask);
 	memalloc_noreclaim_restore(noreclaim_flag);
+	psi_memstall_leave(&pflags);
 
 	cond_resched();
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8d1ad48ffbcd..ee91e8cbeb5a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -49,6 +49,7 @@
 #include <linux/prefetch.h>
 #include <linux/printk.h>
 #include <linux/dax.h>
+#include <linux/psi.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -3115,6 +3116,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 {
 	struct zonelist *zonelist;
 	unsigned long nr_reclaimed;
+	unsigned long pflags;
 	int nid;
 	unsigned int noreclaim_flag;
 	struct scan_control sc = {
@@ -3143,9 +3145,13 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 					    sc.gfp_mask,
 					    sc.reclaim_idx);
 
+	psi_memstall_enter(&pflags);
 	noreclaim_flag = memalloc_noreclaim_save();
+
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
+
 	memalloc_noreclaim_restore(noreclaim_flag);
+	psi_memstall_leave(&pflags);
 
 	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
 
@@ -3565,6 +3571,7 @@ static int kswapd(void *p)
 	pgdat->kswapd_order = 0;
 	pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
 	for ( ; ; ) {
+		unsigned long pflags;
 		bool ret;
 
 		alloc_order = reclaim_order = pgdat->kswapd_order;
@@ -3601,9 +3608,15 @@ static int kswapd(void *p)
 		 */
 		trace_mm_vmscan_kswapd_wake(pgdat->node_id, classzone_idx,
 						alloc_order);
+
+		psi_memstall_enter(&pflags);
 		fs_reclaim_acquire(GFP_KERNEL);
+
 		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx);
+
 		fs_reclaim_release(GFP_KERNEL);
+		psi_memstall_leave(&pflags);
+
 		if (reclaim_order < alloc_order)
 			goto kswapd_try_sleep;
 	}
-- 
2.18.0
