Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 726306B004D
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 20:06:22 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5B06T1q028506
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 11 Jun 2009 09:06:29 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 35FA545DE51
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 09:06:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BE6945DD79
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 09:06:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E6DC41DB803A
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 09:06:28 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 601111DB8038
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 09:06:25 +0900 (JST)
Date: Thu, 11 Jun 2009 09:04:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] lumpy reclaim: clean up and write lumpy reclaim
Message-Id: <20090611090453.e7a035af.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090610133543.GM25943@csn.ul.ie>
References: <20090610142443.9370aff8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090610095140.GB25943@csn.ul.ie>
	<ce0400fcfccf8be455dced006ba15592.squirrel@webmail-b.css.fujitsu.com>
	<20090610133543.GM25943@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, apw@canonical.com, riel@redhat.com, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

At first, I'll do minimum change in this turn.

On Wed, 10 Jun 2009 14:35:43 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Wed, Jun 10, 2009 at 08:36:36PM +0900, KAMEZAWA Hiroyuki wrote:
> > Thank you for review, at first.
> > 
> > Mel Gorman wrote:
> > >> ==
> > >> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > >>
> > >> In lumpty reclaim, "cursor_page" is found just by pfn. Then, we don't
> > >> know
> > >> where "cursor" page came from. Then, putback it to "src" list is BUG.
> > >> And as pointed out, current lumpy reclaim doens't seem to
> > >> work as originally designed and a bit complicated.
> > >
> > > What thread was this discussed in?
> > >
> >
> > http://marc.info/?t=124453903700003&r=1&w=2
> > The original problem I found was a simple one...I wonder whether I should
> > go ahead or not ;) So, I may abort this work and just post simple patches.
> > 
> 
> Comments on that
> 
>   o The -EBUSY case does end up rotating the page on the LRU which is
> 	unnecessary. This logic was copied from the normal case where we are
> 	reclaiming a page from the end of the LRU. Lumpy reclaim rotating
> 	non-cursor pages is probably overkill
> 
Sure.

>   o It's reasonable to abort lumpy reclaim if a page within the
> 	order-aligned block being lumpy reclaimed is encountered and
> 	backout.
> 
> Both of these should be separate patches in a series.
> 
Hmm. but this lumpy reclaim's loop breaks even if it founds a "free" page
(or a page on pcp). So I added "do_aggressive".
I leave this part as homework and revisit this after merge-window.

What I feel now is following
  - isolate_inactive_list() checks at most SWAP_CLUSETER_MAX pages in each turn.
  - If lumpy reclaim catches some number of pages incompleltely but it doesn't do
    push-back, lumpy reclaim will exit loop very easily without any progress in
    "requested order".
  - Then, exit-loop here or not is a difficult problem in current logic.


> > >> +	 * create free continous pages. This algorithm tries to start
> > >> +	 * from order 0 and scan buddy pages up to request_order.
> > >> +	 * If you are unsure about buddy position calclation, please see
> > >> +	 * mm/page_alloc.c
> > >> +	 */
> > >
> > > Why would we start at order 0 and scan buddy pages up to the request
> > > order? The intention was that the order-aligned block of pages the
> > > cursor page resides in be examined.
> > >
> > > Lumpy reclaim is most important for direct reclaimers and it specifies
> > > what its desired order is. Contiguous pages lower than that order are
> > > simply not interesting for direct reclaim.
> > >
> >
> > The order is not important. This code's point is "which pages are selected?"
> > Assume "A" as the target page on the top of LRU. and we'll remove
> > pages _around_ "A".
> > 
> >     [A-X,A-X+1,.....A, A+1, A+2, .....,A+Y]
> > 
> > In original logic, the pages are got from A-X, A-X+1, A-X+2...order
> 
> Yes, because the pages for lumpy reclaim have to be contiguous *and*
> order-aligned for the buddy allocator to coalesce them.
> 
> > In my logic, the pages are got from A+1,A+2,A+3(or some reverse)...order
> > 
> 
> I'm don't believe I am seeing the advantage. If it runs to completion and
> the pages are successfully reclaimed, the contiguous pages are free
> regardless of what order you reclaimed them in.
> 
> > Because we don't have "pushback all at failure" logic, I selected this
> > order to select nearby pages as much as possible to make large order chunks
> > around the page on the top of LRU.
> > I tried to add "pusback all" but it adds unnecessary/unexpected
> > LRU rotation. So, I don't do that but reclaim a lump around "A".
> > 
> 
> I see. I believe you are making assumptions on the distance between pages
> in the order-aligned block and their position in the LRU. While there is
> likely a correlation for processes that started early in the lifetime of
> the system, I'm not sure how accurate that is in general.
> 
> Certainly this patch needs to be all out on it's own. 
I agree here.

> FWIW, once it is,
> I can shove the resulting patch through the anti-fragmentation testcases.
> I still have knocking around somewhere although I'm less sure that I have
> access to suitable machines currently to test on. Regardless, I would like
> to deal with this sort of modification separate from the other clearer issues
> you have identified.
> 
> > To do push back all, I wonder atomic ops for taking range of pages without
> > removing from LRU is necessary. But I think we can't.
> > 
> 
> Probably not. The fact of the matter is that lumpy reclaim can mess up the LRU
> ordering in an undesirable manner when it fails to reclaim the pages it wants.
> 
I'll revisit this problem in my long term work.


> > >> +	zone_id = page_zone_id(page);
> > >> +	page_pfn = page_to_pfn(page);
> > >> +	buddy_base = page_pfn & ~((1 << MAX_ORDER) - 1);
> > >> +
> > >> +	/* Can we expect succesful reclaim ? */
> > >> +	type = get_pageblock_migratetype(page);
> > >> +	if ((type == MIGRATE_MOVABLE) || (type == MIGRATE_RECLAIMABLE))
> > >> +		do_aggressive = 1;
> > >> +
> > >
> > > There is a case for doing lumpy reclaim even within the other blocks.
> > >
> > > 1. The block might have recently changed type because of
> > > anti-fragmentation
> > > 	fallback. It's perfectly possible for MIGRATE_UNMOVABLE to have a
> > > 	large number of reclaimable pages within it.
> > >
> > yes, I know.
> > 
> > > 2. If a MIGRATE_UNMOVABLE block has LRU pages in it, it's again likely
> > > 	due to anti-fragmentation fallback. In the event movable pages are
> > > 	encountered here, it's benefical to reclaim them when encountered so
> > > 	that unmovable pages are allocated within MIGRATE_UNMOVABLE blocks
> > > 	as much as possible
> > >
> > > Hence, this check is likely not as beneficial as you believe.
> > >
> > Hmm, then I should reclaim the range of pages brutally even if
> > the range includes page for the kernel ?
> > 
> 
> Yes.  You don't know in advance how many pages there are belonging to the
> kernel. However, if there are any, it's best to reclaim the pages that
> are near it and within the same pageblock so that future unmovable kernel
> allocations can be allocated from the same block. This is more important
> from an anti-fragmentation perspective than lumpy-reclaim.
> 
Hmm, ok.

> If there happens to be a significant number of movable pages near that
> one kernel page, there is an outside chance that the kernel page will free
> naturally, particularly if it turned out it was holding metadata related to
> the reclaimable data being freed.
> 
I doubts this ;)

> > We have no way to check "the pages are for users" if the page is
> > not on LRU. (tend to happen when shrink_list() works.)
> > 
> > Or do you think following check works well at the page seems busy ?
> > 
> >       page_count(page) == 0 -> continue.
> >       __isolate_lru_page() -> busy
> >         PageUnevictable(page) -> abort
> >         PageSwapBacked(page)  -> continue. #1
> >         PageWriteback(page)   -> continue. #2
> >         PageSwapBacked(page)  -> continue. #3
> >         PageIsFileBacked(page)-> cont. #4 use some magical logic...
> > 
> > I wonder PG_reclaim or some should be set if shrink_list() extract it
> > from LRU Then, #1, #2, #3, #4 can be cheked at once.
> > 
> 
> The logic seems fine but leave the existing agressive decision as it is
> for the moment please and handle the other more straight-forward issues.
Okay.

> I'll try and get the anti-fragementation test cases in place in the meantime
> and see can we do a comparison. It's been a several months since I tested
> anti-fragmentation so it's time for a recheck anyway.
> 
Thanks.

> > >> +		/* scan range [buddy_start_pfn...buddy_end_pfn) */
> > >> +		for (pfn = buddy_start_pfn; pfn < buddy_end_pfn; ++pfn) {
> > >> +			/* Avoid holes within the zone. */
> > >> +			if (unlikely(!pfn_valid_within(pfn)))
> > >> +				break;
> > >> +			page = pfn_to_page(pfn);
> > >> +			/*
> > >> +			 * Check that we have not crossed a zone boundary.
> > >> +			 * Some arch have zones not aligned to MAX_ORDER.
> > >> +			 */
> > >> +			if (unlikely(page_zone_id(page) != zone_id))
> > >> +				break;
> > >> +
> > >> +			/* we are always under ISOLATE_BOTH */
> > >
> > > Once upon a time, we weren't. I'm not sure this assumption is accurate.
> > >
> > To do sucessful lumpy reclaim, ISOLATE_BOTH is required, anyway.
> > 
> 
> Again, not necessarily. The decision to only consider active pages was to
> avoid serious disruption to the LRU ordering where possible. As lumpy reclaim
> rotated active pages en-masse to the inactive list, there was a chance that
> contiguous pages would all be of a similar activity when considered.
> 
ok.

> > 
> > >> +			if (__isolate_lru_page(page, ISOLATE_BOTH, 0) == 0) {
> > >> +				list_move(&page->lru, dst);
> > >> +				nr++;
> > >> +			} else if (do_aggressive && !PageUnevictable(page))
> > >> +					continue;
> > >
> > > Surely if the page was unevitable, we should have aborted the lumpy
> > > reclaim
> > > and continued. Minimally, I would like to see the PageUnevictable check to
> > > be placed in the existing lumpy reclaim code as patch 1.
> > >
> > ok, I'll schedule PageUnevictable() patch as indepnedent one.
> > 
> 
> Thanks, so that will be patch 3 then.
> 
will do.


> > I know that logic. I don't think lumpy reclaim is required for order-1
> > pages if priority is low.
> > 
> 
> I can't remember if we generated exact figures for it or not but assuming
> pages on an LRU were randomly located throughout memory, Andy did show
> statistically that lumpy reclaim of order-1 pages would reduce the number of
> pages that needed to be reclaimed overall. The effect at order-1 is small
> and in practive pages are not randomly located, but it was enough of a
> reason to lead to the logic we currently have.
> 
I looked into this logic at considering "how to implement softlimit-for-memcg"
and I wanted to avoid unnecessary memory freeing from random reegion AMAP.
But I know softlimit-for-memcg will be a long term work and am not in hurry.
I'll revisit here in future anyway.

> > 
> > > I'm sorry, I'm not keen on this patch. I would prefer to see the check
> > > for PageUnevitable done as a standalone patch against the existing lumpy
> > > reclaim code.
> > >
> > ok. I'll just do bug fix.
> > 
> 
> Thanks very much.
> 
Thank you very much, too.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
