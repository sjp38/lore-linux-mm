Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0EBF56B0120
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 01:34:28 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id r10so9536214pdi.3
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 22:34:27 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id ah2si19072785pbd.191.2014.11.10.22.34.23
        for <linux-mm@kvack.org>;
        Mon, 10 Nov 2014 22:34:24 -0800 (PST)
Date: Tue, 11 Nov 2014 17:34:19 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [rfc patch] mm: vmscan: invoke slab shrinkers for each lruvec
Message-ID: <20141111063419.GS23575@dastard>
References: <1415317828-19390-1-git-send-email-hannes@cmpxchg.org>
 <20141110064640.GO23575@dastard>
 <20141110144405.GA6873@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141110144405.GA6873@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 10, 2014 at 09:44:05AM -0500, Johannes Weiner wrote:
> On Mon, Nov 10, 2014 at 05:46:40PM +1100, Dave Chinner wrote:
> > On Thu, Nov 06, 2014 at 06:50:28PM -0500, Johannes Weiner wrote:
> > > The slab shrinkers currently rely on the reclaim code providing an
> > > ad-hoc concept of NUMA nodes that doesn't really exist: for all
> > > scanned zones and lruvecs, the nodes and available LRU pages are
> > > summed up, only to have the shrinkers then again walk that nodemask
> > > when scanning slab caches.  This duplication will only get worse and
> > > more expensive once the shrinkers become aware of cgroups.
> > 
> > As i said previously, it's not an "ad-hoc concept". It's exactly the
> > same NUMA abstraction that the VM presents to anyone who wants to
> > control memory allocation locality. i.e. node IDs and node masks.
> 
> That's what the page allocator takes as input, but it's translated to
> zones fairly quickly, and it definitely doesn't exist in the reclaim
> code anymore.  The way we reconstruct the node view on that level
> really is ad-hoc.  And that is a problem.  It's not just duplicative,
> it's also that reclaim really needs the ability to target types of
> zones in order to meet allocation constraints, and right now we just
> scatter-shoot slab objects and hope we free some desired zone memory.
> 
> I don't see any intrinsic value in symmetry here, especially since we
> can easily encapsulate how the lists are organized for the shrinkers.
> Vladimir is already pushing the interface in that direction: add
> object, remove object, walk objects according to this shrink_control.

You probably don't see the value in symmetry because you look at it
from the inside. I lok at shrinkers from outside the VM, and so I
see them from a very different view point. That is, I do not want
the internal architecture of the VM dictating how I must do things.
The shrinkers are extremely flexible and used in quite varied
subsystems for very different purposes. The shrinker API and
behaviour needs to be independent of the VM so we don't lose that
flexibility....
> 
> > > Instead, invoke the shrinkers for each lruvec scanned - which is
> > > either the zone level, or in case of cgroups, the subset of a zone's
> > > pages that is charged to the scanned memcg.  The number of eligible
> > > LRU pages is naturally available at that level - it is even more
> > > accurate than simply looking at the global state and the number of
> > > available swap pages, as get_scan_count() considers many other factors
> > > when deciding which LRU pages to consider.
> > > 
> > > This invokes the shrinkers more often and with smaller page and scan
> > > counts, but the ratios remain the same, and the shrinkers themselves
> > > do not add significantly to the existing per-lruvec cost.
> > 
> > That goes in the opposite direction is which we've found filesystem
> > shrinkers operate most effectively. i.e. larger batches with less
> > frequent reclaim callouts tend to result in more consistent
> > performance because shrinkers take locks and do IO that other
> > application operations get stuck behind (shrink_batch exists
> > for this reason ;).
> 
> Kswapd, which does the majority of reclaim - unless pressure mounts
> too high - already invokes the shrinkers per-zone, so this seems like
> a granularity we should generally get away with.

Pressure almost always mounts too high on filesystem intensive
workloads. :/

i.e. Almost all siginifcant memory allocation is done under GFP_NOFS
and almost all the kernel caches that need reclaim are filesystem
caches and hence will not do reclaim under GFP_NOFS allocation
contexts. Hence all reclaim gets defered to kswapd very quickly
and so kswapd has to deal with the reclaim backlog of multiple CPUs
on each node generating significant memory pressure....

> > > It would be great if other people could weigh in, and possibly also
> > > expose it to their favorite filesystem and reclaim stress tests.
> > 
> > Causes substantial increase in performance variability on inode
> > intensive benchmarks. On my standard fsmark benchmark, I see file
> > creates sit at around 250,000/sec, but there's several second long
> > dips to about 50,000/sec co-inciding with the inode cache being
> > trimmed by several million inodes. Looking more deeply, this is due
> > to memory pressure driving inode writeback - we're reclaiming inodes
> > that haven't yet been written to disk, and so by reclaiming the
> > inode cache slab more frequently it's driving larger peaks of IO
> > and blocking ongoing filesystem operations more frequently.
> > 
> > My initial thoughts are that this correlates with the above comments
> > I made about frequency of shrinker calls and batch sizes, so I
> > suspect that the aggregation of shrinker-based reclaim work is
> > necessary to minimise the interference that recalim causes at the
> > filesystem level...
> 
> Could you share the benchmark you are running? 

I need to put this in the XFS FAQ. It's the same damn benchmark I've
been running for almost 5 years now....

https://lkml.org/lkml/2013/12/4/813

> Also, how many nodes
> does this machine have?

VM w/ 16p, 16Gb RAM, fakenuma=4, and a sparse 500TB filesystem image
on a pair of SSDs in RAID0.

> My suspicion is that invoking the shrinkers per-zone against the same
> old per-node lists incorrectly triples the slab pressure relative to
> the lru pressure.  Kswapd already does this, but I'm guessing it
> matters less under lower pressure, and once pressure mounts direct
> reclaim takes over, which my patch made more aggressive.
> 
> Organizing the slab objects on per-zone lists would solve this, and
> would also allow proper zone reclaim to meet allocation restraints.

Which is exactly the sort of increase in per-object cache + LRUs we
want to avoid. Nothing outside the VM has the concept of zones - all
our object caches are either global or per-node pools or LRUs. We
need to keep some semblence of global LRU in filesystem
caches because objects are heirarchical in importance. Hence the
more finely grained we chop up the LRUs the worse our working set
maintenance gets.

Indeed, we've moved away from VM based page caches for our complex
subsystems because the VM simply cannot express the reclaim
relationships necessary for efficient maintenance of the working
set. The working set has nothing to do with the locality of the
objects maintained by the cache - it's all about the relationships
between the objects.  Evicting objects based on memory locality does
not work, and that's why we do not use the VM based page caches.

This is precisely why I do not want the internal architecture of the
VM to dictate how we cache and reclaim objects - the VM just has no
concept of what the caches are used for and so therefore should not
be dictating structure of the cache or it's reclaim algorithms.
Shrinkers are simply a method of applying a measure of pressure to a
cache, they do not and should not define how caches are structured
or how they scale.

> But for now, how about the following patch that invokes the shrinkers
> once per node, but uses the allocator's preferred zone as the pivot
> for nr_scanned / nr_eligible instead of summing up the node?  That
> doesn't increase the current number of slab invocations, actually
> reduces them for kswapd, but would put the shrinker calls at a more
> natural level for reclaim, and would also allow us to go ahead with
> the cgroup-aware slab shrinkers.

I'll try to test it tomorrow.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
