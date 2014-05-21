Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 975886B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 09:08:29 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id f8so7637698wiw.2
        for <linux-mm@kvack.org>; Wed, 21 May 2014 06:08:29 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id x3si16145132wja.31.2014.05.21.06.02.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 May 2014 06:02:29 -0700 (PDT)
Date: Wed, 21 May 2014 15:02:23 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: filemap: Avoid unnecessary barries and waitqueue
 lookups in unlock_page fastpath v5
Message-ID: <20140521130223.GE2485@laptop.programming.kicks-ass.net>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-20-git-send-email-mgorman@suse.de>
 <20140513125313.GR23991@suse.de>
 <20140513141748.GD2485@laptop.programming.kicks-ass.net>
 <20140514161152.GA2615@redhat.com>
 <20140514192945.GA10830@redhat.com>
 <20140515104808.GF23991@suse.de>
 <20140515142414.16c47315a03160c58ceb9066@linux-foundation.org>
 <20140521121501.GT23991@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140521121501.GT23991@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On Wed, May 21, 2014 at 01:15:01PM +0100, Mel Gorman wrote:
> Andrew had suggested dropping v4 of the patch entirely as the numbers were
> marginal and the complexity was high. However, even on a relatively small
> machine running simple workloads the overhead of page_waitqueue and wakeup
> functions is around 5% of system CPU time. That's quite high for basic
> operations so I felt it was worth another shot. The performance figures
> are better with this version than they were for v4 and overall the patch
> should be more comprehensible.

Simpler patch and better performance, yay!

> This patch introduces a new page flag for 64-bit capable machines,
> PG_waiters, to signal there are processes waiting on PG_lock and uses it to
> avoid memory barriers and waitqueue hash lookup in the unlock_page fastpath.

The patch seems to also explicitly use it for PG_writeback, yet no
mention of that here.

> diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
> index 0ffa20a..f829e73 100644
> --- a/kernel/sched/wait.c
> +++ b/kernel/sched/wait.c
> @@ -167,31 +167,39 @@ EXPORT_SYMBOL_GPL(__wake_up_sync);	/* For internal use only */
>   * stops them from bleeding out - it would still allow subsequent
>   * loads to move into the critical region).
>   */
> +static inline void

Make that __always_inline, that way we're guaranteed to optimize the
build time constant .page=NULL cases.

> +__prepare_to_wait(wait_queue_head_t *q, wait_queue_t *wait,
> +			struct page *page, int state, bool exclusive)
>  {
>  	unsigned long flags;
>  
> +	if (page && !PageWaiters(page))
> +		SetPageWaiters(page);
> +	if (list_empty(&wait->task_list)) {
> +		if (exclusive) {
> +			wait->flags |= WQ_FLAG_EXCLUSIVE;
> +			__add_wait_queue_tail(q, wait);
> +		} else {

I'm fairly sure we've just initialized the wait thing to 0, so clearing
the bit would be superfluous.

> +			wait->flags &= ~WQ_FLAG_EXCLUSIVE;
> +			__add_wait_queue(q, wait);
> +		}
> +	}
>  	set_current_state(state);
>  	spin_unlock_irqrestore(&q->lock, flags);
>  }
> +
> +void
> +prepare_to_wait(wait_queue_head_t *q, wait_queue_t *wait, int state)
> +{
> +	return __prepare_to_wait(q, wait, NULL, state, false);
> +}
>  EXPORT_SYMBOL(prepare_to_wait);
>  
>  void
>  prepare_to_wait_exclusive(wait_queue_head_t *q, wait_queue_t *wait, int state)
>  {
> +	return __prepare_to_wait(q, wait, NULL, state, true);
>  }
>  EXPORT_SYMBOL(prepare_to_wait_exclusive);
>  
> @@ -228,7 +236,8 @@ EXPORT_SYMBOL(prepare_to_wait_event);
>   * the wait descriptor from the given waitqueue if still
>   * queued.
>   */
> +static inline void __finish_wait(wait_queue_head_t *q, wait_queue_t *wait,
> +			struct page *page)
>  {

Same thing, make that __always_inline.

>  	unsigned long flags;
>  
> @@ -249,9 +258,16 @@ void finish_wait(wait_queue_head_t *q, wait_queue_t *wait)
>  	if (!list_empty_careful(&wait->task_list)) {
>  		spin_lock_irqsave(&q->lock, flags);
>  		list_del_init(&wait->task_list);
> +		if (page && !waitqueue_active(q))
> +			ClearPageWaiters(page);
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

> @@ -374,6 +427,19 @@ int __sched out_of_line_wait_on_bit_lock(void *word, int bit,
>  }
>  EXPORT_SYMBOL(out_of_line_wait_on_bit_lock);
>  
> +void __wake_up_page_bit(wait_queue_head_t *wqh, struct page *page, void *word, int bit)
> +{
> +	struct wait_bit_key key = __WAIT_BIT_KEY_INITIALIZER(word, bit);
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&wqh->lock, flags);
> +	if (waitqueue_active(wqh))
> +		__wake_up_common(wqh, TASK_NORMAL, 1, 0, &key);
> +	else
> +		ClearPageWaiters(page);
> +	spin_unlock_irqrestore(&wqh->lock, flags);
> +}

Seeing how word is always going to be &page->flags, might it make sense
to remove that argument?


Anyway, looks good in principle. Oleg?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
