Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 23E876B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 17:26:25 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so1747160pdi.41
        for <linux-mm@kvack.org>; Wed, 21 May 2014 14:26:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id pv8si7829568pbb.3.2014.05.21.14.26.23
        for <linux-mm@kvack.org>;
        Wed, 21 May 2014 14:26:24 -0700 (PDT)
Date: Wed, 21 May 2014 14:26:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: filemap: Avoid unnecessary barries and waitqueue
 lookups in unlock_page fastpath v5
Message-Id: <20140521142622.049d0b3af5fc94912d5a1472@linux-foundation.org>
In-Reply-To: <20140521121501.GT23991@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
	<1399974350-11089-20-git-send-email-mgorman@suse.de>
	<20140513125313.GR23991@suse.de>
	<20140513141748.GD2485@laptop.programming.kicks-ass.net>
	<20140514161152.GA2615@redhat.com>
	<20140514192945.GA10830@redhat.com>
	<20140515104808.GF23991@suse.de>
	<20140515142414.16c47315a03160c58ceb9066@linux-foundation.org>
	<20140521121501.GT23991@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On Wed, 21 May 2014 13:15:01 +0100 Mel Gorman <mgorman@suse.de> wrote:

> Andrew had suggested dropping v4 of the patch entirely as the numbers were
> marginal and the complexity was high. However, even on a relatively small
> machine running simple workloads the overhead of page_waitqueue and wakeup
> functions is around 5% of system CPU time. That's quite high for basic
> operations so I felt it was worth another shot. The performance figures
> are better with this version than they were for v4 and overall the patch
> should be more comprehensible.
> 
> Changelog since v4
> o Remove dependency on io_schedule_timeout
> o Push waiting logic down into waitqueue
> 
> This patch introduces a new page flag for 64-bit capable machines,
> PG_waiters, to signal there are processes waiting on PG_lock and uses it to
> avoid memory barriers and waitqueue hash lookup in the unlock_page fastpath.
> 
> This adds a few branches to the fast path but avoids bouncing a dirty
> cache line between CPUs. 32-bit machines always take the slow path but the
> primary motivation for this patch is large machines so I do not think that
> is a concern.
> 
> The test case used to evaulate this is a simple dd of a large file done
> multiple times with the file deleted on each iterations. The size of
> the file is 1/10th physical memory to avoid dirty page balancing. In the
> async case it will be possible that the workload completes without even
> hitting the disk and will have variable results but highlight the impact
> of mark_page_accessed for async IO. The sync results are expected to be
> more stable. The exception is tmpfs where the normal case is for the "IO"
> to not hit the disk.
> 
> The test machine was single socket and UMA to avoid any scheduling or
> NUMA artifacts. Throughput and wall times are presented for sync IO, only
> wall times are shown for async as the granularity reported by dd and the
> variability is unsuitable for comparison. As async results were variable
> do to writback timings, I'm only reporting the maximum figures. The sync
> results were stable enough to make the mean and stddev uninteresting.
> 
> The performance results are reported based on a run with no profiling.
> Profile data is based on a separate run with oprofile running. The
> kernels being compared are "accessed-v2" which is the patch series up
> to this patch where as lockpage-v2 includes this patch.
> 
> ...
>
> --- a/include/linux/wait.h
> +++ b/include/linux/wait.h
> @@ -147,8 +147,13 @@ void __wake_up_sync_key(wait_queue_head_t *q, unsigned int mode, int nr, void *k
>  void __wake_up_locked(wait_queue_head_t *q, unsigned int mode, int nr);
>  void __wake_up_sync(wait_queue_head_t *q, unsigned int mode, int nr);
>  void __wake_up_bit(wait_queue_head_t *, void *, int);
> +void __wake_up_page_bit(wait_queue_head_t *, struct page *page, void *, int);

You're going to need to forward-declare struct page in wait.h.  The
good thing about this is that less people will notice that we've gone
and mentioned struct page in wait.h :(

>  int __wait_on_bit(wait_queue_head_t *, struct wait_bit_queue *, int (*)(void *), unsigned);
> +int __wait_on_page_bit(wait_queue_head_t *, struct wait_bit_queue *,
> 
> ...
>
> --- a/kernel/sched/wait.c
> +++ b/kernel/sched/wait.c
> @@ -167,31 +167,39 @@ EXPORT_SYMBOL_GPL(__wake_up_sync);	/* For internal use only */
>   * stops them from bleeding out - it would still allow subsequent
>   * loads to move into the critical region).
>   */
> -void
> -prepare_to_wait(wait_queue_head_t *q, wait_queue_t *wait, int state)
> +static inline void
> +__prepare_to_wait(wait_queue_head_t *q, wait_queue_t *wait,
> +			struct page *page, int state, bool exclusive)

Putting MM stuff into core waitqueue code is rather bad.  I really
don't know how I'm going to explain this to my family.

>  {
>  	unsigned long flags;
>  
> -	wait->flags &= ~WQ_FLAG_EXCLUSIVE;
>  	spin_lock_irqsave(&q->lock, flags);
> -	if (list_empty(&wait->task_list))
> -		__add_wait_queue(q, wait);
> +	if (page && !PageWaiters(page))
> +		SetPageWaiters(page);

And this isn't racy because we're assuming that all users of `page' are
using the same waitqueue.  ie, assuming all callers use
page_waitqueue()?   Subtle, unobvious, worth documenting.

> +	if (list_empty(&wait->task_list)) {
> +		if (exclusive) {
> +			wait->flags |= WQ_FLAG_EXCLUSIVE;
> +			__add_wait_queue_tail(q, wait);
> +		} else {
> +			wait->flags &= ~WQ_FLAG_EXCLUSIVE;
> +			__add_wait_queue(q, wait);
> +		}
> +	}
>  	set_current_state(state);
>  	spin_unlock_irqrestore(&q->lock, flags);
>  }
> 
> ...
>
> @@ -228,7 +236,8 @@ EXPORT_SYMBOL(prepare_to_wait_event);
>   * the wait descriptor from the given waitqueue if still
>   * queued.
>   */
> -void finish_wait(wait_queue_head_t *q, wait_queue_t *wait)
> +static inline void __finish_wait(wait_queue_head_t *q, wait_queue_t *wait,
> +			struct page *page)

Thusly does kerneldoc bitrot.

>  {
>  	unsigned long flags;
>  
> @@ -249,9 +258,16 @@ void finish_wait(wait_queue_head_t *q, wait_queue_t *wait)
>  	if (!list_empty_careful(&wait->task_list)) {
>  		spin_lock_irqsave(&q->lock, flags);
>  		list_del_init(&wait->task_list);
> +		if (page && !waitqueue_active(q))
> +			ClearPageWaiters(page);

And again, the assumption that all users of this page use the same
waitqueue avoids the races?

>  		spin_unlock_irqrestore(&q->lock, flags);
>  	}
>  }
> +
> +void finish_wait(wait_queue_head_t *q, wait_queue_t *wait)
> +{
> +	return __finish_wait(q, wait, NULL);
> +}
>  EXPORT_SYMBOL(finish_wait);
>  
>  /**
> @@ -331,6 +347,22 @@ __wait_on_bit(wait_queue_head_t *wq, struct wait_bit_queue *q,
>  	finish_wait(wq, &q->wait);
>  	return ret;
>  }
> +
> +int __sched
> +__wait_on_page_bit(wait_queue_head_t *wq, struct wait_bit_queue *q,
> +			struct page *page,
> +			int (*action)(void *), unsigned mode)

Comment over __wait_on_bit needs updating.

> +{
> +	int ret = 0;
> +
> +	do {
> +		__prepare_to_wait(wq, &q->wait, page, mode, false);
> +		if (test_bit(q->key.bit_nr, q->key.flags))
> +			ret = (*action)(q->key.flags);
> +	} while (test_bit(q->key.bit_nr, q->key.flags) && !ret);
> +	__finish_wait(wq, &q->wait, page);
> +	return ret;
> +}

__wait_on_bit() can now become a wrapper which calls this with page==NULL?

>  EXPORT_SYMBOL(__wait_on_bit);

This export is now misplaced.

>  int __sched out_of_line_wait_on_bit(void *word, int bit,
> @@ -344,6 +376,27 @@ int __sched out_of_line_wait_on_bit(void *word, int bit,
>  EXPORT_SYMBOL(out_of_line_wait_on_bit);
>  
>  int __sched
> +__wait_on_page_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
> +			struct page *page,
> +			int (*action)(void *), unsigned mode)
> +{
> +	do {
> +		int ret;
> +
> +		__prepare_to_wait(wq, &q->wait, page, mode, true);
> +		if (!test_bit(q->key.bit_nr, q->key.flags))
> +			continue;
> +		ret = action(q->key.flags);
> +		if (!ret)
> +			continue;
> +		abort_exclusive_wait(wq, &q->wait, mode, &q->key);
> +		return ret;
> +	} while (test_and_set_bit(q->key.bit_nr, q->key.flags));
> +	__finish_wait(wq, &q->wait, page);
> +	return 0;
> +}

You are in a maze of twisty little functions, all alike.  Perhaps some
rudimentary documentation here?  Like what on earth does
__wait_on_page_bit_lock() actually do?   And `mode'.


> +int __sched
>  __wait_on_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
>  			int (*action)(void *), unsigned mode)

Perhaps __wait_on_bit_lock() can become a wrapper around
__wait_on_page_bit_lock().

> 
> ...
>
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -67,6 +67,10 @@ static void __page_cache_release(struct page *page)
>  static void __put_single_page(struct page *page)
>  {
>  	__page_cache_release(page);
> +
> +	/* Clear dangling waiters from collisions on page_waitqueue */
> +	__ClearPageWaiters(page);

What's this collisions thing?

>  	free_hot_cold_page(page, false);
>  }
>  
> 
> ...
>
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1096,6 +1096,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		 * waiting on the page lock, because there are no references.
>  		 */
>  		__clear_page_locked(page);
> +		__ClearPageWaiters(page);

We're freeing the page - if someone is still waiting on it then we have
a huge bug?  It's the mysterious collision thing again I hope?

>  free_it:
>  		nr_reclaimed++;
>  
> 
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
