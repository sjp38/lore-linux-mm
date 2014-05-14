Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id C7CF26B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 03:31:39 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e49so1017831eek.35
        for <linux-mm@kvack.org>; Wed, 14 May 2014 00:31:39 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 45si976596eeq.137.2014.05.14.00.31.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 May 2014 00:31:38 -0700 (PDT)
Date: Wed, 14 May 2014 08:31:33 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 19/19] mm: filemap: Avoid unnecessary barries and
 waitqueue lookups in unlock_page fastpath
Message-ID: <20140514073133.GY23991@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-20-git-send-email-mgorman@suse.de>
 <20140513165223.GB5226@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140513165223.GB5226@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Tue, May 13, 2014 at 06:52:23PM +0200, Peter Zijlstra wrote:
> On Tue, May 13, 2014 at 10:45:50AM +0100, Mel Gorman wrote:
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index c60ed0f..d81ed7d 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -241,15 +241,15 @@ void delete_from_page_cache(struct page *page)
> >  }
> >  EXPORT_SYMBOL(delete_from_page_cache);
> >  
> > -static int sleep_on_page(void *word)
> > +static int sleep_on_page(void)
> >  {
> > -	io_schedule();
> > +	io_schedule_timeout(HZ);
> >  	return 0;
> >  }
> >  
> > -static int sleep_on_page_killable(void *word)
> > +static int sleep_on_page_killable(void)
> >  {
> > -	sleep_on_page(word);
> > +	sleep_on_page();
> >  	return fatal_signal_pending(current) ? -EINTR : 0;
> >  }
> >  
> 
> I've got a patch from NeilBrown that conflicts with this, shouldn't be
> hard to resolve though.
> 

Kick me if there are problems.

> > @@ -680,30 +680,105 @@ static wait_queue_head_t *page_waitqueue(struct page *page)
> >  	return &zone->wait_table[hash_ptr(page, zone->wait_table_bits)];
> >  }
> >  
> > -static inline void wake_up_page(struct page *page, int bit)
> > +static inline wait_queue_head_t *clear_page_waiters(struct page *page)
> >  {
> > -	__wake_up_bit(page_waitqueue(page), &page->flags, bit);
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
> This of course is properly disgusting, but my brain isn't working right
> on 4 hours of sleep, so I'm able to suggest anything else.

It could be "solved" by adding a zone lock or abusing the mapping tree_lock
to protect the waiters bit but that would put a very expensive operation into
the unlock page path. Same goes for any sort of sequence counter tricks. The
waitqueue lock cannot be used in this case because that would necessitate
looking up page_waitqueue every time which would render the patch useless.

It occurs to me that one option would be to recheck waiters once we're
added to the waitqueue and if PageWaiters is clear then recheck the bit
we're waiting on instead of going to sleep.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
