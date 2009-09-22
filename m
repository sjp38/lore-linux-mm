Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2026B005C
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 14:29:52 -0400 (EDT)
Subject: Re: [PATCH 2/3] slqb: Treat pages freed on a memoryless node as
 local node
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090922133311.GD25965@csn.ul.ie>
References: <1253302451-27740-1-git-send-email-mel@csn.ul.ie>
	 <1253302451-27740-3-git-send-email-mel@csn.ul.ie>
	 <alpine.DEB.1.10.0909181657280.9490@V090114053VZO-1>
	 <20090919114621.GC1225@csn.ul.ie>
	 <1253554449.7017.256.camel@useless.americas.hpqcorp.net>
	 <20090922133311.GD25965@csn.ul.ie>
Content-Type: text/plain
Date: Tue, 22 Sep 2009 14:29:46 -0400
Message-Id: <1253644186.9398.215.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-09-22 at 14:33 +0100, Mel Gorman wrote:
> On Mon, Sep 21, 2009 at 01:34:09PM -0400, Lee Schermerhorn wrote:
> > On Sat, 2009-09-19 at 12:46 +0100, Mel Gorman wrote:
> > > On Fri, Sep 18, 2009 at 05:01:14PM -0400, Christoph Lameter wrote:
> > > > On Fri, 18 Sep 2009, Mel Gorman wrote:
> > > > 
> > > > > --- a/mm/slqb.c
> > > > > +++ b/mm/slqb.c
> > > > > @@ -1726,6 +1726,7 @@ static __always_inline void __slab_free(struct kmem_cache *s,
> > > > >  	struct kmem_cache_cpu *c;
> > > > >  	struct kmem_cache_list *l;
> > > > >  	int thiscpu = smp_processor_id();
> > > > > +	int thisnode = numa_node_id();
> > > > 
> > > > thisnode must be the first reachable node with usable RAM. Not the current
> > > > node. cpu 0 may be on node 0 but there is no memory on 0. Instead
> > > > allocations fall back to node 2 (depends on policy effective as well. The
> > > > round robin meory policy default on bootup may result in allocations from
> > > > different nodes as well).
> > > > 
> > > 
> > > Agreed. Note that this is the free path and the point was to illustrate
> > > that SLQB is always trying to allocate full pages locally and always
> > > freeing them remotely. It always going to the allocator instead of going
> > > to the remote lists first. On a memoryless system, this acts as a leak.
> > > 
> > > A more appropriate fix may be for the kmem_cache_cpu to remember what it
> > > considers a local node. Ordinarily it'll be numa_node_id() but on memoryless
> > > node it would be the closest reachable node. How would that sound?
> > > 
> > 
> > Interesting.  I've been working on a somewhat similar issue on SLAB and
> > ia64.  SLAB doesn't handle fallback very efficiently when local
> > allocations fail.
> > 
> 
> The problem with SLQB was a bit more severe. It was degraded
> performance, it hit an OOM storm very quickly and died.
> 
> > We noticed, recently,  on a 2.6.72-based kernel that our large ia64
> 
> Assume you mean 2.6.27 or HP has some spectacular technology :)

No, no time travel.  Yet.

> 
> > platforms, when configured in "fully interleaved" mode [all memory on a
> > separate memory-only "pseudo-node"] ran significantly slower on, e.g.,
> > AIM, hackbench, ... than in "100% cell local memory" mode.   In the
> > interleaved mode [0%CLM], all of the actual nodes appear as memoryless,
> > so ALL allocations are, effectively, off node.
> > 
> > I had a patch for SLES11 that addressed this [and eliminated the
> > regression] by doing pretty much what Christoph suggests:  treating the
> > first node in the zone list for memoryless nodes as the local node for
> > slab allocations.  This is, after all, where all "local" allocations
> > will come from, or at least will look first.  Apparently my patch is
> > incomplete, esp in handling of alien caches, as it plain doesn't work on
> > mainline kernels.  I.e., the regression is still there.  
> > 
> 
> Interesting. What you're seeing is a performance degradation but SLQB has
> a more severe problem. It almost looks like memory is getting corrupt and
> I think list accesses are being raced without a lock. I thought I could see
> where it was happening but it didn't solve the problem.
> 
> > The regression is easily visible with hackbench:
> > hackbench 400 process 200
> > Running with 400*40 (== 16000) tasks
> > 
> > 100% CLM [no memoryless nodes]:
> > 	Of 100 samples, Average: 10.388; Min: 9.901; Max: 12.382
> > 
> > 0% CLM [all cpus on memoryless nodes; memory on 1 memory only
> > pseudo-node]:
> > 	Of 50 samples, Average: 242.453; Min: 237.719; Max: 245.671
> > 
> 
> Oof, much more severe a regression than you'd expect from remote
> accesses.

It's not so much the remote access as the gyrations that SLAB goes
through when it can't allocate memory from the default local node.

> 
> > That's from a mainline kernel ~13Aug--2.3.30-ish.  I verified the
> > regression still exists in 2.6.31-rc6 a couple of weeks back.
> > 
> > Hope to get back to this soon...
> > 
> 
> Don't suppose a profile shows where all the time is being spent? As this
> is 2.6.27, can you check the value of /proc/sys/vm/zone_reclaim_mode? If
> it's 1, try setting it to 0 because you might be spending all the time
> reclaiming uselessly.

Well, the profile  just shows the time in __[do_]cache_alloc and friends
throughout the slab code.  I traced the flow [~100 parallel mkfs jobs
here--not hackbench] and saw this:

With cell local memory [!memoryless node] , the typical allocation trace
shows allocation from per cpu queue; no "refill" or "cache grow" from
the page pool:

  timestamp   cpu   pid   function            format tag     cachep         gfp  
16.722752725  23  18094 __cache_alloc          misc: 0x0 0xe000088600160180 0x50 
16.722752810  23  18094 __do_cache_alloc       misc: 0x0 0xe000088600160180 0x50 
16.722762495  23  18094 ____cache_alloc        misc: 0x0 0xe000088600160180 0x50 
16.722763050  23  18094 ____cache_alloc        misc: 0x1 0xe000088600160180 0x50 
16.722772308  23  18094 __do_cache_alloc       misc: 0x1 0xe000088600160180 0x50 
16.722772400  23  18094 __cache_alloc          misc: 0x1 0xe000088600160180 0x50 

You see a few of these that need to refill the slab--here from node 1 page pool [I dropped
the surrounding __cache_alloc function from this one, but it's there].  These a
                                                                                 node id
16.929550814   9  18155 __do_cache_alloc       misc: 0x0 0xe000088600160180 0x50    |
16.929562097   9  18155 ____cache_alloc        misc: 0x0 0xe000088600160180 0x50    |
16.929573762   9  18155 cache_alloc_refill     misc: 0x0 0xe000088600160180 0x50    V
16.929585354   9  18155 cache_grow             misc: 0x0 0xe000088600160180 0x41250 0x1 0x0
16.929688787   9  18155 cache_grow             misc: 0x1 0xe000088600160180 0x41250 0x1 0x0
16.929705349   9  18155 cache_alloc_refill     misc: 0x1 0xe000088600160180 0x50 
16.929715257   9  18155 ____cache_alloc        misc: 0x1 0xe000088600160180 0x50 
16.929725494   9  18155 __do_cache_alloc       misc: 0x1 0xe000088600160180 0x50 

Summary info [extracted from traces -- alloc times include trace overhead]:

              max avg        alloc time
            depth calls    min    max       avg       refills  grows     fallbacks
      total   7  3.02    0.445 149151.245   39.532   265067    21119        0

With 0% Cell Local Memory [all nodes with cpus are memoryless], ALL
traces look like something like the following.  This one took almost no
time in the second cache_grow call [don't know why] so it's not
representative of the times for typical traces.   
                                                                                   node id
19.696309302   1  21026 __cache_alloc          misc: 0x0 0xe000001e0e482600 0x11200  |
19.696309582   1  21026 __do_cache_alloc       misc: 0x0 0xe000001e0e482600 0x11200  |
19.696309690   1  21026 ____cache_alloc        misc: 0x0 0xe000001e0e482600 0x11200  |
19.696310200   1  21026 cache_alloc_refill     misc: 0x0 0xe000001e0e482600 0x11200  V
19.696310730   1  21026 cache_grow             misc: 0x0 0xe000001e0e482600 0x51200 0x0 0x0
19.696310927   1  21026 cache_grow             misc: 0x2 0xe000001e0e482600 0x51200 0x0 0x0
19.696311020   1  21026 cache_alloc_refill     misc: 0x3 0xe000001e0e482600 0x11200  |
19.696311447   1  21026 ____cache_alloc        misc: 0x1 0xe000001e0e482600 0x11200  V
19.696311537   1  21026 ____cache_alloc_node   misc: 0x0 0xe000001e0e482600 0x11200 0x0 0x0
19.696311800   1  21026 cache_grow             misc: 0x0 0xe000001e0e482600 0x51200 0x0 0x0
19.696312350   1  21026 cache_grow             misc: 0x2 0xe000001e0e482600 0x51200 0x0 0x0
19.696312440   1  21026 fallback_alloc         misc: 0x0 0xe000001e0e482600 0x11200  V
19.696313095   1  21026 ____cache_alloc_node   misc: 0x0 0xe000001e0e482600 0x51200 0x4 0x0
19.696313745   1  21026 ____cache_alloc_node   misc: 0x1 0xe000001e0e482600 0x51200 0x4
19.696313957   1  21026 fallback_alloc         misc: 0x1 0xe000001e0e482600 0x11200 0x4
19.696314170   1  21026 __do_cache_alloc       misc: 0x1 0xe000001e0e482600 0x11200 
19.696314427   1  21026 __cache_alloc          misc: 0x1 0xe000001e0e482600 0x11200 

Summary:

              max avg        alloc time
            depth calls    min    max       avg       refills  grows     fallbacks
       total   8  9.00    1.685 269425.305  111.350  5652978 11313754  5652630


The 'misc' field of 0x3 on the first cache_grow call indicates failure
-- no memory on this node [0] -- as does the 0x3 for the 'refill call.
[Generally for this field, '0' = entry, !0 = exit.]  So the "optimistic"
call to ____cache_alloc [that doesn't know how to fallback/overflow]
fails and __do_cache_alloc has to call '__cache_alloc_node' which DOES
know how to fall back.  However, it also first attempts to allocate from
node 0 before falling back to node 4.

[Regarding "node 4":  Node ids 0-3 on this platform represent actually
physical cell boards with cpus, local System Bus Adapters [parents of
the pci buses], and memory.  The firmware takes memory from each cell
board and interleaves it on a cache line and presents it in the
SRAT/SLIT as a Node N+1, where N = the number of actual physical
nodes--so node 4 here is that interleaved memory-only node.  Even in
so-called "100% Cell Local Memory [CLM]" mode, the firmware steals
~0.5-1GB of memory as the interleaved memory is at phys addr 0 and
BIOS/EFI requires this.  The cell local memory appears natively at some
very high physical address.  In 0%CLM mode, all of the memory in in node
N+1, and the local memory physical address ranges appear unpopulated--at
least as far as the SRAT, efi memory table, ... are concerned.]

So, for a memoryless node, SLAB never caches any of the remote node's
slab pages on the local per cpu queues.  Because of this, I saw a fair
amount of contention on node 4's page pool--many tasks entering
cache_grow about the same time and returning in different order from
arrival 

Teaching the slab to treat the node of the first entry in a memoryless
node's [generic] zonelist alleviated the problem on the SLES11 kernel,
but not mainline.  I'm trying to get back to figuring out what's
different there. 


> > SLUB doesn't seem to have this problem with memoryless nodes and I
> > haven't tested SLQB on this config.  x86_64 does not see this issue
> > because in doesn't support memoryless nodes--all cpus on memoryless
> > nodes are moved to other nodes with memory. 
> 
> Other discussions imply that ppc64 should look at doing something
> similar even though it would be pretty invasive.

Yeah, saw that.   I wouldn't want to lose the association of cpus with
IO buses and other widgets that might appear on physical processor
boards or sockets/packages independent of memory.  But, that's another
discussion.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
