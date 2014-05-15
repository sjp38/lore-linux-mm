Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id BDFFC6B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 12:18:12 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id c13so813185eek.26
        for <linux-mm@kvack.org>; Thu, 15 May 2014 09:18:12 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h41si4531421eeo.178.2014.05.15.09.18.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 May 2014 09:18:11 -0700 (PDT)
Date: Thu, 15 May 2014 17:18:04 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: filemap: Avoid unnecessary barries and waitqueue
 lookups in unlock_page fastpath v4
Message-ID: <20140515161804.GG23991@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-20-git-send-email-mgorman@suse.de>
 <20140513125313.GR23991@suse.de>
 <20140513141748.GD2485@laptop.programming.kicks-ass.net>
 <20140514161152.GA2615@redhat.com>
 <20140514192945.GA10830@redhat.com>
 <20140515104808.GF23991@suse.de>
 <20140515132058.GL30445@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140515132058.GL30445@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On Thu, May 15, 2014 at 03:20:58PM +0200, Peter Zijlstra wrote:
> On Thu, May 15, 2014 at 11:48:09AM +0100, Mel Gorman wrote:
> 
> > +static inline wait_queue_head_t *clear_page_waiters(struct page *page)
> >  {
> > +	wait_queue_head_t *wqh = NULL;
> > +
> > +	if (!PageWaiters(page))
> > +		return NULL;
> > +
> > +	/*
> > +	 * Prepare to clear PG_waiters if the waitqueue is no longer
> > +	 * active. Note that there is no guarantee that a page with no
> > +	 * waiters will get cleared as there may be unrelated pages
> > +	 * sleeping on the same page wait queue. Accurate detection
> > +	 * would require a counter. In the event of a collision, the
> > +	 * waiter bit will dangle and lookups will be required until
> > +	 * the page is unlocked without collisions. The bit will need to
> > +	 * be cleared before freeing to avoid triggering debug checks.
> > +	 *
> > +	 * Furthermore, this can race with processes about to sleep on
> > +	 * the same page if it adds itself to the waitqueue just after
> > +	 * this check. The timeout in sleep_on_page prevents the race
> > +	 * being a terminal one. In effect, the uncontended and non-race
> > +	 * cases are faster in exchange for occasional worst case of the
> > +	 * timeout saving us.
> > +	 */
> > +	wqh = page_waitqueue(page);
> > +	if (!waitqueue_active(wqh))
> > +		ClearPageWaiters(page);
> > +
> > +	return wqh;
> > +}
> 
> So clear_page_waiters() is I think a bad name for this function, for one
> it doesn't relate to returning a wait_queue_head.
> 

Fair point. find_waiters_queue()?

> Secondly, I think the clear condition is wrong, if I understand the rest
> of the code correctly we'll keep PageWaiters set until the above
> condition, which is not a single waiter on the waitqueue.
> 
> Would it not make much more sense to clear the page when there are no
> more waiters of this page?
> 

The page_waitqueue is hashed and multiple unrelated pages can be waiting
on the same queue. The queue entry is allocated on the stack so we've lost
track of the page being waited on and we've lost track of the page at
that point. I didn't spot a fast way of detecting if any of the waiters
were for that particular page or not and there is an expectation that
collisions on this waitqueue are rare.

> For the case where there are no waiters at all, this is the same
> condition, but in case there's a hash collision and there's other pages
> waiting, we'll iterate the lot anyway, so we might as well clear it
> there.
> 

> > +/* Returns true if the page is locked */
> > +static inline bool prepare_wait_bit(struct page *page, wait_queue_head_t *wqh,
> > +			wait_queue_t *wq, int state, int bit_nr, bool exclusive)
> > +{
> > +
> > +	/* Set PG_waiters so a racing unlock_page will check the waitiqueue */
> > +	if (!PageWaiters(page))
> > +		SetPageWaiters(page);
> > +
> > +	if (exclusive)
> > +		prepare_to_wait_exclusive(wqh, wq, state);
> > +	else
> > +		prepare_to_wait(wqh, wq, state);
> > +	return test_bit(bit_nr, &page->flags);
> >  }
> >  
> >  void wait_on_page_bit(struct page *page, int bit_nr)
> >  {
> > +	wait_queue_head_t *wqh;
> >  	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
> >  
> > +	if (!test_bit(bit_nr, &page->flags))
> > +		return;
> > +	wqh = page_waitqueue(page);
> > +
> > +	do {
> > +		if (prepare_wait_bit(page, wqh, &wait.wait, TASK_KILLABLE, bit_nr, false))
> > +			sleep_on_page_killable(page);
> > +	} while (test_bit(bit_nr, &page->flags));
> > +	finish_wait(wqh, &wait.wait);
> >  }
> >  EXPORT_SYMBOL(wait_on_page_bit);
> 
> Afaict, after this patch, wait_on_page_bit() is only used by
> wait_on_page_writeback(), and might I ask why that needs the PageWaiter
> set?
> 

To avoid doing a page_waitqueue lookup in end_page_writeback().

> >  int wait_on_page_bit_killable(struct page *page, int bit_nr)
> >  {
> > +	wait_queue_head_t *wqh;
> >  	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
> > +	int ret = 0;
> >  
> >  	if (!test_bit(bit_nr, &page->flags))
> >  		return 0;
> > +	wqh = page_waitqueue(page);
> > +
> > +	do {
> > +		if (prepare_wait_bit(page, wqh, &wait.wait, TASK_KILLABLE, bit_nr, false))
> > +			ret = sleep_on_page_killable(page);
> > +	} while (!ret && test_bit(bit_nr, &page->flags));
> > +	finish_wait(wqh, &wait.wait);
> >  
> > +	return ret;
> >  }
> 
> The only user of wait_on_page_bit_killable() _was_
> wait_on_page_locked_killable(), but you've just converted that to use
> __wait_on_page_bit_killable().
> 
> So we can scrap this function.
> 

Scrapped

> >  /**
> > @@ -721,6 +785,8 @@ void add_page_wait_queue(struct page *page, wait_queue_t *waiter)
> >  	unsigned long flags;
> >  
> >  	spin_lock_irqsave(&q->lock, flags);
> > +	if (!PageWaiters(page))
> > +		SetPageWaiters(page);
> >  	__add_wait_queue(q, waiter);
> >  	spin_unlock_irqrestore(&q->lock, flags);
> >  }
> 
> What does add_page_wait_queue() do and why does it need PageWaiters?
> 

cachefiles uses it for an internal monitor but you're right that this is
necessary because it does not go through paths that conditionally wake
depending on PageWaiters.

Deleted.

> > @@ -740,10 +806,29 @@ EXPORT_SYMBOL_GPL(add_page_wait_queue);
> >   */
> >  void unlock_page(struct page *page)
> >  {
> > +	wait_queue_head_t *wqh = clear_page_waiters(page);
> > +
> >  	VM_BUG_ON_PAGE(!PageLocked(page), page);
> > +
> > +	/*
> > +	 * clear_bit_unlock is not necessary in this case as there is no
> > +	 * need to strongly order the clearing of PG_waiters and PG_locked.
> > +	 * The smp_mb__after_atomic() barrier is still required for RELEASE
> > +	 * semantics as there is no guarantee that a wakeup will take place
> > +	 */
> > +	clear_bit(PG_locked, &page->flags);
> >  	smp_mb__after_atomic();
> 
> If you need RELEASE, use _unlock() because that's exactly what it does.
> 

Done

> > +
> > +	/*
> > +	 * Wake the queue if waiters were detected. Ordinarily this wakeup
> > +	 * would be unconditional to catch races between the lock bit being
> > +	 * set and a new process joining the queue. However, that would
> > +	 * require the waitqueue to be looked up every time. Instead we
> > +	 * optimse for the uncontended and non-race case and recover using
> > +	 * a timeout in sleep_on_page.
> > +	 */
> > +	if (wqh)
> > +		__wake_up_bit(wqh, &page->flags, PG_locked);
> 
> And the only reason we're not clearing PageWaiters under q->lock is to
> skimp on the last contended unlock_page() ?
> 

During implementation I used a new zone lock and then tree_lock to protect
the bit prior to using io_schedule_timeout. This protected the PageWaiter
bit but the granularity of such a lock was troublesome. The problem I
encountered was that the unlock_page() path would not have a reference
to the waitqueue when checking PageWaiters and could hit this race (as it
was structured at the time, code has changed since)

unlock_page			lock_page
				prepare_to_wait
  if (!PageWaiters)
  	return
				SetPageWaiters
				sleep forever

The order of SetPageWaiters is now different but I didn't revisit using
q->lock to see if that race can be closed.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
