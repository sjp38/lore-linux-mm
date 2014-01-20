Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id C3C386B0035
	for <linux-mm@kvack.org>; Sun, 19 Jan 2014 21:28:48 -0500 (EST)
Received: by mail-yk0-f175.google.com with SMTP id q200so1284929ykb.6
        for <linux-mm@kvack.org>; Sun, 19 Jan 2014 18:28:48 -0800 (PST)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id q69si25058082yhd.270.2014.01.19.18.28.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 19 Jan 2014 18:28:47 -0800 (PST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sun, 19 Jan 2014 19:28:46 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id A1B461FF001A
	for <linux-mm@kvack.org>; Sun, 19 Jan 2014 19:28:12 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0K2SVme7537068
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 03:28:31 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s0K2W0iR002360
	for <linux-mm@kvack.org>; Sun, 19 Jan 2014 19:32:01 -0700
Date: Sun, 19 Jan 2014 18:28:40 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 1/6] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
Message-ID: <20140120022840.GI10038@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <cover.1389890175.git.tim.c.chen@linux.intel.com>
 <1389917296.3138.11.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389917296.3138.11.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Thu, Jan 16, 2014 at 04:08:16PM -0800, Tim Chen wrote:
> We will need the MCS lock code for doing optimistic spinning for rwsem
> and queue rwlock.  Extracting the MCS code from mutex.c and put into
> its own file allow us to reuse this code easily.
> 
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>

>From the perspective of correctly moving incorrect code:

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Gripes interspersed below.  ;-)

> ---
>  include/linux/mcs_spinlock.h | 64 ++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/mutex.h        |  5 ++--
>  kernel/locking/mutex.c       | 60 +++++------------------------------------
>  3 files changed, 74 insertions(+), 55 deletions(-)
>  create mode 100644 include/linux/mcs_spinlock.h
> 
> diff --git a/include/linux/mcs_spinlock.h b/include/linux/mcs_spinlock.h
> new file mode 100644
> index 0000000..b5de3b0
> --- /dev/null
> +++ b/include/linux/mcs_spinlock.h
> @@ -0,0 +1,64 @@
> +/*
> + * MCS lock defines
> + *
> + * This file contains the main data structure and API definitions of MCS lock.
> + *
> + * The MCS lock (proposed by Mellor-Crummey and Scott) is a simple spin-lock
> + * with the desirable properties of being fair, and with each cpu trying
> + * to acquire the lock spinning on a local variable.
> + * It avoids expensive cache bouncings that common test-and-set spin-lock
> + * implementations incur.
> + */
> +#ifndef __LINUX_MCS_SPINLOCK_H
> +#define __LINUX_MCS_SPINLOCK_H
> +
> +struct mcs_spinlock {
> +	struct mcs_spinlock *next;
> +	int locked; /* 1 if lock acquired */
> +};
> +
> +/*
> + * We don't inline mcs_spin_lock() so that perf can correctly account for the
> + * time spent in this lock function.
> + */
> +static noinline
> +void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
> +{
> +	struct mcs_spinlock *prev;
> +
> +	/* Init node */
> +	node->locked = 0;
> +	node->next   = NULL;
> +
> +	prev = xchg(lock, node);
> +	if (likely(prev == NULL)) {
> +		/* Lock acquired */
> +		node->locked = 1;
> +		return;
> +	}
> +	ACCESS_ONCE(prev->next) = node;
> +	smp_wmb();

The above memory barrier isn't doing anything useful -- there is a write
before it, but no writes after it.

> +	/* Wait until the lock holder passes the lock down */
> +	while (!ACCESS_ONCE(node->locked))
> +		arch_mutex_cpu_relax();

Nothing I can see prevents critical-section loads from happening before
the above ACCESS_ONCE(), thus leaking them out of the critical section.
(Stores cannot be executed speculatively.)

> +}
> +
> +static void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
> +{
> +	struct mcs_spinlock *next = ACCESS_ONCE(node->next);
> +
> +	if (likely(!next)) {
> +		/*
> +		 * Release the lock by setting it to NULL
> +		 */
> +		if (cmpxchg(lock, node, NULL) == node)
> +			return;
> +		/* Wait until the next pointer is set */
> +		while (!(next = ACCESS_ONCE(node->next)))
> +			arch_mutex_cpu_relax();
> +	}
> +	ACCESS_ONCE(next->locked) = 1;
> +	smp_wmb();

This memory barrier is also not doing anything.  Nothing prevents the
critical section from leaking out.

> +}
> +
> +#endif /* __LINUX_MCS_SPINLOCK_H */
> diff --git a/include/linux/mutex.h b/include/linux/mutex.h
> index d318193..c482e1d 100644
> --- a/include/linux/mutex.h
> +++ b/include/linux/mutex.h
> @@ -46,6 +46,7 @@
>   * - detects multi-task circular deadlocks and prints out all affected
>   *   locks and tasks (and only those tasks)
>   */
> +struct mcs_spinlock;
>  struct mutex {
>  	/* 1: unlocked, 0: locked, negative: locked, possible waiters */
>  	atomic_t		count;
> @@ -55,7 +56,7 @@ struct mutex {
>  	struct task_struct	*owner;
>  #endif
>  #ifdef CONFIG_MUTEX_SPIN_ON_OWNER
> -	void			*spin_mlock;	/* Spinner MCS lock */
> +	struct mcs_spinlock	*mcs_lock;	/* Spinner MCS lock */
>  #endif
>  #ifdef CONFIG_DEBUG_MUTEXES
>  	const char 		*name;
> @@ -179,4 +180,4 @@ extern int atomic_dec_and_mutex_lock(atomic_t *cnt, struct mutex *lock);
>  # define arch_mutex_cpu_relax() cpu_relax()
>  #endif
> 
> -#endif
> +#endif /* __LINUX_MUTEX_H */
> diff --git a/kernel/locking/mutex.c b/kernel/locking/mutex.c
> index 4dd6e4c..45fe1b5 100644
> --- a/kernel/locking/mutex.c
> +++ b/kernel/locking/mutex.c
> @@ -25,6 +25,7 @@
>  #include <linux/spinlock.h>
>  #include <linux/interrupt.h>
>  #include <linux/debug_locks.h>
> +#include <linux/mcs_spinlock.h>
> 
>  /*
>   * In the DEBUG case we are using the "NULL fastpath" for mutexes,
> @@ -52,7 +53,7 @@ __mutex_init(struct mutex *lock, const char *name, struct lock_class_key *key)
>  	INIT_LIST_HEAD(&lock->wait_list);
>  	mutex_clear_owner(lock);
>  #ifdef CONFIG_MUTEX_SPIN_ON_OWNER
> -	lock->spin_mlock = NULL;
> +	lock->mcs_lock = NULL;
>  #endif
> 
>  	debug_mutex_init(lock, name, key);
> @@ -111,54 +112,7 @@ EXPORT_SYMBOL(mutex_lock);
>   * more or less simultaneously, the spinners need to acquire a MCS lock
>   * first before spinning on the owner field.
>   *
> - * We don't inline mspin_lock() so that perf can correctly account for the
> - * time spent in this lock function.
>   */
> -struct mspin_node {
> -	struct mspin_node *next ;
> -	int		  locked;	/* 1 if lock acquired */
> -};
> -#define	MLOCK(mutex)	((struct mspin_node **)&((mutex)->spin_mlock))
> -
> -static noinline
> -void mspin_lock(struct mspin_node **lock, struct mspin_node *node)
> -{
> -	struct mspin_node *prev;
> -
> -	/* Init node */
> -	node->locked = 0;
> -	node->next   = NULL;
> -
> -	prev = xchg(lock, node);
> -	if (likely(prev == NULL)) {
> -		/* Lock acquired */
> -		node->locked = 1;
> -		return;
> -	}
> -	ACCESS_ONCE(prev->next) = node;
> -	smp_wmb();
> -	/* Wait until the lock holder passes the lock down */
> -	while (!ACCESS_ONCE(node->locked))
> -		arch_mutex_cpu_relax();
> -}
> -
> -static void mspin_unlock(struct mspin_node **lock, struct mspin_node *node)
> -{
> -	struct mspin_node *next = ACCESS_ONCE(node->next);
> -
> -	if (likely(!next)) {
> -		/*
> -		 * Release the lock by setting it to NULL
> -		 */
> -		if (cmpxchg(lock, node, NULL) == node)
> -			return;
> -		/* Wait until the next pointer is set */
> -		while (!(next = ACCESS_ONCE(node->next)))
> -			arch_mutex_cpu_relax();
> -	}
> -	ACCESS_ONCE(next->locked) = 1;
> -	smp_wmb();
> -}
> 
>  /*
>   * Mutex spinning code migrated from kernel/sched/core.c
> @@ -448,7 +402,7 @@ __mutex_lock_common(struct mutex *lock, long state, unsigned int subclass,
> 
>  	for (;;) {
>  		struct task_struct *owner;
> -		struct mspin_node  node;
> +		struct mcs_spinlock  node;
> 
>  		if (use_ww_ctx && ww_ctx->acquired > 0) {
>  			struct ww_mutex *ww;
> @@ -470,10 +424,10 @@ __mutex_lock_common(struct mutex *lock, long state, unsigned int subclass,
>  		 * If there's an owner, wait for it to either
>  		 * release the lock or go to sleep.
>  		 */
> -		mspin_lock(MLOCK(lock), &node);
> +		mcs_spin_lock(&lock->mcs_lock, &node);
>  		owner = ACCESS_ONCE(lock->owner);
>  		if (owner && !mutex_spin_on_owner(lock, owner)) {
> -			mspin_unlock(MLOCK(lock), &node);
> +			mcs_spin_unlock(&lock->mcs_lock, &node);
>  			goto slowpath;
>  		}
> 
> @@ -488,11 +442,11 @@ __mutex_lock_common(struct mutex *lock, long state, unsigned int subclass,
>  			}
> 
>  			mutex_set_owner(lock);
> -			mspin_unlock(MLOCK(lock), &node);
> +			mcs_spin_unlock(&lock->mcs_lock, &node);
>  			preempt_enable();
>  			return 0;
>  		}
> -		mspin_unlock(MLOCK(lock), &node);
> +		mcs_spin_unlock(&lock->mcs_lock, &node);
> 
>  		/*
>  		 * When there's no owner, we might have preempted between the
> -- 
> 1.7.11.7
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
