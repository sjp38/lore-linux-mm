Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 79D346B0031
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 17:58:12 -0400 (EDT)
Subject: Re: [PATCH 2/2] rwsem: do optimistic spinning for writer lock
 acquisition
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <51C558E2.1040108@hurleysoftware.com>
References: <cover.1371855277.git.tim.c.chen@linux.intel.com>
	 <1371858700.22432.5.camel@schen9-DESK>
	 <51C558E2.1040108@hurleysoftware.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 24 Jun 2013 14:58:12 -0700
Message-ID: <1372111092.22432.84.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Hurley <peter@hurleysoftware.com>
Cc: Alex Shi <alex.shi@intel.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Sat, 2013-06-22 at 03:57 -0400, Peter Hurley wrote:
> Will this spin for full scheduler value on a reader-owned lock?
> 
> > +		/* wait_lock will be acquired if write_lock is obtained */
> > +		if (rwsem_try_write_lock(sem->count, true, sem)) {
> > +			ret = 1;
> > +			goto out;
> > +		}
> > +
> > +		/*
> > +		 * When there's no owner, we might have preempted between the
>                                                          ^^^^^^^^
> 
> Isn't pre-emption disabled?
> 

Peter, on further review, this code is needed.  This code guard against 
the case of this thread preempting another thread in the middle
of setting the  owner field.  Disabling preemption does not prevent this
thread from preempting others, even though others cannot preempt 
this thread.


> 
> > +		 * owner acquiring the lock and setting the owner field. If
> > +		 * we're an RT task that will live-lock because we won't let
> > +		 * the owner complete.
> > +		 */
> > +		if (!owner && (need_resched() || rt_task(current)))
> > +			break;
> > +
> > +		/*
> > +		 * The cpu_relax() call is a compiler barrier which forces
> > +		 * everything in this loop to be re-loaded. We don't need
> > +		 * memory barriers as we'll eventually observe the right
> > +		 * values at the cost of a few extra spins.
> > +		 */
> > +		arch_mutex_cpu_relax();
> > +
> > +	}
> > +
> > +out:
> > +	preempt_enable();
> > +	return ret;
> > +}
> > +#endif
> > +
> >   /*
> >    * wait until we successfully acquire the write lock
> >    */
> > @@ -200,6 +326,9 @@ struct rw_semaphore __sched *rwsem_down_write_failed(struct rw_semaphore *sem)
> >   	long count, adjustment = -RWSEM_ACTIVE_WRITE_BIAS;
> >   	struct rwsem_waiter waiter;
> >   	struct task_struct *tsk = current;
> > +#ifdef CONFIG_RWSEM_SPIN_ON_WRITE_OWNER
> > +	bool try_optimistic_spin = true;
> > +#endif
> >
> >   	/* set up my own style of waitqueue */
> >   	waiter.task = tsk;
> > @@ -223,20 +352,17 @@ struct rw_semaphore __sched *rwsem_down_write_failed(struct rw_semaphore *sem)
> >   	/* wait until we successfully acquire the lock */
> >   	set_task_state(tsk, TASK_UNINTERRUPTIBLE);
> >   	while (true) {
> > -		if (!(count & RWSEM_ACTIVE_MASK)) {
> > -			/* Try acquiring the write lock. */
> > -			count = RWSEM_ACTIVE_WRITE_BIAS;
> > -			if (!list_is_singular(&sem->wait_list))
> > -				count += RWSEM_WAITING_BIAS;
> > -
> > -			if (sem->count == RWSEM_WAITING_BIAS &&
> > -			    cmpxchg(&sem->count, RWSEM_WAITING_BIAS, count) ==
> > -							RWSEM_WAITING_BIAS)
> > -				break;
> > -		}
> > +		if (rwsem_try_write_lock(count, false, sem))
> > +			break;
> >
> >   		raw_spin_unlock_irq(&sem->wait_lock);
> >
> > +#ifdef CONFIG_RWSEM_SPIN_ON_WRITE_OWNER
> > +		/* do optimistic spinning */
> > +		if (try_optimistic_spin && rwsem_optimistic_spin(sem))
> > +			break;
> > +		try_optimistic_spin = false;
> > +#endif
> >   		/* Block until there are no active lockers. */
> >   		do {
> >   			schedule();
> 

Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
