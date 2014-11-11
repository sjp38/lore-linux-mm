Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 5507A6B0128
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 14:53:29 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id n12so12772675wgh.41
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 11:53:28 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ka4si21444438wjc.46.2014.11.11.11.53.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Nov 2014 11:53:28 -0800 (PST)
Date: Tue, 11 Nov 2014 14:53:10 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [rfc patch] mm: vmscan: invoke slab shrinkers for each lruvec
Message-ID: <20141111195310.GA27249@phnom.home.cmpxchg.org>
References: <1415317828-19390-1-git-send-email-hannes@cmpxchg.org>
 <20141110064640.GO23575@dastard>
 <20141110144405.GA6873@phnom.home.cmpxchg.org>
 <20141111063419.GS23575@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141111063419.GS23575@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 11, 2014 at 05:34:19PM +1100, Dave Chinner wrote:
> On Mon, Nov 10, 2014 at 09:44:05AM -0500, Johannes Weiner wrote:
> > On Mon, Nov 10, 2014 at 05:46:40PM +1100, Dave Chinner wrote:
> > > On Thu, Nov 06, 2014 at 06:50:28PM -0500, Johannes Weiner wrote:
> > > > The slab shrinkers currently rely on the reclaim code providing an
> > > > ad-hoc concept of NUMA nodes that doesn't really exist: for all
> > > > scanned zones and lruvecs, the nodes and available LRU pages are
> > > > summed up, only to have the shrinkers then again walk that nodemask
> > > > when scanning slab caches.  This duplication will only get worse and
> > > > more expensive once the shrinkers become aware of cgroups.
> > > 
> > > As i said previously, it's not an "ad-hoc concept". It's exactly the
> > > same NUMA abstraction that the VM presents to anyone who wants to
> > > control memory allocation locality. i.e. node IDs and node masks.
> > 
> > That's what the page allocator takes as input, but it's translated to
> > zones fairly quickly, and it definitely doesn't exist in the reclaim
> > code anymore.  The way we reconstruct the node view on that level
> > really is ad-hoc.  And that is a problem.  It's not just duplicative,
> > it's also that reclaim really needs the ability to target types of
> > zones in order to meet allocation constraints, and right now we just
> > scatter-shoot slab objects and hope we free some desired zone memory.
> > 
> > I don't see any intrinsic value in symmetry here, especially since we
> > can easily encapsulate how the lists are organized for the shrinkers.
> > Vladimir is already pushing the interface in that direction: add
> > object, remove object, walk objects according to this shrink_control.
> 
> You probably don't see the value in symmetry because you look at it
> from the inside. I lok at shrinkers from outside the VM, and so I
> see them from a very different view point. That is, I do not want
> the internal architecture of the VM dictating how I must do things.
> The shrinkers are extremely flexible and used in quite varied
> subsystems for very different purposes. The shrinker API and
> behaviour needs to be independent of the VM so we don't lose that
> flexibility....
>
> > My suspicion is that invoking the shrinkers per-zone against the same
> > old per-node lists incorrectly triples the slab pressure relative to
> > the lru pressure.  Kswapd already does this, but I'm guessing it
> > matters less under lower pressure, and once pressure mounts direct
> > reclaim takes over, which my patch made more aggressive.
> > 
> > Organizing the slab objects on per-zone lists would solve this, and
> > would also allow proper zone reclaim to meet allocation restraints.
> 
> Which is exactly the sort of increase in per-object cache + LRUs we
> want to avoid. Nothing outside the VM has the concept of zones - all
> our object caches are either global or per-node pools or LRUs. We
> need to keep some semblence of global LRU in filesystem
> caches because objects are heirarchical in importance. Hence the
> more finely grained we chop up the LRUs the worse our working set
> maintenance gets.
> 
> Indeed, we've moved away from VM based page caches for our complex
> subsystems because the VM simply cannot express the reclaim
> relationships necessary for efficient maintenance of the working
> set. The working set has nothing to do with the locality of the
> objects maintained by the cache - it's all about the relationships
> between the objects.  Evicting objects based on memory locality does
> not work, and that's why we do not use the VM based page caches.
> 
> This is precisely why I do not want the internal architecture of the
> VM to dictate how we cache and reclaim objects - the VM just has no
> concept of what the caches are used for and so therefore should not
> be dictating structure of the cache or it's reclaim algorithms.
> Shrinkers are simply a method of applying a measure of pressure to a
> cache, they do not and should not define how caches are structured
> or how they scale.

But that measure of pressure is defined by local activity.  How can we
reasonably derive a global measure of pressure from independent local
situations?

The scanned/eligible ratio can't be meaningful without a unit attached
to it, and that unit is currently implementation defined.  Just try to
figure out what it means for kswapd, direct reclaim, zone reclaim etc.

"One NUMA node" is a reasonable unit, and with NUMA-awareness in the
shrinkers we can finally have a meaningful quantity of pressure that
we can translate between the VM and auxiliary object caches.  My 2nd
patch should at least make all reclaim paths agree on this unit and
invoke the shrinkers with well-defined arguments.

This is still not optimal for the VM and zone reclaim will age slab
objects in an unrelated zone on the same node disproportionately, but
we can probably live with that for the most part.  It's an acceptable
trade-off when filesystems can group related objects on the same node.

Global object lists on the other hand are simply broken when we drive
them by node-local pressure - which is the best the VM can do.  They
can work by accident, but they'll do the wrong thing depending on the
workload, and they'll be tuned to implementation details in the VM.
You might as well drive them by a timer or some other random event.

Using the shrinkers like that is not flexibility, it's just undefined
behavior.  I wish we could stop this abuse.

> > But for now, how about the following patch that invokes the shrinkers
> > once per node, but uses the allocator's preferred zone as the pivot
> > for nr_scanned / nr_eligible instead of summing up the node?  That
> > doesn't increase the current number of slab invocations, actually
> > reduces them for kswapd, but would put the shrinker calls at a more
> > natural level for reclaim, and would also allow us to go ahead with
> > the cgroup-aware slab shrinkers.
> 
> I'll try to test it tomorrow.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
