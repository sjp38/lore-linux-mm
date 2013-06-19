Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 6CC886B0037
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 19:11:58 -0400 (EDT)
Message-ID: <1371683514.1783.3.camel@buesod1.americas.hpqcorp.net>
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Date: Wed, 19 Jun 2013 16:11:54 -0700
In-Reply-To: <1371514081.27102.651.camel@schen9-DESK>
References: <1371165333.27102.568.camel@schen9-DESK>
	 <1371167015.1754.14.camel@buesod1.americas.hpqcorp.net>
	 <51BD8A77.2080201@intel.com>
	 <1371486122.1778.14.camel@buesod1.americas.hpqcorp.net>
	 <51BF99B0.4040509@intel.com>
	 <1371512120.1778.40.camel@buesod1.americas.hpqcorp.net>
	 <1371514081.27102.651.camel@schen9-DESK>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Alex Shi <alex.shi@intel.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, 2013-06-17 at 17:08 -0700, Tim Chen wrote:
> On Mon, 2013-06-17 at 16:35 -0700, Davidlohr Bueso wrote:
> > On Tue, 2013-06-18 at 07:20 +0800, Alex Shi wrote:
> > > On 06/18/2013 12:22 AM, Davidlohr Bueso wrote:
> > > > After a lot of benchmarking, I finally got the ideal results for aim7,
> > > > so far: this patch + optimistic spinning with preemption disabled. Just
> > > > like optimistic spinning, this patch by itself makes little to no
> > > > difference, yet combined is where we actually outperform 3.10-rc5. In
> > > > addition, I noticed extra throughput when disabling preemption in
> > > > try_optimistic_spin().
> > > > 
> > > > With i_mmap as a rwsem and these changes I could see performance
> > > > benefits for alltests (+14.5%), custom (+17%), disk (+11%), high_systime
> > > > (+5%), shared (+15%) and short (+4%), most of them after around 500
> > > > users, for fewer users, it made little to no difference.
> > > 
> > > A pretty good number. what's the cpu number in your machine? :)
> > 
> > 8-socket, 80 cores (ht off)
> > 
> > 
> 
> David,
> 
> I wonder if you are interested to try the experimental patch below.  
> It tries to avoid unnecessary writes to the sem->count when we are 
> going to fail the down_write by executing rwsem_down_write_failed_s
> instead of rwsem_down_write_failed.  It should further reduce the
> cache line bouncing.  It didn't make a difference for my 
> workload.  Wonder if it may help yours more in addition to the 
> other two patches.  Right now the patch is an ugly hack.  I'll merge
> rwsem_down_write_failed_s and rwsem_down_write_failed into one
> function if this approach actually helps things.
> 

I tried this on top of the patches we've already been dealing with. It
actually did more harm than good. Only got a slight increase in the
five_sec workload, for the rest either no effect, or negative. So far
the best results are still with spin on owner + preempt disable + Alex's
patches.

Thanks,
Davidlohr


> I'll clean these three patches after we have some idea of their
> effectiveness.
> 
> Thanks.
> 
> Tim
> 
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> ---
> commit 04c8ad3f21861746d5b7fff55a6ef186a4dd0765
> Author: Tim Chen <tim.c.chen@linux.intel.com>
> Date:   Mon Jun 10 04:50:04 2013 -0700
> 
>     Try skip write to rwsem->count when we have active lockers
> 
> diff --git a/include/linux/rwsem.h b/include/linux/rwsem.h
> index 0616ffe..83f9184 100644
> --- a/include/linux/rwsem.h
> +++ b/include/linux/rwsem.h
> @@ -33,6 +33,7 @@ struct rw_semaphore {
>  
>  extern struct rw_semaphore *rwsem_down_read_failed(struct rw_semaphore *sem);
>  extern struct rw_semaphore *rwsem_down_write_failed(struct rw_semaphore *sem);
> +extern struct rw_semaphore *rwsem_down_write_failed_s(struct rw_semaphore *sem);
>  extern struct rw_semaphore *rwsem_wake(struct rw_semaphore *);
>  extern struct rw_semaphore *rwsem_downgrade_wake(struct rw_semaphore *sem);
>  
> diff --git a/kernel/rwsem.c b/kernel/rwsem.c
> index cfff143..188f6ea 100644
> --- a/kernel/rwsem.c
> +++ b/kernel/rwsem.c
> @@ -42,12 +42,22 @@ EXPORT_SYMBOL(down_read_trylock);
>  /*
>   * lock for writing
>   */
> +
> +static void ___down_write(struct rw_semaphore *sem)
> +{
> +	if (sem->count & RWSEM_ACTIVE_MASK) {
> +		rwsem_down_write_failed_s(sem);
> +		return;
> +	}
> +	__down_write(sem);
> +}
> +
>  void __sched down_write(struct rw_semaphore *sem)
>  {
>  	might_sleep();
>  	rwsem_acquire(&sem->dep_map, 0, 0, _RET_IP_);
>  
> -	LOCK_CONTENDED(sem, __down_write_trylock, __down_write);
> +	LOCK_CONTENDED(sem, __down_write_trylock, ___down_write);
>  }
>  
>  EXPORT_SYMBOL(down_write);
> diff --git a/lib/rwsem.c b/lib/rwsem.c
> index 19c5fa9..25143b5 100644
> --- a/lib/rwsem.c
> +++ b/lib/rwsem.c
> @@ -248,6 +248,63 @@ struct rw_semaphore __sched *rwsem_down_write_failed(struct rw_semaphore *sem)
>  	return sem;
>  }
>  
> +struct rw_semaphore __sched *rwsem_down_write_failed_s(struct rw_semaphore *sem)
> +{
> +	long count, adjustment = 0;
> +	struct rwsem_waiter waiter;
> +	struct task_struct *tsk = current;
> +
> +	/* set up my own style of waitqueue */
> +	waiter.task = tsk;
> +	waiter.type = RWSEM_WAITING_FOR_WRITE;
> +
> +	raw_spin_lock_irq(&sem->wait_lock);
> +	if (list_empty(&sem->wait_list))
> +		adjustment += RWSEM_WAITING_BIAS;
> +	list_add_tail(&waiter.list, &sem->wait_list);
> +
> +	/* If there were already threads queued before us and there are no
> +	 * active writers, the lock must be read owned; so we try to wake
> +	 * any read locks that were queued ahead of us. */
> +	if (adjustment == 0) {
> +		if (sem->count > RWSEM_WAITING_BIAS)
> +			sem = __rwsem_do_wake(sem, RWSEM_WAKE_READERS);
> +	} else
> +		count = rwsem_atomic_update(adjustment, sem);
> +
> +	/* wait until we successfully acquire the lock */
> +	set_task_state(tsk, TASK_UNINTERRUPTIBLE);
> +	while (true) {
> +		if (!(sem->count & RWSEM_ACTIVE_MASK)) {
> +			/* Try acquiring the write lock. */
> +			count = RWSEM_ACTIVE_WRITE_BIAS;
> +			if (!list_is_singular(&sem->wait_list))
> +				count += RWSEM_WAITING_BIAS;
> +
> +			if (sem->count == RWSEM_WAITING_BIAS &&
> +			    cmpxchg(&sem->count, RWSEM_WAITING_BIAS, count) ==
> +							RWSEM_WAITING_BIAS)
> +				break;
> +		}
> +
> +		raw_spin_unlock_irq(&sem->wait_lock);
> +
> +		/* Block until there are no active lockers. */
> +		do {
> +			schedule();
> +			set_task_state(tsk, TASK_UNINTERRUPTIBLE);
> +		} while ((count = sem->count) & RWSEM_ACTIVE_MASK);
> +
> +		raw_spin_lock_irq(&sem->wait_lock);
> +	}
> +
> +	list_del(&waiter.list);
> +	raw_spin_unlock_irq(&sem->wait_lock);
> +	tsk->state = TASK_RUNNING;
> +
> +	return sem;
> +}
> +
>  /*
>   * handle waking up a waiter on the semaphore
>   * - up_read/up_write has decremented the active part of count if we come here
> @@ -289,5 +346,6 @@ struct rw_semaphore *rwsem_downgrade_wake(struct rw_semaphore *sem)
>  
>  EXPORT_SYMBOL(rwsem_down_read_failed);
>  EXPORT_SYMBOL(rwsem_down_write_failed);
> +EXPORT_SYMBOL(rwsem_down_write_failed_s);
>  EXPORT_SYMBOL(rwsem_wake);
>  EXPORT_SYMBOL(rwsem_downgrade_wake);
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
