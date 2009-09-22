Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2FF6B00A7
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 09:33:11 -0400 (EDT)
Date: Tue, 22 Sep 2009 14:33:12 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] slqb: Treat pages freed on a memoryless node as
	local node
Message-ID: <20090922133311.GD25965@csn.ul.ie>
References: <1253302451-27740-1-git-send-email-mel@csn.ul.ie> <1253302451-27740-3-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0909181657280.9490@V090114053VZO-1> <20090919114621.GC1225@csn.ul.ie> <1253554449.7017.256.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1253554449.7017.256.camel@useless.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 21, 2009 at 01:34:09PM -0400, Lee Schermerhorn wrote:
> On Sat, 2009-09-19 at 12:46 +0100, Mel Gorman wrote:
> > On Fri, Sep 18, 2009 at 05:01:14PM -0400, Christoph Lameter wrote:
> > > On Fri, 18 Sep 2009, Mel Gorman wrote:
> > > 
> > > > --- a/mm/slqb.c
> > > > +++ b/mm/slqb.c
> > > > @@ -1726,6 +1726,7 @@ static __always_inline void __slab_free(struct kmem_cache *s,
> > > >  	struct kmem_cache_cpu *c;
> > > >  	struct kmem_cache_list *l;
> > > >  	int thiscpu = smp_processor_id();
> > > > +	int thisnode = numa_node_id();
> > > 
> > > thisnode must be the first reachable node with usable RAM. Not the current
> > > node. cpu 0 may be on node 0 but there is no memory on 0. Instead
> > > allocations fall back to node 2 (depends on policy effective as well. The
> > > round robin meory policy default on bootup may result in allocations from
> > > different nodes as well).
> > > 
> > 
> > Agreed. Note that this is the free path and the point was to illustrate
> > that SLQB is always trying to allocate full pages locally and always
> > freeing them remotely. It always going to the allocator instead of going
> > to the remote lists first. On a memoryless system, this acts as a leak.
> > 
> > A more appropriate fix may be for the kmem_cache_cpu to remember what it
> > considers a local node. Ordinarily it'll be numa_node_id() but on memoryless
> > node it would be the closest reachable node. How would that sound?
> > 
> 
> Interesting.  I've been working on a somewhat similar issue on SLAB and
> ia64.  SLAB doesn't handle fallback very efficiently when local
> allocations fail.
> 

The problem with SLQB was a bit more severe. It was degraded
performance, it hit an OOM storm very quickly and died.

> We noticed, recently,  on a 2.6.72-based kernel that our large ia64

Assume you mean 2.6.27 or HP has some spectacular technology :)

> platforms, when configured in "fully interleaved" mode [all memory on a
> separate memory-only "pseudo-node"] ran significantly slower on, e.g.,
> AIM, hackbench, ... than in "100% cell local memory" mode.   In the
> interleaved mode [0%CLM], all of the actual nodes appear as memoryless,
> so ALL allocations are, effectively, off node.
> 
> I had a patch for SLES11 that addressed this [and eliminated the
> regression] by doing pretty much what Christoph suggests:  treating the
> first node in the zone list for memoryless nodes as the local node for
> slab allocations.  This is, after all, where all "local" allocations
> will come from, or at least will look first.  Apparently my patch is
> incomplete, esp in handling of alien caches, as it plain doesn't work on
> mainline kernels.  I.e., the regression is still there.  
> 

Interesting. What you're seeing is a performance degradation but SLQB has
a more severe problem. It almost looks like memory is getting corrupt and
I think list accesses are being raced without a lock. I thought I could see
where it was happening but it didn't solve the problem.

> The regression is easily visible with hackbench:
> hackbench 400 process 200
> Running with 400*40 (== 16000) tasks
> 
> 100% CLM [no memoryless nodes]:
> 	Of 100 samples, Average: 10.388; Min: 9.901; Max: 12.382
> 
> 0% CLM [all cpus on memoryless nodes; memory on 1 memory only
> pseudo-node]:
> 	Of 50 samples, Average: 242.453; Min: 237.719; Max: 245.671
> 

Oof, much more severe a regression than you'd expect from remote
accesses.

> That's from a mainline kernel ~13Aug--2.3.30-ish.  I verified the
> regression still exists in 2.6.31-rc6 a couple of weeks back.
> 
> Hope to get back to this soon...
> 

Don't suppose a profile shows where all the time is being spent? As this
is 2.6.27, can you check the value of /proc/sys/vm/zone_reclaim_mode? If
it's 1, try setting it to 0 because you might be spending all the time
reclaiming uselessly.

> SLUB doesn't seem to have this problem with memoryless nodes and I
> haven't tested SLQB on this config.  x86_64 does not see this issue
> because in doesn't support memoryless nodes--all cpus on memoryless
> nodes are moved to other nodes with memory. 

Other discussions imply that ppc64 should look at doing something
similar even though it would be pretty invasive.

> [I'm not sure the current
> strategy of ingoring distance when "rehoming" the cpus is a good long
> term strategy, but that's a topic for another discussion :).]
> 


-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
