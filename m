Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4FIqLAt031461
	for <linux-mm@kvack.org>; Tue, 15 May 2007 14:52:21 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4FIqLt5547016
	for <linux-mm@kvack.org>; Tue, 15 May 2007 14:52:21 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4FIqLKD012256
	for <linux-mm@kvack.org>; Tue, 15 May 2007 14:52:21 -0400
Date: Tue, 15 May 2007 11:52:20 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] scalable rw_mutex
Message-ID: <20070515185220.GH9884@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20070511230023.GA449@tv-sign.ru> <1178977276.6810.59.camel@twins> <20070512160428.GA173@tv-sign.ru> <1178989068.19461.3.camel@lappy> <20070512180321.GA320@tv-sign.ru> <1179140350.6810.63.camel@twins> <20070515003619.GC9273@linux.vnet.ibm.com> <1179215037.6810.127.camel@twins> <20070515152950.GC9884@linux.vnet.ibm.com> <1179245844.7173.5.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1179245844.7173.5.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Oleg Nesterov <oleg@tv-sign.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, May 15, 2007 at 06:17:24PM +0200, Peter Zijlstra wrote:
> On Tue, 2007-05-15 at 08:29 -0700, Paul E. McKenney wrote:
> 
> > My concern would be the possibility that someone else also woke the
> > sleeper up just as we were preparing to do so.  This might happen in
> > the case where multiple readers executed this code simultaneously.
> > Seems to me that this might be vulnerable to the following sequence
> > of events:
> > 
> > 1.	Reader-wannabe #1 wakes up the writer.
> > 
> > 2.	The writer wakes up and sees that the sum of the per-cpu
> > 	counters is still non-zero, due to the presence of
> > 	reader-wannabe #2.
> > 
> > 3.	Reader-wannabe #2 decrements its counter.  Note that
> > 	reader-wannabe #2 could do all the memory barriers it
> > 	wanted -- this vulnerability would still exist.
> > 
> > 4.	Reader-wannabe #2 wakes up the writer, which has no effect,
> > 	since the writer is already awake (but is perhaps preempted,
> > 	interrupted, or something).
> > 
> > 5.	The writer goes to sleep, never to awaken again (unless some
> > 	other reader comes along, which might or might not happen).
> > 
> > Or am I missing something here?
> 
> Ugh, nasty. Will have to ponder this a bit. It looks like a spinlock is
> needed somewhere.

Ah -- the usual approach is for the writer to hold a spinlock across
the initial check, the prepare_to_wait(), and last-minute re-checks to
see if blocking is still warranted. Then drop the lock, call schedule(),
and call finish_wait().

The reader would hold this same spinlock across both the change that
would prevent the writer from sleeping and the wake-up call.

Then if the reader shows up just after the writer drops the lock, the
reader's wakeup is guaranteed to do something useful.  If two readers show
up, they cannot run concurrently, so the above situation cannot occur.

There are a number of variations on this theme.  Easy to get wrong,
though -- I have proven that to myself more times than I care to admit...

						Thanx, Paul

> In the mean time, here is the latest code I have:
> 
> ----
> Subject: scalable rw_mutex
> 
> Scalable reader/writer lock.
> 
> Its scalable in that the read count is a percpu counter and the reader fast
> path does not write to a shared cache-line.
> 
> Its not FIFO fair, but starvation proof by alternating readers and writers.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  include/linux/rwmutex.h |   82 ++++++++++++++++
>  kernel/Makefile         |    3 
>  kernel/rwmutex.c        |  240 ++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 324 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6/include/linux/rwmutex.h
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux-2.6/include/linux/rwmutex.h	2007-05-15 09:58:03.000000000 +0200
> @@ -0,0 +1,82 @@
> +/*
> + * Scalable reader/writer lock.
> + *
> + *  Copyright (C) 2007 Red Hat, Inc., Peter Zijlstra <pzijlstr@redhat.com>
> + *
> + * This file contains the public data structure and API definitions.
> + */
> +#ifndef _LINUX_RWMUTEX_H
> +#define _LINUX_RWMUTEX_H
> +
> +#include <linux/preempt.h>
> +#include <linux/wait.h>
> +#include <linux/percpu_counter.h>
> +#include <linux/lockdep.h>
> +#include <linux/mutex.h>
> +#include <asm/atomic.h>
> +
> +struct rw_mutex {
> +	/* Read mostly global */
> +	struct percpu_counter	readers;
> +
> +	/* The following variables are only for the slowpath */
> +	struct task_struct	*waiter;	/* w -> r waiting */
> +	struct mutex		read_mutex;	/* r -> w waiting */
> +	struct mutex		write_mutex;	/* w -> w waiting */
> +	atomic_t		reader_seq;
> +
> +#ifdef CONFIG_DEBUG_LOCK_ALLOC
> +	struct lockdep_map dep_map;
> +#endif
> +};
> +
> +void __rw_mutex_init(struct rw_mutex *rw_mutex, const char * name,
> +		struct lock_class_key *key);
> +void rw_mutex_destroy(struct rw_mutex *rw_mutex);
> +
> +#define rw_mutex_init(rw_mutex)					\
> +	do {							\
> +		static struct lock_class_key __key;		\
> +		__rw_mutex_init((rw_mutex), #rw_mutex, &__key);	\
> +	} while (0)
> +
> +void rw_mutex_read_lock_slow(struct rw_mutex *rw_mutex);
> +
> +void rw_mutex_write_lock_nested(struct rw_mutex *rw_mutex, int subclass);
> +void rw_mutex_write_unlock(struct rw_mutex *rw_mutex);
> +
> +int __rw_mutex_read_trylock(struct rw_mutex *rw_mutex);
> +
> +static inline int rw_mutex_read_trylock(struct rw_mutex *rw_mutex)
> +{
> +	int ret = __rw_mutex_read_trylock(rw_mutex);
> +	if (ret)
> +		rwsem_acquire_read(&rw_mutex->dep_map, 0, 1, _RET_IP_);
> +	return ret;
> +}
> +
> +static inline void rw_mutex_read_lock(struct rw_mutex *rw_mutex)
> +{
> +	int ret;
> +
> +	might_sleep();
> +	rwsem_acquire_read(&rw_mutex->dep_map, 0, 0, _RET_IP_);
> +
> +	ret = __rw_mutex_read_trylock(rw_mutex);
> +	if (!ret)
> +		rw_mutex_read_lock_slow(rw_mutex);
> +}
> +
> +void rw_mutex_read_unlock(struct rw_mutex *rw_mutex);
> +
> +static inline int rw_mutex_is_locked(struct rw_mutex *rw_mutex)
> +{
> +	return mutex_is_locked(&rw_mutex->write_mutex);
> +}
> +
> +static inline void rw_mutex_write_lock(struct rw_mutex *rw_mutex)
> +{
> +	rw_mutex_write_lock_nested(rw_mutex, 0);
> +}
> +
> +#endif /* _LINUX_RWMUTEX_H */
> Index: linux-2.6/kernel/rwmutex.c
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux-2.6/kernel/rwmutex.c	2007-05-15 11:32:07.000000000 +0200
> @@ -0,0 +1,240 @@
> +/*
> + * Scalable reader/writer lock.
> + *
> + *  Copyright (C) 2007 Red Hat, Inc., Peter Zijlstra <pzijlstr@redhat.com>
> + *
> + * Its scalable in that the read count is a percpu counter and the reader fast
> + * path does not write to a shared cache-line.
> + *
> + * Its not FIFO fair, but starvation proof by alternating readers and writers.
> + */
> +#include <linux/sched.h>
> +#include <linux/rwmutex.h>
> +#include <linux/debug_locks.h>
> +#include <linux/module.h>
> +
> +/*
> + * rw mutex - oxymoron when we take mutex to stand for 'MUTual EXlusion'
> + *
> + * However in this context we take mutex to mean a sleeping lock, with the
> + * property that it must be released by the same context that acquired it.
> + *
> + * design goals:
> + *
> + * A sleeping reader writer lock with a scalable read side, to avoid bouncing
> + * cache-lines.
> + *
> + * dynamics:
> + *
> + * The reader fast path is modification of a percpu_counter and a read of a
> + * shared cache-line.
> + *
> + * The write side is quite heavy; it takes two mutexes, a writer mutex and a
> + * readers mutex. The writer mutex is for w <-> w interaction, the read mutex
> + * for r -> w. The read side is forced into the slow path by setting the
> + * status bit. Then it waits for all current readers to disappear.
> + *
> + * The read lock slow path; taken when the status bit is set; takes the read
> + * mutex. Because the write side also takes this mutex, the new readers are
> + * blocked. The read unlock slow path tickles the writer every time a read
> + * lock is released.
> + *
> + * Write unlock clears the status bit, and drops the read mutex; allowing new
> + * readers. It then waits for at least one waiting reader to get a lock (if
> + * there were any readers waiting) before releasing the write mutex which will
> + * allow possible other writers to come in an stop new readers, thus avoiding
> + * starvation by alternating between readers and writers
> + *
> + * considerations:
> + *
> + * The lock's space footprint is quite large (on x86_64):
> + *
> + *   88 bytes				[struct rw_mutex]
> + *    8 bytes per cpu NR_CPUS		[void *]
> + *   32 bytes per cpu (nr_cpu_ids)	[smallest slab]
> + *
> + *  408 bytes for x86_64 defconfig (NR_CPUS = 32) on a 2-way box.
> + *
> + * The write side is quite heavy; this lock is best suited for situations
> + * where the read side vastly dominates the write side.
> + */
> +
> +void __rw_mutex_init(struct rw_mutex *rw_mutex, const char *name,
> +		struct lock_class_key *key)
> +{
> +#ifdef CONFIG_DEBUG_LOCK_ALLOC
> +	debug_check_no_locks_freed((void *)rw_mutex, sizeof(*rw_mutex));
> +	lockdep_init_map(&rw_mutex->dep_map, name, key, 0);
> +#endif
> +
> +	percpu_counter_init(&rw_mutex->readers, 0);
> +	rw_mutex->waiter = NULL;
> +	mutex_init(&rw_mutex->read_mutex);
> +	mutex_init(&rw_mutex->write_mutex);
> +}
> +EXPORT_SYMBOL(__rw_mutex_init);
> +
> +void rw_mutex_destroy(struct rw_mutex *rw_mutex)
> +{
> +	percpu_counter_destroy(&rw_mutex->readers);
> +	mutex_destroy(&rw_mutex->read_mutex);
> +	mutex_destroy(&rw_mutex->write_mutex);
> +}
> +EXPORT_SYMBOL(rw_mutex_destroy);
> +
> +static inline void rw_mutex_waiter_set(struct rw_mutex *rw_mutex,
> +		struct task_struct *tsk)
> +{
> +	spin_lock(&rw_mutex->write_mutex.wait_lock);
> +	rw_mutex->waiter = tsk;
> +	spin_unlock(&rw_mutex->write_mutex.wait_lock);
> +}
> +
> +#define rw_mutex_waiter_wait(rw_mutex, condition)		\
> +do {								\
> +	struct task_struct *tsk = (rw_mutex)->waiter;		\
> +	BUG_ON(tsk != current);					\
> +								\
> +	set_task_state(tsk, TASK_UNINTERRUPTIBLE);		\
> +	while (!(condition)) {					\
> +		schedule();					\
> +		set_task_state(tsk, TASK_UNINTERRUPTIBLE);	\
> +	}							\
> +	tsk->state = TASK_RUNNING;				\
> +} while (0)
> +
> +static inline void rw_mutex_waiter_wake(struct rw_mutex *rw_mutex)
> +{
> +	spin_lock(&rw_mutex->write_mutex.wait_lock);
> +	if (rw_mutex->waiter)
> +		wake_up_process(rw_mutex->waiter);
> +	spin_unlock(&rw_mutex->write_mutex.wait_lock);
> +}
> +
> +void rw_mutex_read_lock_slow(struct rw_mutex *rw_mutex)
> +{
> +	mutex_lock(&rw_mutex->read_mutex);
> +	percpu_counter_inc(&rw_mutex->readers);
> +	/*
> +	 * wake up a possible write unlock; waiting for at least a single
> +	 * reader to pass before letting a new writer through.
> +	 */
> +	atomic_inc(&rw_mutex->reader_seq);
> +	rw_mutex_waiter_wake(rw_mutex);
> +	mutex_unlock(&rw_mutex->read_mutex);
> +}
> +EXPORT_SYMBOL(rw_mutex_read_lock_slow);
> +
> +int __rw_mutex_read_trylock(struct rw_mutex *rw_mutex)
> +{
> +	percpu_counter_inc(&rw_mutex->readers);
> +	/*
> +	 * ensure the ->readers store and the ->waiter load is properly
> +	 * sequenced
> +	 */
> +	smp_mb();
> +	if (unlikely(rw_mutex->waiter)) {
> +		percpu_counter_dec(&rw_mutex->readers);
> +		/*
> +		 * ensure the ->readers store has taken place before we issue
> +		 * the wake_up
> +		 */
> +		smp_wmb();
> +		/*
> +		 * possibly wake up a writer waiting for this reference to
> +		 * disappear
> +		 */
> +		rw_mutex_waiter_wake(rw_mutex);
> +		return 0;
> +	}
> +	return 1;
> +}
> +EXPORT_SYMBOL(__rw_mutex_read_trylock);
> +
> +void rw_mutex_read_unlock(struct rw_mutex *rw_mutex)
> +{
> +	rwsem_release(&rw_mutex->dep_map, 1, _RET_IP_);
> +
> +	percpu_counter_dec(&rw_mutex->readers);
> +	/*
> +	 * ensure the ->readers store and the ->waiter load is properly
> +	 * sequenced
> +	 */
> +	smp_mb();
> +	if (unlikely(rw_mutex->waiter)) {
> +		/*
> +		 * on the slow path; nudge the writer waiting for the last
> +		 * reader to go away
> +		 */
> +		rw_mutex_waiter_wake(rw_mutex);
> +	}
> +}
> +EXPORT_SYMBOL(rw_mutex_read_unlock);
> +
> +static inline bool rw_mutex_no_readers(struct rw_mutex *rw_mutex)
> +{
> +	/*
> +	 * match the wmb in __rw_mutex_read_trylock()
> +	 * sequence the store of ->readers vs this read.
> +	 */
> +	smp_rmb();
> +	return percpu_counter_sum(&rw_mutex->readers) == 0;
> +}
> +
> +void rw_mutex_write_lock_nested(struct rw_mutex *rw_mutex, int subclass)
> +{
> +	might_sleep();
> +	rwsem_acquire(&rw_mutex->dep_map, subclass, 0, _RET_IP_);
> +
> +	mutex_lock_nested(&rw_mutex->write_mutex, subclass);
> +	BUG_ON(rw_mutex->waiter);
> +
> +	/*
> +	 * block new readers
> +	 */
> +	mutex_lock_nested(&rw_mutex->read_mutex, subclass);
> +	rw_mutex->waiter = current;
> +	/*
> +	 * full barrier to sequence the store of ->waiter
> +	 * and the load of ->readers
> +	 */
> +	smp_mb();
> +	/*
> +	 * and wait for all current readers to go away
> +	 */
> +	rw_mutex_waiter_wait(rw_mutex, rw_mutex_no_readers(rw_mutex));
> +}
> +EXPORT_SYMBOL(rw_mutex_write_lock_nested);
> +
> +void rw_mutex_write_unlock(struct rw_mutex *rw_mutex)
> +{
> +	int seq, wait;
> +
> +	might_sleep();
> +	rwsem_release(&rw_mutex->dep_map, 1, _RET_IP_);
> +
> +	/*
> +	 * let the readers rip
> +	 *  - snapshot the reader_seq
> +	 *  - peek inside the read_mutex to see if anyone is waiting
> +	 *
> +	 * if so, we'll wait for the reader_seq to change after releasing the
> +	 * read_mutex
> +	 */
> +	seq = atomic_read(&rw_mutex->reader_seq);
> +	wait = (atomic_read(&rw_mutex->read_mutex.count) < 0);
> +	mutex_unlock(&rw_mutex->read_mutex);
> +	/*
> +	 * wait for at least 1 reader to get through
> +	 */
> +	if (wait) {
> +		rw_mutex_waiter_wait(rw_mutex,
> +			(atomic_read(&rw_mutex->reader_seq) != seq));
> +	}
> +	rw_mutex_waiter_set(rw_mutex, NULL);
> +	/*
> +	 * before we let the writers rip
> +	 */
> +	mutex_unlock(&rw_mutex->write_mutex);
> +}
> +EXPORT_SYMBOL(rw_mutex_write_unlock);
> Index: linux-2.6/kernel/Makefile
> ===================================================================
> --- linux-2.6.orig/kernel/Makefile	2007-05-14 12:53:08.000000000 +0200
> +++ linux-2.6/kernel/Makefile	2007-05-14 12:53:30.000000000 +0200
> @@ -8,7 +8,8 @@ obj-y     = sched.o fork.o exec_domain.o
>  	    signal.o sys.o kmod.o workqueue.o pid.o \
>  	    rcupdate.o extable.o params.o posix-timers.o \
>  	    kthread.o wait.o kfifo.o sys_ni.o posix-cpu-timers.o mutex.o \
> -	    hrtimer.o rwsem.o latency.o nsproxy.o srcu.o die_notifier.o
> +	    hrtimer.o rwsem.o latency.o nsproxy.o srcu.o die_notifier.o \
> +	    rwmutex.o
> 
>  obj-$(CONFIG_STACKTRACE) += stacktrace.o
>  obj-y += time/
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
