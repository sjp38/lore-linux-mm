Date: Fri, 11 May 2007 09:31:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] scalable rw_mutex
Message-Id: <20070511093108.495feb70.akpm@linux-foundation.org>
In-Reply-To: <20070511132321.895740140@chello.nl>
References: <20070511131541.992688403@chello.nl>
	<20070511132321.895740140@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@tv-sign.ru>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 11 May 2007 15:15:42 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Scalable reader/writer lock.
> 
> Its scalable in that the read count is a percpu counter and the reader fast
> path does not write to a shared cache-line.
> 
> Its not FIFO fair, but starvation proof by alternating readers and writers.

It looks .... surprisingly sane, given the history of these things ;)


> ---
>  include/linux/rwmutex.h |  103 +++++++++++++++++++++++++++++++++++++
>  kernel/Makefile         |    3 -
>  kernel/rwmutex.c        |  132 ++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 237 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6/include/linux/rwmutex.h
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux-2.6/include/linux/rwmutex.h	2007-05-11 14:59:09.000000000 +0200
> @@ -0,0 +1,103 @@
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
> +	unsigned int		status;
> +
> +	/* The following variables are only for the slowpath */
> +	struct mutex		read_mutex;	/* r -> w waiting */
> +	struct mutex		write_mutex;	/* w -> w waiting */
> +	wait_queue_head_t	wait_queue;	/* w -> r waiting */
> +	atomic_t		read_waiters;
> +
> +#ifdef CONFIG_DEBUG_LOCK_ALLOC
> +	struct lockdep_map dep_map;
> +#endif
> +};
>

A nice comment describing the overall design and the runtime dynamics and
the lock's characteristics would be useful.  It should include a prominent
description of the lock's storage requirements, which are considerable.

> +extern void __rw_mutex_init(struct rw_mutex *rw_mutex, const char * name,
> +		struct lock_class_key *key);
> +extern void rw_mutex_destroy(struct rw_mutex *rw_mutex);

Sometimes you use `extern'.

> +#define rw_mutex_init(rw_mutex)					\
> +	do {							\
> +		static struct lock_class_key __key;		\
> +		__rw_mutex_init((rw_mutex), #rw_mutex, &__key);	\
> +	} while (0)
> +
> +extern void __rw_mutex_read_lock(struct rw_mutex *rw_mutex);
> +
> +extern void rw_mutex_write_lock_nested(struct rw_mutex *rw_mutex, int subclass);
> +extern void rw_mutex_write_unlock(struct rw_mutex *rw_mutex);
> +
> +static inline unsigned int __rw_mutex_reader_slow(struct rw_mutex *rw_mutex)
> +{
> +	unsigned int ret;
> +
> +	smp_rmb();
> +	ret = rw_mutex->status;
> +
> +	return ret;
> +}

An undocumented barrier!

> +static inline int __rw_mutex_read_trylock(struct rw_mutex *rw_mutex)
> +{
> +	preempt_disable();
> +	if (likely(!__rw_mutex_reader_slow(rw_mutex))) {
> +		percpu_counter_mod(&rw_mutex->readers, 1);
> +		preempt_enable();
> +		return 1;
> +	}
> +	preempt_enable();
> +	return 0;
> +}

What does the preempt_disable() do?

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
> +		__rw_mutex_read_lock(rw_mutex);
> +}
> +
> +void rw_mutex_read_unlock(struct rw_mutex *rw_mutex);

and other times you don't use extern.  I think it's pretty pointless
personally.

> +EXPORT_SYMBOL_GPL(__rw_mutex_init);

down_foo(mmap_sem) was previously accessible to non-gpl modules, so the GPL
export might be a problem.

> +
> +void rw_mutex_destroy(struct rw_mutex *rw_mutex)
> +{
> +	percpu_counter_destroy(&rw_mutex->readers);
> +	mutex_destroy(&rw_mutex->read_mutex);
> +	mutex_destroy(&rw_mutex->write_mutex);
> +}
> +EXPORT_SYMBOL_GPL(rw_mutex_destroy);
> +
> +void __rw_mutex_read_lock(struct rw_mutex *rw_mutex)
> +{
> +	/*
> +	 * read lock slow path;
> +	 * count the number of readers waiting on the read_mutex
> +	 */
> +	atomic_inc(&rw_mutex->read_waiters);
> +	mutex_lock(&rw_mutex->read_mutex);
> +	/*
> +	 * rw_mutex->state is only set while the read_mutex is held
> +	 * so by serialising on this lock, we're sure its free.
> +	 */
> +	BUG_ON(rw_mutex->status);
> +	/*
> +	 * take the read reference, and drop the read_waiters count
> +	 * and nudge all those waiting on the read_waiters count.
> +	 */
> +	percpu_counter_mod(&rw_mutex->readers, 1);
> +	atomic_dec(&rw_mutex->read_waiters);
> +	wake_up_all(&rw_mutex->wait_queue);
> +	mutex_unlock(&rw_mutex->read_mutex);
> +}
> +EXPORT_SYMBOL_GPL(__rw_mutex_read_lock);

hm, I'm surprised that any foo_lock() would ever wake anyone up.

> +void rw_mutex_read_unlock(struct rw_mutex *rw_mutex)
> +{
> +	rwsem_release(&rw_mutex->dep_map, 1, _RET_IP_);
> +
> +	percpu_counter_mod(&rw_mutex->readers, -1);

percpu_counter_dec()?

> +	if (unlikely(__rw_mutex_reader_slow(rw_mutex)) &&
> +			percpu_counter_sum(&rw_mutex->readers) == 0)
> +		wake_up_all(&rw_mutex->wait_queue);
> +}
> +EXPORT_SYMBOL_GPL(rw_mutex_read_unlock);

yipes.  percpu_counter_sum() is expensive.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
