Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F0A2A6B02C3
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 03:14:13 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j83so86670244pfe.10
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 00:14:13 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id u78si4310813pfk.450.2017.08.07.00.14.12
        for <linux-mm@kvack.org>;
        Mon, 07 Aug 2017 00:14:12 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v8 04/14] lockdep: Make check_prev_add() able to handle external stack_trace
Date: Mon,  7 Aug 2017 16:12:51 +0900
Message-Id: <1502089981-21272-5-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

Currently, a space for stack_trace is pinned in check_prev_add(), that
makes us not able to use external stack_trace. The simplest way to
achieve it is to pass an external stack_trace as an argument.

A more suitable solution is to pass a callback additionally along with
a stack_trace so that callers can decide the way to save or whether to
save. Actually crossrelease needs to do other than saving a stack_trace.
So pass a stack_trace and callback to handle it, to check_prev_add().

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 40 +++++++++++++++++++---------------------
 1 file changed, 19 insertions(+), 21 deletions(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index b23e930..22a13f9 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -1813,20 +1813,13 @@ static inline void inc_chains(void)
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
@@ -1874,11 +1867,8 @@ static inline void inc_chains(void)
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
@@ -1886,14 +1876,14 @@ static inline void inc_chains(void)
 	 */
 	ret = add_lock_to_list(hlock_class(next),
 			       &hlock_class(prev)->locks_after,
-			       next->acquire_ip, distance, &trace);
+			       next->acquire_ip, distance, trace);
 
 	if (!ret)
 		return 0;
 
 	ret = add_lock_to_list(hlock_class(prev),
 			       &hlock_class(next)->locks_before,
-			       next->acquire_ip, distance, &trace);
+			       next->acquire_ip, distance, trace);
 	if (!ret)
 		return 0;
 
@@ -1901,8 +1891,6 @@ static inline void inc_chains(void)
 	 * Debugging printouts:
 	 */
 	if (verbose(hlock_class(prev)) || verbose(hlock_class(next))) {
-		/* We drop graph lock, so another thread can overwrite trace. */
-		*stack_saved = 0;
 		graph_unlock();
 		printk("\n new dependency: ");
 		print_lock_name(hlock_class(prev));
@@ -1926,8 +1914,9 @@ static inline void inc_chains(void)
 check_prevs_add(struct task_struct *curr, struct held_lock *next)
 {
 	int depth = curr->lockdep_depth;
-	int stack_saved = 0;
 	struct held_lock *hlock;
+	struct stack_trace trace;
+	int (*save)(struct stack_trace *trace) = save_trace;
 
 	/*
 	 * Debugging checks.
@@ -1952,9 +1941,18 @@ static inline void inc_chains(void)
 		 * added:
 		 */
 		if (hlock->read != 2 && hlock->check) {
-			if (!check_prev_add(curr, hlock, next,
-						distance, &stack_saved))
+			int ret = check_prev_add(curr, hlock, next,
+						distance, &trace, save);
+			if (!ret)
 				return 0;
+
+			/*
+			 * Stop saving stack_trace if save_trace() was
+			 * called at least once:
+			 */
+			if (save && ret == 2)
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
