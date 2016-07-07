Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2608D6B0269
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 05:32:24 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id fq2so22698787obb.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:32:24 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id a2si697563ith.102.2016.07.07.02.32.16
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 02:32:18 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [RFC v2 05/13] lockdep: Implement crossrelease feature
Date: Thu,  7 Jul 2016 18:29:55 +0900
Message-Id: <1467883803-29132-6-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
References: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, npiggin@kernel.dk, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Crossrelease feature calls a lock "crosslock" if it is releasable
by a different context from the context which held the lock. For
crosslock, all locks having been held in the context unlocking the
crosslock, until eventually the crosslock will be unlocked, have
dependency with the crosslock.

Using crossrelease feature, we can detect deadlock possibility even
for lock_page(), wait_for_complete() and so on.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/irqflags.h |  16 +-
 include/linux/lockdep.h  | 139 +++++++++++
 include/linux/sched.h    |   5 +
 kernel/fork.c            |   4 +
 kernel/locking/lockdep.c | 632 +++++++++++++++++++++++++++++++++++++++++++++--
 lib/Kconfig.debug        |  13 +
 6 files changed, 791 insertions(+), 18 deletions(-)

diff --git a/include/linux/irqflags.h b/include/linux/irqflags.h
index 5dd1272..83eebe1 100644
--- a/include/linux/irqflags.h
+++ b/include/linux/irqflags.h
@@ -23,10 +23,18 @@
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
+# define trace_hardirq_exit()		do { current->hardirq_context--; } while (0)
+# define lockdep_softirq_enter()	\
+do {					\
+	current->softirq_context++;	\
+	crossrelease_softirq_start();	\
+} while (0)
+# define lockdep_softirq_exit()		do { current->softirq_context--; } while (0)
 # define INIT_TRACE_IRQFLAGS	.softirqs_enabled = 1,
 #else
 # define trace_hardirqs_on()		do { } while (0)
diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index 4dca42f..1bf513e 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -108,6 +108,19 @@ struct lock_class {
 	unsigned long			contention_point[LOCKSTAT_POINTS];
 	unsigned long			contending_point[LOCKSTAT_POINTS];
 #endif
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+	/*
+	 * A flag to check if this lock class is releasable in
+	 * a differnet context from the context acquiring it.
+	 */
+	int				crosslock;
+
+	/*
+	 * When building a dependency chain, this help any classes
+	 * already established the chain can be skipped.
+	 */
+	unsigned int			skip_gen_id;
+#endif
 };
 
 #ifdef CONFIG_LOCK_STAT
@@ -143,6 +156,9 @@ struct lock_class_stats lock_stats(struct lock_class *class);
 void clear_lock_stats(struct lock_class *class);
 #endif
 
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+struct cross_lock;
+#endif
 /*
  * Map the lock object (the lock instance) to the lock-class object.
  * This is embedded into specific lock instances:
@@ -155,6 +171,15 @@ struct lockdep_map {
 	int				cpu;
 	unsigned long			ip;
 #endif
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+	struct cross_lock		*xlock;
+
+	/*
+	 * A flag to check if this lockdep_map is releasable in
+	 * a differnet context from the context acquiring it.
+	 */
+	int				cross;
+#endif
 };
 
 static inline void lockdep_copy_map(struct lockdep_map *to,
@@ -256,8 +281,90 @@ struct held_lock {
 	unsigned int hardirqs_off:1;
 	unsigned int references:12;					/* 32 bits */
 	unsigned int pin_count;
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+	/*
+	 * This is used to find out the first lock acquired since
+	 * a crosslock was held. In the crossrelease feature, we
+	 * build and use a dependency chain between the crosslock
+	 * and the first normal(non-crosslock) lock acquired
+	 * since the crosslock was held.
+	 */
+	unsigned int gen_id;
+#endif
 };
 
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+#define MAX_PLOCK_TRACE_ENTRIES		5
+
+/*
+ * This is for keeping locks waiting to commit those
+ * so that an actual dependency chain is built, when
+ * commiting a crosslock.
+ *
+ * Every task_struct has an array of this pending lock
+ * to keep those locks. These pending locks will be
+ * added whenever lock_acquire() is called for
+ * normal(non-crosslock) lock and will be
+ * flushed(committed) at proper time.
+ */
+struct pend_lock {
+	/*
+	 * This is used to find out the first lock acquired since
+	 * a crosslock was held. In the crossrelease feature, we
+	 * build and use a dependency chain between the crosslock
+	 * and the first normal(non-crosslock) lock acquired
+	 * since the crosslock was held.
+	 */
+	unsigned int		prev_gen_id;
+	unsigned int		gen_id;
+
+	int			hardirq_context;
+	int			softirq_context;
+
+	/*
+	 * Whenever irq occures, these ids will be updated so that
+	 * we can distinguish each irq context uniquely.
+	 */
+	unsigned int		hardirq_id;
+	unsigned int		softirq_id;
+
+	/*
+	 * Seperated stack_trace data. This will be used when
+	 * building a dependency chain for a crosslock, say,
+	 * commit.
+	 */
+	struct stack_trace	trace;
+	unsigned long		trace_entries[MAX_PLOCK_TRACE_ENTRIES];
+
+	/*
+	 * Seperated hlock instance. This will be used when
+	 * building a dependency chain for a crosslock, say,
+	 * commit.
+	 */
+	struct held_lock	hlock;
+};
+
+/*
+ * One cross_lock per one lockdep_map. For crosslock,
+ * lockdep_init_map_crosslock() should be used instead of
+ * lockdep_init_map(), where the pointer of this cross_lock
+ * instance should be passed as a parameter.
+ */
+struct cross_lock {
+	unsigned int		gen_id;
+	struct list_head	xlock_entry;
+
+	/*
+	 * Seperated hlock instance. This will be used when
+	 * building a dependency chain for a crosslock, say,
+	 * commit.
+	 */
+	struct held_lock	hlock;
+
+	int			ref; /* reference count */
+};
+#endif
+
 /*
  * Initialization, self-test and debugging-output methods:
  */
@@ -280,6 +387,34 @@ extern void lockdep_on(void);
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
+ * A member which we essencially have to initialize is ref.
+ * Other members will be initialized in add_xlock().
+ */
+#define STATIC_CROSS_LOCK_INIT() \
+	{ .ref = 0,}
+
+#define STATIC_CROSS_LOCKDEP_MAP_INIT(_name, _key, _xlock) \
+	{ .name = (_name), .key = (void *)(_key), .xlock = (_xlock), .cross = 1, }
+
+/*
+ * To initialize a lockdep_map statically use this macro.
+ * Note that _name must not be NULL.
+ */
+#define STATIC_LOCKDEP_MAP_INIT(_name, _key) \
+	{ .name = (_name), .key = (void *)(_key), .xlock = NULL, .cross = 0, }
+
+extern void crossrelease_hardirq_start(void);
+extern void crossrelease_softirq_start(void);
+#else
 /*
  * To initialize a lockdep_map statically use this macro.
  * Note that _name must not be NULL.
@@ -287,6 +422,10 @@ extern void lockdep_init_map(struct lockdep_map *lock, const char *name,
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
index a10494a..6e45761 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1644,6 +1644,11 @@ struct task_struct {
 	struct held_lock held_locks[MAX_LOCK_DEPTH];
 	gfp_t lockdep_reclaim_gfp;
 #endif
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+#define MAX_PLOCKS_NR 1024UL
+	int plock_index;
+	struct pend_lock plocks[MAX_PLOCKS_NR];
+#endif
 #ifdef CONFIG_UBSAN
 	unsigned int in_ubsan;
 #endif
diff --git a/kernel/fork.c b/kernel/fork.c
index 2e391c7..eb18c47 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1404,6 +1404,10 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	p->lockdep_depth = 0; /* no locks held yet */
 	p->curr_chain_key = 0;
 	p->lockdep_recursion = 0;
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+	p->plock_index = 0;
+	memset(p->plocks, 0x0, sizeof(struct pend_lock) * MAX_PLOCKS_NR);
+#endif
 #endif
 
 #ifdef CONFIG_DEBUG_MUTEXES
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index b03014b..12903f9 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -739,6 +739,20 @@ look_up_lock_class(struct lockdep_map *lock, unsigned int subclass)
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
@@ -807,6 +821,7 @@ register_lock_class(struct lockdep_map *lock, unsigned int subclass, int force)
 	INIT_LIST_HEAD(&class->locks_before);
 	INIT_LIST_HEAD(&class->locks_after);
 	class->name_version = count_matching_names(class);
+	init_class_crosslock(class, lock->cross);
 	/*
 	 * We use RCU's safe list-add method to make
 	 * parallel walking of the hash-list safe:
@@ -1799,6 +1814,9 @@ check_deadlock(struct task_struct *curr, struct held_lock *next,
 		if (nest)
 			return 2;
 
+		if (cross_class(hlock_class(prev)))
+			continue;
+
 		return print_deadlock_bug(curr, prev, next);
 	}
 	return 1;
@@ -1964,21 +1982,27 @@ check_prevs_add(struct task_struct *curr, struct held_lock *next)
 		int distance = curr->lockdep_depth - depth + 1;
 		hlock = curr->held_locks + depth - 1;
 		/*
-		 * Only non-recursive-read entries get new dependencies
-		 * added:
+		 * Only non-crosslock entries get new dependencies added.
+		 * Crosslock entries will be added by commiting later:
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
@@ -3064,7 +3088,7 @@ static int mark_lock(struct task_struct *curr, struct held_lock *this,
 /*
  * Initialize a lock instance's lock-class mapping info:
  */
-void lockdep_init_map(struct lockdep_map *lock, const char *name,
+static void __lockdep_init_map(struct lockdep_map *lock, const char *name,
 		      struct lock_class_key *key, int subclass)
 {
 	int i;
@@ -3122,8 +3146,27 @@ void lockdep_init_map(struct lockdep_map *lock, const char *name,
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
 
@@ -3227,7 +3270,8 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 
 	class_idx = class - lock_classes + 1;
 
-	if (depth) {
+	/* TODO: nest_lock is not implemented for crosslock yet. */
+	if (depth && !cross_class(class)) {
 		hlock = curr->held_locks + depth - 1;
 		if (hlock->class_idx == class_idx && nest_lock) {
 			if (hlock->references)
@@ -3308,6 +3352,9 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 	if (!validate_chain(curr, lock, hlock, chain_head, chain_key))
 		return 0;
 
+	if (lock_acquire_crosslock(hlock))
+		return 1;
+
 	curr->curr_chain_key = chain_key;
 	curr->lockdep_depth++;
 	check_chain_key(curr);
@@ -3476,6 +3523,9 @@ __lock_release(struct lockdep_map *lock, int nested, unsigned long ip)
 	if (unlikely(!debug_locks))
 		return 0;
 
+	if (lock_release_crosslock(lock))
+		return 1;
+
 	depth = curr->lockdep_depth;
 	/*
 	 * So we're all set to release this lock.. wait what lock? We don't
@@ -4396,3 +4446,557 @@ void lockdep_rcu_suspicious(const char *file, const int line, const char *s)
 	dump_stack();
 }
 EXPORT_SYMBOL_GPL(lockdep_rcu_suspicious);
+
+#ifdef CONFIG_LOCKDEP_CROSSRELEASE
+
+/*
+ * Crossrelease feature call a lock which is releasable by a
+ * different context from the context having acquired the lock,
+ * crosslock. For crosslock, all locks being held in the context
+ * unlocking the crosslock, until eventually the crosslock will
+ * be unlocked, have dependency with the crosslock. That's a key
+ * idea to implement crossrelease feature.
+ *
+ * Crossrelease feature introduces 2 new data structures.
+ *
+ * 1. pend_lock (== plock)
+ *
+ *	This is for keeping locks waiting to commit those so
+ *	that an actual dependency chain is built, when commiting
+ *	a crosslock.
+ *
+ *	Every task_struct has an array of this pending lock to
+ *	keep those locks. These pending locks will be added
+ *	whenever lock_acquire() is called for normal(non-crosslock)
+ *	lock and will be flushed(committed) at proper time.
+ *
+ * 2. cross_lock (== xlock)
+ *
+ *	This keeps some additional data only for crosslock. There
+ *	is one cross_lock per one lockdep_map for crosslock.
+ *	lockdep_init_map_crosslock() should be used instead of
+ *	lockdep_init_map() to use the lock as a crosslock.
+ *
+ * Acquiring and releasing sequence for crossrelease feature:
+ *
+ * 1. Acquire
+ *
+ *	All validation check is performed for all locks.
+ *
+ *	1) For non-crosslock (normal lock)
+ *
+ *		The hlock will be added not only to held_locks
+ *		of the current's task_struct, but also to
+ *		pend_lock array of the task_struct, so that
+ *		a dependency chain can be built with the lock
+ *		when doing commit.
+ *
+ *	2) For crosslock
+ *
+ *		The hlock will be added only to the cross_lock
+ *		of the lock's lockdep_map instead of held_locks,
+ *		so that a dependency chain can be built with
+ *		the lock when doing commit. And this lock is
+ *		added to the xlocks_head list.
+ *
+ * 2. Commit (only for crosslock)
+ *
+ *	This establishes a dependency chain between the lock
+ *	unlocking it now and all locks having held in the context
+ *	unlocking it since the lock was held, even though it tries
+ *	to avoid building a chain unnecessarily as far as possible.
+ *
+ * 3. Release
+ *
+ *	1) For non-crosslock (normal lock)
+ *
+ *		No change.
+ *
+ *	2) For crosslock
+ *
+ *		Just Remove the lock from xlocks_head list. Release
+ *		operation should be used with commit operation
+ *		together for crosslock, in order to build a
+ *		dependency chain properly.
+ */
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
+ * Crossrelease also need to distinguish each hardirq context, not
+ * only identify its depth.
+ */
+static DEFINE_PER_CPU(unsigned int, hardirq_id);
+void crossrelease_hardirq_start(void)
+{
+	per_cpu(hardirq_id, smp_processor_id())++;
+}
+
+/*
+ * Crossrelease also need to distinguish each softirq context, not
+ * only identify its depth.
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
+	return class->crosslock;
+}
+
+/*
+ * This is needed to decide the relationship between
+ * wrapable variables.
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
+ * To find the earlist crosslock among all crosslocks not released yet
+ */
+static unsigned int gen_id_begin(void)
+{
+	struct cross_lock *xlock;
+	unsigned int gen_id;
+	unsigned int min = (unsigned int)atomic_read(&cross_gen_id) + 1;
+
+	list_for_each_entry_rcu(xlock, &xlocks_head, xlock_entry) {
+		gen_id = READ_ONCE(xlock->gen_id);
+		if (before(gen_id, min))
+			min = gen_id;
+	}
+
+	return min;
+}
+
+/*
+ * To find the latest crosslock among all crosslocks already released
+ */
+static inline unsigned int gen_id_done(void)
+{
+	return gen_id_begin() - 1;
+}
+
+/*
+ * Should we check a dependency with previous one?
+ */
+static inline int dep_before(struct held_lock *hlock)
+{
+	return hlock->read != 2 && hlock->check && !hlock->trylock;
+}
+
+/*
+ * Should we check a dependency with next one?
+ */
+static inline int dep_after(struct held_lock *hlock)
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
+	 * plock->hlock.class_idx must be !NULL and
+	 * plock->hlock.instance must be !NULL,
+	 * if it was used once.
+	 */
+	return plock->hlock.instance ? 1 : 0;
+}
+
+/*
+ * Get a pend_lock from pend_lock ring buffer and provide it
+ * to caller.
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
+	unsigned int gen_id = (unsigned int)atomic_read(&cross_gen_id);
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
+ * We try to avoid adding a pend_lock unnecessarily so that
+ * the overhead adding pend_lock and building a dependency
+ * chain when commiting it unnecessarily, can be reduced.
+ */
+static int check_dup_plock(struct held_lock *hlock)
+{
+	struct task_struct *curr = current;
+	struct lock_class *class = hlock_class(hlock);
+	struct pend_lock *plock_c = plock_curr(curr);
+	struct pend_lock *plock = plock_c;
+
+	do {
+		plock = plock_prev(curr, plock);
+
+		if (!plock_used(plock))
+			break;
+		/*
+		 * This control dependency of LOAD cross_gen_id
+		 * orders between the LOAD and all LOCK operations
+		 * causing STORE following this.
+		 *
+		 * It pairs with atomic_inc_return() in add_xlock().
+		 */
+		if (plock->gen_id != (unsigned int)atomic_read(&cross_gen_id))
+			break;
+		if (same_context_plock(plock) &&
+		    hlock_class(&plock->hlock) == class)
+			return 1;
+	} while (plock_c != plock);
+
+	return 0;
+}
+
+/*
+ * This will be called when lock_acquire() is called for
+ * non-crosslock. It should be implemented locklessly as far
+ * as possible since it is called very frequently.
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
+	if (!dep_before(hlock) || check_dup_plock(hlock))
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
+			     !dep_before(prev); prev--);
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
+	if (!dep_after(hlock))
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
+	 * We do assign operation for class_idx here redundantly
+	 * even though memcpy will also be performed soon, to
+	 * ensure a rcu reader can access this class_idx atomically
+	 * without lock.
+	 *
+	 * Here we assume setting a word-sized variable to a value
+	 * is an atomic operation.
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
+ * return 0: Need to do non-crossrelease acquire ops.
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
+	struct stack_trace trace;
+	unsigned int id;
+	u64 chain_key;
+
+	id = xlock_class(xlock) - lock_classes;
+	chain_key = iterate_chain_key((u64)0, id);
+	id = plock_class(plock) - lock_classes;
+	chain_key = iterate_chain_key(chain_key, id);
+
+	if (lookup_chain_cache(chain_key))
+		return 1;
+
+	if (!add_chain_cache_2hlocks(&xlock->hlock, &plock->hlock, chain_key))
+		return 0;
+
+	if (!save_trace(&trace, &plock->trace))
+		return 0;
+
+	if (!check_prev_add(current, &xlock->hlock, &plock->hlock, 1,
+			    NULL, &trace))
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
+		    plock_class(plock)->skip_gen_id != xlock->gen_id &&
+		    !commit_plock(xlock, plock))
+			return 0;
+	} while (plock_c != plock);
+
+	return 1;
+}
+
+/* Need to be protected using graph_lock() by caller */
+static void mark_skip_classes(struct lock_class *class, unsigned int id)
+{
+	struct lock_list *entry;
+
+	list_for_each_entry(entry, &class->locks_after, entry)
+		entry->class->skip_gen_id = id;
+}
+
+/*
+ * lock_commit_crosslock is a function for doing commit.
+ */
+void lock_commit_crosslock(struct lockdep_map *lock)
+{
+	struct cross_lock *xlock;
+	unsigned long flags;
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
+	if (xlock && xlock->ref > 0) {
+		mark_skip_classes(xlock_class(xlock), xlock->gen_id);
+		if (!commit_plocks(xlock))
+			return;
+	}
+
+	graph_unlock();
+	current->lockdep_recursion = 0;
+	raw_local_irq_restore(flags);
+}
+EXPORT_SYMBOL_GPL(lock_commit_crosslock);
+
+/*
+ * return 0: Need to do non-crossrelease release ops.
+ * return 1: Done. No more release ops is needed.
+ */
+static int lock_release_crosslock(struct lockdep_map *lock)
+{
+	struct cross_lock *xlock;
+	int ret = lock->cross;
+
+	if (!graph_lock())
+		return 0;
+
+	xlock = lock->xlock;
+	if (xlock && !--xlock->ref)
+		list_del_rcu(&xlock->xlock_entry);
+
+	graph_unlock();
+	return ret;
+}
+
+static void init_map_noncrosslock(struct lockdep_map *lock)
+{
+	lock->cross = 0;
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
+		lock->cross = 1;
+		lock->xlock = xlock;
+		graph_unlock();
+	}
+	raw_local_irq_restore(flags);
+}
+
+static void init_class_crosslock(struct lock_class *class, int cross)
+{
+	class->crosslock = cross;
+	class->skip_gen_id = gen_id_done();
+}
+#endif
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 8bfd1ac..bb8bf88 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -993,6 +993,19 @@ config DEBUG_LOCK_ALLOC
 	 spin_lock_init()/mutex_init()/etc., or whether there is any lock
 	 held during task exit.
 
+config LOCKDEP_CROSSRELEASE
+	bool "Lock debugging: allow other context to unlock a lock"
+	depends on TRACE_IRQFLAGS_SUPPORT && STACKTRACE_SUPPORT && LOCKDEP_SUPPORT
+	select LOCKDEP
+	select TRACE_IRQFLAGS
+	default n
+	help
+	 This allows a context to unlock a lock held by another context.
+	 Normally a lock must be unlocked by the context holding the lock.
+	 However relexing this constraint helps locks like (un)lock_page()
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
