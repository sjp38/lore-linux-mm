Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 465D76B0270
	for <linux-mm@kvack.org>; Mon,  7 May 2018 17:00:19 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w14-v6so19964372wrk.22
        for <linux-mm@kvack.org>; Mon, 07 May 2018 14:00:19 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l6-v6si6487296eda.121.2018.05.07.14.00.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 07 May 2018 14:00:16 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 6/7] psi: pressure stall information for CPU, memory, and IO
Date: Mon,  7 May 2018 17:01:34 -0400
Message-Id: <20180507210135.1823-7-hannes@cmpxchg.org>
In-Reply-To: <20180507210135.1823-1-hannes@cmpxchg.org>
References: <20180507210135.1823-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

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

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/accounting/psi.txt |  73 ++++++
 include/linux/psi.h              |  27 ++
 include/linux/psi_types.h        |  84 ++++++
 include/linux/sched.h            |  10 +
 include/linux/sched/stat.h       |  10 +-
 init/Kconfig                     |  16 ++
 kernel/fork.c                    |   4 +
 kernel/sched/Makefile            |   1 +
 kernel/sched/core.c              |   3 +
 kernel/sched/psi.c               | 424 +++++++++++++++++++++++++++++++
 kernel/sched/sched.h             | 166 ++++++------
 kernel/sched/stats.h             |  91 ++++++-
 mm/compaction.c                  |   5 +
 mm/filemap.c                     |  15 +-
 mm/page_alloc.c                  |  10 +
 mm/vmscan.c                      |  13 +
 16 files changed, 859 insertions(+), 93 deletions(-)
 create mode 100644 Documentation/accounting/psi.txt
 create mode 100644 include/linux/psi.h
 create mode 100644 include/linux/psi_types.h
 create mode 100644 kernel/sched/psi.c

diff --git a/Documentation/accounting/psi.txt b/Documentation/accounting/psi.txt
new file mode 100644
index 000000000000..e051810d5127
--- /dev/null
+++ b/Documentation/accounting/psi.txt
@@ -0,0 +1,73 @@
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
+
+Cgroup2 interface
+=================
+
+In a system with a CONFIG_CGROUP=y kernel and the cgroup2 filesystem
+mounted, pressure stall information is also tracked for tasks grouped
+into cgroups. Each subdirectory in the cgroupfs mountpoint contains
+cpu.pressure, memory.pressure, and io.pressure files; the format is
+the same as the /proc/pressure/ files.
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
index 000000000000..b22b0ffc729d
--- /dev/null
+++ b/include/linux/psi_types.h
@@ -0,0 +1,84 @@
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
+	/* Start of current state (cpu_clock) */
+	u64 state_start;
+
+	/* Time sampling buckets for pressure states (ns) */
+	u64 times[NR_PSI_STATES - 1];
+};
+
+struct psi_group_cpu {
+	/* States of the tasks belonging to this group */
+	unsigned int tasks[NR_PSI_TASK_COUNTS];
+
+	/* Per-resource pressure tracking in this group */
+	struct psi_resource res[NR_PSI_RESOURCES];
+
+	/* There are runnable or D-state tasks */
+	bool nonidle;
+
+	/* Start of current non-idle state (cpu_clock) */
+	u64 nonidle_start;
+
+	/* Time sampling bucket for non-idle state (ns) */
+	u64 nonidle_time;
+};
+
+struct psi_group {
+	struct psi_group_cpu *cpus;
+
+	struct delayed_work clock_work;
+	unsigned long period_expires;
+
+	u64 some[NR_PSI_RESOURCES];
+	u64 full[NR_PSI_RESOURCES];
+
+	unsigned long avg_some[NR_PSI_RESOURCES][3];
+	unsigned long avg_full[NR_PSI_RESOURCES][3];
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
index b3d697f3b573..d854652f9603 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -25,6 +25,7 @@
 #include <linux/latencytop.h>
 #include <linux/sched/prio.h>
 #include <linux/signal_types.h>
+#include <linux/psi_types.h>
 #include <linux/mm_types_task.h>
 #include <linux/task_io_accounting.h>
 
@@ -669,6 +670,10 @@ struct task_struct {
 	unsigned			sched_contributes_to_load:1;
 	unsigned			sched_migrated:1;
 	unsigned			sched_remote_wakeup:1;
+#ifdef CONFIG_PSI
+	unsigned			sched_psi_wake_requeue:1;
+#endif
+
 	/* Force alignment to the next boundary: */
 	unsigned			:0;
 
@@ -916,6 +921,10 @@ struct task_struct {
 	siginfo_t			*last_siginfo;
 
 	struct task_io_accounting	ioac;
+#ifdef CONFIG_PSI
+	/* Pressure stall state */
+	unsigned int			psi_flags;
+#endif
 #ifdef CONFIG_TASK_XACCT
 	/* Accumulated RSS usage: */
 	u64				acct_rss_mem1;
@@ -1345,6 +1354,7 @@ extern struct pid *cad_pid;
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
index f013afc74b11..36208c2a386c 100644
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
index 5e10aaeebfcc..e663333ec6fb 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -2038,6 +2038,7 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
 	cpu = select_task_rq(p, p->wake_cpu, SD_BALANCE_WAKE, wake_flags);
 	if (task_cpu(p) != cpu) {
 		wake_flags |= WF_MIGRATED;
+		psi_ttwu_dequeue(p);
 		set_task_cpu(p, cpu);
 	}
 
@@ -6113,6 +6114,8 @@ void __init sched_init(void)
 
 	init_schedstats();
 
+	psi_init();
+
 	scheduler_running = 1;
 }
 
diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
new file mode 100644
index 000000000000..052c529a053b
--- /dev/null
+++ b/kernel/sched/psi.c
@@ -0,0 +1,424 @@
+/*
+ * Measure workload productivity impact from overcommitting CPU, memory, IO
+ *
+ * Copyright (c) 2017 Facebook, Inc.
+ * Author: Johannes Weiner <hannes@cmpxchg.org>
+ *
+ * Implementation
+ *
+ * Task states -- running, iowait, memstall -- are tracked through the
+ * scheduler and aggregated into a system-wide productivity state. The
+ * ratio between the times spent in productive states and delays tells
+ * us the overall productivity of the workload.
+ *
+ * The ratio is tracked in decaying time averages over 10s, 1m, 5m
+ * windows. Cumluative stall times are tracked and exported as well to
+ * allow detection of latency spikes and custom time averaging.
+ *
+ * Multiple CPUs
+ *
+ * To avoid cache contention, times are tracked local to the CPUs. To
+ * get a comprehensive view of a system or cgroup, we have to consider
+ * the fact that CPUs could be unevenly loaded or even entirely idle
+ * if the workload doesn't have enough threads. To avoid artifacts
+ * caused by that, when adding up the global pressure ratio, the
+ * CPU-local ratios are weighed according to their non-idle time:
+ *
+ *   Time the CPU had stalled tasks    Time the CPU was non-idle
+ *   ------------------------------ * ---------------------------
+ *                Walltime            Time all CPUs were non-idle
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
+#define MY_LOAD_FREQ	(2*HZ+1)	/* 2 sec intervals */
+#define EXP_10s		1677		/* 1/exp(2s/10s) as fixed-point */
+#define EXP_60s		1981		/* 1/exp(2s/60s) */
+#define EXP_300s	2034		/* 1/exp(2s/300s) */
+
+/* Load frequency in nanoseconds */
+static u64 load_period __read_mostly;
+
+/* System-level pressure tracking */
+static DEFINE_PER_CPU(struct psi_group_cpu, system_group_cpus);
+static struct psi_group psi_system = {
+	.cpus = &system_group_cpus,
+};
+
+static void psi_clock(struct work_struct *work);
+
+static void psi_group_init(struct psi_group *group)
+{
+	group->period_expires = jiffies + MY_LOAD_FREQ;
+	INIT_DELAYED_WORK(&group->clock_work, psi_clock);
+}
+
+void __init psi_init(void)
+{
+	load_period = jiffies_to_nsecs(MY_LOAD_FREQ);
+	psi_group_init(&psi_system);
+}
+
+static void calc_avgs(unsigned long avg[3], u64 time, int missed_periods)
+{
+	unsigned long pct;
+
+	/* Sample the most recent active period */
+	pct = time * 100 / load_period;
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
+static void psi_clock(struct work_struct *work)
+{
+	u64 some[NR_PSI_RESOURCES] = { 0, };
+	u64 full[NR_PSI_RESOURCES] = { 0, };
+	unsigned long nonidle_total = 0;
+	unsigned long missed_periods;
+	struct delayed_work *dwork;
+	struct psi_group *group;
+	unsigned long expires;
+	int cpu;
+	int r;
+
+	dwork = to_delayed_work(work);
+	group = container_of(dwork, struct psi_group, clock_work);
+
+	/*
+	 * Calculate the sampling period. The clock might have been
+	 * stopped for a while.
+	 */
+	expires = group->period_expires;
+	missed_periods = (jiffies - expires) / MY_LOAD_FREQ;
+	group->period_expires = expires + ((1 + missed_periods) * MY_LOAD_FREQ);
+
+	/*
+	 * Aggregate the per-cpu state into a global state. Each CPU
+	 * is weighted by its non-idle time in the sampling period.
+	 */
+	for_each_online_cpu(cpu) {
+		struct psi_group_cpu *groupc = per_cpu_ptr(group->cpus, cpu);
+		unsigned long nonidle;
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
+	for (r = 0; r < NR_PSI_RESOURCES; r++) {
+		/* Finish the weighted aggregation */
+		some[r] /= max(nonidle_total, 1UL);
+		full[r] /= max(nonidle_total, 1UL);
+
+		/* Accumulate stall time */
+		group->some[r] += some[r];
+		group->full[r] += full[r];
+
+		/* Calculate recent pressure averages */
+		calc_avgs(group->avg_some[r], some[r], missed_periods);
+		calc_avgs(group->avg_full[r], full[r], missed_periods);
+	}
+
+	/* Keep the clock ticking only when there is action */
+	if (nonidle_total)
+		schedule_delayed_work(dwork, MY_LOAD_FREQ);
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
+static void psi_group_update(struct psi_group *group, int cpu, u64 now,
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
+			printk_deferred(KERN_ERR "psi: task underflow! cpu=%d idx=%d tasks=[%u %u %u %u]\n",
+					cpu, idx, tasks[0], tasks[1],
+					tasks[2], tasks[3]);
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
+		schedule_delayed_work(&group->clock_work, MY_LOAD_FREQ);
+}
+
+void psi_task_change(struct task_struct *task, u64 now, int clear, int set)
+{
+	struct cgroup *cgroup, *parent;
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
+	psi_group_update(&psi_system, cpu, now, clear, set);
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
+	*flags = current->flags & PF_MEMSTALL;
+	if (*flags)
+		return;
+	/*
+	 * PF_MEMSTALL setting & accounting needs to be atomic wrt
+	 * changes to the task's scheduling state, otherwise we can
+	 * race with CPU migration.
+	 */
+	local_irq_disable();
+	rq = this_rq();
+	raw_spin_lock(&rq->lock);
+	rq_pin_lock(rq, &rf);
+
+	update_rq_clock(rq);
+
+	current->flags |= PF_MEMSTALL;
+	psi_task_change(current, rq_clock(rq), 0, TSK_MEMSTALL);
+
+	rq_unpin_lock(rq, &rf);
+	raw_spin_unlock(&rq->lock);
+	local_irq_enable();
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
+	if (*flags)
+		return;
+	/*
+	 * PF_MEMSTALL clearing & accounting needs to be atomic wrt
+	 * changes to the task's scheduling state, otherwise we could
+	 * race with CPU migration.
+	 */
+	local_irq_disable();
+	rq = this_rq();
+	raw_spin_lock(&rq->lock);
+	rq_pin_lock(rq, &rf);
+
+	update_rq_clock(rq);
+
+	current->flags &= ~PF_MEMSTALL;
+	psi_task_change(current, rq_clock(rq), TSK_MEMSTALL, 0);
+
+	rq_unpin_lock(rq, &rf);
+	raw_spin_unlock(&rq->lock);
+	local_irq_enable();
+}
+
+static int psi_show(struct seq_file *m, struct psi_group *group,
+		    enum psi_res res)
+{
+	unsigned long avg[2][3];
+	int w;
+
+	if (psi_disabled)
+		return -EOPNOTSUPP;
+
+	for (w = 0; w < 3; w++) {
+		avg[0][w] = group->avg_some[res][w];
+		avg[1][w] = group->avg_full[res][w];
+	}
+
+	seq_printf(m, "some avg10=%lu.%02lu avg60=%lu.%02lu avg300=%lu.%02lu total=%llu\n",
+		   LOAD_INT(avg[0][0]), LOAD_FRAC(avg[0][0]),
+		   LOAD_INT(avg[0][1]), LOAD_FRAC(avg[0][1]),
+		   LOAD_INT(avg[0][2]), LOAD_FRAC(avg[0][2]),
+		   group->some[res] / NSEC_PER_USEC);
+
+	if (res == PSI_CPU)
+                return 0;
+
+	seq_printf(m, "full avg10=%lu.%02lu avg60=%lu.%02lu avg300=%lu.%02lu total=%llu\n",
+		   LOAD_INT(avg[1][0]), LOAD_FRAC(avg[1][0]),
+		   LOAD_INT(avg[1][1]), LOAD_FRAC(avg[1][1]),
+		   LOAD_INT(avg[1][2]), LOAD_FRAC(avg[1][2]),
+		   group->full[res] / NSEC_PER_USEC);
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
index 15750c222ca2..1658477466d5 100644
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
@@ -919,6 +921,8 @@ DECLARE_PER_CPU_SHARED_ALIGNED(struct rq, runqueues);
 #define cpu_curr(cpu)		(cpu_rq(cpu)->curr)
 #define raw_rq()		raw_cpu_ptr(&runqueues)
 
+extern void update_rq_clock(struct rq *rq);
+
 static inline u64 __rq_clock_broken(struct rq *rq)
 {
 	return READ_ONCE(rq->clock);
@@ -1037,6 +1041,86 @@ static inline void rq_repin_lock(struct rq *rq, struct rq_flags *rf)
 #endif
 }
 
+struct rq *__task_rq_lock(struct task_struct *p, struct rq_flags *rf)
+	__acquires(rq->lock);
+
+struct rq *task_rq_lock(struct task_struct *p, struct rq_flags *rf)
+	__acquires(p->pi_lock)
+	__acquires(rq->lock);
+
+static inline void __task_rq_unlock(struct rq *rq, struct rq_flags *rf)
+	__releases(rq->lock)
+{
+	rq_unpin_lock(rq, rf);
+	raw_spin_unlock(&rq->lock);
+}
+
+static inline void
+task_rq_unlock(struct rq *rq, struct task_struct *p, struct rq_flags *rf)
+	__releases(rq->lock)
+	__releases(p->pi_lock)
+{
+	rq_unpin_lock(rq, rf);
+	raw_spin_unlock(&rq->lock);
+	raw_spin_unlock_irqrestore(&p->pi_lock, rf->flags);
+}
+
+static inline void
+rq_lock_irqsave(struct rq *rq, struct rq_flags *rf)
+	__acquires(rq->lock)
+{
+	raw_spin_lock_irqsave(&rq->lock, rf->flags);
+	rq_pin_lock(rq, rf);
+}
+
+static inline void
+rq_lock_irq(struct rq *rq, struct rq_flags *rf)
+	__acquires(rq->lock)
+{
+	raw_spin_lock_irq(&rq->lock);
+	rq_pin_lock(rq, rf);
+}
+
+static inline void
+rq_lock(struct rq *rq, struct rq_flags *rf)
+	__acquires(rq->lock)
+{
+	raw_spin_lock(&rq->lock);
+	rq_pin_lock(rq, rf);
+}
+
+static inline void
+rq_relock(struct rq *rq, struct rq_flags *rf)
+	__acquires(rq->lock)
+{
+	raw_spin_lock(&rq->lock);
+	rq_repin_lock(rq, rf);
+}
+
+static inline void
+rq_unlock_irqrestore(struct rq *rq, struct rq_flags *rf)
+	__releases(rq->lock)
+{
+	rq_unpin_lock(rq, rf);
+	raw_spin_unlock_irqrestore(&rq->lock, rf->flags);
+}
+
+static inline void
+rq_unlock_irq(struct rq *rq, struct rq_flags *rf)
+	__releases(rq->lock)
+{
+	rq_unpin_lock(rq, rf);
+	raw_spin_unlock_irq(&rq->lock);
+}
+
+static inline void
+rq_unlock(struct rq *rq, struct rq_flags *rf)
+	__releases(rq->lock)
+{
+	rq_unpin_lock(rq, rf);
+	raw_spin_unlock(&rq->lock);
+}
+
 #ifdef CONFIG_NUMA
 enum numa_topology_type {
 	NUMA_DIRECT,
@@ -1670,8 +1754,6 @@ static inline void sub_nr_running(struct rq *rq, unsigned count)
 	sched_update_tick_dependency(rq);
 }
 
-extern void update_rq_clock(struct rq *rq);
-
 extern void activate_task(struct rq *rq, struct task_struct *p, int flags);
 extern void deactivate_task(struct rq *rq, struct task_struct *p, int flags);
 
@@ -1752,86 +1834,6 @@ static inline void sched_rt_avg_update(struct rq *rq, u64 rt_delta) { }
 static inline void sched_avg_update(struct rq *rq) { }
 #endif
 
-struct rq *__task_rq_lock(struct task_struct *p, struct rq_flags *rf)
-	__acquires(rq->lock);
-
-struct rq *task_rq_lock(struct task_struct *p, struct rq_flags *rf)
-	__acquires(p->pi_lock)
-	__acquires(rq->lock);
-
-static inline void __task_rq_unlock(struct rq *rq, struct rq_flags *rf)
-	__releases(rq->lock)
-{
-	rq_unpin_lock(rq, rf);
-	raw_spin_unlock(&rq->lock);
-}
-
-static inline void
-task_rq_unlock(struct rq *rq, struct task_struct *p, struct rq_flags *rf)
-	__releases(rq->lock)
-	__releases(p->pi_lock)
-{
-	rq_unpin_lock(rq, rf);
-	raw_spin_unlock(&rq->lock);
-	raw_spin_unlock_irqrestore(&p->pi_lock, rf->flags);
-}
-
-static inline void
-rq_lock_irqsave(struct rq *rq, struct rq_flags *rf)
-	__acquires(rq->lock)
-{
-	raw_spin_lock_irqsave(&rq->lock, rf->flags);
-	rq_pin_lock(rq, rf);
-}
-
-static inline void
-rq_lock_irq(struct rq *rq, struct rq_flags *rf)
-	__acquires(rq->lock)
-{
-	raw_spin_lock_irq(&rq->lock);
-	rq_pin_lock(rq, rf);
-}
-
-static inline void
-rq_lock(struct rq *rq, struct rq_flags *rf)
-	__acquires(rq->lock)
-{
-	raw_spin_lock(&rq->lock);
-	rq_pin_lock(rq, rf);
-}
-
-static inline void
-rq_relock(struct rq *rq, struct rq_flags *rf)
-	__acquires(rq->lock)
-{
-	raw_spin_lock(&rq->lock);
-	rq_repin_lock(rq, rf);
-}
-
-static inline void
-rq_unlock_irqrestore(struct rq *rq, struct rq_flags *rf)
-	__releases(rq->lock)
-{
-	rq_unpin_lock(rq, rf);
-	raw_spin_unlock_irqrestore(&rq->lock, rf->flags);
-}
-
-static inline void
-rq_unlock_irq(struct rq *rq, struct rq_flags *rf)
-	__releases(rq->lock)
-{
-	rq_unpin_lock(rq, rf);
-	raw_spin_unlock_irq(&rq->lock);
-}
-
-static inline void
-rq_unlock(struct rq *rq, struct rq_flags *rf)
-	__releases(rq->lock)
-{
-	rq_unpin_lock(rq, rf);
-	raw_spin_unlock(&rq->lock);
-}
-
 #ifdef CONFIG_SMP
 #ifdef CONFIG_PREEMPT
 
diff --git a/kernel/sched/stats.h b/kernel/sched/stats.h
index 8aea199a39b4..cb4a68bcf37a 100644
--- a/kernel/sched/stats.h
+++ b/kernel/sched/stats.h
@@ -55,12 +55,90 @@ static inline void rq_sched_info_depart  (struct rq *rq, unsigned long long delt
 # define   schedstat_val_or_zero(var)	0
 #endif /* CONFIG_SCHEDSTATS */
 
+#ifdef CONFIG_PSI
+/*
+ * PSI tracks state that persists across sleeps, such as iowaits and
+ * memory stalls. As a result, it has to distinguish between sleeps,
+ * where a task's runnable state changes, and requeues, where a task
+ * and its state are being moved between CPUs and runqueues.
+ */
+static inline void psi_enqueue(struct task_struct *p, u64 now)
+{
+	int clear = 0, set = TSK_RUNNING;
+
+	if (p->state == TASK_RUNNING || p->sched_psi_wake_requeue) {
+		if (p->flags & PF_MEMSTALL)
+			set |= TSK_MEMSTALL;
+		p->sched_psi_wake_requeue = 0;
+	} else {
+		if (p->in_iowait)
+			clear |= TSK_IOWAIT;
+	}
+
+	psi_task_change(p, now, clear, set);
+}
+static inline void psi_dequeue(struct task_struct *p, u64 now)
+{
+	int clear = TSK_RUNNING, set = 0;
+
+	if (p->state == TASK_RUNNING) {
+		if (p->flags & PF_MEMSTALL)
+			clear |= TSK_MEMSTALL;
+	} else {
+		if (p->in_iowait)
+			set |= TSK_IOWAIT;
+	}
+
+	psi_task_change(p, now, clear, set);
+}
+static inline void psi_ttwu_dequeue(struct task_struct *p)
+{
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
+static inline void psi_enqueue(struct task_struct *p, u64 now)
+{
+}
+static inline void psi_dequeue(struct task_struct *p, u64 now)
+{
+}
+static inline void psi_ttwu_dequeue(struct task_struct *p) {}
+{
+}
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
@@ -71,9 +149,11 @@ static inline void sched_info_dequeued(struct rq *rq, struct task_struct *t)
 {
 	unsigned long long now = rq_clock(rq), delta = 0;
 
-	if (unlikely(sched_info_on()))
+	if (unlikely(sched_info_on())) {
 		if (t->sched_info.last_queued)
 			delta = now - t->sched_info.last_queued;
+		psi_dequeue(t, now);
+	}
 	sched_info_reset_dequeued(t);
 	t->sched_info.run_delay += delta;
 
@@ -107,8 +187,10 @@ static void sched_info_arrive(struct rq *rq, struct task_struct *t)
 static inline void sched_info_queued(struct rq *rq, struct task_struct *t)
 {
 	if (unlikely(sched_info_on())) {
-		if (!t->sched_info.last_queued)
-			t->sched_info.last_queued = rq_clock(rq);
+		unsigned long long now = rq_clock(rq);
+
+		sched_info_reset_queued(t, now);
+		psi_enqueue(t, now);
 	}
 }
 
@@ -127,7 +209,8 @@ static inline void sched_info_depart(struct rq *rq, struct task_struct *t)
 	rq_sched_info_depart(rq, delta);
 
 	if (t->state == TASK_RUNNING)
-		sched_info_queued(rq, t);
+		if (unlikely(sched_info_on()))
+			sched_info_reset_queued(t, rq_clock(rq));
 }
 
 /*
diff --git a/mm/compaction.c b/mm/compaction.c
index 028b7210a669..7f51685d493b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -22,6 +22,7 @@
 #include <linux/kthread.h>
 #include <linux/freezer.h>
 #include <linux/page_owner.h>
+#include <linux/psi.h>
 #include "internal.h"
 
 #ifdef CONFIG_COMPACTION
@@ -2066,11 +2067,15 @@ static int kcompactd(void *p)
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
index 905db9d7962f..a4b5673166a2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -67,6 +67,7 @@
 #include <linux/ftrace.h>
 #include <linux/lockdep.h>
 #include <linux/nmi.h>
+#include <linux/psi.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -3559,15 +3560,20 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
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
@@ -3756,11 +3762,14 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
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
@@ -3772,6 +3781,7 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 	current->reclaim_state = NULL;
 	fs_reclaim_release(gfp_mask);
 	memalloc_noreclaim_restore(noreclaim_flag);
+	psi_memstall_leave(&pflags);
 
 	cond_resched();
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4ae5d0eb9489..f05a8ef1db15 100644
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
2.17.0
