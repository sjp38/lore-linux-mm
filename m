Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 79D4F6B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 02:43:38 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 204so301850004pge.5
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 23:43:38 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 32si709459plf.34.2017.01.25.23.43.36
        for <linux-mm@kvack.org>;
        Wed, 25 Jan 2017 23:43:37 -0800 (PST)
Date: Thu, 26 Jan 2017 16:43:33 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v5 05/13] lockdep: Pass a callback arg to
 check_prev_add() to handle stack_trace
Message-ID: <20170126074333.GA16086@X58A-UD3R>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-6-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1484745459-2055-6-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

I fixed a hole that peterz pointed out. And then, I think the following
is reasonable. Don't you think so?

----->8-----
commit ac185d1820ee7223773ec3e23f614c1fe5c079fc
Author: Byungchul Park <byungchul.park@lge.com>
Date:   Tue Jan 24 14:46:14 2017 +0900

    lockdep: Pass a callback arg to check_prev_add() to handle stack_trace
    
    Currently, a separate stack_trace instance cannot be used in
    check_prev_add(). The simplest way to achieve it is to pass a
    stack_trace instance to check_prev_add() as an argument after
    saving it. However, unnecessary saving can happen if so implemented.
    
    The proper solution is to pass a callback function additionally along
    with a stack_trace so that a caller can decide the way to save. Actually,
    crossrelease don't need to save stack_trace of current, but only need to
    copy stack_traces from temporary buffers to the global stack_trace[].
    
    In addition, check_prev_add() returns 2 in case that the lock does not
    need to be added into the dependency graph because it was already in.
    However, the return value is not used any more. So, this patch changes
    it to mean that lockdep successfully save stack_trace and add the lock
    to the graph.
    
    Signed-off-by: Byungchul Park <byungchul.park@lge.com>

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 7fe6af1..9562b29 100644
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
@@ -1862,15 +1855,12 @@ static inline void inc_chains(void)
 		if (entry->class == hlock_class(next)) {
 			if (distance == 1)
 				entry->distance = 1;
-			return 2;
+			return 1;
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
@@ -1902,9 +1890,10 @@ static inline void inc_chains(void)
 		print_lock_name(hlock_class(next));
 		printk(KERN_CONT "\n");
 		dump_stack();
-		return graph_lock();
+		if (!graph_lock())
+			return 0;
 	}
-	return 1;
+	return 2;
 }
 
 /*
@@ -1917,8 +1906,9 @@ static inline void inc_chains(void)
 check_prevs_add(struct task_struct *curr, struct held_lock *next)
 {
 	int depth = curr->lockdep_depth;
-	int stack_saved = 0;
 	struct held_lock *hlock;
+	struct stack_trace trace;
+	int (*save)(struct stack_trace *trace) = save_trace;
 
 	/*
 	 * Debugging checks.
@@ -1943,9 +1933,18 @@ static inline void inc_chains(void)
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
