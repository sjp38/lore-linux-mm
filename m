Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B27D66B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 02:53:03 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kp14so4753132pab.38
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 23:53:03 -0700 (PDT)
Received: by mail-ee0-f45.google.com with SMTP id c50so2946852eek.32
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 23:52:59 -0700 (PDT)
Date: Wed, 25 Sep 2013 08:52:56 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v5 6/6] rwsem: do optimistic spinning for writer lock
 acquisition
Message-ID: <20130925065256.GA27960@gmail.com>
References: <cover.1380057198.git.tim.c.chen@linux.intel.com>
 <1380061373.3467.55.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1380061373.3467.55.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>


just a few style nitpicks:

>  
> +static inline int rwsem_try_write_lock(long count, struct rw_semaphore *sem)
> +{
> +	if (!(count & RWSEM_ACTIVE_MASK)) {
> +		/* Try acquiring the write lock. */
> +		if (sem->count == RWSEM_WAITING_BIAS &&
> +		    cmpxchg(&sem->count, RWSEM_WAITING_BIAS,
> +			    RWSEM_ACTIVE_WRITE_BIAS) == RWSEM_WAITING_BIAS) {
> +			if (!list_is_singular(&sem->wait_list))
> +				rwsem_atomic_update(RWSEM_WAITING_BIAS, sem);
> +			return 1;
> +		}
> +	}
> +	return 0;
> +}
> +static inline int rwsem_try_write_lock_unqueued(struct rw_semaphore *sem)
> +{
> +	long count;
> +
> +	count = ACCESS_ONCE(sem->count);
> +retry:
> +	if (count == RWSEM_WAITING_BIAS) {
> +		count = cmpxchg(&sem->count, RWSEM_WAITING_BIAS,
> +			    RWSEM_ACTIVE_WRITE_BIAS + RWSEM_WAITING_BIAS);
> +		/* allow write lock stealing, try acquiring the write lock. */
> +		if (count == RWSEM_WAITING_BIAS)
> +			goto acquired;
> +		else if (count == 0)
> +			goto retry;
> +	} else if (count == 0) {
> +		count = cmpxchg(&sem->count, 0,
> +			    RWSEM_ACTIVE_WRITE_BIAS);

So, you factored this out from within a deeply nested piece of code - but 
the ugly line-break still remained - that can now be put into a single 
line.

> +		if (count == 0)
> +			goto acquired;
> +		else if (count == RWSEM_WAITING_BIAS)
> +			goto retry;
> +	}
> +	return 0;
> +
> +acquired:
> +	return 1;
> +}
> +
> +

Unnecessary newline.

> +static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
> +{
> +	int retval;
> +	struct task_struct *owner;
> +
> +	rcu_read_lock();
> +	owner = ACCESS_ONCE(sem->owner);
> +
> +	/* Spin only if active writer running */
> +	if (owner)
> +		retval = owner->on_cpu;
> +	else
> +		retval = false;
> +
> +	rcu_read_unlock();
> +	/*
> +	 * if lock->owner is not set, the sem owner may have just acquired
> +	 * it and not set the owner yet, or the sem has been released, or
> +	 * reader active.
> +	 */
> +	return retval;
> +}
> +
> +static inline bool owner_running(struct rw_semaphore *lock,
> +				struct task_struct *owner)
> +{
> +	if (lock->owner != owner)
> +		return false;
> +
> +	/*
> +	 * Ensure we emit the owner->on_cpu, dereference _after_ checking
> +	 * lock->owner still matches owner, if that fails, owner might
> +	 * point to free()d memory, if it still matches, the rcu_read_lock()
> +	 * ensures the memory stays valid.
> +	 */
> +	barrier();
> +
> +	return owner->on_cpu;
> +}
> +
> +static noinline
> +int rwsem_spin_on_owner(struct rw_semaphore *lock, struct task_struct *owner)
> +{
> +	rcu_read_lock();
> +	while (owner_running(lock, owner)) {
> +		if (need_resched())
> +			break;
> +
> +		arch_mutex_cpu_relax();
> +	}
> +	rcu_read_unlock();
> +
> +	/*
> +	 * We break out the loop above on need_resched() or when the
> +	 * owner changed, which is a sign for heavy contention. Return
> +	 * success only when lock->owner is NULL.
> +	 */
> +	return lock->owner == NULL;
> +}
> +
> +#define MLOCK(rwsem)    ((struct mcs_spin_node **)&((rwsem)->spin_mlock))
> +
> +int rwsem_optimistic_spin(struct rw_semaphore *sem)
> +{
> +	struct	task_struct	*owner;
> +	int	ret = 0;

Those tabs look weird.

> +
> +	/* sem->wait_lock should not be held when doing optimistic spinning */
> +	if (!rwsem_can_spin_on_owner(sem))
> +		return ret;
> +
> +	preempt_disable();
> +	for (;;) {
> +		struct mcs_spin_node node;
> +
> +		mcs_spin_lock(MLOCK(sem), &node);
> +		owner = ACCESS_ONCE(sem->owner);
> +		if (owner && !rwsem_spin_on_owner(sem, owner)) {
> +			mcs_spin_unlock(MLOCK(sem), &node);
> +			break;
> +		}
> +
> +		/* wait_lock will be acquired if write_lock is obtained */
> +		if (rwsem_try_write_lock_unqueued(sem)) {
> +			mcs_spin_unlock(MLOCK(sem), &node);
> +			ret = 1;
> +			break;
> +		}
> +		mcs_spin_unlock(MLOCK(sem), &node);
> +
> +		/*
> +		 * When there's no owner, we might have preempted between the
> +		 * owner acquiring the lock and setting the owner field. If
> +		 * we're an RT task that will live-lock because we won't let
> +		 * the owner complete.
> +		 */
> +		if (!owner && (need_resched() || rt_task(current)))
> +			break;
> +
> +		/*
> +		 * The cpu_relax() call is a compiler barrier which forces
> +		 * everything in this loop to be re-loaded. We don't need
> +		 * memory barriers as we'll eventually observe the right
> +		 * values at the cost of a few extra spins.
> +		 */
> +		arch_mutex_cpu_relax();
> +

Unnecessary newline.

> +	}
> +
> +	preempt_enable();
> +	return ret;
> +}

Please move the preempt_enable() one line higher, with the extra newline 
after it - it pairs with the loop, not with the return statement.

> +
>  /*
>   * wait until we successfully acquire the write lock
>   */
>  struct rw_semaphore __sched *rwsem_down_write_failed(struct rw_semaphore *sem)
>  {
> -	long count, adjustment = -RWSEM_ACTIVE_WRITE_BIAS;
> +	long count;
>  	struct rwsem_waiter waiter;
>  	struct task_struct *tsk = current;
> +	bool waiting = true;
> +
> +	count = rwsem_atomic_update(-RWSEM_ACTIVE_WRITE_BIAS, sem);
> +	/* do optimistic spinning */
> +	if (rwsem_optimistic_spin(sem))
> +		goto done;
>  
>  	/* set up my own style of waitqueue */
>  	waiter.task = tsk;
> @@ -209,33 +376,26 @@ struct rw_semaphore __sched *rwsem_down_write_failed(struct rw_semaphore *sem)
>  
>  	raw_spin_lock_irq(&sem->wait_lock);
>  	if (list_empty(&sem->wait_list))
> -		adjustment += RWSEM_WAITING_BIAS;
> +		waiting = false;
>  	list_add_tail(&waiter.list, &sem->wait_list);
>  
>  	/* we're now waiting on the lock, but no longer actively locking */
> -	count = rwsem_atomic_update(adjustment, sem);
> +	if (waiting)
> +		count = ACCESS_ONCE(sem->count);
> +	else
> +		count = rwsem_atomic_update(RWSEM_WAITING_BIAS, sem);
>  
>  	/* If there were already threads queued before us and there are no
>  	 * active writers, the lock must be read owned; so we try to wake
>  	 * any read locks that were queued ahead of us. */

Please convert this comment to the usual style while touching the code so 
heavily.

> -	if (count > RWSEM_WAITING_BIAS &&
> -	    adjustment == -RWSEM_ACTIVE_WRITE_BIAS)
> +	if ((count > RWSEM_WAITING_BIAS) && waiting)
>  		sem = __rwsem_do_wake(sem, RWSEM_WAKE_READERS);
>  
>  	/* wait until we successfully acquire the lock */
>  	set_task_state(tsk, TASK_UNINTERRUPTIBLE);
>  	while (true) {

the pattern we typically use in that case is:

	for (;;) {

Like you did in rwsem_optimistic_spin().

There's a lot of style leeway in the kernel, but we try to 'harmonize' 
such patterns as much as possible within the same subsystem, especially 
when changing the code radically which will probably necessiate future 
detective work on this code.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
