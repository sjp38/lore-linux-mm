Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0A62F6B0260
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 00:16:36 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id p66so17067165pga.4
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 21:16:36 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id l26si32021226pli.332.2016.12.08.21.16.34
        for <linux-mm@kvack.org>;
        Thu, 08 Dec 2016 21:16:35 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v4 05/15] lockdep: Make check_prev_add can use a separate stack_trace
Date: Fri,  9 Dec 2016 14:12:01 +0900
Message-Id: <1481260331-360-6-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

check_prev_add() saves a stack trace of the current. But crossrelease
feature needs to use a separate stack trace of another context in
check_prev_add(). So make it use a separate stack trace instead of one
of the current.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 111839f..3eaa11c 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -1793,7 +1793,8 @@ check_deadlock(struct task_struct *curr, struct held_lock *next,
  */
 static int
 check_prev_add(struct task_struct *curr, struct held_lock *prev,
-	       struct held_lock *next, int distance, int *stack_saved)
+	       struct held_lock *next, int distance, int *stack_saved,
+	       struct stack_trace *own_trace)
 {
 	struct lock_list *entry;
 	int ret;
@@ -1854,7 +1855,7 @@ check_prev_add(struct task_struct *curr, struct held_lock *prev,
 		}
 	}
 
-	if (!*stack_saved) {
+	if (!own_trace && stack_saved && !*stack_saved) {
 		if (!save_trace(&trace))
 			return 0;
 		*stack_saved = 1;
@@ -1866,14 +1867,14 @@ check_prev_add(struct task_struct *curr, struct held_lock *prev,
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
 
@@ -1882,7 +1883,8 @@ check_prev_add(struct task_struct *curr, struct held_lock *prev,
 	 */
 	if (verbose(hlock_class(prev)) || verbose(hlock_class(next))) {
 		/* We drop graph lock, so another thread can overwrite trace. */
-		*stack_saved = 0;
+		if (stack_saved)
+			*stack_saved = 0;
 		graph_unlock();
 		printk("\n new dependency: ");
 		print_lock_name(hlock_class(prev));
@@ -1931,8 +1933,8 @@ check_prevs_add(struct task_struct *curr, struct held_lock *next)
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
