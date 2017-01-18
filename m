Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BF7DD6B026E
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 08:17:57 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id f144so16589748pfa.3
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:17:57 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id l24si207503pgn.200.2017.01.18.05.17.54
        for <linux-mm@kvack.org>;
        Wed, 18 Jan 2017 05:17:56 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v5 05/13] lockdep: Pass a callback arg to check_prev_add() to handle stack_trace
Date: Wed, 18 Jan 2017 22:17:31 +0900
Message-Id: <1484745459-2055-6-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

Currently, a separate stack_trace instance cannot be used in
check_prev_add(). The simplest way to achieve it is to pass a
stack_trace instance to check_prev_add() as an argument after
saving it. However, unnecessary saving can happen if so implemented.

The proper solution is to pass a callback function additionally along
with a stack_trace so that a caller can decide the way to save, for
example, doing nothing, calling save_trace() or doing something else.

Actually, crossrelease don't need to save stack_trace of current but
only need to copy stack_traces from temporary buffers to the global
stack_trace[].

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 38 ++++++++++++++++++--------------------
 1 file changed, 18 insertions(+), 20 deletions(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index e63ff97..75dc14a 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -1805,20 +1805,13 @@ static inline void inc_chains(void)
  */
 static int
 check_prev_add(struct task_struct *curr, struct held_lock *prev,
-	       struct held_lock *next, int distance, int *stack_saved)
+	       struct held_lock *next, int distance, struct stack_trace *trace,
+	       int (*save)(struct stack_trace *trace))
 {
 	struct lock_list *entry;
 	int ret;
 	struct lock_list this;
 	struct lock_list *uninitialized_var(target_entry);
-	/*
-	 * Static variable, serialized by the graph_lock().
-	 *
-	 * We use this static variable to save the stack trace in case
-	 * we call into this function multiple times due to encountering
-	 * trylocks in the held lock stack.
-	 */
-	static struct stack_trace trace;
 
 	/*
 	 * Prove that the new <prev> -> <next> dependency would not
@@ -1866,11 +1859,8 @@ static inline void inc_chains(void)
 		}
 	}
 
-	if (!*stack_saved) {
-		if (!save_trace(&trace))
-			return 0;
-		*stack_saved = 1;
-	}
+	if (save && !save(trace))
+		return 0;
 
 	/*
 	 * Ok, all validations passed, add the new lock
@@ -1878,14 +1868,14 @@ static inline void inc_chains(void)
 	 */
 	ret = add_lock_to_list(hlock_class(prev), hlock_class(next),
 			       &hlock_class(prev)->locks_after,
-			       next->acquire_ip, distance, &trace);
+			       next->acquire_ip, distance, trace);
 
 	if (!ret)
 		return 0;
 
 	ret = add_lock_to_list(hlock_class(next), hlock_class(prev),
 			       &hlock_class(next)->locks_before,
-			       next->acquire_ip, distance, &trace);
+			       next->acquire_ip, distance, trace);
 	if (!ret)
 		return 0;
 
@@ -1893,8 +1883,6 @@ static inline void inc_chains(void)
 	 * Debugging printouts:
 	 */
 	if (verbose(hlock_class(prev)) || verbose(hlock_class(next))) {
-		/* We drop graph lock, so another thread can overwrite trace. */
-		*stack_saved = 0;
 		graph_unlock();
 		printk("\n new dependency: ");
 		print_lock_name(hlock_class(prev));
@@ -1917,8 +1905,10 @@ static inline void inc_chains(void)
 check_prevs_add(struct task_struct *curr, struct held_lock *next)
 {
 	int depth = curr->lockdep_depth;
-	int stack_saved = 0;
 	struct held_lock *hlock;
+	struct stack_trace trace;
+	unsigned long start_nr = nr_stack_trace_entries;
+	int (*save)(struct stack_trace *trace) = save_trace;
 
 	/*
 	 * Debugging checks.
@@ -1944,8 +1934,16 @@ static inline void inc_chains(void)
 		 */
 		if (hlock->read != 2 && hlock->check) {
 			if (!check_prev_add(curr, hlock, next,
-						distance, &stack_saved))
+						distance, &trace, save))
 				return 0;
+
+			/*
+			 * Stop saving stack_trace if save_trace() was
+			 * called at least once:
+			 */
+			if (save && start_nr != nr_stack_trace_entries)
+				save = NULL;
+
 			/*
 			 * Stop after the first non-trylock entry,
 			 * as non-trylock entries have added their
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
