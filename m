Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 57EA16B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 04:55:52 -0500 (EST)
Date: Tue, 20 Dec 2011 09:55:44 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 11/11] mm: Isolate pages for immediate reclaim on their
 own LRU
Message-ID: <20111220095544.GP3487@suse.de>
References: <1323877293-15401-1-git-send-email-mgorman@suse.de>
 <1323877293-15401-12-git-send-email-mgorman@suse.de>
 <20111217160822.GA10064@barrios-laptop.redhat.com>
 <20111219132615.GL3487@suse.de>
 <20111220071026.GA19025@barrios-laptop.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20111220071026.GA19025@barrios-laptop.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Dec 20, 2011 at 04:10:26PM +0900, Minchan Kim wrote:
> > > >   * Writeback is about to end against a page which has been marked for immediate
> > > >   * reclaim.  If it still appears to be reclaimable, move it to the tail of the
> > > >   * inactive list.
> > > >   */
> > > >  void rotate_reclaimable_page(struct page *page)
> > > >  {
> > > > +	struct zone *zone = page_zone(page);
> > > > +	struct list_head *page_list;
> > > > +	struct pagevec *pvec;
> > > > +	unsigned long flags;
> > > > +
> > > > +	page_cache_get(page);
> > > > +	local_irq_save(flags);
> > > > +	__mod_zone_page_state(zone, NR_IMMEDIATE, -1);
> > > > +
> > > 
> > > I am not sure underflow never happen.
> > > We do SetPageReclaim at several places but dont' increase NR_IMMEDIATE.
> > > 
> > 
> > In those cases, we do not move the page to the immedate list either.
> 
> That's my concern.
> We didn't move the page to immediate list but set SetPageReclaim. It means
> we don't increate NR_IMMEDIATE.
> If end_page_writeback have called that page, rotate_reclimable_page would be called.
> Eventually, __mod_zone_page_state(zone, NR_IMMEDIATE, -1) is called.
> But I didn't look into the code yet for confirming it's possbile or not.
> 

Ah, now I see your concern. The key is that they get moved to the
immediate LRU later although it is not obvious. This should be double
checked but when I was implementing this, I looked at the different
places that called SetPageReclaim.

mm/swap.c:lru_deactivate_fn() calls SetPageReclaim but also moves the
	page to the immediate LRU list so no problem with accounting
	there.

mm/vmscan.c:pageout() calls SetPageReclaim but does not move the page
	explicitly as such. Instead, it gets picked up by
	putback_lru_pages() later which checks for inactive LRU pages
	that are marked PageReclaim and selects the immediate LRU in
	this case. The counter gets incremented for the appropriate
	LRU list by __add_page_to_lru_list(). Even if we do have
	an active page with PageReclaim set, it should not cause an
	accounting difficulty

mm/vmscan.c:shrink_page_list() calls SetPageReclaim but like pageout(),
	it gets picked up by putback_lru_pages() later

Did I miss anything?

> > During one test I was recording /proc/vmstat every 10 seconds and never
> > saw an underflow.
> 
> If it's very rare, it would be very hard to see it.
> 

But once it happened, I would not expect it to recover. The nr_immediate
value usually reads as 0.

> > > > <SNIP>
> > > >  static void update_page_reclaim_stat(struct zone *zone, struct page *page,
> > > > @@ -475,6 +532,13 @@ static void lru_deactivate_fn(struct page *page, void *arg)
> > > >  		 * is _really_ small and  it's non-critical problem.
> > > >  		 */
> > > >  		SetPageReclaim(page);
> > > > +
> > > > +		/*
> > > > +		 * Move to the LRU_IMMEDIATE list to avoid being scanned
> > > > +		 * by page reclaim uselessly.
> > > > +		 */
> > > > +		list_move_tail(&page->lru, &zone->lru[LRU_IMMEDIATE].list);
> > > > +		__mod_zone_page_state(zone, NR_IMMEDIATE, 1);
> > > 
> > > It mekes below count of PGDEACTIVATE wrong in lru_deactivate_fn.
> > > Before this patch, all is from active to inacive so it was right.
> > > But with this patch, it can be from acdtive to immediate.
> > > 
> > 
> > I do not quite understand. PGDEACTIVATE is incremented if the page was
> > active and this is checked before the move to the immediate LRU. Whether
> > it moves to the immediate LRU or the end of the inactive list, it is
> > still a deactivation. What's wrong with incrementing the count if it
> 
> Hmm, I have thought deactivation is only from active to deactive.

This is a matter of definition really. The page is going from active
to inactive. The immediate list is similar to the inactive list in
this case, at least from a deactivation point of view.

> I might be wrong but if we perhaps move page from active to unevictable list,
> is it deactivation, too? 

I would consider it a deactivate if PageActive got cleared. Here we are
talking about the lru_deactivate_fn function. Whether it moves to the
immediate list or the end of the inactive list, the page is being
deactivated.

> Maybe we need consistent count.
> 

In this case, I think we are being consistent. The page is deactivated,
we increase the PFDEACTIVATE counter.

Thanks very much for reviewing this closely, I appreciate it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
