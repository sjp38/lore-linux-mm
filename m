Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 25D236B004F
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 09:34:44 -0400 (EDT)
Date: Wed, 10 Jun 2009 14:35:43 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] lumpy reclaim: clean up and write lumpy reclaim
Message-ID: <20090610133543.GM25943@csn.ul.ie>
References: <20090610142443.9370aff8.kamezawa.hiroyu@jp.fujitsu.com> <20090610095140.GB25943@csn.ul.ie> <ce0400fcfccf8be455dced006ba15592.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <ce0400fcfccf8be455dced006ba15592.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, apw@canonical.com, riel@redhat.com, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Wed, Jun 10, 2009 at 08:36:36PM +0900, KAMEZAWA Hiroyuki wrote:
> Thank you for review, at first.
> 
> Mel Gorman wrote:
> > On Wed, Jun 10, 2009 at 02:24:43PM +0900, KAMEZAWA Hiroyuki wrote:
> >> I think lumpy reclaim should be updated to meet to current split-lru.
> >> This patch includes bugfix and cleanup. How do you think ?
> >>
> >
> > I think it needs to be split up into its component parts. This patch is
> > changing too much and it's very difficult to consider each change in
> > isolation.
> >
>
> yes, will do.
> 

Thanks.

> >> ==
> >> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >>
> >> In lumpty reclaim, "cursor_page" is found just by pfn. Then, we don't
> >> know
> >> where "cursor" page came from. Then, putback it to "src" list is BUG.
> >> And as pointed out, current lumpy reclaim doens't seem to
> >> work as originally designed and a bit complicated.
> >
> > What thread was this discussed in?
> >
>
> http://marc.info/?t=124453903700003&r=1&w=2
> The original problem I found was a simple one...I wonder whether I should
> go ahead or not ;) So, I may abort this work and just post simple patches.
> 

Comments on that

  o The -EBUSY case does end up rotating the page on the LRU which is
	unnecessary. This logic was copied from the normal case where we are
	reclaiming a page from the end of the LRU. Lumpy reclaim rotating
	non-cursor pages is probably overkill

  o It's reasonable to abort lumpy reclaim if a page within the
	order-aligned block being lumpy reclaimed is encountered and
	backout.

Both of these should be separate patches in a series.

> >> This patch adds a
> >> function try_lumpy_reclaim() and rewrite the logic.
> >>
> >> The major changes from current lumpy reclaim is
> >>   - check migratetype before aggressive retry at failure.
> >>   - check PG_unevictable at failure.
> >>   - scan is done in buddy system order. This is a help for creating
> >>     a lump around targeted page. We'll create a continuous pages for
> >> buddy
> >>     allocator as far as we can _around_ reclaim target page.
> >>
> >> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >> ---
> >>  mm/vmscan.c |  120
> >> +++++++++++++++++++++++++++++++++++-------------------------
> >>  1 file changed, 71 insertions(+), 49 deletions(-)
> >>
> >> Index: mmotm-2.6.30-Jun10/mm/vmscan.c
> >> ===================================================================
> >> --- mmotm-2.6.30-Jun10.orig/mm/vmscan.c
> >> +++ mmotm-2.6.30-Jun10/mm/vmscan.c
> >> @@ -850,6 +850,69 @@ int __isolate_lru_page(struct page *page
> >>  	return ret;
> >>  }
> >>
> >> +static int
> >> +try_lumpy_reclaim(struct page *page, struct list_head *dst, int
> >> request_order)
> >> +{
> >> +	unsigned long buddy_base, buddy_idx, buddy_start_pfn, buddy_end_pfn;
> >> +	unsigned long pfn, page_pfn, page_idx;
> >> +	int zone_id, order, type;
> >> +	int do_aggressive = 0;
> >> +	int nr = 0;
> >> +	/*
> >> +	 * Lumpy reqraim. Try to take near pages in requested order to
> >
> > s/reqraim/reclaim/
> >
> oh, will fix.
> 
> >> +	 * create free continous pages. This algorithm tries to start
> >> +	 * from order 0 and scan buddy pages up to request_order.
> >> +	 * If you are unsure about buddy position calclation, please see
> >> +	 * mm/page_alloc.c
> >> +	 */
> >
> > Why would we start at order 0 and scan buddy pages up to the request
> > order? The intention was that the order-aligned block of pages the
> > cursor page resides in be examined.
> >
> > Lumpy reclaim is most important for direct reclaimers and it specifies
> > what its desired order is. Contiguous pages lower than that order are
> > simply not interesting for direct reclaim.
> >
>
> The order is not important. This code's point is "which pages are selected?"
> Assume "A" as the target page on the top of LRU. and we'll remove
> pages _around_ "A".
> 
>     [A-X,A-X+1,.....A, A+1, A+2, .....,A+Y]
> 
> In original logic, the pages are got from A-X, A-X+1, A-X+2...order

Yes, because the pages for lumpy reclaim have to be contiguous *and*
order-aligned for the buddy allocator to coalesce them.

> In my logic, the pages are got from A+1,A+2,A+3(or some reverse)...order
> 

I'm don't believe I am seeing the advantage. If it runs to completion and
the pages are successfully reclaimed, the contiguous pages are free
regardless of what order you reclaimed them in.

> Because we don't have "pushback all at failure" logic, I selected this
> order to select nearby pages as much as possible to make large order chunks
> around the page on the top of LRU.
> I tried to add "pusback all" but it adds unnecessary/unexpected
> LRU rotation. So, I don't do that but reclaim a lump around "A".
> 

I see. I believe you are making assumptions on the distance between pages
in the order-aligned block and their position in the LRU. While there is
likely a correlation for processes that started early in the lifetime of
the system, I'm not sure how accurate that is in general.

Certainly this patch needs to be all out on it's own.  FWIW, once it is,
I can shove the resulting patch through the anti-fragmentation testcases.
I still have knocking around somewhere although I'm less sure that I have
access to suitable machines currently to test on. Regardless, I would like
to deal with this sort of modification separate from the other clearer issues
you have identified.

> To do push back all, I wonder atomic ops for taking range of pages without
> removing from LRU is necessary. But I think we can't.
> 

Probably not. The fact of the matter is that lumpy reclaim can mess up the LRU
ordering in an undesirable manner when it fails to reclaim the pages it wants.

> >> +	zone_id = page_zone_id(page);
> >> +	page_pfn = page_to_pfn(page);
> >> +	buddy_base = page_pfn & ~((1 << MAX_ORDER) - 1);
> >> +
> >> +	/* Can we expect succesful reclaim ? */
> >> +	type = get_pageblock_migratetype(page);
> >> +	if ((type == MIGRATE_MOVABLE) || (type == MIGRATE_RECLAIMABLE))
> >> +		do_aggressive = 1;
> >> +
> >
> > There is a case for doing lumpy reclaim even within the other blocks.
> >
> > 1. The block might have recently changed type because of
> > anti-fragmentation
> > 	fallback. It's perfectly possible for MIGRATE_UNMOVABLE to have a
> > 	large number of reclaimable pages within it.
> >
> yes, I know.
> 
> > 2. If a MIGRATE_UNMOVABLE block has LRU pages in it, it's again likely
> > 	due to anti-fragmentation fallback. In the event movable pages are
> > 	encountered here, it's benefical to reclaim them when encountered so
> > 	that unmovable pages are allocated within MIGRATE_UNMOVABLE blocks
> > 	as much as possible
> >
> > Hence, this check is likely not as beneficial as you believe.
> >
> Hmm, then I should reclaim the range of pages brutally even if
> the range includes page for the kernel ?
> 

Yes.  You don't know in advance how many pages there are belonging to the
kernel. However, if there are any, it's best to reclaim the pages that
are near it and within the same pageblock so that future unmovable kernel
allocations can be allocated from the same block. This is more important
from an anti-fragmentation perspective than lumpy-reclaim.

If there happens to be a significant number of movable pages near that
one kernel page, there is an outside chance that the kernel page will free
naturally, particularly if it turned out it was holding metadata related to
the reclaimable data being freed.

> We have no way to check "the pages are for users" if the page is
> not on LRU. (tend to happen when shrink_list() works.)
> 
> Or do you think following check works well at the page seems busy ?
> 
>       page_count(page) == 0 -> continue.
>       __isolate_lru_page() -> busy
>         PageUnevictable(page) -> abort
>         PageSwapBacked(page)  -> continue. #1
>         PageWriteback(page)   -> continue. #2
>         PageSwapBacked(page)  -> continue. #3
>         PageIsFileBacked(page)-> cont. #4 use some magical logic...
> 
> I wonder PG_reclaim or some should be set if shrink_list() extract it
> from LRU Then, #1, #2, #3, #4 can be cheked at once.
> 

The logic seems fine but leave the existing agressive decision as it is
for the moment please and handle the other more straight-forward issues.
I'll try and get the anti-fragementation test cases in place in the meantime
and see can we do a comparison. It's been a several months since I tested
anti-fragmentation so it's time for a recheck anyway.

> >> +	for (order = 0; order < request_order; ++order) {
> >> +		/* offset in this buddy region */
> >> +		page_idx = page_pfn & ~buddy_base;
> >> +		/* offset of buddy can be calculated by xor */
> >> +		buddy_idx = page_idx ^ (1 << order);
> >> +		buddy_start_pfn = buddy_base + buddy_idx;
> >> +		buddy_end_pfn = buddy_start_pfn + (1 << order);
> >> +
> >
> > This appears to be duplicating code from page_alloc. If you need to
> > share the code, move the helper to mm/internal. Otherwise the code is a
> > bit brain bending.
> >
> ok.
> 
> > Again, I'm not seeing the advantage of stepping through the buddies like
> > this.
> >
> Sure.
> 
> >> +		/* scan range [buddy_start_pfn...buddy_end_pfn) */
> >> +		for (pfn = buddy_start_pfn; pfn < buddy_end_pfn; ++pfn) {
> >> +			/* Avoid holes within the zone. */
> >> +			if (unlikely(!pfn_valid_within(pfn)))
> >> +				break;
> >> +			page = pfn_to_page(pfn);
> >> +			/*
> >> +			 * Check that we have not crossed a zone boundary.
> >> +			 * Some arch have zones not aligned to MAX_ORDER.
> >> +			 */
> >> +			if (unlikely(page_zone_id(page) != zone_id))
> >> +				break;
> >> +
> >> +			/* we are always under ISOLATE_BOTH */
> >
> > Once upon a time, we weren't. I'm not sure this assumption is accurate.
> >
> To do sucessful lumpy reclaim, ISOLATE_BOTH is required, anyway.
> 

Again, not necessarily. The decision to only consider active pages was to
avoid serious disruption to the LRU ordering where possible. As lumpy reclaim
rotated active pages en-masse to the inactive list, there was a chance that
contiguous pages would all be of a similar activity when considered.

> 
> >> +			if (__isolate_lru_page(page, ISOLATE_BOTH, 0) == 0) {
> >> +				list_move(&page->lru, dst);
> >> +				nr++;
> >> +			} else if (do_aggressive && !PageUnevictable(page))
> >> +					continue;
> >
> > Surely if the page was unevitable, we should have aborted the lumpy
> > reclaim
> > and continued. Minimally, I would like to see the PageUnevictable check to
> > be placed in the existing lumpy reclaim code as patch 1.
> >
> ok, I'll schedule PageUnevictable() patch as indepnedent one.
> 

Thanks, so that will be patch 3 then.

> >> +			else
> >> +				break;
> >> +		}
> >> +		/* we can't refill this order */
> >> +		if (pfn != buddy_end_pfn)
> >> +			break;
> >> +		if (buddy_start_pfn < page_pfn)
> >> +			page_pfn = buddy_start_pfn;
> >> +	}
> >> +	return nr;
> >> +}
> >> +
> >>  /*
> >>   * zone->lru_lock is heavily contended.  Some of the functions that
> >>   * shrink the lists perform better by taking out a batch of pages
> >> @@ -875,14 +938,10 @@ static unsigned long isolate_lru_pages(u
> >>  		unsigned long *scanned, int order, int mode, int file)
> >>  {
> >>  	unsigned long nr_taken = 0;
> >> -	unsigned long scan;
> >> +	unsigned long scan, nr;
> >>
> >>  	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
> >>  		struct page *page;
> >> -		unsigned long pfn;
> >> -		unsigned long end_pfn;
> >> -		unsigned long page_pfn;
> >> -		int zone_id;
> >>
> >>  		page = lru_to_page(src);
> >>  		prefetchw_prev_lru_page(page, src, flags);
> >> @@ -903,52 +962,15 @@ static unsigned long isolate_lru_pages(u
> >>  		default:
> >>  			BUG();
> >>  		}
> >> -
> >> -		if (!order)
> >> -			continue;
> >> -
> >>  		/*
> >> -		 * Attempt to take all pages in the order aligned region
> >> -		 * surrounding the tag page.  Only take those pages of
> >> -		 * the same active state as that tag page.  We may safely
> >> -		 * round the target page pfn down to the requested order
> >> -		 * as the mem_map is guarenteed valid out to MAX_ORDER,
> >> -		 * where that page is in a different zone we will detect
> >> -		 * it from its zone id and abort this block scan.
> >> +		 * Lumpy reclaim tries to free nearby pages regardless of
> >> +		 * their lru attributes(file, active, etc..)
> >>  		 */
> >> -		zone_id = page_zone_id(page);
> >> -		page_pfn = page_to_pfn(page);
> >> -		pfn = page_pfn & ~((1 << order) - 1);
> >> -		end_pfn = pfn + (1 << order);
> >> -		for (; pfn < end_pfn; pfn++) {
> >> -			struct page *cursor_page;
> >> -
> >> -			/* The target page is in the block, ignore it. */
> >> -			if (unlikely(pfn == page_pfn))
> >> -				continue;
> >> -
> >> -			/* Avoid holes within the zone. */
> >> -			if (unlikely(!pfn_valid_within(pfn)))
> >> -				break;
> >> -
> >> -			cursor_page = pfn_to_page(pfn);
> >> -
> >> -			/* Check that we have not crossed a zone boundary. */
> >> -			if (unlikely(page_zone_id(cursor_page) != zone_id))
> >> -				continue;
> >> -			switch (__isolate_lru_page(cursor_page, mode, file)) {
> >> -			case 0:
> >> -				list_move(&cursor_page->lru, dst);
> >> -				nr_taken++;
> >> -				scan++;
> >> -				break;
> >> -
> >> -			case -EBUSY:
> >> -				/* else it is being freed elsewhere */
> >> -				list_move(&cursor_page->lru, src);
> >> -			default:
> >> -				break;	/* ! on LRU or wrong list */
> >> -			}
> >> +		if (order && mode == ISOLATE_BOTH) {
> >> +			/* try to reclaim pages nearby this */
> >> +			nr = try_lumpy_reclaim(page, dst, order);
> >> +			nr_taken += nr;
> >> +			scan += nr;
> >>  		}
> >
> > Initially, lumpy reclaim was able to kick in for just the active or
> > inactive
> > lists.  That is still the case although it only appears to happen now for
> > order < PAGE_ALLOC_COSTLY_ORDER and higher orders than that always
> > examine both active and inactive lists.
> >
> > The check here was for !order but now it's order && ISOLATE_BOTH. This
> > means
> > that lumpy reclaim will not kick in for order-1 pages for example until
> > the
> > priority of the scan is much higher. I do not think that was your
> > intention.
> >
> I know that logic. I don't think lumpy reclaim is required for order-1
> pages if priority is low.
> 

I can't remember if we generated exact figures for it or not but assuming
pages on an LRU were randomly located throughout memory, Andy did show
statistically that lumpy reclaim of order-1 pages would reduce the number of
pages that needed to be reclaimed overall. The effect at order-1 is small
and in practive pages are not randomly located, but it was enough of a
reason to lead to the logic we currently have.

> 
> > I'm sorry, I'm not keen on this patch. I would prefer to see the check
> > for PageUnevitable done as a standalone patch against the existing lumpy
> > reclaim code.
> >
> ok. I'll just do bug fix.
> 

Thanks very much.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
