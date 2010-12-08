Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8DEB76B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 13:11:19 -0500 (EST)
Date: Wed, 8 Dec 2010 13:11:13 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1334413603.521181291831873850.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <1527296193.8541291447855619.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: Re: continuous oom caused system deadlock
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Bisect indicated that this is the first bad commit,

commit 696d3cd5fb318c070dc757fe109e04e398138172
Author: David Rientjes <rientjes@google.com>
Date:   Fri Jun 11 22:45:17 2010 +0200

    __out_of_memory() only has a single caller, so fold it into
    out_of_memory() and add a comment about locking for its call to
    oom_kill_process().
    
    Signed-off-by: David Rientjes <rientjes@google.com>
    Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
    Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index cba18c0..26ae697 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -628,41 +628,6 @@ static void clear_system_oom(void)
 	spin_unlock(&zone_scan_lock);
 }
 
-
-/*
- * Must be called with tasklist_lock held for read.
- */
-static void __out_of_memory(gfp_t gfp_mask, int order, const nodemask_t *mask)
-{
-	struct task_struct *p;
-	unsigned long points;
-
-	if (sysctl_oom_kill_allocating_task)
-		if (!oom_kill_process(current, gfp_mask, order, 0, NULL,
-				"Out of memory (oom_kill_allocating_task)"))
-			return;
-retry:
-	/*
-	 * Rambo mode: Shoot down a process and hope it solves whatever
-	 * issues we may have.
-	 */
-	p = select_bad_process(&points, NULL, mask);
-
-	if (PTR_ERR(p) == -1UL)
-		return;
-
-	/* Found nothing?!?! Either we hang forever, or we panic. */
-	if (!p) {
-		dump_header(NULL, gfp_mask, order, NULL);
-		read_unlock(&tasklist_lock);
-		panic("Out of memory and no killable processes...\n");
-	}
-
-	if (oom_kill_process(p, gfp_mask, order, points, NULL,
-			     "Out of memory"))
-		goto retry;
-}
-
 /**
  * out_of_memory - kill the "best" process when we run out of memory
  * @zonelist: zonelist pointer
@@ -678,7 +643,9 @@ retry:
 void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		int order, nodemask_t *nodemask)
 {
+	struct task_struct *p;
 	unsigned long freed = 0;
+	unsigned long points;
 	enum oom_constraint constraint = CONSTRAINT_NONE;
 
 	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
@@ -703,10 +670,36 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	if (zonelist)
 		constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
 	check_panic_on_oom(constraint, gfp_mask, order);
+
 	read_lock(&tasklist_lock);
-	__out_of_memory(gfp_mask, order,
+	if (sysctl_oom_kill_allocating_task) {
+		/*
+		 * oom_kill_process() needs tasklist_lock held.  If it returns
+		 * non-zero, current could not be killed so we must fallback to
+		 * the tasklist scan.
+		 */
+		if (!oom_kill_process(current, gfp_mask, order, 0, NULL,
+				"Out of memory (oom_kill_allocating_task)"))
+			return;
+	}
+
+retry:
+	p = select_bad_process(&points, NULL,
 			constraint == CONSTRAINT_MEMORY_POLICY ? nodemask :
 								 NULL);
+	if (PTR_ERR(p) == -1UL)
+		return;
+
+	/* Found nothing?!?! Either we hang forever, or we panic. */
+	if (!p) {
+		dump_header(NULL, gfp_mask, order, NULL);
+		read_unlock(&tasklist_lock);
+		panic("Out of memory and no killable processes...\n");
+	}
+
+	if (oom_kill_process(p, gfp_mask, order, points, NULL,
+			     "Out of memory"))
+		goto retry;
 	read_unlock(&tasklist_lock);
 
 	/*

> Running this LTP test a few times for mmotm tree caused system hung
> hard,
> http://people.redhat.com/qcai/oom01.c
> 
> I tried to bisect but only found it was also present in the tree a few
> months back as well.
> 
> SysRq-W output indicated that kswapd0 might stuck,
> [  373.943002] kswapd0       R  running task        0    34      2
> 0x00000000
> [  373.943002]  ffff88022abdbc80 ffffffff8146e4ce ffff88022abdbcb0
> ffffffff81232698
> [  373.943002]  0000000000000001 ffffffff81a248f0 0000000000000000
> 0000000000000000
> [  373.943002]  ffff88022abdbcc0 ffffffff8112d59d ffff88022abdbcd0
> ffffffff8146e4ce
> [  373.943002] Call Trace:
> [  373.943002]  [<ffffffff8146e4ce>] ? _raw_spin_lock+0xe/0x10
> [  373.943002]  [<ffffffff81232698>] ? __percpu_counter_sum+0x4d/0x63
> [  373.943002]  [<ffffffff8112d59d>] ? get_nr_inodes_unused+0x15/0x23
> [  373.943002]  [<ffffffff8146e4ce>] ? _raw_spin_lock+0xe/0x10
> [  373.943002]  [<ffffffff8146ea0e>] ? common_interrupt+0xe/0x13
> [  373.943002]  [<ffffffff810e2add>] ? balance_pgdat+0x29b/0x417
> [  373.943002]  [<ffffffff810e2e83>] ? kswapd+0x22a/0x240
> [  373.943002]  [<ffffffff8106af63>] ?
> autoremove_wake_function+0x0/0x39
> [  373.943002]  [<ffffffff810e2c59>] ? kswapd+0x0/0x240
> [  373.943002]  [<ffffffff8106aaae>] ? kthread+0x82/0x8a
> [  373.943002]  [<ffffffff8100bae4>] ? kernel_thread_helper+0x4/0x10
> [  373.943002]  [<ffffffff8106aa2c>] ? kthread+0x0/0x8a
> [  373.943002]  [<ffffffff8100bae0>] ? kernel_thread_helper+0x0/0x10
> 
> full SysRq-W output:
> [  373.943002] Sched Debug Version: v0.09, 2.6.37-rc3+ #1
> [  373.943002] now at 381511.273166 msecs
> [  373.943002]   .jiffies                                 :
> 4295041238
> [  373.943002]   .sysctl_sched_latency                    : 18.000000
> [  373.943002]   .sysctl_sched_min_granularity            : 2.250000
> [  373.943002]   .sysctl_sched_wakeup_granularity         : 3.000000
> [  373.943002]   .sysctl_sched_child_runs_first           : 0
> [  373.943002]   .sysctl_sched_features                   : 31855
> [  373.943002]   .sysctl_sched_tunable_scaling            : 1
> (logaritmic)
> [  373.943002] 
> [  373.943002] cpu#0, 2826.236 MHz
> [  373.943002]   .nr_running                    : 1
> [  373.943002]   .load                          : 1024
> [  373.943002]   .nr_switches                   : 69769
> [  373.943002]   .nr_load_updates               : 115459
> [  373.943002]   .nr_uninterruptible            : 0
> [  373.943002]   .next_balance                  : 4295.041289
> [  373.943002]   .curr->pid                     : 34
> [  373.943002]   .clock                         : 373942.002254
> [  373.943002]   .cpu_load[0]                   : 1024
> [  373.943002]   .cpu_load[1]                   : 1024
> [  373.943002]   .cpu_load[2]                   : 1024
> [  373.943002]   .cpu_load[3]                   : 1024
> [  373.943002]   .cpu_load[4]                   : 1024
> [  373.943002]   .yld_count                     : 100
> [  373.943002]   .sched_switch                  : 0
> [  373.943002]   .sched_count                   : 82123
> [  373.943002]   .sched_goidle                  : 26687
> [  373.943002]   .avg_idle                      : 1000000
> [  373.943002]   .ttwu_count                    : 30804
> [  373.943002]   .ttwu_local                    : 8525
> [  373.943002]   .bkl_count                     : 0
> [  373.943002] 
> [  373.943002] cfs_rq[0]:/
> [  373.943002]   .exec_clock                    : 107322.196661
> [  373.943002]   .MIN_vruntime                  : 0.000001
> [  373.943002]   .min_vruntime                  : 55990.920524
> [  373.943002]   .max_vruntime                  : 0.000001
> [  373.943002]   .spread                        : 0.000000
> [  373.943002]   .spread0                       : 0.000000
> [  373.943002]   .nr_running                    : 1
> [  373.943002]   .load                          : 1024
> [  373.943002]   .nr_spread_over                : 9
> [  373.943002]   .shares                        : 0
> [  373.943002] 
> [  373.943002] rt_rq[0]:/
> [  373.943002]   .rt_nr_running                 : 0
> [  373.943002]   .rt_throttled                  : 0
> [  373.943002]   .rt_time                       : 0.000000
> [  373.943002]   .rt_runtime                    : 1000.000000
> [  373.943002] 
> [  373.943002] runnable tasks:
> [  373.943002]             task   PID         tree-key  switches  prio
>     exec-runtime         sum-exec        sum-sleep
> [  373.943002]
> ----------------------------------------------------------------------------------------------------------
> [  373.943002] R        kswapd0    34     55990.920524     43568   120
>     55990.920524     38575.283576    287944.752314 /
> [  373.943002] 
> [  373.943002] cpu#1, 2826.236 MHz
> [  373.943002]   .nr_running                    : 2
> [  373.943002]   .load                          : 2048
> [  373.943002]   .nr_switches                   : 80939
> [  373.943002]   .nr_load_updates               : 141862
> [  373.943002]   .nr_uninterruptible            : 1
> [  373.943002]   .next_balance                  : 4295.041423
> [  373.943002]   .curr->pid                     : 925
> [  373.943002]   .clock                         : 382530.001465
> [  373.943002]   .cpu_load[0]                   : 2048
> [  373.943002]   .cpu_load[1]                   : 1920
> [  373.943002]   .cpu_load[2]                   : 1806
> [  373.943002]   .cpu_load[3]                   : 1743
> [  373.943002]   .cpu_load[4]                   : 1716
> [  373.943002]   .yld_count                     : 127
> [  373.943002]   .sched_switch                  : 0
> [  373.943002]   .sched_count                   : 87429
> [  373.943002]   .sched_goidle                  : 29877
> [  373.943002]   .avg_idle                      : 1000000
> [  373.943002]   .ttwu_count                    : 33588
> [  373.943002]   .ttwu_local                    : 9295
> [  373.943002]   .bkl_count                     : 0
> [  373.943002] 
> [  373.943002] cfs_rq[1]:/
> [  373.943002]   .exec_clock                    : 132931.075561
> [  373.943002]   .MIN_vruntime                  : 66573.481283
> [  373.943002]   .min_vruntime                  : 66573.481283
> [  373.943002]   .max_vruntime                  : 66573.481283
> [  373.943002]   .spread                        : 0.000000
> [  373.943002]   .spread0                       : 10582.560759
> [  373.943002]   .nr_running                    : 2
> [  373.943002]   .load                          : 2048
> [  373.943002]   .nr_spread_over                : 10
> [  373.943002]   .shares                        : 0
> [  373.943002] 
> [  373.943002] rt_rq[1]:/
> [  373.943002]   .rt_nr_running                 : 0
> [  373.943002]   .rt_throttled                  : 0
> [  373.943002]   .rt_time                       : 0.000000
> [  373.943002]   .rt_runtime                    : 850.000000
> [  373.943002] 
> [  373.943002] runnable tasks:
> [  373.943002]             task   PID         tree-key  switches  prio
>     exec-runtime         sum-exec        sum-sleep
> [  373.943002]
> ----------------------------------------------------------------------------------------------------------
> [  373.943002] R        rpcbind   925     75167.155023      3118   120
>     75167.155023     33682.358086    277604.838691 /
> [  373.943002]  console-kit-dae  1328     66573.481283       716   120
>     66573.481283      2306.020280    277814.482610 /
> [  373.943002] 
> [  373.943002] cpu#2, 2826.236 MHz
> [  373.943002]   .nr_running                    : 1
> [  373.943002]   .load                          : 1024
> [  373.943002]   .nr_switches                   : 25657
> [  373.943002]   .nr_load_updates               : 133265
> [  373.943002]   .nr_uninterruptible            : 6
> [  373.943002]   .next_balance                  : 4295.041381
> [  373.943002]   .curr->pid                     : 1473
> [  373.943002]   .clock                         : 382530.001959
> [  373.943002]   .cpu_load[0]                   : 1024
> [  373.943002]   .cpu_load[1]                   : 732
> [  373.943002]   .cpu_load[2]                   : 703
> [  373.943002]   .cpu_load[3]                   : 726
> [  373.943002]   .cpu_load[4]                   : 777
> [  373.943002]   .yld_count                     : 143
> [  373.943002]   .sched_switch                  : 0
> [  373.943002]   .sched_count                   : 33466
> [  373.943002]   .sched_goidle                  : 5814
> [  373.943002]   .avg_idle                      : 1000000
> [  373.943002]   .ttwu_count                    : 9228
> [  373.943002]   .ttwu_local                    : 6942
> [  373.943002]   .bkl_count                     : 0
> [  373.943002] 
> [  373.943002] cfs_rq[2]:/
> [  373.943002]   .exec_clock                    : 125235.081389
> [  373.943002]   .MIN_vruntime                  : 0.000001
> [  373.943002]   .min_vruntime                  : 64653.378538
> [  373.943002]   .max_vruntime                  : 0.000001
> [  373.943002]   .spread                        : 0.000000
> [  373.943002]   .spread0                       : 8662.458014
> [  373.943002]   .nr_running                    : 1
> [  373.943002]   .load                          : 1024
> [  373.943002]   .nr_spread_over                : 28
> [  373.943002]   .shares                        : 0
> [  373.943002] 
> [  373.943002] rt_rq[2]:/
> [  373.943002]   .rt_nr_running                 : 0
> [  373.943002]   .rt_throttled                  : 0
> [  373.943002]   .rt_time                       : 0.000000
> [  373.943002]   .rt_runtime                    : 1000.000000
> [  373.943002] 
> [  373.943002] runnable tasks:
> [  373.943002]             task   PID         tree-key  switches  prio
>     exec-runtime         sum-exec        sum-sleep
> [  373.943002]
> ----------------------------------------------------------------------------------------------------------
> [  373.943002] R          oom01  1473     64653.378538      3405   120
>     64653.378538     44153.912865      3897.833338 /
> [  373.943002] 
> [  373.943002] cpu#3, 2826.236 MHz
> [  373.943002]   .nr_running                    : 2
> [  373.943002]   .load                          : 2048
> [  373.943002]   .nr_switches                   : 27316
> [  373.943002]   .nr_load_updates               : 137905
> [  373.943002]   .nr_uninterruptible            : 5
> [  373.943002]   .next_balance                  : 4295.041253
> [  373.943002]   .curr->pid                     : 1336
> [  373.943002]   .clock                         : 382530.002311
> [  373.943002]   .cpu_load[0]                   : 2048
> [  373.943002]   .cpu_load[1]                   : 1980
> [  373.943002]   .cpu_load[2]                   : 1820
> [  373.943002]   .cpu_load[3]                   : 1754
> [  373.943002]   .cpu_load[4]                   : 1790
> [  373.943002]   .yld_count                     : 9
> [  373.943002]   .sched_switch                  : 0
> [  373.943002]   .sched_count                   : 36031
> [  373.943002]   .sched_goidle                  : 6309
> [  373.943002]   .avg_idle                      : 1000000
> [  373.943002]   .ttwu_count                    : 9803
> [  373.943002]   .ttwu_local                    : 7501
> [  373.943002]   .bkl_count                     : 0
> [  373.943002] 
> [  373.943002] cfs_rq[3]:/
> [  373.943002]   .exec_clock                    : 131690.185382
> [  373.943002]   .MIN_vruntime                  : 72546.296158
> [  373.943002]   .min_vruntime                  : 72546.296158
> [  373.943002]   .max_vruntime                  : 72546.296158
> [  373.943002]   .spread                        : 0.000000
> [  373.943002]   .spread0                       : 16555.375634
> [  373.943002]   .nr_running                    : 2
> [  373.943002]   .load                          : 2048
> [  373.943002]   .nr_spread_over                : 4
> [  373.943002]   .shares                        : 0
> [  373.943002] 
> [  373.943002] rt_rq[3]:/
> [  373.943002]   .rt_nr_running                 : 0
> [  373.943002]   .rt_throttled                  : 0
> [  373.943002]   .rt_time                       : 0.000000
> [  373.943002]   .rt_runtime                    : 950.000000
> [  373.943002] 
> [  373.943002] runnable tasks:
> [  373.943002]             task   PID         tree-key  switches  prio
>     exec-runtime         sum-exec        sum-sleep
> [  373.943002]
> ----------------------------------------------------------------------------------------------------------
> [  373.943002]       irqbalance   908     72546.296158      5882   120
>     72546.296158     30782.122083    264942.728048 /
> [  373.943002] R           bash  1336     81138.830657       744   120
>     81138.830657     10827.322162    278614.352123 /
> [  373.943002] 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
