Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D34136B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 05:31:52 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id fq2so22680434obb.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:31:52 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id b37si4832084iod.103.2016.07.07.02.31.51
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 02:31:52 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [RFC v2 04/13] lockdep: Make save_trace can copy from other stack_trace
Date: Thu,  7 Jul 2016 18:29:54 +0900
Message-Id: <1467883803-29132-5-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
References: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, npiggin@kernel.dk, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Currently, save_trace() can only save current context's stack trace.
However, it would be useful if it can save(copy from) another context's
stack trace. Especially, it can be used by crossrelease feature.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index c596bef..b03014b 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -389,7 +389,7 @@ static void print_lockdep_off(const char *bug_msg)
 #endif
 }
 
-static int save_trace(struct stack_trace *trace)
+static int save_trace(struct stack_trace *trace, struct stack_trace *copy)
 {
 	trace->nr_entries = 0;
 	trace->max_entries = MAX_STACK_TRACE_ENTRIES - nr_stack_trace_entries;
@@ -397,7 +397,13 @@ static int save_trace(struct stack_trace *trace)
 
 	trace->skip = 3;
 
-	save_stack_trace(trace);
+	if (copy) {
+		trace->nr_entries = min(copy->nr_entries, trace->max_entries);
+		trace->skip = copy->skip;
+		memcpy(trace->entries, copy->entries,
+				trace->nr_entries * sizeof(unsigned long));
+	} else
+		save_stack_trace(trace);
 
 	/*
 	 * Some daft arches put -1 at the end to indicate its a full trace.
@@ -1201,7 +1207,7 @@ static noinline int print_circular_bug(struct lock_list *this,
 	if (!debug_locks_off_graph_unlock() || debug_locks_silent)
 		return 0;
 
-	if (!save_trace(&this->trace))
+	if (!save_trace(&this->trace, NULL))
 		return 0;
 
 	depth = get_lock_depth(target);
@@ -1547,13 +1553,13 @@ print_bad_irq_dependency(struct task_struct *curr,
 
 	printk("\nthe dependencies between %s-irq-safe lock", irqclass);
 	printk(" and the holding lock:\n");
-	if (!save_trace(&prev_root->trace))
+	if (!save_trace(&prev_root->trace, NULL))
 		return 0;
 	print_shortest_lock_dependencies(backwards_entry, prev_root);
 
 	printk("\nthe dependencies between the lock to be acquired");
 	printk(" and %s-irq-unsafe lock:\n", irqclass);
-	if (!save_trace(&next_root->trace))
+	if (!save_trace(&next_root->trace, NULL))
 		return 0;
 	print_shortest_lock_dependencies(forwards_entry, next_root);
 
@@ -1885,7 +1891,7 @@ check_prev_add(struct task_struct *curr, struct held_lock *prev,
 	}
 
 	if (!own_trace && stack_saved && !*stack_saved) {
-		if (!save_trace(&trace))
+		if (!save_trace(&trace, NULL))
 			return 0;
 		*stack_saved = 1;
 	}
@@ -2436,7 +2442,7 @@ print_irq_inversion_bug(struct task_struct *curr,
 	lockdep_print_held_locks(curr);
 
 	printk("\nthe shortest dependencies between 2nd lock and 1st lock:\n");
-	if (!save_trace(&root->trace))
+	if (!save_trace(&root->trace, NULL))
 		return 0;
 	print_shortest_lock_dependencies(other, root);
 
@@ -3015,7 +3021,7 @@ static int mark_lock(struct task_struct *curr, struct held_lock *this,
 
 	hlock_class(this)->usage_mask |= new_mask;
 
-	if (!save_trace(hlock_class(this)->usage_traces + new_bit))
+	if (!save_trace(hlock_class(this)->usage_traces + new_bit, NULL))
 		return 0;
 
 	switch (new_bit) {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
