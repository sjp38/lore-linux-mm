Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 907C76B0031
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 15:59:59 -0400 (EDT)
Message-ID: <1375214394.11122.4.camel@buesod1.americas.hpqcorp.net>
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 30 Jul 2013 12:59:54 -0700
In-Reply-To: <1375143209.22432.419.camel@schen9-DESK>
References: <1372366385.22432.185.camel@schen9-DESK>
	 <1372375873.22432.200.camel@schen9-DESK> <20130628093809.GB29205@gmail.com>
	 <1372453461.22432.216.camel@schen9-DESK> <20130629071245.GA5084@gmail.com>
	 <1372710497.22432.224.camel@schen9-DESK> <20130702064538.GB3143@gmail.com>
	 <1373997195.22432.297.camel@schen9-DESK> <20130723094513.GA24522@gmail.com>
	 <20130723095124.GW27075@twins.programming.kicks-ass.net>
	 <20130723095306.GA26174@gmail.com> <1375143209.22432.419.camel@schen9-DESK>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>

cc'ing Dave Chinner for XFS

On Mon, 2013-07-29 at 17:13 -0700, Tim Chen wrote:
> On Tue, 2013-07-23 at 11:53 +0200, Ingo Molnar wrote:
> > * Peter Zijlstra <peterz@infradead.org> wrote:
> > 
> > > On Tue, Jul 23, 2013 at 11:45:13AM +0200, Ingo Molnar wrote:
> > >
> > > > Why not just try the delayed addition approach first? The spinning is 
> > > > time limited AFAICS, so we don't _have to_ recognize those as writers 
> > > > per se, only if the spinning fails and it wants to go on the waitlist. 
> > > > Am I missing something?
> > > > 
> > > > It will change patterns, it might even change the fairness balance - 
> > > > but is a legit change otherwise, especially if it helps performance.
> > > 
> > > Be very careful here. Some people (XFS) have very specific needs. Walken 
> > > and dchinner had a longish discussion on this a while back.
> > 
> > Agreed - yet it's worth at least trying it out the quick way, to see the 
> > main effect and to see whether that explains the performance assymetry and 
> > invest more effort into it.
> > 
> 
> Ingo & Peter,
> 
> Here's a patch that moved optimistic spinning of the writer lock
> acquisition before putting the writer on the wait list.  It did give me
> a 5% performance boost on my exim mail server workload. 
> It recovered a good portion of the 8% performance regression from 
> mutex implementation.
> 
> I think we are on the right track. Let me know if there's anything
> in the patch that may cause grief to XFS. 
> 
> There is some further optimization possible.  We went
> to the failed path within __down_write if the count field is non
> zero. But in fact if the old count field was RWSEM_WAITING_BIAS, 
> there's no one active and we could have stolen the
> lock when we perform our atomic op on the count field
> in __down_write. Yet we go to the failed path in the current
> code.
> 
> I will combine this change and also Alex's patches on rwsem together
> in a patchset later.
> 
> Your comments and thoughts are most welcomed.
> 
> Tim
> 
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> ---
> diff --git a/include/linux/rwsem.h b/include/linux/rwsem.h
> index 0616ffe..58a4acb 100644
> --- a/include/linux/rwsem.h
> +++ b/include/linux/rwsem.h
> @@ -29,6 +29,10 @@ struct rw_semaphore {
>  #ifdef CONFIG_DEBUG_LOCK_ALLOC
>  	struct lockdep_map	dep_map;
>  #endif
> +#ifdef CONFIG_RWSEM_SPIN_ON_WRITE_OWNER
> +	struct task_struct	*owner;
> +	void			*spin_mlock;
> +#endif
>  };
>  
>  extern struct rw_semaphore *rwsem_down_read_failed(struct rw_semaphore *sem);
> @@ -55,11 +59,21 @@ static inline int rwsem_is_locked(struct rw_semaphore *sem)
>  # define __RWSEM_DEP_MAP_INIT(lockname)
>  #endif
>  
> +#ifdef CONFIG_RWSEM_SPIN_ON_WRITE_OWNER
> +#define __RWSEM_INITIALIZER(name)			\
> +	{ RWSEM_UNLOCKED_VALUE,				\
> +	  __RAW_SPIN_LOCK_UNLOCKED(name.wait_lock),	\
> +	  LIST_HEAD_INIT((name).wait_list),		\
> +	  __RWSEM_DEP_MAP_INIT(name)			\
> +	  NULL,						\
> +	  NULL }
> +#else
>  #define __RWSEM_INITIALIZER(name)			\
>  	{ RWSEM_UNLOCKED_VALUE,				\
>  	  __RAW_SPIN_LOCK_UNLOCKED(name.wait_lock),	\
>  	  LIST_HEAD_INIT((name).wait_list)		\
>  	  __RWSEM_DEP_MAP_INIT(name) }
> +#endif
>  
>  #define DECLARE_RWSEM(name) \
>  	struct rw_semaphore name = __RWSEM_INITIALIZER(name)
> diff --git a/init/Kconfig b/init/Kconfig
> index 9d3a788..d97225f 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1595,6 +1595,16 @@ config TRACEPOINTS
>  
>  source "arch/Kconfig"
>  
> +config RWSEM_SPIN_ON_WRITE_OWNER
> +	bool "Optimistic spin write acquisition for writer owned rw-sem"
> +	default n
> +	depends on SMP
> +	help
> +	  Allows a writer to perform optimistic spinning if another writer own
> +	  the read write semaphore.  If the lock owner is running, it is likely
> +	  to release the lock soon. Spinning gives a greater chance for writer to
> +	  acquire a semaphore before putting it to sleep.
> +
>  endmenu		# General setup
>  
>  config HAVE_GENERIC_DMA_COHERENT
> diff --git a/kernel/rwsem.c b/kernel/rwsem.c
> index cfff143..a32990a 100644
> --- a/kernel/rwsem.c
> +++ b/kernel/rwsem.c
> @@ -12,6 +12,26 @@
>  
>  #include <linux/atomic.h>
>  
> +#ifdef CONFIG_RWSEM_SPIN_ON_WRITE_OWNER
> +static inline void rwsem_set_owner(struct rw_semaphore *sem)
> +{
> +	sem->owner = current;
> +}
> +
> +static inline void rwsem_clear_owner(struct rw_semaphore *sem)
> +{
> +	sem->owner = NULL;
> +}
> +#else
> +static inline void rwsem_set_owner(struct rw_semaphore *sem)
> +{
> +}
> +
> +static inline void rwsem_clear_owner(struct rw_semaphore *sem)
> +{
> +}
> +#endif
> +
>  /*
>   * lock for reading
>   */
> @@ -48,6 +68,7 @@ void __sched down_write(struct rw_semaphore *sem)
>  	rwsem_acquire(&sem->dep_map, 0, 0, _RET_IP_);
>  
>  	LOCK_CONTENDED(sem, __down_write_trylock, __down_write);
> +	rwsem_set_owner(sem);
>  }
>  
>  EXPORT_SYMBOL(down_write);
> @@ -59,8 +80,10 @@ int down_write_trylock(struct rw_semaphore *sem)
>  {
>  	int ret = __down_write_trylock(sem);
>  
> -	if (ret == 1)
> +	if (ret == 1) {
>  		rwsem_acquire(&sem->dep_map, 0, 1, _RET_IP_);
> +		rwsem_set_owner(sem);
> +	}
>  	return ret;
>  }
>  
> @@ -86,6 +109,7 @@ void up_write(struct rw_semaphore *sem)
>  	rwsem_release(&sem->dep_map, 1, _RET_IP_);
>  
>  	__up_write(sem);
> +	rwsem_clear_owner(sem);
>  }
>  
>  EXPORT_SYMBOL(up_write);
> @@ -100,6 +124,7 @@ void downgrade_write(struct rw_semaphore *sem)
>  	 * dependency.
>  	 */
>  	__downgrade_write(sem);
> +	rwsem_clear_owner(sem);
>  }
>  
>  EXPORT_SYMBOL(downgrade_write);
> @@ -122,6 +147,7 @@ void _down_write_nest_lock(struct rw_semaphore *sem, struct lockdep_map *nest)
>  	rwsem_acquire_nest(&sem->dep_map, 0, 0, nest, _RET_IP_);
>  
>  	LOCK_CONTENDED(sem, __down_write_trylock, __down_write);
> +	rwsem_set_owner(sem);
>  }
>  
>  EXPORT_SYMBOL(_down_write_nest_lock);
> @@ -141,6 +167,7 @@ void down_write_nested(struct rw_semaphore *sem, int subclass)
>  	rwsem_acquire(&sem->dep_map, subclass, 0, _RET_IP_);
>  
>  	LOCK_CONTENDED(sem, __down_write_trylock, __down_write);
> +	rwsem_set_owner(sem);
>  }
>  
>  EXPORT_SYMBOL(down_write_nested);
> diff --git a/lib/rwsem.c b/lib/rwsem.c
> index 1d6e6e8..1472ff3 100644
> --- a/lib/rwsem.c
> +++ b/lib/rwsem.c
> @@ -8,6 +8,7 @@
>   */
>  #include <linux/rwsem.h>
>  #include <linux/sched.h>
> +#include <linux/sched/rt.h>
>  #include <linux/init.h>
>  #include <linux/export.h>
>  
> @@ -27,6 +28,10 @@ void __init_rwsem(struct rw_semaphore *sem, const char *name,
>  	sem->count = RWSEM_UNLOCKED_VALUE;
>  	raw_spin_lock_init(&sem->wait_lock);
>  	INIT_LIST_HEAD(&sem->wait_list);
> +#ifdef CONFIG_RWSEM_SPIN_ON_WRITE_OWNER
> +	sem->owner = NULL;
> +	sem->spin_mlock = NULL;
> +#endif
>  }
>  
>  EXPORT_SYMBOL(__init_rwsem);
> @@ -194,48 +199,252 @@ struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
>  	return sem;
>  }
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
> +
> +#ifdef CONFIG_RWSEM_SPIN_ON_WRITE_OWNER
> +
> +struct mspin_node {
> +       struct mspin_node *next ;
> +       int               locked;       /* 1 if lock acquired */
> +};
> +#define        MLOCK(rwsem)    ((struct mspin_node **)&((rwsem)->spin_mlock))
> +
> +static noinline
> +void mspin_lock(struct mspin_node **lock, struct mspin_node *node)
> +{
> +       struct mspin_node *prev;
> +
> +       /* Init node */
> +       node->locked = 0;
> +       node->next   = NULL;
> +
> +       prev = xchg(lock, node);
> +       if (likely(prev == NULL)) {
> +               /* Lock acquired */
> +               node->locked = 1;
> +               return;
> +       }
> +       ACCESS_ONCE(prev->next) = node;
> +       smp_wmb();
> +       /* Wait until the lock holder passes the lock down */
> +       while (!ACCESS_ONCE(node->locked))
> +               arch_mutex_cpu_relax();
> +}
> +
> +static void mspin_unlock(struct mspin_node **lock, struct mspin_node *node)
> +{
> +       struct mspin_node *next = ACCESS_ONCE(node->next);
> +
> +       if (likely(!next)) {
> +               /*
> +                * Release the lock by setting it to NULL
> +                */
> +               if (cmpxchg(lock, node, NULL) == node)
> +                       return;
> +               /* Wait until the next pointer is set */
> +               while (!(next = ACCESS_ONCE(node->next)))
> +                       arch_mutex_cpu_relax();
> +       }
> +       ACCESS_ONCE(next->locked) = 1;
> +       smp_wmb();
> +}
> +
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
> +	 * We break out the loop above on need_resched() and when the
> +	 * owner changed, which is a sign for heavy contention. Return
> +	 * success only when lock->owner is NULL.
> +	 */
> +	return lock->owner == NULL;
> +}
> +
> +int rwsem_optimistic_spin(struct rw_semaphore *sem)
> +{
> +	struct	task_struct	*owner;
> +	int	ret = 0;
> +
> +	/* sem->wait_lock should not be held when doing optimistic spinning */
> +	if (!rwsem_can_spin_on_owner(sem))
> +		return ret;
> +
> +	preempt_disable();
> +	for (;;) {
> +		struct mspin_node node;
> +
> +		mspin_lock(MLOCK(sem), &node);
> +		owner = ACCESS_ONCE(sem->owner);
> +		if (owner && !rwsem_spin_on_owner(sem, owner)) {
> +			mspin_unlock(MLOCK(sem), &node);
> +			break;
> +		}
> +
> +		/* wait_lock will be acquired if write_lock is obtained */
> +		if (rwsem_try_write_lock_unqueued(sem)) {
> +			mspin_unlock(MLOCK(sem), &node);
> +			ret = 1;
> +			break;
> +		}
> +		mspin_unlock(MLOCK(sem), &node);
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
> +	}
> +
> +	preempt_enable();
> +	return ret;
> +}
> +#endif
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
>  
> +	count = rwsem_atomic_update(-RWSEM_ACTIVE_WRITE_BIAS, sem);
> +#ifdef CONFIG_RWSEM_SPIN_ON_WRITE_OWNER
> +	/* do optimistic spinning */
> +	if (rwsem_optimistic_spin(sem))
> +		goto done;
> +#endif
>  	/* set up my own style of waitqueue */
>  	waiter.task = tsk;
>  	waiter.type = RWSEM_WAITING_FOR_WRITE;
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
> -	if (count > RWSEM_WAITING_BIAS &&
> -	    adjustment == -RWSEM_ACTIVE_WRITE_BIAS)
> +	if ((count > RWSEM_WAITING_BIAS) && waiting)
>  		sem = __rwsem_do_wake(sem, RWSEM_WAKE_READERS);
>  
>  	/* wait until we successfully acquire the lock */
>  	set_task_state(tsk, TASK_UNINTERRUPTIBLE);
>  	while (true) {
> -		if (!(count & RWSEM_ACTIVE_MASK)) {
> -			/* Try acquiring the write lock. */
> -			count = RWSEM_ACTIVE_WRITE_BIAS;
> -			if (!list_is_singular(&sem->wait_list))
> -				count += RWSEM_WAITING_BIAS;
> -
> -			if (sem->count == RWSEM_WAITING_BIAS &&
> -			    cmpxchg(&sem->count, RWSEM_WAITING_BIAS, count) ==
> -							RWSEM_WAITING_BIAS)
> -				break;
> -		}
> +		if (rwsem_try_write_lock(count, sem))
> +			break;
>  
>  		raw_spin_unlock_irq(&sem->wait_lock);
>  
> @@ -250,6 +459,7 @@ struct rw_semaphore __sched *rwsem_down_write_failed(struct rw_semaphore *sem)
>  
>  	list_del(&waiter.list);
>  	raw_spin_unlock_irq(&sem->wait_lock);
> +done:
>  	tsk->state = TASK_RUNNING;
>  
>  	return sem;
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
