Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0CD6B0387
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 03:14:15 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id w187so90630799pgb.10
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 00:14:15 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id o12si4308844pfa.545.2017.08.07.00.14.12
        for <linux-mm@kvack.org>;
        Mon, 07 Aug 2017 00:14:13 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v8 05/14] lockdep: Implement crossrelease feature
Date: Mon,  7 Aug 2017 16:12:52 +0900
Message-Id: <1502089981-21272-6-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

Lockdep is a runtime locking correctness validator that detects and
reports a deadlock or its possibility by checking dependencies between
locks. It's useful since it does not report just an actual deadlock but
also the possibility of a deadlock that has not actually happened yet.
That enables problems to be fixed before they affect real systems.

However, this facility is only applicable to typical locks, such as
spinlocks and mutexes, which are normally released within the context in
which they were acquired. However, synchronization primitives like page
locks or completions, which are allowed to be released in any context,
also create dependencies and can cause a deadlock. So lockdep should
track these locks to do a better job. The 'crossrelease' implementation
makes these primitives also be tracked.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/irqflags.h |  24 ++-
 include/linux/lockdep.h  | 110 +++++++++-
 include/linux/sched.h    |   8 +
 kernel/exit.c            |   1 +
 kernel/fork.c            |   4 +
 kernel/locking/lockdep.c | 508 ++++++++++++++++++++++++++++++++++++++++++++---
 kernel/workqueue.c       |   2 +
 lib/Kconfig.debug        |  12 ++
 8 files changed, 635 insertions(+), 34 deletions(-)

diff --git a/include/linux/irqflags.h b/include/linux/irqflags.h
index 5dd1272..e9ed580 100644
--- a/include/linux/irqflags.h
+++ b/include/linux/irqflags.h
@@ -23,10 +23,26 @@
 # define trace_softirq_context(p)	((p)->softirq_context)
 # define trace_hardirqs_enabled(p)	((p)->hardirqs_enabled)
 # define trace_softirqs_enabled(p)	((p)->softirqs_enabled)
-# define trace_hardirq_enter()	do { current->hardirq_context++; } while (0)
-# define trace_hardirq_exit()	do { current->hardirq_context--; } while (0)
-# define lockdep_softirq_enter()	do { current->softirq_context++; } while (0)
-# define lockdep_softirq_exit()	do { current->softirq_context--; } while (0)
+# define trace_hardirq_enter()			\
+do {						\
+	current->hardirq_context++;		\
+	crossrelease_hist_start(HARD);	\
+} while (0)
+# define trace_hardirq_exit()			\
+do {						\
+	current->hardirq_context--;		\
+	crossrelease_hist_end(HARD);		\
+} while (0)
+# define lockdep_softirq_enter()		\
+do {						\
+	current->softirq_context++;		\
+	crossrelease_hist_start(SOFT);	\
+} while (0)
+# define lockdep_softirq_exit()			\
+do {						\
+	current->softirq_context--;		\
+	crossrelease_hist_end(SOFT);		\
+} while (0)
 # define INIT_TRACE_IRQFLAGS	.softirqs_enabled = 1,
 #else
 # define trace_hardirqs_on()		do { } while (0)
diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index fffe49f..0c8a1b8 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -155,6 +155,12 @@ struct lockdep_map {
 	int				cpu;
 	unsigned long			ip;
 #endif
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+	/*
+	 * Whether it's a crosslock.
+	 */
+	int				cross;
+#endif
 };
 
 static inline void lockdep_copy_map(struct lockdep_map *to,
@@ -258,8 +264,62 @@ struct held_lock {
 	unsigned int hardirqs_off:1;
 	unsigned int references:12;					/* 32 bits */
 	unsigned int pin_count;
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+	/*
+	 * Generation id.
+	 *
+	 * A value of cross_gen_id will be stored when holding this,
+	 * which is globally increased whenever each crosslock is held.
+	 */
+	unsigned int gen_id;
+#endif
+};
+
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+#define MAX_XHLOCK_TRACE_ENTRIES 5
+
+/*
+ * This is for keeping locks waiting for commit so that true dependencies
+ * can be added at commit step.
+ */
+struct hist_lock {
+	/*
+	 * Seperate stack_trace data. This will be used at commit step.
+	 */
+	struct stack_trace	trace;
+	unsigned long		trace_entries[MAX_XHLOCK_TRACE_ENTRIES];
+
+	/*
+	 * Seperate hlock instance. This will be used at commit step.
+	 *
+	 * TODO: Use a smaller data structure containing only necessary
+	 * data. However, we should make lockdep code able to handle the
+	 * smaller one first.
+	 */
+	struct held_lock	hlock;
+};
+
+/*
+ * To initialize a lock as crosslock, lockdep_init_map_crosslock() should
+ * be called instead of lockdep_init_map().
+ */
+struct cross_lock {
+	/*
+	 * Seperate hlock instance. This will be used at commit step.
+	 *
+	 * TODO: Use a smaller data structure containing only necessary
+	 * data. However, we should make lockdep code able to handle the
+	 * smaller one first.
+	 */
+	struct held_lock	hlock;
 };
 
+struct lockdep_map_cross {
+	struct lockdep_map map;
+	struct cross_lock xlock;
+};
+#endif
+
 /*
  * Initialization, self-test and debugging-output methods:
  */
@@ -282,13 +342,6 @@ extern void lockdep_init_map(struct lockdep_map *lock, const char *name,
 			     struct lock_class_key *key, int subclass);
 
 /*
- * To initialize a lockdep_map statically use this macro.
- * Note that _name must not be NULL.
- */
-#define STATIC_LOCKDEP_MAP_INIT(_name, _key) \
-	{ .name = (_name), .key = (void *)(_key), }
-
-/*
  * Reinitialize a lock key - for cases where there is special locking or
  * special initialization of locks so that the validator gets the scope
  * of dependencies wrong: they are either too broad (they need a class-split)
@@ -467,6 +520,49 @@ static inline void lockdep_on(void)
 
 #endif /* !LOCKDEP */
 
+enum context_t {
+	HARD,
+	SOFT,
+	PROC,
+	CONTEXT_NR,
+};
+
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+extern void lockdep_init_map_crosslock(struct lockdep_map *lock,
+				       const char *name,
+				       struct lock_class_key *key,
+				       int subclass);
+extern void lock_commit_crosslock(struct lockdep_map *lock);
+
+#define STATIC_CROSS_LOCKDEP_MAP_INIT(_name, _key) \
+	{ .map.name = (_name), .map.key = (void *)(_key), \
+	  .map.cross = 1, }
+
+/*
+ * To initialize a lockdep_map statically use this macro.
+ * Note that _name must not be NULL.
+ */
+#define STATIC_LOCKDEP_MAP_INIT(_name, _key) \
+	{ .name = (_name), .key = (void *)(_key), .cross = 0, }
+
+extern void crossrelease_hist_start(enum context_t c);
+extern void crossrelease_hist_end(enum context_t c);
+extern void lockdep_init_task(struct task_struct *task);
+extern void lockdep_free_task(struct task_struct *task);
+#else
+/*
+ * To initialize a lockdep_map statically use this macro.
+ * Note that _name must not be NULL.
+ */
+#define STATIC_LOCKDEP_MAP_INIT(_name, _key) \
+	{ .name = (_name), .key = (void *)(_key), }
+
+static inline void crossrelease_hist_start(enum context_t c) {}
+static inline void crossrelease_hist_end(enum context_t c) {}
+static inline void lockdep_init_task(struct task_struct *task) {}
+static inline void lockdep_free_task(struct task_struct *task) {}
+#endif
+
 #ifdef CONFIG_LOCK_STAT
 
 extern void lock_contended(struct lockdep_map *lock, unsigned long ip);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 8337e2d..5becef5 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -849,6 +849,14 @@ struct task_struct {
 	gfp_t				lockdep_reclaim_gfp;
 #endif
 
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+#define MAX_XHLOCKS_NR 64UL
+	struct hist_lock *xhlocks; /* Crossrelease history locks */
+	unsigned int xhlock_idx;
+	/* For restoring at history boundaries */
+	unsigned int xhlock_idx_hist[CONTEXT_NR];
+#endif
+
 #ifdef CONFIG_UBSAN
 	unsigned int			in_ubsan;
 #endif
diff --git a/kernel/exit.c b/kernel/exit.c
index c5548fa..fa72d57 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -920,6 +920,7 @@ void __noreturn do_exit(long code)
 	exit_rcu();
 	TASKS_RCU(__srcu_read_unlock(&tasks_rcu_exit_srcu, tasks_rcu_i));
 
+	lockdep_free_task(tsk);
 	do_task_dead();
 }
 EXPORT_SYMBOL_GPL(do_exit);
diff --git a/kernel/fork.c b/kernel/fork.c
index 17921b0..cbf2221 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -484,6 +484,8 @@ void __init fork_init(void)
 	cpuhp_setup_state(CPUHP_BP_PREPARE_DYN, "fork:vm_stack_cache",
 			  NULL, free_vm_stack_cache);
 #endif
+
+	lockdep_init_task(&init_task);
 }
 
 int __weak arch_dup_task_struct(struct task_struct *dst,
@@ -1691,6 +1693,7 @@ static __latent_entropy struct task_struct *copy_process(
 	p->lockdep_depth = 0; /* no locks held yet */
 	p->curr_chain_key = 0;
 	p->lockdep_recursion = 0;
+	lockdep_init_task(p);
 #endif
 
 #ifdef CONFIG_DEBUG_MUTEXES
@@ -1949,6 +1952,7 @@ static __latent_entropy struct task_struct *copy_process(
 bad_fork_cleanup_perf:
 	perf_event_free_task(p);
 bad_fork_cleanup_policy:
+	lockdep_free_task(p);
 #ifdef CONFIG_NUMA
 	mpol_put(p->mempolicy);
 bad_fork_cleanup_threadgroup_lock:
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 22a13f9..afd6e64 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -58,6 +58,10 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/lock.h>
 
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+#include <linux/slab.h>
+#endif
+
 #ifdef CONFIG_PROVE_LOCKING
 int prove_locking = 1;
 module_param(prove_locking, int, 0644);
@@ -726,6 +730,18 @@ static int count_matching_names(struct lock_class *new_class)
 	return is_static || static_obj(lock->key) ? NULL : ERR_PTR(-EINVAL);
 }
 
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+static void cross_init(struct lockdep_map *lock, int cross);
+static int cross_lock(struct lockdep_map *lock);
+static int lock_acquire_crosslock(struct held_lock *hlock);
+static int lock_release_crosslock(struct lockdep_map *lock);
+#else
+static inline void cross_init(struct lockdep_map *lock, int cross) {}
+static inline int cross_lock(struct lockdep_map *lock) { return 0; }
+static inline int lock_acquire_crosslock(struct held_lock *hlock) { return 2; }
+static inline int lock_release_crosslock(struct lockdep_map *lock) { return 2; }
+#endif
+
 /*
  * Register a lock's class in the hash-table, if the class is not present
  * yet. Otherwise we look it up. We cache the result in the lock object
@@ -1784,6 +1800,9 @@ static inline void inc_chains(void)
 		if (nest)
 			return 2;
 
+		if (cross_lock(prev->instance))
+			continue;
+
 		return print_deadlock_bug(curr, prev, next);
 	}
 	return 1;
@@ -1937,30 +1956,36 @@ static inline void inc_chains(void)
 		int distance = curr->lockdep_depth - depth + 1;
 		hlock = curr->held_locks + depth - 1;
 		/*
-		 * Only non-recursive-read entries get new dependencies
-		 * added:
+		 * Only non-crosslock entries get new dependencies added.
+		 * Crosslock entries will be added by commit later:
 		 */
-		if (hlock->read != 2 && hlock->check) {
-			int ret = check_prev_add(curr, hlock, next,
-						distance, &trace, save);
-			if (!ret)
-				return 0;
-
+		if (!cross_lock(hlock->instance)) {
 			/*
-			 * Stop saving stack_trace if save_trace() was
-			 * called at least once:
+			 * Only non-recursive-read entries get new dependencies
+			 * added:
 			 */
-			if (save && ret == 2)
-				save = NULL;
+			if (hlock->read != 2 && hlock->check) {
+				int ret = check_prev_add(curr, hlock, next,
+							 distance, &trace, save);
+				if (!ret)
+					return 0;
 
-			/*
-			 * Stop after the first non-trylock entry,
-			 * as non-trylock entries have added their
-			 * own direct dependencies already, so this
-			 * lock is connected to them indirectly:
-			 */
-			if (!hlock->trylock)
-				break;
+				/*
+				 * Stop saving stack_trace if save_trace() was
+				 * called at least once:
+				 */
+				if (save && ret == 2)
+					save = NULL;
+
+				/*
+				 * Stop after the first non-trylock entry,
+				 * as non-trylock entries have added their
+				 * own direct dependencies already, so this
+				 * lock is connected to them indirectly:
+				 */
+				if (!hlock->trylock)
+					break;
+			}
 		}
 		depth--;
 		/*
@@ -3225,7 +3250,7 @@ static int mark_lock(struct task_struct *curr, struct held_lock *this,
 /*
  * Initialize a lock instance's lock-class mapping info:
  */
-void lockdep_init_map(struct lockdep_map *lock, const char *name,
+static void __lockdep_init_map(struct lockdep_map *lock, const char *name,
 		      struct lock_class_key *key, int subclass)
 {
 	int i;
@@ -3283,8 +3308,25 @@ void lockdep_init_map(struct lockdep_map *lock, const char *name,
 		raw_local_irq_restore(flags);
 	}
 }
+
+void lockdep_init_map(struct lockdep_map *lock, const char *name,
+		      struct lock_class_key *key, int subclass)
+{
+	cross_init(lock, 0);
+	__lockdep_init_map(lock, name, key, subclass);
+}
 EXPORT_SYMBOL_GPL(lockdep_init_map);
 
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+void lockdep_init_map_crosslock(struct lockdep_map *lock, const char *name,
+		      struct lock_class_key *key, int subclass)
+{
+	cross_init(lock, 1);
+	__lockdep_init_map(lock, name, key, subclass);
+}
+EXPORT_SYMBOL_GPL(lockdep_init_map_crosslock);
+#endif
+
 struct lock_class_key __lockdep_no_validate__;
 EXPORT_SYMBOL_GPL(__lockdep_no_validate__);
 
@@ -3340,6 +3382,7 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 	int chain_head = 0;
 	int class_idx;
 	u64 chain_key;
+	int ret;
 
 	if (unlikely(!debug_locks))
 		return 0;
@@ -3388,7 +3431,8 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 
 	class_idx = class - lock_classes + 1;
 
-	if (depth) {
+	/* TODO: nest_lock is not implemented for crosslock yet. */
+	if (depth && !cross_lock(lock)) {
 		hlock = curr->held_locks + depth - 1;
 		if (hlock->class_idx == class_idx && nest_lock) {
 			if (hlock->references) {
@@ -3476,6 +3520,14 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 	if (!validate_chain(curr, lock, hlock, chain_head, chain_key))
 		return 0;
 
+	ret = lock_acquire_crosslock(hlock);
+	/*
+	 * 2 means normal acquire operations are needed. Otherwise, it's
+	 * ok just to return with '0:fail, 1:success'.
+	 */
+	if (ret != 2)
+		return ret;
+
 	curr->curr_chain_key = chain_key;
 	curr->lockdep_depth++;
 	check_chain_key(curr);
@@ -3713,11 +3765,19 @@ static int __lock_downgrade(struct lockdep_map *lock, unsigned long ip)
 	struct task_struct *curr = current;
 	struct held_lock *hlock;
 	unsigned int depth;
-	int i;
+	int ret, i;
 
 	if (unlikely(!debug_locks))
 		return 0;
 
+	ret = lock_release_crosslock(lock);
+	/*
+	 * 2 means normal release operations are needed. Otherwise, it's
+	 * ok just to return with '0:fail, 1:success'.
+	 */
+	if (ret != 2)
+		return ret;
+
 	depth = curr->lockdep_depth;
 	/*
 	 * So we're all set to release this lock.. wait what lock? We don't
@@ -4593,6 +4653,13 @@ asmlinkage __visible void lockdep_sys_exit(void)
 				curr->comm, curr->pid);
 		lockdep_print_held_locks(curr);
 	}
+
+	/*
+	 * The lock history for each syscall should be independent. So wipe the
+	 * slate clean on return to userspace.
+	 */
+	crossrelease_hist_end(PROC);
+	crossrelease_hist_start(PROC);
 }
 
 void lockdep_rcu_suspicious(const char *file, const int line, const char *s)
@@ -4641,3 +4708,398 @@ void lockdep_rcu_suspicious(const char *file, const int line, const char *s)
 	dump_stack();
 }
 EXPORT_SYMBOL_GPL(lockdep_rcu_suspicious);
+
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+
+/*
+ * Crossrelease works by recording a lock history for each thread and
+ * connecting those historic locks that were taken after the
+ * wait_for_completion() in the complete() context.
+ *
+ * Task-A				Task-B
+ *
+ *					mutex_lock(&A);
+ *					mutex_unlock(&A);
+ *
+ * wait_for_completion(&C);
+ *   lock_acquire_crosslock();
+ *     atomic_inc_return(&cross_gen_id);
+ *                                |
+ *				  |	mutex_lock(&B);
+ *				  |	mutex_unlock(&B);
+ *                                |
+ *				  |	complete(&C);
+ *				  `--	  lock_commit_crosslock();
+ *
+ * Which will then add a dependency between B and C.
+ */
+
+#define xhlock(i)         (current->xhlocks[(i) % MAX_XHLOCKS_NR])
+
+/*
+ * Whenever a crosslock is held, cross_gen_id will be increased.
+ */
+static atomic_t cross_gen_id; /* Can be wrapped */
+
+/*
+ * Lock history stacks; we have 3 nested lock history stacks:
+ *
+ *   Hard IRQ
+ *   Soft IRQ
+ *   History / Task
+ *
+ * The thing is that once we complete a (Hard/Soft) IRQ the future task locks
+ * should not depend on any of the locks observed while running the IRQ.
+ *
+ * So what we do is rewind the history buffer and erase all our knowledge of
+ * that temporal event.
+ */
+
+/*
+ * We need this to annotate lock history boundaries. Take for instance
+ * workqueues; each work is independent of the last. The completion of a future
+ * work does not depend on the completion of a past work (in general).
+ * Therefore we must not carry that (lock) dependency across works.
+ *
+ * This is true for many things; pretty much all kthreads fall into this
+ * pattern, where they have an 'idle' state and future completions do not
+ * depend on past completions. Its just that since they all have the 'same'
+ * form -- the kthread does the same over and over -- it doesn't typically
+ * matter.
+ *
+ * The same is true for system-calls, once a system call is completed (we've
+ * returned to userspace) the next system call does not depend on the lock
+ * history of the previous system call.
+ */
+void crossrelease_hist_start(enum context_t c)
+{
+	if (current->xhlocks)
+		current->xhlock_idx_hist[c] = current->xhlock_idx;
+}
+
+void crossrelease_hist_end(enum context_t c)
+{
+	if (current->xhlocks)
+		current->xhlock_idx = current->xhlock_idx_hist[c];
+}
+
+static int cross_lock(struct lockdep_map *lock)
+{
+	return lock ? lock->cross : 0;
+}
+
+/*
+ * This is needed to decide the relationship between wrapable variables.
+ */
+static inline int before(unsigned int a, unsigned int b)
+{
+	return (int)(a - b) < 0;
+}
+
+static inline struct lock_class *xhlock_class(struct hist_lock *xhlock)
+{
+	return hlock_class(&xhlock->hlock);
+}
+
+static inline struct lock_class *xlock_class(struct cross_lock *xlock)
+{
+	return hlock_class(&xlock->hlock);
+}
+
+/*
+ * Should we check a dependency with previous one?
+ */
+static inline int depend_before(struct held_lock *hlock)
+{
+	return hlock->read != 2 && hlock->check && !hlock->trylock;
+}
+
+/*
+ * Should we check a dependency with next one?
+ */
+static inline int depend_after(struct held_lock *hlock)
+{
+	return hlock->read != 2 && hlock->check;
+}
+
+/*
+ * Check if the xhlock is valid, which would be false if,
+ *
+ *    1. Has not used after initializaion yet.
+ *
+ * Remind hist_lock is implemented as a ring buffer.
+ */
+static inline int xhlock_valid(struct hist_lock *xhlock)
+{
+	/*
+	 * xhlock->hlock.instance must be !NULL.
+	 */
+	return !!xhlock->hlock.instance;
+}
+
+/*
+ * Record a hist_lock entry.
+ *
+ * Irq disable is only required.
+ */
+static void add_xhlock(struct held_lock *hlock)
+{
+	unsigned int idx = ++current->xhlock_idx;
+	struct hist_lock *xhlock = &xhlock(idx);
+
+#ifdef CONFIG_DEBUG_LOCKDEP
+	/*
+	 * This can be done locklessly because they are all task-local
+	 * state, we must however ensure IRQs are disabled.
+	 */
+	WARN_ON_ONCE(!irqs_disabled());
+#endif
+
+	/* Initialize hist_lock's members */
+	xhlock->hlock = *hlock;
+
+	xhlock->trace.nr_entries = 0;
+	xhlock->trace.max_entries = MAX_XHLOCK_TRACE_ENTRIES;
+	xhlock->trace.entries = xhlock->trace_entries;
+	xhlock->trace.skip = 3;
+	save_stack_trace(&xhlock->trace);
+}
+
+static inline int same_context_xhlock(struct hist_lock *xhlock)
+{
+	return xhlock->hlock.irq_context == task_irq_context(current);
+}
+
+/*
+ * This should be lockless as far as possible because this would be
+ * called very frequently.
+ */
+static void check_add_xhlock(struct held_lock *hlock)
+{
+	/*
+	 * Record a hist_lock, only in case that acquisitions ahead
+	 * could depend on the held_lock. For example, if the held_lock
+	 * is trylock then acquisitions ahead never depends on that.
+	 * In that case, we don't need to record it. Just return.
+	 */
+	if (!current->xhlocks || !depend_before(hlock))
+		return;
+
+	add_xhlock(hlock);
+}
+
+/*
+ * For crosslock.
+ */
+static int add_xlock(struct held_lock *hlock)
+{
+	struct cross_lock *xlock;
+	unsigned int gen_id;
+
+	if (!graph_lock())
+		return 0;
+
+	xlock = &((struct lockdep_map_cross *)hlock->instance)->xlock;
+
+	gen_id = (unsigned int)atomic_inc_return(&cross_gen_id);
+	xlock->hlock = *hlock;
+	xlock->hlock.gen_id = gen_id;
+	graph_unlock();
+
+	return 1;
+}
+
+/*
+ * Called for both normal and crosslock acquires. Normal locks will be
+ * pushed on the hist_lock queue. Cross locks will record state and
+ * stop regular lock_acquire() to avoid being placed on the held_lock
+ * stack.
+ *
+ * Return: 0 - failure;
+ *         1 - crosslock, done;
+ *         2 - normal lock, continue to held_lock[] ops.
+ */
+static int lock_acquire_crosslock(struct held_lock *hlock)
+{
+	/*
+	 *	CONTEXT 1		CONTEXT 2
+	 *	---------		---------
+	 *	lock A (cross)
+	 *	X = atomic_inc_return(&cross_gen_id)
+	 *	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+	 *				Y = atomic_read_acquire(&cross_gen_id)
+	 *				lock B
+	 *
+	 * atomic_read_acquire() is for ordering between A and B,
+	 * IOW, A happens before B, when CONTEXT 2 see Y >= X.
+	 *
+	 * Pairs with atomic_inc_return() in add_xlock().
+	 */
+	hlock->gen_id = (unsigned int)atomic_read_acquire(&cross_gen_id);
+
+	if (cross_lock(hlock->instance))
+		return add_xlock(hlock);
+
+	check_add_xhlock(hlock);
+	return 2;
+}
+
+static int copy_trace(struct stack_trace *trace)
+{
+	unsigned long *buf = stack_trace + nr_stack_trace_entries;
+	unsigned int max_nr = MAX_STACK_TRACE_ENTRIES - nr_stack_trace_entries;
+	unsigned int nr = min(max_nr, trace->nr_entries);
+
+	trace->nr_entries = nr;
+	memcpy(buf, trace->entries, nr * sizeof(trace->entries[0]));
+	trace->entries = buf;
+	nr_stack_trace_entries += nr;
+
+	if (nr_stack_trace_entries >= MAX_STACK_TRACE_ENTRIES-1) {
+		if (!debug_locks_off_graph_unlock())
+			return 0;
+
+		print_lockdep_off("BUG: MAX_STACK_TRACE_ENTRIES too low!");
+		dump_stack();
+
+		return 0;
+	}
+
+	return 1;
+}
+
+static int commit_xhlock(struct cross_lock *xlock, struct hist_lock *xhlock)
+{
+	unsigned int xid, pid;
+	u64 chain_key;
+
+	xid = xlock_class(xlock) - lock_classes;
+	chain_key = iterate_chain_key((u64)0, xid);
+	pid = xhlock_class(xhlock) - lock_classes;
+	chain_key = iterate_chain_key(chain_key, pid);
+
+	if (lookup_chain_cache(chain_key))
+		return 1;
+
+	if (!add_chain_cache_classes(xid, pid, xhlock->hlock.irq_context,
+				chain_key))
+		return 0;
+
+	if (!check_prev_add(current, &xlock->hlock, &xhlock->hlock, 1,
+			    &xhlock->trace, copy_trace))
+		return 0;
+
+	return 1;
+}
+
+static void commit_xhlocks(struct cross_lock *xlock)
+{
+	unsigned int cur = current->xhlock_idx;
+	unsigned int i;
+
+	if (!graph_lock())
+		return;
+
+	for (i = 0; i < MAX_XHLOCKS_NR; i++) {
+		struct hist_lock *xhlock = &xhlock(cur - i);
+
+		if (!xhlock_valid(xhlock))
+			break;
+
+		if (before(xhlock->hlock.gen_id, xlock->hlock.gen_id))
+			break;
+
+		if (!same_context_xhlock(xhlock))
+			break;
+
+		/*
+		 * commit_xhlock() returns 0 with graph_lock already
+		 * released if fail.
+		 */
+		if (!commit_xhlock(xlock, xhlock))
+			return;
+	}
+
+	graph_unlock();
+}
+
+void lock_commit_crosslock(struct lockdep_map *lock)
+{
+	struct cross_lock *xlock;
+	unsigned long flags;
+
+	if (unlikely(!debug_locks || current->lockdep_recursion))
+		return;
+
+	if (!current->xhlocks)
+		return;
+
+	/*
+	 * Do commit hist_locks with the cross_lock, only in case that
+	 * the cross_lock could depend on acquisitions after that.
+	 *
+	 * For example, if the cross_lock does not have the 'check' flag
+	 * then we don't need to check dependencies and commit for that.
+	 * Just skip it. In that case, of course, the cross_lock does
+	 * not depend on acquisitions ahead, either.
+	 *
+	 * WARNING: Don't do that in add_xlock() in advance. When an
+	 * acquisition context is different from the commit context,
+	 * invalid(skipped) cross_lock might be accessed.
+	 */
+	if (!depend_after(&((struct lockdep_map_cross *)lock)->xlock.hlock))
+		return;
+
+	raw_local_irq_save(flags);
+	check_flags(flags);
+	current->lockdep_recursion = 1;
+	xlock = &((struct lockdep_map_cross *)lock)->xlock;
+	commit_xhlocks(xlock);
+	current->lockdep_recursion = 0;
+	raw_local_irq_restore(flags);
+}
+EXPORT_SYMBOL_GPL(lock_commit_crosslock);
+
+/*
+ * Return: 1 - crosslock, done;
+ *         2 - normal lock, continue to held_lock[] ops.
+ */
+static int lock_release_crosslock(struct lockdep_map *lock)
+{
+	return cross_lock(lock) ? 1 : 2;
+}
+
+static void cross_init(struct lockdep_map *lock, int cross)
+{
+	lock->cross = cross;
+
+	/*
+	 * Crossrelease assumes that the ring buffer size of xhlocks
+	 * is aligned with power of 2. So force it on build.
+	 */
+	BUILD_BUG_ON(MAX_XHLOCKS_NR & (MAX_XHLOCKS_NR - 1));
+}
+
+void lockdep_init_task(struct task_struct *task)
+{
+	int i;
+
+	task->xhlock_idx = UINT_MAX;
+
+	for (i = 0; i < CONTEXT_NR; i++)
+		task->xhlock_idx_hist[i] = UINT_MAX;
+
+	task->xhlocks = kzalloc(sizeof(struct hist_lock) * MAX_XHLOCKS_NR,
+				GFP_KERNEL);
+}
+
+void lockdep_free_task(struct task_struct *task)
+{
+	if (task->xhlocks) {
+		void *tmp = task->xhlocks;
+		/* Diable crossrelease for current */
+		task->xhlocks = NULL;
+		kfree(tmp);
+	}
+}
+#endif
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index a86688f..eb03c4f 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -2093,6 +2093,7 @@ static void process_one_work(struct worker *worker, struct work_struct *work)
 
 	lock_map_acquire_read(&pwq->wq->lockdep_map);
 	lock_map_acquire(&lockdep_map);
+	crossrelease_hist_start(PROC);
 	trace_workqueue_execute_start(work);
 	worker->current_func(work);
 	/*
@@ -2100,6 +2101,7 @@ static void process_one_work(struct worker *worker, struct work_struct *work)
 	 * point will only record its address.
 	 */
 	trace_workqueue_execute_end(work);
+	crossrelease_hist_end(PROC);
 	lock_map_release(&lockdep_map);
 	lock_map_release(&pwq->wq->lockdep_map);
 
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 98fe715..037e813 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1073,6 +1073,18 @@ config DEBUG_LOCK_ALLOC
 	 spin_lock_init()/mutex_init()/etc., or whether there is any lock
 	 held during task exit.
 
+config LOCKDEP_CROSSRELEASE
+	bool "Lock debugging: make lockdep work for crosslocks"
+	depends on PROVE_LOCKING
+	default n
+	help
+	 This makes lockdep work for crosslock which is a lock allowed to
+	 be released in a different context from the acquisition context.
+	 Normally a lock must be released in the context acquiring the lock.
+	 However, relexing this constraint helps synchronization primitives
+	 such as page locks or completions can use the lock correctness
+	 detector, lockdep.
+
 config PROVE_LOCKING
 	bool "Lock debugging: prove locking correctness"
 	depends on DEBUG_KERNEL && TRACE_IRQFLAGS_SUPPORT && STACKTRACE_SUPPORT && LOCKDEP_SUPPORT
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
