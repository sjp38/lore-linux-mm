Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 0D7F46B00AA
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:24:45 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 28/49] mm: sched: numa: Implement slow start for working set sampling
Date: Fri,  7 Dec 2012 10:23:31 +0000
Message-Id: <1354875832-9700-29-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

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
deals with adding the /proc/sys/kernel/balance_numa_scan_delay_ms tunable
knob.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
[ Wrote the changelog, ran measurements, tuned the default. ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 include/linux/sched.h |    1 +
 kernel/sched/core.c   |    2 +-
 kernel/sched/fair.c   |    5 +++++
 kernel/sysctl.c       |    7 +++++++
 4 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index abb1c70..a2b06ea 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2006,6 +2006,7 @@ enum sched_tunable_scaling {
 };
 extern enum sched_tunable_scaling sysctl_sched_tunable_scaling;
 
+extern unsigned int sysctl_balance_numa_scan_delay;
 extern unsigned int sysctl_balance_numa_scan_period_min;
 extern unsigned int sysctl_balance_numa_scan_period_max;
 extern unsigned int sysctl_balance_numa_scan_size;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 81fa185..047e3c7 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1543,7 +1543,7 @@ static void __sched_fork(struct task_struct *p)
 	p->node_stamp = 0ULL;
 	p->numa_scan_seq = p->mm ? p->mm->numa_scan_seq : 0;
 	p->numa_migrate_seq = p->mm ? p->mm->numa_scan_seq - 1 : 0;
-	p->numa_scan_period = sysctl_balance_numa_scan_period_min;
+	p->numa_scan_period = sysctl_balance_numa_scan_delay;
 	p->numa_work.next = &p->numa_work;
 #endif /* CONFIG_BALANCE_NUMA */
 }
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 773ef97..2e65f44 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -788,6 +788,9 @@ unsigned int sysctl_balance_numa_scan_period_max = 100*16;
 /* Portion of address space to scan in MB */
 unsigned int sysctl_balance_numa_scan_size = 256;
 
+/* Scan @scan_size MB every @scan_period after an initial @scan_delay in ms */
+unsigned int sysctl_balance_numa_scan_delay = 1000;
+
 static void task_numa_placement(struct task_struct *p)
 {
 	int seq = ACCESS_ONCE(p->mm->numa_scan_seq);
@@ -929,6 +932,8 @@ void task_tick_numa(struct rq *rq, struct task_struct *curr)
 	period = (u64)curr->numa_scan_period * NSEC_PER_MSEC;
 
 	if (now - curr->node_stamp > period) {
+		if (!curr->node_stamp)
+			curr->numa_scan_period = sysctl_balance_numa_scan_period_min;
 		curr->node_stamp = now;
 
 		if (!time_before(jiffies, curr->mm->numa_next_scan)) {
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index d191203..5ee587d 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -353,6 +353,13 @@ static struct ctl_table kern_table[] = {
 #endif /* CONFIG_SMP */
 #ifdef CONFIG_BALANCE_NUMA
 	{
+		.procname	= "balance_numa_scan_delay_ms",
+		.data		= &sysctl_balance_numa_scan_delay,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "balance_numa_scan_period_min_ms",
 		.data		= &sysctl_balance_numa_scan_period_min,
 		.maxlen		= sizeof(unsigned int),
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
