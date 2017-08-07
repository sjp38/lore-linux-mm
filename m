Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 48A206B02FA
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 03:14:14 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u199so89892581pgb.13
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 00:14:14 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id z1si4980332plb.152.2017.08.07.00.14.12
        for <linux-mm@kvack.org>;
        Mon, 07 Aug 2017 00:14:13 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v8 06/14] lockdep: Detect and handle hist_lock ring buffer overwrite
Date: Mon,  7 Aug 2017 16:12:53 +0900
Message-Id: <1502089981-21272-7-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
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
 include/linux/lockdep.h  | 20 +++++++++++++++++++
 include/linux/sched.h    |  3 +++
 kernel/locking/lockdep.c | 52 +++++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 70 insertions(+), 5 deletions(-)

diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index 0c8a1b8..48c244c 100644
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
index 5becef5..373466b 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -855,6 +855,9 @@ struct task_struct {
 	unsigned int xhlock_idx;
 	/* For restoring at history boundaries */
 	unsigned int xhlock_idx_hist[CONTEXT_NR];
+	unsigned int hist_id;
+	/* For overwrite check at each context exit */
+	unsigned int hist_id_save[CONTEXT_NR];
 #endif
 
 #ifdef CONFIG_UBSAN
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index afd6e64..5168dac 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -4742,6 +4742,17 @@ void lockdep_rcu_suspicious(const char *file, const int line, const char *s)
 static atomic_t cross_gen_id; /* Can be wrapped */
 
 /*
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
+/*
  * Lock history stacks; we have 3 nested lock history stacks:
  *
  *   Hard IRQ
@@ -4773,14 +4784,28 @@ void lockdep_rcu_suspicious(const char *file, const int line, const char *s)
  */
 void crossrelease_hist_start(enum context_t c)
 {
-	if (current->xhlocks)
-		current->xhlock_idx_hist[c] = current->xhlock_idx;
+	struct task_struct *cur = current;
+
+	if (cur->xhlocks) {
+		cur->xhlock_idx_hist[c] = cur->xhlock_idx;
+		cur->hist_id_save[c] = cur->hist_id;
+	}
 }
 
 void crossrelease_hist_end(enum context_t c)
 {
-	if (current->xhlocks)
-		current->xhlock_idx = current->xhlock_idx_hist[c];
+	struct task_struct *cur = current;
+
+	if (cur->xhlocks) {
+		unsigned int idx = cur->xhlock_idx_hist[c];
+		struct hist_lock *h = &xhlock(idx);
+
+		cur->xhlock_idx = idx;
+
+		/* Check if the ring was overwritten. */
+		if (h->hist_id != cur->hist_id_save[c])
+			invalidate_xhlock(h);
+	}
 }
 
 static int cross_lock(struct lockdep_map *lock)
@@ -4826,6 +4851,7 @@ static inline int depend_after(struct held_lock *hlock)
  * Check if the xhlock is valid, which would be false if,
  *
  *    1. Has not used after initializaion yet.
+ *    2. Got invalidated.
  *
  * Remind hist_lock is implemented as a ring buffer.
  */
@@ -4857,6 +4883,7 @@ static void add_xhlock(struct held_lock *hlock)
 
 	/* Initialize hist_lock's members */
 	xhlock->hlock = *hlock;
+	xhlock->hist_id = current->hist_id++;
 
 	xhlock->trace.nr_entries = 0;
 	xhlock->trace.max_entries = MAX_XHLOCK_TRACE_ENTRIES;
@@ -4995,6 +5022,7 @@ static int commit_xhlock(struct cross_lock *xlock, struct hist_lock *xhlock)
 static void commit_xhlocks(struct cross_lock *xlock)
 {
 	unsigned int cur = current->xhlock_idx;
+	unsigned int prev_hist_id = xhlock(cur).hist_id;
 	unsigned int i;
 
 	if (!graph_lock())
@@ -5013,6 +5041,17 @@ static void commit_xhlocks(struct cross_lock *xlock)
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
@@ -5085,9 +5124,12 @@ void lockdep_init_task(struct task_struct *task)
 	int i;
 
 	task->xhlock_idx = UINT_MAX;
+	task->hist_id = 0;
 
-	for (i = 0; i < CONTEXT_NR; i++)
+	for (i = 0; i < CONTEXT_NR; i++) {
 		task->xhlock_idx_hist[i] = UINT_MAX;
+		task->hist_id_save[i] = 0;
+	}
 
 	task->xhlocks = kzalloc(sizeof(struct hist_lock) * MAX_XHLOCKS_NR,
 				GFP_KERNEL);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
