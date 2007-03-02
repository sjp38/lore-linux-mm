Date: Fri, 2 Mar 2007 04:57:51 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: The performance and behaviour of the anti-fragmentation related patches
Message-ID: <20070302035751.GA15867@wotan.suse.de>
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org> <Pine.LNX.4.64.0703011854540.5530@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703011854540.5530@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 01, 2007 at 07:05:48PM -0800, Christoph Lameter wrote:
> On Thu, 1 Mar 2007, Andrew Morton wrote:
> > For prioritisation purposes I'd judge that memory hot-unplug is of similar
> > value to the antifrag work (because memory hot-unplug permits DIMM
> > poweroff).
> 
> I would say that anti-frag / defrag enables memory unplug.

Well that really depends. If you want to have any sort of guaranteed
amount of unplugging or shrinking (or hugepage allocating), then antifrag
doesn't work because it is a heuristic.

One thing that worries me about anti-fragmentation is that people might
actually start _using_ higher order pages in the kernel. Then fragmentation
comes back, and it's worse because now it is not just the fringe hugepage or
unplug users (who can anyway work around the fragmentation by allocating
from reserve zones).

> > Our basic unit of memory management is the zone.  Right now, a zone maps
> > onto some hardware-imposed thing.  But the zone-based MM works *well*.  I
> 
> Thats a value judgement that I doubt. Zone based balancing is bad and has 
> been repeatedly patched up so that it works with the usual loads.

Shouldn't we fix it instead of deciding it is broken and add another layer
on top that supposedly does better balancing?

> > suspect that a good way to solve both per-container RSS and mem hotunplug
> > is to split the zone concept away from its hardware limitations: create a
> > "software zone" and a "hardware zone".  All the existing page allocator and
> > reclaim code remains basically unchanged, and it operates on "software
> > zones".  Each software zones always lies within a single hardware zone. 
> > The software zones are resizeable.  For per-container RSS we give each
> > container one (or perhaps multiple) resizeable software zones.
> 
> Resizable software zones? Are they contiguous or not? If not then we
> add another layer to the defrag problem.

I think Andrew is proposing that we work out what the problem is first.
I don't know what the defrag problem is, but I know that fragmentation
is unavoidable unless you have fixed size areas for each different size
of unreclaimable allocation.

> > NUMA and cpusets screwed up: they've gone and used nodes as their basic
> > unit of memory management whereas they should have used zones.  This will
> > need to be untangled.
> 
> zones have hardware characteristics at its core. In a NUMA setting zones 
> determine the performance of loads from those areas. I would like to have
> zones and nodes merged. Maybe extend node numbers into the negative area
> -1 = DMA -2 DMA32 etc? All systems then manage the "nones" (node / zones 
> meerged). One could create additional "virtual" nones after the real nones 
> that have hardware characteristics behind them. The virtual nones would be 
> something like the software zones? Contain MAX_ORDER portions of hardware 
> nones?

But just because zones are hardware _now_ doesn't mean they have to stay
that way. The upshot is that a lot of work for zones is already there.

> > Anyway, that's just a shot in the dark.  Could be that we implement unplug
> > and RSS control by totally different means.  But I do wish that we'd sort
> > out what those means will be before we potentially complicate the story a
> > lot by adding antifragmentation.
> 
> Hmmm.... My shot:
> 
> 1. Merge zones/nodes
> 
> 2. Create new virtual zones/nodes that are subsets of MAX_order blocks of 
> the real zones/nodes. These may then have additional characteristics such
> as 
> 
> A. moveable/unmovable
> B. DMA restrictions
> C. container assignment.

There are alternatives to adding a new layer of virtual zones. We could try
using zones, enven.

zones aren't perfect right now, but they are quite similar to what you
want (ie. blocks of memory). I think we should first try to generalise what
we have rather than adding another layer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
