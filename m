Date: Thu, 1 Mar 2007 19:05:48 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
In-Reply-To: <20070301160915.6da876c5.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0703011854540.5530@schroedinger.engr.sgi.com>
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@skynet.ie>, npiggin@suse.de, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 1 Mar 2007, Andrew Morton wrote:

> What worries me is memory hot-unplug and per-container RSS limits.  We
> don't know how we're going to do either of these yet, and it could well be
> that the anti-frag work significantly complexicates whatever we end up
> doing there.

Right now it seems that the per container RSS limits differ from the 
statistics calculated per zone. There would be a conceptual overlap but 
the containers are optional and track numbers differently. There is no RSS 
counter in a zone f.e.

memory hot-unplug would directly tap into the anti-frag work. Essentially 
only the zone with movable pages would be unpluggable without additional 
measures. Making slab items and other allocations that is fixed movable 
requires work anyways. A new zone concept will not help.

> For prioritisation purposes I'd judge that memory hot-unplug is of similar
> value to the antifrag work (because memory hot-unplug permits DIMM
> poweroff).

I would say that anti-frag / defrag enables memory unplug.

> And I'd judge that per-container RSS limits are of considerably more value
> than antifrag (in fact per-container RSS might be a superset of antifrag,
> in the sense that per-container RSS and containers could be abused to fix
> the i-cant-get-any-hugepages problem, dunno).

They relate? How can a container perform antifrag? Meaning a container 
reserves a portion of a hardware zone and becomes a software zone.

> So some urgent questions are: how are we going to do mem hotunplug and
> per-container RSS?

Separately. There is no need to mingle these two together.

> Our basic unit of memory management is the zone.  Right now, a zone maps
> onto some hardware-imposed thing.  But the zone-based MM works *well*.  I

Thats a value judgement that I doubt. Zone based balancing is bad and has 
been repeatedly patched up so that it works with the usual loads.

> suspect that a good way to solve both per-container RSS and mem hotunplug
> is to split the zone concept away from its hardware limitations: create a
> "software zone" and a "hardware zone".  All the existing page allocator and
> reclaim code remains basically unchanged, and it operates on "software
> zones".  Each software zones always lies within a single hardware zone. 
> The software zones are resizeable.  For per-container RSS we give each
> container one (or perhaps multiple) resizeable software zones.

Resizable software zones? Are they contiguous or not? If not then we
add another layer to the defrag problem.

> For memory hotunplug, some of the hardware zone's software zones are marked
> reclaimable and some are not; DIMMs which are wholly within reclaimable
> zones can be depopulated and powered off or removed.

So subzones indeed. How about calling the MAX_ORDER entities that Mel's 
patches create "software zones"?

> NUMA and cpusets screwed up: they've gone and used nodes as their basic
> unit of memory management whereas they should have used zones.  This will
> need to be untangled.

zones have hardware characteristics at its core. In a NUMA setting zones 
determine the performance of loads from those areas. I would like to have
zones and nodes merged. Maybe extend node numbers into the negative area
-1 = DMA -2 DMA32 etc? All systems then manage the "nones" (node / zones 
meerged). One could create additional "virtual" nones after the real nones 
that have hardware characteristics behind them. The virtual nones would be 
something like the software zones? Contain MAX_ORDER portions of hardware 
nones?

> Anyway, that's just a shot in the dark.  Could be that we implement unplug
> and RSS control by totally different means.  But I do wish that we'd sort
> out what those means will be before we potentially complicate the story a
> lot by adding antifragmentation.

Hmmm.... My shot:

1. Merge zones/nodes

2. Create new virtual zones/nodes that are subsets of MAX_order blocks of 
the real zones/nodes. These may then have additional characteristics such
as 

A. moveable/unmovable
B. DMA restrictions
C. container assignment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
