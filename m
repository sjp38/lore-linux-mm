Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 4505B6B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 16:03:00 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id hq4so1031902wib.2
        for <linux-mm@kvack.org>; Wed, 19 Jun 2013 13:02:58 -0700 (PDT)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v2 1/2] mm: make vmstat_update periodic run conditional
Date: Wed, 19 Jun 2013 23:02:47 +0300
Message-Id: <1371672168-9869-1-git-send-email-gilad@benyossef.com>
In-Reply-To: <CAOtvUMc5w3zNe8ed6qX0OOM__3F_hOTqvFa1AkdXF0PHvzGZqg@mail.gmail.com>
References: <CAOtvUMc5w3zNe8ed6qX0OOM__3F_hOTqvFa1AkdXF0PHvzGZqg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

vmstat_update runs every second from the work queue to update statistics
and drain per cpu pages back into the global page allocator.

This is useful in most circumstances but is wasteful if the CPU doesn't
actually make any VM activity. This can happen in the situtation that
the CPU is idle or running a CPU bound long term task (e.g. CPU
isolation), in which case the periodic vmstate_update timer needlessly
interrupts the CPU.

This patch tries to make vmstat_update schedule itself for the next
round only if there was any work for it to do in the previous run.
The assumption is that if for a whole second we didn't see any VM
activity it is reasnoable to assume that the CPU is not using the
VM because it is idle or runs a long term single CPU bound task.

A scapegoat CPU is picked to serve to periodically monitor
CPUs that have their vmstat_update work stopped and re-schedule them
if VM activity is detected. The scapegoat CPU never stops its
vmstat_update work item instance.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
CC: Christoph Lameter <cl@linux.com>
CC: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
CC: linux-kernel@vger.kernel.org
CC: linux-mm@kvack.org
---
 include/linux/vmstat.h |    2 +-
 mm/vmstat.c            |   92 ++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 79 insertions(+), 15 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index c586679..a30ab79 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -198,7 +198,7 @@ extern void __inc_zone_state(struct zone *, enum zone_stat_item);
 extern void dec_zone_state(struct zone *, enum zone_stat_item);
 extern void __dec_zone_state(struct zone *, enum zone_stat_item);
 
-void refresh_cpu_vm_stats(int);
+bool refresh_cpu_vm_stats(int);
 void refresh_zone_stat_thresholds(void);
 
 void drain_zonestat(struct zone *zone, struct per_cpu_pageset *);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index f42745e..6143c70 100644
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
@@ -432,11 +433,12 @@ EXPORT_SYMBOL(dec_zone_page_state);
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
@@ -483,14 +485,21 @@ void refresh_cpu_vm_stats(int cpu)
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
 
 /*
@@ -1172,24 +1181,69 @@ static const struct file_operations proc_vmstat_file_operations = {
 #endif /* CONFIG_PROC_FS */
 
 #ifdef CONFIG_SMP
+
+#define VMSTAT_NO_CPU (-1)
+
 static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
 int sysctl_stat_interval __read_mostly = HZ;
+static struct cpumask vmstat_cpus;
+static int vmstat_monitor_cpu __read_mostly = VMSTAT_NO_CPU;
 
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
 
-	INIT_DEFERRABLE_WORK(work, vmstat_update);
+	cpumask_set_cpu(cpu, &vmstat_cpus);
 	schedule_delayed_work_on(cpu, work, __round_jiffies_relative(HZ, cpu));
 }
 
+static void __cpuinit setup_cpu_timer(int cpu)
+{
+	struct delayed_work *work = &per_cpu(vmstat_work, cpu);
+
+	INIT_DEFERRABLE_WORK(work, vmstat_update);
+	start_cpu_timer(cpu);
+}
+
+static void vmstat_update(struct work_struct *w)
+{
+	int cpu, this_cpu = smp_processor_id();
+
+	if (unlikely(this_cpu == vmstat_monitor_cpu))
+		for_each_cpu_not(cpu, &vmstat_cpus)
+			if (need_vmstat(cpu))
+				start_cpu_timer(cpu);
+
+	if (likely(refresh_cpu_vm_stats(this_cpu) || (this_cpu == vmstat_monitor_cpu)))
+		schedule_delayed_work(&__get_cpu_var(vmstat_work),
+				round_jiffies_relative(sysctl_stat_interval));
+	else
+		cpumask_clear_cpu(this_cpu, &vmstat_cpus);
+}
+
 /*
  * Use the cpu notifier to insure that the thresholds are recalculated
  * when necessary.
@@ -1204,17 +1258,25 @@ static int __cpuinit vmstat_cpuup_callback(struct notifier_block *nfb,
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
+		if (cpumask_test_cpu(cpu, &vmstat_cpus)) {
+			cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
+			per_cpu(vmstat_work, cpu).work.func = NULL;
+			if(cpu == vmstat_monitor_cpu) {
+				int this_cpu = smp_processor_id();
+				vmstat_monitor_cpu = this_cpu;
+				if (!cpumask_test_cpu(this_cpu, &vmstat_cpus))
+					start_cpu_timer(this_cpu);
+			}
+		}
 		break;
 	case CPU_DOWN_FAILED:
 	case CPU_DOWN_FAILED_FROZEN:
-		start_cpu_timer(cpu);
+		setup_cpu_timer(cpu);
 		break;
 	case CPU_DEAD:
 	case CPU_DEAD_FROZEN:
@@ -1237,8 +1299,10 @@ static int __init setup_vmstat(void)
 
 	register_cpu_notifier(&vmstat_notifier);
 
+	vmstat_monitor_cpu = smp_processor_id();
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
