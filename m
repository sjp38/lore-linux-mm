Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BCBCE6B0311
	for <linux-mm@kvack.org>; Wed, 24 May 2017 05:00:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p74so190579613pfd.11
        for <linux-mm@kvack.org>; Wed, 24 May 2017 02:00:45 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id j69si24055331pgc.214.2017.05.24.02.00.43
        for <linux-mm@kvack.org>;
        Wed, 24 May 2017 02:00:44 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v7 06/16] lockdep: Detect and handle hist_lock ring buffer overwrite
Date: Wed, 24 May 2017 17:59:39 +0900
Message-Id: <1495616389-29772-7-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
References: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

The ring buffer can be overwritten by hardirq/softirq/work contexts.
That cases must be considered on rollback or commit. For example,

          |<------ hist_lock ring buffer size ----->|
          ppppppppppppiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
wrapped > iiiiiiiiiiiiiiiiiiiiiii....................

          where 'p' represents an acquisition in process context,
          'i' represents an acquisition in irq context.

On irq exit, crossrelease tries to rollback idx to original position,
but it should not because the entry already has been invalid by
overwriting 'i'. Avoid rollback or commit for entries overwritten.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/lockdep.h  | 20 +++++++++++
 include/linux/sched.h    |  4 +++
 kernel/locking/lockdep.c | 92 +++++++++++++++++++++++++++++++++++++++++-------
 3 files changed, 104 insertions(+), 12 deletions(-)

diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index d531097..a03f79d 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -284,6 +284,26 @@ struct held_lock {
  */
 struct hist_lock {
 	/*
+	 * Id for each entry in the ring buffer. This is used to
+	 * decide whether the ring buffer was overwritten or not.
+	 *
+	 * For example,
+	 *
+	 *           |<----------- hist_lock ring buffer size ------->|
+	 *           pppppppppppppppppppppiiiiiiiiiiiiiiiiiiiiiiiiiiiii
+	 * wrapped > iiiiiiiiiiiiiiiiiiiiiiiiiii.......................
+	 *
+	 *           where 'p' represents an acquisition in process
+	 *           context, 'i' represents an acquisition in irq
+	 *           context.
+	 *
+	 * In this example, the ring buffer was overwritten by
+	 * acquisitions in irq context, that should be detected on
+	 * rollback or commit.
+	 */
+	unsigned int hist_id;
+
+	/*
 	 * Seperate stack_trace data. This will be used at commit step.
 	 */
 	struct stack_trace	trace;
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 5f6d6f4..9e1437c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1756,6 +1756,10 @@ struct task_struct {
 	unsigned int xhlock_idx_soft; /* For restoring at softirq exit */
 	unsigned int xhlock_idx_hard; /* For restoring at hardirq exit */
 	unsigned int xhlock_idx_work; /* For restoring at work exit */
+	unsigned int hist_id;
+	unsigned int hist_id_soft; /* For overwrite check at softirq exit */
+	unsigned int hist_id_hard; /* For overwrite check at hardirq exit */
+	unsigned int hist_id_work; /* For overwrite check at work exit */
 #endif
 #ifdef CONFIG_UBSAN
 	unsigned int in_ubsan;
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 63eb04a..26ff205 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -4627,28 +4627,65 @@ void lockdep_rcu_suspicious(const char *file, const int line, const char *s)
  */
 static atomic_t cross_gen_id; /* Can be wrapped */
 
+/*
+ * Make an entry of the ring buffer invalid.
+ */
+static inline void invalidate_xhlock(struct hist_lock *xhlock)
+{
+	/*
+	 * Normally, xhlock->hlock.instance must be !NULL.
+	 */
+	xhlock->hlock.instance = NULL;
+}
+
 void crossrelease_hardirq_start(void)
 {
-	if (current->xhlocks)
-		current->xhlock_idx_hard = current->xhlock_idx;
+	struct task_struct *cur = current;
+
+	if (cur->xhlocks) {
+		cur->xhlock_idx_hard = cur->xhlock_idx;
+		cur->hist_id_hard = cur->hist_id;
+	}
 }
 
 void crossrelease_hardirq_end(void)
 {
-	if (current->xhlocks)
-		current->xhlock_idx = current->xhlock_idx_hard;
+	struct task_struct *cur = current;
+
+	if (cur->xhlocks) {
+		unsigned int idx = cur->xhlock_idx_hard;
+		struct hist_lock *h = &xhlock(idx);
+
+		cur->xhlock_idx = idx;
+		/* Check if the ring was overwritten. */
+		if (h->hist_id != cur->hist_id_hard)
+			invalidate_xhlock(h);
+	}
 }
 
 void crossrelease_softirq_start(void)
 {
-	if (current->xhlocks)
-		current->xhlock_idx_soft = current->xhlock_idx;
+	struct task_struct *cur = current;
+
+	if (cur->xhlocks) {
+		cur->xhlock_idx_soft = cur->xhlock_idx;
+		cur->hist_id_soft = cur->hist_id;
+	}
 }
 
 void crossrelease_softirq_end(void)
 {
-	if (current->xhlocks)
-		current->xhlock_idx = current->xhlock_idx_soft;
+	struct task_struct *cur = current;
+
+	if (cur->xhlocks) {
+		unsigned int idx = cur->xhlock_idx_soft;
+		struct hist_lock *h = &xhlock(idx);
+
+		cur->xhlock_idx = idx;
+		/* Check if the ring was overwritten. */
+		if (h->hist_id != cur->hist_id_soft)
+			invalidate_xhlock(h);
+	}
 }
 
 /*
@@ -4658,14 +4695,27 @@ void crossrelease_softirq_end(void)
  */
 void crossrelease_work_start(void)
 {
-	if (current->xhlocks)
-		current->xhlock_idx_work = current->xhlock_idx;
+	struct task_struct *cur = current;
+
+	if (cur->xhlocks) {
+		cur->xhlock_idx_work = cur->xhlock_idx;
+		cur->hist_id_work = cur->hist_id;
+	}
 }
 
 void crossrelease_work_end(void)
 {
-	if (current->xhlocks)
-		current->xhlock_idx = current->xhlock_idx_work;
+	struct task_struct *cur = current;
+
+	if (cur->xhlocks) {
+		unsigned int idx = cur->xhlock_idx_work;
+		struct hist_lock *h = &xhlock(idx);
+
+		cur->xhlock_idx = idx;
+		/* Check if the ring was overwritten. */
+		if (h->hist_id != cur->hist_id_work)
+			invalidate_xhlock(h);
+	}
 }
 
 static int cross_lock(struct lockdep_map *lock)
@@ -4711,6 +4761,7 @@ static inline int depend_after(struct held_lock *hlock)
  * Check if the xhlock is valid, which would be false if,
  *
  *    1. Has not used after initializaion yet.
+ *    2. Got invalidated.
  *
  * Remind hist_lock is implemented as a ring buffer.
  */
@@ -4742,6 +4793,7 @@ static void add_xhlock(struct held_lock *hlock)
 
 	/* Initialize hist_lock's members */
 	xhlock->hlock = *hlock;
+	xhlock->hist_id = current->hist_id++;
 
 	xhlock->trace.nr_entries = 0;
 	xhlock->trace.max_entries = MAX_XHLOCK_TRACE_ENTRIES;
@@ -4880,6 +4932,7 @@ static int commit_xhlock(struct cross_lock *xlock, struct hist_lock *xhlock)
 static void commit_xhlocks(struct cross_lock *xlock)
 {
 	unsigned int cur = current->xhlock_idx;
+	unsigned int prev_hist_id = xhlock(cur).hist_id;
 	unsigned int i;
 
 	if (!graph_lock())
@@ -4898,6 +4951,17 @@ static void commit_xhlocks(struct cross_lock *xlock)
 			break;
 
 		/*
+		 * Filter out the cases that the ring buffer was
+		 * overwritten and the previous entry has a bigger
+		 * hist_id than the following one, which is impossible
+		 * otherwise.
+		 */
+		if (unlikely(before(xhlock->hist_id, prev_hist_id)))
+			break;
+
+		prev_hist_id = xhlock->hist_id;
+
+		/*
 		 * commit_xhlock() returns 0 with graph_lock already
 		 * released if fail.
 		 */
@@ -4967,6 +5031,10 @@ static void cross_init(struct lockdep_map *lock, int cross)
 
 void init_crossrelease_task(struct task_struct *task)
 {
+	task->hist_id = 0;
+	task->hist_id_soft = 0;
+	task->hist_id_hard = 0;
+	task->hist_id_work = 0;
 	task->xhlock_idx = UINT_MAX;
 	task->xhlock_idx_soft = UINT_MAX;
 	task->xhlock_idx_hard = UINT_MAX;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
