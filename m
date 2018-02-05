Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 54ACE6B028F
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:29:35 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id l7so4866404pga.6
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:29:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c15-v6si4234244plk.327.2018.02.04.17.28.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:03 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 02/64] Introduce range reader/writer lock
Date: Mon,  5 Feb 2018 02:26:52 +0100
Message-Id: <20180205012754.23615-3-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

This implements a sleepable range rwlock, based on interval tree, serializing
conflicting/intersecting/overlapping ranges within the tree. The largest range
is given by [0, ~0] (inclusive). Unlike traditional locks, range locking
involves dealing with the tree itself and the range to be locked, normally
stack allocated and always explicitly prepared/initialized by the user in a
[a0, a1] a0 <= a1 sorted manner, before actually taking the lock.

Interval-tree based range locking is about controlling tasks' forward
progress when adding an arbitrary interval (node) to the tree, depending
on any overlapping ranges. A task can only continue (wakeup) if there are
no intersecting ranges, thus achieving mutual exclusion. To this end, a
reference counter is kept for each intersecting range in the tree
(_before_ adding itself to it). To enable shared locking semantics,
the reader to-be-locked will not take reference if an intersecting node
is also a reader, therefore ignoring the node altogether.

Fairness and freedom of starvation are guaranteed by the lack of lock
stealing, thus range locks depend directly on interval tree semantics.
This is particularly for iterations, where the key for the rbtree is
given by the interval's low endpoint, and duplicates are walked as it
would an inorder traversal of the tree.

The cost of lock and unlock of a range is O((1+R_int)log(R_all)) where
R_all is total number of ranges and R_int is the number of ranges
intersecting the operated range.

How much does it cost:
----------------------

The cost of lock and unlock of a range is O((1+R_int)log(R_all)) where R_all
is total number of ranges and R_int is the number of ranges intersecting the
new range range to be added.

Due to its sharable nature, full range locks can be compared with rw-sempahores,
which also serves from a mutex standpoint as writer-only situations are
pretty similar nowadays.

The first is the memory footprint, tree locks are smaller than rwsems: 32 vs
40 bytes, but require an additional 72 bytes of stack for the range structure.

Secondly, because every range call is serialized by the tree->lock, any lock()
fastpath will at least have an interval_tree_insert() and spinlock lock+unlock
overhead compared to a single atomic insn in the case of rwsems. Similar scenario
obviously for the unlock() case.

The torture module was used to measure 1-1 differences in lock acquisition with
increasing core counts over a period of 10 minutes. Readers and writers are
interleaved, with a slight advantage to writers as its the first kthread that is
created. The following shows the avg ops/minute with various thread-setups on
boxes with small and large core-counts.

** 4-core AMD Opteron **
(write-only)
rwsem-2thr: 4198.5, stddev: 7.77
range-2thr: 4199.1, stddev: 0.73

rwsem-4thr: 6036.8, stddev: 50.91
range-4thr: 6004.9, stddev: 126.57

rwsem-8thr: 6245.6, stddev: 59.39
range-8thr: 6229.3, stddev: 10.60

(read-only)
rwsem-2thr: 5930.7, stddev: 21.92
range-2thr: 5917.3, stddev: 25.45

rwsem-4thr: 9881.6, stddev: 0.70
range-4thr: 9540.2, stddev: 98.28

rwsem-8thr: 11633.2, stddev: 7.72
range-8thr: 11314.7, stddev: 62.22

For the read/write-only cases, there is very little difference between the range lock
and rwsems, with up to a 3% hit, which could very well be considered in the noise range.

(read-write)
rwsem-write-1thr: 1744.8, stddev: 11.59
rwsem-read-1thr:  1043.1, stddev: 3.97
range-write-1thr: 1740.2, stddev: 5.99
range-read-1thr:  1022.5, stddev: 6.41

rwsem-write-2thr: 1662.5, stddev: 0.70
rwsem-read-2thr:  1278.0, stddev: 25.45
range-write-2thr: 1321.5, stddev: 51.61
range-read-2thr:  1243.5, stddev: 30.40

rwsem-write-4thr: 1761.0, stddev: 11.31
rwsem-read-4thr:  1426.0, stddev: 7.07
range-write-4thr: 1417.0, stddev: 29.69
range-read-4thr:  1398.0, stddev: 56.56

While a single reader and writer threads does not show must difference, increasing
core counts shows that in reader/writer workloads, writer threads can take a hit in
raw performance of up to ~20%, while the number of reader throughput is quite similar
among both locks.

** 240-core (ht) IvyBridge **
(write-only)
rwsem-120thr: 6844.5, stddev: 82.73
range-120thr: 6070.5, stddev: 85.55

rwsem-240thr: 6292.5, stddev: 146.3
range-240thr: 6099.0, stddev: 15.55

rwsem-480thr: 6164.8, stddev: 33.94
range-480thr: 6062.3, stddev: 19.79

(read-only)
rwsem-120thr: 136860.4, stddev: 2539.92
range-120thr: 138052.2, stddev: 327.39

rwsem-240thr: 235297.5, stddev: 2220.50
range-240thr: 232099.1, stddev: 3614.72

rwsem-480thr: 272683.0, stddev: 3924.32
range-480thr: 256539.2, stddev: 9541.69

Similar to the small box, larger machines show that range locks take only a minor
(up to ~6% for 480 threads) hit even in completely exclusive or shared scenarios.

(read-write)
rwsem-write-60thr: 4658.1, stddev: 1303.19
rwsem-read-60thr:  1108.7, stddev: 718.42
range-write-60thr: 3203.6, stddev: 139.30
range-read-60thr:  1852.8, stddev: 147.5

rwsem-write-120thr: 3971.3, stddev: 1413.0
rwsem-read-120thr:  1038.8, stddev: 353.51
range-write-120thr: 2282.1, stddev: 207.18
range-read-120thr:  1856.5, stddev: 198.69

rwsem-write-240thr: 4112.7, stddev: 2448.1
rwsem-read-240thr:  1277.4, stddev: 430.30
range-write-240thr: 2353.1, stddev: 502.04
range-read-240thr:  1551.5, stddev: 361.33

When mixing readers and writers, writer throughput can take a hit of up to ~40%,
similar to the 4 core machine, however, reader threads can increase the number of
acquisitions in up to ~80%. In any case, the overall writer+reader throughput will
always be higher for rwsems. A huge factor in this behavior is that range locks
do not have writer spin-on-owner feature.

On both machines when actually testing threads acquiring different ranges, the
amount of throughput will always outperform the rwsem, due to the increased
parallelism; which is no surprise either. As such microbenchmarks that merely
pounds on a lock will pretty much always suffer upon direct lock conversions,
but not enough to matter in the overall picture.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 include/linux/lockdep.h     |  33 +++
 include/linux/range_lock.h  | 189 +++++++++++++
 kernel/locking/Makefile     |   2 +-
 kernel/locking/range_lock.c | 667 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 890 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/range_lock.h
 create mode 100644 kernel/locking/range_lock.c

diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index 6fc77d4dbdcd..5df01b567d16 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -490,6 +490,16 @@ do {								\
 	lock_acquired(&(_lock)->dep_map, _RET_IP_);			\
 } while (0)
 
+#define RANGE_LOCK_CONTENDED(tree, _lock, try, lock)		\
+do {								\
+	if (!try(tree, _lock)) {				\
+		lock_contended(&(tree)->dep_map, _RET_IP_);	\
+		lock(tree, _lock);				\
+	}							\
+	lock_acquired(&(tree)->dep_map, _RET_IP_);		\
+} while (0)
+
+
 #define LOCK_CONTENDED_RETURN(_lock, try, lock)			\
 ({								\
 	int ____err = 0;					\
@@ -502,6 +512,18 @@ do {								\
 	____err;						\
 })
 
+#define RANGE_LOCK_CONTENDED_RETURN(tree, _lock, try, lock)	\
+({								\
+	int ____err = 0;					\
+	if (!try(tree, _lock)) {				\
+		lock_contended(&(tree)->dep_map, _RET_IP_);	\
+		____err = lock(tree, _lock);			\
+	}							\
+	if (!____err)						\
+		lock_acquired(&(tree)->dep_map, _RET_IP_);	\
+	____err;						\
+})
+
 #else /* CONFIG_LOCK_STAT */
 
 #define lock_contended(lockdep_map, ip) do {} while (0)
@@ -510,9 +532,15 @@ do {								\
 #define LOCK_CONTENDED(_lock, try, lock) \
 	lock(_lock)
 
+#define RANGE_LOCK_CONTENDED(tree, _lock, try, lock) \
+	lock(tree, _lock)
+
 #define LOCK_CONTENDED_RETURN(_lock, try, lock) \
 	lock(_lock)
 
+#define RANGE_LOCK_CONTENDED_RETURN(tree, _lock, try, lock) \
+	lock(tree, _lock)
+
 #endif /* CONFIG_LOCK_STAT */
 
 #ifdef CONFIG_LOCKDEP
@@ -577,6 +605,11 @@ static inline void print_irqtrace_events(struct task_struct *curr)
 #define rwsem_acquire_read(l, s, t, i)		lock_acquire_shared(l, s, t, NULL, i)
 #define rwsem_release(l, n, i)			lock_release(l, n, i)
 
+#define range_lock_acquire(l, s, t, i)		lock_acquire_exclusive(l, s, t, NULL, i)
+#define range_lock_acquire_nest(l, s, t, n, i)	lock_acquire_exclusive(l, s, t, n, i)
+#define range_lock_acquire_read(l, s, t, i)	lock_acquire_shared(l, s, t, NULL, i)
+#define range_lock_release(l, n, i)		lock_release(l, n, i)
+
 #define lock_map_acquire(l)			lock_acquire_exclusive(l, 0, 0, NULL, _THIS_IP_)
 #define lock_map_acquire_read(l)		lock_acquire_shared_recursive(l, 0, 0, NULL, _THIS_IP_)
 #define lock_map_acquire_tryread(l)		lock_acquire_shared_recursive(l, 0, 1, NULL, _THIS_IP_)
diff --git a/include/linux/range_lock.h b/include/linux/range_lock.h
new file mode 100644
index 000000000000..51448addb2fa
--- /dev/null
+++ b/include/linux/range_lock.h
@@ -0,0 +1,189 @@
+/*
+ * Range/interval rw-locking
+ * -------------------------
+ *
+ * Interval-tree based range locking is about controlling tasks' forward
+ * progress when adding an arbitrary interval (node) to the tree, depending
+ * on any overlapping ranges. A task can only continue (or wakeup) if there
+ * are no intersecting ranges, thus achieving mutual exclusion. To this end,
+ * a reference counter is kept for each intersecting range in the tree
+ * (_before_ adding itself to it). To enable shared locking semantics,
+ * the reader to-be-locked will not take reference if an intersecting node
+ * is also a reader, therefore ignoring the node altogether.
+ *
+ * Given the above, range lock order and fairness has fifo semantics among
+ * contended ranges. Among uncontended ranges, order is given by the inorder
+ * tree traversal which is performed.
+ *
+ * Example: Tasks A, B, C. Tree is empty.
+ *
+ *   t0: A grabs the (free) lock [a,n]; thus ref[a,n] = 0.
+ *   t1: B tries to grab the lock [g,z]; thus ref[g,z] = 1.
+ *   t2: C tries to grab the lock [b,m]; thus ref[b,m] = 2.
+ *
+ *   t3: A releases the lock [a,n]; thus ref[g,z] = 0, ref[b,m] = 1.
+ *   t4: B grabs the lock [g.z].
+ *
+ * In addition, freedom of starvation is guaranteed by the fact that there
+ * is no lock stealing going on, everything being serialized by the tree->lock.
+ *
+ * The cost of lock and unlock of a range is O((1+R_int)log(R_all)) where
+ * R_all is total number of ranges and R_int is the number of ranges
+ * intersecting the operated range.
+ */
+#ifndef _LINUX_RANGE_LOCK_H
+#define _LINUX_RANGE_LOCK_H
+
+#include <linux/rbtree.h>
+#include <linux/interval_tree.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+
+/*
+ * The largest range will span [0,RANGE_LOCK_FULL].
+ */
+#define RANGE_LOCK_FULL  ~0UL
+
+struct range_lock {
+	struct interval_tree_node node;
+	struct task_struct *tsk;
+	/* Number of ranges which are blocking acquisition of the lock */
+	unsigned int blocking_ranges;
+	u64 seqnum;
+};
+
+struct range_lock_tree {
+	struct rb_root_cached root;
+	spinlock_t lock;
+	u64 seqnum; /* track order of incoming ranges, avoid overflows */
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+	struct lockdep_map dep_map;
+#endif
+};
+
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+# define __RANGE_LOCK_DEP_MAP_INIT(lockname) , .dep_map = { .name = #lockname }
+#else
+# define __RANGE_LOCK_DEP_MAP_INIT(lockname)
+#endif
+
+#define __RANGE_LOCK_TREE_INITIALIZER(name)		\
+	{ .root = RB_ROOT_CACHED			\
+	, .seqnum = 0					\
+	, .lock = __SPIN_LOCK_UNLOCKED(name.lock)       \
+	__RANGE_LOCK_DEP_MAP_INIT(name) }		\
+
+#define DEFINE_RANGE_LOCK_TREE(name) \
+	struct range_lock_tree name = __RANGE_LOCK_TREE_INITIALIZER(name)
+
+#define __RANGE_LOCK_INITIALIZER(__start, __last) {	\
+		.node = {				\
+			.start = (__start)		\
+			,.last = (__last)		\
+		}					\
+		, .tsk = NULL				\
+		, .blocking_ranges = 0			\
+		, .seqnum = 0				\
+	}
+
+#define DEFINE_RANGE_LOCK(name, start, last)				\
+	struct range_lock name = __RANGE_LOCK_INITIALIZER((start), (last))
+
+#define DEFINE_RANGE_LOCK_FULL(name)					\
+	struct range_lock name = __RANGE_LOCK_INITIALIZER(0, RANGE_LOCK_FULL)
+
+static inline void
+__range_lock_tree_init(struct range_lock_tree *tree,
+		       const char *name, struct lock_class_key *key)
+{
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+	/*
+	 * Make sure we are not reinitializing a held lock:
+	 */
+	debug_check_no_locks_freed((void *)tree, sizeof(*tree));
+	lockdep_init_map(&tree->dep_map, name, key, 0);
+#endif
+	tree->root = RB_ROOT_CACHED;
+	spin_lock_init(&tree->lock);
+	tree->seqnum = 0;
+}
+
+#define range_lock_tree_init(tree)				\
+do {								\
+	static struct lock_class_key __key;			\
+								\
+	__range_lock_tree_init((tree), #tree, &__key);		\
+} while (0)
+
+void range_lock_init(struct range_lock *lock,
+		       unsigned long start, unsigned long last);
+void range_lock_init_full(struct range_lock *lock);
+
+/*
+ * lock for reading
+ */
+void range_read_lock(struct range_lock_tree *tree, struct range_lock *lock);
+int range_read_lock_interruptible(struct range_lock_tree *tree,
+				  struct range_lock *lock);
+int range_read_lock_killable(struct range_lock_tree *tree,
+			     struct range_lock *lock);
+int range_read_trylock(struct range_lock_tree *tree, struct range_lock *lock);
+void range_read_unlock(struct range_lock_tree *tree, struct range_lock *lock);
+
+/*
+ * lock for writing
+ */
+void range_write_lock(struct range_lock_tree *tree, struct range_lock *lock);
+int range_write_lock_interruptible(struct range_lock_tree *tree,
+				   struct range_lock *lock);
+int range_write_lock_killable(struct range_lock_tree *tree,
+			      struct range_lock *lock);
+int range_write_trylock(struct range_lock_tree *tree, struct range_lock *lock);
+void range_write_unlock(struct range_lock_tree *tree, struct range_lock *lock);
+
+void range_downgrade_write(struct range_lock_tree *tree,
+			   struct range_lock *lock);
+
+int range_is_locked(struct range_lock_tree *tree, struct range_lock *lock);
+
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+/*
+ * nested locking. NOTE: range locks are not allowed to recurse
+ * (which occurs if the same task tries to acquire the same
+ * lock instance multiple times), but multiple locks of the
+ * same lock class might be taken, if the order of the locks
+ * is always the same. This ordering rule can be expressed
+ * to lockdep via the _nested() APIs, but enumerating the
+ * subclasses that are used. (If the nesting relationship is
+ * static then another method for expressing nested locking is
+ * the explicit definition of lock class keys and the use of
+ * lockdep_set_class() at lock initialization time.
+ * See Documentation/locking/lockdep-design.txt for more details.)
+ */
+extern void range_read_lock_nested(struct range_lock_tree *tree,
+		struct range_lock *lock, int subclass);
+extern void range_write_lock_nested(struct range_lock_tree *tree,
+		struct range_lock *lock, int subclass);
+extern int range_write_lock_killable_nested(struct range_lock_tree *tree,
+		struct range_lock *lock, int subclass);
+extern void _range_write_lock_nest_lock(struct range_lock_tree *tree,
+		struct range_lock *lock, struct lockdep_map *nest_lock);
+
+# define range_write_lock_nest_lock(tree, lock, nest_lock)		\
+do {									\
+	typecheck(struct lockdep_map *, &(nest_lock)->dep_map);		\
+	_range_write_lock_nest_lock(tree, lock, &(nest_lock)->dep_map);	\
+} while (0);
+
+#else
+# define range_read_lock_nested(tree, lock, subclass) \
+	range_read_lock(tree, lock)
+# define range_write_lock_nest_lock(tree, lock, nest_lock) \
+	range_write_lock(tree, lock)
+# define range_write_lock_nested(tree, lock, subclass) \
+	range_write_lock(tree, lock)
+# define range_write_lock_killable_nested(tree, lock, subclass) \
+	range_write_lock_killable(tree, lock)
+#endif
+
+#endif
diff --git a/kernel/locking/Makefile b/kernel/locking/Makefile
index 392c7f23af76..348a6f7d8c21 100644
--- a/kernel/locking/Makefile
+++ b/kernel/locking/Makefile
@@ -3,7 +3,7 @@
 # and is generally not a function of system call inputs.
 KCOV_INSTRUMENT		:= n
 
-obj-y += mutex.o semaphore.o rwsem.o percpu-rwsem.o
+obj-y += mutex.o semaphore.o rwsem.o percpu-rwsem.o range_lock.o
 
 ifdef CONFIG_FUNCTION_TRACER
 CFLAGS_REMOVE_lockdep.o = $(CC_FLAGS_FTRACE)
diff --git a/kernel/locking/range_lock.c b/kernel/locking/range_lock.c
new file mode 100644
index 000000000000..673c30c07743
--- /dev/null
+++ b/kernel/locking/range_lock.c
@@ -0,0 +1,667 @@
+/*
+ * Copyright (C) 2017 Jan Kara, Davidlohr Bueso.
+ */
+
+#include <linux/rbtree.h>
+#include <linux/spinlock.h>
+#include <linux/range_lock.h>
+#include <linux/lockdep.h>
+#include <linux/sched/signal.h>
+#include <linux/sched/debug.h>
+#include <linux/sched/wake_q.h>
+#include <linux/sched.h>
+#include <linux/export.h>
+
+#define range_interval_tree_foreach(node, root, start, last)	\
+	for (node = interval_tree_iter_first(root, start, last); \
+	     node; node = interval_tree_iter_next(node, start, last))
+
+#define to_range_lock(ptr) container_of(ptr, struct range_lock, node)
+#define to_interval_tree_node(ptr) \
+	container_of(ptr, struct interval_tree_node, rb)
+
+static inline void
+__range_tree_insert(struct range_lock_tree *tree, struct range_lock *lock)
+{
+	lock->seqnum = tree->seqnum++;
+	interval_tree_insert(&lock->node, &tree->root);
+}
+
+static inline void
+__range_tree_remove(struct range_lock_tree *tree, struct range_lock *lock)
+{
+	interval_tree_remove(&lock->node, &tree->root);
+}
+
+/*
+ * lock->tsk reader tracking.
+ */
+#define RANGE_FLAG_READER	1UL
+
+static inline struct task_struct *range_lock_waiter(struct range_lock *lock)
+{
+	return (struct task_struct *)
+		((unsigned long) lock->tsk & ~RANGE_FLAG_READER);
+}
+
+static inline void range_lock_set_reader(struct range_lock *lock)
+{
+	lock->tsk = (struct task_struct *)
+		((unsigned long)lock->tsk | RANGE_FLAG_READER);
+}
+
+static inline void range_lock_clear_reader(struct range_lock *lock)
+{
+	lock->tsk = (struct task_struct *)
+		((unsigned long)lock->tsk & ~RANGE_FLAG_READER);
+}
+
+static inline bool range_lock_is_reader(struct range_lock *lock)
+{
+	return (unsigned long) lock->tsk & RANGE_FLAG_READER;
+}
+
+static inline void
+__range_lock_init(struct range_lock *lock,
+		  unsigned long start, unsigned long last)
+{
+	WARN_ON(start > last);
+
+	lock->node.start = start;
+	lock->node.last = last;
+	RB_CLEAR_NODE(&lock->node.rb);
+	lock->blocking_ranges = 0;
+	lock->tsk = NULL;
+	lock->seqnum = 0;
+}
+
+/**
+ * range_lock_init - Initialize a range lock
+ * @lock: the range lock to be initialized
+ * @start: start of the interval (inclusive)
+ * @last: last location in the interval (inclusive)
+ *
+ * Initialize the range's [start, last] such that it can
+ * later be locked. User is expected to enter a sorted
+ * range, such that @start <= @last.
+ *
+ * It is not allowed to initialize an already locked range.
+ */
+void range_lock_init(struct range_lock *lock,
+		     unsigned long start, unsigned long last)
+{
+	__range_lock_init(lock, start, last);
+}
+EXPORT_SYMBOL_GPL(range_lock_init);
+
+/**
+ * range_lock_init_full - Initialize a full range lock
+ * @lock: the range lock to be initialized
+ *
+ * Initialize the full range.
+ *
+ * It is not allowed to initialize an already locked range.
+ */
+void range_lock_init_full(struct range_lock *lock)
+{
+	__range_lock_init(lock, 0, RANGE_LOCK_FULL);
+}
+EXPORT_SYMBOL_GPL(range_lock_init_full);
+
+static inline void
+range_lock_put(struct range_lock *lock, struct wake_q_head *wake_q)
+{
+	if (!--lock->blocking_ranges)
+		wake_q_add(wake_q, range_lock_waiter(lock));
+}
+
+static inline int wait_for_ranges(struct range_lock_tree *tree,
+				  struct range_lock *lock, long state)
+{
+	int ret = 0;
+
+	while (true) {
+		set_current_state(state);
+
+		/* do we need to go to sleep? */
+		if (!lock->blocking_ranges)
+			break;
+
+		if (unlikely(signal_pending_state(state, current))) {
+			struct interval_tree_node *node;
+			unsigned long flags;
+			DEFINE_WAKE_Q(wake_q);
+
+			ret = -EINTR;
+			/*
+			 * We're not taking the lock after all, cleanup
+			 * after ourselves.
+			 */
+			spin_lock_irqsave(&tree->lock, flags);
+
+			range_lock_clear_reader(lock);
+			__range_tree_remove(tree, lock);
+
+			range_interval_tree_foreach(node, &tree->root,
+						    lock->node.start,
+						    lock->node.last) {
+				struct range_lock *blked;
+				blked = to_range_lock(node);
+
+				if (range_lock_is_reader(lock) &&
+				    range_lock_is_reader(blked))
+					continue;
+
+				/* unaccount for threads _we_ are blocking */
+				if (lock->seqnum < blked->seqnum)
+					range_lock_put(blked, &wake_q);
+			}
+
+			spin_unlock_irqrestore(&tree->lock, flags);
+			wake_up_q(&wake_q);
+			break;
+		}
+
+		schedule();
+	}
+
+	__set_current_state(TASK_RUNNING);
+	return ret;
+}
+
+/**
+ * range_read_trylock - Trylock for reading
+ * @tree: interval tree
+ * @lock: the range lock to be trylocked
+ *
+ * The trylock is against the range itself, not the @tree->lock.
+ *
+ * Returns 1 if successful, 0 if contention (must block to acquire).
+ */
+static inline int __range_read_trylock(struct range_lock_tree *tree,
+				       struct range_lock *lock)
+{
+	int ret = true;
+	unsigned long flags;
+	struct interval_tree_node *node;
+
+	spin_lock_irqsave(&tree->lock, flags);
+
+	range_interval_tree_foreach(node, &tree->root,
+				    lock->node.start, lock->node.last) {
+		struct range_lock *blocked_lock;
+		blocked_lock = to_range_lock(node);
+
+		if (!range_lock_is_reader(blocked_lock)) {
+			ret = false;
+			goto unlock;
+		}
+	}
+
+	range_lock_set_reader(lock);
+	__range_tree_insert(tree, lock);
+unlock:
+	spin_unlock_irqrestore(&tree->lock, flags);
+
+	return ret;
+}
+
+int range_read_trylock(struct range_lock_tree *tree, struct range_lock *lock)
+{
+	int ret = __range_read_trylock(tree, lock);
+
+	if (ret)
+		range_lock_acquire_read(&tree->dep_map, 0, 1, _RET_IP_);
+
+	return ret;
+}
+
+EXPORT_SYMBOL_GPL(range_read_trylock);
+
+static __always_inline int __sched
+__range_read_lock_common(struct range_lock_tree *tree,
+			 struct range_lock *lock, long state)
+{
+	struct interval_tree_node *node;
+	unsigned long flags;
+
+	spin_lock_irqsave(&tree->lock, flags);
+
+	range_interval_tree_foreach(node, &tree->root,
+				    lock->node.start, lock->node.last) {
+		struct range_lock *blocked_lock;
+		blocked_lock = to_range_lock(node);
+
+		if (!range_lock_is_reader(blocked_lock))
+			lock->blocking_ranges++;
+	}
+
+	__range_tree_insert(tree, lock);
+
+	lock->tsk = current;
+	range_lock_set_reader(lock);
+	spin_unlock_irqrestore(&tree->lock, flags);
+
+	return wait_for_ranges(tree, lock, state);
+}
+
+static __always_inline int
+__range_read_lock(struct range_lock_tree *tree, struct range_lock *lock)
+{
+	return __range_read_lock_common(tree, lock, TASK_UNINTERRUPTIBLE);
+}
+
+/**
+ * range_read_lock - Lock for reading
+ * @tree: interval tree
+ * @lock: the range lock to be locked
+ *
+ * Returns when the lock has been acquired or sleep until
+ * until there are no overlapping ranges.
+ */
+void range_read_lock(struct range_lock_tree *tree, struct range_lock *lock)
+{
+	might_sleep();
+	range_lock_acquire_read(&tree->dep_map, 0, 0, _RET_IP_);
+
+	RANGE_LOCK_CONTENDED(tree, lock,
+			     __range_read_trylock, __range_read_lock);
+}
+EXPORT_SYMBOL_GPL(range_read_lock);
+
+/**
+ * range_read_lock_interruptible - Lock for reading (interruptible)
+ * @tree: interval tree
+ * @lock: the range lock to be locked
+ *
+ * Lock the range like range_read_lock(), and return 0 if the
+ * lock has been acquired or sleep until until there are no
+ * overlapping ranges. If a signal arrives while waiting for the
+ * lock then this function returns -EINTR.
+ */
+int range_read_lock_interruptible(struct range_lock_tree *tree,
+				  struct range_lock *lock)
+{
+	might_sleep();
+	return __range_read_lock_common(tree, lock, TASK_INTERRUPTIBLE);
+}
+EXPORT_SYMBOL_GPL(range_read_lock_interruptible);
+
+/**
+ * range_read_lock_killable - Lock for reading (killable)
+ * @tree: interval tree
+ * @lock: the range lock to be locked
+ *
+ * Lock the range like range_read_lock(), and return 0 if the
+ * lock has been acquired or sleep until until there are no
+ * overlapping ranges. If a signal arrives while waiting for the
+ * lock then this function returns -EINTR.
+ */
+static __always_inline int
+__range_read_lock_killable(struct range_lock_tree *tree,
+			   struct range_lock *lock)
+{
+	return __range_read_lock_common(tree, lock, TASK_KILLABLE);
+}
+
+int range_read_lock_killable(struct range_lock_tree *tree,
+			     struct range_lock *lock)
+{
+	might_sleep();
+	range_lock_acquire_read(&tree->dep_map, 0, 0, _RET_IP_);
+
+	if (RANGE_LOCK_CONTENDED_RETURN(tree, lock, __range_read_trylock,
+					__range_read_lock_killable)) {
+		range_lock_release(&tree->dep_map, 1, _RET_IP_);
+		return -EINTR;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(range_read_lock_killable);
+
+/**
+ * range_read_unlock - Unlock for reading
+ * @tree: interval tree
+ * @lock: the range lock to be unlocked
+ *
+ * Wakes any blocked readers, when @lock is the only conflicting range.
+ *
+ * It is not allowed to unlock an unacquired read lock.
+ */
+void range_read_unlock(struct range_lock_tree *tree, struct range_lock *lock)
+{
+	struct interval_tree_node *node;
+	unsigned long flags;
+	DEFINE_WAKE_Q(wake_q);
+
+	spin_lock_irqsave(&tree->lock, flags);
+
+	range_lock_clear_reader(lock);
+	__range_tree_remove(tree, lock);
+
+	range_lock_release(&tree->dep_map, 1, _RET_IP_);
+
+	range_interval_tree_foreach(node, &tree->root,
+				    lock->node.start, lock->node.last) {
+		struct range_lock *blocked_lock;
+		blocked_lock = to_range_lock(node);
+
+		if (!range_lock_is_reader(blocked_lock))
+			range_lock_put(blocked_lock, &wake_q);
+	}
+
+	spin_unlock_irqrestore(&tree->lock, flags);
+	wake_up_q(&wake_q);
+}
+EXPORT_SYMBOL_GPL(range_read_unlock);
+
+/*
+ * Check for overlaps for fast write_trylock(), which is the same
+ * optimization that interval_tree_iter_first() does.
+ */
+static inline bool __range_overlaps_intree(struct range_lock_tree *tree,
+					   struct range_lock *lock)
+{
+	struct interval_tree_node *root;
+	struct range_lock *left;
+
+	if (unlikely(RB_EMPTY_ROOT(&tree->root.rb_root)))
+		return false;
+
+	root = to_interval_tree_node(tree->root.rb_root.rb_node);
+	left = to_range_lock(to_interval_tree_node(rb_first_cached(&tree->root)));
+
+	return lock->node.start <= root->__subtree_last &&
+		left->node.start <= lock->node.last;
+}
+
+/**
+ * range_write_trylock - Trylock for writing
+ * @tree: interval tree
+ * @lock: the range lock to be trylocked
+ *
+ * The trylock is against the range itself, not the @tree->lock.
+ *
+ * Returns 1 if successful, 0 if contention (must block to acquire).
+ */
+static inline int __range_write_trylock(struct range_lock_tree *tree,
+					struct range_lock *lock)
+{
+	int overlaps;
+	unsigned long flags;
+
+	spin_lock_irqsave(&tree->lock, flags);
+	overlaps = __range_overlaps_intree(tree, lock);
+
+	if (!overlaps) {
+		range_lock_clear_reader(lock);
+		__range_tree_insert(tree, lock);
+	}
+
+	spin_unlock_irqrestore(&tree->lock, flags);
+
+	return !overlaps;
+}
+
+int range_write_trylock(struct range_lock_tree *tree, struct range_lock *lock)
+{
+	int ret = __range_write_trylock(tree, lock);
+
+	if (ret)
+		range_lock_acquire(&tree->dep_map, 0, 1, _RET_IP_);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(range_write_trylock);
+
+static __always_inline int __sched
+__range_write_lock_common(struct range_lock_tree *tree,
+			  struct range_lock *lock, long state)
+{
+	struct interval_tree_node *node;
+	unsigned long flags;
+
+	spin_lock_irqsave(&tree->lock, flags);
+
+	range_interval_tree_foreach(node, &tree->root,
+				    lock->node.start, lock->node.last) {
+		/*
+		 * As a writer, we always consider an existing node. We
+		 * need to wait; either the intersecting node is another
+		 * writer or we have a reader that needs to finish.
+		 */
+		lock->blocking_ranges++;
+	}
+
+	__range_tree_insert(tree, lock);
+
+	lock->tsk = current;
+	spin_unlock_irqrestore(&tree->lock, flags);
+
+	return wait_for_ranges(tree, lock, state);
+}
+
+static __always_inline int
+__range_write_lock(struct range_lock_tree *tree, struct range_lock *lock)
+{
+	return __range_write_lock_common(tree, lock, TASK_UNINTERRUPTIBLE);
+}
+
+/**
+ * range_write_lock - Lock for writing
+ * @tree: interval tree
+ * @lock: the range lock to be locked
+ *
+ * Returns when the lock has been acquired or sleep until
+ * until there are no overlapping ranges.
+ */
+void range_write_lock(struct range_lock_tree *tree, struct range_lock *lock)
+{
+	might_sleep();
+	range_lock_acquire(&tree->dep_map, 0, 0, _RET_IP_);
+
+	RANGE_LOCK_CONTENDED(tree, lock,
+			     __range_write_trylock, __range_write_lock);
+}
+EXPORT_SYMBOL_GPL(range_write_lock);
+
+/**
+ * range_write_lock_interruptible - Lock for writing (interruptible)
+ * @tree: interval tree
+ * @lock: the range lock to be locked
+ *
+ * Lock the range like range_write_lock(), and return 0 if the
+ * lock has been acquired or sleep until until there are no
+ * overlapping ranges. If a signal arrives while waiting for the
+ * lock then this function returns -EINTR.
+ */
+int range_write_lock_interruptible(struct range_lock_tree *tree,
+				   struct range_lock *lock)
+{
+	might_sleep();
+	return __range_write_lock_common(tree, lock, TASK_INTERRUPTIBLE);
+}
+EXPORT_SYMBOL_GPL(range_write_lock_interruptible);
+
+/**
+ * range_write_lock_killable - Lock for writing (killable)
+ * @tree: interval tree
+ * @lock: the range lock to be locked
+ *
+ * Lock the range like range_write_lock(), and return 0 if the
+ * lock has been acquired or sleep until until there are no
+ * overlapping ranges. If a signal arrives while waiting for the
+ * lock then this function returns -EINTR.
+ */
+static __always_inline int
+__range_write_lock_killable(struct range_lock_tree *tree,
+			   struct range_lock *lock)
+{
+	return __range_write_lock_common(tree, lock, TASK_KILLABLE);
+}
+
+int range_write_lock_killable(struct range_lock_tree *tree,
+			      struct range_lock *lock)
+{
+	might_sleep();
+	range_lock_acquire(&tree->dep_map, 0, 0, _RET_IP_);
+
+	if (RANGE_LOCK_CONTENDED_RETURN(tree, lock, __range_write_trylock,
+					__range_write_lock_killable)) {
+		range_lock_release(&tree->dep_map, 1, _RET_IP_);
+		return -EINTR;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(range_write_lock_killable);
+
+/**
+ * range_write_unlock - Unlock for writing
+ * @tree: interval tree
+ * @lock: the range lock to be unlocked
+ *
+ * Wakes any blocked readers, when @lock is the only conflicting range.
+ *
+ * It is not allowed to unlock an unacquired write lock.
+ */
+void range_write_unlock(struct range_lock_tree *tree, struct range_lock *lock)
+{
+	struct interval_tree_node *node;
+	unsigned long flags;
+	DEFINE_WAKE_Q(wake_q);
+
+	spin_lock_irqsave(&tree->lock, flags);
+
+	range_lock_clear_reader(lock);
+	__range_tree_remove(tree, lock);
+
+	range_lock_release(&tree->dep_map, 1, _RET_IP_);
+
+	range_interval_tree_foreach(node, &tree->root,
+				    lock->node.start, lock->node.last) {
+		struct range_lock *blocked_lock;
+		blocked_lock = to_range_lock(node);
+
+		range_lock_put(blocked_lock, &wake_q);
+	}
+
+	spin_unlock_irqrestore(&tree->lock, flags);
+	wake_up_q(&wake_q);
+}
+EXPORT_SYMBOL_GPL(range_write_unlock);
+
+/**
+ * range_downgrade_write - Downgrade write range lock to read lock
+ * @tree: interval tree
+ * @lock: the range lock to be downgraded
+ *
+ * Wakes any blocked readers, when @lock is the only conflicting range.
+ *
+ * It is not allowed to downgrade an unacquired write lock.
+ */
+void range_downgrade_write(struct range_lock_tree *tree,
+			   struct range_lock *lock)
+{
+	unsigned long flags;
+	struct interval_tree_node *node;
+	DEFINE_WAKE_Q(wake_q);
+
+	lock_downgrade(&tree->dep_map, _RET_IP_);
+
+	spin_lock_irqsave(&tree->lock, flags);
+
+	WARN_ON(range_lock_is_reader(lock));
+
+	range_interval_tree_foreach(node, &tree->root,
+				    lock->node.start, lock->node.last) {
+		struct range_lock *blocked_lock;
+		blocked_lock = to_range_lock(node);
+
+		/*
+		 * Unaccount for any blocked reader lock. Wakeup if possible.
+		 */
+		if (range_lock_is_reader(blocked_lock))
+			range_lock_put(blocked_lock, &wake_q);
+	}
+
+	range_lock_set_reader(lock);
+	spin_unlock_irqrestore(&tree->lock, flags);
+	wake_up_q(&wake_q);
+}
+EXPORT_SYMBOL_GPL(range_downgrade_write);
+
+/**
+ * range_is_locked - Returns 1 if the given range is already either reader or
+ *                   writer owned. Otherwise 0.
+ * @tree: interval tree
+ * @lock: the range lock to be checked
+ *
+ * Similar to trylocks, this is against the range itself, not the @tree->lock.
+ */
+int range_is_locked(struct range_lock_tree *tree, struct range_lock *lock)
+{
+	int overlaps;
+	unsigned long flags;
+
+	spin_lock_irqsave(&tree->lock, flags);
+	overlaps = __range_overlaps_intree(tree, lock);
+	spin_lock_irqsave(&tree->lock, flags);
+
+	return overlaps;
+}
+EXPORT_SYMBOL_GPL(range_is_locked);
+
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+
+void range_read_lock_nested(struct range_lock_tree *tree,
+			    struct range_lock *lock, int subclass)
+{
+	might_sleep();
+	range_lock_acquire_read(&tree->dep_map, subclass, 0, _RET_IP_);
+
+	RANGE_LOCK_CONTENDED(tree, lock, __range_read_trylock, __range_read_lock);
+}
+EXPORT_SYMBOL_GPL(range_read_lock_nested);
+
+void _range_write_lock_nest_lock(struct range_lock_tree *tree,
+				struct range_lock *lock,
+				struct lockdep_map *nest)
+{
+	might_sleep();
+	range_lock_acquire_nest(&tree->dep_map, 0, 0, nest, _RET_IP_);
+
+	RANGE_LOCK_CONTENDED(tree, lock,
+			     __range_write_trylock, __range_write_lock);
+}
+EXPORT_SYMBOL_GPL(_range_write_lock_nest_lock);
+
+void range_write_lock_nested(struct range_lock_tree *tree,
+			    struct range_lock *lock, int subclass)
+{
+	might_sleep();
+	range_lock_acquire(&tree->dep_map, subclass, 0, _RET_IP_);
+
+	RANGE_LOCK_CONTENDED(tree, lock,
+			     __range_write_trylock, __range_write_lock);
+}
+EXPORT_SYMBOL_GPL(range_write_lock_nested);
+
+
+int range_write_lock_killable_nested(struct range_lock_tree *tree,
+				     struct range_lock *lock, int subclass)
+{
+	might_sleep();
+	range_lock_acquire(&tree->dep_map, subclass, 0, _RET_IP_);
+
+	if (RANGE_LOCK_CONTENDED_RETURN(tree, lock, __range_write_trylock,
+					__range_write_lock_killable)) {
+		range_lock_release(&tree->dep_map, 1, _RET_IP_);
+		return -EINTR;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(range_write_lock_killable_nested);
+#endif
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
