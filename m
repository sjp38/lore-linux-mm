Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B1C3D6B0087
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 07:13:28 -0500 (EST)
Date: Thu, 9 Dec 2010 12:13:09 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/5] Prevent kswapd dumping excessive amounts of memory
	in response to high-order allocations V2
Message-ID: <20101209121309.GB20133@csn.ul.ie>
References: <1291376734-30202-1-git-send-email-mel@csn.ul.ie> <20101209011808.GC3796@hostway.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101209011808.GC3796@hostway.ca>
Sender: owner-linux-mm@kvack.org
To: Simon Kirby <sim@hostway.ca>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 08, 2010 at 05:18:08PM -0800, Simon Kirby wrote:
> On Fri, Dec 03, 2010 at 11:45:29AM +0000, Mel Gorman wrote:
> 
> > This still needs testing. I've tried multiple reproduction scenarios locally
> > but two things are tripping me. One, Simon's network card is using GFP_ATOMIC
> > allocations where as the one I use locally does not. Second, Simon's is a real
> > mail workload with network traffic and there are no decent mail simulator
> > benchmarks (that I could find at least) that would replicate the situation.
> > Still, I'm hopeful it'll stop kswapd going mad on his machine and might
> > also alleviate some of the "too much free memory" problem.
> > 
> > Changelog since V1
> >   o Take classzone into account
> >   o Ensure that kswapd always balances at order-09
> >   o Reset classzone and order after reading
> >   o Require a percentage of a node be balanced for high-order allocations,
> >     not just any zone as ZONE_DMA could be balanced when the node in general
> >     is a mess
> > 
> > Simon Kirby reported the following problem
> > 
> >    We're seeing cases on a number of servers where cache never fully
> >    grows to use all available memory.  Sometimes we see servers with 4
> >    GB of memory that never seem to have less than 1.5 GB free, even with
> >    a constantly-active VM.  In some cases, these servers also swap out
> >    while this happens, even though they are constantly reading the working
> >    set into memory.  We have been seeing this happening for a long time;
> >    I don't think it's anything recent, and it still happens on 2.6.36.
> > 
> > After some debugging work by Simon, Dave Hansen and others, the prevaling
> > theory became that kswapd is reclaiming order-3 pages requested by SLUB
> > too aggressive about it.
> > 
> > There are two apparent problems here. On the target machine, there is a small
> > Normal zone in comparison to DMA32. As kswapd tries to balance all zones, it
> > would continually try reclaiming for Normal even though DMA32 was balanced
> > enough for callers. The second problem is that sleeping_prematurely() uses
> > the requested order, not the order kswapd finally reclaimed at. This keeps
> > kswapd artifically awake.
> > 
> > This series aims to alleviate these problems but needs testing to confirm
> > it alleviates the actual problem and wider review to think if there is a
> > better alternative approach. Local tests passed but are not reproducing
> > the same problem unfortunately so the results are inclusive.
> 
> So, we have been running the first version of this series in production
> since November 26th, and this version of this series in production since
> early yesterday morning.  Both versions definitely solve the kswapd not
> sleeping problem and do improve the use of memory for caching.  There are
> still problems with fragmentation causing reclaim of more page cache than
> I would like, but without this patch, the system is in bad shape (it
> keeps reading daemons in from disk because kswapd keeps reclaiming them).
> 

This is a plus at least. I've cc'd Andrew, Johannes and Rik so they are
aware of this result. I just released V3 of the series which is very
similar to this version with one major exception, patch 5, which alters
how sleeping_prematurely() treats zone->all_unreclaimable.

> http://0x.ca/sim/ref/2.6.36/?C=M;O=A
> http://0x.ca/sim/ref/2.6.36/mel_v2_memory_day.png
> http://0x.ca/sim/ref/2.6.36/mel_v2_buddyinfo_day.png
> http://0x.ca/sim/ref/2.6.36/mel_v2_buddyinfo_DMA32_day.png
> http://0x.ca/sim/ref/2.6.36/mel_v2_buddyinfo_Normal_day.png
> 
> No problem with page allocation failures or any other problem in the
> weeks of testing.
> 

As you've reported that moving slub to order-0 does not help, I don't
think slub is the only problem any more. I think V3 of the series is
worth merging just for the kswapd-being-awake- problem. If there are
still too many free pages after this is merged, the next best guess is
that it's order-1 pages for task_struct causing the problem.

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
