Date: Mon, 14 May 2007 13:36:14 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 1/2] scalable rw_mutex
Message-ID: <20070514113614.GB31234@wotan.suse.de>
References: <20070511131541.992688403@chello.nl> <20070511132321.895740140@chello.nl> <20070511230023.GA449@tv-sign.ru> <1178977276.6810.59.camel@twins> <20070512160428.GA173@tv-sign.ru> <1178989068.19461.3.camel@lappy> <20070512180321.GA320@tv-sign.ru> <1179140350.6810.63.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1179140350.6810.63.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Oleg Nesterov <oleg@tv-sign.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, May 14, 2007 at 12:59:10PM +0200, Peter Zijlstra wrote:
> Changes include:
> 
>  - wmb+rmb != mb
>  - ->state folded into ->waiter
> 
> ---
> Subject: scalable rw_mutex
> 
> Scalable reader/writer lock.
> 
> Its scalable in that the read count is a percpu counter and the reader fast
> path does not write to a shared cache-line.
> 
> Its not FIFO fair, but starvation proof by alternating readers and writers.

> +#define rw_mutex_writer_wait(rw_mutex, condition)		\
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
> +void rw_mutex_read_lock_slow(struct rw_mutex *rw_mutex)
> +{
> +	struct task_struct *tsk;
> +
> +	/*
> +	 * read lock slow path;
> +	 * count the number of readers waiting on the read_mutex
> +	 */
> +	atomic_inc(&rw_mutex->read_waiters);
> +	mutex_lock(&rw_mutex->read_mutex);
> +
> +	percpu_counter_inc(&rw_mutex->readers);
> +
> +	/*
> +	 * wake up a possible write unlock; waiting for at least a single
> +	 * reader to pass before letting a new writer through.
> +	 */
> +	atomic_dec(&rw_mutex->read_waiters);
> +	tsk = rw_mutex->waiter;
> +	if (tsk)
> +		wake_up_process(tsk);
> +	mutex_unlock(&rw_mutex->read_mutex);
> +}
> +EXPORT_SYMBOL(rw_mutex_read_lock_slow);
> +
> +int __rw_mutex_read_trylock(struct rw_mutex *rw_mutex)
> +{
> +	struct task_struct *tsk;
> +
> +	percpu_counter_inc(&rw_mutex->readers);
> +	/*
> +	 * ensure the ->readers store and the ->waiter load is properly
> +	 * sequenced
> +	 */
> +	smp_mb();
> +	tsk = rw_mutex->waiter;
> +	if (unlikely(tsk)) {
> +		percpu_counter_dec(&rw_mutex->readers);
> +		/*
> +		 * ensure the ->readers store has taken place before we issue
> +		 * the wake_up
> +		 *
> +		 * XXX: or does this require an smp_wmb() and the waiter to do
> +		 *   (smp_rmb(), percpu_counter(&rw_mutex->readers) == 0)
> +		 */
> +		barrier();

The store to percpu readers AFAIKS may not become visible until after the
wakeup and therefore after the waiter checks for readers. So I think this
needs a full smp_mb, doesn't it? (you seem to have the barrier in unlock,
so I can't see what differs here).


> +		/*
> +		 * possibly wake up a writer waiting for this reference to
> +		 * disappear
> +		 */
> +		wake_up_process(tsk);

Pretty sure you need to be more careful here: the waiter might have left
the locking code and have exitted by this time, no? (ditto for the rest of
the wake_up_process calls)


> +		return 0;
> +	}
> +	return 1;
> +}
> +EXPORT_SYMBOL(__rw_mutex_read_trylock);
> +
> +void rw_mutex_read_unlock(struct rw_mutex *rw_mutex)
> +{
> +	struct task_struct *tsk;
> +
> +	rwsem_release(&rw_mutex->dep_map, 1, _RET_IP_);
> +
> +	percpu_counter_dec(&rw_mutex->readers);
> +	/*
> +	 * ensure the ->readers store and the ->waiter load is properly
> +	 * sequenced
> +	 */
> +	smp_mb();
> +	tsk = rw_mutex->waiter;
> +	if (unlikely(tsk)) {
> +		/*
> +		 * on the slow path; nudge the writer waiting for the last
> +		 * reader to go away
> +		 */
> +		wake_up_process(tsk);
> +	}
> +}
> +EXPORT_SYMBOL(rw_mutex_read_unlock);
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
> +	rw_mutex_writer_wait(rw_mutex,
> +			(percpu_counter_sum(&rw_mutex->readers) == 0));
> +}
> +EXPORT_SYMBOL(rw_mutex_write_lock_nested);
> +
> +void rw_mutex_write_unlock(struct rw_mutex *rw_mutex)
> +{
> +	int waiters;
> +
> +	might_sleep();
> +	rwsem_release(&rw_mutex->dep_map, 1, _RET_IP_);
> +
> +	/*
> +	 * let the readers rip
> +	 */
> +	waiters = atomic_read(&rw_mutex->read_waiters);
> +	mutex_unlock(&rw_mutex->read_mutex);
> +	/*
> +	 * wait for at least 1 reader to get through
> +	 */
> +	if (waiters) {
> +		rw_mutex_writer_wait(rw_mutex,
> +			(atomic_read(&rw_mutex->read_waiters) < waiters));
> +	}
> +	rw_mutex->waiter = NULL;

Hmm, if you have set rw_mutex->waiter to NULL _after_ waiting for
read_waiters to be decremented below value X, don't you have a starvation
problem?

What I believe you need to do is this:

  set_task_state(task_uninterruptible);
  rw_mutex->waiter = NULL;
  smp_mb();
  if (read_waiters >= waiters)
    schedule();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
