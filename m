Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id A5EFF900008
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 10:01:00 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 15/27] sched: Track NUMA hinting faults on per-node basis
Date: Thu,  8 Aug 2013 15:00:27 +0100
Message-Id: <1375970439-5111-16-git-send-email-mgorman@suse.de>
In-Reply-To: <1375970439-5111-1-git-send-email-mgorman@suse.de>
References: <1375970439-5111-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch tracks what nodes numa hinting faults were incurred on.
This information is later used to schedule a task on the node storing
the pages most frequently faulted by the task.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h |  2 ++
 kernel/sched/core.c   |  3 +++
 kernel/sched/fair.c   | 11 ++++++++++-
 kernel/sched/sched.h  | 12 ++++++++++++
 4 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 59c473b..702a5b6 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1334,6 +1334,8 @@ struct task_struct {
 	unsigned int numa_scan_period_max;
 	u64 node_stamp;			/* migration stamp  */
 	struct callback_head numa_work;
+
+	unsigned long *numa_faults;
 #endif /* CONFIG_NUMA_BALANCING */
 
 	struct rcu_head rcu;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index e148975..e6dda1b 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1635,6 +1635,7 @@ static void __sched_fork(struct task_struct *p)
 	p->numa_migrate_seq = p->mm ? p->mm->numa_scan_seq - 1 : 0;
 	p->numa_scan_period = sysctl_numa_balancing_scan_delay;
 	p->numa_work.next = &p->numa_work;
+	p->numa_faults = NULL;
 #endif /* CONFIG_NUMA_BALANCING */
 }
 
@@ -1896,6 +1897,8 @@ static void finish_task_switch(struct rq *rq, struct task_struct *prev)
 	if (mm)
 		mmdrop(mm);
 	if (unlikely(prev_state == TASK_DEAD)) {
+		task_numa_free(prev);
+
 		/*
 		 * Remove function-return probe instances associated with this
 		 * task and put them back on the free list.
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index d77bb32..babac71 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -902,7 +902,14 @@ void task_numa_fault(int node, int pages, bool migrated)
 	if (!sched_feat_numa(NUMA))
 		return;
 
-	/* FIXME: Allocate task-specific structure for placement policy here */
+	/* Allocate buffer to track faults on a per-node basis */
+	if (unlikely(!p->numa_faults)) {
+		int size = sizeof(*p->numa_faults) * nr_node_ids;
+
+		p->numa_faults = kzalloc(size, GFP_KERNEL|__GFP_NOWARN);
+		if (!p->numa_faults)
+			return;
+	}
 
 	/*
 	 * If pages are properly placed (did not migrate) then scan slower.
@@ -918,6 +925,8 @@ void task_numa_fault(int node, int pages, bool migrated)
 	}
 
 	task_numa_placement(p);
+
+	p->numa_faults[node] += pages;
 }
 
 static void reset_ptenuma_scan(struct task_struct *p)
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index ef0a7b2..c2f1c86 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -6,6 +6,7 @@
 #include <linux/spinlock.h>
 #include <linux/stop_machine.h>
 #include <linux/tick.h>
+#include <linux/slab.h>
 
 #include "cpupri.h"
 #include "cpuacct.h"
@@ -553,6 +554,17 @@ static inline u64 rq_clock_task(struct rq *rq)
 	return rq->clock_task;
 }
 
+#ifdef CONFIG_NUMA_BALANCING
+static inline void task_numa_free(struct task_struct *p)
+{
+	kfree(p->numa_faults);
+}
+#else /* CONFIG_NUMA_BALANCING */
+static inline void task_numa_free(struct task_struct *p)
+{
+}
+#endif /* CONFIG_NUMA_BALANCING */
+
 #ifdef CONFIG_SMP
 
 #define rcu_dereference_check_sched_domain(p) \
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
