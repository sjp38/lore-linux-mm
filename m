Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id AFB456B00F6
	for <linux-mm@kvack.org>; Thu,  3 May 2012 10:57:26 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id hr7so111711wib.8
        for <linux-mm@kvack.org>; Thu, 03 May 2012 07:57:26 -0700 (PDT)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v1 5/6] mm: make vmstat_update periodic run conditional
Date: Thu,  3 May 2012 17:56:01 +0300
Message-Id: <1336056962-10465-6-git-send-email-gilad@benyossef.com>
In-Reply-To: <1336056962-10465-1-git-send-email-gilad@benyossef.com>
References: <1336056962-10465-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Mike Frysinger <vapier@gentoo.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org

vmstat_update runs every second from the work queue to update statistics
and drain per cpu pages back into the global page allocator.

This is useful in most circumstances but is wasteful if the CPU doesn't
actually make any VM activity. This can happen in the situtation that
the CPU is idle or running a CPU bound long term task (e.g. CPU
isolation), in which case the periodic vmstate_update timer needlessly
itnerrupts the CPU.

This patch tries to make vmstat_update schedule itself for the next
round only if there was any work for it to do in the previous run.
The assumption is that if for a whole second we didn't see any VM
activity it is reasnoable to assume that the CPU is not using the
VM because it is idle or runs a long term single CPU bound task.

A new single unbound system work queue item is scheduled periodically
to monitor CPUs that have their vmstat_update work stopped and
re-schedule them if VM activity is detected.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: Tejun Heo <tj@kernel.org>
CC: John Stultz <johnstul@us.ibm.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Mel Gorman <mel@csn.ul.ie>
CC: Mike Frysinger <vapier@gentoo.org>
CC: David Rientjes <rientjes@google.com>
CC: Hugh Dickins <hughd@google.com>
CC: Minchan Kim <minchan.kim@gmail.com>
CC: Konstantin Khlebnikov <khlebnikov@openvz.org>
CC: Christoph Lameter <cl@linux.com>
CC: Chris Metcalf <cmetcalf@tilera.com>
CC: Hakan Akkan <hakanakkan@gmail.com>
CC: Max Krasnyansky <maxk@qualcomm.com>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: linux-kernel@vger.kernel.org
CC: linux-mm@kvack.org
---
 include/linux/vmstat.h |    2 +-
 mm/vmstat.c            |   95 +++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 82 insertions(+), 15 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 65efb92..67bf202 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -200,7 +200,7 @@ extern void __inc_zone_state(struct zone *, enum zone_stat_item);
 extern void dec_zone_state(struct zone *, enum zone_stat_item);
 extern void __dec_zone_state(struct zone *, enum zone_stat_item);
 
-void refresh_cpu_vm_stats(int);
+bool refresh_cpu_vm_stats(int);
 void refresh_zone_stat_thresholds(void);
 
 int calculate_pressure_threshold(struct zone *zone);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7db1b9b..1676132 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -14,6 +14,7 @@
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/cpu.h>
+#include <linux/cpumask.h>
 #include <linux/vmstat.h>
 #include <linux/sched.h>
 #include <linux/math64.h>
@@ -434,11 +435,12 @@ EXPORT_SYMBOL(dec_zone_page_state);
  * with the global counters. These could cause remote node cache line
  * bouncing and will have to be only done when necessary.
  */
-void refresh_cpu_vm_stats(int cpu)
+bool refresh_cpu_vm_stats(int cpu)
 {
 	struct zone *zone;
 	int i;
 	int global_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
+	bool vm_activity = false;
 
 	for_each_populated_zone(zone) {
 		struct per_cpu_pageset *p;
@@ -485,14 +487,21 @@ void refresh_cpu_vm_stats(int cpu)
 		if (p->expire)
 			continue;
 
-		if (p->pcp.count)
+		if (p->pcp.count) {
+			vm_activity = true;
 			drain_zone_pages(zone, &p->pcp);
+		}
 #endif
 	}
 
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
-		if (global_diff[i])
+		if (global_diff[i]) {
 			atomic_long_add(global_diff[i], &vm_stat[i]);
+			vm_activity = true;
+		}
+
+	return vm_activity;
+
 }
 
 #endif
@@ -1141,22 +1150,72 @@ static const struct file_operations proc_vmstat_file_operations = {
 #ifdef CONFIG_SMP
 static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
 int sysctl_stat_interval __read_mostly = HZ;
+static struct cpumask vmstat_off_cpus;
+struct delayed_work vmstat_monitor_work;
 
-static void vmstat_update(struct work_struct *w)
+static inline bool need_vmstat(int cpu)
 {
-	refresh_cpu_vm_stats(smp_processor_id());
-	schedule_delayed_work(&__get_cpu_var(vmstat_work),
-		round_jiffies_relative(sysctl_stat_interval));
+	struct zone *zone;
+	int i;
+
+	for_each_populated_zone(zone) {
+		struct per_cpu_pageset *p;
+
+		p = per_cpu_ptr(zone->pageset, cpu);
+
+		for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
+			if (p->vm_stat_diff[i])
+				return true;
+
+		if (zone_to_nid(zone) != numa_node_id() && p->pcp.count)
+			return true;
+	}
+
+	return false;
 }
 
-static void __cpuinit start_cpu_timer(int cpu)
+static void vmstat_update(struct work_struct *w);
+
+static void start_cpu_timer(int cpu)
 {
 	struct delayed_work *work = &per_cpu(vmstat_work, cpu);
 
-	INIT_DELAYED_WORK_DEFERRABLE(work, vmstat_update);
+	cpumask_clear_cpu(cpu, &vmstat_off_cpus);
 	schedule_delayed_work_on(cpu, work, __round_jiffies_relative(HZ, cpu));
 }
 
+static void __cpuinit setup_cpu_timer(int cpu)
+{
+	struct delayed_work *work = &per_cpu(vmstat_work, cpu);
+
+	INIT_DELAYED_WORK_DEFERRABLE(work, vmstat_update);
+	start_cpu_timer(cpu);
+}
+
+static void vmstat_update_monitor(struct work_struct *w)
+{
+	int cpu;
+
+	for_each_cpu_and(cpu, &vmstat_off_cpus, cpu_online_mask)
+		if (need_vmstat(cpu))
+			start_cpu_timer(cpu);
+
+	queue_delayed_work(system_unbound_wq, &vmstat_monitor_work,
+		round_jiffies_relative(sysctl_stat_interval));
+}
+
+
+static void vmstat_update(struct work_struct *w)
+{
+	int cpu = smp_processor_id();
+
+	if (likely(refresh_cpu_vm_stats(cpu)))
+		schedule_delayed_work(&__get_cpu_var(vmstat_work),
+				round_jiffies_relative(sysctl_stat_interval));
+	else
+		cpumask_set_cpu(cpu, &vmstat_off_cpus);
+}
+
 /*
  * Use the cpu notifier to insure that the thresholds are recalculated
  * when necessary.
@@ -1171,17 +1230,19 @@ static int __cpuinit vmstat_cpuup_callback(struct notifier_block *nfb,
 	case CPU_ONLINE:
 	case CPU_ONLINE_FROZEN:
 		refresh_zone_stat_thresholds();
-		start_cpu_timer(cpu);
+		setup_cpu_timer(cpu);
 		node_set_state(cpu_to_node(cpu), N_CPU);
 		break;
 	case CPU_DOWN_PREPARE:
 	case CPU_DOWN_PREPARE_FROZEN:
-		cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
-		per_cpu(vmstat_work, cpu).work.func = NULL;
+		if (!cpumask_test_cpu(cpu, &vmstat_off_cpus)) {
+			cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
+			per_cpu(vmstat_work, cpu).work.func = NULL;
+		}
 		break;
 	case CPU_DOWN_FAILED:
 	case CPU_DOWN_FAILED_FROZEN:
-		start_cpu_timer(cpu);
+		setup_cpu_timer(cpu);
 		break;
 	case CPU_DEAD:
 	case CPU_DEAD_FROZEN:
@@ -1204,8 +1265,14 @@ static int __init setup_vmstat(void)
 
 	register_cpu_notifier(&vmstat_notifier);
 
+	INIT_DELAYED_WORK_DEFERRABLE(&vmstat_monitor_work,
+				vmstat_update_monitor);
+	queue_delayed_work(system_unbound_wq,
+				&vmstat_monitor_work,
+				round_jiffies_relative(HZ));
+
 	for_each_online_cpu(cpu)
-		start_cpu_timer(cpu);
+		setup_cpu_timer(cpu);
 #endif
 #ifdef CONFIG_PROC_FS
 	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
