Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 38C6A6B00DC
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 22:06:56 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so14305061pab.18
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 19:06:55 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id hf4si12279518pac.80.2014.11.12.19.06.53
        for <linux-mm@kvack.org>;
        Wed, 12 Nov 2014 19:06:54 -0800 (PST)
Date: Thu, 13 Nov 2014 14:06:31 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [rfc patch] mm: vmscan: invoke slab shrinkers for each lruvec
Message-ID: <20141113030631.GZ28565@dastard>
References: <1415317828-19390-1-git-send-email-hannes@cmpxchg.org>
 <20141110064640.GO23575@dastard>
 <20141110144405.GA6873@phnom.home.cmpxchg.org>
 <20141111063419.GS23575@dastard>
 <20141111195310.GA27249@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141111195310.GA27249@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 11, 2014 at 02:53:10PM -0500, Johannes Weiner wrote:
> On Tue, Nov 11, 2014 at 05:34:19PM +1100, Dave Chinner wrote:
> > On Mon, Nov 10, 2014 at 09:44:05AM -0500, Johannes Weiner wrote:
> > > On Mon, Nov 10, 2014 at 05:46:40PM +1100, Dave Chinner wrote:
> > > > On Thu, Nov 06, 2014 at 06:50:28PM -0500, Johannes Weiner wrote:
> > > > > The slab shrinkers currently rely on the reclaim code providing an
> > > > > ad-hoc concept of NUMA nodes that doesn't really exist: for all
> > > > > scanned zones and lruvecs, the nodes and available LRU pages are
> > > > > summed up, only to have the shrinkers then again walk that nodemask
> > > > > when scanning slab caches.  This duplication will only get worse and
> > > > > more expensive once the shrinkers become aware of cgroups.
> > > > 
> > > > As i said previously, it's not an "ad-hoc concept". It's exactly the
> > > > same NUMA abstraction that the VM presents to anyone who wants to
> > > > control memory allocation locality. i.e. node IDs and node masks.
> > > 
> > > That's what the page allocator takes as input, but it's translated to
> > > zones fairly quickly, and it definitely doesn't exist in the reclaim
> > > code anymore.  The way we reconstruct the node view on that level
> > > really is ad-hoc.  And that is a problem.  It's not just duplicative,
> > > it's also that reclaim really needs the ability to target types of
> > > zones in order to meet allocation constraints, and right now we just
> > > scatter-shoot slab objects and hope we free some desired zone memory.
> > > 
> > > I don't see any intrinsic value in symmetry here, especially since we
> > > can easily encapsulate how the lists are organized for the shrinkers.
> > > Vladimir is already pushing the interface in that direction: add
> > > object, remove object, walk objects according to this shrink_control.
> > 
> > You probably don't see the value in symmetry because you look at it
> > from the inside. I lok at shrinkers from outside the VM, and so I
> > see them from a very different view point. That is, I do not want
> > the internal architecture of the VM dictating how I must do things.
> > The shrinkers are extremely flexible and used in quite varied
> > subsystems for very different purposes. The shrinker API and
> > behaviour needs to be independent of the VM so we don't lose that
> > flexibility....
> >
> > > My suspicion is that invoking the shrinkers per-zone against the same
> > > old per-node lists incorrectly triples the slab pressure relative to
> > > the lru pressure.  Kswapd already does this, but I'm guessing it
> > > matters less under lower pressure, and once pressure mounts direct
> > > reclaim takes over, which my patch made more aggressive.
> > > 
> > > Organizing the slab objects on per-zone lists would solve this, and
> > > would also allow proper zone reclaim to meet allocation restraints.
> > 
> > Which is exactly the sort of increase in per-object cache + LRUs we
> > want to avoid. Nothing outside the VM has the concept of zones - all
> > our object caches are either global or per-node pools or LRUs. We
> > need to keep some semblence of global LRU in filesystem
> > caches because objects are heirarchical in importance. Hence the
> > more finely grained we chop up the LRUs the worse our working set
> > maintenance gets.
> > 
> > Indeed, we've moved away from VM based page caches for our complex
> > subsystems because the VM simply cannot express the reclaim
> > relationships necessary for efficient maintenance of the working
> > set. The working set has nothing to do with the locality of the
> > objects maintained by the cache - it's all about the relationships
> > between the objects.  Evicting objects based on memory locality does
> > not work, and that's why we do not use the VM based page caches.
> > 
> > This is precisely why I do not want the internal architecture of the
> > VM to dictate how we cache and reclaim objects - the VM just has no
> > concept of what the caches are used for and so therefore should not
> > be dictating structure of the cache or it's reclaim algorithms.
> > Shrinkers are simply a method of applying a measure of pressure to a
> > cache, they do not and should not define how caches are structured
> > or how they scale.
> 
> But that measure of pressure is defined by local activity.  How can we
> reasonably derive a global measure of pressure from independent local
> situations?
> 
> The scanned/eligible ratio can't be meaningful without a unit attached
> to it, and that unit is currently implementation defined.  Just try to
> figure out what it means for kswapd, direct reclaim, zone reclaim etc.
> 
> "One NUMA node" is a reasonable unit, and with NUMA-awareness in the
> shrinkers we can finally have a meaningful quantity of pressure that
> we can translate between the VM and auxiliary object caches.  My 2nd
> patch should at least make all reclaim paths agree on this unit and
> invoke the shrinkers with well-defined arguments.
> 
> This is still not optimal for the VM and zone reclaim will age slab
> objects in an unrelated zone on the same node disproportionately, but
> we can probably live with that for the most part.  It's an acceptable
> trade-off when filesystems can group related objects on the same node.
> 

Just becaus a subsystem can group objects by memory locality doesn't
mean it's a good idea. In fact, it's actively harmful to do so at
times.

An example from XFS - the metadata buffer cache.  A metadata buffer
in memory is accessed instantly. In contrast, a metadata buffer that
has to be read from disk can take seconds to be read under heavy IO
load and memory pressure.  We have a global filesystem metadata
buffer LRU that the shrinker walks and so we have global working set
management.

Cleaning dirty pages on a node under memory pressure often requires
allocation (i.e.  delayed allocation) during ->writepage.  Every
single allocation or freeing operation needs an allocation group
header buffer to be in memory as it's the root of the btree that
indexes free space.

So, let's make that LRU per-node and the shrinker NUMA aware and
follow VM reclaim locality node masks. The AG header buffer is on
the node with memory pressure, so we turf it out of cache because it
got to the end of the LRU.

Now memory reclaim goes back to scanning the page LRU because we
still need more pages. We find a dirty page, go to write it back,
and then we find we need the AG header for allocation, We now need to
allocate pages for the buffer, then read it in from disk before we
can allocate the blocks needed to clean the page. because this is
kswapd that is running, allocation is node local and occurs on the
node we have memory pressure on, increasing the amount of memory
pressure on the node. This causes more reclaim from the local buffer
cache LRU, leaving only actively referenced buffers on the LRU.

Eventually we finish the page LRU scanning pass and then we run the
shrinkers again. They trigger background cleaning of dirty buffers,
then the buffer cache shrinker sees the AG header buffer as one of
the only unreferenced buffers on the LRU for that node, so reclaims
it.

Memory pressure continues, page LRU scanning goes to write another
dirty page, and the AG header read/reclaim cycle starts again.
The result of this behaviour is that page writeback is several
orders of magnitude slower than it should because we are not
maintaining the working set of metadata buffers in memory.

Caches are funny like this: if you ignore the dependencies between
them then the system performs like crap. The page cache does not
exist in isolation - it is dependent on several other caches (and
therefore shrinkers) behaving appropriately under memory pressure
for it's algorithms to work effectively.

> Global object lists on the other hand are simply broken when we drive
> them by node-local pressure - which is the best the VM can do.  They
> can work by accident, but they'll do the wrong thing depending on the
> workload, and they'll be tuned to implementation details in the VM.
> You might as well drive them by a timer or some other random event.

Seriously? The above metadata buffer LRU is a global object list
because the buffers are owned by the filesystem, not the VM. Access
patterns to the filesystem metadata determine what gets reclaimed,
not memory locality, and as the above example shows memory reclaim
performance is dependent on the filesystem ignoring memory reclaim
locality hints for critical filesystem metadata.

Perhaps another view:

The VM as a nice, neat a bunch of LRUs with well defined
locality dervied from the hardware it directly manages.

Filesystems have nice, neat caches with well defined locality
and reclaimation algorithms that are derived directly from the
hardware they manage.

Graphics memory pools are nice, neat caches with well defined
locality and reclaimation algorithms that are derived directly from
the hardware they manage.

What's the difference between them? They all have different
definitions of "locality".

In the case of filesystems, locality of IO and using caches to
avoiding repeated IO by maintaining the working set in memory is
*always* going to be more important than memory locality. Memory
locality of cached objects has almost no impact on filesystem
performance, and so when it comes to chosing between "working set
cached in memory" and "node low on memory" we are *always* going to
chose to keep the working set cached in memory.

IOWs, what fits the VM does not fit filesystems which does not fit
what graphics drivers need. The *best* we can do is supply some
abstract measure of *how much work to do* and hints about *where to
apply the work*. We have to leave it up to the subsystems to best
manage the impedence mismatch between what the VM wants and what the
subsystem can do - the VM cannot do this and because of that it
can't dictate how reclaim should be performed by shrinkers...

> Using the shrinkers like that is not flexibility, it's just undefined
> behavior.  I wish we could stop this abuse.

It's not undefined, nor is it abuse - it's just not how you wish it
worked.  There is no "one size fits all" answer here, and trying to
force shrinkers to behave according to the VM's idea of "reclaim
locality" instead of their own is counter-productive.

If you want to make things better, start by trying to make the
zonelist page reclaim implemented by shrinker callouts so all memory
reclaim is controlled by the shrinker infrastructure. Just try it as
a mental exercise - it might make you think about this whole "caches
are all different" from a new perspective....

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
