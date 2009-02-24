Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 124AB6B003D
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 06:36:23 -0500 (EST)
Date: Tue, 24 Feb 2009 11:36:19 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 04/20] Convert gfp_zone() to use a table of
	precalculated value
Message-ID: <20090224113619.GA25151@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <1235344649-18265-5-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0902231003090.7298@qirst.com> <200902240241.48575.nickpiggin@yahoo.com.au> <alpine.DEB.1.10.0902231042440.7790@qirst.com> <20090223164047.GO6740@csn.ul.ie> <20090224103226.e9e2766f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090224103226.e9e2766f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 24, 2009 at 10:32:26AM +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 23 Feb 2009 16:40:47 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > On Mon, Feb 23, 2009 at 10:43:20AM -0500, Christoph Lameter wrote:
> > > On Tue, 24 Feb 2009, Nick Piggin wrote:
> > > 
> > > > > Are you sure that this is a benefit? Jumps are forward and pretty short
> > > > > and the compiler is optimizing a branch away in the current code.
> > > >
> > > > Pretty easy to mispredict there, though, especially as you can tend
> > > > to get allocations interleaved between kernel and movable (or simply
> > > > if the branch predictor is cold there are a lot of branches on x86-64).
> > > >
> > > > I would be interested to know if there is a measured improvement.
> > 
> > Not in kernbench at least, but that is no surprise. It's a small
> > percentage of the overall cost. It'll appear in the noise for anything
> > other than micro-benchmarks.
> > 
> > > > It
> > > > adds an extra dcache line to the footprint, but OTOH the instructions
> > > > you quote is more than one icache line, and presumably Mel's code will
> > > > be a lot shorter.
> > > 
> > 
> > Yes, it's an index lookup of a shared read-only cache line versus a lot
> > of code with branches to mispredict. I wasn't happy with the cache line
> > consumption but it was the first obvious alternative.
> > 
> > > Maybe we can come up with a version of gfp_zone that has no branches and
> > > no lookup?
> > > 
> > 
> > Ideally, yes, but I didn't spot any obvious way of figuring it out at
> > compile time then or now. Suggestions?
> > 
> 
> 
> Assume
>   ZONE_DMA=0
>   ZONE_DMA32=1
>   ZONE_NORMAL=2
>   ZONE_HIGHMEM=3
>   ZONE_MOVABLE=4
> 
> #define __GFP_DMA       ((__force gfp_t)0x01u)
> #define __GFP_DMA32     ((__force gfp_t)0x02u)
> #define __GFP_HIGHMEM   ((__force gfp_t)0x04u)
> #define __GFP_MOVABLE   ((__force gfp_t)0x08u)
> 
> #define GFP_MAGIC (0400030102) ) #depends on config.
> 
> gfp_zone(mask) = ((GFP_MAGIC >> ((mask & 0xf)*3) & 0x7)
> 

Clever. I can see how this can be made work for __GFP_DMA, __GFP_DMA32 and
__GFP_HIGHMEM. However, I'm not currently seeing how __GFP_MOVABLE can be dealt
with properly and quickly. In the above scheme __GFP_MOVABLE would return
zone 4 which appears right but it's not. Only __GFP_MOVABLE|__GFP_HIGHMEM
should return 4.

To make that work, you end up with something like the following;

#define GFP_DMA_ZONEMAGIC       0000000100
#define GFP_DMA32_ZONEMAGIC     0000010000
#define GFP_NORMAL_ZONEMAGIC    0000000002
#define GFP_HIGHMEM_ZONEMAGIC   0000000200
#define GFP_MOVABLE_ZONEMAGIC   040000000000ULL
#define GFP_MAGIC (GFP_DMA_ZONEMAGIC|GFP_DMA32_ZONEMAGIC|GFP_NORMAL_ZONEMAGIC|GFP_HIGHMEM_ZONEMAGIC|GFP_MOVABLE_ZONEMAGIC)

static inline int new_gfp_zone(gfp_t flags) {
        if ((flags & __GFP_MOVABLE))
                if (!(flags & __GFP_HIGHMEM))
                        flags &= ~__GFP_MOVABLE;
        return (GFP_MAGIC >> ((flags & 0xf)*3) & 0x7);
}

so we end up back again with branches and checking masks. Mind you, I also
ended up with a different GFP magic value when actually implementing this
so I might be missing something else with your suggestion and how it works.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
