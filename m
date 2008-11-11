Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mABDdjkf026292
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 11 Nov 2008 22:39:45 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BB1B2AEA81
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 22:39:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 260331EF081
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 22:39:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D6411DB8038
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 22:39:45 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A4F281DB8037
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 22:39:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] mm: the page of MIGRATE_RESERVE don't insert into pcp
In-Reply-To: <20081107104726.GD13786@csn.ul.ie>
References: <20081107093127.F84A.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081107104726.GD13786@csn.ul.ie>
Message-Id: <20081111221059.8B44.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 11 Nov 2008 22:39:40 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > > What your patch may help is the situation where the system is under intense
> > > memory pressure, is dipping routinely into the lowmem reserves and mixing
> > > with high-order atomic allocations. This seems a bit extreme.
> > 
> > not so extreame.
> > 
> > The linux page reclaim can't process in interrupt context.
> > Sl network subsystem and driver often use MIGRATE_RESERVE memory although
> > system have many reclaimable memory.
> > 
> 
> Why are they often using MIGRATE_RESERVE, have you confirmed that? For that
> to be happening, it implies that either memory is under intense pressure and
> free pages are often below watermarks due to interrupt contexts or they are
> frequently allocating high-order pages in interrupt context. Normal order-0
> allocations should be getting satisified from elsewhere as if the free page
> counts are low, they would be direct reclaiming and that will likely be
> outside of the MIGRATE_RESERVE areas.

if inserting printk() in MIGRATE_RESERVE, I can observe MIGRATE_RESERVE
page alloc easily although heavy workload don't run.
but, there aren't my point.

ok, I guess my patch description was too poor (and a bit pointless).
So, I retry it.

(1) in general principal, the system should effort to avoid oom rather than
    performance if memory shortage happend.
    MIGRATE_RESERVE directly indicate memory shortage happend.
    and pcp caching can prevent another cpu allocation.
(2) MIGRATE_RESERVE is never searched by buffered_rmqueue() because 
    allocflags_to_migratetype() never return MIGRATE_RESERVE.
    it doesn't work as cache.
    IOW, it don't help to increase performance.
(3) if the system pass MIGRATE_RESERVE to free_hot_cold_page() continously,
    pcp queueing can reduce the number of grabing zone->lock.
    However, it is rate. because MIGRATE_RESERVE is emergency memory,
    and it is often used interupt context processing.
    continuous emergency memory allocation in interrupt context isn't so sane.

Then, unqueueing MIGRATE_RESERVE page doesn't cause performance degression
and, it can (a bit) increase realibility and I think merit is much over demerit.




> > static struct page *buffered_rmqueue(struct zone *preferred_zone,
> >                         struct zone *zone, int order, gfp_t gfp_flags)
> > {
> > (snip)
> >                 /* Find a page of the appropriate migrate type */
> >                 if (cold) {
> >                         list_for_each_entry_reverse(page, &pcp->list, lru)
> >                                 if (page_private(page) == migratetype)
> >                                         break;
> >                 } else {
> >                         list_for_each_entry(page, &pcp->list, lru)
> >                                 if (page_private(page) == migratetype)
> >                                         break;
> >                 }
> > 
> > Therefore, I'd like to make per migratetype pcp list.
> 
> That was actually how it was originally implemented and later moved to a list
> search. It got shot down on the grounds a per-cpu structure increased in size.

Yup, I believe at that time your decision is right.
However, I think the condision was changed (or to be able to change).

 (1) legacy pcp implementation deeply relate to struct zone size.
     and, to blow up struct zone size cause performance degression
     because cache miss increasing.
     However, it solved cristoph's cpu-alloc patch

 (2) legacy pcp doesn't have total number of pages restriction.
     So, increasing lists directly cause number of pages in pcp.
     it can cause oom problem on large numa environment.
     However, I think we can implement total number of pages restriction.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
