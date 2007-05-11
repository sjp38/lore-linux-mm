Message-Id: <20070511132321.895740140@chello.nl>
References: <20070511131541.992688403@chello.nl>
Date: Fri, 11 May 2007 15:15:42 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 1/2] scalable rw_mutex
Content-Disposition: inline; filename=rwmutex.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Oleg Nesterov <oleg@tv-sign.ru>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Scalable reader/writer lock.

Its scalable in that the read count is a percpu counter and the reader fast
path does not write to a shared cache-line.

Its not FIFO fair, but starvation proof by alternating readers and writers.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/rwmutex.h |  103 +++++++++++++++++++++++++++++++++++++
 kernel/Makefile         |    3 -
 kernel/rwmutex.c        |  132 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 237 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/rwmutex.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/include/linux/rwmutex.h	2007-05-11 14:59:09.000000000 +0200
@@ -0,0 +1,103 @@
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
+	wait_queue_head_t	wait_queue;	/* w -> r waiting */
+	atomic_t		read_waiters;
+
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+	struct lockdep_map dep_map;
+#endif
+};
+
+extern void __rw_mutex_init(struct rw_mutex *rw_mutex, const char * name,
+		struct lock_class_key *key);
+extern void rw_mutex_destroy(struct rw_mutex *rw_mutex);
+
+#define rw_mutex_init(rw_mutex)					\
+	do {							\
+		static struct lock_class_key __key;		\
+		__rw_mutex_init((rw_mutex), #rw_mutex, &__key);	\
+	} while (0)
+
+extern void __rw_mutex_read_lock(struct rw_mutex *rw_mutex);
+
+extern void rw_mutex_write_lock_nested(struct rw_mutex *rw_mutex, int subclass);
+extern void rw_mutex_write_unlock(struct rw_mutex *rw_mutex);
+
+static inline unsigned int __rw_mutex_reader_slow(struct rw_mutex *rw_mutex)
+{
+	unsigned int ret;
+
+	smp_rmb();
+	ret = rw_mutex->status;
+
+	return ret;
+}
+
+static inline int __rw_mutex_read_trylock(struct rw_mutex *rw_mutex)
+{
+	preempt_disable();
+	if (likely(!__rw_mutex_reader_slow(rw_mutex))) {
+		percpu_counter_mod(&rw_mutex->readers, 1);
+		preempt_enable();
+		return 1;
+	}
+	preempt_enable();
+	return 0;
+}
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
+		__rw_mutex_read_lock(rw_mutex);
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
+++ linux-2.6/kernel/rwmutex.c	2007-05-11 15:08:39.000000000 +0200
@@ -0,0 +1,132 @@
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
+	init_waitqueue_head(&rw_mutex->wait_queue);
+}
+EXPORT_SYMBOL_GPL(__rw_mutex_init);
+
+void rw_mutex_destroy(struct rw_mutex *rw_mutex)
+{
+	percpu_counter_destroy(&rw_mutex->readers);
+	mutex_destroy(&rw_mutex->read_mutex);
+	mutex_destroy(&rw_mutex->write_mutex);
+}
+EXPORT_SYMBOL_GPL(rw_mutex_destroy);
+
+void __rw_mutex_read_lock(struct rw_mutex *rw_mutex)
+{
+	/*
+	 * read lock slow path;
+	 * count the number of readers waiting on the read_mutex
+	 */
+	atomic_inc(&rw_mutex->read_waiters);
+	mutex_lock(&rw_mutex->read_mutex);
+	/*
+	 * rw_mutex->state is only set while the read_mutex is held
+	 * so by serialising on this lock, we're sure its free.
+	 */
+	BUG_ON(rw_mutex->status);
+	/*
+	 * take the read reference, and drop the read_waiters count
+	 * and nudge all those waiting on the read_waiters count.
+	 */
+	percpu_counter_mod(&rw_mutex->readers, 1);
+	atomic_dec(&rw_mutex->read_waiters);
+	wake_up_all(&rw_mutex->wait_queue);
+	mutex_unlock(&rw_mutex->read_mutex);
+}
+EXPORT_SYMBOL_GPL(__rw_mutex_read_lock);
+
+void rw_mutex_read_unlock(struct rw_mutex *rw_mutex)
+{
+	rwsem_release(&rw_mutex->dep_map, 1, _RET_IP_);
+
+	percpu_counter_mod(&rw_mutex->readers, -1);
+	if (unlikely(__rw_mutex_reader_slow(rw_mutex)) &&
+			percpu_counter_sum(&rw_mutex->readers) == 0)
+		wake_up_all(&rw_mutex->wait_queue);
+}
+EXPORT_SYMBOL_GPL(rw_mutex_read_unlock);
+
+static inline
+void __rw_mutex_status_set(struct rw_mutex *rw_mutex, unsigned int status)
+{
+	rw_mutex->status = status;
+	/*
+	 * allow new readers to see this change in status
+	 */
+	smp_wmb();
+}
+
+void rw_mutex_write_lock_nested(struct rw_mutex *rw_mutex, int subclass)
+{
+	might_sleep();
+	rwsem_acquire(&rw_mutex->dep_map, subclass, 0, _RET_IP_);
+
+	mutex_lock_nested(&rw_mutex->write_mutex, subclass);
+	mutex_lock_nested(&rw_mutex->read_mutex, subclass);
+
+	/*
+	 * block new readers
+	 */
+	__rw_mutex_status_set(rw_mutex, RW_MUTEX_READER_SLOW);
+	/*
+	 * wait for all readers to go away
+	 */
+	wait_event(rw_mutex->wait_queue,
+			(percpu_counter_sum(&rw_mutex->readers) == 0));
+}
+EXPORT_SYMBOL_GPL(rw_mutex_write_lock_nested);
+
+void rw_mutex_write_unlock(struct rw_mutex *rw_mutex)
+{
+	int waiters;
+
+	rwsem_release(&rw_mutex->dep_map, 1, _RET_IP_);
+
+	/*
+	 * let the readers rip
+	 */
+	__rw_mutex_status_set(rw_mutex, RW_MUTEX_READER_FAST);
+	waiters = atomic_read(&rw_mutex->read_waiters);
+	mutex_unlock(&rw_mutex->read_mutex);
+	/*
+	 * wait for at least 1 reader to get through
+	 */
+	if (waiters) {
+		wait_event(rw_mutex->wait_queue,
+			(atomic_read(&rw_mutex->read_waiters) < waiters));
+	}
+	/*
+	 * before we let the writers rip
+	 */
+	mutex_unlock(&rw_mutex->write_mutex);
+}
+EXPORT_SYMBOL_GPL(rw_mutex_write_unlock);
Index: linux-2.6/kernel/Makefile
===================================================================
--- linux-2.6.orig/kernel/Makefile	2007-05-11 14:58:58.000000000 +0200
+++ linux-2.6/kernel/Makefile	2007-05-11 14:59:09.000000000 +0200
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
