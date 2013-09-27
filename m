Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 49BC1900026
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:28:40 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so2612850pdi.14
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:28:39 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 48/63] sched: numa: stay on the same node if CLONE_VM
Date: Fri, 27 Sep 2013 14:27:33 +0100
Message-Id: <1380288468-5551-49-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
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
index 3b1f6af..51f6c4b 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1310,7 +1310,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 #endif
 
 	/* Perform scheduler related setup. Assign this task to a CPU. */
-	sched_fork(p);
+	sched_fork(clone_flags, p);
 
 	retval = perf_event_init_task(p);
 	if (retval)
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 123ac92..336a8ba 100644
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
