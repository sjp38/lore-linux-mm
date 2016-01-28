Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id B004F6B0253
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 12:17:56 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id l66so20679311wml.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 09:17:56 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id 65si5401224wmg.21.2016.01.28.09.17.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 09:17:55 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id l66so5038483wml.2
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 09:17:55 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm, vmstat: make quiet_vmstat lighter
Date: Thu, 28 Jan 2016 18:17:45 +0100
Message-Id: <1454001466-27398-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1454001466-27398-1-git-send-email-mhocko@kernel.org>
References: <1454001466-27398-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cristopher Lameter <clameter@sgi.com>, Mike Galbraith <mgalbraith@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Mike has reported a considerable overhead of refresh_cpu_vm_stats from
the idle entry during pipe test:
    12.89%  [kernel]       [k] refresh_cpu_vm_stats.isra.12
     4.75%  [kernel]       [k] __schedule
     4.70%  [kernel]       [k] mutex_unlock
     3.14%  [kernel]       [k] __switch_to

This is caused by 0eb77e988032 ("vmstat: make vmstat_updater deferrable
again and shut down on idle") which has placed quiet_vmstat into
cpu_idle_loop. The main reason here seems to be that the idle entry has
to get over all zones and perform atomic operations for each vmstat
entry even though there might be no per cpu diffs. This is a pointless
overhead for _each_ idle entry.

Make sure that quiet_vmstat is as light as possible.

 First of all it doesn't make any sense to do any local sync if the
current cpu is already set in oncpu_stat_off because vmstat_update puts
itself there only if there is nothing to do.

Then we can check need_update which should be a cheap way to check for
potential per-cpu diffs and only then do refresh_cpu_vm_stats.

The original patch also did cancel_delayed_work which we are not doing
here. There are two reasons for that. Firstly cancel_delayed_work from
idle context will blow up on RT kernels (reported by Mike):
[    2.279582] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.5.0-rt3 #7
[    2.280444] Hardware name: MEDION MS-7848/MS-7848, BIOS M7848W08.20C 09/23/2013
[    2.281316]  ffff88040b00d640 ffff88040b01fe10 ffffffff812d20e2 0000000000000000
[    2.282202]  ffff88040b01fe30 ffffffff81081095 ffff88041ec4cee0 ffff88041ec501e0
[    2.283073]  ffff88040b01fe48 ffffffff815ff910 ffff88041ec4cee0 ffff88040b01fe88
[    2.283941] Call Trace:
[    2.284797]  [<ffffffff812d20e2>] dump_stack+0x49/0x67
[    2.285658]  [<ffffffff81081095>] ___might_sleep+0xf5/0x180
[    2.286521]  [<ffffffff815ff910>] rt_spin_lock+0x20/0x50
[    2.287382]  [<ffffffff81075919>] try_to_grab_pending+0x69/0x240
[    2.288239]  [<ffffffff81075b16>] cancel_delayed_work+0x26/0xe0
[    2.289094]  [<ffffffff8115ec05>] quiet_vmstat+0x75/0xa0
[    2.289949]  [<ffffffff8109ab38>] cpu_idle_loop+0x38/0x3e0
[    2.290800]  [<ffffffff8109aef3>] cpu_startup_entry+0x13/0x20
[    2.291647]  [<ffffffff81036164>] start_secondary+0x114/0x140

And secondly, even on !RT kernels it might add some non trivial overhead
which is not necessary. Even if the vmstat worker wakes up and preempts
idle then it will be most likely a single shot noop because the stats
were already synced and so it would end up on the oncpu_stat_off anyway.
We just need to teach both vmstat_shepherd and vmstat_update to stop
scheduling the worker if there is nothing to do.

Acked-by: Christoph Lameter <cl@linux.com>
Reported-by: Mike Galbraith <umgwanakikbuti@gmail.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/vmstat.c | 64 ++++++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 44 insertions(+), 20 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 40b2c74ddf16..eb30bf45bd55 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1396,10 +1396,15 @@ static void vmstat_update(struct work_struct *w)
 		 * Counters were updated so we expect more updates
 		 * to occur in the future. Keep on running the
 		 * update worker thread.
+		 * If we were marked on cpu_stat_off clear the flag
+		 * so that vmstat_shepherd doesn't schedule us again.
 		 */
-		queue_delayed_work_on(smp_processor_id(), vmstat_wq,
-			this_cpu_ptr(&vmstat_work),
-			round_jiffies_relative(sysctl_stat_interval));
+		if (!cpumask_test_and_clear_cpu(smp_processor_id(),
+						cpu_stat_off)) {
+			queue_delayed_work_on(smp_processor_id(), vmstat_wq,
+				this_cpu_ptr(&vmstat_work),
+				round_jiffies_relative(sysctl_stat_interval));
+		}
 	} else {
 		/*
 		 * We did not update any counters so the app may be in
@@ -1417,18 +1422,6 @@ static void vmstat_update(struct work_struct *w)
  * until the diffs stay at zero. The function is used by NOHZ and can only be
  * invoked when tick processing is not active.
  */
-void quiet_vmstat(void)
-{
-	if (system_state != SYSTEM_RUNNING)
-		return;
-
-	do {
-		if (!cpumask_test_and_set_cpu(smp_processor_id(), cpu_stat_off))
-			cancel_delayed_work(this_cpu_ptr(&vmstat_work));
-
-	} while (refresh_cpu_vm_stats(false));
-}
-
 /*
  * Check if the diffs for a certain cpu indicate that
  * an update is needed.
@@ -1452,6 +1445,30 @@ static bool need_update(int cpu)
 	return false;
 }
 
+void quiet_vmstat(void)
+{
+	if (system_state != SYSTEM_RUNNING)
+		return;
+
+	/*
+	 * If we are already in hands of the shepherd then there
+	 * is nothing for us to do here.
+	 */
+	if (cpumask_test_and_set_cpu(smp_processor_id(), cpu_stat_off))
+		return;
+
+	if (!need_update(smp_processor_id()))
+		return;
+
+	/*
+	 * Just refresh counters and do not care about the pending delayed
+	 * vmstat_update. It doesn't fire that often to matter and canceling
+	 * it would be too expensive from this path.
+	 * vmstat_shepherd will take care about that for us.
+	 */
+	refresh_cpu_vm_stats(false);
+}
+
 
 /*
  * Shepherd worker thread that checks the
@@ -1470,11 +1487,18 @@ static void vmstat_shepherd(struct work_struct *w)
 	get_online_cpus();
 	/* Check processors whose vmstat worker threads have been disabled */
 	for_each_cpu(cpu, cpu_stat_off)
-		if (need_update(cpu) &&
-			cpumask_test_and_clear_cpu(cpu, cpu_stat_off))
-
-			queue_delayed_work_on(cpu, vmstat_wq,
-				&per_cpu(vmstat_work, cpu), 0);
+		if (need_update(cpu)) {
+			if (cpumask_test_and_clear_cpu(cpu, cpu_stat_off))
+				queue_delayed_work_on(cpu, vmstat_wq,
+					&per_cpu(vmstat_work, cpu), 0);
+		} else {
+			/*
+			 * Cancel the work if quiet_vmstat has put this
+			 * cpu on cpu_stat_off because the work item might
+			 * be still scheduled
+			 */
+			cancel_delayed_work(this_cpu_ptr(&vmstat_work));
+		}
 
 	put_online_cpus();
 
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
