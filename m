Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id D4A526B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 12:08:46 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id q59so2285226wes.35
        for <linux-mm@kvack.org>; Wed, 21 May 2014 09:08:46 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id hb4si1453680wib.0.2014.05.21.09.08.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 May 2014 09:08:45 -0700 (PDT)
Date: Wed, 21 May 2014 18:08:37 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: filemap: Avoid unnecessary barries and waitqueue
 lookups in unlock_page fastpath v5
Message-ID: <20140521160837.GH2485@laptop.programming.kicks-ass.net>
References: <1399974350-11089-20-git-send-email-mgorman@suse.de>
 <20140513125313.GR23991@suse.de>
 <20140513141748.GD2485@laptop.programming.kicks-ass.net>
 <20140514161152.GA2615@redhat.com>
 <20140514192945.GA10830@redhat.com>
 <20140515104808.GF23991@suse.de>
 <20140515142414.16c47315a03160c58ceb9066@linux-foundation.org>
 <20140521121501.GT23991@suse.de>
 <20140521130223.GE2485@laptop.programming.kicks-ass.net>
 <20140521153357.GW23991@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140521153357.GW23991@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On Wed, May 21, 2014 at 04:33:57PM +0100, Mel Gorman wrote:
> > > +__prepare_to_wait(wait_queue_head_t *q, wait_queue_t *wait,
> > > +			struct page *page, int state, bool exclusive)
> > >  {
> > >  	unsigned long flags;
> > >  
> > > +	if (page && !PageWaiters(page))
> > > +		SetPageWaiters(page);
> > > +	if (list_empty(&wait->task_list)) {
> > > +		if (exclusive) {
> > > +			wait->flags |= WQ_FLAG_EXCLUSIVE;
> > > +			__add_wait_queue_tail(q, wait);
> > > +		} else {
> > 
> > I'm fairly sure we've just initialized the wait thing to 0, so clearing
> > the bit would be superfluous.
> > 
> 
> I assume you mean the clearing of WQ_FLAG_EXCLUSIVE. It may or may not be
> superflous. If it's an on-stack wait_queue_t initialised with DEFINE_WAIT()
> then it's redundant. If it's a wait_queue_t that is being reused and
> sometimes used for exclusive waits and other times for non-exclusive
> waits then it's required. The API allows this to happen so I see no harm
> is clearing the flag like the old code did. Am I missing your point?

Yeah, I'm not aware of any other users except the on-stack kind, but
you're right.

Maybe we should stick an object_is_on_stack() test in there to see if
anything falls out, something for a rainy afternoon perhaps..

> > > +void __wake_up_page_bit(wait_queue_head_t *wqh, struct page *page, void *word, int bit)
> > > +{
> > > +	struct wait_bit_key key = __WAIT_BIT_KEY_INITIALIZER(word, bit);
> > > +	unsigned long flags;
> > > +
> > > +	spin_lock_irqsave(&wqh->lock, flags);
> > > +	if (waitqueue_active(wqh))
> > > +		__wake_up_common(wqh, TASK_NORMAL, 1, 0, &key);
> > > +	else
> > > +		ClearPageWaiters(page);
> > > +	spin_unlock_irqrestore(&wqh->lock, flags);
> > > +}
> > 
> > Seeing how word is always going to be &page->flags, might it make sense
> > to remove that argument?
> > 
> 
> The wait_queue was defined on-stack with DEFINE_WAIT_BIT which uses
> wake_bit_function() as a wakeup function and that thing consumes both the
> page->flags and the bit number it's interested in. This is used for both
> PG_writeback and PG_locked so assumptions cannot really be made about
> the value.

Well, both PG_flags come from the same &page->flags word, right? But
yeah, if we ever decide to grow the page frame with another flags word
we'd be in trouble :-)

In any case I don't feel too strongly about either of these points.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
