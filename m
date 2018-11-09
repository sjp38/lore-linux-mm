Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 25DAE6B06C4
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 04:55:50 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id e144-v6so1473339iof.13
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 01:55:50 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 62-v6si126909ito.66.2018.11.09.01.55.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 01:55:46 -0800 (PST)
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181107151900.gxmdvx42qeanpoah@pathway.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <3786fdc3-49a5-281f-74cd-c7f37fb06748@i-love.sakura.ne.jp>
Date: Fri, 9 Nov 2018 18:54:56 +0900
MIME-Version: 1.0
In-Reply-To: <20181107151900.gxmdvx42qeanpoah@pathway.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On 2018/11/08 0:19, Petr Mladek wrote:
> I really hope that the maze of pr_cont() calls in lockdep.c is the most
> complicated one that we would meet.
> 
> Anyway, the following comes to my mind:
> 
> 1. The mixing of normal and buffered printk calls is a bit confusing
>    and error prone. It would make sense to use the buffered printk
>    everywhere in the given section of code even when it is not
>    strictly needed.

Here is a draft version for how the code would look like...

 include/linux/printk.h   |  16 ++
 kernel/locking/lockdep.c | 711 ++++++++++++++++++++++++++---------------------
 2 files changed, 404 insertions(+), 323 deletions(-)

diff --git a/include/linux/printk.h b/include/linux/printk.h
index cf3eccf..ff4f66c 100644
--- a/include/linux/printk.h
+++ b/include/linux/printk.h
@@ -530,4 +530,20 @@ static inline void print_hex_dump_debug(const char *prefix_str, int prefix_type,
 }
 #endif
 
+struct printk_buffer;
+struct printk_buffer *get_printk_buffer(void);
+void put_printk_buffer(struct printk_buffer *buf);
+__printf(2, 3)
+int bprintk(struct printk_buffer *buf, const char *fmt, ...);
+
+#define bpr_info(buf, fmt, ...)				\
+	bprintk(buf, KERN_INFO pr_fmt(fmt), ##__VA_ARGS__)
+#define bpr_warning(buf, fmt, ...)				\
+	bprintk(buf, KERN_WARNING pr_fmt(fmt), ##__VA_ARGS__)
+#define bpr_warn bpr_warning
+#define bpr_err(buf, fmt, ...)				\
+	bprintk(buf, KERN_ERR pr_fmt(fmt), ##__VA_ARGS__)
+#define bpr_cont(buf, fmt, ...)			\
+	bprintk(buf, KERN_CONT fmt, ##__VA_ARGS__)
+
 #endif
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 1efada2..22b85aa 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -493,7 +493,7 @@ void get_usage_chars(struct lock_class *class, char usage[LOCK_USAGE_CHARS])
 	usage[i] = '\0';
 }
 
-static void __print_lock_name(struct lock_class *class)
+static void __print_lock_name(struct printk_buffer *buf, struct lock_class *class)
 {
 	char str[KSYM_NAME_LEN];
 	const char *name;
@@ -501,28 +501,28 @@ static void __print_lock_name(struct lock_class *class)
 	name = class->name;
 	if (!name) {
 		name = __get_key_name(class->key, str);
-		printk(KERN_CONT "%s", name);
+		bprintk(buf, KERN_CONT "%s", name);
 	} else {
-		printk(KERN_CONT "%s", name);
+		bprintk(buf, KERN_CONT "%s", name);
 		if (class->name_version > 1)
-			printk(KERN_CONT "#%d", class->name_version);
+			bprintk(buf, KERN_CONT "#%d", class->name_version);
 		if (class->subclass)
-			printk(KERN_CONT "/%d", class->subclass);
+			bprintk(buf, KERN_CONT "/%d", class->subclass);
 	}
 }
 
-static void print_lock_name(struct lock_class *class)
+static void print_lock_name(struct printk_buffer *buf, struct lock_class *class)
 {
 	char usage[LOCK_USAGE_CHARS];
 
 	get_usage_chars(class, usage);
 
-	printk(KERN_CONT " (");
-	__print_lock_name(class);
-	printk(KERN_CONT "){%s}", usage);
+	bprintk(buf, KERN_CONT " (");
+	__print_lock_name(buf, class);
+	bprintk(buf, KERN_CONT "){%s}", usage);
 }
 
-static void print_lockdep_cache(struct lockdep_map *lock)
+static void print_lockdep_cache(struct printk_buffer *buf, struct lockdep_map *lock)
 {
 	const char *name;
 	char str[KSYM_NAME_LEN];
@@ -531,10 +531,10 @@ static void print_lockdep_cache(struct lockdep_map *lock)
 	if (!name)
 		name = __get_key_name(lock->key->subkeys, str);
 
-	printk(KERN_CONT "%s", name);
+	bprintk(buf, KERN_CONT "%s", name);
 }
 
-static void print_lock(struct held_lock *hlock)
+static void print_lock(struct printk_buffer *buf, struct held_lock *hlock)
 {
 	/*
 	 * We can be called locklessly through debug_show_all_locks() so be
@@ -546,23 +546,23 @@ static void print_lock(struct held_lock *hlock)
 	barrier();
 
 	if (!class_idx || (class_idx - 1) >= MAX_LOCKDEP_KEYS) {
-		printk(KERN_CONT "<RELEASED>\n");
+		bprintk(buf, KERN_CONT "<RELEASED>\n");
 		return;
 	}
 
-	printk(KERN_CONT "%p", hlock->instance);
-	print_lock_name(lock_classes + class_idx - 1);
-	printk(KERN_CONT ", at: %pS\n", (void *)hlock->acquire_ip);
+	bprintk(buf, KERN_CONT "%p", hlock->instance);
+	print_lock_name(buf, lock_classes + class_idx - 1);
+	bprintk(buf, KERN_CONT ", at: %pS\n", (void *)hlock->acquire_ip);
 }
 
-static void lockdep_print_held_locks(struct task_struct *p)
+static void lockdep_print_held_locks(struct printk_buffer *buf, struct task_struct *p)
 {
 	int i, depth = READ_ONCE(p->lockdep_depth);
 
 	if (!depth)
-		printk("no locks held by %s/%d.\n", p->comm, task_pid_nr(p));
+		bprintk(buf, "no locks held by %s/%d.\n", p->comm, task_pid_nr(p));
 	else
-		printk("%d lock%s held by %s/%d:\n", depth,
+		bprintk(buf, "%d lock%s held by %s/%d:\n", depth,
 		       depth > 1 ? "s" : "", p->comm, task_pid_nr(p));
 	/*
 	 * It's not reliable to print a task's held locks if it's not sleeping
@@ -571,14 +571,14 @@ static void lockdep_print_held_locks(struct task_struct *p)
 	if (p->state == TASK_RUNNING && p != current)
 		return;
 	for (i = 0; i < depth; i++) {
-		printk(" #%d: ", i);
-		print_lock(p->held_locks + i);
+		bprintk(buf, " #%d: ", i);
+		print_lock(buf, p->held_locks + i);
 	}
 }
 
-static void print_kernel_ident(void)
+static void print_kernel_ident(struct printk_buffer *buf)
 {
-	printk("%s %.*s %s\n", init_utsname()->release,
+	bprintk(buf, "%s %.*s %s\n", init_utsname()->release,
 		(int)strcspn(init_utsname()->version, " "),
 		init_utsname()->version,
 		print_tainted());
@@ -804,12 +804,14 @@ static bool assign_lock_key(struct lockdep_map *lock)
 	list_add_tail_rcu(&class->lock_entry, &all_lock_classes);
 
 	if (verbose(class)) {
+		struct printk_buffer *buf = get_printk_buffer();
 		graph_unlock();
 
-		printk("\nnew class %px: %s", class->key, class->name);
+		bprintk(buf, "\nnew class %px: %s", class->key, class->name);
 		if (class->name_version > 1)
-			printk(KERN_CONT "#%d", class->name_version);
-		printk(KERN_CONT "\n");
+			bprintk(buf, KERN_CONT "#%d", class->name_version);
+		bprintk(buf, KERN_CONT "\n");
+		put_printk_buffer(buf);
 		dump_stack();
 
 		if (!graph_lock()) {
@@ -1081,20 +1083,20 @@ static inline int __bfs_backwards(struct lock_list *src_entry,
  * has been detected):
  */
 static noinline int
-print_circular_bug_entry(struct lock_list *target, int depth)
+print_circular_bug_entry(struct printk_buffer *buf, struct lock_list *target, int depth)
 {
 	if (debug_locks_silent)
 		return 0;
-	printk("\n-> #%u", depth);
-	print_lock_name(target->class);
-	printk(KERN_CONT ":\n");
+	bprintk(buf, "\n-> #%u", depth);
+	print_lock_name(buf, target->class);
+	bprintk(buf, KERN_CONT ":\n");
 	print_stack_trace(&target->trace, 6);
 
 	return 0;
 }
 
 static void
-print_circular_lock_scenario(struct held_lock *src,
+print_circular_lock_scenario(struct printk_buffer *buf, struct held_lock *src,
 			     struct held_lock *tgt,
 			     struct lock_list *prt)
 {
@@ -1116,31 +1118,31 @@ static inline int __bfs_backwards(struct lock_list *src_entry,
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
+		bprintk(buf, "Chain exists of:\n  ");
+		__print_lock_name(buf, source);
+		bprintk(buf, KERN_CONT " --> ");
+		__print_lock_name(buf, parent);
+		bprintk(buf, KERN_CONT " --> ");
+		__print_lock_name(buf, target);
+		bprintk(buf, KERN_CONT "\n\n");
 	}
 
-	printk(" Possible unsafe locking scenario:\n\n");
-	printk("       CPU0                    CPU1\n");
-	printk("       ----                    ----\n");
-	printk("  lock(");
-	__print_lock_name(target);
-	printk(KERN_CONT ");\n");
-	printk("                               lock(");
-	__print_lock_name(parent);
-	printk(KERN_CONT ");\n");
-	printk("                               lock(");
-	__print_lock_name(target);
-	printk(KERN_CONT ");\n");
-	printk("  lock(");
-	__print_lock_name(source);
-	printk(KERN_CONT ");\n");
-	printk("\n *** DEADLOCK ***\n\n");
+	bprintk(buf, " Possible unsafe locking scenario:\n\n");
+	bprintk(buf, "       CPU0                    CPU1\n");
+	bprintk(buf, "       ----                    ----\n");
+	bprintk(buf, "  lock(");
+	__print_lock_name(buf, target);
+	bprintk(buf, KERN_CONT ");\n");
+	bprintk(buf, "                               lock(");
+	__print_lock_name(buf, parent);
+	bprintk(buf, KERN_CONT ");\n");
+	bprintk(buf, "                               lock(");
+	__print_lock_name(buf, target);
+	bprintk(buf, KERN_CONT ");\n");
+	bprintk(buf, "  lock(");
+	__print_lock_name(buf, source);
+	bprintk(buf, KERN_CONT ");\n");
+	bprintk(buf, "\n *** DEADLOCK ***\n\n");
 }
 
 /*
@@ -1148,7 +1150,7 @@ static inline int __bfs_backwards(struct lock_list *src_entry,
  * header first:
  */
 static noinline int
-print_circular_bug_header(struct lock_list *entry, unsigned int depth,
+print_circular_bug_header(struct printk_buffer *buf, struct lock_list *entry, unsigned int depth,
 			struct held_lock *check_src,
 			struct held_lock *check_tgt)
 {
@@ -1157,22 +1159,22 @@ static inline int __bfs_backwards(struct lock_list *src_entry,
 	if (debug_locks_silent)
 		return 0;
 
-	pr_warn("\n");
-	pr_warn("======================================================\n");
-	pr_warn("WARNING: possible circular locking dependency detected\n");
-	print_kernel_ident();
-	pr_warn("------------------------------------------------------\n");
-	pr_warn("%s/%d is trying to acquire lock:\n",
+	bpr_warn(buf, "\n");
+	bpr_warn(buf, "======================================================\n");
+	bpr_warn(buf, "WARNING: possible circular locking dependency detected\n");
+	print_kernel_ident(buf);
+	bpr_warn(buf, "------------------------------------------------------\n");
+	bpr_warn(buf, "%s/%d is trying to acquire lock:\n",
 		curr->comm, task_pid_nr(curr));
-	print_lock(check_src);
+	print_lock(buf, check_src);
 
-	pr_warn("\nbut task is already holding lock:\n");
+	bpr_warn(buf, "\nbut task is already holding lock:\n");
 
-	print_lock(check_tgt);
-	pr_warn("\nwhich lock already depends on the new lock.\n\n");
-	pr_warn("\nthe existing dependency chain (in reverse order) is:\n");
+	print_lock(buf, check_tgt);
+	bpr_warn(buf, "\nwhich lock already depends on the new lock.\n\n");
+	bpr_warn(buf, "\nthe existing dependency chain (in reverse order) is:\n");
 
-	print_circular_bug_entry(entry, depth);
+	print_circular_bug_entry(buf, entry, depth);
 
 	return 0;
 }
@@ -1188,6 +1190,7 @@ static noinline int print_circular_bug(struct lock_list *this,
 				struct held_lock *check_tgt,
 				struct stack_trace *trace)
 {
+	struct printk_buffer *buf;
 	struct task_struct *curr = current;
 	struct lock_list *parent;
 	struct lock_list *first_parent;
@@ -1199,25 +1202,27 @@ static noinline int print_circular_bug(struct lock_list *this,
 	if (!save_trace(&this->trace))
 		return 0;
 
+	buf = get_printk_buffer();
 	depth = get_lock_depth(target);
 
-	print_circular_bug_header(target, depth, check_src, check_tgt);
+	print_circular_bug_header(buf, target, depth, check_src, check_tgt);
 
 	parent = get_lock_parent(target);
 	first_parent = parent;
 
 	while (parent) {
-		print_circular_bug_entry(parent, --depth);
+		print_circular_bug_entry(buf, parent, --depth);
 		parent = get_lock_parent(parent);
 	}
 
-	printk("\nother info that might help us debug this:\n\n");
-	print_circular_lock_scenario(check_src, check_tgt,
+	bprintk(buf, "\nother info that might help us debug this:\n\n");
+	print_circular_lock_scenario(buf, check_src, check_tgt,
 				     first_parent);
 
-	lockdep_print_held_locks(curr);
+	lockdep_print_held_locks(buf, curr);
 
-	printk("\nstack backtrace:\n");
+	bprintk(buf, "\nstack backtrace:\n");
+	put_printk_buffer(buf);
 	dump_stack();
 
 	return 0;
@@ -1385,29 +1390,29 @@ static inline int usage_match(struct lock_list *entry, void *bit)
 	return result;
 }
 
-static void print_lock_class_header(struct lock_class *class, int depth)
+static void print_lock_class_header(struct printk_buffer *buf, struct lock_class *class, int depth)
 {
 	int bit;
 
-	printk("%*s->", depth, "");
-	print_lock_name(class);
+	bprintk(buf, "%*s->", depth, "");
+	print_lock_name(buf, class);
 #ifdef CONFIG_DEBUG_LOCKDEP
-	printk(KERN_CONT " ops: %lu", debug_class_ops_read(class));
+	bprintk(buf, KERN_CONT " ops: %lu", debug_class_ops_read(class));
 #endif
-	printk(KERN_CONT " {\n");
+	bprintk(buf, KERN_CONT " {\n");
 
 	for (bit = 0; bit < LOCK_USAGE_STATES; bit++) {
 		if (class->usage_mask & (1 << bit)) {
 			int len = depth;
 
-			len += printk("%*s   %s", depth, "", usage_str[bit]);
-			len += printk(KERN_CONT " at:\n");
+			len += bprintk(buf, "%*s   %s", depth, "", usage_str[bit]);
+			len += bprintk(buf, KERN_CONT " at:\n");
 			print_stack_trace(class->usage_traces + bit, len);
 		}
 	}
-	printk("%*s }\n", depth, "");
+	bprintk(buf, "%*s }\n", depth, "");
 
-	printk("%*s ... key      at: [<%px>] %pS\n",
+	bprintk(buf, "%*s ... key      at: [<%px>] %pS\n",
 		depth, "", class->key, class->key);
 }
 
@@ -1415,7 +1420,7 @@ static void print_lock_class_header(struct lock_class *class, int depth)
  * printk the shortest lock dependencies from @start to @end in reverse order:
  */
 static void __used
-print_shortest_lock_dependencies(struct lock_list *leaf,
+print_shortest_lock_dependencies(struct printk_buffer *buf, struct lock_list *leaf,
 				struct lock_list *root)
 {
 	struct lock_list *entry = leaf;
@@ -1425,13 +1430,13 @@ static void print_lock_class_header(struct lock_class *class, int depth)
 	depth = get_lock_depth(leaf);
 
 	do {
-		print_lock_class_header(entry->class, depth);
-		printk("%*s ... acquired at:\n", depth, "");
+		print_lock_class_header(buf, entry->class, depth);
+		bprintk(buf, "%*s ... acquired at:\n", depth, "");
 		print_stack_trace(&entry->trace, 2);
-		printk("\n");
+		bprintk(buf, "\n");
 
 		if (depth == 0 && (entry != root)) {
-			printk("lockdep:%s bad path found in chain graph\n", __func__);
+			bprintk(buf, "lockdep:%s bad path found in chain graph\n", __func__);
 			break;
 		}
 
@@ -1443,7 +1448,7 @@ static void print_lock_class_header(struct lock_class *class, int depth)
 }
 
 static void
-print_irq_lock_scenario(struct lock_list *safe_entry,
+print_irq_lock_scenario(struct printk_buffer *buf, struct lock_list *safe_entry,
 			struct lock_list *unsafe_entry,
 			struct lock_class *prev_class,
 			struct lock_class *next_class)
@@ -1469,33 +1474,33 @@ static void print_lock_class_header(struct lock_class *class, int depth)
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
+		bprintk(buf, "Chain exists of:\n  ");
+		__print_lock_name(buf, safe_class);
+		bprintk(buf, KERN_CONT " --> ");
+		__print_lock_name(buf, middle_class);
+		bprintk(buf, KERN_CONT " --> ");
+		__print_lock_name(buf, unsafe_class);
+		bprintk(buf, KERN_CONT "\n\n");
 	}
 
-	printk(" Possible interrupt unsafe locking scenario:\n\n");
-	printk("       CPU0                    CPU1\n");
-	printk("       ----                    ----\n");
-	printk("  lock(");
-	__print_lock_name(unsafe_class);
-	printk(KERN_CONT ");\n");
-	printk("                               local_irq_disable();\n");
-	printk("                               lock(");
-	__print_lock_name(safe_class);
-	printk(KERN_CONT ");\n");
-	printk("                               lock(");
-	__print_lock_name(middle_class);
-	printk(KERN_CONT ");\n");
-	printk("  <Interrupt>\n");
-	printk("    lock(");
-	__print_lock_name(safe_class);
-	printk(KERN_CONT ");\n");
-	printk("\n *** DEADLOCK ***\n\n");
+	bprintk(buf, " Possible interrupt unsafe locking scenario:\n\n");
+	bprintk(buf, "       CPU0                    CPU1\n");
+	bprintk(buf, "       ----                    ----\n");
+	bprintk(buf, "  lock(");
+	__print_lock_name(buf, unsafe_class);
+	bprintk(buf, KERN_CONT ");\n");
+	bprintk(buf, "                               local_irq_disable();\n");
+	bprintk(buf, "                               lock(");
+	__print_lock_name(buf, safe_class);
+	bprintk(buf, KERN_CONT ");\n");
+	bprintk(buf, "                               lock(");
+	__print_lock_name(buf, middle_class);
+	bprintk(buf, KERN_CONT ");\n");
+	bprintk(buf, "  <Interrupt>\n");
+	bprintk(buf, "    lock(");
+	__print_lock_name(buf, safe_class);
+	bprintk(buf, KERN_CONT ");\n");
+	bprintk(buf, "\n *** DEADLOCK ***\n\n");
 }
 
 static int
@@ -1510,65 +1515,69 @@ static void print_lock_class_header(struct lock_class *class, int depth)
 			 enum lock_usage_bit bit2,
 			 const char *irqclass)
 {
+	struct printk_buffer *buf;
+
 	if (!debug_locks_off_graph_unlock() || debug_locks_silent)
 		return 0;
 
-	pr_warn("\n");
-	pr_warn("=====================================================\n");
-	pr_warn("WARNING: %s-safe -> %s-unsafe lock order detected\n",
+	buf = get_printk_buffer();
+	bpr_warn(buf, "\n");
+	bpr_warn(buf, "=====================================================\n");
+	bpr_warn(buf, "WARNING: %s-safe -> %s-unsafe lock order detected\n",
 		irqclass, irqclass);
-	print_kernel_ident();
-	pr_warn("-----------------------------------------------------\n");
-	pr_warn("%s/%d [HC%u[%lu]:SC%u[%lu]:HE%u:SE%u] is trying to acquire:\n",
+	print_kernel_ident(buf);
+	bpr_warn(buf, "-----------------------------------------------------\n");
+	bpr_warn(buf, "%s/%d [HC%u[%lu]:SC%u[%lu]:HE%u:SE%u] is trying to acquire:\n",
 		curr->comm, task_pid_nr(curr),
 		curr->hardirq_context, hardirq_count() >> HARDIRQ_SHIFT,
 		curr->softirq_context, softirq_count() >> SOFTIRQ_SHIFT,
 		curr->hardirqs_enabled,
 		curr->softirqs_enabled);
-	print_lock(next);
+	print_lock(buf, next);
 
-	pr_warn("\nand this task is already holding:\n");
-	print_lock(prev);
-	pr_warn("which would create a new lock dependency:\n");
-	print_lock_name(hlock_class(prev));
-	pr_cont(" ->");
-	print_lock_name(hlock_class(next));
-	pr_cont("\n");
+	bpr_warn(buf, "\nand this task is already holding:\n");
+	print_lock(buf, prev);
+	bpr_warn(buf, "which would create a new lock dependency:\n");
+	print_lock_name(buf, hlock_class(prev));
+	bpr_cont(buf, " ->");
+	print_lock_name(buf, hlock_class(next));
+	bpr_cont(buf, "\n");
 
-	pr_warn("\nbut this new dependency connects a %s-irq-safe lock:\n",
+	bpr_warn(buf, "\nbut this new dependency connects a %s-irq-safe lock:\n",
 		irqclass);
-	print_lock_name(backwards_entry->class);
-	pr_warn("\n... which became %s-irq-safe at:\n", irqclass);
+	print_lock_name(buf, backwards_entry->class);
+	bpr_warn(buf, "\n... which became %s-irq-safe at:\n", irqclass);
 
 	print_stack_trace(backwards_entry->class->usage_traces + bit1, 1);
 
-	pr_warn("\nto a %s-irq-unsafe lock:\n", irqclass);
-	print_lock_name(forwards_entry->class);
-	pr_warn("\n... which became %s-irq-unsafe at:\n", irqclass);
-	pr_warn("...");
+	bpr_warn(buf, "\nto a %s-irq-unsafe lock:\n", irqclass);
+	print_lock_name(buf, forwards_entry->class);
+	bpr_warn(buf, "\n... which became %s-irq-unsafe at:\n", irqclass);
+	bpr_warn(buf, "...");
 
 	print_stack_trace(forwards_entry->class->usage_traces + bit2, 1);
 
-	pr_warn("\nother info that might help us debug this:\n\n");
-	print_irq_lock_scenario(backwards_entry, forwards_entry,
+	bpr_warn(buf, "\nother info that might help us debug this:\n\n");
+	print_irq_lock_scenario(buf, backwards_entry, forwards_entry,
 				hlock_class(prev), hlock_class(next));
 
-	lockdep_print_held_locks(curr);
+	lockdep_print_held_locks(buf, curr);
 
-	pr_warn("\nthe dependencies between %s-irq-safe lock and the holding lock:\n", irqclass);
+	bpr_warn(buf, "\nthe dependencies between %s-irq-safe lock and the holding lock:\n", irqclass);
 	if (!save_trace(&prev_root->trace))
-		return 0;
-	print_shortest_lock_dependencies(backwards_entry, prev_root);
+		goto done;
+	print_shortest_lock_dependencies(buf, backwards_entry, prev_root);
 
-	pr_warn("\nthe dependencies between the lock to be acquired");
-	pr_warn(" and %s-irq-unsafe lock:\n", irqclass);
+	bpr_warn(buf, "\nthe dependencies between the lock to be acquired");
+	bpr_warn(buf, " and %s-irq-unsafe lock:\n", irqclass);
 	if (!save_trace(&next_root->trace))
-		return 0;
-	print_shortest_lock_dependencies(forwards_entry, next_root);
+		goto done;
+	print_shortest_lock_dependencies(buf, forwards_entry, next_root);
 
-	pr_warn("\nstack backtrace:\n");
+	bpr_warn(buf, "\nstack backtrace:\n");
 	dump_stack();
-
+ done:
+	put_printk_buffer(buf);
 	return 0;
 }
 
@@ -1716,48 +1725,52 @@ static inline void inc_chains(void)
 #endif
 
 static void
-print_deadlock_scenario(struct held_lock *nxt,
+print_deadlock_scenario(struct printk_buffer *buf, struct held_lock *nxt,
 			     struct held_lock *prv)
 {
 	struct lock_class *next = hlock_class(nxt);
 	struct lock_class *prev = hlock_class(prv);
 
-	printk(" Possible unsafe locking scenario:\n\n");
-	printk("       CPU0\n");
-	printk("       ----\n");
-	printk("  lock(");
-	__print_lock_name(prev);
-	printk(KERN_CONT ");\n");
-	printk("  lock(");
-	__print_lock_name(next);
-	printk(KERN_CONT ");\n");
-	printk("\n *** DEADLOCK ***\n\n");
-	printk(" May be due to missing lock nesting notation\n\n");
+	bprintk(buf, " Possible unsafe locking scenario:\n\n");
+	bprintk(buf, "       CPU0\n");
+	bprintk(buf, "       ----\n");
+	bprintk(buf, "  lock(");
+	__print_lock_name(buf, prev);
+	bprintk(buf, KERN_CONT ");\n");
+	bprintk(buf, "  lock(");
+	__print_lock_name(buf, next);
+	bprintk(buf, KERN_CONT ");\n");
+	bprintk(buf, "\n *** DEADLOCK ***\n\n");
+	bprintk(buf, " May be due to missing lock nesting notation\n\n");
 }
 
 static int
 print_deadlock_bug(struct task_struct *curr, struct held_lock *prev,
 		   struct held_lock *next)
 {
+	struct printk_buffer *buf;
+
 	if (!debug_locks_off_graph_unlock() || debug_locks_silent)
 		return 0;
 
-	pr_warn("\n");
-	pr_warn("============================================\n");
-	pr_warn("WARNING: possible recursive locking detected\n");
-	print_kernel_ident();
-	pr_warn("--------------------------------------------\n");
-	pr_warn("%s/%d is trying to acquire lock:\n",
+	buf = get_printk_buffer();
+	bpr_warn(buf, "\n");
+	bpr_warn(buf, "============================================\n");
+	bpr_warn(buf, "WARNING: possible recursive locking detected\n");
+	print_kernel_ident(buf);
+	bpr_warn(buf, "--------------------------------------------\n");
+	bpr_warn(buf, "%s/%d is trying to acquire lock:\n",
 		curr->comm, task_pid_nr(curr));
-	print_lock(next);
-	pr_warn("\nbut task is already holding lock:\n");
-	print_lock(prev);
+	print_lock(buf, next);
+	bpr_warn(buf, "\nbut task is already holding lock:\n");
+	print_lock(buf, prev);
 
-	pr_warn("\nother info that might help us debug this:\n");
-	print_deadlock_scenario(next, prev);
-	lockdep_print_held_locks(curr);
+	bpr_warn(buf, "\nother info that might help us debug this:\n");
+	print_deadlock_scenario(buf, next, prev);
+	lockdep_print_held_locks(buf, curr);
 
-	pr_warn("\nstack backtrace:\n");
+	bpr_warn(buf, "\nstack backtrace:\n");
+	put_printk_buffer(buf);
 	dump_stack();
 
 	return 0;
@@ -2048,49 +2061,49 @@ static inline int get_first_held_lock(struct task_struct *curr,
 /*
  * Returns the next chain_key iteration
  */
-static u64 print_chain_key_iteration(int class_idx, u64 chain_key)
+static u64 print_chain_key_iteration(struct printk_buffer *buf, int class_idx, u64 chain_key)
 {
 	u64 new_chain_key = iterate_chain_key(chain_key, class_idx);
 
-	printk(" class_idx:%d -> chain_key:%016Lx",
+	bprintk(buf, " class_idx:%d -> chain_key:%016Lx",
 		class_idx,
 		(unsigned long long)new_chain_key);
 	return new_chain_key;
 }
 
 static void
-print_chain_keys_held_locks(struct task_struct *curr, struct held_lock *hlock_next)
+print_chain_keys_held_locks(struct printk_buffer *buf, struct task_struct *curr, struct held_lock *hlock_next)
 {
 	struct held_lock *hlock;
 	u64 chain_key = 0;
 	int depth = curr->lockdep_depth;
 	int i;
 
-	printk("depth: %u\n", depth + 1);
+	bprintk(buf, "depth: %u\n", depth + 1);
 	for (i = get_first_held_lock(curr, hlock_next); i < depth; i++) {
 		hlock = curr->held_locks + i;
-		chain_key = print_chain_key_iteration(hlock->class_idx, chain_key);
+		chain_key = print_chain_key_iteration(buf, hlock->class_idx, chain_key);
 
-		print_lock(hlock);
+		print_lock(buf, hlock);
 	}
 
-	print_chain_key_iteration(hlock_next->class_idx, chain_key);
-	print_lock(hlock_next);
+	print_chain_key_iteration(buf, hlock_next->class_idx, chain_key);
+	print_lock(buf, hlock_next);
 }
 
-static void print_chain_keys_chain(struct lock_chain *chain)
+static void print_chain_keys_chain(struct printk_buffer *buf, struct lock_chain *chain)
 {
 	int i;
 	u64 chain_key = 0;
 	int class_id;
 
-	printk("depth: %u\n", chain->depth);
+	bprintk(buf, "depth: %u\n", chain->depth);
 	for (i = 0; i < chain->depth; i++) {
 		class_id = chain_hlocks[chain->base + i];
-		chain_key = print_chain_key_iteration(class_id + 1, chain_key);
+		chain_key = print_chain_key_iteration(buf, class_id + 1, chain_key);
 
-		print_lock_name(lock_classes + class_id);
-		printk("\n");
+		print_lock_name(buf, lock_classes + class_id);
+		bprintk(buf, "\n");
 	}
 }
 
@@ -2098,21 +2111,24 @@ static void print_collision(struct task_struct *curr,
 			struct held_lock *hlock_next,
 			struct lock_chain *chain)
 {
-	pr_warn("\n");
-	pr_warn("============================\n");
-	pr_warn("WARNING: chain_key collision\n");
-	print_kernel_ident();
-	pr_warn("----------------------------\n");
-	pr_warn("%s/%d: ", current->comm, task_pid_nr(current));
-	pr_warn("Hash chain already cached but the contents don't match!\n");
+	struct printk_buffer *buf = get_printk_buffer();
 
-	pr_warn("Held locks:");
-	print_chain_keys_held_locks(curr, hlock_next);
+	bpr_warn(buf, "\n");
+	bpr_warn(buf, "============================\n");
+	bpr_warn(buf, "WARNING: chain_key collision\n");
+	print_kernel_ident(buf);
+	bpr_warn(buf, "----------------------------\n");
+	bpr_warn(buf, "%s/%d: ", current->comm, task_pid_nr(current));
+	bpr_warn(buf, "Hash chain already cached but the contents don't match!\n");
 
-	pr_warn("Locks in cached chain:");
-	print_chain_keys_chain(chain);
+	bpr_warn(buf, "Held locks:");
+	print_chain_keys_held_locks(buf, curr, hlock_next);
 
-	pr_warn("\nstack backtrace:\n");
+	bpr_warn(buf, "Locks in cached chain:");
+	print_chain_keys_chain(buf, chain);
+
+	bpr_warn(buf, "\nstack backtrace:\n");
+	put_printk_buffer(buf);
 	dump_stack();
 }
 #endif
@@ -2418,57 +2434,61 @@ static void check_chain_key(struct task_struct *curr)
 }
 
 static void
-print_usage_bug_scenario(struct held_lock *lock)
+print_usage_bug_scenario(struct printk_buffer *buf, struct held_lock *lock)
 {
 	struct lock_class *class = hlock_class(lock);
 
-	printk(" Possible unsafe locking scenario:\n\n");
-	printk("       CPU0\n");
-	printk("       ----\n");
-	printk("  lock(");
-	__print_lock_name(class);
-	printk(KERN_CONT ");\n");
-	printk("  <Interrupt>\n");
-	printk("    lock(");
-	__print_lock_name(class);
-	printk(KERN_CONT ");\n");
-	printk("\n *** DEADLOCK ***\n\n");
+	bprintk(buf, " Possible unsafe locking scenario:\n\n");
+	bprintk(buf, "       CPU0\n");
+	bprintk(buf, "       ----\n");
+	bprintk(buf, "  lock(");
+	__print_lock_name(buf, class);
+	bprintk(buf, KERN_CONT ");\n");
+	bprintk(buf, "  <Interrupt>\n");
+	bprintk(buf, "    lock(");
+	__print_lock_name(buf, class);
+	bprintk(buf, KERN_CONT ");\n");
+	bprintk(buf, "\n *** DEADLOCK ***\n\n");
 }
 
 static int
 print_usage_bug(struct task_struct *curr, struct held_lock *this,
 		enum lock_usage_bit prev_bit, enum lock_usage_bit new_bit)
 {
+	struct printk_buffer *buf;
+
 	if (!debug_locks_off_graph_unlock() || debug_locks_silent)
 		return 0;
 
-	pr_warn("\n");
-	pr_warn("================================\n");
-	pr_warn("WARNING: inconsistent lock state\n");
-	print_kernel_ident();
-	pr_warn("--------------------------------\n");
+	buf = get_printk_buffer();
+	bpr_warn(buf, "\n");
+	bpr_warn(buf, "================================\n");
+	bpr_warn(buf, "WARNING: inconsistent lock state\n");
+	print_kernel_ident(buf);
+	bpr_warn(buf, "--------------------------------\n");
 
-	pr_warn("inconsistent {%s} -> {%s} usage.\n",
+	bpr_warn(buf, "inconsistent {%s} -> {%s} usage.\n",
 		usage_str[prev_bit], usage_str[new_bit]);
 
-	pr_warn("%s/%d [HC%u[%lu]:SC%u[%lu]:HE%u:SE%u] takes:\n",
+	bpr_warn(buf, "%s/%d [HC%u[%lu]:SC%u[%lu]:HE%u:SE%u] takes:\n",
 		curr->comm, task_pid_nr(curr),
 		trace_hardirq_context(curr), hardirq_count() >> HARDIRQ_SHIFT,
 		trace_softirq_context(curr), softirq_count() >> SOFTIRQ_SHIFT,
 		trace_hardirqs_enabled(curr),
 		trace_softirqs_enabled(curr));
-	print_lock(this);
+	print_lock(buf, this);
 
-	pr_warn("{%s} state was registered at:\n", usage_str[prev_bit]);
+	bpr_warn(buf, "{%s} state was registered at:\n", usage_str[prev_bit]);
 	print_stack_trace(hlock_class(this)->usage_traces + prev_bit, 1);
 
 	print_irqtrace_events(curr);
-	pr_warn("\nother info that might help us debug this:\n");
-	print_usage_bug_scenario(this);
+	bpr_warn(buf, "\nother info that might help us debug this:\n");
+	print_usage_bug_scenario(buf, this);
 
-	lockdep_print_held_locks(curr);
+	lockdep_print_held_locks(buf, curr);
 
-	pr_warn("\nstack backtrace:\n");
+	bpr_warn(buf, "\nstack backtrace:\n");
+	put_printk_buffer(buf);
 	dump_stack();
 
 	return 0;
@@ -2500,6 +2520,7 @@ static int mark_lock(struct task_struct *curr, struct held_lock *this,
 			struct held_lock *this, int forwards,
 			const char *irqclass)
 {
+	struct printk_buffer *buf;
 	struct lock_list *entry = other;
 	struct lock_list *middle = NULL;
 	int depth;
@@ -2507,28 +2528,29 @@ static int mark_lock(struct task_struct *curr, struct held_lock *this,
 	if (!debug_locks_off_graph_unlock() || debug_locks_silent)
 		return 0;
 
-	pr_warn("\n");
-	pr_warn("========================================================\n");
-	pr_warn("WARNING: possible irq lock inversion dependency detected\n");
-	print_kernel_ident();
-	pr_warn("--------------------------------------------------------\n");
-	pr_warn("%s/%d just changed the state of lock:\n",
+	buf = get_printk_buffer();
+	bpr_warn(buf, "\n");
+	bpr_warn(buf, "========================================================\n");
+	bpr_warn(buf, "WARNING: possible irq lock inversion dependency detected\n");
+	print_kernel_ident(buf);
+	bpr_warn(buf, "--------------------------------------------------------\n");
+	bpr_warn(buf, "%s/%d just changed the state of lock:\n",
 		curr->comm, task_pid_nr(curr));
-	print_lock(this);
+	print_lock(buf, this);
 	if (forwards)
-		pr_warn("but this lock took another, %s-unsafe lock in the past:\n", irqclass);
+		bpr_warn(buf, "but this lock took another, %s-unsafe lock in the past:\n", irqclass);
 	else
-		pr_warn("but this lock was taken by another, %s-safe lock in the past:\n", irqclass);
-	print_lock_name(other->class);
-	pr_warn("\n\nand interrupts could create inverse lock ordering between them.\n\n");
+		bpr_warn(buf, "but this lock was taken by another, %s-safe lock in the past:\n", irqclass);
+	print_lock_name(buf, other->class);
+	bpr_warn(buf, "\n\nand interrupts could create inverse lock ordering between them.\n\n");
 
-	pr_warn("\nother info that might help us debug this:\n");
+	bpr_warn(buf, "\nother info that might help us debug this:\n");
 
 	/* Find a middle lock (if one exists) */
 	depth = get_lock_depth(other);
 	do {
 		if (depth == 0 && (entry != root)) {
-			pr_warn("lockdep:%s bad path found in chain graph\n", __func__);
+			bpr_warn(buf, "lockdep:%s bad path found in chain graph\n", __func__);
 			break;
 		}
 		middle = entry;
@@ -2536,20 +2558,21 @@ static int mark_lock(struct task_struct *curr, struct held_lock *this,
 		depth--;
 	} while (entry && entry != root && (depth >= 0));
 	if (forwards)
-		print_irq_lock_scenario(root, other,
+		print_irq_lock_scenario(buf, root, other,
 			middle ? middle->class : root->class, other->class);
 	else
-		print_irq_lock_scenario(other, root,
+		print_irq_lock_scenario(buf, other, root,
 			middle ? middle->class : other->class, root->class);
 
-	lockdep_print_held_locks(curr);
+	lockdep_print_held_locks(buf, curr);
 
-	pr_warn("\nthe shortest dependencies between 2nd lock and 1st lock:\n");
+	bpr_warn(buf, "\nthe shortest dependencies between 2nd lock and 1st lock:\n");
 	if (!save_trace(&root->trace))
 		return 0;
-	print_shortest_lock_dependencies(other, root);
+	print_shortest_lock_dependencies(buf, other, root);
 
-	pr_warn("\nstack backtrace:\n");
+	bpr_warn(buf, "\nstack backtrace:\n");
+	put_printk_buffer(buf);
 	dump_stack();
 
 	return 0;
@@ -3076,8 +3099,11 @@ static int mark_lock(struct task_struct *curr, struct held_lock *this,
 	 * We must printk outside of the graph_lock:
 	 */
 	if (ret == 2) {
-		printk("\nmarked lock as {%s}:\n", usage_str[new_bit]);
-		print_lock(this);
+		struct printk_buffer *buf = get_printk_buffer();
+
+		bprintk(buf, "\nmarked lock as {%s}:\n", usage_str[new_bit]);
+		print_lock(buf, this);
+		put_printk_buffer(buf);
 		print_irqtrace_events(curr);
 		dump_stack();
 	}
@@ -3160,30 +3186,34 @@ void lockdep_init_map(struct lockdep_map *lock, const char *name,
 				struct held_lock *hlock,
 				unsigned long ip)
 {
+	struct printk_buffer *buf;
+
 	if (!debug_locks_off())
 		return 0;
 	if (debug_locks_silent)
 		return 0;
 
-	pr_warn("\n");
-	pr_warn("==================================\n");
-	pr_warn("WARNING: Nested lock was not taken\n");
-	print_kernel_ident();
-	pr_warn("----------------------------------\n");
+	buf = get_printk_buffer();
+	bpr_warn(buf, "\n");
+	bpr_warn(buf, "==================================\n");
+	bpr_warn(buf, "WARNING: Nested lock was not taken\n");
+	print_kernel_ident(buf);
+	bpr_warn(buf, "----------------------------------\n");
 
-	pr_warn("%s/%d is trying to lock:\n", curr->comm, task_pid_nr(curr));
-	print_lock(hlock);
+	bpr_warn(buf, "%s/%d is trying to lock:\n", curr->comm, task_pid_nr(curr));
+	print_lock(buf, hlock);
 
-	pr_warn("\nbut this task is not holding:\n");
-	pr_warn("%s\n", hlock->nest_lock->name);
+	bpr_warn(buf, "\nbut this task is not holding:\n");
+	bpr_warn(buf, "%s\n", hlock->nest_lock->name);
 
-	pr_warn("\nstack backtrace:\n");
+	bpr_warn(buf, "\nstack backtrace:\n");
 	dump_stack();
 
-	pr_warn("\nother info that might help us debug this:\n");
-	lockdep_print_held_locks(curr);
+	bpr_warn(buf, "\nother info that might help us debug this:\n");
+	lockdep_print_held_locks(buf, curr);
 
-	pr_warn("\nstack backtrace:\n");
+	bpr_warn(buf, "\nstack backtrace:\n");
+	put_printk_buffer(buf);
 	dump_stack();
 
 	return 0;
@@ -3232,10 +3262,13 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 	debug_class_ops_inc(class);
 
 	if (very_verbose(class)) {
-		printk("\nacquire class [%px] %s", class->key, class->name);
+		struct printk_buffer *buf = get_printk_buffer();
+
+		bprintk(buf, "\nacquire class [%px] %s", class->key, class->name);
 		if (class->name_version > 1)
-			printk(KERN_CONT "#%d", class->name_version);
-		printk(KERN_CONT "\n");
+			bprintk(buf, KERN_CONT "#%d", class->name_version);
+		bprintk(buf, KERN_CONT "\n");
+		put_printk_buffer(buf);
 		dump_stack();
 	}
 
@@ -3349,12 +3382,15 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 		return 0;
 #endif
 	if (unlikely(curr->lockdep_depth >= MAX_LOCK_DEPTH)) {
+		struct printk_buffer *buf = get_printk_buffer();
+
 		debug_locks_off();
 		print_lockdep_off("BUG: MAX_LOCK_DEPTH too low!");
-		printk(KERN_DEBUG "depth: %i  max: %lu!\n",
+		bprintk(buf, KERN_DEBUG "depth: %i  max: %lu!\n",
 		       curr->lockdep_depth, MAX_LOCK_DEPTH);
 
-		lockdep_print_held_locks(current);
+		lockdep_print_held_locks(buf, current);
+		put_printk_buffer(buf);
 		debug_show_all_locks();
 		dump_stack();
 
@@ -3371,26 +3407,30 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 print_unlock_imbalance_bug(struct task_struct *curr, struct lockdep_map *lock,
 			   unsigned long ip)
 {
+	struct printk_buffer *buf;
+
 	if (!debug_locks_off())
 		return 0;
 	if (debug_locks_silent)
 		return 0;
 
-	pr_warn("\n");
-	pr_warn("=====================================\n");
-	pr_warn("WARNING: bad unlock balance detected!\n");
-	print_kernel_ident();
-	pr_warn("-------------------------------------\n");
-	pr_warn("%s/%d is trying to release lock (",
+	buf = get_printk_buffer();
+	bpr_warn(buf, "\n");
+	bpr_warn(buf, "=====================================\n");
+	bpr_warn(buf, "WARNING: bad unlock balance detected!\n");
+	print_kernel_ident(buf);
+	bpr_warn(buf, "-------------------------------------\n");
+	bpr_warn(buf, "%s/%d is trying to release lock (",
 		curr->comm, task_pid_nr(curr));
-	print_lockdep_cache(lock);
-	pr_cont(") at:\n");
+	print_lockdep_cache(buf, lock);
+	bpr_cont(buf, ") at:\n");
 	print_ip_sym(ip);
-	pr_warn("but there are no more locks to release!\n");
-	pr_warn("\nother info that might help us debug this:\n");
-	lockdep_print_held_locks(curr);
+	bpr_warn(buf, "but there are no more locks to release!\n");
+	bpr_warn(buf, "\nother info that might help us debug this:\n");
+	lockdep_print_held_locks(buf, curr);
 
-	pr_warn("\nstack backtrace:\n");
+	bpr_warn(buf, "\nstack backtrace:\n");
+	put_printk_buffer(buf);
 	dump_stack();
 
 	return 0;
@@ -3946,26 +3986,30 @@ void lock_unpin_lock(struct lockdep_map *lock, struct pin_cookie cookie)
 print_lock_contention_bug(struct task_struct *curr, struct lockdep_map *lock,
 			   unsigned long ip)
 {
+	struct printk_buffer *buf;
+
 	if (!debug_locks_off())
 		return 0;
 	if (debug_locks_silent)
 		return 0;
 
-	pr_warn("\n");
-	pr_warn("=================================\n");
-	pr_warn("WARNING: bad contention detected!\n");
-	print_kernel_ident();
-	pr_warn("---------------------------------\n");
-	pr_warn("%s/%d is trying to contend lock (",
+	buf = get_printk_buffer();
+	bpr_warn(buf, "\n");
+	bpr_warn(buf, "=================================\n");
+	bpr_warn(buf, "WARNING: bad contention detected!\n");
+	print_kernel_ident(buf);
+	bpr_warn(buf, "---------------------------------\n");
+	bpr_warn(buf, "%s/%d is trying to contend lock (",
 		curr->comm, task_pid_nr(curr));
-	print_lockdep_cache(lock);
-	pr_cont(") at:\n");
+	print_lockdep_cache(buf, lock);
+	bpr_cont(buf, ") at:\n");
 	print_ip_sym(ip);
-	pr_warn("but there are no locks held!\n");
-	pr_warn("\nother info that might help us debug this:\n");
-	lockdep_print_held_locks(curr);
+	bpr_warn(buf, "but there are no locks held!\n");
+	bpr_warn(buf, "\nother info that might help us debug this:\n");
+	lockdep_print_held_locks(buf, curr);
 
-	pr_warn("\nstack backtrace:\n");
+	bpr_warn(buf, "\nstack backtrace:\n");
+	put_printk_buffer(buf);
 	dump_stack();
 
 	return 0;
@@ -4288,22 +4332,26 @@ void __init lockdep_init(void)
 print_freed_lock_bug(struct task_struct *curr, const void *mem_from,
 		     const void *mem_to, struct held_lock *hlock)
 {
+	struct printk_buffer *buf;
+
 	if (!debug_locks_off())
 		return;
 	if (debug_locks_silent)
 		return;
 
-	pr_warn("\n");
-	pr_warn("=========================\n");
-	pr_warn("WARNING: held lock freed!\n");
-	print_kernel_ident();
-	pr_warn("-------------------------\n");
-	pr_warn("%s/%d is freeing memory %px-%px, with a lock still held there!\n",
+	buf = get_printk_buffer();
+	bpr_warn(buf, "\n");
+	bpr_warn(buf, "=========================\n");
+	bpr_warn(buf, "WARNING: held lock freed!\n");
+	print_kernel_ident(buf);
+	bpr_warn(buf, "-------------------------\n");
+	bpr_warn(buf, "%s/%d is freeing memory %px-%px, with a lock still held there!\n",
 		curr->comm, task_pid_nr(curr), mem_from, mem_to-1);
-	print_lock(hlock);
-	lockdep_print_held_locks(curr);
+	print_lock(buf, hlock);
+	lockdep_print_held_locks(buf, curr);
 
-	pr_warn("\nstack backtrace:\n");
+	bpr_warn(buf, "\nstack backtrace:\n");
+	put_printk_buffer(buf);
 	dump_stack();
 }
 
@@ -4346,19 +4394,23 @@ void debug_check_no_locks_freed(const void *mem_from, unsigned long mem_len)
 
 static void print_held_locks_bug(void)
 {
+	struct printk_buffer *buf;
+
 	if (!debug_locks_off())
 		return;
 	if (debug_locks_silent)
 		return;
 
-	pr_warn("\n");
-	pr_warn("====================================\n");
-	pr_warn("WARNING: %s/%d still has locks held!\n",
+	buf = get_printk_buffer();
+	bpr_warn(buf, "\n");
+	bpr_warn(buf, "====================================\n");
+	bpr_warn(buf, "WARNING: %s/%d still has locks held!\n",
 	       current->comm, task_pid_nr(current));
-	print_kernel_ident();
-	pr_warn("------------------------------------\n");
-	lockdep_print_held_locks(current);
-	pr_warn("\nstack backtrace:\n");
+	print_kernel_ident(buf);
+	bpr_warn(buf, "------------------------------------\n");
+	lockdep_print_held_locks(buf, current);
+	bpr_warn(buf, "\nstack backtrace:\n");
+	put_printk_buffer(buf);
 	dump_stack();
 }
 
@@ -4372,26 +4424,29 @@ void debug_check_no_locks_held(void)
 #ifdef __KERNEL__
 void debug_show_all_locks(void)
 {
+	struct printk_buffer *buf;
 	struct task_struct *g, *p;
 
 	if (unlikely(!debug_locks)) {
 		pr_warn("INFO: lockdep is turned off.\n");
 		return;
 	}
-	pr_warn("\nShowing all locks held in the system:\n");
+	buf = get_printk_buffer();
+	bpr_warn(buf, "\nShowing all locks held in the system:\n");
 
 	rcu_read_lock();
 	for_each_process_thread(g, p) {
 		if (!p->lockdep_depth)
 			continue;
-		lockdep_print_held_locks(p);
+		lockdep_print_held_locks(buf, p);
 		touch_nmi_watchdog();
 		touch_all_softlockup_watchdogs();
 	}
 	rcu_read_unlock();
 
-	pr_warn("\n");
-	pr_warn("=============================================\n\n");
+	bpr_warn(buf, "\n");
+	bpr_warn(buf, "=============================================\n\n");
+	put_printk_buffer(buf);
 }
 EXPORT_SYMBOL_GPL(debug_show_all_locks);
 #endif
@@ -4402,11 +4457,15 @@ void debug_show_all_locks(void)
  */
 void debug_show_held_locks(struct task_struct *task)
 {
+	struct printk_buffer *buf;
+
 	if (unlikely(!debug_locks)) {
 		printk("INFO: lockdep is turned off.\n");
 		return;
 	}
-	lockdep_print_held_locks(task);
+	buf = get_printk_buffer();
+	lockdep_print_held_locks(buf, task);
+	put_printk_buffer(buf);
 }
 EXPORT_SYMBOL_GPL(debug_show_held_locks);
 
@@ -4415,16 +4474,20 @@ asmlinkage __visible void lockdep_sys_exit(void)
 	struct task_struct *curr = current;
 
 	if (unlikely(curr->lockdep_depth)) {
+		struct printk_buffer *buf;
+
 		if (!debug_locks_off())
 			return;
-		pr_warn("\n");
-		pr_warn("================================================\n");
-		pr_warn("WARNING: lock held when returning to user space!\n");
-		print_kernel_ident();
-		pr_warn("------------------------------------------------\n");
-		pr_warn("%s/%d is leaving the kernel with locks still held!\n",
+		buf = get_printk_buffer();
+		bpr_warn(buf, "\n");
+		bpr_warn(buf, "================================================\n");
+		bpr_warn(buf, "WARNING: lock held when returning to user space!\n");
+		print_kernel_ident(buf);
+		bpr_warn(buf, "------------------------------------------------\n");
+		bpr_warn(buf, "%s/%d is leaving the kernel with locks still held!\n",
 				curr->comm, curr->pid);
-		lockdep_print_held_locks(curr);
+		lockdep_print_held_locks(buf, curr);
+		put_printk_buffer(buf);
 	}
 
 	/*
@@ -4436,17 +4499,18 @@ asmlinkage __visible void lockdep_sys_exit(void)
 
 void lockdep_rcu_suspicious(const char *file, const int line, const char *s)
 {
+	struct printk_buffer *buf = get_printk_buffer();
 	struct task_struct *curr = current;
 
 	/* Note: the following can be executed concurrently, so be careful. */
-	pr_warn("\n");
-	pr_warn("=============================\n");
-	pr_warn("WARNING: suspicious RCU usage\n");
-	print_kernel_ident();
-	pr_warn("-----------------------------\n");
-	pr_warn("%s:%d %s!\n", file, line, s);
-	pr_warn("\nother info that might help us debug this:\n\n");
-	pr_warn("\n%srcu_scheduler_active = %d, debug_locks = %d\n",
+	bpr_warn(buf, "\n");
+	bpr_warn(buf, "=============================\n");
+	bpr_warn(buf, "WARNING: suspicious RCU usage\n");
+	print_kernel_ident(buf);
+	bpr_warn(buf, "-----------------------------\n");
+	bpr_warn(buf, "%s:%d %s!\n", file, line, s);
+	bpr_warn(buf, "\nother info that might help us debug this:\n\n");
+	bpr_warn(buf, "\n%srcu_scheduler_active = %d, debug_locks = %d\n",
 	       !rcu_lockdep_current_cpu_online()
 			? "RCU used illegally from offline CPU!\n"
 			: !rcu_is_watching()
@@ -4473,10 +4537,11 @@ void lockdep_rcu_suspicious(const char *file, const int line, const char *s)
 	 * rcu_read_lock_bh() and so on from extended quiescent states.
 	 */
 	if (!rcu_is_watching())
-		pr_warn("RCU used illegally from extended quiescent state!\n");
+		bpr_warn(buf, "RCU used illegally from extended quiescent state!\n");
 
-	lockdep_print_held_locks(curr);
-	pr_warn("\nstack backtrace:\n");
+	lockdep_print_held_locks(buf, curr);
+	bpr_warn(buf, "\nstack backtrace:\n");
+	put_printk_buffer(buf);
 	dump_stack();
 }
 EXPORT_SYMBOL_GPL(lockdep_rcu_suspicious);
-- 
1.8.3.1
