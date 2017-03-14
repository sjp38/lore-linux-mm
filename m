Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E1B746B0388
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 04:22:29 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j190so162215pgc.4
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 01:22:29 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id q11si14041888pfj.274.2017.03.14.01.22.27
        for <linux-mm@kvack.org>;
        Tue, 14 Mar 2017 01:22:28 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v6 05/15] lockdep: Implement crossrelease feature
Date: Tue, 14 Mar 2017 17:18:52 +0900
Message-ID: <1489479542-27030-6-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

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
 include/linux/lockdep.h  | 116 +++++++++++-
 include/linux/sched.h    |   8 +
 kernel/exit.c            |   1 +
 kernel/fork.c            |   3 +
 kernel/locking/lockdep.c | 451 ++++++++++++++++++++++++++++++++++++++++++++---
 kernel/workqueue.c       |   1 +
 lib/Kconfig.debug        |  12 ++
 8 files changed, 582 insertions(+), 34 deletions(-)

diff --git a/include/linux/irqflags.h b/include/linux/irqflags.h
index 5dd1272..c40af8a 100644
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
+# define trace_hardirq_enter()		\
+do {					\
+	current->hardirq_context++;	\
+	crossrelease_hardirq_start();	\
+} while (0)
+# define trace_hardirq_exit()		\
+do {					\
+	current->hardirq_context--;	\
+	crossrelease_hardirq_end();	\
+} while (0)
+# define lockdep_softirq_enter()	\
+do {					\
+	current->softirq_context++;	\
+	crossrelease_softirq_start();	\
+} while (0)
+# define lockdep_softirq_exit()		\
+do {					\
+	current->softirq_context--;	\
+	crossrelease_softirq_end();	\
+} while (0)
 # define INIT_TRACE_IRQFLAGS	.softirqs_enabled = 1,
 #else
 # define trace_hardirqs_on()		do { } while (0)
diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index c1458fe..9902b2a 100644
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
@@ -258,9 +264,70 @@ struct held_lock {
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
+	 * Each work of workqueue might run in a different context,
+	 * thanks to concurrency support of workqueue. So we have to
+	 * distinguish each work to avoid false positive.
+	 */
+	unsigned int		work_id;
+
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
 };
 
 /*
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
+};
+
+struct lockdep_map_cross {
+	struct lockdep_map map;
+	struct cross_lock xlock;
+};
+#endif
+
+/*
  * Initialization, self-test and debugging-output methods:
  */
 extern void lockdep_info(void);
@@ -282,13 +349,6 @@ extern void lockdep_init_map(struct lockdep_map *lock, const char *name,
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
@@ -443,6 +503,48 @@ static inline void lockdep_on(void)
 
 #endif /* !LOCKDEP */
 
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
+extern void crossrelease_hardirq_start(void);
+extern void crossrelease_hardirq_end(void);
+extern void crossrelease_softirq_start(void);
+extern void crossrelease_softirq_end(void);
+extern void crossrelease_work_start(void);
+extern void init_crossrelease_task(struct task_struct *task);
+extern void free_crossrelease_task(struct task_struct *task);
+#else
+/*
+ * To initialize a lockdep_map statically use this macro.
+ * Note that _name must not be NULL.
+ */
+#define STATIC_LOCKDEP_MAP_INIT(_name, _key) \
+	{ .name = (_name), .key = (void *)(_key), }
+
+static inline void crossrelease_hardirq_start(void) {}
+static inline void crossrelease_hardirq_end(void) {}
+static inline void crossrelease_softirq_start(void) {}
+static inline void crossrelease_softirq_end(void) {}
+static inline void crossrelease_work_start(void) {}
+static inline void init_crossrelease_task(struct task_struct *task) {}
+static inline void free_crossrelease_task(struct task_struct *task) {}
+#endif
+
 #ifdef CONFIG_LOCK_STAT
 
 extern void lock_contended(struct lockdep_map *lock, unsigned long ip);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index e9c009d..318d020 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1749,6 +1749,14 @@ struct task_struct {
 	struct held_lock held_locks[MAX_LOCK_DEPTH];
 	gfp_t lockdep_reclaim_gfp;
 #endif
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+#define MAX_XHLOCKS_NR 64UL
+	struct hist_lock *xhlocks; /* Crossrelease history locks */
+	unsigned int xhlock_idx;
+	unsigned int xhlock_idx_soft; /* For backing up at softirq entry */
+	unsigned int xhlock_idx_hard; /* For backing up at hardirq entry */
+	unsigned int work_id;
+#endif
 #ifdef CONFIG_UBSAN
 	unsigned int in_ubsan;
 #endif
diff --git a/kernel/exit.c b/kernel/exit.c
index 3076f30..cc56aad 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -883,6 +883,7 @@ void __noreturn do_exit(long code)
 	exit_rcu();
 	TASKS_RCU(__srcu_read_unlock(&tasks_rcu_exit_srcu, tasks_rcu_i));
 
+	free_crossrelease_task(tsk);
 	do_task_dead();
 }
 EXPORT_SYMBOL_GPL(do_exit);
diff --git a/kernel/fork.c b/kernel/fork.c
index 997ac1d..f9623a0 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -451,6 +451,7 @@ void __init fork_init(void)
 	for (i = 0; i < UCOUNT_COUNTS; i++) {
 		init_user_ns.ucount_max[i] = max_threads/2;
 	}
+	init_crossrelease_task(&init_task);
 }
 
 int __weak arch_dup_task_struct(struct task_struct *dst,
@@ -1611,6 +1612,7 @@ static __latent_entropy struct task_struct *copy_process(
 	p->lockdep_depth = 0; /* no locks held yet */
 	p->curr_chain_key = 0;
 	p->lockdep_recursion = 0;
+	init_crossrelease_task(p);
 #endif
 
 #ifdef CONFIG_DEBUG_MUTEXES
@@ -1856,6 +1858,7 @@ static __latent_entropy struct task_struct *copy_process(
 bad_fork_cleanup_perf:
 	perf_event_free_task(p);
 bad_fork_cleanup_policy:
+	free_crossrelease_task(p);
 #ifdef CONFIG_NUMA
 	mpol_put(p->mempolicy);
 bad_fork_cleanup_threadgroup_lock:
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 2847356..db15fce 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -55,6 +55,10 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/lock.h>
 
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+#include <linux/slab.h>
+#endif
+
 #ifdef CONFIG_PROVE_LOCKING
 int prove_locking = 1;
 module_param(prove_locking, int, 0644);
@@ -709,6 +713,18 @@ static int count_matching_names(struct lock_class *new_class)
 	return NULL;
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
@@ -1768,6 +1784,9 @@ static inline void inc_chains(void)
 		if (nest)
 			return 2;
 
+		if (cross_lock(prev->instance))
+			continue;
+
 		return print_deadlock_bug(curr, prev, next);
 	}
 	return 1;
@@ -1921,30 +1940,36 @@ static inline void inc_chains(void)
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
@@ -3203,7 +3228,7 @@ static int mark_lock(struct task_struct *curr, struct held_lock *this,
 /*
  * Initialize a lock instance's lock-class mapping info:
  */
-void lockdep_init_map(struct lockdep_map *lock, const char *name,
+static void __lockdep_init_map(struct lockdep_map *lock, const char *name,
 		      struct lock_class_key *key, int subclass)
 {
 	int i;
@@ -3261,8 +3286,25 @@ void lockdep_init_map(struct lockdep_map *lock, const char *name,
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
 
@@ -3317,6 +3359,7 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 	unsigned int depth;
 	int chain_head = 0;
 	int class_idx;
+	int ret;
 	u64 chain_key;
 
 	if (unlikely(!debug_locks))
@@ -3366,7 +3409,8 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 
 	class_idx = class - lock_classes + 1;
 
-	if (depth) {
+	/* TODO: nest_lock is not implemented for crosslock yet. */
+	if (depth && !cross_lock(lock)) {
 		hlock = curr->held_locks + depth - 1;
 		if (hlock->class_idx == class_idx && nest_lock) {
 			if (hlock->references)
@@ -3447,6 +3491,14 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
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
@@ -3610,11 +3662,19 @@ static int match_held_lock(struct held_lock *hlock, struct lockdep_map *lock)
 	struct task_struct *curr = current;
 	struct held_lock *hlock, *prev_hlock;
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
@@ -4557,3 +4617,348 @@ void lockdep_rcu_suspicious(const char *file, const int line, const char *s)
 	dump_stack();
 }
 EXPORT_SYMBOL_GPL(lockdep_rcu_suspicious);
+
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+
+#define xhlock(i)         (current->xhlocks[(i) % MAX_XHLOCKS_NR])
+#define xhlock_same(i, j) ((i) % MAX_XHLOCKS_NR == (j) % MAX_XHLOCKS_NR)
+
+/*
+ * Whenever a crosslock is held, cross_gen_id will be increased.
+ */
+static atomic_t cross_gen_id; /* Can be wrapped */
+
+void crossrelease_hardirq_start(void)
+{
+	if (current->xhlocks)
+		current->xhlock_idx_hard = current->xhlock_idx;
+}
+
+void crossrelease_hardirq_end(void)
+{
+	if (current->xhlocks)
+		current->xhlock_idx = current->xhlock_idx_hard;
+}
+
+void crossrelease_softirq_start(void)
+{
+	if (current->xhlocks)
+		current->xhlock_idx_soft = current->xhlock_idx;
+}
+
+void crossrelease_softirq_end(void)
+{
+	if (current->xhlocks)
+		current->xhlock_idx = current->xhlock_idx_soft;
+}
+
+/*
+ * Crossrelease needs to distinguish each work of workqueues.
+ * Caller is supposed to be a worker.
+ */
+void crossrelease_work_start(void)
+{
+	if (current->xhlocks)
+		current->work_id++;
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
+ * Check if the xhlock is used at least once after initializaion.
+ * Remind hist_lock is implemented as a ring buffer.
+ */
+static inline int xhlock_used(struct hist_lock *xhlock)
+{
+	/*
+	 * xhlock->hlock.instance must be !NULL if it's used.
+	 */
+	return !!xhlock->hlock.instance;
+}
+
+/*
+ * Only access local task's data, so irq disable is only required.
+ */
+static void add_xhlock(struct held_lock *hlock)
+{
+	unsigned int idx = current->xhlock_idx++;
+	struct hist_lock *xhlock = &xhlock(idx);
+
+	/* Initialize hist_lock's members */
+	xhlock->hlock = *hlock;
+	xhlock->work_id = current->work_id;
+
+	xhlock->trace.nr_entries = 0;
+	xhlock->trace.max_entries = MAX_XHLOCK_TRACE_ENTRIES;
+	xhlock->trace.entries = xhlock->trace_entries;
+	xhlock->trace.skip = 3;
+	save_stack_trace(&xhlock->trace);
+}
+
+/*
+ * Only access local task's data, so irq disable is only required.
+ */
+static int same_context_xhlock(struct hist_lock *xhlock)
+{
+	struct task_struct *curr = current;
+
+	/* In the case of hardirq context */
+	if (curr->hardirq_context) {
+		if (xhlock->hlock.irq_context & 2) /* 2: bitmask for hardirq */
+			return 1;
+	/* In the case of softriq context */
+	} else if (curr->softirq_context) {
+		if (xhlock->hlock.irq_context & 1) /* 1: bitmask for softirq */
+			return 1;
+	/* In the case of process context */
+	} else {
+		if (xhlock->work_id == curr->work_id)
+			return 1;
+	}
+	return 0;
+}
+
+/*
+ * This should be lockless as far as possible because this would be
+ * called very frequently.
+ */
+static void check_add_xhlock(struct held_lock *hlock)
+{
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
+ * return 0: Stop. Failed to acquire graph_lock.
+ * return 1: Done. No more acquire ops is needed.
+ * return 2: Need to do normal acquire operation.
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
+static int commit_xhlocks(struct cross_lock *xlock)
+{
+	unsigned int cur = current->xhlock_idx;
+	unsigned int i;
+
+	if (!graph_lock())
+		return 0;
+
+	for (i = cur - 1; !xhlock_same(i, cur); i--) {
+		struct hist_lock *xhlock = &xhlock(i);
+
+		if (!xhlock_used(xhlock))
+			break;
+
+		if (before(xhlock->hlock.gen_id, xlock->hlock.gen_id))
+			break;
+
+		if (same_context_xhlock(xhlock) &&
+		    !commit_xhlock(xlock, xhlock))
+			return 0;
+	}
+
+	graph_unlock();
+	return 1;
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
+	 * We have to check this here instead of in add_xlock(), since
+	 * otherwise invalid cross_lock might be accessed on commit. In
+	 * other words, building xlock in add_xlock() should not be
+	 * skipped in order to access valid cross_lock on commit.
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
+ * return 1: Done. No more release ops is needed.
+ * return 2: Need to do normal release operation.
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
+void init_crossrelease_task(struct task_struct *task)
+{
+	task->xhlock_idx = 0;
+	task->xhlock_idx_soft = 0;
+	task->xhlock_idx_hard = 0;
+	task->xhlocks = kzalloc(sizeof(struct hist_lock) * MAX_XHLOCKS_NR,
+				GFP_KERNEL);
+	task->work_id = 0;
+}
+
+void free_crossrelease_task(struct task_struct *task)
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
index 479d840..b4a451f 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -2034,6 +2034,7 @@ static void process_one_work(struct worker *worker, struct work_struct *work)
 	struct lockdep_map lockdep_map;
 
 	lockdep_copy_map(&lockdep_map, &work->lockdep_map);
+	crossrelease_work_start();
 #endif
 	/* ensure we're on the correct CPU */
 	WARN_ON_ONCE(!(pool->flags & POOL_DISASSOCIATED) &&
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index a6c8db1..2a9e475 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1042,6 +1042,18 @@ config DEBUG_LOCK_ALLOC
 	 spin_lock_init()/mutex_init()/etc., or whether there is any lock
 	 held during task exit.
 
+config LOCKDEP_CROSSRELEASE
+	bool "Lock debugging: make lockdep work for crosslocks"
+	select PROVE_LOCKING
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
