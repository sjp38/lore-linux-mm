Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C41136B0096
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 10:21:59 -0500 (EST)
Received: by pwi6 with SMTP id 6so23468pwi.14
        for <linux-mm@kvack.org>; Tue, 07 Dec 2010 07:21:58 -0800 (PST)
Date: Wed, 8 Dec 2010 00:21:47 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v4 4/7] Reclaim invalidated page ASAP
Message-ID: <20101207152147.GA608@barrios-desktop>
References: <cover.1291568905.git.minchan.kim@gmail.com>
 <0724024711222476a0c8deadb5b366265b8e5824.1291568905.git.minchan.kim@gmail.com>
 <20101207150525.GD2356@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101207150525.GD2356@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 07, 2010 at 04:05:25PM +0100, Johannes Weiner wrote:
> On Mon, Dec 06, 2010 at 02:29:12AM +0900, Minchan Kim wrote:
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -275,26 +275,59 @@ void add_page_to_unevictable_list(struct page *page)
> >   * head of the list, rather than the tail, to give the flusher
> >   * threads some time to write it out, as this is much more
> >   * effective than the single-page writeout from reclaim.
> > + *
> > + * If the page isn't page_mapped and dirty/writeback, the page
> > + * could reclaim asap using PG_reclaim.
> > + *
> > + * 1. active, mapped page -> none
> > + * 2. active, dirty/writeback page -> inactive, head, PG_reclaim
> > + * 3. inactive, mapped page -> none
> > + * 4. inactive, dirty/writeback page -> inactive, head, PG_reclaim
> 
>          inactive, clean -> inactive, tail

Indeed. I missed it.

> 
> > + * 5. Others -> none
> > + *
> > + * In 4, why it moves inactive's head, the VM expects the page would
> > + * be write it out by flusher threads as this is much more effective
> > + * than the single-page writeout from reclaim.
> >   */
> >  static void lru_deactivate(struct page *page, struct zone *zone)
> >  {
> >  	int lru, file;
> > +	bool active;
> >  
> > -	if (!PageLRU(page) || !PageActive(page))
> > +	if (!PageLRU(page))
> >  		return;
> >  
> >  	/* Some processes are using the page */
> >  	if (page_mapped(page))
> >  		return;
> >  
> > +	active = PageActive(page);
> > +
> >  	file = page_is_file_cache(page);
> >  	lru = page_lru_base_type(page);
> > -	del_page_from_lru_list(zone, page, lru + LRU_ACTIVE);
> > +	del_page_from_lru_list(zone, page, lru + active);
> >  	ClearPageActive(page);
> >  	ClearPageReferenced(page);
> >  	add_page_to_lru_list(zone, page, lru);
> > -	__count_vm_event(PGDEACTIVATE);
> >
> > +	if (PageWriteback(page) || PageDirty(page)) {
> > +		/*
> > +		 * PG_reclaim could be raced with end_page_writeback
> > +		 * It can make readahead confusing.  But race window
> > +		 * is _really_ small and  it's non-critical problem.
> > +		 */
> > +		SetPageReclaim(page);
> > +	} else {
> > +		/*
> > +		 * The page's writeback ends up during pagevec
> > +		 * We moves tha page into tail of inactive.
> > +		 */
> > +		list_move_tail(&page->lru, &zone->lru[lru].list);
> > +		mem_cgroup_rotate_reclaimable_page(page);
> 
> I think you also need to increase PGROTATED here.

Absolutely.

Thanks, Hannes. :)
> 
> Other than that,
> Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
