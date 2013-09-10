Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 1110A6B008C
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 17:13:36 -0400 (EDT)
Date: Tue, 10 Sep 2013 21:13:34 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: RFC vmstat: On demand vmstat threads
In-Reply-To: <CAOtvUMdfqyg80_9J8AnOaAdahuRYGC-bpemdo_oucDBPguXbVA@mail.gmail.com>
Message-ID: <0000014109b8e5db-4b0f577e-c3b4-47fe-b7f2-0e5febbcc948-000000@email.amazonses.com>
References: <00000140e9dfd6bd-40db3d4f-c1be-434f-8132-7820f81bb586-000000@email.amazonses.com> <CAOtvUMdfqyg80_9J8AnOaAdahuRYGC-bpemdo_oucDBPguXbVA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>

On Tue, 10 Sep 2013, Gilad Ben-Yossef wrote:

> I wasn't happy with the results of my own attempt to accomplish the same and I
> like this much better. So, for what it's worth -

Thanks. In the meantime I found some issues with my patchset and revised
it further. Could you have another look?


Subject: vmstat: On demand vmstat workers V2

vmstat threads are used for folding counter differentials into the
zone, per node and global counters at certain time intervals.

They currently run at defined intervals on all processors which will
cause some holdoff for processors that need minimal intrusion by the
OS.

This patch creates a vmstat shepherd task that monitors the
per cpu differentials on all processors. If there are differentials
on a processor then a vmstat worker thread local to the processors
with the differentials is created. That worker will then start
folding the diffs in regular intervals. Should the worker
find that there is no work to be done then it will
terminate itself and make the shepherd task monitor the differentials
again.

With this patch it is possible then to have periods longer than
2 seconds without any OS event on a "cpu" (hardware thread).

The tick_do_timer_cpu is chosen to run the shepherd workers.
So there must be at least one cpu that will keep running vmstat
updates.

Note: This patch is based on the vmstat patches in Andrew's tree
to be merged for the 3.12 kernel.

V1->V2:
- Optimize the need_update check by using memchr_inv.
- Clean up.
- Fixup the wrong need_update check.
- Drop the check for pcp.count. Too many false positives.

Reviewed-by: Gilad Ben-Yossef <gilad@benyossef.com>
Signed-off-by: Christoph Lameter <cl@linux.com>


Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c	2013-09-09 13:58:25.526562233 -0500
+++ linux/mm/vmstat.c	2013-09-09 16:09:14.266402841 -0500
@@ -14,6 +14,7 @@
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/cpu.h>
+#include <linux/cpumask.h>
 #include <linux/vmstat.h>
 #include <linux/sched.h>
 #include <linux/math64.h>
@@ -414,13 +415,18 @@ void dec_zone_page_state(struct page *pa
 EXPORT_SYMBOL(dec_zone_page_state);
 #endif

-static inline void fold_diff(int *diff)
+
+static inline int fold_diff(int *diff)
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
@@ -437,11 +443,12 @@ static inline void fold_diff(int *diff)
  * with the global counters. These could cause remote node cache line
  * bouncing and will have to be only done when necessary.
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
@@ -485,11 +492,14 @@ static void refresh_cpu_vm_stats(void)
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
@@ -1203,12 +1213,15 @@ static const struct file_operations proc
 #ifdef CONFIG_SMP
 static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
 int sysctl_stat_interval __read_mostly = HZ;
+static struct cpumask *monitored_cpus;

 static void vmstat_update(struct work_struct *w)
 {
-	refresh_cpu_vm_stats();
-	schedule_delayed_work(this_cpu_ptr(&vmstat_work),
-		round_jiffies_relative(sysctl_stat_interval));
+	if (refresh_cpu_vm_stats())
+		schedule_delayed_work(this_cpu_ptr(&vmstat_work),
+			round_jiffies_relative(sysctl_stat_interval));
+	else
+		cpumask_set_cpu(smp_processor_id(), monitored_cpus);
 }

 static void start_cpu_timer(int cpu)
@@ -1216,7 +1229,63 @@ static void start_cpu_timer(int cpu)
 	struct delayed_work *work = &per_cpu(vmstat_work, cpu);

 	INIT_DEFERRABLE_WORK(work, vmstat_update);
-	schedule_delayed_work_on(cpu, work, __round_jiffies_relative(HZ, cpu));
+	schedule_delayed_work_on(cpu, work,
+		__round_jiffies_relative(sysctl_stat_interval, cpu));
+}
+
+/*
+ * Check if the diffs for a certain cpu indicate that
+ * an update is needed.
+ */
+static int need_update(int cpu)
+{
+	struct zone *zone;
+
+	for_each_populated_zone(zone) {
+		struct per_cpu_pageset *p = per_cpu_ptr(zone->pageset, cpu);
+
+		/*
+		 * The fast way of checking if there are any vmstat diffs.
+		 * This works because the diffs are byte sized items.
+		 */
+		if (memchr_inv(p->vm_stat_diff, 0, NR_VM_ZONE_STAT_ITEMS))
+			return 1;
+	}
+	return 0;
+}
+
+static struct delayed_work shepherd_work;
+extern int tick_do_timer_cpu;
+
+static void vmstat_shepherd(struct work_struct *w)
+{
+	int cpu;
+
+	refresh_cpu_vm_stats();
+	for_each_cpu(cpu, monitored_cpus)
+		if (need_update(cpu)) {
+			cpumask_clear_cpu(cpu, monitored_cpus);
+			start_cpu_timer(cpu);
+		}
+
+	schedule_delayed_work_on(tick_do_timer_cpu,
+		&shepherd_work,
+		__round_jiffies_relative(sysctl_stat_interval,
+			tick_do_timer_cpu));
+}
+
+static void start_shepherd_timer(void)
+{
+	INIT_DEFERRABLE_WORK(&shepherd_work, vmstat_shepherd);
+	monitored_cpus = kmalloc(BITS_TO_LONGS(nr_cpu_ids) * sizeof(long),
+			__GFP_NOFAIL);
+	cpumask_copy(monitored_cpus, cpu_online_mask);
+	cpumask_clear_cpu(tick_do_timer_cpu, monitored_cpus);
+	schedule_delayed_work_on(tick_do_timer_cpu,
+		&shepherd_work,
+		__round_jiffies_relative(sysctl_stat_interval,
+			tick_do_timer_cpu));
+
 }

 /*
@@ -1233,17 +1302,19 @@ static int vmstat_cpuup_callback(struct
 	case CPU_ONLINE:
 	case CPU_ONLINE_FROZEN:
 		refresh_zone_stat_thresholds();
-		start_cpu_timer(cpu);
 		node_set_state(cpu_to_node(cpu), N_CPU);
+		cpumask_set_cpu(cpu, monitored_cpus);
 		break;
 	case CPU_DOWN_PREPARE:
 	case CPU_DOWN_PREPARE_FROZEN:
-		cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
+		if (!cpumask_test_cpu(cpu, monitored_cpus))
+			cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
+		cpumask_clear_cpu(cpu, monitored_cpus);
 		per_cpu(vmstat_work, cpu).work.func = NULL;
 		break;
 	case CPU_DOWN_FAILED:
 	case CPU_DOWN_FAILED_FROZEN:
-		start_cpu_timer(cpu);
+		cpumask_set_cpu(cpu, monitored_cpus);
 		break;
 	case CPU_DEAD:
 	case CPU_DEAD_FROZEN:
@@ -1262,12 +1333,8 @@ static struct notifier_block vmstat_noti
 static int __init setup_vmstat(void)
 {
 #ifdef CONFIG_SMP
-	int cpu;
-
 	register_cpu_notifier(&vmstat_notifier);
-
-	for_each_online_cpu(cpu)
-		start_cpu_timer(cpu);
+	start_shepherd_timer();
 #endif
 #ifdef CONFIG_PROC_FS
 	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
