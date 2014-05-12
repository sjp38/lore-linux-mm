Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 234A06B0037
	for <linux-mm@kvack.org>; Mon, 12 May 2014 14:18:16 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id l6so8450523qcy.31
        for <linux-mm@kvack.org>; Mon, 12 May 2014 11:18:15 -0700 (PDT)
Received: from qmta05.emeryville.ca.mail.comcast.net (qmta05.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:48])
        by mx.google.com with ESMTP id s6si6409913qaj.154.2014.05.12.11.18.14
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 11:18:15 -0700 (PDT)
Date: Mon, 12 May 2014 13:18:10 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: vmstat: On demand vmstat workers V5
Message-ID: <alpine.DEB.2.10.1405121317270.29911@gentwo.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org


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

Signed-off-by: Christoph Lameter <cl@linux.com>


Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c	2014-05-12 12:43:49.373311788 -0500
+++ linux/mm/vmstat.c	2014-05-12 13:07:12.406956661 -0500
@@ -7,6 +7,7 @@
  *  zoned VM statistics
  *  Copyright (C) 2006 Silicon Graphics, Inc.,
  *		Christoph Lameter <christoph@lameter.com>
+ *  Copyright (C) 2008-2014 Christoph Lameter
  */
 #include <linux/fs.h>
 #include <linux/mm.h>
@@ -14,12 +15,14 @@
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/cpu.h>
+#include <linux/cpumask.h>
 #include <linux/vmstat.h>
 #include <linux/sched.h>
 #include <linux/math64.h>
 #include <linux/writeback.h>
 #include <linux/compaction.h>
 #include <linux/mm_inline.h>
+#include <linux/tick.h>

 #include "internal.h"

@@ -417,13 +420,22 @@
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
@@ -439,12 +451,15 @@
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
@@ -484,15 +499,17 @@
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
@@ -1222,20 +1239,119 @@
 #ifdef CONFIG_SMP
 static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
 int sysctl_stat_interval __read_mostly = HZ;
+static DECLARE_BITMAP(cpu_stat_off_bits, CONFIG_NR_CPUS) __read_mostly;
+const struct cpumask *const cpu_stat_off = to_cpumask(cpu_stat_off_bits);
+EXPORT_SYMBOL(cpu_stat_off);
+
+/* We need to write to cpu_stat_off here */
+#define stat_off to_cpumask(cpu_stat_off_bits)

 static void vmstat_update(struct work_struct *w)
 {
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
+		 * Housekeeping cpu does not race since it never
+		 * changes the bit if its zero
+		 */
+		r = cpumask_test_and_set_cpu(smp_processor_id(),
+			stat_off);
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
+ * Shepherd worker thread that updates the statistics for the
+ * processor the shepherd worker is running on and checks the
+ * differentials of other processors that have their worker
+ * threads for vm statistics updates disabled because of
+ * inactivity.
+ */
+static void vmstat_shepherd(struct work_struct *w)
+{
+	int cpu;
+
 	refresh_cpu_vm_stats();
-	schedule_delayed_work(&__get_cpu_var(vmstat_work),
-		round_jiffies_relative(sysctl_stat_interval));
+
+	/* Check processors whose vmstat worker threads have been disabled */
+	for_each_cpu(cpu, stat_off)
+		if (need_update(cpu) &&
+			cpumask_test_and_clear_cpu(cpu, stat_off)) {
+
+			struct delayed_work *work = &per_cpu(vmstat_work, cpu);
+
+			INIT_DEFERRABLE_WORK(work, vmstat_update);
+			schedule_delayed_work_on(cpu, work,
+				__round_jiffies_relative(sysctl_stat_interval,
+				cpu));
+		}
+
+	schedule_delayed_work(this_cpu_ptr(&vmstat_work),
+		__round_jiffies_relative(sysctl_stat_interval,
+		HOUSEKEEPING_CPU));
+
 }

-static void start_cpu_timer(int cpu)
+static void __init start_shepherd_timer(void)
 {
-	struct delayed_work *work = &per_cpu(vmstat_work, cpu);
+	struct delayed_work *d = per_cpu_ptr(&vmstat_work,
+					HOUSEKEEPING_CPU);
+	int cpu;
+
+	for_each_possible_cpu(cpu)
+		INIT_DEFERRABLE_WORK(per_cpu_ptr(&vmstat_work, cpu),
+			vmstat_update);
+
+	INIT_DELAYED_WORK(d, vmstat_shepherd);
+
+	cpumask_copy(stat_off, cpu_online_mask);

-	INIT_DEFERRABLE_WORK(work, vmstat_update);
-	schedule_delayed_work_on(cpu, work, __round_jiffies_relative(HZ, cpu));
+	/* Make sure that arch code hasnt dont anything goofy */
+	VM_BUG_ON(!cpu_isset(HOUSEKEEPING_CPU, *stat_off));
+
+	cpumask_clear_cpu(HOUSEKEEPING_CPU, stat_off);
+	schedule_delayed_work_on(HOUSEKEEPING_CPU, d,
+		__round_jiffies_relative(sysctl_stat_interval,
+		HOUSEKEEPING_CPU));
 }

 static void vmstat_cpu_dead(int node)
@@ -1266,17 +1382,17 @@
 	case CPU_ONLINE:
 	case CPU_ONLINE_FROZEN:
 		refresh_zone_stat_thresholds();
-		start_cpu_timer(cpu);
 		node_set_state(cpu_to_node(cpu), N_CPU);
+		cpumask_set_cpu(cpu, stat_off);
 		break;
 	case CPU_DOWN_PREPARE:
 	case CPU_DOWN_PREPARE_FROZEN:
-		cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
-		per_cpu(vmstat_work, cpu).work.func = NULL;
+		if (!cpumask_test_and_clear_cpu(cpu, stat_off))
+			cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
 		break;
 	case CPU_DOWN_FAILED:
 	case CPU_DOWN_FAILED_FROZEN:
-		start_cpu_timer(cpu);
+		cpumask_set_cpu(cpu, stat_off);
 		break;
 	case CPU_DEAD:
 	case CPU_DEAD_FROZEN:
@@ -1296,15 +1412,10 @@
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
Index: linux/include/linux/tick.h
===================================================================
--- linux.orig/include/linux/tick.h	2014-05-12 12:43:49.373311788 -0500
+++ linux/include/linux/tick.h	2014-05-12 12:43:49.369311864 -0500
@@ -13,6 +13,8 @@
 #include <linux/context_tracking_state.h>
 #include <linux/cpumask.h>

+#define HOUSEKEEPING_CPU 0
+
 #ifdef CONFIG_GENERIC_CLOCKEVENTS

 enum tick_device_mode {
Index: linux/drivers/base/cpu.c
===================================================================
--- linux.orig/drivers/base/cpu.c	2014-05-12 12:43:49.373311788 -0500
+++ linux/drivers/base/cpu.c	2014-05-12 13:11:07.054562341 -0500
@@ -222,6 +222,7 @@
 	_CPU_ATTR(online, &cpu_online_mask),
 	_CPU_ATTR(possible, &cpu_possible_mask),
 	_CPU_ATTR(present, &cpu_present_mask),
+	_CPU_ATTR(stat_off, &cpu_stat_off),
 };

 /*
@@ -378,6 +379,7 @@
 	&cpu_attrs[0].attr.attr,
 	&cpu_attrs[1].attr.attr,
 	&cpu_attrs[2].attr.attr,
+	&cpu_attrs[3].attr.attr,
 	&dev_attr_kernel_max.attr,
 	&dev_attr_offline.attr,
 #ifdef CONFIG_GENERIC_CPU_AUTOPROBE
Index: linux/include/linux/cpumask.h
===================================================================
--- linux.orig/include/linux/cpumask.h	2014-05-12 12:43:49.373311788 -0500
+++ linux/include/linux/cpumask.h	2014-05-12 12:52:12.191784100 -0500
@@ -80,6 +80,7 @@
 extern const struct cpumask *const cpu_online_mask;
 extern const struct cpumask *const cpu_present_mask;
 extern const struct cpumask *const cpu_active_mask;
+extern const struct cpumask *const cpu_stat_off;

 #if NR_CPUS > 1
 #define num_online_cpus()	cpumask_weight(cpu_online_mask)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
