Date: Wed, 8 Aug 2007 10:36:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/3] Use one zonelist per node instead of multiple
 zonelists v2
In-Reply-To: <20070808161504.32320.79576.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0708081025330.12652@schroedinger.engr.sgi.com>
References: <20070808161504.32320.79576.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee.Schermerhorn@hp.com, pj@sgi.com, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Aug 2007, Mel Gorman wrote:

> These are the range of performance losses/gains I found when running against
> 2.6.23-rc1-mm2. The set and these machines are a mix of i386, x86_64 and
> ppc64 both NUMA and non-NUMA.
> 
> Total CPU time on Kernbench: -0.20% to  3.70%
> Elapsed   time on Kernbench: -0.32% to  3.62%
> page_test from aim9:         -2.17% to 12.42%
> brk_test  from aim9:         -6.03% to 11.49%
> fork_test from aim9:         -2.30% to  5.42%
> exec_test from aim9:         -0.68% to  3.39%
> Size reduction of pg_dat_t:   0     to  7808 bytes (depends on alignment)

Looks good.

> o Remove bind_zonelist() (Patch in progress, very messy right now)

Will this also allow us to avoid always hitting the first node of an 
MPOL_BIND first?

> o Eliminate policy_zone (Trickier)

I doubt that this is possible given

1. We need lower zones (DMA) in various context

2. Those DMA zones are only available on particular nodes.

Policy_zone could be made to only control allows of the highest (and with 
ZONE_MOVABLE) second highest zone on a node?

Think about the 8GB x86_64 configuration I mentioned earlier

node 0  up to 2 GB 		ZONE_DMA and ZONE_DMA32
node 1  up to 4 GB		ZONE_DMA32
node 2  up to 6 GB		ZONE_NORMAL
node 3  up to 8 GB		ZONE_NORMAL

If one wants the node restrictions to work on all nodes then we need to 
apply policy depending on the highest zone of the node.

Current MPOL_BIND would only apply policy to allocations on node 2 and 3.

With ZONE_MOVABLE splitting the highest zone (We will likely need that):

node 0  up to 2 GB              ZONE_DMA and ZONE_DMA32, ZONE_MOVABLE
node 1  up to 4 GB              ZONE_DMA32, ZONE_MOVABLE
node 2  up to 6 GB              ZONE_NORMAL, ZONE_MOVABLE
node 3  up to 8 GB              ZONE_NORMAL, ZONE_MOVABLE

So then the two highest zones on each node would need to be subject to 
policy control.

Another thing is that we may want to think about is maybe to evolve 
ZONE_MOVABLE to be more like the antifrag sections. That way we may be 
able to avoid the multiple types of pages on the pcp lists. That would 
work if we would only work with two page types: Movable and unmovable 
(fold reclaimable into movable after slab defrag)

Then would make blocks of memory movable between ZONE_MOVABLE and others. 
At that point we are almost at the functionality that antifrag offers and 
we may have simplified things a bit.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
