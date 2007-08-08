Date: Wed, 8 Aug 2007 22:04:29 +0100
Subject: Re: [PATCH 0/3] Use one zonelist per node instead of multiple zonelists v2
Message-ID: <20070808210429.GA32462@skynet.ie>
References: <20070808161504.32320.79576.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0708081025330.12652@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708081025330.12652@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee.Schermerhorn@hp.com, pj@sgi.com, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (08/08/07 10:36), Christoph Lameter didst pronounce:
> On Wed, 8 Aug 2007, Mel Gorman wrote:
> 
> > These are the range of performance losses/gains I found when running against
> > 2.6.23-rc1-mm2. The set and these machines are a mix of i386, x86_64 and
> > ppc64 both NUMA and non-NUMA.
> > 
> > Total CPU time on Kernbench: -0.20% to  3.70%
> > Elapsed   time on Kernbench: -0.32% to  3.62%
> > page_test from aim9:         -2.17% to 12.42%
> > brk_test  from aim9:         -6.03% to 11.49%
> > fork_test from aim9:         -2.30% to  5.42%
> > exec_test from aim9:         -0.68% to  3.39%
> > Size reduction of pg_dat_t:   0     to  7808 bytes (depends on alignment)
> 
> Looks good.
> 

Indeed.

> > o Remove bind_zonelist() (Patch in progress, very messy right now)
> 
> Will this also allow us to avoid always hitting the first node of an 
> MPOL_BIND first?
> 

If by first node you mean avoid hitting nodes in numerical order, then
yes. The patch changes __alloc_pages to be __alloc_pages_nodemask() with
a wrapper __alloc_pages that passes in NULL for nodemask. The nodemask
is then filtered similar to how zones are filtered in this patch. The
patch is ugly right now and untested but it deletes policy-specific code
and prehaps some of the cpuset code could be expressed in those terms as
well.

> > o Eliminate policy_zone (Trickier)
> 
> I doubt that this is possible given
> 
> 1. We need lower zones (DMA) in various context
> 
> 2. Those DMA zones are only available on particular nodes.
> 

Right.

> Policy_zone could be made to only control allows of the highest (and with 
> ZONE_MOVABLE) second highest zone on a node?
> 
> Think about the 8GB x86_64 configuration I mentioned earlier
> 
> node 0  up to 2 GB 		ZONE_DMA and ZONE_DMA32
> node 1  up to 4 GB		ZONE_DMA32
> node 2  up to 6 GB		ZONE_NORMAL
> node 3  up to 8 GB		ZONE_NORMAL
> 
> If one wants the node restrictions to work on all nodes then we need to 
> apply policy depending on the highest zone of the node.
> 
> Current MPOL_BIND would only apply policy to allocations on node 2 and 3.
> 
> With ZONE_MOVABLE splitting the highest zone (We will likely need that):
> 
> node 0  up to 2 GB              ZONE_DMA and ZONE_DMA32, ZONE_MOVABLE
> node 1  up to 4 GB              ZONE_DMA32, ZONE_MOVABLE
> node 2  up to 6 GB              ZONE_NORMAL, ZONE_MOVABLE
> node 3  up to 8 GB              ZONE_NORMAL, ZONE_MOVABLE
> 
> So then the two highest zones on each node would need to be subject to 
> policy control.
> 

One option would be to force that a node with ZONE_DMA is bound so that
policies will get applied as much as possible but that would lead to an
unfair use of one node for ZONE_DMA allocations for example.

An alternative may be to work out at policy creation time what the lowest
zone common to all nodes in the list is and apply the MPOL_BIND policy if
the current allocation can use that zone. It's an improvement on the global
policy_zone at least but depends on this one-zonelist-per-node patchset
which we need to agree/disagree on first.

> Another thing is that we may want to think about is maybe to evolve 
> ZONE_MOVABLE to be more like the antifrag sections. That way we may be 
> able to avoid the multiple types of pages on the pcp lists. That would 
> work if we would only work with two page types: Movable and unmovable 
> (fold reclaimable into movable after slab defrag)
> 

I'll keep it in mind. It's been suggested before so I revisit it every
so often. The details were messy each time though and inferior to
grouping pages by mobility in a number of respects.

> Then would make blocks of memory movable between ZONE_MOVABLE and others. 
> At that point we are almost at the functionality that antifrag offers and 
> we may have simplified things a bit.
> 

It gets hard when the zone for unmovable pages is full, the zone with movable
pages doesn't have a fully free block and the allocator cannot reclaim. Even
though the blocks in the movable potion may contain free pages, there is
no easy way to access them. At that point, we are in a similar situation
grouping pages by mobility deals with except it's harder to work out.

I'll revisit it again just in case but for now I'd rather not get
sidetracked from the patchset at hand.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
