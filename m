Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 054AE6B008C
	for <linux-mm@kvack.org>; Wed, 31 Dec 2008 06:06:23 -0500 (EST)
Date: Wed, 31 Dec 2008 11:06:19 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: stop kswapd's infinite loop at high order
	allocation
Message-ID: <20081231110619.GA20534@csn.ul.ie>
References: <20081230195006.1286.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081230185919.GA17725@csn.ul.ie> <20081231013233.GB32239@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20081231013233.GB32239@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, wassim dagash <wassim.dagash@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 31, 2008 at 02:32:33AM +0100, Nick Piggin wrote:
> On Tue, Dec 30, 2008 at 06:59:19PM +0000, Mel Gorman wrote:
> > On Tue, Dec 30, 2008 at 07:55:47PM +0900, KOSAKI Motohiro wrote:
> > > 
> > > ok, wassim confirmed this patch works well.
> > > 
> > > 
> > > ==
> > > From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > Subject: [PATCH] mm: kswapd stop infinite loop at high order allocation
> > > 
> > > Wassim Dagash reported following kswapd infinite loop problem.
> > > 
> > >   kswapd runs in some infinite loop trying to swap until order 10 of zone
> > >   highmem is OK, While zone higmem (as I understand) has nothing to do
> > >   with contiguous memory (cause there is no 1-1 mapping) which means
> > >   kswapd will continue to try to balance order 10 of zone highmem
> > >   forever (or until someone release a very large chunk of highmem).
> > > 
> > > He proposed remove contenious checking on highmem at all.
> > > However hugepage on highmem need contenious highmem page.
> > > 
> > 
> > I'm lacking the original problem report, but contiguous order-10 pages are
> > indeed required for hugepages in highmem and reclaiming for them should not
> > be totally disabled at any point. While no 1-1 mapping exists for the kernel,
> > contiguity is still required.
> 
> This doesn't totally disable them. It disables asynchronous reclaim for them
> until the next time kswapd kicks is kicked by a higher order allocator. The
> guy who kicked us off this time should go into direct reclaim.
> 

I get that. The check to bail out is made after we've already done the
scanning. I wanted to be clear that contiguity in highmem is required for
hugepages.

> 
> > kswapd gets a sc.order when it is known there is a process trying to get
> > high-order pages so it can reclaim at that order in an attempt to prevent
> > future direct reclaim at a high-order. Your patch does not appear to depend on
> > GFP_KERNEL at all so I found the comment misleading. Furthermore, asking it to
> > loop again at order-0 means it may scan and reclaim more memory unnecessarily
> > seeing as all_zones_ok was calculated based on a high-order value, not order-0.
> 
> It shouldn't, because it should check all that.
> 

Ok, with KOSAKI's patch we

1. Set order to 0 (and stop kswapd doing what it was asked to do)
2. goto loop_again
3. nr_reclaimed gets set to 0 (meaning we lose that value, but no biggie
   as it doesn't get used by the caller anyway)
4. Reset all priorities
5. Do something like the following

	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
		...
		all_zones_ok = 1;
		for (i = pgdat->nr_zones - 1; i >= 0; i--) {
			...
			if (inactive_anon_is_low(zone)) {
				shrink_active_list(SWAP_CLUSTER_MAX, zone,
					&sc, priority, 0);
			}

			if (!zone_watermark_ok(zone, order, zone->pages_high,
					0, 0)) {
				end_zone = i;
				break;
			}
		}
	}

  So, by looping around, we could end up shrinking the active list again
  before we recheck the zone watermarks depending on the size of the
  inactive lists.

If the size of the lists is ok, I agree that we'll go through the lists,
do no reclaiming and exit out, albeit returning 0 when we have reclaimed pages.

> 
> > While constantly looping trying to balance for high-orders is indeed bad,
> > I'm unconvinced this is the correct change. As we have already gone through
> > a priorities and scanned everything at the high-order, would it not make
> > more sense to do just give up with something like the following?
> > 
> >        /*
> >         * If zones are still not balanced, loop again and continue attempting
> >         * to rebalance the system. For high-order allocations, fragmentation
> >         * can prevent the zones being rebalanced no matter how hard kswapd
> >         * works, particularly on systems with little or no swap. For costly
> >         * orders, just give up and assume interested processes will either
> >         * direct reclaim or wake up kswapd as necessary.
> >         */
> >         if (!all_zones_ok && sc.order <= PAGE_ALLOC_COSTLY_ORDER) {
> >                 cond_resched();
> > 
> >                 try_to_freeze();
> > 
> >                 goto loop_again;
> >         }
> > 
> > I used PAGE_ALLOC_COSTLY_ORDER instead of sc.order == 0 because we are
> > expected to support allocations up to that order in a fairly reliable fashion.
> 
> I actually think it's better to do it for all orders, because that
> constant is more or less arbitrary.

i.e.

if (!all_zones_ok && sc.order == 0) {

? or something else

What I did miss was that we have 

                if (nr_reclaimed >= SWAP_CLUSTER_MAX)
                        break;

so with my patch, kswapd is bailing out early without trying to reclaim for
high-orders that hard. That was not what I intended as it means we only ever
really rebalance the full system for order-0 pages and for everything else we
do relatively light scanning. The impact is that high-order users will direct
reclaim rather than depending on kswapd scanning very heavily. Arguably,
this is a good thing.

However, it also means that KOSAKI's and my patches only differs in that mine
bails early and KOSAKI rechecks everything at order-0, possibly reclaiming
more. If the comment was not so misleading, I'd have been a lot happier.

> It is possible a zone might become
> too fragmented to support this, but the allocating process has been OOMed or
> had their allocation satisfied from another zone. kswapd would have no way
> out of the loop even if the system no longer requires higher order allocations.
> 
> IOW, I don't see a big downside, and there is a real upside.
> 
> I think the patch is good.
> 

Which one, KOSAKI's or my one?

Here is my one again which bails out for any high-order allocation after
just light scanning.

====
