Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f182.google.com (mail-vc0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id D2B956B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 15:56:20 -0400 (EDT)
Received: by mail-vc0-f182.google.com with SMTP id id10so966947vcb.41
        for <linux-mm@kvack.org>; Thu, 29 May 2014 12:56:20 -0700 (PDT)
Received: from qmta07.emeryville.ca.mail.comcast.net (qmta07.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:64])
        by mx.google.com with ESMTP id fa1si1397693vcb.39.2014.05.29.12.56.19
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 12:56:20 -0700 (PDT)
Date: Thu, 29 May 2014 14:56:15 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: [PATCH] vmstat: on demand updates from differentials V7
Message-ID: <alpine.DEB.2.10.1405291453260.2899@gentwo.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>


V6->V7
- Remove /sysfs support and avoid the large cpumask definition.

V5->V6:
- Shepherd thread as a general worker thread. This means
  that the general mechanism to control worker thread
  cpu use by Frederic Weisbecker is necessary to
  restrict the shepherd thread to the cpus not used
  for low latency tasks. Hopefully that is ready to be
  merged soon. No need anymore to have a specific
  cpu be the housekeeper cpu.

V4->V5:
- Shepherd thread on a specific cpu (HOUSEKEEPING_CPU).
- Incorporate Andrew's feedback
- Work out the races.
- Make visible which CPUs have stat updates switched off
  in /sys/devices/system/cpu/stat_off

V3->V4:
- Make the shepherd task not deferrable. It runs on the tick cpu
  anyways. Deferral could get deltas too far out of sync if
  vmstat operations are disabled for a certain processor.

V2->V3:
- Introduce a new tick_get_housekeeping_cpu() function. Not sure
  if that is exactly what we want but it is a start. Thomas?
- Migrate the shepherd task if the output of
  tick_get_housekeeping_cpu() changes.
- Fixes recommended by Andrew.

V1->V2:
- Optimize the need_update check by using memchr_inv.
- Clean up.

vmstat workers are used for folding counter differentials into the
zone, per node and global counters at certain time intervals.
They currently run at defined intervals on all processors which will
cause some holdoff for processors that need minimal intrusion by the
OS.

The current vmstat_update mechanism depends on a deferrable timer
firing every other second by default which registers a work queue item
that runs on the local CPU, with the result that we have 1 interrupt
and one additional schedulable task on each CPU every 2 seconds
If a workload indeed causes VM activity or multiple tasks are running
on a CPU, then there are probably bigger issues to deal with.

However, some workloads dedicate a CPU for a single CPU bound task.
This is done in high performance computing, in high frequency
financial applications, in networking (Intel DPDK, EZchip NPS) and with
the advent of systems with more and more CPUs over time, this may become
more and more common to do since when one has enough CPUs
one cares less about efficiently sharing a CPU with other tasks and
more about efficiently monopolizing a CPU per task.

The difference of having this timer firing and workqueue kernel thread
scheduled per second can be enormous. An artificial test measuring the
worst case time to do a simple "i++" in an endless loop on a bare metal
system and under Linux on an isolated CPU with dynticks and with and
without this patch, have Linux match the bare metal performance
(~700 cycles) with this patch and loose by couple of orders of magnitude
(~200k cycles) without it[*].  The loss occurs for something that just
calculates statistics. For networking applications, for example, this
could be the difference between dropping packets or sustaining line rate.

Statistics are important and useful, but it would be great if there
would be a way to not cause statistics gathering produce a huge
performance difference. This patche does just that.

This patch creates a vmstat shepherd worker that monitors the
per cpu differentials on all processors. If there are differentials
on a processor then a vmstat worker local to the processors
with the differentials is created. That worker will then start
folding the diffs in regular intervals. Should the worker
find that there is no work to be done then it will make the shepherd
worker monitor the differentials again.

With this patch it is possible then to have periods longer than
2 seconds without any OS event on a "cpu" (hardware thread).

Reviewed-by: Gilad Ben-Yossef <gilad@benyossef.com>
Signed-off-by: Christoph Lameter <cl@linux.com>


Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c	2014-05-29 14:37:45.277853004 -0500
+++ linux/mm/vmstat.c	2014-05-29 14:43:26.439163942 -0500
@@ -7,6 +7,7 @@
  *  zoned VM statistics
  *  Copyright (C) 2006 Silicon Graphics, Inc.,
  *		Christoph Lameter <christoph@lameter.com>
+ *  Copyright (C) 2008-2014 Christoph Lameter
  */
 #include <linux/fs.h>
 #include <linux/mm.h>
@@ -14,6 +15,7 @@
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/cpu.h>
+#include <linux/cpumask.h>
 #include <linux/vmstat.h>
 #include <linux/sched.h>
 #include <linux/math64.h>
@@ -417,13 +419,22 @@
 EXPORT_SYMBOL(dec_zone_page_state);
 #endif

-static inline void fold_diff(int *diff)
+
+/*
+ * Fold a differential into the global counters.
+ * Returns the number of counters updated.
+ */
+static int fold_diff(int *diff)
 {
 	int i;
+	int changes = 0;

 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
-		if (diff[i])
+		if (diff[i]) {
 			atomic_long_add(diff[i], &vm_stat[i]);
+			changes++;
+	}
+	return changes;
 }

 /*
@@ -439,12 +450,15 @@
  * statistics in the remote zone struct as well as the global cachelines
  * with the global counters. These could cause remote node cache line
  * bouncing and will have to be only done when necessary.
+ *
+ * The function returns the number of global counters updated.
  */
-static void refresh_cpu_vm_stats(void)
+static int refresh_cpu_vm_stats(void)
 {
 	struct zone *zone;
 	int i;
 	int global_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
+	int changes = 0;

 	for_each_populated_zone(zone) {
 		struct per_cpu_pageset __percpu *p = zone->pageset;
@@ -484,15 +498,17 @@
 			continue;
 		}

-
 		if (__this_cpu_dec_return(p->expire))
 			continue;

-		if (__this_cpu_read(p->pcp.count))
+		if (__this_cpu_read(p->pcp.count)) {
 			drain_zone_pages(zone, __this_cpu_ptr(&p->pcp));
+			changes++;
+		}
 #endif
 	}
-	fold_diff(global_diff);
+	changes += fold_diff(global_diff);
+	return changes;
 }

 /*
@@ -1222,20 +1238,105 @@
 #ifdef CONFIG_SMP
 static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
 int sysctl_stat_interval __read_mostly = HZ;
+struct cpumask *cpu_stat_off;

 static void vmstat_update(struct work_struct *w)
 {
-	refresh_cpu_vm_stats();
-	schedule_delayed_work(&__get_cpu_var(vmstat_work),
+	if (refresh_cpu_vm_stats())
+		/*
+		 * Counters were updated so we expect more updates
+		 * to occur in the future. Keep on running the
+		 * update worker thread.
+		 */
+		schedule_delayed_work(this_cpu_ptr(&vmstat_work),
+			round_jiffies_relative(sysctl_stat_interval));
+	else {
+		/*
+		 * We did not update any counters so the app may be in
+		 * a mode where it does not cause counter updates.
+		 * We may be uselessly running vmstat_update.
+		 * Defer the checking for differentials to the
+		 * shepherd thread on a different processor.
+		 */
+		int r;
+		/*
+		 * Shepherd work thread does not race since it never
+		 * changes the bit if its zero but the cpu
+		 * online / off line code may race if
+		 * worker threads are still allowed during
+		 * shutdown / startup.
+		 */
+		r = cpumask_test_and_set_cpu(smp_processor_id(),
+			cpu_stat_off);
+		VM_BUG_ON(r);
+	}
+}
+
+/*
+ * Check if the diffs for a certain cpu indicate that
+ * an update is needed.
+ */
+static bool need_update(int cpu)
+{
+	struct zone *zone;
+
+	for_each_populated_zone(zone) {
+		struct per_cpu_pageset *p = per_cpu_ptr(zone->pageset, cpu);
+
+		BUILD_BUG_ON(sizeof(p->vm_stat_diff[0]) != 1);
+		/*
+		 * The fast way of checking if there are any vmstat diffs.
+		 * This works because the diffs are byte sized items.
+		 */
+		if (memchr_inv(p->vm_stat_diff, 0, NR_VM_ZONE_STAT_ITEMS))
+			return true;
+
+	}
+	return false;
+}
+
+
+/*
+ * Shepherd worker thread that checks the
+ * differentials of processors that have their worker
+ * threads for vm statistics updates disabled because of
+ * inactivity.
+ */
+static void vmstat_shepherd(struct work_struct *w);
+
+static DECLARE_DELAYED_WORK(shepherd, vmstat_shepherd);
+
+static void vmstat_shepherd(struct work_struct *w)
+{
+	int cpu;
+
+	/* Check processors whose vmstat worker threads have been disabled */
+	for_each_cpu(cpu, cpu_stat_off)
+		if (need_update(cpu) &&
+			cpumask_test_and_clear_cpu(cpu, cpu_stat_off))
+
+			schedule_delayed_work_on(cpu, &per_cpu(vmstat_work, cpu),
+				__round_jiffies_relative(sysctl_stat_interval, cpu));
+
+
+	schedule_delayed_work(&shepherd,
 		round_jiffies_relative(sysctl_stat_interval));
+
 }

-static void start_cpu_timer(int cpu)
+static void __init start_shepherd_timer(void)
 {
-	struct delayed_work *work = &per_cpu(vmstat_work, cpu);
+	int cpu;
+
+	for_each_possible_cpu(cpu)
+		INIT_DEFERRABLE_WORK(per_cpu_ptr(&vmstat_work, cpu),
+			vmstat_update);
+
+	cpu_stat_off = kmalloc(cpumask_size(), GFP_KERNEL);
+	cpumask_copy(cpu_stat_off, cpu_online_mask);

-	INIT_DEFERRABLE_WORK(work, vmstat_update);
-	schedule_delayed_work_on(cpu, work, __round_jiffies_relative(HZ, cpu));
+	schedule_delayed_work(&shepherd,
+		round_jiffies_relative(sysctl_stat_interval));
 }

 static void vmstat_cpu_dead(int node)
@@ -1266,17 +1367,17 @@
 	case CPU_ONLINE:
 	case CPU_ONLINE_FROZEN:
 		refresh_zone_stat_thresholds();
-		start_cpu_timer(cpu);
 		node_set_state(cpu_to_node(cpu), N_CPU);
+		cpumask_set_cpu(cpu, cpu_stat_off);
 		break;
 	case CPU_DOWN_PREPARE:
 	case CPU_DOWN_PREPARE_FROZEN:
-		cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
-		per_cpu(vmstat_work, cpu).work.func = NULL;
+		if (!cpumask_test_and_set_cpu(cpu, cpu_stat_off))
+			cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
 		break;
 	case CPU_DOWN_FAILED:
 	case CPU_DOWN_FAILED_FROZEN:
-		start_cpu_timer(cpu);
+		cpumask_set_cpu(cpu, cpu_stat_off);
 		break;
 	case CPU_DEAD:
 	case CPU_DEAD_FROZEN:
@@ -1296,15 +1397,10 @@
 static int __init setup_vmstat(void)
 {
 #ifdef CONFIG_SMP
-	int cpu;
-
 	cpu_notifier_register_begin();
 	__register_cpu_notifier(&vmstat_notifier);

-	for_each_online_cpu(cpu) {
-		start_cpu_timer(cpu);
-		node_set_state(cpu_to_node(cpu), N_CPU);
-	}
+	start_shepherd_timer();
 	cpu_notifier_register_done();
 #endif
 #ifdef CONFIG_PROC_FS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
