Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7FABE6B00A1
	for <linux-mm@kvack.org>; Wed, 31 Dec 2008 08:34:18 -0500 (EST)
Date: Wed, 31 Dec 2008 22:34:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: stop kswapd's infinite loop at high order allocation
In-Reply-To: <20081231115332.GB20534@csn.ul.ie>
References: <2f11576a0812302054rd26d8bcw6a113b3abefe8965@mail.gmail.com> <20081231115332.GB20534@csn.ul.ie>
Message-Id: <20081231215934.1296.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, wassim dagash <wassim.dagash@gmail.com>
List-ID: <linux-mm.kvack.org>

Hi

> > > I'm lacking the original problem report, but contiguous order-10 pages are
> > > indeed required for hugepages in highmem and reclaiming for them should not
> > > be totally disabled at any point. While no 1-1 mapping exists for the kernel,
> > > contiguity is still required.
> > 
> > correct.
> > but that's ok.
> > 
> > my patch only change corner case bahavior and only disable high-order
> > when priority==0. typical hugepage reclaim don't need and don't reach
> > priority==0.
> > 
> > and sorry. I agree with my "2nd loop"  word of the patch comment is a
> > bit misleading.
> > 
> 
> As I mentioned in the last mail, if it wasn't so misleading, I probably
> would have said nothing at all :)

very sorry.



> > > kswapd gets a sc.order when it is known there is a process trying to get
> > > high-order pages so it can reclaim at that order in an attempt to prevent
> > > future direct reclaim at a high-order. Your patch does not appear to depend on
> > > GFP_KERNEL at all so I found the comment misleading. Furthermore, asking it to
> > > loop again at order-0 means it may scan and reclaim more memory unnecessarily
> > > seeing as all_zones_ok was calculated based on a high-order value, not order-0.
> > 
> > Yup. my patch doesn't depend on GFP_KERNEL.
> > 
> > but, Why order-0 means it may scan more memory unnecessary?
> 
> Because we can enter shrink_active_list() depending on the size of the LRU
> lists. Maybe it doesn't matter but it's what I was concerned with as well
> as the fact we are changing kswapd to do work other than what it was asked for.

I think it isn't matter.

	if (inactive_anon_is_low(zone)) {
		shrink_active_list(SWAP_CLUSTER_MAX, zone,
		&sc, priority, 0);
	}

this code isn't reclaim, it adjustfor number of pages in inactive list.
if the number of inactive anon pages are already enough, 
inactive_anon_is_low() return 0. then above code doesn't have bad side effect.



> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 62e7f62..03ed9a0 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -1867,7 +1867,16 @@ out:
> > >
> > >                zone->prev_priority = temp_priority[i];
> > >        }
> > > -       if (!all_zones_ok) {
> > > +
> > > +       /*
> > > +        * If zones are still not balanced, loop again and continue attempting
> > > +        * to rebalance the system. For high-order allocations, fragmentation
> > > +        * can prevent the zones being rebalanced no matter how hard kswapd
> > > +        * works, particularly on systems with little or no swap. For costly
> > > +        * orders, just give up and assume interested processes will either
> > > +        * direct reclaim or wake up kswapd as necessary.
> > > +        */
> > > +       if (!all_zones_ok && sc.order <= PAGE_ALLOC_COSTLY_ORDER) {
> > >                cond_resched();
> > >
> > >                try_to_freeze();
> > 
> > this patch seems no good.
> > kswapd come this point every SWAP_CLUSTER_MAX reclaimed because to avoid
> > unnecessary priority variable decreasing.
> > then "nr_reclaimed >= SWAP_CLUSTER_MAX" indicate kswapd need reclaim more.
> > 
> > kswapd purpose is "reclaim until pages_high", not reclaim
> > SWAP_CLUSTER_MAX pages.
> > 
> > if your patch applied and kswapd start to reclaim for hugepage, kswapd
> > exit balance_pgdat() function after to reclaim only 32 pages
> > (SWAP_CLUSTER_MAX).
> > 
> 
> It probably will have reclaimed more. Lumpy reclaim will have isolated
> more pages in down in  isolate_lru_pages() and reclaimed pages within a
> high-order blocks of pages even if that is more than SWAP_CLUSTER_MAX pages
> (right?). 

correct.
but please recall, lumpy reclaim try to get contenious pages, not guarantee
get contenious pages.

Then, although nr_reclaimed >= SWAP_CLUSTER_MAX, no contenious memory can happend.


> The bailing out does mean that kswapd no longer works as hard for
> high-order pages but as I said in the other mail, this is not necessarily
> a bad thing as processes will still direct reclaim if they have to.
> 
> > In the other hand, "nr_reclaimed < SWAP_CLUSTER_MAX" mean kswapd can't
> > reclaim enough
> > page although priority == 0.
> > in this case, retry is worthless.
> > 
> 
> Good point. With my patch, we would just give up in the event SWAP_CLUSTER_MAX
> pages were not even reclaimed. With your patch, we rescan at order-0 to ensure
> the system is actually balanced without waiting to be woken up again. It's
> not what kswapd was asked to do, but arguably it's the smart thing to do.

Agreed.



> AFter looking at this for long enough, our patches are functionally similar
> except you loop a second time at order-0 without waiting for kswapd to be
> woken up. It may reclaim more but if people are ok with that, I'll stay
> quiet. Fix the comment and I'll be happy (or even delete it, I prefer no
> comments to misleading ones :/). Maybe something like
> 
>                 /*
>                  * Fragmentation may mean that the system cannot be
>                  * rebalanced for high-order allocations in all zones.
>                  * At this point, if nr_reclaimed < SWAP_CLUSTER_MAX,
>                  * it means the zones have been fully scanned and are still
>                  * not balanced. For high-order allocations, there is 
>                  * little point trying all over again as kswapd may
>                  * infinite loop.
>                  *
>                  * Instead, recheck all watermarks at order-0 as they
>                  * are the most important. If watermarks are ok, kswapd will go
>                  * back to sleep. High-order users can still direct reclaim
>                  * if they wish.
>                  */
> 
> ?

Excellent. I strongly like this and I hope merge it to my patch.
I'll resend new patch.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
