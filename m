Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 68D816B000C
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 09:33:04 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id r68-v6so1238855oie.12
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 06:33:04 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id x9-v6si6512454oie.102.2018.11.02.06.33.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 06:33:02 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep messages.
Date: Fri,  2 Nov 2018 22:31:57 +0900
Message-Id: <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>
Cc: Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

syzbot is sometimes getting mixed output like below due to concurrent
printk(). Mitigate such output by using line-buffered printk() API.

  RCU used illegally from idle CPU!
  rcu_scheduler_active = 2, debug_locks = 1
  RSP: 0018:ffffffff88007bb8 EFLAGS: 00000286
  RCU used illegally from extended quiescent state!
   ORIG_RAX: ffffffffffffff13
  1 lock held by swapper/1/0:
  RAX: dffffc0000000000 RBX: 1ffffffff1000f7b RCX: 0000000000000000
   #0: 
  RDX: 1ffffffff10237b8 RSI: 0000000000000001 RDI: ffffffff8811bdc0
  000000004b34587c
  RBP: ffffffff88007bb8 R08: ffffffff88075e00 R09: 0000000000000000
   (
  R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
  rcu_read_lock
  R13: ffffffff88007c78 R14: 0000000000000000 R15: 0000000000000000
  ){....}
   arch_safe_halt arch/x86/include/asm/paravirt.h:94 [inline]
   default_idle+0xc2/0x410 arch/x86/kernel/process.c:498
  , at: trace_call_bpf+0xf8/0x640 kernel/trace/bpf_trace.c:46

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Will Deacon <will.deacon@arm.com>
---
 kernel/locking/lockdep.c | 268 +++++++++++++++++++++++++++--------------------
 1 file changed, 155 insertions(+), 113 deletions(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 1efada2..fbc127d 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -493,7 +493,8 @@ void get_usage_chars(struct lock_class *class, char usage[LOCK_USAGE_CHARS])
 	usage[i] = '\0';
 }
 
-static void __print_lock_name(struct lock_class *class)
+static void __print_lock_name(struct lock_class *class,
+			      struct printk_buffer *buf)
 {
 	char str[KSYM_NAME_LEN];
 	const char *name;
@@ -501,25 +502,25 @@ static void __print_lock_name(struct lock_class *class)
 	name = class->name;
 	if (!name) {
 		name = __get_key_name(class->key, str);
-		printk(KERN_CONT "%s", name);
+		printk_buffered(buf, "%s", name);
 	} else {
-		printk(KERN_CONT "%s", name);
+		printk_buffered(buf, "%s", name);
 		if (class->name_version > 1)
-			printk(KERN_CONT "#%d", class->name_version);
+			printk_buffered(buf, "#%d", class->name_version);
 		if (class->subclass)
-			printk(KERN_CONT "/%d", class->subclass);
+			printk_buffered(buf, "/%d", class->subclass);
 	}
 }
 
-static void print_lock_name(struct lock_class *class)
+static void print_lock_name(struct lock_class *class, struct printk_buffer *buf)
 {
 	char usage[LOCK_USAGE_CHARS];
 
 	get_usage_chars(class, usage);
 
-	printk(KERN_CONT " (");
-	__print_lock_name(class);
-	printk(KERN_CONT "){%s}", usage);
+	printk_buffered(buf, " (");
+	__print_lock_name(class, buf);
+	printk_buffered(buf, "){%s}", usage);
 }
 
 static void print_lockdep_cache(struct lockdep_map *lock)
@@ -534,8 +535,9 @@ static void print_lockdep_cache(struct lockdep_map *lock)
 	printk(KERN_CONT "%s", name);
 }
 
-static void print_lock(struct held_lock *hlock)
+static void print_lock(struct held_lock *hlock, struct printk_buffer *buf)
 {
+	bool free = false;
 	/*
 	 * We can be called locklessly through debug_show_all_locks() so be
 	 * extra careful, the hlock might have been released and cleared.
@@ -546,17 +548,24 @@ static void print_lock(struct held_lock *hlock)
 	barrier();
 
 	if (!class_idx || (class_idx - 1) >= MAX_LOCKDEP_KEYS) {
-		printk(KERN_CONT "<RELEASED>\n");
+		printk_buffered(buf, "<RELEASED>\n");
 		return;
 	}
 
-	printk(KERN_CONT "%p", hlock->instance);
-	print_lock_name(lock_classes + class_idx - 1);
-	printk(KERN_CONT ", at: %pS\n", (void *)hlock->acquire_ip);
+	if (!buf) {
+		free = true;
+		buf = get_printk_buffer();
+	}
+	printk_buffered(buf, "%p", hlock->instance);
+	print_lock_name(lock_classes + class_idx - 1, buf);
+	printk_buffered(buf, ", at: %pS\n", (void *)hlock->acquire_ip);
+	if (free)
+		put_printk_buffer(buf);
 }
 
 static void lockdep_print_held_locks(struct task_struct *p)
 {
+	struct printk_buffer *buf;
 	int i, depth = READ_ONCE(p->lockdep_depth);
 
 	if (!depth)
@@ -570,10 +579,12 @@ static void lockdep_print_held_locks(struct task_struct *p)
 	 */
 	if (p->state == TASK_RUNNING && p != current)
 		return;
+	buf = get_printk_buffer();
 	for (i = 0; i < depth; i++) {
-		printk(" #%d: ", i);
-		print_lock(p->held_locks + i);
+		printk_buffered(buf, " #%d: ", i);
+		print_lock(p->held_locks + i, buf);
 	}
+	put_printk_buffer(buf);
 }
 
 static void print_kernel_ident(void)
@@ -1083,12 +1094,16 @@ static inline int __bfs_backwards(struct lock_list *src_entry,
 static noinline int
 print_circular_bug_entry(struct lock_list *target, int depth)
 {
+	struct printk_buffer *buf;
+
 	if (debug_locks_silent)
 		return 0;
-	printk("\n-> #%u", depth);
-	print_lock_name(target->class);
-	printk(KERN_CONT ":\n");
+	buf = get_printk_buffer();
+	printk_buffered(buf, "\n-> #%u", depth);
+	print_lock_name(target->class, buf);
+	printk_buffered(buf, ":\n");
 	print_stack_trace(&target->trace, 6);
+	put_printk_buffer(buf);
 
 	return 0;
 }
@@ -1098,6 +1113,7 @@ static inline int __bfs_backwards(struct lock_list *src_entry,
 			     struct held_lock *tgt,
 			     struct lock_list *prt)
 {
+	struct printk_buffer *buf = get_printk_buffer();
 	struct lock_class *source = hlock_class(src);
 	struct lock_class *target = hlock_class(tgt);
 	struct lock_class *parent = prt->class;
@@ -1116,31 +1132,32 @@ static inline int __bfs_backwards(struct lock_list *src_entry,
 	 * from the safe_class lock to the unsafe_class lock.
 	 */
 	if (parent != source) {
-		printk("Chain exists of:\n  ");
-		__print_lock_name(source);
-		printk(KERN_CONT " --> ");
-		__print_lock_name(parent);
-		printk(KERN_CONT " --> ");
-		__print_lock_name(target);
-		printk(KERN_CONT "\n\n");
+		printk_buffered(buf, "Chain exists of:\n  ");
+		__print_lock_name(source, buf);
+		printk_buffered(buf, " --> ");
+		__print_lock_name(parent, buf);
+		printk_buffered(buf, " --> ");
+		__print_lock_name(target, buf);
+		printk_buffered(buf, "\n\n");
 	}
 
 	printk(" Possible unsafe locking scenario:\n\n");
 	printk("       CPU0                    CPU1\n");
 	printk("       ----                    ----\n");
-	printk("  lock(");
-	__print_lock_name(target);
-	printk(KERN_CONT ");\n");
+	printk_buffered(buf, "  lock(");
+	__print_lock_name(target, buf);
+	printk_buffered(buf, ");\n");
 	printk("                               lock(");
-	__print_lock_name(parent);
-	printk(KERN_CONT ");\n");
-	printk("                               lock(");
-	__print_lock_name(target);
-	printk(KERN_CONT ");\n");
-	printk("  lock(");
-	__print_lock_name(source);
-	printk(KERN_CONT ");\n");
+	__print_lock_name(parent, buf);
+	printk_buffered(buf, ");\n");
+	printk_buffered(buf, "                               lock(");
+	__print_lock_name(target, buf);
+	printk_buffered(buf, ");\n");
+	printk_buffered(buf, "  lock(");
+	__print_lock_name(source, buf);
+	printk_buffered(buf, ");\n");
 	printk("\n *** DEADLOCK ***\n\n");
+	put_printk_buffer(buf);
 }
 
 /*
@@ -1164,11 +1181,11 @@ static inline int __bfs_backwards(struct lock_list *src_entry,
 	pr_warn("------------------------------------------------------\n");
 	pr_warn("%s/%d is trying to acquire lock:\n",
 		curr->comm, task_pid_nr(curr));
-	print_lock(check_src);
+	print_lock(check_src, NULL);
 
 	pr_warn("\nbut task is already holding lock:\n");
 
-	print_lock(check_tgt);
+	print_lock(check_tgt, NULL);
 	pr_warn("\nwhich lock already depends on the new lock.\n\n");
 	pr_warn("\nthe existing dependency chain (in reverse order) is:\n");
 
@@ -1387,21 +1404,23 @@ static inline int usage_match(struct lock_list *entry, void *bit)
 
 static void print_lock_class_header(struct lock_class *class, int depth)
 {
+	struct printk_buffer *buf = get_printk_buffer();
 	int bit;
 
-	printk("%*s->", depth, "");
-	print_lock_name(class);
+	printk_buffered(buf, "%*s->", depth, "");
+	print_lock_name(class, buf);
 #ifdef CONFIG_DEBUG_LOCKDEP
-	printk(KERN_CONT " ops: %lu", debug_class_ops_read(class));
+	printk_buffered(buf, " ops: %lu", debug_class_ops_read(class));
 #endif
-	printk(KERN_CONT " {\n");
+	printk_buffered(buf, " {\n");
 
 	for (bit = 0; bit < LOCK_USAGE_STATES; bit++) {
 		if (class->usage_mask & (1 << bit)) {
 			int len = depth;
 
-			len += printk("%*s   %s", depth, "", usage_str[bit]);
-			len += printk(KERN_CONT " at:\n");
+			len += printk_buffered(buf, "%*s   %s", depth, "",
+					       usage_str[bit]);
+			len += printk_buffered(buf, " at:\n");
 			print_stack_trace(class->usage_traces + bit, len);
 		}
 	}
@@ -1409,6 +1428,7 @@ static void print_lock_class_header(struct lock_class *class, int depth)
 
 	printk("%*s ... key      at: [<%px>] %pS\n",
 		depth, "", class->key, class->key);
+	put_printk_buffer(buf);
 }
 
 /*
@@ -1451,6 +1471,7 @@ static void print_lock_class_header(struct lock_class *class, int depth)
 	struct lock_class *safe_class = safe_entry->class;
 	struct lock_class *unsafe_class = unsafe_entry->class;
 	struct lock_class *middle_class = prev_class;
+	struct printk_buffer *buf = get_printk_buffer();
 
 	if (middle_class == safe_class)
 		middle_class = next_class;
@@ -1469,33 +1490,34 @@ static void print_lock_class_header(struct lock_class *class, int depth)
 	 * from the safe_class lock to the unsafe_class lock.
 	 */
 	if (middle_class != unsafe_class) {
-		printk("Chain exists of:\n  ");
-		__print_lock_name(safe_class);
-		printk(KERN_CONT " --> ");
-		__print_lock_name(middle_class);
-		printk(KERN_CONT " --> ");
-		__print_lock_name(unsafe_class);
-		printk(KERN_CONT "\n\n");
+		printk_buffered(buf, "Chain exists of:\n  ");
+		__print_lock_name(safe_class, buf);
+		printk_buffered(buf, " --> ");
+		__print_lock_name(middle_class, buf);
+		printk_buffered(buf, " --> ");
+		__print_lock_name(unsafe_class, buf);
+		printk_buffered(buf, "\n\n");
 	}
 
 	printk(" Possible interrupt unsafe locking scenario:\n\n");
 	printk("       CPU0                    CPU1\n");
 	printk("       ----                    ----\n");
-	printk("  lock(");
-	__print_lock_name(unsafe_class);
-	printk(KERN_CONT ");\n");
+	printk_buffered(buf, "  lock(");
+	__print_lock_name(unsafe_class, buf);
+	printk_buffered(buf, ");\n");
 	printk("                               local_irq_disable();\n");
-	printk("                               lock(");
-	__print_lock_name(safe_class);
-	printk(KERN_CONT ");\n");
-	printk("                               lock(");
-	__print_lock_name(middle_class);
-	printk(KERN_CONT ");\n");
+	printk_buffered(buf, "                               lock(");
+	__print_lock_name(safe_class, buf);
+	printk_buffered(buf, ");\n");
+	printk_buffered(buf, "                               lock(");
+	__print_lock_name(middle_class, buf);
+	printk_buffered(buf, ");\n");
 	printk("  <Interrupt>\n");
-	printk("    lock(");
-	__print_lock_name(safe_class);
-	printk(KERN_CONT ");\n");
+	printk_buffered(buf, "    lock(");
+	__print_lock_name(safe_class, buf);
+	printk_buffered(buf, ");\n");
 	printk("\n *** DEADLOCK ***\n\n");
+	put_printk_buffer(buf);
 }
 
 static int
@@ -1510,9 +1532,12 @@ static void print_lock_class_header(struct lock_class *class, int depth)
 			 enum lock_usage_bit bit2,
 			 const char *irqclass)
 {
+	struct printk_buffer *buf;
+
 	if (!debug_locks_off_graph_unlock() || debug_locks_silent)
 		return 0;
 
+	buf = get_printk_buffer();
 	pr_warn("\n");
 	pr_warn("=====================================================\n");
 	pr_warn("WARNING: %s-safe -> %s-unsafe lock order detected\n",
@@ -1525,26 +1550,26 @@ static void print_lock_class_header(struct lock_class *class, int depth)
 		curr->softirq_context, softirq_count() >> SOFTIRQ_SHIFT,
 		curr->hardirqs_enabled,
 		curr->softirqs_enabled);
-	print_lock(next);
+	print_lock(next, buf);
 
 	pr_warn("\nand this task is already holding:\n");
-	print_lock(prev);
+	print_lock(prev, buf);
 	pr_warn("which would create a new lock dependency:\n");
-	print_lock_name(hlock_class(prev));
-	pr_cont(" ->");
-	print_lock_name(hlock_class(next));
-	pr_cont("\n");
+	print_lock_name(hlock_class(prev), buf);
+	bpr_cont(buf, " ->");
+	print_lock_name(hlock_class(next), buf);
+	bpr_cont(buf, "\n");
 
 	pr_warn("\nbut this new dependency connects a %s-irq-safe lock:\n",
 		irqclass);
-	print_lock_name(backwards_entry->class);
-	pr_warn("\n... which became %s-irq-safe at:\n", irqclass);
+	print_lock_name(backwards_entry->class, buf);
+	bpr_warn(buf, "\n... which became %s-irq-safe at:\n", irqclass);
 
 	print_stack_trace(backwards_entry->class->usage_traces + bit1, 1);
 
 	pr_warn("\nto a %s-irq-unsafe lock:\n", irqclass);
-	print_lock_name(forwards_entry->class);
-	pr_warn("\n... which became %s-irq-unsafe at:\n", irqclass);
+	print_lock_name(forwards_entry->class, buf);
+	bpr_warn(buf, "\n... which became %s-irq-unsafe at:\n", irqclass);
 	pr_warn("...");
 
 	print_stack_trace(forwards_entry->class->usage_traces + bit2, 1);
@@ -1557,18 +1582,20 @@ static void print_lock_class_header(struct lock_class *class, int depth)
 
 	pr_warn("\nthe dependencies between %s-irq-safe lock and the holding lock:\n", irqclass);
 	if (!save_trace(&prev_root->trace))
-		return 0;
+		goto done;
 	print_shortest_lock_dependencies(backwards_entry, prev_root);
 
 	pr_warn("\nthe dependencies between the lock to be acquired");
 	pr_warn(" and %s-irq-unsafe lock:\n", irqclass);
 	if (!save_trace(&next_root->trace))
-		return 0;
+		goto done;
 	print_shortest_lock_dependencies(forwards_entry, next_root);
 
 	pr_warn("\nstack backtrace:\n");
 	dump_stack();
 
+ done:
+	put_printk_buffer(buf);
 	return 0;
 }
 
@@ -1721,18 +1748,20 @@ static inline void inc_chains(void)
 {
 	struct lock_class *next = hlock_class(nxt);
 	struct lock_class *prev = hlock_class(prv);
+	struct printk_buffer *buf = get_printk_buffer();
 
 	printk(" Possible unsafe locking scenario:\n\n");
 	printk("       CPU0\n");
 	printk("       ----\n");
-	printk("  lock(");
-	__print_lock_name(prev);
-	printk(KERN_CONT ");\n");
-	printk("  lock(");
-	__print_lock_name(next);
-	printk(KERN_CONT ");\n");
+	printk_buffered(buf, "  lock(");
+	__print_lock_name(prev, buf);
+	printk_buffered(buf, ");\n");
+	printk_buffered(buf, "  lock(");
+	__print_lock_name(next, buf);
+	printk_buffered(buf, ");\n");
 	printk("\n *** DEADLOCK ***\n\n");
 	printk(" May be due to missing lock nesting notation\n\n");
+	put_printk_buffer(buf);
 }
 
 static int
@@ -1749,9 +1778,9 @@ static inline void inc_chains(void)
 	pr_warn("--------------------------------------------\n");
 	pr_warn("%s/%d is trying to acquire lock:\n",
 		curr->comm, task_pid_nr(curr));
-	print_lock(next);
+	print_lock(next, NULL);
 	pr_warn("\nbut task is already holding lock:\n");
-	print_lock(prev);
+	print_lock(prev, NULL);
 
 	pr_warn("\nother info that might help us debug this:\n");
 	print_deadlock_scenario(next, prev);
@@ -2048,18 +2077,20 @@ static inline int get_first_held_lock(struct task_struct *curr,
 /*
  * Returns the next chain_key iteration
  */
-static u64 print_chain_key_iteration(int class_idx, u64 chain_key)
+static u64 print_chain_key_iteration(int class_idx, u64 chain_key,
+				     struct printk_buffer *buf)
 {
 	u64 new_chain_key = iterate_chain_key(chain_key, class_idx);
 
-	printk(" class_idx:%d -> chain_key:%016Lx",
+	printk_buffered(buf, " class_idx:%d -> chain_key:%016Lx",
 		class_idx,
 		(unsigned long long)new_chain_key);
 	return new_chain_key;
 }
 
-static void
-print_chain_keys_held_locks(struct task_struct *curr, struct held_lock *hlock_next)
+static void print_chain_keys_held_locks(struct task_struct *curr,
+					struct held_lock *hlock_next,
+					struct printk_buffer *buf)
 {
 	struct held_lock *hlock;
 	u64 chain_key = 0;
@@ -2069,16 +2100,18 @@ static u64 print_chain_key_iteration(int class_idx, u64 chain_key)
 	printk("depth: %u\n", depth + 1);
 	for (i = get_first_held_lock(curr, hlock_next); i < depth; i++) {
 		hlock = curr->held_locks + i;
-		chain_key = print_chain_key_iteration(hlock->class_idx, chain_key);
+		chain_key = print_chain_key_iteration(hlock->class_idx,
+						      chain_key, buf);
 
-		print_lock(hlock);
+		print_lock(hlock, buf);
 	}
 
-	print_chain_key_iteration(hlock_next->class_idx, chain_key);
-	print_lock(hlock_next);
+	print_chain_key_iteration(hlock_next->class_idx, chain_key, buf);
+	print_lock(hlock_next, buf);
 }
 
-static void print_chain_keys_chain(struct lock_chain *chain)
+static void print_chain_keys_chain(struct lock_chain *chain,
+				   struct printk_buffer *buf)
 {
 	int i;
 	u64 chain_key = 0;
@@ -2087,10 +2120,11 @@ static void print_chain_keys_chain(struct lock_chain *chain)
 	printk("depth: %u\n", chain->depth);
 	for (i = 0; i < chain->depth; i++) {
 		class_id = chain_hlocks[chain->base + i];
-		chain_key = print_chain_key_iteration(class_id + 1, chain_key);
+		chain_key = print_chain_key_iteration(class_id + 1, chain_key,
+						      buf);
 
-		print_lock_name(lock_classes + class_id);
-		printk("\n");
+		print_lock_name(lock_classes + class_id, buf);
+		printk_buffered(buf, "\n");
 	}
 }
 
@@ -2098,6 +2132,8 @@ static void print_collision(struct task_struct *curr,
 			struct held_lock *hlock_next,
 			struct lock_chain *chain)
 {
+	struct printk_buffer *buf = get_printk_buffer();
+
 	pr_warn("\n");
 	pr_warn("============================\n");
 	pr_warn("WARNING: chain_key collision\n");
@@ -2106,14 +2142,15 @@ static void print_collision(struct task_struct *curr,
 	pr_warn("%s/%d: ", current->comm, task_pid_nr(current));
 	pr_warn("Hash chain already cached but the contents don't match!\n");
 
-	pr_warn("Held locks:");
-	print_chain_keys_held_locks(curr, hlock_next);
+	bpr_warn(buf, "Held locks:");
+	print_chain_keys_held_locks(curr, hlock_next, buf);
 
-	pr_warn("Locks in cached chain:");
-	print_chain_keys_chain(chain);
+	bpr_warn(buf, "Locks in cached chain:");
+	print_chain_keys_chain(chain, buf);
 
 	pr_warn("\nstack backtrace:\n");
 	dump_stack();
+	put_printk_buffer(buf);
 }
 #endif
 
@@ -2421,18 +2458,20 @@ static void check_chain_key(struct task_struct *curr)
 print_usage_bug_scenario(struct held_lock *lock)
 {
 	struct lock_class *class = hlock_class(lock);
+	struct printk_buffer *buf = get_printk_buffer();
 
 	printk(" Possible unsafe locking scenario:\n\n");
 	printk("       CPU0\n");
 	printk("       ----\n");
-	printk("  lock(");
-	__print_lock_name(class);
-	printk(KERN_CONT ");\n");
+	printk_buffered(buf, "  lock(");
+	__print_lock_name(class, buf);
+	printk_buffered(buf, ");\n");
 	printk("  <Interrupt>\n");
-	printk("    lock(");
-	__print_lock_name(class);
-	printk(KERN_CONT ");\n");
+	printk_buffered(buf, "    lock(");
+	__print_lock_name(class, buf);
+	printk_buffered(buf, ");\n");
 	printk("\n *** DEADLOCK ***\n\n");
+	put_printk_buffer(buf);
 }
 
 static int
@@ -2457,7 +2496,7 @@ static void check_chain_key(struct task_struct *curr)
 		trace_softirq_context(curr), softirq_count() >> SOFTIRQ_SHIFT,
 		trace_hardirqs_enabled(curr),
 		trace_softirqs_enabled(curr));
-	print_lock(this);
+	print_lock(this, NULL);
 
 	pr_warn("{%s} state was registered at:\n", usage_str[prev_bit]);
 	print_stack_trace(hlock_class(this)->usage_traces + prev_bit, 1);
@@ -2500,6 +2539,7 @@ static int mark_lock(struct task_struct *curr, struct held_lock *this,
 			struct held_lock *this, int forwards,
 			const char *irqclass)
 {
+	struct printk_buffer *buf;
 	struct lock_list *entry = other;
 	struct lock_list *middle = NULL;
 	int depth;
@@ -2514,13 +2554,15 @@ static int mark_lock(struct task_struct *curr, struct held_lock *this,
 	pr_warn("--------------------------------------------------------\n");
 	pr_warn("%s/%d just changed the state of lock:\n",
 		curr->comm, task_pid_nr(curr));
-	print_lock(this);
+	print_lock(this, NULL);
 	if (forwards)
 		pr_warn("but this lock took another, %s-unsafe lock in the past:\n", irqclass);
 	else
 		pr_warn("but this lock was taken by another, %s-safe lock in the past:\n", irqclass);
-	print_lock_name(other->class);
-	pr_warn("\n\nand interrupts could create inverse lock ordering between them.\n\n");
+	buf = get_printk_buffer();
+	print_lock_name(other->class, buf);
+	bpr_warn(buf, "\n\nand interrupts could create inverse lock ordering between them.\n\n");
+	put_printk_buffer(buf);
 
 	pr_warn("\nother info that might help us debug this:\n");
 
@@ -3077,7 +3119,7 @@ static int mark_lock(struct task_struct *curr, struct held_lock *this,
 	 */
 	if (ret == 2) {
 		printk("\nmarked lock as {%s}:\n", usage_str[new_bit]);
-		print_lock(this);
+		print_lock(this, NULL);
 		print_irqtrace_events(curr);
 		dump_stack();
 	}
@@ -3172,7 +3214,7 @@ void lockdep_init_map(struct lockdep_map *lock, const char *name,
 	pr_warn("----------------------------------\n");
 
 	pr_warn("%s/%d is trying to lock:\n", curr->comm, task_pid_nr(curr));
-	print_lock(hlock);
+	print_lock(hlock, NULL);
 
 	pr_warn("\nbut this task is not holding:\n");
 	pr_warn("%s\n", hlock->nest_lock->name);
@@ -4300,7 +4342,7 @@ void __init lockdep_init(void)
 	pr_warn("-------------------------\n");
 	pr_warn("%s/%d is freeing memory %px-%px, with a lock still held there!\n",
 		curr->comm, task_pid_nr(curr), mem_from, mem_to-1);
-	print_lock(hlock);
+	print_lock(hlock, NULL);
 	lockdep_print_held_locks(curr);
 
 	pr_warn("\nstack backtrace:\n");
-- 
1.8.3.1
