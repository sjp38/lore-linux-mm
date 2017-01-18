Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 408BD6B026C
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 08:17:57 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 201so16524657pfw.5
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:17:57 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id j15si217857pfj.118.2017.01.18.05.17.54
        for <linux-mm@kvack.org>;
        Wed, 18 Jan 2017 05:17:55 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Date: Wed, 18 Jan 2017 22:17:32 +0900
Message-Id: <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

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
track these locks to do a better job. The "crossrelease" implementation
makes these primitives also be tracked.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/irqflags.h |  24 ++-
 include/linux/lockdep.h  | 129 +++++++++++++
 include/linux/sched.h    |   9 +
 kernel/exit.c            |   9 +
 kernel/fork.c            |  23 +++
 kernel/locking/lockdep.c | 482 ++++++++++++++++++++++++++++++++++++++++++++---
 kernel/workqueue.c       |   1 +
 lib/Kconfig.debug        |  13 ++
 8 files changed, 665 insertions(+), 25 deletions(-)

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
index c1458fe..f7c6905 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -155,6 +155,12 @@ struct lockdep_map {
 	int				cpu;
 	unsigned long			ip;
 #endif
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+	/*
+	 * Flag to indicate whether it's a crosslock.
+	 */
+	int				cross;
+#endif
 };
 
 static inline void lockdep_copy_map(struct lockdep_map *to,
@@ -258,9 +264,94 @@ struct held_lock {
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
+	 * If the previous in held_locks can create a proper dependency
+	 * with a target crosslock, then we can skip commiting this,
+	 * since "the target crosslock -> the previous lock" and
+	 * "the previous lock -> this lock" can cover the case. So we
+	 * keep the previous's gen_id to make the decision.
+	 */
+	unsigned int		prev_gen_id;
+
+	/*
+	 * Each work of workqueue might run in a different context,
+	 * thanks to concurrency support of workqueue. So we have to
+	 * distinguish each work to avoid false positive.
+	 *
+	 * TODO: We can also add dependencies between two acquisitions
+	 * of different work_id, if they don't cause a sleep so make
+	 * the worker stalled.
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
+	 * struct held_lock does not have an indicator whether in nmi.
+	 */
+	int nmi;
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
+	 * When more than one acquisition of crosslocks are overlapped,
+	 * we do actual commit only when ref == 0.
+	 */
+	atomic_t ref;
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
@@ -281,6 +372,37 @@ struct held_lock {
 extern void lockdep_init_map(struct lockdep_map *lock, const char *name,
 			     struct lock_class_key *key, int subclass);
 
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+extern void lockdep_init_map_crosslock(struct lockdep_map *lock,
+				       const char *name,
+				       struct lock_class_key *key,
+				       int subclass);
+extern void lock_commit_crosslock(struct lockdep_map *lock);
+
+/*
+ * What we essencially have to initialize is 'ref'. Other members will
+ * be initialized in add_xlock().
+ */
+#define STATIC_CROSS_LOCK_INIT() \
+	{ .ref = ATOMIC_INIT(0),}
+
+#define STATIC_CROSS_LOCKDEP_MAP_INIT(_name, _key) \
+	{ .map.name = (_name), .map.key = (void *)(_key), \
+	  .map.cross = 1, .xlock = STATIC_CROSS_LOCK_INIT(), }
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
+#else
 /*
  * To initialize a lockdep_map statically use this macro.
  * Note that _name must not be NULL.
@@ -288,6 +410,13 @@ extern void lockdep_init_map(struct lockdep_map *lock, const char *name,
 #define STATIC_LOCKDEP_MAP_INIT(_name, _key) \
 	{ .name = (_name), .key = (void *)(_key), }
 
+void crossrelease_hardirq_start(void) {}
+void crossrelease_hardirq_end(void) {}
+void crossrelease_softirq_start(void) {}
+void crossrelease_softirq_end(void) {}
+void crossrelease_work_start(void) {}
+#endif
+
 /*
  * Reinitialize a lock key - for cases where there is special locking or
  * special initialization of locks so that the validator gets the scope
diff --git a/include/linux/sched.h b/include/linux/sched.h
index e9c009d..e7bcae8 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1749,6 +1749,15 @@ struct task_struct {
 	struct held_lock held_locks[MAX_LOCK_DEPTH];
 	gfp_t lockdep_reclaim_gfp;
 #endif
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+#define MAX_XHLOCKS_NR 64UL
+	struct hist_lock *xhlocks; /* Crossrelease history locks */
+	int xhlock_idx;
+	int xhlock_idx_soft; /* For backing up at softirq entry */
+	int xhlock_idx_hard; /* For backing up at hardirq entry */
+	int xhlock_idx_nmi; /* For backing up at nmi entry */
+	unsigned int work_id;
+#endif
 #ifdef CONFIG_UBSAN
 	unsigned int in_ubsan;
 #endif
diff --git a/kernel/exit.c b/kernel/exit.c
index 3076f30..1bba1ab 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -54,6 +54,7 @@
 #include <linux/writeback.h>
 #include <linux/shm.h>
 #include <linux/kcov.h>
+#include <linux/vmalloc.h>
 
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
@@ -883,6 +884,14 @@ void __noreturn do_exit(long code)
 	exit_rcu();
 	TASKS_RCU(__srcu_read_unlock(&tasks_rcu_exit_srcu, tasks_rcu_i));
 
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+	if (tsk->xhlocks) {
+		void *tmp = tsk->xhlocks;
+		/* Disable crossrelease for current */
+		tsk->xhlocks = NULL;
+		vfree(tmp);
+	}
+#endif
 	do_task_dead();
 }
 EXPORT_SYMBOL_GPL(do_exit);
diff --git a/kernel/fork.c b/kernel/fork.c
index 997ac1d..1eda5cd 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -451,6 +451,13 @@ void __init fork_init(void)
 	for (i = 0; i < UCOUNT_COUNTS; i++) {
 		init_user_ns.ucount_max[i] = max_threads/2;
 	}
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+	/*
+	 * TODO: We need to make init_task also use crossrelease. Now,
+	 * just disable the feature for init_task.
+	 */
+	init_task.xhlocks = NULL;
+#endif
 }
 
 int __weak arch_dup_task_struct(struct task_struct *dst,
@@ -1611,6 +1618,14 @@ static __latent_entropy struct task_struct *copy_process(
 	p->lockdep_depth = 0; /* no locks held yet */
 	p->curr_chain_key = 0;
 	p->lockdep_recursion = 0;
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+	p->xhlock_idx = 0;
+	p->xhlock_idx_soft = 0;
+	p->xhlock_idx_hard = 0;
+	p->xhlock_idx_nmi = 0;
+	p->xhlocks = vzalloc(sizeof(struct hist_lock) * MAX_XHLOCKS_NR);
+	p->work_id = 0;
+#endif
 #endif
 
 #ifdef CONFIG_DEBUG_MUTEXES
@@ -1856,6 +1871,14 @@ static __latent_entropy struct task_struct *copy_process(
 bad_fork_cleanup_perf:
 	perf_event_free_task(p);
 bad_fork_cleanup_policy:
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+	if (p->xhlocks) {
+		void *tmp = p->xhlocks;
+		/* Diable crossrelease for current */
+		p->xhlocks = NULL;
+		vfree(tmp);
+	}
+#endif
 #ifdef CONFIG_NUMA
 	mpol_put(p->mempolicy);
 bad_fork_cleanup_threadgroup_lock:
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 75dc14a..0621b3e 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -717,6 +717,18 @@ static int count_matching_names(struct lock_class *new_class)
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
+static inline int lock_acquire_crosslock(struct held_lock *hlock) { return 0; }
+static inline int lock_release_crosslock(struct lockdep_map *lock) { return 0; }
+#endif
+
 /*
  * Register a lock's class in the hash-table, if the class is not present
  * yet. Otherwise we look it up. We cache the result in the lock object
@@ -1776,6 +1788,9 @@ static inline void inc_chains(void)
 		if (nest)
 			return 2;
 
+		if (cross_lock(prev->instance))
+			continue;
+
 		return print_deadlock_bug(curr, prev, next);
 	}
 	return 1;
@@ -1929,29 +1944,35 @@ static inline void inc_chains(void)
 		int distance = curr->lockdep_depth - depth + 1;
 		hlock = curr->held_locks + depth - 1;
 		/*
-		 * Only non-recursive-read entries get new dependencies
-		 * added:
+		 * Only non-crosslock entries get new dependencies added.
+		 * Crosslock entries will be added by commit later:
 		 */
-		if (hlock->read != 2 && hlock->check) {
-			if (!check_prev_add(curr, hlock, next,
-						distance, &trace, save))
-				return 0;
-
+		if (!cross_lock(hlock->instance)) {
 			/*
-			 * Stop saving stack_trace if save_trace() was
-			 * called at least once:
+			 * Only non-recursive-read entries get new dependencies
+			 * added:
 			 */
-			if (save && start_nr != nr_stack_trace_entries)
-				save = NULL;
+			if (hlock->read != 2 && hlock->check) {
+				if (!check_prev_add(curr, hlock, next,
+							distance, &trace, save))
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
+				if (save && start_nr != nr_stack_trace_entries)
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
@@ -3203,7 +3224,7 @@ static int mark_lock(struct task_struct *curr, struct held_lock *this,
 /*
  * Initialize a lock instance's lock-class mapping info:
  */
-void lockdep_init_map(struct lockdep_map *lock, const char *name,
+static void __lockdep_init_map(struct lockdep_map *lock, const char *name,
 		      struct lock_class_key *key, int subclass)
 {
 	int i;
@@ -3261,8 +3282,25 @@ void lockdep_init_map(struct lockdep_map *lock, const char *name,
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
 
@@ -3366,7 +3404,8 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 
 	class_idx = class - lock_classes + 1;
 
-	if (depth) {
+	/* TODO: nest_lock is not implemented for crosslock yet. */
+	if (depth && !cross_lock(lock)) {
 		hlock = curr->held_locks + depth - 1;
 		if (hlock->class_idx == class_idx && nest_lock) {
 			if (hlock->references)
@@ -3447,6 +3486,9 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 	if (!validate_chain(curr, lock, hlock, chain_head, chain_key))
 		return 0;
 
+	if (lock_acquire_crosslock(hlock))
+		return 1;
+
 	curr->curr_chain_key = chain_key;
 	curr->lockdep_depth++;
 	check_chain_key(curr);
@@ -3615,6 +3657,9 @@ static int match_held_lock(struct held_lock *hlock, struct lockdep_map *lock)
 	if (unlikely(!debug_locks))
 		return 0;
 
+	if (lock_release_crosslock(lock))
+		return 1;
+
 	depth = curr->lockdep_depth;
 	/*
 	 * So we're all set to release this lock.. wait what lock? We don't
@@ -4557,3 +4602,398 @@ void lockdep_rcu_suspicious(const char *file, const int line, const char *s)
 	dump_stack();
 }
 EXPORT_SYMBOL_GPL(lockdep_rcu_suspicious);
+
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+
+#define idx(t)			((t)->xhlock_idx)
+#define idx_prev(i)		((i) ? (i) - 1 : MAX_XHLOCKS_NR - 1)
+#define idx_next(i)		(((i) + 1) % MAX_XHLOCKS_NR)
+
+/* For easy access to xhlock */
+#define xhlock(t, i)		((t)->xhlocks + (i))
+#define xhlock_prev(t, l)	xhlock(t, idx_prev((l) - (t)->xhlocks))
+#define xhlock_curr(t)		xhlock(t, idx(t))
+#define xhlock_incr(t)		({idx(t) = idx_next(idx(t));})
+
+/*
+ * Whenever a crosslock is held, cross_gen_id will be increased.
+ */
+static atomic_t cross_gen_id; /* Can be wrapped */
+
+void crossrelease_hardirq_start(void)
+{
+	if (current->xhlocks) {
+		if (preempt_count() & NMI_MASK)
+			current->xhlock_idx_nmi = current->xhlock_idx;
+		else
+			current->xhlock_idx_hard = current->xhlock_idx;
+	}
+}
+
+void crossrelease_hardirq_end(void)
+{
+	if (current->xhlocks) {
+		if (preempt_count() & NMI_MASK)
+			current->xhlock_idx = current->xhlock_idx_nmi;
+		else
+			current->xhlock_idx = current->xhlock_idx_hard;
+	}
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
+ * Get a hist_lock from hist_lock ring buffer.
+ *
+ * Only access local task's data, so irq disable is only required.
+ */
+static struct hist_lock *alloc_xhlock(void)
+{
+	struct task_struct *curr = current;
+	struct hist_lock *xhlock = xhlock_curr(curr);
+
+	xhlock_incr(curr);
+	return xhlock;
+}
+
+/*
+ * Only access local task's data, so irq disable is only required.
+ */
+static void add_xhlock(struct held_lock *hlock, unsigned int prev_gen_id)
+{
+	struct hist_lock *xhlock;
+
+	xhlock = alloc_xhlock();
+
+	/* Initialize hist_lock's members */
+	xhlock->hlock = *hlock;
+	xhlock->nmi = !!(preempt_count() & NMI_MASK);
+	/*
+	 * prev_gen_id is used to skip adding dependency at commit step,
+	 * when the previous lock in held_locks can do that instead.
+	 */
+	xhlock->prev_gen_id = prev_gen_id;
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
+	/* In the case of nmi context */
+	if (preempt_count() & NMI_MASK) {
+		if (xhlock->nmi)
+			return 1;
+	/* In the case of hardirq context */
+	} else if (curr->hardirq_context) {
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
+	struct held_lock *prev;
+	struct held_lock *start;
+	unsigned int gen_id;
+	unsigned int gen_id_invalid;
+
+	if (!current->xhlocks || !depend_before(hlock))
+		return;
+
+	gen_id = (unsigned int)atomic_read(&cross_gen_id);
+	/*
+	 * gen_id_invalid must be too old to be valid. That means
+	 * current hlock should not be skipped but should be
+	 * considered at commit step.
+	 */
+	gen_id_invalid = gen_id - (UINT_MAX / 4);
+	start = current->held_locks;
+
+	for (prev = hlock - 1; prev >= start &&
+			!depend_before(prev); prev--);
+
+	if (prev < start)
+		add_xhlock(hlock, gen_id_invalid);
+	else if (prev->gen_id != gen_id)
+		add_xhlock(hlock, prev->gen_id);
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
+	if (!depend_after(hlock))
+		return 1;
+
+	if (!graph_lock())
+		return 0;
+
+	xlock = &((struct lockdep_map_cross *)hlock->instance)->xlock;
+
+	/*
+	 * When acquisitions for a xlock are overlapped, we use
+	 * a reference counter to handle it.
+	 */
+	if (atomic_inc_return(&xlock->ref) > 1)
+		goto unlock;
+
+	gen_id = (unsigned int)atomic_inc_return(&cross_gen_id);
+	xlock->hlock = *hlock;
+	xlock->hlock.gen_id = gen_id;
+unlock:
+	graph_unlock();
+	return 1;
+}
+
+/*
+ * return 0: Need to do normal acquire operation.
+ * return 1: Done. No more acquire ops is needed.
+ */
+static int lock_acquire_crosslock(struct held_lock *hlock)
+{
+	/*
+	 *	CONTEXT 1		CONTEXT 2
+	 *	---------		---------
+	 *	lock A (cross)
+	 *	X = atomic_inc_return()
+	 *	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ serialize
+	 *				Y = atomic_read_acquire()
+	 *				lock B
+	 *
+	 * atomic_read_acquire() is for ordering between this and all
+	 * following locks. This way, we ensure the order A -> B when
+	 * CONTEXT 2 can see that, Y is equal to or greater than X.
+	 *
+	 * Pairs with atomic_inc_return() in add_xlock().
+	 */
+	hlock->gen_id = (unsigned int)atomic_read_acquire(&cross_gen_id);
+
+	if (cross_lock(hlock->instance))
+		return add_xlock(hlock);
+
+	check_add_xhlock(hlock);
+	return 0;
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
+	struct task_struct *curr = current;
+	struct hist_lock *xhlock_c = xhlock_curr(curr);
+	struct hist_lock *xhlock = xhlock_c;
+
+	do {
+		xhlock = xhlock_prev(curr, xhlock);
+
+		if (!xhlock_used(xhlock))
+			break;
+
+		if (before(xhlock->hlock.gen_id, xlock->hlock.gen_id))
+			break;
+
+		if (same_context_xhlock(xhlock) &&
+		    before(xhlock->prev_gen_id, xlock->hlock.gen_id) &&
+		    !commit_xhlock(xlock, xhlock))
+			return 0;
+	} while (xhlock_c != xhlock);
+
+	return 1;
+}
+
+void lock_commit_crosslock(struct lockdep_map *lock)
+{
+	struct cross_lock *xlock;
+	unsigned long flags;
+
+	if (!current->xhlocks)
+		return;
+
+	if (unlikely(current->lockdep_recursion))
+		return;
+
+	raw_local_irq_save(flags);
+	check_flags(flags);
+	current->lockdep_recursion = 1;
+
+	if (unlikely(!debug_locks))
+		return;
+
+	if (!graph_lock())
+		return;
+
+	xlock = &((struct lockdep_map_cross *)lock)->xlock;
+	if (atomic_read(&xlock->ref) > 0 && !commit_xhlocks(xlock))
+		return;
+
+	graph_unlock();
+	current->lockdep_recursion = 0;
+	raw_local_irq_restore(flags);
+}
+EXPORT_SYMBOL_GPL(lock_commit_crosslock);
+
+/*
+ * return 0: Need to do normal release operation.
+ * return 1: Done. No more release ops is needed.
+ */
+static int lock_release_crosslock(struct lockdep_map *lock)
+{
+	if (cross_lock(lock)) {
+		atomic_dec(&((struct lockdep_map_cross *)lock)->xlock.ref);
+		return 1;
+	}
+	return 0;
+}
+
+static void cross_init(struct lockdep_map *lock, int cross)
+{
+	if (cross)
+		atomic_set(&((struct lockdep_map_cross *)lock)->xlock.ref, 0);
+
+	lock->cross = cross;
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
index a6c8db1..7890661 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1042,6 +1042,19 @@ config DEBUG_LOCK_ALLOC
 	 spin_lock_init()/mutex_init()/etc., or whether there is any lock
 	 held during task exit.
 
+config LOCKDEP_CROSSRELEASE
+	bool "Lock debugging: make lockdep work for crosslocks"
+	select LOCKDEP
+	select TRACE_IRQFLAGS
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
