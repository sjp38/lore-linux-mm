Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 2B9096B0033
	for <linux-mm@kvack.org>; Sat, 22 Jun 2013 03:57:30 -0400 (EDT)
Message-ID: <51C558E2.1040108@hurleysoftware.com>
Date: Sat, 22 Jun 2013 03:57:22 -0400
From: Peter Hurley <peter@hurleysoftware.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] rwsem: do optimistic spinning for writer lock acquisition
References: <cover.1371855277.git.tim.c.chen@linux.intel.com> <1371858700.22432.5.camel@schen9-DESK>
In-Reply-To: <1371858700.22432.5.camel@schen9-DESK>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>, Alex Shi <alex.shi@intel.com>, Michel Lespinasse <walken@google.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On 06/21/2013 07:51 PM, Tim Chen wrote:
> Introduce in this patch optimistic spinning for writer lock
> acquisition in read write semaphore.  The logic is
> similar to the optimistic spinning in mutex but without
> the MCS lock queueing of the spinner.  This provides a
> better chance for a writer to acquire the lock before
> being we block it and put it to sleep.

This is just my opinion but I'd rather read the justification
here instead of referencing mutex logic that may or may not
exist in 2 years.


> Disabling of pre-emption during optimistic spinning
> was suggested by Davidlohr Bueso.  It
> improved performance of aim7 for his test suite.
>
> Combined with the patch to avoid unnecesary cmpxchg,
> in testing by Davidlohr Bueso on aim7 workloads
> on 8 socket 80 cores system, he saw improvements of
> alltests (+14.5%), custom (+17%), disk (+11%), high_systime
> (+5%), shared (+15%) and short (+4%), most of them after around 500
> users when he implemented i_mmap as rwsem.
>
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> ---
>   Makefile              |    2 +-
>   include/linux/rwsem.h |    3 +
>   init/Kconfig          |    9 +++
>   kernel/rwsem.c        |   29 +++++++++-
>   lib/rwsem.c           |  148 +++++++++++++++++++++++++++++++++++++++++++++----
>   5 files changed, 178 insertions(+), 13 deletions(-)
>
> diff --git a/Makefile b/Makefile
> index 49aa84b..7d1ef64 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -1,7 +1,7 @@
>   VERSION = 3
>   PATCHLEVEL = 10
>   SUBLEVEL = 0
> -EXTRAVERSION = -rc4
> +EXTRAVERSION = -rc4-optspin4
>   NAME = Unicycling Gorilla
>
>   # *DOCUMENTATION*
> diff --git a/include/linux/rwsem.h b/include/linux/rwsem.h
> index 0616ffe..0c5933b 100644
> --- a/include/linux/rwsem.h
> +++ b/include/linux/rwsem.h
> @@ -29,6 +29,9 @@ struct rw_semaphore {
>   #ifdef CONFIG_DEBUG_LOCK_ALLOC
>   	struct lockdep_map	dep_map;
>   #endif
> +#ifdef CONFIG_RWSEM_SPIN_ON_WRITE_OWNER
> +	struct task_struct	*owner;
> +#endif
>   };
>
>   extern struct rw_semaphore *rwsem_down_read_failed(struct rw_semaphore *sem);
> diff --git a/init/Kconfig b/init/Kconfig
> index 9d3a788..1c582d1 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1595,6 +1595,15 @@ config TRACEPOINTS
>
>   source "arch/Kconfig"
>
> +config RWSEM_SPIN_ON_WRITE_OWNER
> +	bool "Optimistic spin write acquisition for writer owned rw-sem"
> +	default n
> +	depends on SMP
> +	help
> +	  Allows a writer to perform optimistic spinning if another writer own
> +	  the read write semaphore.  This gives a greater chance for writer to
> +	  acquire a semaphore before blocking it and putting it to sleep.
> +
>   endmenu		# General setup
>
>   config HAVE_GENERIC_DMA_COHERENT
> diff --git a/kernel/rwsem.c b/kernel/rwsem.c
> index cfff143..a32990a 100644
> --- a/kernel/rwsem.c
> +++ b/kernel/rwsem.c
> @@ -12,6 +12,26 @@
>
>   #include <linux/atomic.h>
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
>   /*
>    * lock for reading
>    */
> @@ -48,6 +68,7 @@ void __sched down_write(struct rw_semaphore *sem)
>   	rwsem_acquire(&sem->dep_map, 0, 0, _RET_IP_);
>
>   	LOCK_CONTENDED(sem, __down_write_trylock, __down_write);
> +	rwsem_set_owner(sem);
>   }
>
>   EXPORT_SYMBOL(down_write);
> @@ -59,8 +80,10 @@ int down_write_trylock(struct rw_semaphore *sem)
>   {
>   	int ret = __down_write_trylock(sem);
>
> -	if (ret == 1)
> +	if (ret == 1) {
>   		rwsem_acquire(&sem->dep_map, 0, 1, _RET_IP_);
> +		rwsem_set_owner(sem);
> +	}
>   	return ret;
>   }
>
> @@ -86,6 +109,7 @@ void up_write(struct rw_semaphore *sem)
>   	rwsem_release(&sem->dep_map, 1, _RET_IP_);
>
>   	__up_write(sem);
> +	rwsem_clear_owner(sem);
>   }
>
>   EXPORT_SYMBOL(up_write);
> @@ -100,6 +124,7 @@ void downgrade_write(struct rw_semaphore *sem)
>   	 * dependency.
>   	 */
>   	__downgrade_write(sem);
> +	rwsem_clear_owner(sem);
>   }
>
>   EXPORT_SYMBOL(downgrade_write);
> @@ -122,6 +147,7 @@ void _down_write_nest_lock(struct rw_semaphore *sem, struct lockdep_map *nest)
>   	rwsem_acquire_nest(&sem->dep_map, 0, 0, nest, _RET_IP_);
>
>   	LOCK_CONTENDED(sem, __down_write_trylock, __down_write);
> +	rwsem_set_owner(sem);
>   }
>
>   EXPORT_SYMBOL(_down_write_nest_lock);
> @@ -141,6 +167,7 @@ void down_write_nested(struct rw_semaphore *sem, int subclass)
>   	rwsem_acquire(&sem->dep_map, subclass, 0, _RET_IP_);
>
>   	LOCK_CONTENDED(sem, __down_write_trylock, __down_write);
> +	rwsem_set_owner(sem);
>   }
>
>   EXPORT_SYMBOL(down_write_nested);
> diff --git a/lib/rwsem.c b/lib/rwsem.c
> index 2072af5..8e331c5 100644
> --- a/lib/rwsem.c
> +++ b/lib/rwsem.c
> @@ -8,6 +8,7 @@
>    */
>   #include <linux/rwsem.h>
>   #include <linux/sched.h>
> +#include <linux/sched/rt.h>
>   #include <linux/init.h>
>   #include <linux/export.h>
>
> @@ -27,6 +28,9 @@ void __init_rwsem(struct rw_semaphore *sem, const char *name,
>   	sem->count = RWSEM_UNLOCKED_VALUE;
>   	raw_spin_lock_init(&sem->wait_lock);
>   	INIT_LIST_HEAD(&sem->wait_list);
> +#ifdef CONFIG_RWSEM_SPIN_ON_WRITE_OWNER
> +	sem->owner = NULL;
> +#endif
>   }
>
>   EXPORT_SYMBOL(__init_rwsem);
> @@ -192,6 +196,128 @@ struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
>   	return sem;
>   }
>
> +static inline int rwsem_try_write_lock(long count, bool need_lock,
> +	struct rw_semaphore *sem)
> +{
> +	if (!(count & RWSEM_ACTIVE_MASK)) {
> +		/* Try acquiring the write lock. */
> +		if (sem->count == RWSEM_WAITING_BIAS &&
> +		    cmpxchg(&sem->count, RWSEM_WAITING_BIAS,
> +			    RWSEM_ACTIVE_WRITE_BIAS) == RWSEM_WAITING_BIAS) {
> +			if (need_lock)
> +				raw_spin_lock_irq(&sem->wait_lock);
> +			if (!list_is_singular(&sem->wait_list))
> +				rwsem_atomic_update(RWSEM_WAITING_BIAS, sem);
> +			return 1;
> +		}
> +	}
> +	return 0;
> +}
> +
> +#ifdef CONFIG_RWSEM_SPIN_ON_WRITE_OWNER
> +static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
> +{
> +	int retval = true;
> +
> +	/* Spin only if active writer running */
> +	if (!sem->owner)
> +		return false;
> +
> +	rcu_read_lock();
> +	if (sem->owner)
> +		retval = sem->owner->on_cpu;
                          ^^^^^^^^^^^^^^^^^^

Why is this a safe dereference? Could not another cpu have just
dropped the sem (and thus set sem->owner to NULL and oops)?


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

Again just my opinion, but kernel style is to prefer multi-line comments
in a function comment block.

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
> +		owner = ACCESS_ONCE(sem->owner);
> +		if (owner && !rwsem_spin_on_owner(sem, owner))
> +			break;

Will this spin for full scheduler value on a reader-owned lock?

> +		/* wait_lock will be acquired if write_lock is obtained */
> +		if (rwsem_try_write_lock(sem->count, true, sem)) {
> +			ret = 1;
> +			goto out;
> +		}
> +
> +		/*
> +		 * When there's no owner, we might have preempted between the
                                                         ^^^^^^^^

Isn't pre-emption disabled?


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
> +out:
> +	preempt_enable();
> +	return ret;
> +}
> +#endif
> +
>   /*
>    * wait until we successfully acquire the write lock
>    */
> @@ -200,6 +326,9 @@ struct rw_semaphore __sched *rwsem_down_write_failed(struct rw_semaphore *sem)
>   	long count, adjustment = -RWSEM_ACTIVE_WRITE_BIAS;
>   	struct rwsem_waiter waiter;
>   	struct task_struct *tsk = current;
> +#ifdef CONFIG_RWSEM_SPIN_ON_WRITE_OWNER
> +	bool try_optimistic_spin = true;
> +#endif
>
>   	/* set up my own style of waitqueue */
>   	waiter.task = tsk;
> @@ -223,20 +352,17 @@ struct rw_semaphore __sched *rwsem_down_write_failed(struct rw_semaphore *sem)
>   	/* wait until we successfully acquire the lock */
>   	set_task_state(tsk, TASK_UNINTERRUPTIBLE);
>   	while (true) {
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
> +		if (rwsem_try_write_lock(count, false, sem))
> +			break;
>
>   		raw_spin_unlock_irq(&sem->wait_lock);
>
> +#ifdef CONFIG_RWSEM_SPIN_ON_WRITE_OWNER
> +		/* do optimistic spinning */
> +		if (try_optimistic_spin && rwsem_optimistic_spin(sem))
> +			break;
> +		try_optimistic_spin = false;
> +#endif
>   		/* Block until there are no active lockers. */
>   		do {
>   			schedule();

Regards,
Peter Hurley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
