Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2AC389C000B
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:30:03 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so7087284pab.40
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:30:02 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 19/63] sched: Track NUMA hinting faults on per-node basis
Date: Mon,  7 Oct 2013 11:28:57 +0100
Message-Id: <1381141781-10992-20-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
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
index a8095ad..8828e40 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1332,6 +1332,8 @@ struct task_struct {
 	unsigned int numa_scan_period_max;
 	u64 node_stamp;			/* migration stamp  */
 	struct callback_head numa_work;
+
+	unsigned long *numa_faults;
 #endif /* CONFIG_NUMA_BALANCING */
 
 	struct rcu_head rcu;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 681945e..aad2e02 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1629,6 +1629,7 @@ static void __sched_fork(struct task_struct *p)
 	p->numa_migrate_seq = p->mm ? p->mm->numa_scan_seq - 1 : 0;
 	p->numa_scan_period = sysctl_numa_balancing_scan_delay;
 	p->numa_work.next = &p->numa_work;
+	p->numa_faults = NULL;
 #endif /* CONFIG_NUMA_BALANCING */
 
 	cpu_hotplug_init_task(p);
@@ -1892,6 +1893,8 @@ static void finish_task_switch(struct rq *rq, struct task_struct *prev)
 	if (mm)
 		mmdrop(mm);
 	if (unlikely(prev_state == TASK_DEAD)) {
+		task_numa_free(prev);
+
 		/*
 		 * Remove function-return probe instances associated with this
 		 * task and put them back on the free list.
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 8cea7a2..df300d9 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -902,7 +902,14 @@ void task_numa_fault(int node, int pages, bool migrated)
 	if (!numabalancing_enabled)
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
index b3c5653..6a955f4 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -6,6 +6,7 @@
 #include <linux/spinlock.h>
 #include <linux/stop_machine.h>
 #include <linux/tick.h>
+#include <linux/slab.h>
 
 #include "cpupri.h"
 #include "cpuacct.h"
@@ -552,6 +553,17 @@ static inline u64 rq_clock_task(struct rq *rq)
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
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
