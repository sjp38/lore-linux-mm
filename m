Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 429226B0062
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 19:19:40 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so3277745eaa.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 16:19:38 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 1/9] numa, sched: Fix NUMA tick ->numa_shared setting
Date: Fri,  7 Dec 2012 01:19:18 +0100
Message-Id: <1354839566-15697-2-git-send-email-mingo@kernel.org>
In-Reply-To: <1354839566-15697-1-git-send-email-mingo@kernel.org>
References: <1354839566-15697-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Split out an unlocked variant of __sched_setnuma(),
and use it in the NUMA tick when we are modifying
p->numa_shared.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 kernel/sched/core.c  | 19 +++++++++++++++----
 kernel/sched/fair.c  |  2 +-
 kernel/sched/sched.h |  1 +
 3 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 69b18b3..cce84c3 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -6091,13 +6091,10 @@ static struct sched_domain_topology_level *sched_domain_topology = default_topol
 /*
  * Change a task's NUMA state - called from the placement tick.
  */
-void sched_setnuma(struct task_struct *p, int node, int shared)
+void __sched_setnuma(struct rq *rq, struct task_struct *p, int node, int shared)
 {
-	unsigned long flags;
 	int on_rq, running;
-	struct rq *rq;
 
-	rq = task_rq_lock(p, &flags);
 	on_rq = p->on_rq;
 	running = task_current(rq, p);
 
@@ -6113,6 +6110,20 @@ void sched_setnuma(struct task_struct *p, int node, int shared)
 		p->sched_class->set_curr_task(rq);
 	if (on_rq)
 		enqueue_task(rq, p, 0);
+}
+
+/*
+ * Change a task's NUMA state - called from the placement tick.
+ */
+void sched_setnuma(struct task_struct *p, int node, int shared)
+{
+	unsigned long flags;
+	struct rq *rq;
+
+	rq = task_rq_lock(p, &flags);
+
+	__sched_setnuma(rq, p, node, shared);
+
 	task_rq_unlock(rq, p, &flags);
 
 	/*
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 21c10f7..0c83689 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2540,7 +2540,7 @@ static void task_tick_numa(struct rq *rq, struct task_struct *curr)
 	/* Cheap checks first: */
 	if (!task_numa_candidate(curr)) {
 		if (curr->numa_shared >= 0)
-			curr->numa_shared = -1;
+			__sched_setnuma(rq, curr, -1, -1);
 		return;
 	}
 
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 0fdd304..f75bf06 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -513,6 +513,7 @@ DECLARE_PER_CPU(struct rq, runqueues);
 #define raw_rq()		(&__raw_get_cpu_var(runqueues))
 
 #ifdef CONFIG_NUMA_BALANCING
+extern void __sched_setnuma(struct rq *rq, struct task_struct *p, int node, int shared);
 extern void sched_setnuma(struct task_struct *p, int node, int shared);
 static inline void task_numa_free(struct task_struct *p)
 {
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
