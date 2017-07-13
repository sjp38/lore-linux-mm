Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4544D440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 04:58:34 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id g14so51134737pgu.9
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 01:58:34 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id e21si3745764pfh.275.2017.07.13.01.58.32
        for <linux-mm@kvack.org>;
        Thu, 13 Jul 2017 01:58:33 -0700 (PDT)
Date: Thu, 13 Jul 2017 17:57:46 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v7 06/16] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170713085746.GH20323@X58A-UD3R>
References: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
 <1495616389-29772-7-git-send-email-byungchul.park@lge.com>
 <20170711161232.GB28975@worktop>
 <20170712020053.GB20323@X58A-UD3R>
 <20170712075617.o2jds2giuoqxjqic@hirez.programming.kicks-ass.net>
 <20170713020745.GG20323@X58A-UD3R>
 <20170713081442.GA439@worktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170713081442.GA439@worktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Thu, Jul 13, 2017 at 10:14:42AM +0200, Peter Zijlstra wrote:
> On Thu, Jul 13, 2017 at 11:07:45AM +0900, Byungchul Park wrote:
> > Does my approach have problems, rewinding to 'original idx' on exit and
> > deciding whether overwrite or not? I think, this way, no need to do the
> > drastic work. Or.. does my one get more overhead in usual case?
> 
> So I think that invalidating just the one entry doesn't work; the moment

I think invalidating just the one is enough. After rewinding, the entry
will be invalidated and the ring buffer starts to be filled forward from
the point with valid ones. When commit, it will proceed backward with
valid ones until meeting the invalidated entry and stop.

IOW, in case of (overwritten)

         rewind to here
         |
ppppppppppiiiiiiiiiiiiiiii
iiiiiiiiiiiiiii

         invalidate it on exit_irq
         and start to fill from here again
         |
pppppppppxiiiiiiiiiiiiiiii
iiiiiiiiiiiiiii

                    when commit occurs here
                    |
pppppppppxpppppppppppiiiii

         do commit within this range
         |<---------|
pppppppppxpppppppppppiiiii

So I think this works and is much simple. Anything I missed?

> you fill that up the iteration in commit_xhlocks() will again use the
> next one etc.. even though you wanted it not to.
> 
> So we need to wipe the _entire_ history.
> 
> So I _think_ the below should work, but its not been near a compiler.
> 
> 
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -822,6 +822,7 @@ struct task_struct {
>  	unsigned int xhlock_idx_soft; /* For restoring at softirq exit */
>  	unsigned int xhlock_idx_hard; /* For restoring at hardirq exit */
>  	unsigned int xhlock_idx_hist; /* For restoring at history boundaries */
> +	unsigned int xhlock_idX_max;
>  #endif
>  #ifdef CONFIG_UBSAN
>  	unsigned int			in_ubsan;
> --- a/kernel/locking/lockdep.c
> +++ b/kernel/locking/lockdep.c
> @@ -4746,6 +4746,14 @@ EXPORT_SYMBOL_GPL(lockdep_rcu_suspicious
>  static atomic_t cross_gen_id; /* Can be wrapped */
>  
>  /*
> + * make xhlock_valid() false.
> + */
> +static inline void invalidate_xhlock(struct hist_lock *xhlock)
> +{
> +	xhlock->hlock.instance = NULL;
> +}
> +
> +/*
>   * Lock history stacks; we have 3 nested lock history stacks:
>   *
>   *   Hard IRQ
> @@ -4764,28 +4772,58 @@ static atomic_t cross_gen_id; /* Can be
>   * MAX_XHLOCKS_NR ? Possibly re-instroduce hist_gen_id ?
>   */
>  
> -void crossrelease_hardirq_start(void)
> +static inline void __crossrelease_start(unsigned int *stamp)
>  {
>  	if (current->xhlocks)
> -		current->xhlock_idx_hard = current->xhlock_idx;
> +		*stamp = current->xhlock_idx;
> +}
> +
> +static void __crossrelease_end(unsigned int *stamp)
> +{
> +	int i;
> +
> +	if (!current->xhlocks)
> +		return;
> +
> +	current->xhlock_idx = *stamp;
> +
> +	/*
> +	 * If we rewind past the tail; all of history is lost.
> +	 */
> +	if ((current->xhlock_idx_max - *stamp) < MAX_XHLOCKS_NR)
> +		return;
> +
> +	/*
> +	 * Invalidate the entire history..
> +	 */
> +	for (i = 0; i < MAX_XHLOCKS_NR; i++)
> +		invalidate_xhlock(&xhlock(i));
> +
> +	current->xhlock_idx = 0;
> +	current->xhlock_idx_hard = 0;
> +	current->xhlock_idx_soft = 0;
> +	current->xhlock_idx_hist = 0;
> +	current->xhlock_idx_max = 0;
> +}
> +
> +void crossrelease_hardirq_start(void)
> +{
> +	__crossrelease_start(&current->xhlock_idx_hard);
>  }
>  
>  void crossrelease_hardirq_end(void)
>  {
> -	if (current->xhlocks)
> -		current->xhlock_idx = current->xhlock_idx_hard;
> +	__crossrelease_end(&current->xhlock_idx_hard);
>  }
>  
>  void crossrelease_softirq_start(void)
>  {
> -	if (current->xhlocks)
> -		current->xhlock_idx_soft = current->xhlock_idx;
> +	__crossrelease_start(&current->xhlock_idx_soft);
>  }
>  
>  void crossrelease_softirq_end(void)
>  {
> -	if (current->xhlocks)
> -		current->xhlock_idx = current->xhlock_idx_soft;
> +	__crossrelease_end(&current->xhlock_idx_soft);
>  }
>  
>  /*
> @@ -4806,14 +4844,12 @@ void crossrelease_softirq_end(void)
>   */
>  void crossrelease_hist_start(void)
>  {
> -	if (current->xhlocks)
> -		current->xhlock_idx_hist = current->xhlock_idx;
> +	__crossrelease_start(&current->xhlock_idx_hist);
>  }
>  
>  void crossrelease_hist_end(void)
>  {
> -	if (current->xhlocks)
> -		current->xhlock_idx = current->xhlock_idx_hist;
> +	__crossrelease_end(&current->xhlock_idx_hist);
>  }
>  
>  static int cross_lock(struct lockdep_map *lock)
> @@ -4880,6 +4916,9 @@ static void add_xhlock(struct held_lock
>  	unsigned int idx = ++current->xhlock_idx;
>  	struct hist_lock *xhlock = &xhlock(idx);
>  
> +	if ((int)(current->xhlock_idx_max - idx) < 0)
> +		current->xhlock_idx_max = idx;
> +
>  #ifdef CONFIG_DEBUG_LOCKDEP
>  	/*
>  	 * This can be done locklessly because they are all task-local

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
