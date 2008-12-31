Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 57DE86B0096
	for <linux-mm@kvack.org>; Wed, 31 Dec 2008 06:53:36 -0500 (EST)
Date: Wed, 31 Dec 2008 11:53:32 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: stop kswapd's infinite loop at high order
	allocation
Message-ID: <20081231115332.GB20534@csn.ul.ie>
References: <20081230195006.1286.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081230185919.GA17725@csn.ul.ie> <2f11576a0812302054rd26d8bcw6a113b3abefe8965@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <2f11576a0812302054rd26d8bcw6a113b3abefe8965@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, wassim dagash <wassim.dagash@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 31, 2008 at 01:54:17PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> thank you for reviewing.
> 
> >> ==
> >> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> >> Subject: [PATCH] mm: kswapd stop infinite loop at high order allocation
> >>
> >> Wassim Dagash reported following kswapd infinite loop problem.
> >>
> >>   kswapd runs in some infinite loop trying to swap until order 10 of zone
> >>   highmem is OK, While zone higmem (as I understand) has nothing to do
> >>   with contiguous memory (cause there is no 1-1 mapping) which means
> >>   kswapd will continue to try to balance order 10 of zone highmem
> >>   forever (or until someone release a very large chunk of highmem).
> >>
> >> He proposed remove contenious checking on highmem at all.
> >> However hugepage on highmem need contenious highmem page.
> >>
> >
> > I'm lacking the original problem report, but contiguous order-10 pages are
> > indeed required for hugepages in highmem and reclaiming for them should not
> > be totally disabled at any point. While no 1-1 mapping exists for the kernel,
> > contiguity is still required.
> 
> correct.
> but that's ok.
> 
> my patch only change corner case bahavior and only disable high-order
> when priority==0. typical hugepage reclaim don't need and don't reach
> priority==0.
> 
> and sorry. I agree with my "2nd loop"  word of the patch comment is a
> bit misleading.
> 

As I mentioned in the last mail, if it wasn't so misleading, I probably
would have said nothing at all :)

> 
> > kswapd gets a sc.order when it is known there is a process trying to get
> > high-order pages so it can reclaim at that order in an attempt to prevent
> > future direct reclaim at a high-order. Your patch does not appear to depend on
> > GFP_KERNEL at all so I found the comment misleading. Furthermore, asking it to
> > loop again at order-0 means it may scan and reclaim more memory unnecessarily
> > seeing as all_zones_ok was calculated based on a high-order value, not order-0.
> 
> Yup. my patch doesn't depend on GFP_KERNEL.
> 
> but, Why order-0 means it may scan more memory unnecessary?

Because we can enter shrink_active_list() depending on the size of the LRU
lists. Maybe it doesn't matter but it's what I was concerned with as well
as the fact we are changing kswapd to do work other than what it was asked for.

> all_zones_ok() is calculated by zone_watermark_ok() and zone_watermark_ok()
> depend on order argument. and my patch set order variable to 0 too.
> 
> 
> > While constantly looping trying to balance for high-orders is indeed bad,
> > I'm unconvinced this is the correct change. As we have already gone through
> > a priorities and scanned everything at the high-order, would it not make
> > more sense to do just give up with something like the following?
> >
> >       /*
> >        * If zones are still not balanced, loop again and continue attempting
> >        * to rebalance the system. For high-order allocations, fragmentation
> >        * can prevent the zones being rebalanced no matter how hard kswapd
> >        * works, particularly on systems with little or no swap. For costly
> >        * orders, just give up and assume interested processes will either
> >        * direct reclaim or wake up kswapd as necessary.
> >        */
> >        if (!all_zones_ok && sc.order <= PAGE_ALLOC_COSTLY_ORDER) {
> >                cond_resched();
> >
> >                try_to_freeze();
> >
> >                goto loop_again;
> >        }
> >
> > I used PAGE_ALLOC_COSTLY_ORDER instead of sc.order == 0 because we are
> > expected to support allocations up to that order in a fairly reliable fashion.
> 
> my comment is bellow.
> 
> 
> > =============
> > From: Mel Gorman <mel@csn.ul.ie>
> > Subject: [PATCH] mm: stop kswapd's infinite loop at high order allocation
> >
> >  kswapd runs in some infinite loop trying to swap until order 10 of zone
> >  highmem is OK.... kswapd will continue to try to balance order 10 of zone
> >  highmem forever (or until someone release a very large chunk of highmem).
> >
> > For costly high-order allocations, the system may never be balanced due to
> > fragmentation but kswapd should not infinitely loop as a result. The
> > following patch lets kswapd stop reclaiming in the event it cannot
> > balance zones and the order is high-order.
> >
> > Reported-by: wassim dagash <wassim.dagash@gmail.com>
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 62e7f62..03ed9a0 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1867,7 +1867,16 @@ out:
> >
> >                zone->prev_priority = temp_priority[i];
> >        }
> > -       if (!all_zones_ok) {
> > +
> > +       /*
> > +        * If zones are still not balanced, loop again and continue attempting
> > +        * to rebalance the system. For high-order allocations, fragmentation
> > +        * can prevent the zones being rebalanced no matter how hard kswapd
> > +        * works, particularly on systems with little or no swap. For costly
> > +        * orders, just give up and assume interested processes will either
> > +        * direct reclaim or wake up kswapd as necessary.
> > +        */
> > +       if (!all_zones_ok && sc.order <= PAGE_ALLOC_COSTLY_ORDER) {
> >                cond_resched();
> >
> >                try_to_freeze();
> 
> this patch seems no good.
> kswapd come this point every SWAP_CLUSTER_MAX reclaimed because to avoid
> unnecessary priority variable decreasing.
> then "nr_reclaimed >= SWAP_CLUSTER_MAX" indicate kswapd need reclaim more.
> 
> kswapd purpose is "reclaim until pages_high", not reclaim
> SWAP_CLUSTER_MAX pages.
> 
> if your patch applied and kswapd start to reclaim for hugepage, kswapd
> exit balance_pgdat() function after to reclaim only 32 pages
> (SWAP_CLUSTER_MAX).
> 

It probably will have reclaimed more. Lumpy reclaim will have isolated
more pages in down in  isolate_lru_pages() and reclaimed pages within a
high-order blocks of pages even if that is more than SWAP_CLUSTER_MAX pages
(right?). The bailing out does mean that kswapd no longer works as hard for
high-order pages but as I said in the other mail, this is not necessarily
a bad thing as processes will still direct reclaim if they have to.

> In the other hand, "nr_reclaimed < SWAP_CLUSTER_MAX" mean kswapd can't
> reclaim enough
> page although priority == 0.
> in this case, retry is worthless.
> 

Good point. With my patch, we would just give up in the event SWAP_CLUSTER_MAX
pages were not even reclaimed. With your patch, we rescan at order-0 to ensure
the system is actually balanced without waiting to be woken up again. It's
not what kswapd was asked to do, but arguably it's the smart thing to do.

> sorting out again.
> "goto loop_again" reaching happend by two case.
> 
> 1. kswapd reclaimed SWAP_CLUSTER_MAX pages.
>     at that time, kswapd reset priority variable to prevent
> unnecessary priority decreasing.
>     I don't hope this behavior change.
> 2. kswapd scanned until priority==0.
>     this case is debatable. my patch reset any order to 0. but
> following code is also considerable to me. (sorry for tab corrupted,
> current my mail environment is very poor)
> 
> 
> code-A:
>        if (!all_zones_ok) {
>               if ((nr_reclaimed >= SWAP_CLUSTER_MAX) ||
>                  (sc.order <= PAGE_ALLOC_COSTLY_ORDER)) {
>                           cond_resched();
>                            try_to_freeze();
>                            goto loop_again;
>                 }
>        }
> 
> or
> 
> code-B:
>        if (!all_zones_ok) {
>               cond_resched();
>                try_to_freeze();
> 
>               if (nr_reclaimed >= SWAP_CLUSTER_MAX)
>                            goto loop_again;
> 
>               if (sc.order <= PAGE_ALLOC_COSTLY_ORDER)) {
>                            order = sc.order = 0;
>                            goto loop_again;
>               }
>        }
> 
> 
> However, I still like my original proposal because ..
>   - code-A forget to order-1 (for stack) allocation also can cause
> infinite loop.

Conceivably it would cause an infinite loop although we are meant to be
able to grant allocations of that order. The point stands though, it is
not guaranteed which is why I changed it to sc.order == 0 in the second
revision.

>   - code-B doesn't simpler than my original proposal.
> 

Indeed.

> What do you think it?
> 

AFter looking at this for long enough, our patches are functionally similar
except you loop a second time at order-0 without waiting for kswapd to be
woken up. It may reclaim more but if people are ok with that, I'll stay
quiet. Fix the comment and I'll be happy (or even delete it, I prefer no
comments to misleading ones :/). Maybe something like

                /*
                 * Fragmentation may mean that the system cannot be
                 * rebalanced for high-order allocations in all zones.
                 * At this point, if nr_reclaimed < SWAP_CLUSTER_MAX,
                 * it means the zones have been fully scanned and are still
                 * not balanced. For high-order allocations, there is 
                 * little point trying all over again as kswapd may
                 * infinite loop.
                 *
                 * Instead, recheck all watermarks at order-0 as they
                 * are the most important. If watermarks are ok, kswapd will go
                 * back to sleep. High-order users can still direct reclaim
                 * if they wish.
                 */

?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
