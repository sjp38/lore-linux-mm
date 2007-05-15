Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4FFTqCV002119
	for <linux-mm@kvack.org>; Tue, 15 May 2007 11:29:52 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4FFTqx5549800
	for <linux-mm@kvack.org>; Tue, 15 May 2007 11:29:52 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4FFTpHF028970
	for <linux-mm@kvack.org>; Tue, 15 May 2007 11:29:51 -0400
Date: Tue, 15 May 2007 08:29:50 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] scalable rw_mutex
Message-ID: <20070515152950.GC9884@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20070511131541.992688403@chello.nl> <20070511132321.895740140@chello.nl> <20070511230023.GA449@tv-sign.ru> <1178977276.6810.59.camel@twins> <20070512160428.GA173@tv-sign.ru> <1178989068.19461.3.camel@lappy> <20070512180321.GA320@tv-sign.ru> <1179140350.6810.63.camel@twins> <20070515003619.GC9273@linux.vnet.ibm.com> <1179215037.6810.127.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1179215037.6810.127.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Oleg Nesterov <oleg@tv-sign.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, May 15, 2007 at 09:43:57AM +0200, Peter Zijlstra wrote:
> On Mon, 2007-05-14 at 17:36 -0700, Paul E. McKenney wrote:
> > On Mon, May 14, 2007 at 12:59:10PM +0200, Peter Zijlstra wrote:
> > > Changes include:
> > > 
> > >  - wmb+rmb != mb
> > >  - ->state folded into ->waiter
> > > 
> > > ---
> > > Subject: scalable rw_mutex
> > > 
> > > Scalable reader/writer lock.
> > > 
> > > Its scalable in that the read count is a percpu counter and the reader fast
> > > path does not write to a shared cache-line.
> > > 
> > > Its not FIFO fair, but starvation proof by alternating readers and writers.
> > 
> > Hmmm...  brlock reincarnates, but as sleeplock.  ;-)
> 
> /me googles... ooh, yeah, quite similar.
> 
> > I believe that there are a few severe problems in this code, search
> > for "!!!" to quickly find the specific areas that concern me.
> 
> Thanks for the feedback, replies at the !!! sites.
> 
> > 						Thanx, Paul
> > 
> > > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > > ---
> > >  include/linux/rwmutex.h |   82 ++++++++++++++++
> > >  kernel/Makefile         |    3 
> > >  kernel/rwmutex.c        |  232 ++++++++++++++++++++++++++++++++++++++++++++++++
> > >  3 files changed, 316 insertions(+), 1 deletion(-)
> > 
> > List of races that must be resolved:
> > 
> > 1.	Read acquire vs. write acquire.
> > 
> > 	rw_mutex_read_lock() invokes __rw_mutex_read_trylock(), if
> > 		this fails, invokes rw_mutex_read_lock_slow().
> > 
> > 		__rw_mutex_read_trylock() increments the per-CPU counter,
> > 			does smp_mb(), picks up ->waiter:
> > 				if non-NULL decrements the per-CPU
> > 				counter, does a barrier(), does
> > 				wake_up_process() on the task fetched
> > 				from ->waiter.  Return failure.
> > 
> > 				Otherwise, return success.
> > 
> > 		rw_mutex_read_lock_slow() increments ->read_waiters,
> > 			acquires ->read_mutex, increments the ->readers
> > 			counter, and decrements the ->read_waiters
> > 			counter.  It then fetches ->waiter, and, if
> > 			non-NULL, wakes up the tasks.
> > 			Either way, releases ->read_mutex.
> > 
> > 	rw_mutex_write_lock_nested(): acquires ->write_mutex, which
> > 		prevents any writer-writer races.  Acquires ->read_mutex,
> > 		which does -not- prevent readers from continuing to
> > 		acquire.  Sets ->waiter to current, which -does-
> > 		(eventually) stop readers.  smp_mb(), then invokes
> > 		rw_mutex_writer_wait() for the sum of the per-CPU
> > 		counters to go to zero.
> > 
> > 		!In principle, this could be indefinitely postponed,
> > 		but in practice would require an infinite number of
> > 		reading tasks, so probably OK to ignore.  ;-)
> > 		This can occur because the readers unconditionally
> > 		increment their per-CPU counters, and decrement it
> > 		only later.
> > 
> > 	The smp_mb()s currently in the reader and the writer code
> > 	forms a Dekker-algorithm-like barrier, preventing both the
> > 	reader and writer from entering their critical section, as
> > 	required.
> > 
> > 2.	Read acquire vs. write release (need to avoid reader sleeping
> > 	forever, even in the case where no one ever uses the lock again).
> > 
> > 	rw_mutex_read_lock() invokes __rw_mutex_read_trylock(), if
> > 		this fails, invokes rw_mutex_read_lock_slow().
> > 
> > 		__rw_mutex_read_trylock() increments the per-CPU counter,
> > 			does smp_mb(), picks up ->waiter:
> > 				if non-NULL decrements the per-CPU
> > 				counter, does a barrier(), does
> > 				wake_up_process() on the task fetched
> > 				from ->waiter.  Return failure.
> > 
> > 				Otherwise, return success.
> > 
> > 		rw_mutex_read_lock_slow() increments ->read_waiters,
> > 			acquires ->read_mutex, increments the ->readers
> > 			counter, and decrements the ->read_waiters
> > 			counter.  It then fetches ->waiter, and, if
> > 			non-NULL, wakes up the tasks.
> > 			Either way, releases ->read_mutex.
> > 
> > 	rw_mutex_write_unlock(): pick up ->read_waiters, release
> > 		->read_mutex, if copy of ->read_waiters was non-NULL
> > 		do slow path (but refetches ->read_waiters??? why???
> > 		[Ah -- refetched each time through the loop in the
> > 		rw_mutex_writer_wait() macro), NULL out ->waiter,
> > 		then release ->write_mutex.
> > 
> > 		Slow path: Pick up ->waiter, make sure it is us,
> > 			set state to uninterruptible, loop while
> > 			->read_waiters less than the value fetched
> > 			earlier from ->read_waiters, scheduling each time
> > 			through, set state back to running.
> > 
> > 		(!!!This is subject to indefinite postponement by a
> > 		flurry of readers, see the commentary for 
> > 		rw_mutex_write_unlock() interspersed below.)
> > 
> > 	However, the fact that ->read_mutex is unconditionally released
> > 	by the writer prevents the readers from being starved.
> > 
> > 3.	Read release vs. write acquire (similar to #2).
> > 
> > 	rw_mutex_read_unlock(): decrement the per-CPU counter, smb_mb(),
> > 		pick up ->waiter, if non-NULL, wake it up.
> > 
> > 	rw_mutex_write_lock_nested(): acquires ->write_mutex, which
> > 		prevents any writer-writer races.  Acquires ->read_mutex,
> > 		which does -not- prevent readers from continuing to
> > 		acquire.  Sets ->waiter to current, which -does-
> > 		(eventually) stop readers.  smp_mb(), then invokes
> > 		rw_mutex_writer_wait() for the sum of the per-CPU
> > 		counters to go to zero.
> > 
> > 	As written, the writer never really blocks, so omitting the
> > 	wakeup is OK.  (Failing to really block is -not- OK given realtime
> > 	processes, but more on that later.)
> > 
> > 4.	Read release vs. write release -- presumably this one cannot
> > 	happen, but wouldn't want to fall prey to complacency.  ;-)
> > 
> > 	Strangely enough, this -can- happen!!!	When the readers
> > 	indefinitely postpone writer release, the readers will also
> > 	be read-releasing...  So the readers will be needlessly waking
> > 	up the task that is trying to finish releasing the write lock.
> > 	:-/  Not a big deal in this case, but just shows to go that
> > 	when reviewing locking algorithms, you should -never- restrict
> > 	yourself to considering only things that seem possible.  ;-)
> > 
> > > Index: linux-2.6/include/linux/rwmutex.h
> > > ===================================================================
> > > --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> > > +++ linux-2.6/include/linux/rwmutex.h	2007-05-14 10:34:32.000000000 +0200
> > > @@ -0,0 +1,82 @@
> > > +/*
> > > + * Scalable reader/writer lock.
> > > + *
> > > + *  Copyright (C) 2007 Red Hat, Inc., Peter Zijlstra <pzijlstr@redhat.com>
> > > + *
> > > + * This file contains the public data structure and API definitions.
> > > + */
> > > +#ifndef _LINUX_RWMUTEX_H
> > > +#define _LINUX_RWMUTEX_H
> > > +
> > > +#include <linux/preempt.h>
> > > +#include <linux/wait.h>
> > > +#include <linux/percpu_counter.h>
> > > +#include <linux/lockdep.h>
> > > +#include <linux/mutex.h>
> > > +#include <asm/atomic.h>
> > > +
> > > +struct rw_mutex {
> > > +	/* Read mostly global */
> > > +	struct percpu_counter	readers;
> > > +
> > > +	/* The following variables are only for the slowpath */
> > > +	struct task_struct	*waiter;	/* w -> r waiting */
> > > +	struct mutex		read_mutex;	/* r -> w waiting */
> > > +	struct mutex		write_mutex;	/* w -> w waiting */
> > 
> > Priority-inheritance relationship?  Seems like this would be tough
> > to arrange while still avoiding deadlock...
> > 
> > Readers currently do boost the writer via ->read_mutex.
> > 
> > !!!
> > 
> > Writers currently do -not- boost readers.  In fact, the identities of
> > the readers are not tracked, so there is no way for the writer to tell
> > what to boost.  Admittedly, write-to-read priority boosting is quite
> > the can of worms if you allow more than one reader, but something will
> > be needed for realtime kernels.
> > 
> > A brlock-like implementation can allow boosting in both directions,
> > but has other issues (such as write-side performance even in the case
> > where there are no readers).
> 
> You could short circuit the no readers case for a full brlock like
> affair. But yeah, the write side will be horribly heavy when you have to
> take nr_cpu_ids() locks.

Yeah, I don't immediately see a good solution.  :-/

> > > +	atomic_t		read_waiters;
> > > +
> > > +#ifdef CONFIG_DEBUG_LOCK_ALLOC
> > > +	struct lockdep_map dep_map;
> > > +#endif
> > > +};
> > > +
> > > +void __rw_mutex_init(struct rw_mutex *rw_mutex, const char * name,
> > > +		struct lock_class_key *key);
> > > +void rw_mutex_destroy(struct rw_mutex *rw_mutex);
> > > +
> > > +#define rw_mutex_init(rw_mutex)					\
> > > +	do {							\
> > > +		static struct lock_class_key __key;		\
> > > +		__rw_mutex_init((rw_mutex), #rw_mutex, &__key);	\
> > > +	} while (0)
> > > +
> > > +void rw_mutex_read_lock_slow(struct rw_mutex *rw_mutex);
> > > +
> > > +void rw_mutex_write_lock_nested(struct rw_mutex *rw_mutex, int subclass);
> > > +void rw_mutex_write_unlock(struct rw_mutex *rw_mutex);
> > > +
> > > +int __rw_mutex_read_trylock(struct rw_mutex *rw_mutex);
> > > +
> > > +static inline int rw_mutex_read_trylock(struct rw_mutex *rw_mutex)
> > > +{
> > > +	int ret = __rw_mutex_read_trylock(rw_mutex);
> > > +	if (ret)
> > > +		rwsem_acquire_read(&rw_mutex->dep_map, 0, 1, _RET_IP_);
> > > +	return ret;
> > > +}
> > > +
> > > +static inline void rw_mutex_read_lock(struct rw_mutex *rw_mutex)
> > > +{
> > > +	int ret;
> > > +
> > > +	might_sleep();
> > > +	rwsem_acquire_read(&rw_mutex->dep_map, 0, 0, _RET_IP_);
> > > +
> > > +	ret = __rw_mutex_read_trylock(rw_mutex);
> > > +	if (!ret)
> > > +		rw_mutex_read_lock_slow(rw_mutex);
> > > +}
> > > +
> > > +void rw_mutex_read_unlock(struct rw_mutex *rw_mutex);
> > > +
> > > +static inline int rw_mutex_is_locked(struct rw_mutex *rw_mutex)
> > > +{
> > > +	return mutex_is_locked(&rw_mutex->write_mutex);
> > > +}
> > > +
> > > +static inline void rw_mutex_write_lock(struct rw_mutex *rw_mutex)
> > > +{
> > > +	rw_mutex_write_lock_nested(rw_mutex, 0);
> > > +}
> > > +
> > > +#endif /* _LINUX_RWMUTEX_H */
> > > Index: linux-2.6/kernel/rwmutex.c
> > > ===================================================================
> > > --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> > > +++ linux-2.6/kernel/rwmutex.c	2007-05-14 11:32:01.000000000 +0200
> > > @@ -0,0 +1,229 @@
> > > +/*
> > > + * Scalable reader/writer lock.
> > > + *
> > > + *  Copyright (C) 2007 Red Hat, Inc., Peter Zijlstra <pzijlstr@redhat.com>
> > > + *
> > > + * Its scalable in that the read count is a percpu counter and the reader fast
> > > + * path does not write to a shared cache-line.
> > > + *
> > > + * Its not FIFO fair, but starvation proof by alternating readers and writers.
> > > + */
> > > +#include <linux/sched.h>
> > > +#include <linux/rwmutex.h>
> > > +#include <linux/debug_locks.h>
> > > +#include <linux/module.h>
> > > +
> > > +/*
> > > + * rw mutex - oxymoron when we take mutex to stand for 'MUTual EXlusion'
> > > + *
> > > + * However in this context we take mutex to mean a sleeping lock, with the
> > > + * property that it must be released by the same context that acquired it.
> > > + *
> > > + * design goals:
> > > + *
> > > + * A sleeping reader writer lock with a scalable read side, to avoid bouncing
> > > + * cache-lines.
> > > + *
> > > + * dynamics:
> > > + *
> > > + * The reader fast path is modification of a percpu_counter and a read of a
> > > + * shared cache-line.
> > > + *
> > > + * The write side is quite heavy; it takes two mutexes, a writer mutex and a
> > > + * readers mutex. The writer mutex is for w <-> w interaction, the read mutex
> > > + * for r -> w. The read side is forced into the slow path by setting the
> > > + * status bit. Then it waits for all current readers to disappear.
> > > + *
> > > + * The read lock slow path; taken when the status bit is set; takes the read
> > > + * mutex. Because the write side also takes this mutex, the new readers are
> > > + * blocked. The read unlock slow path tickles the writer every time a read
> > > + * lock is released.
> > > + *
> > > + * Write unlock clears the status bit, and drops the read mutex; allowing new
> > > + * readers. It then waits for at least one waiting reader to get a lock (if
> > > + * there were any readers waiting) before releasing the write mutex which will
> > > + * allow possible other writers to come in an stop new readers, thus avoiding
> > > + * starvation by alternating between readers and writers
> > > + *
> > > + * considerations:
> > > + *
> > > + * The lock's space footprint is quite large (on x86_64):
> > > + *
> > > + *   88 bytes				[struct rw_mutex]
> > > + *    8 bytes per cpu NR_CPUS		[void *]
> > > + *   32 bytes per cpu (nr_cpu_ids)	[smallest slab]
> > > + *
> > > + *  408 bytes for x86_64 defconfig (NR_CPUS = 32) on a 2-way box.
> > > + *
> > > + * The write side is quite heavy; this lock is best suited for situations
> > > + * where the read side vastly dominates the write side.
> > > + */
> > > +
> > > +void __rw_mutex_init(struct rw_mutex *rw_mutex, const char *name,
> > > +		struct lock_class_key *key)
> > > +{
> > > +#ifdef CONFIG_DEBUG_LOCK_ALLOC
> > > +	debug_check_no_locks_freed((void *)rw_mutex, sizeof(*rw_mutex));
> > > +	lockdep_init_map(&rw_mutex->dep_map, name, key, 0);
> > > +#endif
> > > +
> > > +	percpu_counter_init(&rw_mutex->readers, 0);
> > > +	rw_mutex->waiter = NULL;
> > > +	mutex_init(&rw_mutex->read_mutex);
> > > +	mutex_init(&rw_mutex->write_mutex);
> > > +}
> > > +EXPORT_SYMBOL(__rw_mutex_init);
> > > +
> > > +void rw_mutex_destroy(struct rw_mutex *rw_mutex)
> > > +{
> > > +	percpu_counter_destroy(&rw_mutex->readers);
> > > +	mutex_destroy(&rw_mutex->read_mutex);
> > > +	mutex_destroy(&rw_mutex->write_mutex);
> > > +}
> > > +EXPORT_SYMBOL(rw_mutex_destroy);
> > > +
> > > +#define rw_mutex_writer_wait(rw_mutex, condition)		\
> > > +do {								\
> > > +	struct task_struct *tsk = (rw_mutex)->waiter;		\
> > > +	BUG_ON(tsk != current);					\
> > > +								\
> > > +	set_task_state(tsk, TASK_UNINTERRUPTIBLE);		\
> > > +	while (!(condition)) {					\
> > > +		schedule();					\
> > 
> > !!!
> > 
> > If there are at least as many of these scalable reader-writer locks
> > as there are CPUs, and each such lock has a realtime-priority writer
> > executing, you can have an infinite loop starving all the non-realtime
> > readers, who are then unable to ever read-release the lock, preventing
> > the writers from making progress.  Or am I missing something subtle here?
> 
> It will actually block the task. schedule() will make it sleep when
> state is uninterruptible.

Color me confused...  :-(

Sorry for the noise!!!

But there were a couple of places that I thought were correct only
because I also thought that the schedule() wasn't really blocking...

> > > +		set_task_state(tsk, TASK_UNINTERRUPTIBLE);	\
> > > +	}							\
> > > +	tsk->state = TASK_RUNNING;				\
> > > +} while (0)
> > 
> > Can't something like __wait_event() be used here?
> 
> Blame Oleg for this :-)
> He suggested I not use waitqueues since I only ever have a single
> waiter.

I will defer to Oleg on this, although I could have sworn that the
waitqueues were designed mostly for the single-waiter case.

> > > +void rw_mutex_read_lock_slow(struct rw_mutex *rw_mutex)
> > > +{
> > > +	struct task_struct *tsk;
> > > +
> > > +	/*
> > > +	 * read lock slow path;
> > > +	 * count the number of readers waiting on the read_mutex
> > > +	 */
> > > +	atomic_inc(&rw_mutex->read_waiters);
> > > +	mutex_lock(&rw_mutex->read_mutex);
> > > +
> > > +	percpu_counter_inc(&rw_mutex->readers);
> > > +
> > > +	/*
> > > +	 * wake up a possible write unlock; waiting for at least a single
> > > +	 * reader to pass before letting a new writer through.
> > > +	 */
> > > +	atomic_dec(&rw_mutex->read_waiters);
> > > +	tsk = rw_mutex->waiter;
> > > +	if (tsk)
> > > +		wake_up_process(tsk);
> > > +	mutex_unlock(&rw_mutex->read_mutex);
> > > +}
> > > +EXPORT_SYMBOL(rw_mutex_read_lock_slow);
> > > +
> > > +int __rw_mutex_read_trylock(struct rw_mutex *rw_mutex)
> > > +{
> > > +	struct task_struct *tsk;
> > > +
> > > +	percpu_counter_inc(&rw_mutex->readers);
> > > +	/*
> > > +	 * ensure the ->readers store and the ->waiter load is properly
> > > +	 * sequenced
> > > +	 */
> > > +	smp_mb();
> > > +	tsk = rw_mutex->waiter;
> > > +	if (unlikely(tsk)) {
> > > +		percpu_counter_dec(&rw_mutex->readers);
> > > +		/*
> > > +		 * ensure the ->readers store has taken place before we issue
> > > +		 * the wake_up
> > > +		 *
> > > +		 * XXX: or does this require an smp_wmb() and the waiter to do
> > > +		 *   (smp_rmb(), percpu_counter(&rw_mutex->readers) == 0)
> > 
> > I don't think that -anything- is needed here as written.  The "sleeping"
> > writers don't really block, they instead simply loop on schedule().  Of
> > course that in itself is a -really- bad idea if case of realtime-priority
> > writers...
> > 
> > So the writers need to really block, which will make the wakeup code
> > much more ticklish.  In that case, it seems to me that smp_mb() will
> > be needed here, but much will depend on the exact structure of the
> > block/wakeup scheme chosen.
> 
> It does really sleep. And Nick thinks the suggested wmb + rmb will
> suffice if I read his latest mail correctly.

My concern would be the possibility that someone else also woke the
sleeper up just as we were preparing to do so.  This might happen in
the case where multiple readers executed this code simultaneously.
Seems to me that this might be vulnerable to the following sequence
of events:

1.	Reader-wannabe #1 wakes up the writer.

2.	The writer wakes up and sees that the sum of the per-cpu
	counters is still non-zero, due to the presence of
	reader-wannabe #2.

3.	Reader-wannabe #2 decrements its counter.  Note that
	reader-wannabe #2 could do all the memory barriers it
	wanted -- this vulnerability would still exist.

4.	Reader-wannabe #2 wakes up the writer, which has no effect,
	since the writer is already awake (but is perhaps preempted,
	interrupted, or something).

5.	The writer goes to sleep, never to awaken again (unless some
	other reader comes along, which might or might not happen).

Or am I missing something here?

> > > +		barrier();
> > > +		/*
> > > +		 * possibly wake up a writer waiting for this reference to
> > > +		 * disappear
> > > +		 */
> > 
> > !!!
> > 
> > Suppose we get delayed here (preempted, interrupted, whatever) and the
> > task referenced by tsk has exited and cleaned up before we get a chance
> > to wake it up?  We might well be "waking up" some entirely different
> > data structure in that case, not?
> 
> Yes, this is a real problem, I'll borrow a spinlock from one of the
> mutexes.

Not sure exactly what you are intending to do, so will await your
next patch.  ;-)

> > > +		wake_up_process(tsk);
> > > +		return 0;
> > > +	}
> > > +	return 1;
> > > +}
> > > +EXPORT_SYMBOL(__rw_mutex_read_trylock);
> > > +
> > > +void rw_mutex_read_unlock(struct rw_mutex *rw_mutex)
> > > +{
> > > +	struct task_struct *tsk;
> > > +
> > > +	rwsem_release(&rw_mutex->dep_map, 1, _RET_IP_);
> > > +
> > > +	percpu_counter_dec(&rw_mutex->readers);
> > > +	/*
> > > +	 * ensure the ->readers store and the ->waiter load is properly
> > > +	 * sequenced
> > > +	 */
> > > +	smp_mb();
> > > +	tsk = rw_mutex->waiter;
> > > +	if (unlikely(tsk)) {
> > > +		/*
> > > +		 * on the slow path; nudge the writer waiting for the last
> > > +		 * reader to go away
> > > +		 */
> > 
> > !!!
> > 
> > What if we are delayed (interrupted, preempted, whatever) here, so that
> > the task referenced by tsk has exited and been cleaned up before we can
> > execute the following?  We could end up "waking up" the freelist, not?
> 
> idem.

Likewise.

> > > +		wake_up_process(tsk);
> > > +	}
> > > +}
> > > +EXPORT_SYMBOL(rw_mutex_read_unlock);
> > > +
> > > +void rw_mutex_write_lock_nested(struct rw_mutex *rw_mutex, int subclass)
> > > +{
> > > +	might_sleep();
> > > +	rwsem_acquire(&rw_mutex->dep_map, subclass, 0, _RET_IP_);
> > > +
> > > +	mutex_lock_nested(&rw_mutex->write_mutex, subclass);
> > > +	BUG_ON(rw_mutex->waiter);
> > > +
> > > +	/*
> > > +	 * block new readers
> > > +	 */
> > > +	mutex_lock_nested(&rw_mutex->read_mutex, subclass);
> > > +	rw_mutex->waiter = current;
> > > +	/*
> > > +	 * full barrier to sequence the store of ->waiter
> > > +	 * and the load of ->readers
> > > +	 */
> > > +	smp_mb();
> > > +	/*
> > > +	 * and wait for all current readers to go away
> > > +	 */
> > > +	rw_mutex_writer_wait(rw_mutex,
> > > +			(percpu_counter_sum(&rw_mutex->readers) == 0));
> > > +}
> > > +EXPORT_SYMBOL(rw_mutex_write_lock_nested);
> > > +
> > > +void rw_mutex_write_unlock(struct rw_mutex *rw_mutex)
> > > +{
> > > +	int waiters;
> > > +
> > > +	might_sleep();
> > > +	rwsem_release(&rw_mutex->dep_map, 1, _RET_IP_);
> > > +
> > > +	/*
> > > +	 * let the readers rip
> > > +	 */
> > > +	waiters = atomic_read(&rw_mutex->read_waiters);
> > > +	mutex_unlock(&rw_mutex->read_mutex);
> > > +	/*
> > > +	 * wait for at least 1 reader to get through
> > > +	 */
> > > +	if (waiters) {
> > > +		rw_mutex_writer_wait(rw_mutex,
> > > +			(atomic_read(&rw_mutex->read_waiters) < waiters));
> > > +	}
> > 
> > !!!
> > 
> > Readers can indefinitely postpone the write-unlock at this point.
> > Suppose that there is one reader waiting when we fetch ->read_waiters
> > above.  Suppose that as soon as the mutex is released, a large number
> > of readers arrive.  Because we have not yet NULLed ->waiter, all of
> > these readers will take the slow path, incrementing the ->read_waiters
> > counter, acquiring the ->read_mutex, and so on.  The ->read_mutex lock
> > acquisition is likely to be the bottleneck for large systems, which
> > would result in the count remaining 2 or higher indefinitely.  The
> > readers would make progress (albeit quite inefficiently), but the
> > writer would never get out of the loop in the rw_mutex_writer_wait()
> > macro.
> 
> Ah, yeah. Ouch!
> 
> I missed this detail when I got rid of ->state. I used to clear the
> reader slow path before unlocking the ->read_mutex.
> 
> > Consider instead using a generation number that just increments every
> > time a reader successfully acquires the lock and is never decremented.
> > That way, you can unambiguously determine when at least one reader has
> > made progress.  An additional counter required, but might be able to
> > multiplex with something else.  Or get rid of the current ->read_waiters
> > in favor of the generation number?  This latter seems like it should be
> > possible, at least at first glance...  Just change the name of the field,
> > get rid of the decrement, and change the comparison to "!=", right?
> 
> Yes, this seems like a very good suggestion, I'll give it a shot.
> Thanks!

NP!  (Glad I got -something- right on this one!)

> > > +	rw_mutex->waiter = NULL;
> > > +	/*
> > > +	 * before we let the writers rip
> > > +	 */
> > > +	mutex_unlock(&rw_mutex->write_mutex);
> > > +}
> > > +EXPORT_SYMBOL(rw_mutex_write_unlock);
> > > Index: linux-2.6/kernel/Makefile
> > > ===================================================================
> > > --- linux-2.6.orig/kernel/Makefile	2007-05-12 15:33:00.000000000 +0200
> > > +++ linux-2.6/kernel/Makefile	2007-05-12 15:33:02.000000000 +0200
> > > @@ -8,7 +8,8 @@ obj-y     = sched.o fork.o exec_domain.o
> > >  	    signal.o sys.o kmod.o workqueue.o pid.o \
> > >  	    rcupdate.o extable.o params.o posix-timers.o \
> > >  	    kthread.o wait.o kfifo.o sys_ni.o posix-cpu-timers.o mutex.o \
> > > -	    hrtimer.o rwsem.o latency.o nsproxy.o srcu.o die_notifier.o
> > > +	    hrtimer.o rwsem.o latency.o nsproxy.o srcu.o die_notifier.o \
> > > +	    rwmutex.o
> > > 
> > >  obj-$(CONFIG_STACKTRACE) += stacktrace.o
> > >  obj-y += time/
> > > 
> > > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
