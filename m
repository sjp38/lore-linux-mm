Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id EFC266B003A
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 11:30:24 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so2768767pde.10
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 08:30:24 -0700 (PDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 27 Sep 2013 11:30:21 -0400
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id C4B1838C806B
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 11:29:55 -0400 (EDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8RFTtPs7078274
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 15:29:55 GMT
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8RFWwhl016739
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:32:59 -0600
Date: Fri, 27 Sep 2013 08:29:53 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 5/6] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
Message-ID: <20130927152953.GA4464@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <cover.1380144003.git.tim.c.chen@linux.intel.com>
 <1380147049.3467.67.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1380147049.3467.67.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Wed, Sep 25, 2013 at 03:10:49PM -0700, Tim Chen wrote:
> We will need the MCS lock code for doing optimistic spinning for rwsem.
> Extracting the MCS code from mutex.c and put into its own file allow us
> to reuse this code easily for rwsem.
> 
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> ---
>  include/linux/mcslock.h |   58 +++++++++++++++++++++++++++++++++++++++++++++++
>  kernel/mutex.c          |   58 +++++-----------------------------------------
>  2 files changed, 65 insertions(+), 51 deletions(-)
>  create mode 100644 include/linux/mcslock.h
> 
> diff --git a/include/linux/mcslock.h b/include/linux/mcslock.h
> new file mode 100644
> index 0000000..20fd3f0
> --- /dev/null
> +++ b/include/linux/mcslock.h
> @@ -0,0 +1,58 @@
> +/*
> + * MCS lock defines
> + *
> + * This file contains the main data structure and API definitions of MCS lock.
> + */
> +#ifndef __LINUX_MCSLOCK_H
> +#define __LINUX_MCSLOCK_H
> +
> +struct mcs_spin_node {
> +	struct mcs_spin_node *next;
> +	int		  locked;	/* 1 if lock acquired */
> +};
> +
> +/*
> + * We don't inline mcs_spin_lock() so that perf can correctly account for the
> + * time spent in this lock function.
> + */
> +static noinline
> +void mcs_spin_lock(struct mcs_spin_node **lock, struct mcs_spin_node *node)
> +{
> +	struct mcs_spin_node *prev;
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
> +	/* Wait until the lock holder passes the lock down */
> +	while (!ACCESS_ONCE(node->locked))
> +		arch_mutex_cpu_relax();
> +}
> +
> +static void mcs_spin_unlock(struct mcs_spin_node **lock, struct mcs_spin_node *node)
> +{
> +	struct mcs_spin_node *next = ACCESS_ONCE(node->next);
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

Shouldn't the memory barrier precede the "ACCESS_ONCE(next->locked) = 1;"?
Maybe in an "else" clause of the prior "if" statement, given that the
cmpxchg() does it otherwise.

Otherwise, in the case where the "if" conditionn is false, the critical
section could bleed out past the unlock.

							Thanx, Paul

> +}
> +
> +#endif
> diff --git a/kernel/mutex.c b/kernel/mutex.c
> index 6d647ae..1b6ba3f 100644
> --- a/kernel/mutex.c
> +++ b/kernel/mutex.c
> @@ -25,6 +25,7 @@
>  #include <linux/spinlock.h>
>  #include <linux/interrupt.h>
>  #include <linux/debug_locks.h>
> +#include <linux/mcslock.h>
>  
>  /*
>   * In the DEBUG case we are using the "NULL fastpath" for mutexes,
> @@ -111,54 +112,9 @@ EXPORT_SYMBOL(mutex_lock);
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
>  
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
> +#define	MLOCK(mutex)	((struct mcs_spin_node **)&((mutex)->spin_mlock))
>  
>  /*
>   * Mutex spinning code migrated from kernel/sched/core.c
> @@ -448,7 +404,7 @@ __mutex_lock_common(struct mutex *lock, long state, unsigned int subclass,
>  
>  	for (;;) {
>  		struct task_struct *owner;
> -		struct mspin_node  node;
> +		struct mcs_spin_node  node;
>  
>  		if (!__builtin_constant_p(ww_ctx == NULL) && ww_ctx->acquired > 0) {
>  			struct ww_mutex *ww;
> @@ -470,10 +426,10 @@ __mutex_lock_common(struct mutex *lock, long state, unsigned int subclass,
>  		 * If there's an owner, wait for it to either
>  		 * release the lock or go to sleep.
>  		 */
> -		mspin_lock(MLOCK(lock), &node);
> +		mcs_spin_lock(MLOCK(lock), &node);
>  		owner = ACCESS_ONCE(lock->owner);
>  		if (owner && !mutex_spin_on_owner(lock, owner)) {
> -			mspin_unlock(MLOCK(lock), &node);
> +			mcs_spin_unlock(MLOCK(lock), &node);
>  			goto slowpath;
>  		}
>  
> @@ -488,11 +444,11 @@ __mutex_lock_common(struct mutex *lock, long state, unsigned int subclass,
>  			}
>  
>  			mutex_set_owner(lock);
> -			mspin_unlock(MLOCK(lock), &node);
> +			mcs_spin_unlock(MLOCK(lock), &node);
>  			preempt_enable();
>  			return 0;
>  		}
> -		mspin_unlock(MLOCK(lock), &node);
> +		mcs_spin_unlock(MLOCK(lock), &node);
>  
>  		/*
>  		 * When there's no owner, we might have preempted between the
> -- 
> 1.7.4.4
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
