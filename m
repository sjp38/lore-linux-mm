Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id E52036B009A
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 05:33:19 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 44/50] sched: numa: stay on the same node if CLONE_VM
Date: Tue, 10 Sep 2013 10:32:24 +0100
Message-Id: <1378805550-29949-45-git-send-email-mgorman@suse.de>
In-Reply-To: <1378805550-29949-1-git-send-email-mgorman@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Rik van Riel <riel@redhat.com>

A newly spawned thread inside a process should stay on the same
NUMA node as its parent. This prevents processes from being "torn"
across multiple NUMA nodes every time they spawn a new thread.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h |  2 +-
 kernel/fork.c         |  2 +-
 kernel/sched/core.c   | 14 +++++++++-----
 3 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 15888f5..4f51ceb 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2005,7 +2005,7 @@ extern void wake_up_new_task(struct task_struct *tsk);
 #else
  static inline void kick_process(struct task_struct *tsk) { }
 #endif
-extern void sched_fork(struct task_struct *p);
+extern void sched_fork(unsigned long clone_flags, struct task_struct *p);
 extern void sched_dead(struct task_struct *p);
 
 extern void proc_caches_init(void);
diff --git a/kernel/fork.c b/kernel/fork.c
index f693bdf..2bc7f88 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1309,7 +1309,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 #endif
 
 	/* Perform scheduler related setup. Assign this task to a CPU. */
-	sched_fork(p);
+	sched_fork(clone_flags, p);
 
 	retval = perf_event_init_task(p);
 	if (retval)
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 3808860..7bf0827 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1699,7 +1699,7 @@ int wake_up_state(struct task_struct *p, unsigned int state)
  *
  * __sched_fork() is basic setup used by init_idle() too:
  */
-static void __sched_fork(struct task_struct *p)
+static void __sched_fork(unsigned long clone_flags, struct task_struct *p)
 {
 	p->on_rq			= 0;
 
@@ -1732,11 +1732,15 @@ static void __sched_fork(struct task_struct *p)
 		p->mm->numa_scan_seq = 0;
 	}
 
+	if (clone_flags & CLONE_VM)
+		p->numa_preferred_nid = current->numa_preferred_nid;
+	else
+		p->numa_preferred_nid = -1;
+
 	p->node_stamp = 0ULL;
 	p->numa_scan_seq = p->mm ? p->mm->numa_scan_seq : 0;
 	p->numa_migrate_seq = 1;
 	p->numa_scan_period = sysctl_numa_balancing_scan_delay;
-	p->numa_preferred_nid = -1;
 	p->numa_work.next = &p->numa_work;
 	p->numa_faults = NULL;
 	p->numa_faults_buffer = NULL;
@@ -1768,12 +1772,12 @@ void set_numabalancing_state(bool enabled)
 /*
  * fork()/clone()-time setup:
  */
-void sched_fork(struct task_struct *p)
+void sched_fork(unsigned long clone_flags, struct task_struct *p)
 {
 	unsigned long flags;
 	int cpu = get_cpu();
 
-	__sched_fork(p);
+	__sched_fork(clone_flags, p);
 	/*
 	 * We mark the process as running here. This guarantees that
 	 * nobody will actually run it, and a signal or other external
@@ -4304,7 +4308,7 @@ void init_idle(struct task_struct *idle, int cpu)
 
 	raw_spin_lock_irqsave(&rq->lock, flags);
 
-	__sched_fork(idle);
+	__sched_fork(0, idle);
 	idle->state = TASK_RUNNING;
 	idle->se.exec_start = sched_clock();
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
