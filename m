Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 568DD6B0098
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 02:32:04 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5A6X2Y6006626
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 10 Jun 2009 15:33:02 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DB50D45DE55
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 15:33:01 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 807E445DE5C
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 15:33:01 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EDA881DB8051
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 15:33:00 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F290F1DB8047
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 15:32:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] lumpy reclaim: clean up and write lumpy reclaim
In-Reply-To: <20090610153010.8d219dfc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090610151027.DDBA.A69D9226@jp.fujitsu.com> <20090610153010.8d219dfc.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20090610153238.DDC0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 10 Jun 2009 15:32:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, apw@canonical.com, riel@redhat.com, minchan.kim@gmail.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

> On Wed, 10 Jun 2009 15:11:21 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > I think lumpy reclaim should be updated to meet to current split-lru.
> > > This patch includes bugfix and cleanup. How do you think ?
> > > 
> > > ==
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > 
> > > In lumpty reclaim, "cursor_page" is found just by pfn. Then, we don't know
> > > where "cursor" page came from. Then, putback it to "src" list is BUG.
> > > And as pointed out, current lumpy reclaim doens't seem to
> > > work as originally designed and a bit complicated. This patch adds a
> > > function try_lumpy_reclaim() and rewrite the logic.
> > > 
> > > The major changes from current lumpy reclaim is
> > >   - check migratetype before aggressive retry at failure.
> > >   - check PG_unevictable at failure.
> > >   - scan is done in buddy system order. This is a help for creating
> > >     a lump around targeted page. We'll create a continuous pages for buddy
> > >     allocator as far as we can _around_ reclaim target page.
> > > 
> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > ---
> > >  mm/vmscan.c |  120 +++++++++++++++++++++++++++++++++++-------------------------
> > >  1 file changed, 71 insertions(+), 49 deletions(-)
> > > 
> > > Index: mmotm-2.6.30-Jun10/mm/vmscan.c
> > > ===================================================================
> > > --- mmotm-2.6.30-Jun10.orig/mm/vmscan.c
> > > +++ mmotm-2.6.30-Jun10/mm/vmscan.c
> > > @@ -850,6 +850,69 @@ int __isolate_lru_page(struct page *page
> > >  	return ret;
> > >  }
> > >  
> > > +static int
> > > +try_lumpy_reclaim(struct page *page, struct list_head *dst, int request_order)
> > > +{
> > > +	unsigned long buddy_base, buddy_idx, buddy_start_pfn, buddy_end_pfn;
> > > +	unsigned long pfn, page_pfn, page_idx;
> > > +	int zone_id, order, type;
> > > +	int do_aggressive = 0;
> > > +	int nr = 0;
> > > +	/*
> > > +	 * Lumpy reqraim. Try to take near pages in requested order to
> > > +	 * create free continous pages. This algorithm tries to start
> > > +	 * from order 0 and scan buddy pages up to request_order.
> > > +	 * If you are unsure about buddy position calclation, please see
> > > +	 * mm/page_alloc.c
> > > +	 */
> > > +	zone_id = page_zone_id(page);
> > > +	page_pfn = page_to_pfn(page);
> > > +	buddy_base = page_pfn & ~((1 << MAX_ORDER) - 1);
> > > +
> > > +	/* Can we expect succesful reclaim ? */
> > > +	type = get_pageblock_migratetype(page);
> > > +	if ((type == MIGRATE_MOVABLE) || (type == MIGRATE_RECLAIMABLE))
> > > +		do_aggressive = 1;
> > > +
> > > +	for (order = 0; order < request_order; ++order) {
> > > +		/* offset in this buddy region */
> > > +		page_idx = page_pfn & ~buddy_base;
> > > +		/* offset of buddy can be calculated by xor */
> > > +		buddy_idx = page_idx ^ (1 << order);
> > > +		buddy_start_pfn = buddy_base + buddy_idx;
> > > +		buddy_end_pfn = buddy_start_pfn + (1 << order);
> > > +
> > > +		/* scan range [buddy_start_pfn...buddy_end_pfn) */
> > > +		for (pfn = buddy_start_pfn; pfn < buddy_end_pfn; ++pfn) {
> > > +			/* Avoid holes within the zone. */
> > > +			if (unlikely(!pfn_valid_within(pfn)))
> > > +				break;
> > > +			page = pfn_to_page(pfn);
> > > +			/*
> > > +			 * Check that we have not crossed a zone boundary.
> > > +			 * Some arch have zones not aligned to MAX_ORDER.
> > > +			 */
> > > +			if (unlikely(page_zone_id(page) != zone_id))
> > > +				break;
> > > +
> > > +			/* we are always under ISOLATE_BOTH */
> > > +			if (__isolate_lru_page(page, ISOLATE_BOTH, 0) == 0) {
> > > +				list_move(&page->lru, dst);
> > > +				nr++;
> > > +			} else if (do_aggressive && !PageUnevictable(page))
> > 
> > Could you explain this branch intention more?
> > 
> __isolate_lru_page() can fail in following case
>   - the page is not on LRU.
>         This implies
> 		(a) the page is not for anon/file-cache
> 		(b) the page is taken off from LRU by shirnk_list or pagevec.
> 		(c) the page is free.
>    - the page is temorarlly busy.
> 
> So, aborting this loop here directly is not very good. But if the page is for
> kernel' usage or unevictable,  contuning this loop just wastes time.
> 
> Then, I used migrate_type attribute for the target page.
> migrate_type is determined per pageblock_order (This itself detemined by
> sizeo of hugepage at el. see  include/linux/pageblock-flags.h)
> 
> If the page is under MIGRATE_MOVABLE
> 	- at least 50% of nearby pages are used for GFP_MOVABLE(GFP_HIGHUSER_MOVABLE)
>    the page is udner MIGRATE_REMOVABLE
> 	- at least 50% of nearby pages are used for  GFP_TEMPORARY
> 
> Then, we can expect meaningful lumpy reclaim if do_aggressive == 1.
> If do_aggressive==0, nearby pages are used for some kernel usage and not suitable
> for _this_ lumpy reclaim.
> 
> How about a comment like this ?
> /*
>  * __isolate_lru_page() returns busy status in many reason. If we are under
>  * migrate type of MIGRATE_MOVABLE/MIGRATE_REMOVABLE, we can expect nearby
>  * pages are just temporally busy and should be reclaimed later. (If the page
>  * is _now_ free or being freed, __isolate_lru_page() returns -EBUSY.)
>  * Then, continue this loop.
>  */

OK, looks good.
thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
