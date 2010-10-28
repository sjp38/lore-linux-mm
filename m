Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 525038D000B
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 06:21:03 -0400 (EDT)
Date: Thu, 28 Oct 2010 11:20:48 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/7] vmscan: narrowing synchrounous lumply reclaim
	condition
Message-ID: <20101028102048.GD4896@csn.ul.ie>
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com> <20100805151341.31C3.A69D9226@jp.fujitsu.com> <20101027164138.GD29304@random.random> <20101027171643.GA4896@csn.ul.ie> <20101027180333.GE29304@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101027180333.GE29304@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 27, 2010 at 08:03:33PM +0200, Andrea Arcangeli wrote:
> Hi Mel,
> 
> On Wed, Oct 27, 2010 at 06:16:43PM +0100, Mel Gorman wrote:
> > The series drastically limits the level of hammering lumpy does to the
> > system. I'm currently keeping it alive because lumpy reclaim has received a lot
> > more testing than compaction has. While I ultimately see it going away, I am
> > resisting it being deleted until compaction has been around for a few releases.
> 
> I admit I didn't yet test this modification yet to verify how
> "drastical" is the drastical change. But "less unusable lumpy" I doubt
> will translate to "as usable as without lumpy". And I doubt lumpy will
> ever lead to something "usable" when order 9 allocations are the norm
> and more frequent than order 0 allocations.
> 

Except in the case that this is what you really want - you want those order-9
pages even if it means there is a high allocating cost. This applies when
resizing the static huge page pool to start a very long-lived job for
example.

However, I do agree that lumpy really was bashing the system way too hard
which led to that series of patches. It still could be a lot lighter but
it's much better than it was.


> > Simply because it has been tested and even with compaction there were cases
> > envisoned where it would be used - low memory or when compaction is not
> > configured in for example. The ideal is that compaction is used until lumpy
> 
> Compaction should always be configured in.

That is not the same as guaranteed and it's disabled by default. While I'd
expect distros to enable it, they might not.

> All archs supports
> migration. Only reason to disable compaction is for debugging
> purposes, and should go in kernel hacking section. Or alternatively if
> it's not important that order >0 allocation succeeds (some embedded
> may be in that lucky situation and they can save some bytecode).
> 
> Keeping lumpy in and activated for all high order allocations like

This is not true. We always compact first if it is possible and only if
that fails do we fall back to direct reclaim leading to lumpy reclaim.

> this, can only _hide_ bugs and inefficiencies in compaction in my view
> so in addition to damaging the runtime, it fragment userbase and
> debuggability and I see zero good out of lumpy for all normal
> allocations.
> 

As both code paths are hit, I do not see how it fragments the userbase.
As for debuggability to see if lumpy reclaim is being relied on, one can
monitor if lumpy reclaim using the mm_vmscan_lru_isolate tracepoint and
checking the values for the "lumpy" fields or the order field there.

That said, if it was possible, I'd be also watching to see how often
lumpy reclaim or compaction is being used for small orders because if
it is a common occurance, there is something else possibly wrong (e.g.
MIGRATE_RESERVE broken again).

> > is necessary although this applies more to the static resizing of the huge
> > page pool than THP which I'd expect to backoff without using lumpy reclaim
> > i.e. fail the allocation rather than using lumpy reclaim.
> 
> I agree lumpy is more drastic and aggressive than reclaim and it may
> be quicker to generate hugepages by throwing its blind hammer, in turn
> destroying everything else running and hanging the system for a long
> while.

The point of the series was to be more precise about the hammering and
reduce the allocation latency while also reducing the number of pages
reclaimed and the disruption to the system.

> I wouldn't be so against lumpy if it was only activated by a
> special __GFP_LUMPY flag that only hugetlbfs pool resizing uses.
> hugetlbfs is the very special case, not all other normal
> allocations.
> 

Then by all means try taking it in this direction. I would prefer it over
deletion. Just be careful on what has to happen when compaction is not
available or when it fails because there was not enough memory free to both
allocate the page and satisfy watermarks. Returning "fail" only suits THP. It
doesn't suit static huge page pool resizing and it doesn't suit users of
dynamic huge page pool resizing either.

> > Uhhh, I have one more modification in mind when lumpy is involved and
> > it's to relax the zone watermark slightly to only obey up to
> > PAGE_ALLOC_COSTLY_ORDER. At the moment, it is freeing more pages than
> > are necessary to satisfy an allocation request and hits the system
> > harder than it should. Similar logic should apply to compaction.
> 
> On a side note I want to remove the PAGE_ALLOC_COSTLY_ORDER too, that
> is a flawed concept in the first place.

I didn't say remove. In zone_watermark_ok(), we do not consider any pages of
the lower orders to be free. Depending on the required watermark level, the
system can end up freeing multiple order-9 pages for 1 request unnecessarily.

> A VM that behaves radically
> (radically as in grinding system to an halt and being unusable and
> creating swap storms) different when the order of allocation raises
> from 3 to 4 is hackish and fundamentally incompatible with logics that
> uses frequent order 9 allocations and makes them the default.
> 

Are order-4 allocations common? If so, that in itself needs to be examined. If
they are kernel allocations, both compaction and lumpy reclaim are going
to hit a wall eventually as large numbers of long-lived high-order kernel
allocations impair anti-fragmentation.

> Basically anybody asking an order 9 during the normal runtime (not
> some magic sysfs control) has to be ok if it fails and only relay on
> compaction, or it's in some corner case and as such shall be threated
> instead of mandating the default VM behavior for >=4 order allocation
> for everything else.
> 

And as I've said before, there are users that are happy to wait while those
order-9 allocations happen because it occurs early in the lifetime of a very
long-lived process and where rebooting the machine is not an option.

> The PAGE_ALLOC_COSTLY_ORDER was in practice a not stack-local
> per-process equivalent of what I recommended as the way to trigger
> lumpy (i.e. __GFP_LUMPY), but it's not a good enough approximation
> anymore. So the "activation" for
> blindfolded-hammer-algorithm-creating-swap-storms has to be in
> function of the caller stack, and not in function of the allocation
> order. If that change is done, I won't be forced to drop lumpy
> anymore! But even then I find it hard to justify to keep lumpy alive
> unless it is proven to be more efficient than compaction. But I could
> avoid touching the lumpy code at least.
> 

To make compaction a full replacement for lumpy, reclaim would have to
know how to reclaim order-9 worth of pages and then compact properly.
It's not setup for this and a naive algorithm would spend a lot of time
in the compaction scanning code (which is pretty inefficient). A possible
alternative would be to lumpy-compact i.e. select a page from the LRU and
move all pages around it elsewhere. Again, this is not what we are currently
doing but it's a direction that could be taken.

> My tree uses compaction in a fine way inside kswapd too and tons of
> systems are running without lumpy and floods of order 9 allocations
> with only compaction (in direct reclaim and kswapd) without the
> slighest problem.
>
> Furthermore I extended compaction for all
> allocations not just that PAGE_ALLOC_COSTLY_ORDER (maybe I already
> removed all PAGE_ALLOC_COSTLY_ORDER checks?). There's no good reason
> not to use compaction for every allocation including 1,2,3, and things
> works fine this way.
> 

I see no problem with using compaction for the lower orders when it is
available. It was during review that it got disabled because there were
concerns about how stable migration was as there were a number of bugs being
ironed out.

> For now, to fixup the reject I think I'll go ahead remove these new
> lumpy changes, which also guarantees me the most tested configuration
> that I'm sure works fine without having to test how "less unusable"
> lumpy has become. If later I'll be asked to retain lumpy in order to
> merge THP I'll simply add the __GFP_LUMPY and I'll restrict lumpy in
> the sysfs tweaking corner case.
> 

Just bear in mind what happens when compaction is not available.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
