Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A2E736B0087
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 20:33:38 -0500 (EST)
Date: Fri, 10 Dec 2010 17:33:30 -0800
From: Simon Kirby <sim@hostway.ca>
Subject: Re: [PATCH 0/5] Prevent kswapd dumping excessive amounts of memory
	in response to high-order allocations V2
Message-ID: <20101211013330.GB30377@hostway.ca>
References: <1291376734-30202-1-git-send-email-mel@csn.ul.ie> <20101209015530.GD3796@hostway.ca> <20101209114506.GA20133@csn.ul.ie> <20101210000632.GB18263@hostway.ca> <20101210112832.GP20133@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101210112832.GP20133@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 10, 2010 at 11:28:32AM +0000, Mel Gorman wrote:

> On Thu, Dec 09, 2010 at 04:06:32PM -0800, Simon Kirby wrote:
> 
> > Yeah, I don't mean in all cases, I mean when no particular zone is
> > requested; eg, __alloc_pages_nodemask() with a non-picky zone list, or 
> > when multiple zones are allowed.  This is the case for most allocations.
> 
> Yes, but just because caller A is not picky about the zone does not mean
> caller B is not. Callers always try the highest-possible zone first so
> that pages from lower zones are not used unnecessarily.

But this is only true when the machine is booting or hasn't yet ever
fallen out of the allocator fast path (get_page_from_freelist() has never
failed).

> > So, I'm not proposing abandoning zones, but simply changing
> > get_page_from_freelist() to remember where it last walked zonelist, and
> > try to make a (weighted) round robin out of it.  It can already allocate
> > from any zone in this case anyway.  (The implementation would be a bit
> > more complicated than this due to zonelist not being static, of course.)
> > 
> 
> I'd worry it'd still fall foul of using lower zones when it shouldn't.

It would definitely increase the chance during boot, though we do live in
a hotplug world... :)

> > Even if the checking of other zones happens in a buffered or chunky way
> > to reduce caching effects, it would still mean that all zones fill up at
> > roughly the same time, rather than the DMA zone filling up last. 
> 
> Well, as each zone gets filled, kswapd is woken up to reclaim some
> pages. kswapd always works from the lowest to the highest zone to reduce
> the likelihood a picky caller will fail its allocation. If the lower
> zones have enough free pages they are ignored and kswapd reclaimed from
> the higher zone.

I thought I saw a patch at some point to implement this to avoid it
fighting allocations in the other same direction, but anyway, this
comment which seems to exist since 2.6.5 is interesting:

 * kswapd scans the zones in the highmem->normal->dma direction.  It skips
 * zones which have free_pages > high_wmark_pages(zone), but once a zone is
 * found to have free_pages <= high_wmark_pages(zone), we scan that zone and the
 * lower zones regardless of the number of free pages in the lower zones. This
 * interoperates with the page allocator fallback scheme to ensure that aging
 * of pages is balanced across the zones.

Your patch series changes this behaviour, right?

> > This way, the oldest pages would all be the ones that want to be
> > reclaimed, rather than the a bunch of not-oldest pages being
> > reclaimed simply because the allocator decided to start with a
> > higher zone to avoid allocating from the DMA zone.
> 
> I see what you're saying - a young page can be reclaimed quickly just
> because it's in the wrong zone. In cases where the highest zone is
> comparatively small, it could cause serious issues. Will think about it
> more but a straight round-robining of the zones used could cause
> problems of its own :(

Sure, straight doesn't make sense either.  Weighted round robin based
on zone size sounds right.  Maybe the algo could be borrowed from
net/netfilter/ipvs/ip_vs_wrr.c. ;)

Simon-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
