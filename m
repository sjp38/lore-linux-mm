Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9D00B6B0005
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 11:54:55 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id u74so61220849lff.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 08:54:55 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e126si15393398wme.102.2016.06.13.08.54.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 08:54:54 -0700 (PDT)
Date: Mon, 13 Jun 2016 11:52:31 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 10/10] mm: balance LRU lists based on relative thrashing
Message-ID: <20160613155231.GB30642@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-11-hannes@cmpxchg.org>
 <20160610021935.GF29779@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160610021935.GF29779@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Fri, Jun 10, 2016 at 11:19:35AM +0900, Minchan Kim wrote:
> On Mon, Jun 06, 2016 at 03:48:36PM -0400, Johannes Weiner wrote:
> > @@ -79,6 +79,7 @@ enum pageflags {
> >  	PG_dirty,
> >  	PG_lru,
> >  	PG_active,
> > +	PG_workingset,
> 
> I think PG_workingset might be a good flag in the future, core MM might
> utilize it to optimize something so I hope it supports for 32bit, too.
> 
> A usecase with PG_workingset in old was cleancache. A few year ago,
> Dan tried it to only cache activated page from page cache to cleancache,
> IIRC. As well, many system using zram(i.e., fast swap) are still 32 bit
> architecture.
> 
> Just an idea. we might be able to move less important flag(i.e., enabled
> in specific configuration, for example, PG_hwpoison or PG_uncached) in 32bit
> to page_extra to avoid allocate extra memory space and charge the bit as
> PG_workingset. :)

Yeah, I do think it should be a core flag. We have the space for it.

> Other concern about PG_workingset is naming. For file-backed pages, it's
> good because file-backed pages started from inactive's head and promoted
> active LRU once two touch so it's likely to be workingset. However,
> for anonymous page, it starts from active list so every anonymous page
> has PG_workingset while mlocked pages cannot have a chance to have it.
> It wouldn't matter in eclaim POV but if we would use PG_workingset as
> indicator to identify real workingset page, it might be confused.
> Maybe, We could mark mlocked pages as workingset unconditionally.

Hm I'm not sure it matters. Technically we don't have to set it on
anon, but since it's otherwise unused anyway, it's nice to set it to
reinforce the notion that anon is currently always workingset.

> > @@ -544,6 +544,8 @@ void migrate_page_copy(struct page *newpage, struct page *page)
> >  		SetPageActive(newpage);
> >  	} else if (TestClearPageUnevictable(page))
> >  		SetPageUnevictable(newpage);
> > +	if (PageWorkingset(page))
> > +		SetPageWorkingset(newpage);
> 
> When I see this, popped thought is how we handle PG_workingset
> when split/collapsing THP and then, I can't find any logic. :(
> Every anonymous page is PG_workingset by birth so you ignore it
> intentionally?

Good catch. __split_huge_page_tail() should copy it over, will fix that.

> > @@ -1809,6 +1811,8 @@ fail_putback:
> >  		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> >  
> >  		/* Reverse changes made by migrate_page_copy() */
> > +		if (TestClearPageWorkingset(new_page))
> > +			ClearPageWorkingset(page);
> >  		if (TestClearPageActive(new_page))
> >  			SetPageActive(page);
> >  		if (TestClearPageUnevictable(new_page))
> > diff --git a/mm/swap.c b/mm/swap.c
> > index ae07b469ddca..cb6773e1424e 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -249,8 +249,28 @@ void rotate_reclaimable_page(struct page *page)
> >  	}
> >  }
> >  
> > -void lru_note_cost(struct lruvec *lruvec, bool file, unsigned int nr_pages)
> > +void lru_note_cost(struct lruvec *lruvec, enum lru_cost_type cost,
> > +		   bool file, unsigned int nr_pages)
> >  {
> > +	if (cost == COST_IO) {
> > +		/*
> > +		 * Reflect the relative reclaim cost between incurring
> > +		 * IO from refaults on one hand, and incurring CPU
> > +		 * cost from rotating scanned pages on the other.
> > +		 *
> > +		 * XXX: For now, the relative cost factor for IO is
> > +		 * set statically to outweigh the cost of rotating
> > +		 * referenced pages. This might change with ultra-fast
> > +		 * IO devices, or with secondary memory devices that
> > +		 * allow users continued access of swapped out pages.
> > +		 *
> > +		 * Until then, the value is chosen simply such that we
> > +		 * balance for IO cost first and optimize for CPU only
> > +		 * once the thrashing subsides.
> > +		 */
> > +		nr_pages *= SWAP_CLUSTER_MAX;
> > +	}
> > +
> >  	lruvec->balance.numer[file] += nr_pages;
> >  	lruvec->balance.denom += nr_pages;
> 
> So, lru_cost_type is binary. COST_IO and COST_CPU. 'bool' is enough to
> represent it if you doesn't have further plan to expand it.
> But if you did to make it readable, I'm not against. Just trivial.

Yeah, it's meant for readability. "true" and "false" make for fairly
cryptic arguments when they are a static property of the callsite:

  lru_note_cost(lruvec, false, page_is_file_cache(page), hpage_nr_pages(page))

???

So I'd rather name these things and leave bool for things that are
based on predicate functions.

> > @@ -821,13 +842,28 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
> >  static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
> >  				 void *arg)
> >  {
> > +	unsigned int nr_pages = hpage_nr_pages(page);
> >  	enum lru_list lru = page_lru(page);
> > +	bool active = is_active_lru(lru);
> > +	bool file = is_file_lru(lru);
> > +	bool new = (bool)arg;
> >  
> >  	VM_BUG_ON_PAGE(PageLRU(page), page);
> >  
> >  	SetPageLRU(page);
> >  	add_page_to_lru_list(page, lruvec, lru);
> >  
> > +	if (new) {
> > +		/*
> > +		 * If the workingset is thrashing, note the IO cost of
> > +		 * reclaiming that list and steer reclaim away from it.
> > +		 */
> > +		if (PageWorkingset(page))
> > +			lru_note_cost(lruvec, COST_IO, file, nr_pages);
> > +		else if (active)
> > +			SetPageWorkingset(page);
> > +	}
> > +
> >  	trace_mm_lru_insertion(page, lru);
> >  }
> >  
> > diff --git a/mm/swap_state.c b/mm/swap_state.c
> > index 5400f814ae12..43561a56ba5d 100644
> > --- a/mm/swap_state.c
> > +++ b/mm/swap_state.c
> > @@ -365,6 +365,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
> >  			/*
> >  			 * Initiate read into locked page and return.
> >  			 */
> 
> How about putting the comment you said to Tim in here?
> 
> "
> There are no shadow entries for anonymous evictions, only page cache
> evictions. All swap-ins are treated as "eligible" refaults and push back
> against cache, whereas cache only pushes against anon if the cache
> workingset is determined to fit into memory.
> That implies a fixed hierarchy where the VM always tries to fit the
> anonymous workingset into memory first and the page cache second.
> If the anonymous set is bigger than memory, the algorithm won't stop
> counting IO cost from anonymous refaults and pressuring page cache.
> "
> Or put it in workingset.c. I see you wrote up a little bit about
> anonymous refault in there but I think adding abvove paragraph is
> very helpful.

Agreed, that would probably be helpful. I'll put that in.

Thanks Minchan!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
