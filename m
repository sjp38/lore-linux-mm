Subject: Re: [PATCH 1/2] scalable rw_mutex
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070511230023.GA449@tv-sign.ru>
References: <20070511131541.992688403@chello.nl>
	 <20070511132321.895740140@chello.nl>  <20070511230023.GA449@tv-sign.ru>
Content-Type: text/plain
Date: Sat, 12 May 2007 15:41:16 +0200
Message-Id: <1178977276.6810.59.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oleg Nesterov <oleg@tv-sign.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

It has grown a few undocumented barriers again; but I'd like some
feedback on them. /me still hopes some can go.. but these things still
mess my head up.

---

Scalable reader/writer lock.

Its scalable in that the read count is a percpu counter and the reader fast
path does not write to a shared cache-line.

Its not FIFO fair, but starvation proof by alternating readers and writers.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/rwmutex.h |   83 +++++++++++++++
 kernel/Makefile         |    3 
 kernel/rwmutex.c        |  254 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 339 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/rwmutex.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/include/linux/rwmutex.h	2007-05-12 13:39:51.000000000 +0200
@@ -0,0 +1,83 @@
+/*
+ * Scalable reader/writer lock.
+ *
+ *  Copyright (C) 2007 Red Hat, Inc., Peter Zijlstra <pzijlstr@redhat.com>
+ *
+ * This file contains the public data structure and API definitions.
+ */
+#ifndef _LINUX_RWMUTEX_H
+#define _LINUX_RWMUTEX_H
+
+#include <linux/preempt.h>
+#include <linux/wait.h>
+#include <linux/percpu_counter.h>
+#include <linux/lockdep.h>
+#include <linux/mutex.h>
+#include <asm/atomic.h>
+
+struct rw_mutex {
+	/* Read mostly global */
+	struct percpu_counter	readers;
+	unsigned int		status;
+
+	/* The following variables are only for the slowpath */
+	struct mutex		read_mutex;	/* r -> w waiting */
+	struct mutex		write_mutex;	/* w -> w waiting */
+	struct task_struct	*waiter;	/* w -> r waiting */
+	atomic_t		read_waiters;
+
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+	struct lockdep_map dep_map;
+#endif
+};
+
+void __rw_mutex_init(struct rw_mutex *rw_mutex, const char * name,
+		struct lock_class_key *key);
+void rw_mutex_destroy(struct rw_mutex *rw_mutex);
+
+#define rw_mutex_init(rw_mutex)					\
+	do {							\
+		static struct lock_class_key __key;		\
+		__rw_mutex_init((rw_mutex), #rw_mutex, &__key);	\
+	} while (0)
+
+void rw_mutex_read_lock_slow(struct rw_mutex *rw_mutex);
+
+void rw_mutex_write_lock_nested(struct rw_mutex *rw_mutex, int subclass);
+void rw_mutex_write_unlock(struct rw_mutex *rw_mutex);
+
+int __rw_mutex_read_trylock(struct rw_mutex *rw_mutex);
+
+static inline int rw_mutex_read_trylock(struct rw_mutex *rw_mutex)
+{
+	int ret = __rw_mutex_read_trylock(rw_mutex);
+	if (ret)
+		rwsem_acquire_read(&rw_mutex->dep_map, 0, 1, _RET_IP_);
+	return ret;
+}
+
+static inline void rw_mutex_read_lock(struct rw_mutex *rw_mutex)
+{
+	int ret;
+
+	might_sleep();
+	rwsem_acquire_read(&rw_mutex->dep_map, 0, 0, _RET_IP_);
+
+	ret = __rw_mutex_read_trylock(rw_mutex);
+	if (!ret)
+		rw_mutex_read_lock_slow(rw_mutex);
+}
+
+void rw_mutex_read_unlock(struct rw_mutex *rw_mutex);
+
+static inline int rw_mutex_is_locked(struct rw_mutex *rw_mutex)
+{
+	return mutex_is_locked(&rw_mutex->write_mutex);
+}
+
+static inline void rw_mutex_write_lock(struct rw_mutex *rw_mutex)
+{
+	rw_mutex_write_lock_nested(rw_mutex, 0);
+}
+
+#endif /* _LINUX_RWMUTEX_H */
Index: linux-2.6/kernel/rwmutex.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/kernel/rwmutex.c	2007-05-12 15:32:19.000000000 +0200
@@ -0,0 +1,254 @@
+/*
+ * Scalable reader/writer lock.
+ *
+ *  Copyright (C) 2007 Red Hat, Inc., Peter Zijlstra <pzijlstr@redhat.com>
+ *
+ * Its scalable in that the read count is a percpu counter and the reader fast
+ * path does not write to a shared cache-line.
+ *
+ * Its not FIFO fair, but starvation proof by alternating readers and writers.
+ */
+#include <linux/sched.h>
+#include <linux/rwmutex.h>
+#include <linux/debug_locks.h>
+#include <linux/module.h>
+
+/*
+ * rw mutex - oxymoron when we take mutex to stand for 'MUTual EXlusion'
+ *
+ * However in this context we take mutex to mean a sleeping lock, with the
+ * property that it must be released by the same context that acquired it.
+ *
+ * design goals:
+ *
+ * A sleeping reader writer lock with a scalable read side, to avoid bouncing
+ * cache-lines.
+ *
+ * dynamics:
+ *
+ * The reader fast path is modification of a percpu_counter and a read of a
+ * shared cache-line.
+ *
+ * The write side is quite heavy; it takes two mutexes, a writer mutex and a
+ * readers mutex. The writer mutex is for w <-> w interaction, the read mutex
+ * for r -> w. The read side is forced into the slow path by setting the
+ * status bit. Then it waits for all current readers to disappear.
+ *
+ * The read lock slow path; taken when the status bit is set; takes the read
+ * mutex. Because the write side also takes this mutex, the new readers are
+ * blocked. The read unlock slow path tickles the writer every time a read
+ * lock is released.
+ *
+ * Write unlock clears the status bit, and drops the read mutex; allowing new
+ * readers. It then waits for at least one waiting reader to get a lock (if
+ * there were any readers waiting) before releasing the write mutex which will
+ * allow possible other writers to come in an stop new readers, thus avoiding
+ * starvation by alternating between readers and writers
+ *
+ * considerations:
+ *
+ * The lock's space footprint is quite large (on x86_64):
+ *
+ *   96 bytes				[struct rw_mutex]
+ *    8 bytes per cpu NR_CPUS		[void *]
+ *   32 bytes per cpu (NR_CPUS ?= cpu_possible_map ?= nr_cpu_ids)
+ *					[smallest slab]
+ *
+ * 1376 bytes for x86_64 defconfig (NR_CPUS = 32)
+ */
+
+#define RW_MUTEX_READER_FAST 	0
+#define RW_MUTEX_READER_SLOW	1
+
+void __rw_mutex_init(struct rw_mutex *rw_mutex, const char *name,
+		struct lock_class_key *key)
+{
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+	debug_check_no_locks_freed((void *)rw_mutex, sizeof(*rw_mutex));
+	lockdep_init_map(&rw_mutex->dep_map, name, key, 0);
+#endif
+
+	percpu_counter_init(&rw_mutex->readers, 0);
+	rw_mutex->status = RW_MUTEX_READER_FAST;
+	mutex_init(&rw_mutex->read_mutex);
+	mutex_init(&rw_mutex->write_mutex);
+	rw_mutex->waiter = NULL;
+	printk("rw_mutex size: %lu\n", sizeof(struct rw_mutex));
+}
+EXPORT_SYMBOL(__rw_mutex_init);
+
+void rw_mutex_destroy(struct rw_mutex *rw_mutex)
+{
+	percpu_counter_destroy(&rw_mutex->readers);
+	mutex_destroy(&rw_mutex->read_mutex);
+	mutex_destroy(&rw_mutex->write_mutex);
+}
+EXPORT_SYMBOL(rw_mutex_destroy);
+
+static inline void rw_mutex_readers_inc(struct rw_mutex *rw_mutex)
+{
+	percpu_counter_inc(&rw_mutex->readers);
+	smp_wmb();
+}
+
+static inline void rw_mutex_readers_dec(struct rw_mutex *rw_mutex)
+{
+	percpu_counter_dec(&rw_mutex->readers);
+	smp_wmb();
+}
+
+static inline long rw_mutex_readers(struct rw_mutex *rw_mutex)
+{
+	smp_rmb();
+	return percpu_counter_sum(&rw_mutex->readers);
+}
+
+#define rw_mutex_writer_wait(rw_mutex, condition)			\
+do {									\
+	struct task_struct *tsk = current;				\
+									\
+	BUG_ON((rw_mutex)->waiter);					\
+	set_task_state(tsk, TASK_UNINTERRUPTIBLE);			\
+	get_task_struct(tsk);						\
+	(rw_mutex)->waiter = tsk;					\
+	smp_wmb();							\
+	while (!(condition)) {						\
+		schedule();						\
+		set_task_state(tsk, TASK_UNINTERRUPTIBLE);		\
+	}								\
+	tsk->state = TASK_RUNNING;					\
+	(rw_mutex)->waiter = NULL;					\
+	put_task_struct(tsk);						\
+} while (0)
+
+static inline void rw_mutex_writer_wake(struct rw_mutex *rw_mutex)
+{
+	struct task_struct *tsk;
+
+	smp_rmb();
+	tsk = rw_mutex->waiter;
+	if (tsk)
+		wake_up_process(tsk);
+}
+
+void rw_mutex_read_lock_slow(struct rw_mutex *rw_mutex)
+{
+	/*
+	 * read lock slow path;
+	 * count the number of readers waiting on the read_mutex
+	 */
+	atomic_inc(&rw_mutex->read_waiters);
+	mutex_lock(&rw_mutex->read_mutex);
+
+	/*
+	 * rw_mutex->state is only set while the read_mutex is held
+	 * so by serialising on this lock, we're sure its free.
+	 */
+	BUG_ON(rw_mutex->status);
+
+	rw_mutex_readers_inc(rw_mutex);
+
+	/*
+	 * wake up a possible write unlock; waiting for at least a single
+	 * reader to pass before letting a new writer through.
+	 */
+	atomic_dec(&rw_mutex->read_waiters);
+	rw_mutex_writer_wake(rw_mutex);
+	mutex_unlock(&rw_mutex->read_mutex);
+}
+EXPORT_SYMBOL(rw_mutex_read_lock_slow);
+
+static inline
+void rw_mutex_status_set(struct rw_mutex *rw_mutex, unsigned int status)
+{
+	rw_mutex->status = status;
+	/*
+	 * allow new readers to see this change in status
+	 */
+	smp_wmb();
+}
+
+static inline unsigned int rw_mutex_reader_slow(struct rw_mutex *rw_mutex)
+{
+	/*
+	 * match rw_mutex_status_set()
+	 */
+	smp_rmb();
+	return rw_mutex->status;
+}
+
+int __rw_mutex_read_trylock(struct rw_mutex *rw_mutex)
+{
+	rw_mutex_readers_inc(rw_mutex);
+	if (unlikely(rw_mutex_reader_slow(rw_mutex))) {
+		rw_mutex_readers_dec(rw_mutex);
+		/*
+		 * possibly wake up a writer waiting for this reference to
+		 * disappear
+		 */
+		rw_mutex_writer_wake(rw_mutex);
+		return 0;
+	}
+	return 1;
+}
+EXPORT_SYMBOL(__rw_mutex_read_trylock);
+
+void rw_mutex_read_unlock(struct rw_mutex *rw_mutex)
+{
+	rwsem_release(&rw_mutex->dep_map, 1, _RET_IP_);
+
+	rw_mutex_readers_dec(rw_mutex);
+	/*
+	 * on the slow path;
+	 * nudge the writer waiting for the last reader to go away
+	 */
+	if (unlikely(rw_mutex_reader_slow(rw_mutex)))
+		rw_mutex_writer_wake(rw_mutex);
+}
+EXPORT_SYMBOL(rw_mutex_read_unlock);
+
+void rw_mutex_write_lock_nested(struct rw_mutex *rw_mutex, int subclass)
+{
+	might_sleep();
+	rwsem_acquire(&rw_mutex->dep_map, subclass, 0, _RET_IP_);
+
+	mutex_lock_nested(&rw_mutex->write_mutex, subclass);
+
+	/*
+	 * block new readers
+	 */
+	mutex_lock_nested(&rw_mutex->read_mutex, subclass);
+	rw_mutex_status_set(rw_mutex, RW_MUTEX_READER_SLOW);
+	/*
+	 * and wait for all current readers to go away
+	 */
+	rw_mutex_writer_wait(rw_mutex, (rw_mutex_readers(rw_mutex) == 0));
+}
+EXPORT_SYMBOL(rw_mutex_write_lock_nested);
+
+void rw_mutex_write_unlock(struct rw_mutex *rw_mutex)
+{
+	int waiters;
+
+	might_sleep();
+	rwsem_release(&rw_mutex->dep_map, 1, _RET_IP_);
+
+	/*
+	 * let the readers rip
+	 */
+	rw_mutex_status_set(rw_mutex, RW_MUTEX_READER_FAST);
+	waiters = atomic_read(&rw_mutex->read_waiters);
+	mutex_unlock(&rw_mutex->read_mutex);
+	/*
+	 * wait for at least 1 reader to get through
+	 */
+	if (waiters) {
+		rw_mutex_writer_wait(rw_mutex,
+			(atomic_read(&rw_mutex->read_waiters) < waiters));
+	}
+	/*
+	 * before we let the writers rip
+	 */
+	mutex_unlock(&rw_mutex->write_mutex);
+}
+EXPORT_SYMBOL(rw_mutex_write_unlock);
Index: linux-2.6/kernel/Makefile
===================================================================
--- linux-2.6.orig/kernel/Makefile	2007-05-11 15:15:01.000000000 +0200
+++ linux-2.6/kernel/Makefile	2007-05-12 08:40:59.000000000 +0200
@@ -8,7 +8,8 @@ obj-y     = sched.o fork.o exec_domain.o
 	    signal.o sys.o kmod.o workqueue.o pid.o \
 	    rcupdate.o extable.o params.o posix-timers.o \
 	    kthread.o wait.o kfifo.o sys_ni.o posix-cpu-timers.o mutex.o \
-	    hrtimer.o rwsem.o latency.o nsproxy.o srcu.o die_notifier.o
+	    hrtimer.o rwsem.o latency.o nsproxy.o srcu.o die_notifier.o \
+	    rwmutex.o
 
 obj-$(CONFIG_STACKTRACE) += stacktrace.o
 obj-y += time/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
