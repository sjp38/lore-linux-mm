Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7E6BD6B003D
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 14:21:45 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id hz1so5604319pad.40
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 11:21:45 -0800 (PST)
Received: from psmtp.com ([74.125.245.175])
        by mx.google.com with SMTP id ty3si7564408pbc.317.2013.11.19.11.21.43
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 11:21:44 -0800 (PST)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 19 Nov 2013 12:21:42 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id A305E1FF0021
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 12:21:21 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAJHJf5b8585512
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 18:19:41 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAJJOVk6011656
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 12:24:33 -0700
Date: Tue, 19 Nov 2013 11:21:36 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 4/4] MCS Lock: Barrier corrections
Message-ID: <20131119192136.GQ4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <cover.1383935697.git.tim.c.chen@linux.intel.com>
 <1383940358.11046.417.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1383940358.11046.417.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, Will Deacon <will.deacon@arm.com>, "Figo.zhang" <figo1802@gmail.com>

On Fri, Nov 08, 2013 at 11:52:38AM -0800, Tim Chen wrote:
> From: Waiman Long <Waiman.Long@hp.com>
> 
> This patch corrects the way memory barriers are used in the MCS lock
> with smp_load_acquire and smp_store_release fucnction.
> It removes ones that are not needed.
> 
> It uses architecture specific load-acquire and store-release
> primitives for synchronization, if available. Generic implementations
> are provided in case they are not defined even though they may not
> be optimal. These generic implementation could be removed later on
> once changes are made in all the relevant header files.
> 
> Suggested-by: Michel Lespinasse <walken@google.com>
> Signed-off-by: Waiman Long <Waiman.Long@hp.com>
> Signed-off-by: Jason Low <jason.low2@hp.com>
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>

Please see comments below.

							Thanx, Paul

> ---
>  kernel/locking/mcs_spinlock.c |   48 +++++++++++++++++++++++++++++++++++------
>  1 files changed, 41 insertions(+), 7 deletions(-)
> 
> diff --git a/kernel/locking/mcs_spinlock.c b/kernel/locking/mcs_spinlock.c
> index b6f27f8..df5c167 100644
> --- a/kernel/locking/mcs_spinlock.c
> +++ b/kernel/locking/mcs_spinlock.c
> @@ -23,6 +23,31 @@
>  #endif
> 
>  /*
> + * Fall back to use the regular atomic operations and memory barrier if
> + * the acquire/release versions are not defined.
> + */
> +#ifndef	xchg_acquire
> +# define xchg_acquire(p, v)		xchg(p, v)
> +#endif
> +
> +#ifndef	smp_load_acquire
> +# define smp_load_acquire(p)				\
> +	({						\
> +		typeof(*p) __v = ACCESS_ONCE(*(p));	\
> +		smp_mb();				\
> +		__v;					\
> +	})
> +#endif
> +
> +#ifndef smp_store_release
> +# define smp_store_release(p, v)		\
> +	do {					\
> +		smp_mb();			\
> +		ACCESS_ONCE(*(p)) = v;		\
> +	} while (0)
> +#endif
> +
> +/*
>   * In order to acquire the lock, the caller should declare a local node and
>   * pass a reference of the node to this function in addition to the lock.
>   * If the lock has already been acquired, then this will proceed to spin
> @@ -37,15 +62,19 @@ void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
>  	node->locked = 0;
>  	node->next   = NULL;
> 
> -	prev = xchg(lock, node);
> +	/* xchg() provides a memory barrier */
> +	prev = xchg_acquire(lock, node);

But if this is xchg_acquire() with only acquire semantics, it need not
ensure that the initializations of node->locked and node->next above
will happen before the "ACCESS_ONCE(prev->next) = node" below.  This
therefore needs to remain xchg().  Or you need an smp_store_release()
below instead of an ACCESS_ONCE() assignment.

As currently written, the poor CPU doing the unlock can be fatally
disappointed by seeing pre-initialized values of ->locked and ->next.
This could, among other things, result in a hang where the handoff
happens before the initialization.

>  	if (likely(prev == NULL)) {
>  		/* Lock acquired */
>  		return;
>  	}
>  	ACCESS_ONCE(prev->next) = node;
> -	smp_wmb();
> -	/* Wait until the lock holder passes the lock down */
> -	while (!ACCESS_ONCE(node->locked))
> +	/*
> +	 * Wait until the lock holder passes the lock down.
> +	 * Using smp_load_acquire() provides a memory barrier that
> +	 * ensures subsequent operations happen after the lock is acquired.
> +	 */
> +	while (!(smp_load_acquire(&node->locked)))
>  		arch_mutex_cpu_relax();

OK, this smp_load_acquire() makes sense!

>  }
>  EXPORT_SYMBOL_GPL(mcs_spin_lock);
> @@ -54,7 +83,7 @@ EXPORT_SYMBOL_GPL(mcs_spin_lock);
>   * Releases the lock. The caller should pass in the corresponding node that
>   * was used to acquire the lock.
>   */
> -static void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
> +void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
>  {
>  	struct mcs_spinlock *next = ACCESS_ONCE(node->next);
> 
> @@ -68,7 +97,12 @@ static void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *nod
>  		while (!(next = ACCESS_ONCE(node->next)))
>  			arch_mutex_cpu_relax();
>  	}
> -	ACCESS_ONCE(next->locked) = 1;
> -	smp_wmb();
> +	/*
> +	 * Pass lock to next waiter.
> +	 * smp_store_release() provides a memory barrier to ensure
> +	 * all operations in the critical section has been completed
> +	 * before unlocking.
> +	 */
> +	smp_store_release(&next->locked , 1);

This smp_store_release() makes sense as well!

Could you please get rid of the extraneous space before the comma?

>  }
>  EXPORT_SYMBOL_GPL(mcs_spin_unlock);
> -- 
> 1.7.4.4
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
