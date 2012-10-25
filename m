Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id C196F6B0096
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 09:09:33 -0400 (EDT)
Message-Id: <20121025124834.720647725@chello.nl>
Date: Thu, 25 Oct 2012 14:16:47 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 30/31] sched, numa, mm: Implement slow start for working set sampling
References: <20121025121617.617683848@chello.nl>
Content-Disposition: inline; filename=0030-sched-numa-mm-Implement-slow-start-for-working-set-s.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>

Add a 1 second delay before starting to scan the working set of
a task and starting to balance it amongst nodes.

[ note that before the constant per task WSS sampling rate patch
  the initial scan would happen much later still, in effect that
  patch caused this regression. ]

The theory is that short-run tasks benefit very little from NUMA
placement: they come and go, and they better stick to the node
they were started on. As tasks mature and rebalance to other CPUs
and nodes, so does their NUMA placement have to change and so
does it start to matter more and more.

In practice this change fixes an observable kbuild regression:

   # [ a perf stat --null --repeat 10 test of ten bzImage builds to /dev/shm ]

   !NUMA:
   45.291088843 seconds time elapsed                                          ( +-  0.40% )
   45.154231752 seconds time elapsed                                          ( +-  0.36% )

   +NUMA, no slow start:
   46.172308123 seconds time elapsed                                          ( +-  0.30% )
   46.343168745 seconds time elapsed                                          ( +-  0.25% )

   +NUMA, 1 sec slow start:
   45.224189155 seconds time elapsed                                          ( +-  0.25% )
   45.160866532 seconds time elapsed                                          ( +-  0.17% )

and it also fixes an observable perf bench (hackbench) regression:

   # perf stat --null --repeat 10 perf bench sched messaging

   -NUMA:

   -NUMA:                  0.246225691 seconds time elapsed                   ( +-  1.31% )
   +NUMA no slow start:    0.252620063 seconds time elapsed                   ( +-  1.13% )

   +NUMA 1sec delay:       0.248076230 seconds time elapsed                   ( +-  1.35% )

The implementation is simple and straightforward, most of the patch
deals with adding the /proc/sys/kernel/sched_numa_scan_delay_ms tunable
knob.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
[ Wrote the changelog, ran measurements, tuned the default. ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/sched.h |    1 +
 kernel/sched/core.c   |    2 +-
 kernel/sched/fair.c   |   11 +++++++----
 kernel/sysctl.c       |    7 +++++++
 4 files changed, 16 insertions(+), 5 deletions(-)

Index: tip/include/linux/sched.h
===================================================================
--- tip.orig/include/linux/sched.h
+++ tip/include/linux/sched.h
@@ -2020,6 +2020,7 @@ enum sched_tunable_scaling {
 };
 extern enum sched_tunable_scaling sysctl_sched_tunable_scaling;
 
+extern unsigned int sysctl_sched_numa_scan_delay;
 extern unsigned int sysctl_sched_numa_scan_period_min;
 extern unsigned int sysctl_sched_numa_scan_period_max;
 extern unsigned int sysctl_sched_numa_scan_size;
Index: tip/kernel/sched/core.c
===================================================================
--- tip.orig/kernel/sched/core.c
+++ tip/kernel/sched/core.c
@@ -1545,7 +1545,7 @@ static void __sched_fork(struct task_str
 	p->numa_scan_seq = p->mm ? p->mm->numa_scan_seq : 0;
 	p->numa_migrate_seq = p->mm ? p->mm->numa_scan_seq - 1 : 0;
 	p->numa_faults = NULL;
-	p->numa_scan_period = sysctl_sched_numa_scan_period_min;
+	p->numa_scan_period = sysctl_sched_numa_scan_delay;
 	p->numa_work.next = &p->numa_work;
 #endif /* CONFIG_SCHED_NUMA */
 }
Index: tip/kernel/sched/fair.c
===================================================================
--- tip.orig/kernel/sched/fair.c
+++ tip/kernel/sched/fair.c
@@ -827,11 +827,12 @@ static void account_numa_dequeue(struct
 }
 
 /*
- * numa task sample period in ms: 5s
+ * Scan @scan_size MB every @scan_period after an initial @scan_delay.
  */
-unsigned int sysctl_sched_numa_scan_period_min = 100;
-unsigned int sysctl_sched_numa_scan_period_max = 100*16;
-unsigned int sysctl_sched_numa_scan_size = 256;   /* MB */
+unsigned int sysctl_sched_numa_scan_delay = 1000;	/* ms */
+unsigned int sysctl_sched_numa_scan_period_min = 100;	/* ms */
+unsigned int sysctl_sched_numa_scan_period_max = 100*16;/* ms */
+unsigned int sysctl_sched_numa_scan_size = 256;		/* MB */
 
 /*
  * Wait for the 2-sample stuff to settle before migrating again
@@ -985,6 +986,8 @@ void task_tick_numa(struct rq *rq, struc
 	period = (u64)curr->numa_scan_period * NSEC_PER_MSEC;
 
 	if (now - curr->node_stamp > period) {
+		if (!curr->node_stamp)
+			curr->numa_scan_period = sysctl_sched_numa_scan_period_min;
 		curr->node_stamp = now;
 
 		if (!time_before(jiffies, curr->mm->numa_next_scan)) {
Index: tip/kernel/sysctl.c
===================================================================
--- tip.orig/kernel/sysctl.c
+++ tip/kernel/sysctl.c
@@ -353,6 +353,13 @@ static struct ctl_table kern_table[] = {
 #endif /* CONFIG_SMP */
 #ifdef CONFIG_SCHED_NUMA
 	{
+		.procname	= "sched_numa_scan_delay_ms",
+		.data		= &sysctl_sched_numa_scan_delay,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "sched_numa_scan_period_min_ms",
 		.data		= &sysctl_sched_numa_scan_period_min,
 		.maxlen		= sizeof(unsigned int),


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
