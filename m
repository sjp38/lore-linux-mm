Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f178.google.com (mail-gg0-f178.google.com [209.85.161.178])
	by kanga.kvack.org (Postfix) with ESMTP id 290516B0035
	for <linux-mm@kvack.org>; Sun, 19 Jan 2014 21:34:56 -0500 (EST)
Received: by mail-gg0-f178.google.com with SMTP id q2so1981610ggc.23
        for <linux-mm@kvack.org>; Sun, 19 Jan 2014 18:34:55 -0800 (PST)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id j24si25124656yhb.121.2014.01.19.18.34.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 19 Jan 2014 18:34:55 -0800 (PST)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sun, 19 Jan 2014 19:34:54 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id E0C101FF001B
	for <linux-mm@kvack.org>; Sun, 19 Jan 2014 19:34:20 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0K2YdnW10027430
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 03:34:39 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s0K2c8kp012283
	for <linux-mm@kvack.org>; Sun, 19 Jan 2014 19:38:10 -0700
Date: Sun, 19 Jan 2014 18:34:48 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 5/6] MCS Lock: allow architectures to hook in to
 contended paths
Message-ID: <20140120023448.GM10038@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <cover.1389890175.git.tim.c.chen@linux.intel.com>
 <1389917311.3138.15.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389917311.3138.15.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Thu, Jan 16, 2014 at 04:08:31PM -0800, Tim Chen wrote:
> When contended, architectures may be able to reduce the polling overhead
> in ways which aren't expressible using a simple relax() primitive.
> 
> This patch allows architectures to hook into the mcs_{lock,unlock}
> functions for the contended cases only.
> 
> From: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Will Deacon <will.deacon@arm.com>

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> ---
>  kernel/locking/mcs_spinlock.c | 47 +++++++++++++++++++++++++------------------
>  1 file changed, 27 insertions(+), 20 deletions(-)
> 
> diff --git a/kernel/locking/mcs_spinlock.c b/kernel/locking/mcs_spinlock.c
> index 6cdc730..66d8883 100644
> --- a/kernel/locking/mcs_spinlock.c
> +++ b/kernel/locking/mcs_spinlock.c
> @@ -7,19 +7,34 @@
>   * It avoids expensive cache bouncings that common test-and-set spin-lock
>   * implementations incur.
>   */
> -/*
> - * asm/processor.h may define arch_mutex_cpu_relax().
> - * If it is not defined, cpu_relax() will be used.
> - */
> +
>  #include <asm/barrier.h>
>  #include <asm/cmpxchg.h>
>  #include <asm/processor.h>
>  #include <linux/compiler.h>
>  #include <linux/mcs_spinlock.h>
> +#include <linux/mutex.h>
>  #include <linux/export.h>
> 
> -#ifndef arch_mutex_cpu_relax
> -# define arch_mutex_cpu_relax() cpu_relax()
> +#ifndef arch_mcs_spin_lock_contended
> +/*
> + * Using smp_load_acquire() provides a memory barrier that ensures
> + * subsequent operations happen after the lock is acquired.
> + */
> +#define arch_mcs_spin_lock_contended(l)					\
> +	while (!(smp_load_acquire(l))) {				\
> +		arch_mutex_cpu_relax();					\
> +	}
> +#endif
> +
> +#ifndef arch_mcs_spin_unlock_contended
> +/*
> + * smp_store_release() provides a memory barrier to ensure all
> + * operations in the critical section has been completed before
> + * unlocking.
> + */
> +#define arch_mcs_spin_unlock_contended(l)				\
> +	smp_store_release((l), 1)
>  #endif
> 
>  /*
> @@ -43,13 +58,9 @@ void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
>  		return;
>  	}
>  	ACCESS_ONCE(prev->next) = node;
> -	/*
> -	 * Wait until the lock holder passes the lock down.
> -	 * Using smp_load_acquire() provides a memory barrier that
> -	 * ensures subsequent operations happen after the lock is acquired.
> -	 */
> -	while (!(smp_load_acquire(&node->locked)))
> -		arch_mutex_cpu_relax();
> +
> +	/* Wait until the lock holder passes the lock down. */
> +	arch_mcs_spin_lock_contended(&node->locked);
>  }
>  EXPORT_SYMBOL_GPL(mcs_spin_lock);
> 
> @@ -71,12 +82,8 @@ void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
>  		while (!(next = ACCESS_ONCE(node->next)))
>  			arch_mutex_cpu_relax();
>  	}
> -	/*
> -	 * Pass lock to next waiter.
> -	 * smp_store_release() provides a memory barrier to ensure
> -	 * all operations in the critical section has been completed
> -	 * before unlocking.
> -	 */
> -	smp_store_release(&next->locked, 1);
> +
> +	/* Pass lock to next waiter. */
> +	arch_mcs_spin_unlock_contended(&next->locked);
>  }
>  EXPORT_SYMBOL_GPL(mcs_spin_unlock);
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
