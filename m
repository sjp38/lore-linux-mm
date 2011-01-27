Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1F28C8D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 11:03:28 -0500 (EST)
Date: Thu, 27 Jan 2011 16:03:01 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: too big min_free_kbytes
Message-ID: <20110127160301.GA29291@csn.ul.ie>
References: <1295841406.1949.953.camel@sli10-conroe> <20110124150033.GB9506@random.random> <20110126141746.GS18984@csn.ul.ie> <20110126152302.GT18984@csn.ul.ie> <20110126154203.GS926@random.random> <20110126163655.GU18984@csn.ul.ie> <20110126174236.GV18984@csn.ul.ie> <20110127134057.GA32039@csn.ul.ie> <20110127152755.GB30919@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110127152755.GB30919@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 27, 2011 at 04:27:55PM +0100, Andrea Arcangeli wrote:
> On Thu, Jan 27, 2011 at 01:40:58PM +0000, Mel Gorman wrote:
> > On Wed, Jan 26, 2011 at 05:42:37PM +0000, Mel Gorman wrote:
> > > On Wed, Jan 26, 2011 at 04:36:55PM +0000, Mel Gorman wrote:
> > > > > But the wmarks don't
> > > > > seem the real offender, maybe it's something related to the tiny pci32
> > > > > zone that materialize on 4g systems that relocate some little memory
> > > > > over 4g to make space for the pci32 mmio. I didn't yet finish to debug
> > > > > it.
> > > > > 
> > > > 
> > > > This has to be it. What I think is happening is that we're in balance_pgdat(),
> > > > the "Normal" zone is never hitting the watermark and we constantly call
> > > > "goto loop_again" trying to "rebalance" all zones.
> > > > 
> > > 
> > > Confirmed.
> > > <SNIP>
> > 
> > How about the following? Functionally it would work but I am concerned
> > that the logic in balance_pgdat() and kswapd() is getting out of hand
> > having being adjusted to work with a number of corner cases already. In
> > the next cycle, it could do with a "do-over" attempt to make it easier
> > to follow.
> 
> That number 8 is the problem,

Agreed, I considered your approach as well. I didn't go with it because it
was the main heuristic that allowed kswapd to skip a zone but still allows
kswapd to keep going. I made the choice to try and put kswapd to sleep
sooner.

> I don't think anybody was ever supposed
> to free 8*highwmark pages. kswapd must work in the hysteresis range
> low->high area and then sleep wait low to hit again before it gets
> wakenup. Not sure how that number 8 ever come up... but to be it looks
> like the real offender and I wouldn't work around it.
> 

It was introduced by commit [32a4330d: mm: prevent kswapd from freeing
excessive amounts of lowmem] and sure enough, it was intended to avoid a
situation where memory was freed from every zone if one was imbalanced -
sounds familiar.

> totally untested... I will test....
> 

It should work in terms of free memory. When testing, monitor as well if
kswapd is going asleep or if it is stuck in D state. If it's stuck in D state,
it's looping around in balance_pgdat() and consuming CPU for no good reason
(can use vmscan tracepoints to confirm).

-- 
Mel Gorman
Linux Technology Center
IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
