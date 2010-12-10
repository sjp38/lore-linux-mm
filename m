Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 68F7D6B0087
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 06:28:52 -0500 (EST)
Date: Fri, 10 Dec 2010 11:28:32 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/5] Prevent kswapd dumping excessive amounts of memory
	in response to high-order allocations V2
Message-ID: <20101210112832.GP20133@csn.ul.ie>
References: <1291376734-30202-1-git-send-email-mel@csn.ul.ie> <20101209015530.GD3796@hostway.ca> <20101209114506.GA20133@csn.ul.ie> <20101210000632.GB18263@hostway.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101210000632.GB18263@hostway.ca>
Sender: owner-linux-mm@kvack.org
To: Simon Kirby <sim@hostway.ca>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 09, 2010 at 04:06:32PM -0800, Simon Kirby wrote:
> On Thu, Dec 09, 2010 at 11:45:06AM +0000, Mel Gorman wrote:
> 
> > On Wed, Dec 08, 2010 at 05:55:30PM -0800, Simon Kirby wrote:
> > > Hmm...
> > > 
> > > Wouldn't it make more sense for the fast path page allocator to allocate
> > > weighted-round-robin (by zone size) from each zone, rather than just
> > > starting from the highest and working down?
> > > 
> > 
> > Unfortunately, that would cause other problems. Zones are about
> > addressing limitations. The DMA zone is used by callers that cannot
> > address above 16M. On the other extreme, the HighMem zone is used for
> > addresses that cannot be directly mapped at all times due to a lack of
> > virtual address space.
> > 
> > If we round-robined the zones, callers that could use HighMem or Normal
> > may consume memory from DMA32 or DMA causing future allocation requests
> > that require those zones to fail.
> 
> Yeah, I don't mean in all cases, I mean when no particular zone is
> requested; eg, __alloc_pages_nodemask() with a non-picky zone list, or 
> when multiple zones are allowed.  This is the case for most allocations.
> 

Yes, but just because caller A is not picky about the zone does not mean
caller B is not. Callers always try the highest-possible zone first so
that pages from lower zones are not used unnecessarily.

> As soon as my 757 MB Normal fills up, the allocations come from DMA32
> anyway.  (Nothing ever comes from DMA because of lowmem_reserve_pages.)
> 
> > > This would mean that each zone would get a proportional amount of
> > > allocations and reclaiming a bit from each would likely throw out the
> > > oldest allocations, rather than some of that and and some more recent
> > > stuff that was allocated at the beginning of the lower zone.
> > > 
> > > For example, with the current approach, a time progression of allocations
> > > looks like this (N=Normal, D=DMA32): 1N 2N 3N 4D 5D 6D 7D 8D 9D
> > > 
> > > ...once the watermark is hit, kswapd reclaims 1 and 4, since they're
> > > oldest in each zone, but 2 and 3 were allocated earlier.
> > > 
> > > Versus a weighted-round-robin approach: 1N 2D 3D 4N 5D 6D 7N 8D 9D
> > > 
> > > ...kswapd reclaims 1 and 2, and they're oldest in time and maybe LRU.
> > > 
> > > Things probably eventually mix up enough once the system has reclaimed
> > > and allocated more for a while with the current approach, but the
> > > allocations are still chunky depending on how many extra things kswapd
> > > reclaims to reach higher-order watermarks, and doesn't this always mess
> > > with the LRU when the there are multiple usable zones?
> > 
> > If addressing limitations were not a problem, we'd just have a single
> > zone :/
> 
> Wouldn't that be nice. ;)
> 

It would :)

> > > Anyway, this approach might be horrible for some other reasons (page
> > > allocations hoping to be sequential?  bigger cache footprint?), but it
> > > might reduce the requirements for other other workarounds, and it would
> > > make the LRU node-wide instead of zone-wide.
> > > 
> > 
> > Node-wide would be preferably from a page aging perspective but as zones
> > are about addressing limitations, we need to be able to reclaim zones
> > from a specific zone quickly and not have to scan looking for suitable
> > pages.
> 
> So, I'm not proposing abandoning zones, but simply changing
> get_page_from_freelist() to remember where it last walked zonelist, and
> try to make a (weighted) round robin out of it.  It can already allocate
> from any zone in this case anyway.  (The implementation would be a bit
> more complicated than this due to zonelist not being static, of course.)
> 

I'd worry it'd still fall foul of using lower zones when it shouldn't.

> Even if the checking of other zones happens in a buffered or chunky way
> to reduce caching effects, it would still mean that all zones fill up at
> roughly the same time, rather than the DMA zone filling up last. 

Well, as each zone gets filled, kswapd is woken up to reclaim some
pages. kswapd always works from the lowest to the highest zone to reduce
the likelihood a picky caller will fail its allocation. If the lower
zones have enough free pages they are ignored and kswapd reclaimed from
the higher zone.

> This
> way, the oldest pages would all be the ones that want to be reclaimed,
> rather than the a bunch of not-oldest pages being reclaimed simply
> because the allocator decided to start with a higher zone to avoid
> allocating from the DMA zone.
> 

I see what you're saying - a young page can be reclaimed quickly just
because it's in the wrong zone. In cases where the highest zone is
comparatively small, it could cause serious issues. Will think about it
more but a straight round-robining of the zones used could cause
problems of its own :(

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
