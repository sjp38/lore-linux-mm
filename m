Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 83C186B0261
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 05:48:14 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id o7so370621621oif.0
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 02:48:14 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id x11si25671297ita.12.2016.09.13.02.48.11
        for <linux-mm@kvack.org>;
        Tue, 13 Sep 2016 02:48:11 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v3 06/15] lockdep: Make save_trace can skip stack tracing of the current
Date: Tue, 13 Sep 2016 18:45:05 +0900
Message-Id: <1473759914-17003-7-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

Currently, save_trace() always performs save_stack_trace() for the
current. However, crossrelease needs to use stack trace data of another
context instead of the current. So add a parameter for skipping stack
tracing of the current and make it use trace data, which is already
saved by crossrelease framework.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 33 ++++++++++++++++++++-------------
 1 file changed, 20 insertions(+), 13 deletions(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 3eaa11c..11580ec 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -387,15 +387,22 @@ static void print_lockdep_off(const char *bug_msg)
 #endif
 }
 
-static int save_trace(struct stack_trace *trace)
+static int save_trace(struct stack_trace *trace, int skip_tracing)
 {
-	trace->nr_entries = 0;
-	trace->max_entries = MAX_STACK_TRACE_ENTRIES - nr_stack_trace_entries;
-	trace->entries = stack_trace + nr_stack_trace_entries;
+	unsigned int nr_avail = MAX_STACK_TRACE_ENTRIES - nr_stack_trace_entries;
 
-	trace->skip = 3;
-
-	save_stack_trace(trace);
+	if (skip_tracing) {
+		trace->nr_entries = min(trace->nr_entries, nr_avail);
+		memcpy(stack_trace + nr_stack_trace_entries, trace->entries,
+				trace->nr_entries * sizeof(trace->entries[0]));
+		trace->entries = stack_trace + nr_stack_trace_entries;
+	} else {
+		trace->nr_entries = 0;
+		trace->max_entries = nr_avail;
+		trace->entries = stack_trace + nr_stack_trace_entries;
+		trace->skip = 3;
+		save_stack_trace(trace);
+	}
 
 	/*
 	 * Some daft arches put -1 at the end to indicate its a full trace.
@@ -1172,7 +1179,7 @@ static noinline int print_circular_bug(struct lock_list *this,
 	if (!debug_locks_off_graph_unlock() || debug_locks_silent)
 		return 0;
 
-	if (!save_trace(&this->trace))
+	if (!save_trace(&this->trace, 0))
 		return 0;
 
 	depth = get_lock_depth(target);
@@ -1518,13 +1525,13 @@ print_bad_irq_dependency(struct task_struct *curr,
 
 	printk("\nthe dependencies between %s-irq-safe lock", irqclass);
 	printk(" and the holding lock:\n");
-	if (!save_trace(&prev_root->trace))
+	if (!save_trace(&prev_root->trace, 0))
 		return 0;
 	print_shortest_lock_dependencies(backwards_entry, prev_root);
 
 	printk("\nthe dependencies between the lock to be acquired");
 	printk(" and %s-irq-unsafe lock:\n", irqclass);
-	if (!save_trace(&next_root->trace))
+	if (!save_trace(&next_root->trace, 0))
 		return 0;
 	print_shortest_lock_dependencies(forwards_entry, next_root);
 
@@ -1856,7 +1863,7 @@ check_prev_add(struct task_struct *curr, struct held_lock *prev,
 	}
 
 	if (!own_trace && stack_saved && !*stack_saved) {
-		if (!save_trace(&trace))
+		if (!save_trace(&trace, 0))
 			return 0;
 		*stack_saved = 1;
 	}
@@ -2547,7 +2554,7 @@ print_irq_inversion_bug(struct task_struct *curr,
 	lockdep_print_held_locks(curr);
 
 	printk("\nthe shortest dependencies between 2nd lock and 1st lock:\n");
-	if (!save_trace(&root->trace))
+	if (!save_trace(&root->trace, 0))
 		return 0;
 	print_shortest_lock_dependencies(other, root);
 
@@ -3134,7 +3141,7 @@ static int mark_lock(struct task_struct *curr, struct held_lock *this,
 
 	hlock_class(this)->usage_mask |= new_mask;
 
-	if (!save_trace(hlock_class(this)->usage_traces + new_bit))
+	if (!save_trace(hlock_class(this)->usage_traces + new_bit, 0))
 		return 0;
 
 	switch (new_bit) {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
