Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id F19CF82F69
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 13:10:54 -0500 (EST)
Received: by mail-io0-f169.google.com with SMTP id 9so187719903iom.1
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 10:10:54 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id 89si42258138iok.84.2016.02.22.10.10.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 22 Feb 2016 10:10:54 -0800 (PST)
Message-Id: <20160222181049.953663183@linux.com>
Date: Mon, 22 Feb 2016 12:10:42 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [patch 2/2] vmstat: Get rid of the ugly cpu_stat_off variable
References: <20160222181040.553533936@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=vmstat_no_cpu_off
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@kernel.org>, Tejun Heo <htejun@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, hannes@cmpxchg.org, mgorman@suse.de

The cpu_stat_off variable is unecessary since we can check if
a workqueue request is pending otherwise. This makes it pretty
easy for the shepherd to ensure that the proper things happen.

Removing the state also removes all races related to it.
Should a workqueue not be scheduled as needed for vmstat_update
then the shepherd will notice and schedule it as needed.
Should a workqueue be unecessarily scheduled then the vmstat
updater will disable it.

Thus vmstat_idle can also be simplified.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c	2016-02-22 11:55:59.432096146 -0600
+++ linux/mm/vmstat.c	2016-02-22 12:01:22.883825094 -0600
@@ -1401,7 +1401,6 @@ static const struct file_operations proc
 static struct workqueue_struct *vmstat_wq;
 static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
 int sysctl_stat_interval __read_mostly = HZ;
-static cpumask_var_t cpu_stat_off;
 
 static void vmstat_update(struct work_struct *w)
 {
@@ -1414,15 +1413,6 @@ static void vmstat_update(struct work_st
 		queue_delayed_work_on(smp_processor_id(), vmstat_wq,
 			this_cpu_ptr(&vmstat_work),
 			round_jiffies_relative(sysctl_stat_interval));
-	} else {
-		/*
-		 * We did not update any counters so the app may be in
-		 * a mode where it does not cause counter updates.
-		 * We may be uselessly running vmstat_update.
-		 * Defer the checking for differentials to the
-		 * shepherd thread on a different processor.
-		 */
-		cpumask_set_cpu(smp_processor_id(), cpu_stat_off);
 	}
 }
 
@@ -1436,11 +1426,8 @@ void quiet_vmstat(void)
 	if (system_state != SYSTEM_RUNNING)
 		return;
 
-	do {
-		if (!cpumask_test_and_set_cpu(smp_processor_id(), cpu_stat_off))
-			cancel_delayed_work(this_cpu_ptr(&vmstat_work));
-
-	} while (refresh_cpu_vm_stats(false));
+	refresh_cpu_vm_stats(false);
+	cancel_delayed_work(this_cpu_ptr(&vmstat_work));
 }
 
 /*
@@ -1476,13 +1463,12 @@ static void vmstat_shepherd(struct work_
 
 	get_online_cpus();
 	/* Check processors whose vmstat worker threads have been disabled */
-	for_each_cpu(cpu, cpu_stat_off)
-		if (need_update(cpu) &&
-			cpumask_test_and_clear_cpu(cpu, cpu_stat_off))
-
-			queue_delayed_work_on(cpu, vmstat_wq,
-				&per_cpu(vmstat_work, cpu), 0);
+	for_each_online_cpu(cpu) {
+		struct delayed_work *worker = &per_cpu(vmstat_work, cpu);
 
+		if (!delayed_work_pending(worker) && need_update(cpu))
+			queue_delayed_work_on(cpu, vmstat_wq, worker, 0);
+	}
 	put_online_cpus();
 
 	schedule_delayed_work(&shepherd,
@@ -1498,10 +1484,6 @@ static void __init start_shepherd_timer(
 		INIT_DELAYED_WORK(per_cpu_ptr(&vmstat_work, cpu),
 			vmstat_update);
 
-	if (!alloc_cpumask_var(&cpu_stat_off, GFP_KERNEL))
-		BUG();
-	cpumask_copy(cpu_stat_off, cpu_online_mask);
-
 	vmstat_wq = alloc_workqueue("vmstat", WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);
 	schedule_delayed_work(&shepherd,
 		round_jiffies_relative(sysctl_stat_interval));
@@ -1536,16 +1518,13 @@ static int vmstat_cpuup_callback(struct
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
