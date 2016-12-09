Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id DB1516B0277
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 00:16:56 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id g186so17064257pgc.2
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 21:16:56 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 90si32022583plb.305.2016.12.08.21.16.35
        for <linux-mm@kvack.org>;
        Thu, 08 Dec 2016 21:16:35 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v4 07/15] lockdep: Implement crossrelease feature
Date: Fri,  9 Dec 2016 14:12:03 +0900
Message-Id: <1481260331-360-8-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

Crossrelease feature calls a lock 'crosslock' if it is releasable
in any context. For crosslock, all locks having been held in the
release context of the crosslock, until eventually the crosslock
will be released, have dependency with the crosslock.

Using crossrelease feature, we can detect deadlock possibility even
for lock_page(), wait_for_complete() and so on.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/irqflags.h |  12 +-
 include/linux/lockdep.h  | 122 +++++++++++
 include/linux/sched.h    |   5 +
 kernel/exit.c            |   9 +
 kernel/fork.c            |  20 ++
 kernel/locking/lockdep.c | 517 +++++++++++++++++++++++++++++++++++++++++++++--
 lib/Kconfig.debug        |  13 ++
 7 files changed, 682 insertions(+), 16 deletions(-)

diff --git a/include/linux/irqflags.h b/include/linux/irqflags.h
index 5dd1272..b1854fa 100644
--- a/include/linux/irqflags.h
+++ b/include/linux/irqflags.h
@@ -23,9 +23,17 @@
 # define trace_softirq_context(p)	((p)->softirq_context)
 # define trace_hardirqs_enabled(p)	((p)->hardirqs_enabled)
 # define trace_softirqs_enabled(p)	((p)->softirqs_enabled)
-# define trace_hardirq_enter()	do { current->hardirq_context++; } while (0)
+# define trace_hardirq_enter()		\
+do {					\
+	current->hardirq_context++;	\
+	crossrelease_hardirq_start();	\
+} while (0)
 # define trace_hardirq_exit()	do { current->hardirq_context--; } while (0)
-# define lockdep_softirq_enter()	do { current->softirq_context++; } while (0)
+# define lockdep_softirq_enter()	\
+do {					\
+	current->softirq_context++;	\
+	crossrelease_softirq_start();	\
+} while (0)
 # define lockdep_softirq_exit()	do { current->softirq_context--; } while (0)
 # define INIT_TRACE_IRQFLAGS	.softirqs_enabled = 1,
 #else
diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index eabe013..6b3708b 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -108,6 +108,12 @@ struct lock_class {
 	unsigned long			contention_point[LOCKSTAT_POINTS];
 	unsigned long			contending_point[LOCKSTAT_POINTS];
 #endif
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+	/*
+	 * Flag to indicate whether it's a crosslock or normal.
+	 */
+	int				cross;
+#endif
 };
 
 #ifdef CONFIG_LOCK_STAT
@@ -143,6 +149,9 @@ struct lock_class_stats lock_stats(struct lock_class *class);
 void clear_lock_stats(struct lock_class *class);
 #endif
 
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+struct cross_lock;
+#endif
 /*
  * Map the lock object (the lock instance) to the lock-class object.
  * This is embedded into specific lock instances:
@@ -155,6 +164,9 @@ struct lockdep_map {
 	int				cpu;
 	unsigned long			ip;
 #endif
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+	struct cross_lock		*xlock;
+#endif
 };
 
 static inline void lockdep_copy_map(struct lockdep_map *to,
@@ -258,7 +270,82 @@ struct held_lock {
 	unsigned int hardirqs_off:1;
 	unsigned int references:12;					/* 32 bits */
 	unsigned int pin_count;
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+	/*
+	 * This is used to find out the first plock among plocks having
+	 * been acquired since a crosslock was held. Crossrelease feature
+	 * uses chain cache between the crosslock and the first plock to
+	 * avoid building unnecessary dependencies, like how lockdep uses
+	 * a sort of chain cache for normal locks.
+	 */
+	unsigned int gen_id;
+#endif
+};
+
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+#define MAX_PLOCK_TRACE_ENTRIES		5
+
+/*
+ * This is for keeping locks waiting for commit to happen so that
+ * dependencies are actually built later at commit step.
+ *
+ * Every task_struct has an array of pend_lock. Each entiry will be
+ * added with a lock whenever lock_acquire() is called for normal lock.
+ */
+struct pend_lock {
+	/*
+	 * prev_gen_id is used to check whether any other hlock in the
+	 * current is already dealing with the xlock, with which commit
+	 * is performed. If so, this plock can be skipped.
+	 */
+	unsigned int		prev_gen_id;
+	/*
+	 * A kind of global timestamp increased and set when this plock
+	 * is inserted.
+	 */
+	unsigned int		gen_id;
+
+	int			hardirq_context;
+	int			softirq_context;
+
+	/*
+	 * Whenever irq happens, these are updated so that we can
+	 * distinguish each irq context uniquely.
+	 */
+	unsigned int		hardirq_id;
+	unsigned int		softirq_id;
+
+	/*
+	 * Seperate stack_trace data. This will be used at commit step.
+	 */
+	struct stack_trace	trace;
+	unsigned long		trace_entries[MAX_PLOCK_TRACE_ENTRIES];
+
+	/*
+	 * Seperate hlock instance. This will be used at commit step.
+	 */
+	struct held_lock	hlock;
+};
+
+/*
+ * One cross_lock per one lockdep_map.
+ *
+ * To initialize a lock as crosslock, lockdep_init_map_crosslock() should
+ * be used instead of lockdep_init_map(), where the pointer of cross_lock
+ * instance should be passed as a parameter.
+ */
+struct cross_lock {
+	unsigned int		gen_id;
+	struct list_head	xlock_entry;
+
+	/*
+	 * Seperate hlock instance. This will be used at commit step.
+	 */
+	struct held_lock	hlock;
+
+	int			ref; /* reference count */
 };
+#endif
 
 /*
  * Initialization, self-test and debugging-output methods:
@@ -281,6 +368,37 @@ extern void lockdep_on(void);
 extern void lockdep_init_map(struct lockdep_map *lock, const char *name,
 			     struct lock_class_key *key, int subclass);
 
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+extern void lockdep_init_map_crosslock(struct lockdep_map *lock,
+				       struct cross_lock *xlock,
+				       const char *name,
+				       struct lock_class_key *key,
+				       int subclass);
+extern void lock_commit_crosslock(struct lockdep_map *lock);
+
+/*
+ * What we essencially have to initialize is 'ref'.
+ * Other members will be initialized in add_xlock().
+ */
+#define STATIC_CROSS_LOCK_INIT() \
+	{ .ref = 0,}
+
+/*
+ * Note that _name and _xlock must not be NULL.
+ */
+#define STATIC_CROSS_LOCKDEP_MAP_INIT(_name, _key, _xlock) \
+	{ .name = (_name), .key = (void *)(_key), .xlock = (_xlock), }
+
+/*
+ * To initialize a lockdep_map statically use this macro.
+ * Note that _name must not be NULL.
+ */
+#define STATIC_LOCKDEP_MAP_INIT(_name, _key) \
+	{ .name = (_name), .key = (void *)(_key), .xlock = NULL, }
+
+extern void crossrelease_hardirq_start(void);
+extern void crossrelease_softirq_start(void);
+#else
 /*
  * To initialize a lockdep_map statically use this macro.
  * Note that _name must not be NULL.
@@ -288,6 +406,10 @@ extern void lockdep_init_map(struct lockdep_map *lock, const char *name,
 #define STATIC_LOCKDEP_MAP_INIT(_name, _key) \
 	{ .name = (_name), .key = (void *)(_key), }
 
+void crossrelease_hardirq_start(void) {}
+void crossrelease_softirq_start(void) {}
+#endif
+
 /*
  * Reinitialize a lock key - for cases where there is special locking or
  * special initialization of locks so that the validator gets the scope
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 253538f..592ee368 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1719,6 +1719,11 @@ struct task_struct {
 	struct held_lock held_locks[MAX_LOCK_DEPTH];
 	gfp_t lockdep_reclaim_gfp;
 #endif
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+#define MAX_PLOCKS_NR 1024UL
+	int plock_index;
+	struct pend_lock *plocks;
+#endif
 #ifdef CONFIG_UBSAN
 	unsigned int in_ubsan;
 #endif
diff --git a/kernel/exit.c b/kernel/exit.c
index 9e6e135..9c69995 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -54,6 +54,7 @@
 #include <linux/writeback.h>
 #include <linux/shm.h>
 #include <linux/kcov.h>
+#include <linux/vmalloc.h>
 
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
@@ -822,6 +823,14 @@ void do_exit(long code)
 	smp_mb();
 	raw_spin_unlock_wait(&tsk->pi_lock);
 
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+	if (tsk->plocks) {
+		void *tmp = tsk->plocks;
+		/* Disable crossrelease operation for current */
+		tsk->plocks = NULL;
+		vfree(tmp);
+	}
+#endif
 	/* causes final put_task_struct in finish_task_switch(). */
 	tsk->state = TASK_DEAD;
 	tsk->flags |= PF_NOFREEZE;	/* tell freezer to ignore us */
diff --git a/kernel/fork.c b/kernel/fork.c
index 4a7ec0c..91ab81b 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -323,6 +323,14 @@ void __init fork_init(void)
 	init_task.signal->rlim[RLIMIT_NPROC].rlim_max = max_threads/2;
 	init_task.signal->rlim[RLIMIT_SIGPENDING] =
 		init_task.signal->rlim[RLIMIT_NPROC];
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+	/*
+	 * TODO: We need to make init_task also use crossrelease feature.
+	 * For simplicity, now just disable the feature for init_task.
+	 */
+	init_task.plock_index = 0;
+	init_task.plocks = NULL;
+#endif
 }
 
 int __weak arch_dup_task_struct(struct task_struct *dst,
@@ -1443,6 +1451,10 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	p->lockdep_depth = 0; /* no locks held yet */
 	p->curr_chain_key = 0;
 	p->lockdep_recursion = 0;
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+	p->plock_index = 0;
+	p->plocks = vzalloc(sizeof(struct pend_lock) * MAX_PLOCKS_NR);
+#endif
 #endif
 
 #ifdef CONFIG_DEBUG_MUTEXES
@@ -1686,6 +1698,14 @@ bad_fork_cleanup_audit:
 bad_fork_cleanup_perf:
 	perf_event_free_task(p);
 bad_fork_cleanup_policy:
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+	if (p->plocks) {
+		void *tmp = p->plocks;
+		/* Diable crossrelease operation for current */
+		p->plocks = NULL;
+		vfree(tmp);
+	}
+#endif
 #ifdef CONFIG_NUMA
 	mpol_put(p->mempolicy);
 bad_fork_cleanup_threadgroup_lock:
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 11580ec..2c8b2c1 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -711,6 +711,20 @@ look_up_lock_class(struct lockdep_map *lock, unsigned int subclass)
 	return NULL;
 }
 
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+static int cross_class(struct lock_class *class);
+static void init_map_noncrosslock(struct lockdep_map *lock);
+static void init_class_crosslock(struct lock_class *class, int cross);
+static int lock_acquire_crosslock(struct held_lock *hlock);
+static int lock_release_crosslock(struct lockdep_map *lock);
+#else
+static inline int cross_class(struct lock_class *class) { return 0; }
+static inline void init_map_noncrosslock(struct lockdep_map *lock) {}
+static inline void init_class_crosslock(struct lock_class *class, int cross) {}
+static inline int lock_acquire_crosslock(struct held_lock *hlock) { return 0; }
+static inline int lock_release_crosslock(struct lockdep_map *lock) { return 0; }
+#endif
+
 /*
  * Register a lock's class in the hash-table, if the class is not present
  * yet. Otherwise we look it up. We cache the result in the lock object
@@ -779,6 +793,7 @@ register_lock_class(struct lockdep_map *lock, unsigned int subclass, int force)
 	INIT_LIST_HEAD(&class->locks_before);
 	INIT_LIST_HEAD(&class->locks_after);
 	class->name_version = count_matching_names(class);
+	init_class_crosslock(class, !!lock->xlock);
 	/*
 	 * We use RCU's safe list-add method to make
 	 * parallel walking of the hash-list safe:
@@ -1771,6 +1786,9 @@ check_deadlock(struct task_struct *curr, struct held_lock *next,
 		if (nest)
 			return 2;
 
+		if (cross_class(hlock_class(prev)))
+			continue;
+
 		return print_deadlock_bug(curr, prev, next);
 	}
 	return 1;
@@ -1936,21 +1954,27 @@ check_prevs_add(struct task_struct *curr, struct held_lock *next)
 		int distance = curr->lockdep_depth - depth + 1;
 		hlock = curr->held_locks + depth - 1;
 		/*
-		 * Only non-recursive-read entries get new dependencies
-		 * added:
+		 * Only non-crosslock entries get new dependencies added.
+		 * Crosslock entries will be added by commit later:
 		 */
-		if (hlock->read != 2 && hlock->check) {
-			if (!check_prev_add(curr, hlock, next, distance,
-						&stack_saved, NULL))
-				return 0;
+		if (!cross_class(hlock_class(hlock))) {
 			/*
-			 * Stop after the first non-trylock entry,
-			 * as non-trylock entries have added their
-			 * own direct dependencies already, so this
-			 * lock is connected to them indirectly:
+			 * Only non-recursive-read entries get new dependencies
+			 * added:
 			 */
-			if (!hlock->trylock)
-				break;
+			if (hlock->read != 2 && hlock->check) {
+				if (!check_prev_add(curr, hlock, next, distance,
+							&stack_saved, NULL))
+					return 0;
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
@@ -3184,7 +3208,7 @@ static int mark_lock(struct task_struct *curr, struct held_lock *this,
 /*
  * Initialize a lock instance's lock-class mapping info:
  */
-void lockdep_init_map(struct lockdep_map *lock, const char *name,
+static void __lockdep_init_map(struct lockdep_map *lock, const char *name,
 		      struct lock_class_key *key, int subclass)
 {
 	int i;
@@ -3242,8 +3266,27 @@ void lockdep_init_map(struct lockdep_map *lock, const char *name,
 		raw_local_irq_restore(flags);
 	}
 }
+
+void lockdep_init_map(struct lockdep_map *lock, const char *name,
+		      struct lock_class_key *key, int subclass)
+{
+	init_map_noncrosslock(lock);
+	__lockdep_init_map(lock, name, key, subclass);
+}
 EXPORT_SYMBOL_GPL(lockdep_init_map);
 
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+static void init_map_crosslock(struct lockdep_map *lock, struct cross_lock *xlock);
+void lockdep_init_map_crosslock(struct lockdep_map *lock,
+		      struct cross_lock *xlock, const char *name,
+		      struct lock_class_key *key, int subclass)
+{
+	init_map_crosslock(lock, xlock);
+	__lockdep_init_map(lock, name, key, subclass);
+}
+EXPORT_SYMBOL_GPL(lockdep_init_map_crosslock);
+#endif
+
 struct lock_class_key __lockdep_no_validate__;
 EXPORT_SYMBOL_GPL(__lockdep_no_validate__);
 
@@ -3347,7 +3390,8 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 
 	class_idx = class - lock_classes + 1;
 
-	if (depth) {
+	/* TODO: nest_lock is not implemented for crosslock yet. */
+	if (depth && !cross_class(class)) {
 		hlock = curr->held_locks + depth - 1;
 		if (hlock->class_idx == class_idx && nest_lock) {
 			if (hlock->references)
@@ -3428,6 +3472,9 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 	if (!validate_chain(curr, lock, hlock, chain_head, chain_key))
 		return 0;
 
+	if (lock_acquire_crosslock(hlock))
+		return 1;
+
 	curr->curr_chain_key = chain_key;
 	curr->lockdep_depth++;
 	check_chain_key(curr);
@@ -3596,6 +3643,9 @@ __lock_release(struct lockdep_map *lock, int nested, unsigned long ip)
 	if (unlikely(!debug_locks))
 		return 0;
 
+	if (lock_release_crosslock(lock))
+		return 1;
+
 	depth = curr->lockdep_depth;
 	/*
 	 * So we're all set to release this lock.. wait what lock? We don't
@@ -4538,3 +4588,442 @@ void lockdep_rcu_suspicious(const char *file, const int line, const char *s)
 	dump_stack();
 }
 EXPORT_SYMBOL_GPL(lockdep_rcu_suspicious);
+
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+
+static LIST_HEAD(xlocks_head);
+
+/*
+ * Whenever a crosslock is held, cross_gen_id will be increased.
+ */
+static atomic_t cross_gen_id; /* Can be wrapped */
+
+/* Implement a circular buffer - for internal use */
+#define cir_p(n, i)		((i) ? (i) - 1 : (n) - 1)
+#define cir_n(n, i)		((i) == (n) - 1 ? 0 : (i) + 1)
+#define p_idx_p(i)		cir_p(MAX_PLOCKS_NR, i)
+#define p_idx_n(i)		cir_n(MAX_PLOCKS_NR, i)
+#define p_idx(t)		((t)->plock_index)
+
+/* For easy access to plock */
+#define plock(t, i)		((t)->plocks + (i))
+#define plock_prev(t, p)	plock(t, p_idx_p((p) - (t)->plocks))
+#define plock_curr(t)		plock(t, p_idx(t))
+#define plock_incr(t)		({p_idx(t) = p_idx_n(p_idx(t));})
+
+/*
+ * Crossrelease needs to distinguish each hardirq context.
+ */
+static DEFINE_PER_CPU(unsigned int, hardirq_id);
+void crossrelease_hardirq_start(void)
+{
+	per_cpu(hardirq_id, smp_processor_id())++;
+}
+
+/*
+ * Crossrelease needs to distinguish each softirq context.
+ */
+static DEFINE_PER_CPU(unsigned int, softirq_id);
+void crossrelease_softirq_start(void)
+{
+	per_cpu(softirq_id, smp_processor_id())++;
+}
+
+static int cross_class(struct lock_class *class)
+{
+	if (!class)
+		return 0;
+
+	return class->cross;
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
+static inline struct lock_class *plock_class(struct pend_lock *plock)
+{
+	return hlock_class(&plock->hlock);
+}
+
+static inline struct lock_class *xlock_class(struct cross_lock *xlock)
+{
+	return hlock_class(&xlock->hlock);
+}
+
+/*
+ * To find the earlist crosslock among all crosslocks not released yet.
+ */
+static unsigned int gen_id_begin(void)
+{
+	struct cross_lock *xlock = list_entry_rcu(xlocks_head.next,
+			struct cross_lock, xlock_entry);
+
+	/* If empty */
+	if (&xlock->xlock_entry == &xlocks_head)
+		return (unsigned int)atomic_read(&cross_gen_id) + 1;
+
+	return READ_ONCE(xlock->gen_id);
+}
+
+/*
+ * To find the latest crosslock among all crosslocks already released.
+ */
+static inline unsigned int gen_id_done(void)
+{
+	return gen_id_begin() - 1;
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
+ * Check if the plock is used at least once after initializaion.
+ * Remind pend_lock is implemented as a ring buffer.
+ */
+static inline int plock_used(struct pend_lock *plock)
+{
+	/*
+	 * plock->hlock.instance must be !NULL if it's used.
+	 */
+	return !!plock->hlock.instance;
+}
+
+/*
+ * Get a pend_lock from pend_lock ring buffer.
+ *
+ * No contention. Irq disable is only required.
+ */
+static struct pend_lock *alloc_plock(unsigned int gen_id_done)
+{
+	struct task_struct *curr = current;
+	struct pend_lock *plock = plock_curr(curr);
+
+	if (plock_used(plock) && before(gen_id_done, plock->gen_id)) {
+		printk_once("crossrelease: plock pool is full.\n");
+		return NULL;
+	}
+
+	plock_incr(curr);
+	return plock;
+}
+
+/*
+ * No contention. Irq disable is only required.
+ */
+static void add_plock(struct held_lock *hlock, unsigned int prev_gen_id,
+		unsigned int gen_id_done)
+{
+	struct task_struct *curr = current;
+	int cpu = smp_processor_id();
+	struct pend_lock *plock;
+	/*
+	 *	CONTEXT 1		CONTEXT 2
+	 *	---------		---------
+	 *	acquire A (cross)
+	 *	X = atomic_inc_return()
+	 *	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ serialize
+	 *				Y = atomic_read_acquire()
+	 *				acquire B
+	 *				acquire C
+	 *
+	 * For ordering between this and all following LOCKs.
+	 * This way we ensure the order A -> B -> C when CONTEXT 2
+	 * can see Y is equal to or greater than X.
+	 *
+	 * Pairs with atomic_inc_return() in add_xlock().
+	 */
+	unsigned int gen_id = (unsigned int)atomic_read_acquire(&cross_gen_id);
+
+	plock = alloc_plock(gen_id_done);
+
+	if (plock) {
+		/* Initialize pend_lock's members here */
+		memcpy(&plock->hlock, hlock, sizeof(struct held_lock));
+		plock->prev_gen_id = prev_gen_id;
+		plock->gen_id = gen_id;
+		plock->hardirq_context = curr->hardirq_context;
+		plock->softirq_context = curr->softirq_context;
+		plock->hardirq_id = per_cpu(hardirq_id, cpu);
+		plock->softirq_id = per_cpu(softirq_id, cpu);
+
+		plock->trace.nr_entries = 0;
+		plock->trace.max_entries = MAX_PLOCK_TRACE_ENTRIES;
+		plock->trace.entries = plock->trace_entries;
+		plock->trace.skip = 3;
+		save_stack_trace(&plock->trace);
+	}
+}
+
+/*
+ * No contention. Irq disable is only required.
+ */
+static int same_context_plock(struct pend_lock *plock)
+{
+	struct task_struct *curr = current;
+	int cpu = smp_processor_id();
+
+	/* In the case of hardirq context */
+	if (curr->hardirq_context) {
+		if (plock->hardirq_id != per_cpu(hardirq_id, cpu) ||
+		    plock->hardirq_context != curr->hardirq_context)
+			return 0;
+	/* In the case of softriq context */
+	} else if (curr->softirq_context) {
+		if (plock->softirq_id != per_cpu(softirq_id, cpu) ||
+		    plock->softirq_context != curr->softirq_context)
+			return 0;
+	/* In the case of process context */
+	} else {
+		if (plock->hardirq_context != 0 ||
+		    plock->softirq_context != 0)
+			return 0;
+	}
+	return 1;
+}
+
+/*
+ * Called from lock_acquire() in case of non-crosslock. This should be
+ * lockless if possible.
+ */
+static void check_add_plock(struct held_lock *hlock)
+{
+	struct held_lock *prev;
+	struct held_lock *start;
+	struct cross_lock *xlock;
+	struct lock_chain *chain;
+	unsigned int id;
+	unsigned int gen_id;
+	unsigned int gen_id_e;
+	u64 chain_key;
+
+	if (!current->plocks || !depend_before(hlock))
+		return;
+
+	gen_id = (unsigned int)atomic_read(&cross_gen_id);
+	gen_id_e = gen_id_done();
+	start = current->held_locks;
+
+	list_for_each_entry_rcu(xlock, &xlocks_head, xlock_entry) {
+		id = xlock_class(xlock) - lock_classes;
+		chain_key = iterate_chain_key((u64)0, id);
+		id = hlock_class(hlock) - lock_classes;
+		chain_key = iterate_chain_key(chain_key, id);
+		chain = lookup_chain_cache(chain_key);
+
+		if (!chain) {
+			for (prev = hlock - 1; prev >= start &&
+			     !depend_before(prev); prev--);
+
+			if (prev < start)
+				add_plock(hlock, gen_id_e, gen_id_e);
+			else if (prev->gen_id != gen_id)
+				add_plock(hlock, prev->gen_id, gen_id_e);
+
+			break;
+		}
+	}
+}
+
+/*
+ * This will be called when lock_acquire() is called for crosslock.
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
+	xlock = hlock->instance->xlock;
+	if (!xlock)
+		goto unlock;
+
+	if (xlock->ref++)
+		goto unlock;
+
+	/*
+	 * We assign class_idx here redundantly even though following
+	 * memcpy will cover it, in order to ensure a rcu reader can
+	 * access the class_idx atomically without lock.
+	 *
+	 * Here we assume setting a word-sized variable is atomic.
+	 */
+	xlock->hlock.class_idx = hlock->class_idx;
+	gen_id = (unsigned int)atomic_inc_return(&cross_gen_id);
+	WRITE_ONCE(xlock->gen_id, gen_id);
+	memcpy(&xlock->hlock, hlock, sizeof(struct held_lock));
+	INIT_LIST_HEAD(&xlock->xlock_entry);
+	list_add_tail_rcu(&xlock->xlock_entry, &xlocks_head);
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
+	unsigned int gen_id = (unsigned int)atomic_read(&cross_gen_id);
+
+	hlock->gen_id = gen_id;
+
+	if (cross_class(hlock_class(hlock)))
+		return add_xlock(hlock);
+
+	check_add_plock(hlock);
+	return 0;
+}
+
+static int commit_plock(struct cross_lock *xlock, struct pend_lock *plock)
+{
+	unsigned int xid, pid;
+	u64 chain_key;
+
+	xid = xlock_class(xlock) - lock_classes;
+	chain_key = iterate_chain_key((u64)0, xid);
+	pid = plock_class(plock) - lock_classes;
+	chain_key = iterate_chain_key(chain_key, pid);
+
+	if (lookup_chain_cache(chain_key))
+		return 1;
+
+	if (!add_chain_cache_classes(xid, pid, plock->hlock.irq_context,
+				chain_key))
+		return 0;
+
+	if (!save_trace(&plock->trace, 1))
+		return 0;
+
+	if (!check_prev_add(current, &xlock->hlock, &plock->hlock, 1,
+			    NULL, &plock->trace))
+		return 0;
+
+	return 1;
+}
+
+static int commit_plocks(struct cross_lock *xlock)
+{
+	struct task_struct *curr = current;
+	struct pend_lock *plock_c = plock_curr(curr);
+	struct pend_lock *plock = plock_c;
+
+	do {
+		plock = plock_prev(curr, plock);
+
+		if (!plock_used(plock))
+			break;
+
+		if (before(plock->gen_id, xlock->gen_id))
+			break;
+
+		if (same_context_plock(plock) &&
+		    before(plock->prev_gen_id, xlock->gen_id) &&
+		    !commit_plock(xlock, plock))
+			return 0;
+	} while (plock_c != plock);
+
+	return 1;
+}
+
+/*
+ * Commit function.
+ */
+void lock_commit_crosslock(struct lockdep_map *lock)
+{
+	struct cross_lock *xlock;
+	unsigned long flags;
+
+	if (!current->plocks)
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
+	xlock = lock->xlock;
+	if (xlock && xlock->ref > 0 && !commit_plocks(xlock))
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
+	struct cross_lock *xlock;
+
+	if (!graph_lock())
+		return 0;
+
+	xlock = lock->xlock;
+	if (xlock && !--xlock->ref)
+		list_del_rcu(&xlock->xlock_entry);
+
+	graph_unlock();
+	return !!xlock;
+}
+
+static void init_map_noncrosslock(struct lockdep_map *lock)
+{
+	lock->xlock = NULL;
+}
+
+static void init_map_crosslock(struct lockdep_map *lock, struct cross_lock *xlock)
+{
+	unsigned long flags;
+
+	BUG_ON(!lock || !xlock);
+
+	raw_local_irq_save(flags);
+	if (graph_lock()) {
+		memset(xlock, 0x0, sizeof(struct cross_lock));
+		lock->xlock = xlock;
+		graph_unlock();
+	}
+	raw_local_irq_restore(flags);
+}
+
+static void init_class_crosslock(struct lock_class *class, int cross)
+{
+	class->cross = cross;
+}
+#endif
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index b9cfdbf..ef9ca8d 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1027,6 +1027,19 @@ config DEBUG_LOCK_ALLOC
 	 spin_lock_init()/mutex_init()/etc., or whether there is any lock
 	 held during task exit.
 
+config LOCKDEP_CROSSRELEASE
+	bool "Lock debugging: allow other context to unlock a lock"
+	depends on TRACE_IRQFLAGS_SUPPORT && STACKTRACE_SUPPORT && LOCKDEP_SUPPORT
+	select LOCKDEP
+	select TRACE_IRQFLAGS
+	default n
+	help
+	 This allows any context to unlock a lock held by another context.
+	 Normally a lock must be unlocked by the context holding the lock.
+	 However, relexing this constraint helps locks like (un)lock_page()
+	 or wait_for_complete() can use lock correctness detector using
+	 lockdep.
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
