Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8A8466B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 10:40:52 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id e53so2636456eek.8
        for <linux-mm@kvack.org>; Thu, 22 May 2014 07:40:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r5si809122eem.166.2014.05.22.07.40.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 22 May 2014 07:40:50 -0700 (PDT)
Date: Thu, 22 May 2014 15:40:45 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: filemap: Avoid unnecessary barriers and waitqueue
 lookups in unlock_page fastpath v7
Message-ID: <20140522144045.GH23991@suse.de>
References: <20140515104808.GF23991@suse.de>
 <20140515142414.16c47315a03160c58ceb9066@linux-foundation.org>
 <20140521121501.GT23991@suse.de>
 <20140521142622.049d0b3af5fc94912d5a1472@linux-foundation.org>
 <20140521213354.GL2485@laptop.programming.kicks-ass.net>
 <20140521145000.f130f8779f7641d0d8afcace@linux-foundation.org>
 <20140522000715.GA23991@suse.de>
 <20140522072001.GP30445@twins.programming.kicks-ass.net>
 <20140522104051.GE23991@suse.de>
 <20140522105638.GT30445@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140522105638.GT30445@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Thu, May 22, 2014 at 12:56:38PM +0200, Peter Zijlstra wrote:
> On Thu, May 22, 2014 at 11:40:51AM +0100, Mel Gorman wrote:
> > +void __wake_up_page_bit(wait_queue_head_t *wqh, struct page *page, void *word, int bit)
> > +{
> > +	struct wait_bit_key key = __WAIT_BIT_KEY_INITIALIZER(word, bit);
> > +	unsigned long flags;
> > +
> > +	/* If there is no PG_waiters bit, always take the slow path */
> 
> That comment is misleading, this is actually a fast path for
> !PG_waiters.
> 
> > +	if (!__PG_WAITERS && waitqueue_active(wq)) {
> > +		__wake_up(wq, TASK_NORMAL, 1, &key);
> > +		return;
> > +	}
> > +
> > +	/*
> > +	 * Unlike __wake_up_bit it is necessary to check waitqueue_active to be
> > +	 * checked under the wqh->lock to avoid races with parallel additions
> > +	 * to the waitqueue. Otherwise races could result in lost wakeups
> > +	 */
> > +	spin_lock_irqsave(&wqh->lock, flags);
> > +	if (waitqueue_active(wqh))
> > +		__wake_up_common(wqh, TASK_NORMAL, 1, 0, &key);
> > +	else
> > +		ClearPageWaiters(page);
> > +	spin_unlock_irqrestore(&wqh->lock, flags);
> > +}
> 
> So I think you missed one Clear opportunity here that was in my original
> proposal, possibly because you also frobbed PG_writeback in.
> 
> If you do:
> 
> 	spin_lock_irqsave(&wqh->lock, flags);
> 	if (!waitqueue_active(wqh) || !__wake_up_common(wqh, TASK_NORMAL, 1, 0, &key))
> 		ClearPageWaiters(page);
> 	spin_unlock_irqrestore(&wqh->lock, flags);
> 
> With the below change to __wake_up_common(), we'll also clear the bit
> when there's no waiters of @page, even if there's waiters for another
> page.
> 
> I suppose the one thing to say for the big open coded loop is that its
> much easier to read than this scattered stuff.
> 
> ---
> diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
> index 0ffa20ae657b..213c5bfe6b56 100644
> --- a/kernel/sched/wait.c
> +++ b/kernel/sched/wait.c
> @@ -61,18 +61,23 @@ EXPORT_SYMBOL(remove_wait_queue);
>   * started to run but is not in state TASK_RUNNING. try_to_wake_up() returns
>   * zero in this (rare) case, and we handle it by continuing to scan the queue.
>   */
> -static void __wake_up_common(wait_queue_head_t *q, unsigned int mode,
> +static bool __wake_up_common(wait_queue_head_t *q, unsigned int mode,
>  			int nr_exclusive, int wake_flags, void *key)
>  {
>  	wait_queue_t *curr, *next;
> +	bool woke = false;
>  
>  	list_for_each_entry_safe(curr, next, &q->task_list, task_list) {
>  		unsigned flags = curr->flags;
>  
> -		if (curr->func(curr, mode, wake_flags, key) &&
> -				(flags & WQ_FLAG_EXCLUSIVE) && !--nr_exclusive)
> -			break;
> +		if (curr->func(curr, mode, wake_flags, key)) {
> +			woke = true;
> +			if ((flags & WQ_FLAG_EXCLUSIVE) && !--nr_exclusive)
> +				break;
> +		}
>  	}
> +
> +	return woke;

Ok, thinking about this more I'm less sure.

There are cases where the curr->func returns false even though there is a
task that needs to run -- task was already running or preparing to run. We
potentially end up clearing PG_waiters while there are still tasks on the
waitqueue. As __finish_wait checks if the waitqueue is empty and the last
waiter clears the bit I think there is nothing to gain by trying to do the
same job in __wake_up_page_bit.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
