Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BEDC46B025F
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 05:31:55 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a69so25133126pfa.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:31:55 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id s6si2341237pax.34.2016.07.07.02.31.51
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 02:31:52 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [RFC v2 03/13] lockdep: Make check_prev_add can use a stack_trace of other context
Date: Thu,  7 Jul 2016 18:29:53 +0900
Message-Id: <1467883803-29132-4-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
References: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, npiggin@kernel.dk, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Currently, check_prev_add() can only save its current context's stack
trace. But it would be useful if a seperated stack_trace can be taken
and used in check_prev_add(). Crossrelease feature can use
check_prev_add() with another context's stack_trace.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 4d51208..c596bef 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -1822,7 +1822,8 @@ check_deadlock(struct task_struct *curr, struct held_lock *next,
  */
 static int
 check_prev_add(struct task_struct *curr, struct held_lock *prev,
-	       struct held_lock *next, int distance, int *stack_saved)
+	       struct held_lock *next, int distance, int *stack_saved,
+	       struct stack_trace *own_trace)
 {
 	struct lock_list *entry;
 	int ret;
@@ -1883,7 +1884,7 @@ check_prev_add(struct task_struct *curr, struct held_lock *prev,
 		}
 	}
 
-	if (!*stack_saved) {
+	if (!own_trace && stack_saved && !*stack_saved) {
 		if (!save_trace(&trace))
 			return 0;
 		*stack_saved = 1;
@@ -1895,14 +1896,14 @@ check_prev_add(struct task_struct *curr, struct held_lock *prev,
 	 */
 	ret = add_lock_to_list(hlock_class(prev), hlock_class(next),
 			       &hlock_class(prev)->locks_after,
-			       next->acquire_ip, distance, &trace);
+			       next->acquire_ip, distance, own_trace ?: &trace);
 
 	if (!ret)
 		return 0;
 
 	ret = add_lock_to_list(hlock_class(next), hlock_class(prev),
 			       &hlock_class(next)->locks_before,
-			       next->acquire_ip, distance, &trace);
+			       next->acquire_ip, distance, own_trace ?: &trace);
 	if (!ret)
 		return 0;
 
@@ -1911,7 +1912,8 @@ check_prev_add(struct task_struct *curr, struct held_lock *prev,
 	 */
 	if (verbose(hlock_class(prev)) || verbose(hlock_class(next))) {
 		/* We drop graph lock, so another thread can overwrite trace. */
-		*stack_saved = 0;
+		if (stack_saved)
+			*stack_saved = 0;
 		graph_unlock();
 		printk("\n new dependency: ");
 		print_lock_name(hlock_class(prev));
@@ -1960,8 +1962,8 @@ check_prevs_add(struct task_struct *curr, struct held_lock *next)
 		 * added:
 		 */
 		if (hlock->read != 2 && hlock->check) {
-			if (!check_prev_add(curr, hlock, next,
-						distance, &stack_saved))
+			if (!check_prev_add(curr, hlock, next, distance,
+						&stack_saved, NULL))
 				return 0;
 			/*
 			 * Stop after the first non-trylock entry,
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
