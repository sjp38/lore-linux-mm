Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE3586B064C
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 15:35:31 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id f81-v6so41439649qkb.14
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 12:35:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q8-v6si3779608qtl.393.2018.11.08.12.35.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 12:35:30 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH 02/12] locking/lockdep: Add a new terminal lock type
Date: Thu,  8 Nov 2018 15:34:18 -0500
Message-Id: <1541709268-3766-3-git-send-email-longman@redhat.com>
In-Reply-To: <1541709268-3766-1-git-send-email-longman@redhat.com>
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>

A terminal lock is a lock where further locking or unlocking on another
lock is not allowed. IOW, no forward dependency is permitted.

With such a restriction in place, we don't really need to do a full
validation of the lock chain involving a terminal lock.  Instead,
we just check if there is any further locking or unlocking on another
lock when a terminal lock is being held.

Only spinlocks which are acquired by the _irq or _irqsave variants
or in IRQ disabled context should be classified as terminal locks.

By adding this new lock type, we can save entries in lock_chains[],
chain_hlocks[], list_entries[] and stack_trace[]. By marking suitable
locks as terminal, we reduce the chance of overflowing those tables
allowing them to focus on locks that can have both forward and backward
dependencies.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 include/linux/lockdep.h            | 13 ++++++++++-
 kernel/locking/lockdep.c           | 44 ++++++++++++++++++++++++++++++++++----
 kernel/locking/lockdep_internals.h |  5 +++++
 kernel/locking/lockdep_proc.c      | 11 ++++++++--
 4 files changed, 66 insertions(+), 7 deletions(-)

diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index 18f9607..c5ff8c5 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -143,9 +143,16 @@ struct lock_class_stats {
 
 /*
  * Lockdep class flags
+ *
  * 1) LOCKDEP_FLAG_NOVALIDATE: No full validation, just simple checks.
+ * 2) LOCKDEP_FLAG_TERMINAL: This is a terminal lock where lock/unlock on
+ *    another lock within its critical section is not allowed.
  */
 #define LOCKDEP_FLAG_NOVALIDATE 	(1 << 0)
+#define LOCKDEP_FLAG_TERMINAL		(1 << 1)
+
+#define LOCKDEP_NOCHECK_FLAGS		(LOCKDEP_FLAG_NOVALIDATE |\
+					 LOCKDEP_FLAG_TERMINAL)
 
 /*
  * Map the lock object (the lock instance) to the lock-class object.
@@ -263,6 +270,7 @@ struct held_lock {
 	unsigned int hardirqs_off:1;
 	unsigned int references:12;					/* 32 bits */
 	unsigned int pin_count;
+	unsigned int flags;
 };
 
 /*
@@ -304,6 +312,8 @@ extern void lockdep_init_map(struct lockdep_map *lock, const char *name,
 
 #define lockdep_set_novalidate_class(lock) \
 	do { (lock)->dep_map.flags |= LOCKDEP_FLAG_NOVALIDATE; } while (0)
+#define lockdep_set_terminal_class(lock) \
+	do { (lock)->dep_map.flags |= LOCKDEP_FLAG_TERMINAL; } while (0)
 
 /*
  * Compare locking classes
@@ -419,7 +429,8 @@ static inline void lockdep_on(void)
 		do { (void)(key); } while (0)
 #define lockdep_set_subclass(lock, sub)		do { } while (0)
 
-#define lockdep_set_novalidate_class(lock) do { } while (0)
+#define lockdep_set_novalidate_class(lock)	do { } while (0)
+#define lockdep_set_terminal_class(lock)	do { } while (0)
 
 /*
  * We don't define lockdep_match_class() and lockdep_match_key() for !LOCKDEP
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 493b567..02631a0 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -3020,6 +3020,16 @@ static inline int separate_irq_context(struct task_struct *curr,
 
 #endif /* defined(CONFIG_TRACE_IRQFLAGS) && defined(CONFIG_PROVE_LOCKING) */
 
+static int lock_is_terminal(struct lockdep_map *lock)
+{
+	return flags_is_terminal(lock->flags);
+}
+
+static int hlock_is_terminal(struct held_lock *hlock)
+{
+	return flags_is_terminal(hlock->flags);
+}
+
 /*
  * Mark a lock with a usage bit, and validate the state transition:
  */
@@ -3047,7 +3057,11 @@ static int mark_lock(struct task_struct *curr, struct held_lock *this,
 
 	hlock_class(this)->usage_mask |= new_mask;
 
-	if (!save_trace(hlock_class(this)->usage_traces + new_bit))
+	/*
+	 * We don't need to save the stack trace for terminal locks.
+	 */
+	if (!hlock_is_terminal(this) &&
+	    !save_trace(hlock_class(this)->usage_traces + new_bit))
 		return 0;
 
 	switch (new_bit) {
@@ -3215,9 +3229,6 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 	if (unlikely(!debug_locks))
 		return 0;
 
-	if (!prove_locking || (lock->flags & LOCKDEP_FLAG_NOVALIDATE))
-		check = 0;
-
 	if (subclass < NR_LOCKDEP_CACHING_CLASSES)
 		class = lock->class_cache[subclass];
 	/*
@@ -3229,6 +3240,9 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 			return 0;
 	}
 
+	if (!prove_locking || (class->flags & LOCKDEP_NOCHECK_FLAGS))
+		check = 0;
+
 	debug_class_ops_inc(class);
 
 	if (very_verbose(class)) {
@@ -3255,6 +3269,13 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 
 	if (depth) {
 		hlock = curr->held_locks + depth - 1;
+
+		/*
+		 * Warn if the previous lock is a terminal lock.
+		 */
+		if (DEBUG_LOCKS_WARN_ON(hlock_is_terminal(hlock)))
+			return 0;
+
 		if (hlock->class_idx == class_idx && nest_lock) {
 			if (hlock->references) {
 				/*
@@ -3294,6 +3315,7 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 	hlock->holdtime_stamp = lockstat_clock();
 #endif
 	hlock->pin_count = pin_count;
+	hlock->flags = class->flags;
 
 	if (check && !mark_irqflags(curr, hlock))
 		return 0;
@@ -3636,6 +3658,14 @@ static int __lock_downgrade(struct lockdep_map *lock, unsigned long ip)
 	if (i == depth-1)
 		return 1;
 
+	/*
+	 * Unlock of an outer lock is not allowed while holding a terminal
+	 * lock.
+	 */
+	hlock = curr->held_locks + depth - 1;
+	if (DEBUG_LOCKS_WARN_ON(hlock_is_terminal(hlock)))
+		return 0;
+
 	if (reacquire_held_locks(curr, depth, i + 1))
 		return 0;
 
@@ -4093,6 +4123,12 @@ void lock_acquired(struct lockdep_map *lock, unsigned long ip)
 		return;
 
 	raw_local_irq_save(flags);
+
+	/*
+	 * A terminal lock should only be used with IRQ disabled.
+	 */
+	DEBUG_LOCKS_WARN_ON(lock_is_terminal(lock) &&
+			    !irqs_disabled_flags(flags));
 	check_flags(flags);
 	current->lockdep_recursion = 1;
 	__lock_acquired(lock, ip);
diff --git a/kernel/locking/lockdep_internals.h b/kernel/locking/lockdep_internals.h
index 88c847a..271fba8 100644
--- a/kernel/locking/lockdep_internals.h
+++ b/kernel/locking/lockdep_internals.h
@@ -212,3 +212,8 @@ static inline unsigned long debug_class_ops_read(struct lock_class *class)
 # define debug_atomic_read(ptr)		0
 # define debug_class_ops_inc(ptr)	do { } while (0)
 #endif
+
+static inline unsigned int flags_is_terminal(unsigned int flags)
+{
+	return flags & LOCKDEP_FLAG_TERMINAL;
+}
diff --git a/kernel/locking/lockdep_proc.c b/kernel/locking/lockdep_proc.c
index 3d31f9b..37fbd41 100644
--- a/kernel/locking/lockdep_proc.c
+++ b/kernel/locking/lockdep_proc.c
@@ -78,7 +78,10 @@ static int l_show(struct seq_file *m, void *v)
 	get_usage_chars(class, usage);
 	seq_printf(m, " %s", usage);
 
-	seq_printf(m, ": ");
+	/*
+	 * Print terminal lock status
+	 */
+	seq_printf(m, "%c: ", flags_is_terminal(class->flags) ? 'T' : ' ');
 	print_name(m, class);
 	seq_puts(m, "\n");
 
@@ -208,7 +211,7 @@ static int lockdep_stats_show(struct seq_file *m, void *v)
 		      nr_irq_read_safe = 0, nr_irq_read_unsafe = 0,
 		      nr_softirq_read_safe = 0, nr_softirq_read_unsafe = 0,
 		      nr_hardirq_read_safe = 0, nr_hardirq_read_unsafe = 0,
-		      sum_forward_deps = 0;
+		      nr_nocheck = 0, sum_forward_deps = 0;
 
 	list_for_each_entry(class, &all_lock_classes, lock_entry) {
 
@@ -240,6 +243,8 @@ static int lockdep_stats_show(struct seq_file *m, void *v)
 			nr_hardirq_read_safe++;
 		if (class->usage_mask & LOCKF_ENABLED_HARDIRQ_READ)
 			nr_hardirq_read_unsafe++;
+		if (class->flags & LOCKDEP_NOCHECK_FLAGS)
+			nr_nocheck++;
 
 #ifdef CONFIG_PROVE_LOCKING
 		sum_forward_deps += lockdep_count_forward_deps(class);
@@ -318,6 +323,8 @@ static int lockdep_stats_show(struct seq_file *m, void *v)
 			nr_uncategorized);
 	seq_printf(m, " unused locks:                  %11lu\n",
 			nr_unused);
+	seq_printf(m, " unchecked locks:               %11lu\n",
+			nr_nocheck);
 	seq_printf(m, " max locking depth:             %11u\n",
 			max_lockdep_depth);
 #ifdef CONFIG_PROVE_LOCKING
-- 
1.8.3.1
