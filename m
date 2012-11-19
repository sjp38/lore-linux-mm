Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 114BF6B008C
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 21:16:06 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so3182484eek.14
        for <linux-mm@kvack.org>; Sun, 18 Nov 2012 18:16:05 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 21/27] sched: Implement slow start for working set sampling
Date: Mon, 19 Nov 2012 03:14:38 +0100
Message-Id: <1353291284-2998-22-git-send-email-mingo@kernel.org>
In-Reply-To: <1353291284-2998-1-git-send-email-mingo@kernel.org>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

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
deals with adding the /proc/sys/kernel/sched_numa_scan_delay_ms tunable
knob.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Link: http://lkml.kernel.org/n/tip-vn7p3ynbwqt3qqewhdlvjltc@git.kernel.org
[ Wrote the changelog, ran measurements, tuned the default. ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/sched.h |  1 +
 kernel/sched/core.c   |  2 +-
 kernel/sched/fair.c   | 16 ++++++++++------
 kernel/sysctl.c       |  7 +++++++
 4 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 3372aac..8f65323 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2045,6 +2045,7 @@ enum sched_tunable_scaling {
 };
 extern enum sched_tunable_scaling sysctl_sched_tunable_scaling;
 
+extern unsigned int sysctl_sched_numa_scan_delay;
 extern unsigned int sysctl_sched_numa_scan_period_min;
 extern unsigned int sysctl_sched_numa_scan_period_max;
 extern unsigned int sysctl_sched_numa_scan_size;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 7b58366..af0602f 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1556,7 +1556,7 @@ static void __sched_fork(struct task_struct *p)
 	p->numa_scan_seq = p->mm ? p->mm->numa_scan_seq : 0;
 	p->numa_migrate_seq = 2;
 	p->numa_faults = NULL;
-	p->numa_scan_period = sysctl_sched_numa_scan_period_min;
+	p->numa_scan_period = sysctl_sched_numa_scan_delay;
 	p->numa_work.next = &p->numa_work;
 #endif /* CONFIG_NUMA_BALANCING */
 }
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index da28315..8f0e6ba 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -823,11 +823,12 @@ static void account_numa_dequeue(struct rq *rq, struct task_struct *p)
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
@@ -938,10 +939,12 @@ void task_numa_work(struct callback_head *work)
 	if (time_before(now, migrate))
 		return;
 
-	next_scan = now + 2*msecs_to_jiffies(sysctl_sched_numa_scan_period_min);
+	next_scan = now + msecs_to_jiffies(sysctl_sched_numa_scan_period_min);
 	if (cmpxchg(&mm->numa_next_scan, migrate, next_scan) != migrate)
 		return;
 
+	current->numa_scan_period += jiffies_to_msecs(2);
+
 	start = mm->numa_scan_offset;
 	pages = sysctl_sched_numa_scan_size;
 	pages <<= 20 - PAGE_SHIFT; /* MB in pages */
@@ -998,7 +1001,8 @@ void task_tick_numa(struct rq *rq, struct task_struct *curr)
 	period = (u64)curr->numa_scan_period * NSEC_PER_MSEC;
 
 	if (now - curr->node_stamp > period) {
-		curr->node_stamp = now;
+		curr->node_stamp += period;
+		curr->numa_scan_period = sysctl_sched_numa_scan_period_min;
 
 		/*
 		 * We are comparing runtime to wall clock time here, which
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index a14b8a4..6d2fe5b 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -353,6 +353,13 @@ static struct ctl_table kern_table[] = {
 #endif /* CONFIG_SMP */
 #ifdef CONFIG_NUMA_BALANCING
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
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
