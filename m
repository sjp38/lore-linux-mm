Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 3DEC38D0008
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 13:45:45 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so1476620eek.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 10:45:44 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 51/52] sched: Exclude pinned tasks from the NUMA-balancing logic
Date: Sun,  2 Dec 2012 19:43:43 +0100
Message-Id: <1354473824-19229-52-git-send-email-mingo@kernel.org>
In-Reply-To: <1354473824-19229-1-git-send-email-mingo@kernel.org>
References: <1354473824-19229-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Don't try to NUMA-balance hard-bound tasks in vein. This
also makes it easier to compare hard-bound workloads against
NUMA-balanced workloads, because the NUMA code will
be completely inactive for those hard-bound tasks.

( Keep a debugging feature flag around: for development it
  makes sense to observe what NUMA balancing tries to do
  with hard-affine tasks. )

[ Note: the duplicated test condition will be consolidated
  in the next patch. ]

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 kernel/sched/core.c     | 6 ++++++
 kernel/sched/debug.c    | 1 +
 kernel/sched/fair.c     | 7 +++++++
 kernel/sched/features.h | 1 +
 4 files changed, 15 insertions(+)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 85fd67c..69b18b3 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4664,6 +4664,12 @@ void do_set_cpus_allowed(struct task_struct *p, const struct cpumask *new_mask)
 
 	cpumask_copy(&p->cpus_allowed, new_mask);
 	p->nr_cpus_allowed = cpumask_weight(new_mask);
+
+#ifdef CONFIG_NUMA_BALANCING
+	/* Don't disturb hard-bound tasks: */
+	if (sched_feat(NUMA_EXCLUDE_AFFINE) && (p->nr_cpus_allowed != num_online_cpus()))
+		p->numa_shared = -1;
+#endif
 }
 
 /*
diff --git a/kernel/sched/debug.c b/kernel/sched/debug.c
index 2cd3c1b..e10b714 100644
--- a/kernel/sched/debug.c
+++ b/kernel/sched/debug.c
@@ -448,6 +448,7 @@ void proc_sched_show_task(struct task_struct *p, struct seq_file *m)
 
 	nr_switches = p->nvcsw + p->nivcsw;
 
+	P(nr_cpus_allowed);
 #ifdef CONFIG_SCHEDSTATS
 	PN(se.statistics.wait_start);
 	PN(se.statistics.sleep_start);
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index eaff006..9667191 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2495,6 +2495,13 @@ static void task_tick_numa(struct rq *rq, struct task_struct *curr)
 	if (!curr->mm || (curr->flags & PF_EXITING) || !curr->numa_faults)
 		return;
 
+	/* Don't disturb hard-bound tasks: */
+	if (sched_feat(NUMA_EXCLUDE_AFFINE) && (curr->nr_cpus_allowed != num_online_cpus())) {
+		if (curr->numa_shared >= 0)
+			curr->numa_shared = -1;
+		return;
+	}
+
 	task_tick_numa_scan(rq, curr);
 	task_tick_numa_placement(rq, curr);
 }
diff --git a/kernel/sched/features.h b/kernel/sched/features.h
index 1775b80..5598f63 100644
--- a/kernel/sched/features.h
+++ b/kernel/sched/features.h
@@ -77,6 +77,7 @@ SCHED_FEAT(WAKE_ON_IDEAL_CPU,		false)
 SCHED_FEAT(NUMA,			true)
 SCHED_FEAT(NUMA_BALANCE_ALL,		false)
 SCHED_FEAT(NUMA_BALANCE_INTERNODE,	false)
+SCHED_FEAT(NUMA_EXCLUDE_AFFINE,		true)
 SCHED_FEAT(NUMA_LB,			false)
 SCHED_FEAT(NUMA_GROUP_LB_COMPRESS,	true)
 SCHED_FEAT(NUMA_GROUP_LB_SPREAD,	true)
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
