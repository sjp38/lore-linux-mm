Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C24356B004A
	for <linux-mm@kvack.org>; Sun, 28 Nov 2010 20:58:50 -0500 (EST)
Received: by qwi2 with SMTP id 2so1037934qwi.14
        for <linux-mm@kvack.org>; Sun, 28 Nov 2010 17:58:48 -0800 (PST)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: Re: [PATCH v2 1/3] deactivate invalidated pages
In-Reply-To: <20101129090514.829C.A69D9226@jp.fujitsu.com>
References: <7b50614882592047dfd96f6ca2bb2d0baa8f5367.1290956059.git.minchan.kim@gmail.com> <20101129090514.829C.A69D9226@jp.fujitsu.com>
Date: Sun, 28 Nov 2010 20:58:36 -0500
Message-ID: <87pqto3n77.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Nov 2010 09:33:38 +0900 (JST), KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > ---
> >  mm/swap.c |   84 +++++++++++++++++++++++++++++++++++++++++++++---------------
> >  1 files changed, 63 insertions(+), 21 deletions(-)
> > 
> > diff --git a/mm/swap.c b/mm/swap.c
> > index 31f5ec4..345eca1 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -268,10 +268,65 @@ void add_page_to_unevictable_list(struct page *page)
> >  	spin_unlock_irq(&zone->lru_lock);
> >  }
> >  
> > -static void __pagevec_lru_deactive(struct pagevec *pvec)
> > +/*
> > + * This function is used by invalidate_mapping_pages.
> > + * If the page can't be invalidated, this function moves the page
> > + * into inative list's head or tail to reclaim ASAP and evict
> > + * working set page.
> > + *
> > + * PG_reclaim means when the page's writeback completes, the page
> > + * will move into tail of inactive for reclaiming ASAP.
> > + *
> > + * 1. active, mapped page -> inactive, head
> > + * 2. active, dirty/writeback page -> inactive, head, PG_reclaim
> > + * 3. inactive, mapped page -> none
> > + * 4. inactive, dirty/writeback page -> inactive, head, PG_reclaim
> > + * 5. others -> none
> > + *
> > + * In 4, why it moves inactive's head, the VM expects the page would
> > + * be writeout by flusher. The flusher's writeout is much effective than
> > + * reclaimer's random writeout.
> > + */
> > +static void __lru_deactivate(struct page *page, struct zone *zone)
> >  {
> > -	int i, lru, file;
> > +	int lru, file;
> > +	int active = 0;
> > +
> > +	if (!PageLRU(page))
> > +		return;
> > +
> > +	if (PageActive(page))
> > +		active = 1;
> > +	/* Some processes are using the page */
> > +	if (page_mapped(page) && !active)
> > +		return;
> > +
> > +	else if (PageWriteback(page)) {
> > +		SetPageReclaim(page);
> > +		/* Check race with end_page_writeback */
> > +		if (!PageWriteback(page))
> > +			ClearPageReclaim(page);
> > +	} else if (PageDirty(page))
> > +		SetPageReclaim(page);
> > +
> > +	file = page_is_file_cache(page);
> > +	lru = page_lru_base_type(page);
> > +	del_page_from_lru_list(zone, page, lru + active);
> > +	ClearPageActive(page);
> > +	ClearPageReferenced(page);
> > +	add_page_to_lru_list(zone, page, lru);
> > +	if (active)
> > +		__count_vm_event(PGDEACTIVATE);
> > +
> > +	update_page_reclaim_stat(zone, page, file, 0);
> > +}
> 
> I don't like this change because fadvise(DONT_NEED) is rarely used
> function and this PG_reclaim trick doesn't improve so much. In the
> other hand, It increase VM state mess.
> 

Can we please stop appealing to this argument? The reason that
fadvise(DONT_NEED) is currently rarely employed is that the interface as
implemented now is extremely kludgey to use.

Are you proposing that this particular implementation is not worth the
mess (as opposed to putting the pages at the head of the inactive list
as done earlier) or would you rather that we simply leave DONT_NEED in
its current state? Even if today's gains aren't as great as we would
like them to be, we should still make an effort to make fadvise()
usable, if for no other reason than to encourage use in user-space so
that applications can benefit when we finally do figure out how to
properly account for the user's hints.

Cheers,

- Ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
