Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 725A76B010B
	for <linux-mm@kvack.org>; Mon, 11 Nov 2013 13:12:41 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id y13so2678264pdi.14
        for <linux-mm@kvack.org>; Mon, 11 Nov 2013 10:12:41 -0800 (PST)
Received: from psmtp.com ([74.125.245.178])
        by mx.google.com with SMTP id xp9si14158620pab.200.2013.11.11.10.12.38
        for <linux-mm@kvack.org>;
        Mon, 11 Nov 2013 10:12:40 -0800 (PST)
Date: Mon, 11 Nov 2013 18:10:49 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v5 4/4] MCS Lock: Barrier corrections
Message-ID: <20131111181049.GL28302@mudshark.cambridge.arm.com>
References: <cover.1383935697.git.tim.c.chen@linux.intel.com>
 <1383940358.11046.417.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1383940358.11046.417.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

Hello,

On Fri, Nov 08, 2013 at 07:52:38PM +0000, Tim Chen wrote:
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

PeterZ already has a series implementing acquire/release accessors, so you
should probably take a look at that rather than rolling your own here.

You could then augment that with [cmp]xchg_{acquire,release} as
appropriate.

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

After a chat with some micro-architects, I'm going to have to disagree with
Paul here. For architectures where acquire/release are implemented with
explicit barriers (similarly for simple microarchitectures), emitting
barriers in a loop *is* going to have an affect on overall performance,
since those barriers may well result in traffic outside of the core (at
least, on ARM).

Thinking more about that, the real issue here is that arch_mutex_cpu_relax()
doesn't have a corresponding hook on the unlock side. On ARM, for example,
we can enter a low-power state using the wfe instruction, but that requires
the unlocker to wake up the core when the lock is released.

So, although I'm completely in favour of introducing acquire/release
accessors, I really think the mcs locking routines would benefit from
some arch-specific backend code, even if it's optional (although I would
imagine most architectures implementing something to improve power and/or
performance).

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
