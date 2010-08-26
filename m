Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 259C56B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 03:59:14 -0400 (EDT)
Date: Thu, 26 Aug 2010 15:59:10 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: [RFC]mm: batch activate_page() to reduce lock contention
Message-ID: <20100826075910.GA2189@sli10-conroe.sh.intel.com>
References: <1279610324.17101.9.camel@sli10-desk.sh.intel.com>
 <20100723234938.88EB.A69D9226@jp.fujitsu.com>
 <20100726050827.GA24047@sli10-desk.sh.intel.com>
 <20100805140755.501af8a7.akpm@linux-foundation.org>
 <20100806030805.GA10038@sli10-desk.sh.intel.com>
 <20100825130318.93c03403.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100825130318.93c03403.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 26, 2010 at 04:03:18AM +0800, Andrew Morton wrote:
> On Fri, 6 Aug 2010 11:08:05 +0800
> Shaohua Li <shaohua.li@intel.com> wrote:
> 
> > Subject: mm: batch activate_page() to reduce lock contention
> > 
> > The zone->lru_lock is heavily contented in workload where activate_page()
> > is frequently used. We could do batch activate_page() to reduce the lock
> > contention. The batched pages will be added into zone list when the pool
> > is full or page reclaim is trying to drain them.
> > 
> > For example, in a 4 socket 64 CPU system, create a sparse file and 64 processes,
> > processes shared map to the file. Each process read access the whole file and
> > then exit. The process exit will do unmap_vmas() and cause a lot of
> > activate_page() call. In such workload, we saw about 58% total time reduction
> > with below patch.
> > 
> 
> Am still not happy that this bloats swap.o by 144 bytes in an
> allnoconfig build for something which is only relevant to SMP builds.
> 
> > index 3ce7bc3..744883f 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -172,28 +172,93 @@ static void update_page_reclaim_stat(struct zone *zone, struct page *page,
> >  		memcg_reclaim_stat->recent_rotated[file]++;
> >  }
> >  
> > -/*
> > - * FIXME: speed this up?
> > - */
> > -void activate_page(struct page *page)
> > +static void __activate_page(struct page *page, void *arg)
> >  {
> > -	struct zone *zone = page_zone(page);
> > -
> > -	spin_lock_irq(&zone->lru_lock);
> >  	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
> > +		struct zone *zone = page_zone(page);
> >  		int file = page_is_file_cache(page);
> >  		int lru = page_lru_base_type(page);
> > +
> >  		del_page_from_lru_list(zone, page, lru);
> >  
> >  		SetPageActive(page);
> >  		lru += LRU_ACTIVE;
> >  		add_page_to_lru_list(zone, page, lru);
> > -		__count_vm_event(PGACTIVATE);
> >  
> > +		__count_vm_event(PGACTIVATE);
> >  		update_page_reclaim_stat(zone, page, file, 1);
> >  	}
> > +}
> > +
> > +static void pagevec_lru_move_fn(struct pagevec *pvec,
> > +				void (*move_fn)(struct page *page, void *arg),
> > +				void *arg)
> > +{
> > +	struct zone *last_zone = NULL;
> > +	int i, j;
> > +	DECLARE_BITMAP(pages_done, PAGEVEC_SIZE);
> > +
> > +	bitmap_zero(pages_done, PAGEVEC_SIZE);
> > +	for (i = 0; i < pagevec_count(pvec); i++) {
> > +		if (test_bit(i, pages_done))
> > +			continue;
> > +
> > +		if (last_zone)
> > +			spin_unlock_irq(&last_zone->lru_lock);
> > +		last_zone = page_zone(pvec->pages[i]);
> > +		spin_lock_irq(&last_zone->lru_lock);
> > +
> > +		for (j = i; j < pagevec_count(pvec); j++) {
> > +			struct page *page = pvec->pages[j];
> > +
> > +			if (last_zone != page_zone(page))
> > +				continue;
> > +			(*move_fn)(page, arg);
> > +			__set_bit(j, pages_done);
> > +		}
> > +	}
> > +	if (last_zone)
> > +		spin_unlock_irq(&last_zone->lru_lock);
> > +	release_pages(pvec->pages, pagevec_count(pvec), pvec->cold);
> > +	pagevec_reinit(pvec);
> > +}
> 
> This function is pretty bizarre.  It really really needs some comments
> explaining what it's doing and most especially *why* it's doing it.
> 
> It's a potential O(n*nr_zones) search (I think)!  We demand proof that
> it's worthwhile!
> 
> Yes, if the pagevec is filled with pages from different zones then it
> will reduce the locking frequency.  But in the common case where the
> pagevec has pages all from the same zone, or has contiguous runs of
> pages from different zones then all that extra bitmap fiddling gained
> us nothing.
> 
> (I think the search could be made more efficient by advancing `i' when
> we first see last_zone!=page_zone(page), but that'd just make the code
> even worse).
Thanks for pointing this out. Then we can simplify things a little bit.
the 144 bytes footprint is because of this too, then we can remove it.

> 
> There's a downside/risk to this code.  A billion years ago I found
> that it was pretty important that if we're going to batch pages in this
> manner, it's important that ALL pages be batched via the same means. 
> If 99% of the pages go through the pagevec and 1% of pages bypass the
> pagevec, the LRU order gets scrambled and we can end up causing
> additional disk seeks when the time comes to write things out.  The
> effect was measurable.
> 
> And lo, putback_lru_pages() (at least) bypasses your new pagevecs,
> potentially scrambling the LRU ordering.  Admittedly, if we're putting
> back unreclaimable pages in there, the LRU is probably already pretty
> scrambled.  But that's just a guess.
ok, we can drain the pagevecs in putback_lru_pages() or add active page
to the new pagevecs.

> Even if that is addressed, we still scramble the LRU to some extent
> simply because the pagevecs are per-cpu.  We already do that to some
> extent when shrink_inactive_list() snips a batch of pages off the LRU
> for processing.  To what extent this matters and to what extent your
> new activate_page() worsens this is also unknown.
ok, this is possible. Any suggestion which benchmark I can test to verify
if this is a real problem?

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
