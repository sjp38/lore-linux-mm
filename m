Subject: Re: [PATCH 1/2] scalable rw_mutex
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070511230023.GA449@tv-sign.ru>
References: <20070511131541.992688403@chello.nl>
	 <20070511132321.895740140@chello.nl>  <20070511230023.GA449@tv-sign.ru>
Content-Type: text/plain
Date: Sat, 12 May 2007 09:39:34 +0200
Message-Id: <1178955574.6810.50.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oleg Nesterov <oleg@tv-sign.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Sat, 2007-05-12 at 03:00 +0400, Oleg Nesterov wrote:
> On 05/11, Peter Zijlstra wrote:
> > 
> > +static inline int __rw_mutex_read_trylock(struct rw_mutex *rw_mutex)
> > +{
> > +	preempt_disable();
> > +	if (likely(!__rw_mutex_reader_slow(rw_mutex))) {
> 
> 	--- WINDOW ---
> 
> > +		percpu_counter_mod(&rw_mutex->readers, 1);
> > +		preempt_enable();
> > +		return 1;
> > +	}
> > +	preempt_enable();
> > +	return 0;
> > +}

Yeah, I found that one when Andrew asked me about that preempt_disable()
thing.

How about:

int __rw_mutex_read_trylock(struct rw_mutex *rw_mutex)
{
	percpu_counter_inc(&rw_mutex->readers);
	if (unlikely(rw_mutex_reader_slow(rw_mutex))) {
		percpu_counter_dec(&rw_mutex->readers);
		/*
		 * possibly wake up a writer waiting for this reference to
		 * disappear
		 */
		wake_up(&rw_mutex->wait_queue);
		return 0;
	}
	return 1;
}


> > [...snip...]
> >
> > +void rw_mutex_write_lock_nested(struct rw_mutex *rw_mutex, int subclass)
> > +{
> > [...snip...]
> > +
> > +	/*
> > +	 * block new readers
> > +	 */
> > +	__rw_mutex_status_set(rw_mutex, RW_MUTEX_READER_SLOW);
> > +	/*
> > +	 * wait for all readers to go away
> > +	 */
> > +	wait_event(rw_mutex->wait_queue,
> > +			(percpu_counter_sum(&rw_mutex->readers) == 0));
> > +}
> 
> This look a bit suspicious, can't mutex_write_lock() set RW_MUTEX_READER_SLOW
> and find percpu_counter_sum() == 0 in that WINDOW above?

Indeed; however with the above having the reverse sequence this has, it
should be closed no?

> > +void rw_mutex_read_unlock(struct rw_mutex *rw_mutex)
> > +{
> > +     rwsem_release(&rw_mutex->dep_map, 1, _RET_IP_);
> > +
> > +     percpu_counter_mod(&rw_mutex->readers, -1);
> > +     if (unlikely(__rw_mutex_reader_slow(rw_mutex)) &&
> > +                     percpu_counter_sum(&rw_mutex->readers) == 0)

I took out the percpu_counter_sum()

> > +             wake_up_all(&rw_mutex->wait_queue);
> > +}
> 
> The same. __rw_mutex_status_set()->wmb() in rw_mutex_write_lock below
> is not enough. percpu_counter_mod() doesn't take fbc->lock if < FBC_BATCH,
> so we don't have a proper serialization.
> 
> write_lock() sets RW_MUTEX_READER_SLOW, finds percpu_counter_sum() != 0,
> and sleeps. rw_mutex_read_unlock() decrements cpu-local var, does not
> see RW_MUTEX_READER_SLOW and skips wake_up_all().

write lock              read lock               read unlock

a) state = slow         1) readers++            I)  readers--
b) wait(readers == 0)   2) if (state == slow)   II) if (state == slow)

That looks pretty safe to me; however are you suggesting the
percpu_counter_inc() needs some sort of barrier in order to be reliably
picked up by the percpu_counter_sum()?

something like this:

percpu_counter_{inc,dec}
smp_wmb()

vs

smp_rmb()
percpu_counter_sum(()

> > +void rw_mutex_write_lock_nested(struct rw_mutex *rw_mutex, int subclass)
> > +{
> > +	might_sleep();
> > +	rwsem_acquire(&rw_mutex->dep_map, subclass, 0, _RET_IP_);
> > +
> > +	mutex_lock_nested(&rw_mutex->write_mutex, subclass);
> > +	mutex_lock_nested(&rw_mutex->read_mutex, subclass);
> > +
> > +	/*
> > +	 * block new readers
> > +	 */
> > +	__rw_mutex_status_set(rw_mutex, RW_MUTEX_READER_SLOW);
> > +	/*
> > +	 * wait for all readers to go away
> > +	 */
> > +	wait_event(rw_mutex->wait_queue,
> > +			(percpu_counter_sum(&rw_mutex->readers) == 0));
> > +}
> > +
> > +void rw_mutex_write_unlock(struct rw_mutex *rw_mutex)
> > +{
> > +	int waiters;
> > +
> > +	rwsem_release(&rw_mutex->dep_map, 1, _RET_IP_);
> > +
> > +	/*
> > +	 * let the readers rip
> > +	 */
> > +	__rw_mutex_status_set(rw_mutex, RW_MUTEX_READER_FAST);
> > +	waiters = atomic_read(&rw_mutex->read_waiters);
> > +	mutex_unlock(&rw_mutex->read_mutex);
> > +	/*
> > +	 * wait for at least 1 reader to get through
> > +	 */
> > +	if (waiters) {
> > +		wait_event(rw_mutex->wait_queue,
> > +			(atomic_read(&rw_mutex->read_waiters) < waiters));
> > +	}
> > +	/*
> > +	 * before we let the writers rip
> > +	 */
> > +	mutex_unlock(&rw_mutex->write_mutex);
> > +}
> 
> Looks like we can have only one task on rw_mutex->wait_queue, and it holds
> ->write_mutex. Can't we use just a "task_struct *write_waiter" instead of
> ->wait_queue ? This makes rw_mutex smaller.

Good point; I'll try and figure out how to sleep and wake a single task
without the waitqueue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
