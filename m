Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 330586B004A
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 06:07:46 -0500 (EST)
Date: Wed, 1 Dec 2010 11:07:28 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] mm: kswapd: Stop high-order balancing when any
	suitable zone is balanced
Message-ID: <20101201110728.GN13268@csn.ul.ie>
References: <1291137339-6323-1-git-send-email-mel@csn.ul.ie> <1291137339-6323-2-git-send-email-mel@csn.ul.ie> <1291169636.12777.43.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1291169636.12777.43.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 01, 2010 at 10:13:56AM +0800, Shaohua Li wrote:
> On Wed, 2010-12-01 at 01:15 +0800, Mel Gorman wrote:
> > When the allocator enters its slow path, kswapd is woken up to balance the
> > node. It continues working until all zones within the node are balanced. For
> > order-0 allocations, this makes perfect sense but for higher orders it can
> > have unintended side-effects. If the zone sizes are imbalanced, kswapd
> > may reclaim heavily on a smaller zone discarding an excessive number of
> > pages. The user-visible behaviour is that kswapd is awake and reclaiming
> > even though plenty of pages are free from a suitable zone.
> > 
> > This patch alters the "balance" logic to stop kswapd if any suitable zone
> > becomes balanced to reduce the number of pages it reclaims from other zones.
>
> from my understanding, the patch will break reclaim high zone if a low
> zone meets the high order allocation, even the high zone doesn't meet
> the high order allocation.

Indeed this is possible and it's a situation confirmed by Simon. Patch 3
should cover it because replacing "are any zones ok?" with "are zones
representing at least 25% of the node balanced?"

> This, for example, will make a high order
> allocation from a high zone fallback to low zone and quickly exhaust low
> zone, for example DMA. This will break some drivers.
> 

The lowmem reserve would prevent that happening so the drivers would be
fine. The real impact is that kswapd would stop when DMA was balanced
even though it was really DMA32 or Normal needed to be balanced for
proper behaviour.

On lowmem reserves though, there is another buglet in
sleeping_prematurely. The classzone_idx it uses means that the wrong
lowmem_reserve is used for the majority of allocation requests.

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
