Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3AA436B0262
	for <linux-mm@kvack.org>; Fri,  6 May 2016 14:10:20 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id e63so264639012iod.2
        for <linux-mm@kvack.org>; Fri, 06 May 2016 11:10:20 -0700 (PDT)
Received: from resqmta-po-06v.sys.comcast.net (resqmta-po-06v.sys.comcast.net. [2001:558:fe16:19:96:114:154:165])
        by mx.google.com with ESMTPS id 92si18770441iog.75.2016.05.06.11.10.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 May 2016 11:10:19 -0700 (PDT)
Date: Fri, 6 May 2016 13:09:49 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH] vmstat: Get rid of the ugly cpu_stat_off variable V2
Message-ID: <alpine.DEB.2.20.1605061306460.17934@east.gentwo.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tejun Heo <htejun@gmail.com>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

The cpu_stat_off variable is unecessary since we can check if
a workqueue request is pending otherwise. Removal of
cpu_stat_off makes it pretty easy for the vmstat shepherd to
ensure that the proper things happen.

Removing the state also removes all races related to it.
Should a workqueue not be scheduled as needed for vmstat_update
then the shepherd will notice and schedule it as needed.
Should a workqueue be unecessarily scheduled then the vmstat
updater will disable it.

V1->V2:
 - Rediff to proper upstream version

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c
+++ linux/mm/vmstat.c
@@ -1376,42 +1376,21 @@ static const struct file_operations proc
 static struct workqueue_struct *vmstat_wq;
 static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
 int sysctl_stat_interval __read_mostly = HZ;
-static cpumask_var_t cpu_stat_off;

 static void vmstat_update(struct work_struct *w)
 {
-	if (refresh_cpu_vm_stats(true)) {
+	if (refresh_cpu_vm_stats(true))
 		/*
 		 * Counters were updated so we expect more updates
 		 * to occur in the future. Keep on running the
 		 * update worker thread.
-		 * If we were marked on cpu_stat_off clear the flag
-		 * so that vmstat_shepherd doesn't schedule us again.
 		 */
-		if (!cpumask_test_and_clear_cpu(smp_processor_id(),
-						cpu_stat_off)) {
-			queue_delayed_work_on(smp_processor_id(), vmstat_wq,
+		queue_delayed_work_on(smp_processor_id(), vmstat_wq,
 				this_cpu_ptr(&vmstat_work),
 				round_jiffies_relative(sysctl_stat_interval));
-		}
-	} else {
-		/*
-		 * We did not update any counters so the app may be in
-		 * a mode where it does not cause counter updates.
-		 * We may be uselessly running vmstat_update.
-		 * Defer the checking for differentials to the
-		 * shepherd thread on a different processor.
-		 */
-		cpumask_set_cpu(smp_processor_id(), cpu_stat_off);
-	}
 }

 /*
- * Switch off vmstat processing and then fold all the remaining differentials
- * until the diffs stay at zero. The function is used by NOHZ and can only be
- * invoked when tick processing is not active.
- */
-/*
  * Check if the diffs for a certain cpu indicate that
  * an update is needed.
  */
@@ -1434,16 +1413,17 @@ static bool need_update(int cpu)
 	return false;
 }

+/*
+ * Switch off vmstat processing and then fold all the remaining differentials
+ * until the diffs stay at zero. The function is used by NOHZ and can only be
+ * invoked when tick processing is not active.
+ */
 void quiet_vmstat(void)
 {
 	if (system_state != SYSTEM_RUNNING)
 		return;

-	/*
-	 * If we are already in hands of the shepherd then there
-	 * is nothing for us to do here.
-	 */
-	if (cpumask_test_and_set_cpu(smp_processor_id(), cpu_stat_off))
+	if (!delayed_work_pending(this_cpu_ptr(&vmstat_work)))
 		return;

 	if (!need_update(smp_processor_id()))
@@ -1458,7 +1438,6 @@ void quiet_vmstat(void)
 	refresh_cpu_vm_stats(false);
 }

-
 /*
  * Shepherd worker thread that checks the
  * differentials of processors that have their worker
@@ -1475,20 +1454,11 @@ static void vmstat_shepherd(struct work_

 	get_online_cpus();
 	/* Check processors whose vmstat worker threads have been disabled */
-	for_each_cpu(cpu, cpu_stat_off) {
+	for_each_online_cpu(cpu) {
 		struct delayed_work *dw = &per_cpu(vmstat_work, cpu);

-		if (need_update(cpu)) {
-			if (cpumask_test_and_clear_cpu(cpu, cpu_stat_off))
+		if (!delayed_work_pending(dw) && need_update(cpu))
 				queue_delayed_work_on(cpu, vmstat_wq, dw, 0);
-		} else {
-			/*
-			 * Cancel the work if quiet_vmstat has put this
-			 * cpu on cpu_stat_off because the work item might
-			 * be still scheduled
-			 */
-			cancel_delayed_work(dw);
-		}
 	}
 	put_online_cpus();

@@ -1504,10 +1474,6 @@ static void __init start_shepherd_timer(
 		INIT_DEFERRABLE_WORK(per_cpu_ptr(&vmstat_work, cpu),
 			vmstat_update);

-	if (!alloc_cpumask_var(&cpu_stat_off, GFP_KERNEL))
-		BUG();
-	cpumask_copy(cpu_stat_off, cpu_online_mask);
-
 	vmstat_wq = alloc_workqueue("vmstat", WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);
 	schedule_delayed_work(&shepherd,
 		round_jiffies_relative(sysctl_stat_interval));
@@ -1542,16 +1508,13 @@ static int vmstat_cpuup_callback(struct
 	case CPU_ONLINE_FROZEN:
 		refresh_zone_stat_thresholds();
 		node_set_state(cpu_to_node(cpu), N_CPU);
-		cpumask_set_cpu(cpu, cpu_stat_off);
 		break;
 	case CPU_DOWN_PREPARE:
 	case CPU_DOWN_PREPARE_FROZEN:
 		cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
-		cpumask_clear_cpu(cpu, cpu_stat_off);
 		break;
 	case CPU_DOWN_FAILED:
 	case CPU_DOWN_FAILED_FROZEN:
-		cpumask_set_cpu(cpu, cpu_stat_off);
 		break;
 	case CPU_DEAD:
 	case CPU_DEAD_FROZEN:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
