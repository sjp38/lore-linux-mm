Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 150656B00A4
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 23:13:04 -0400 (EDT)
Date: Wed, 20 Oct 2010 14:12:56 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: [patch 31/35] fs: icache per-zone inode LRU
Message-ID: <20101020031256.GA4095@amd>
References: <20101019034216.319085068@kernel.dk>
 <20101019034658.744504135@kernel.dk>
 <20101019123852.GA12506@dastard>
 <20101020023556.GC3740@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101020023556.GC3740@amd>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Gah. Try again.

On Wed, Oct 20, 2010 at 01:35:56PM +1100, Nick Piggin wrote:
> [I should have cc'ed this one to linux-mm as well, so I quote your
> reply in full here]
> 
> On Tue, Oct 19, 2010 at 11:38:52PM +1100, Dave Chinner wrote:
> > On Tue, Oct 19, 2010 at 02:42:47PM +1100, npiggin@kernel.dk wrote:
> > > Per-zone LRUs and shrinkers for inode cache.
> > 
> > Regardless of whether this is the right way to scale or not, I don't
> > like the fact that this moves the cache LRUs into the memory
> > management structures, and expands the use of MM specific structures
> > throughout the code.
> 
> The zone structure really is the basic unit of memory abstraction
> in the whole zoned VM concept (which covers different properties
> of both physical address and NUMA cost).
> 
> The zone contains structures for memory management that aren't
> otherwise directly related to one another. Generic page waitqueues,
> page allocator structures, pagecache reclaim structures, memory model
> data, and various statistics.
> 
> Structures to reclaim inodes from a particular zone belong in the
> zone struct as much as those to reclaim pagecache or anonymous
> memory from that zone too. It actually fits far better in here than
> globally, because all our allocation/reclaiming/watermarks etc is
> driven per-zone.
> 
> The structure is not frequent -- a couple per NUMA node.
> 
> 
> > It ties the cache implementation to the current
> > VM implementation. That, IMO, goes against all the principle of
> > modularisation at the source code level, and it means we have to tie
> > all shrinker implemenations to the current internal implementation
> > of the VM. I don't think that is wise thing to do because of the
> > dependencies and impedance mismatches it introduces.
> 
> It's very fundamental. We allocate memory from, and have to reclaim
> memory from -- zones. Memory reclaim is driven based on how the VM
> wants to reclaim memory: nothing you can do to avoid some linkage
> between the two.
> 
> Look at it this way. The dumb global shrinker is also tied to an
> MM implementation detail, but that detail in fact does *not* match
> the reality of the MM, and so it has all these problems interacting
> with real reclaim.
> 
> What problems? OK, on an N zone system (assuming equal zones and
> even distribution of objects around memory), then if there is a shortage
> on a particular zone, slabs from _all_ zones are reclaimed. We reclaim
> a factor of N too many objects. In a NUMA situation, we also touch
> remote memory with a chance (N-1)/N.
> 
> As number of nodes grow beyond 2, this quickly goes down hill.
> 
> In summary, there needs to be some knowledge of how MM reclaims memory
> in memory reclaim shrinkers -- simply can't do a good implementation
> without that. If the zone concept changes, the MM gets turned upside
> down and all those assumptions would need to be revisited anyway.
> 
> 
> > As an example: XFS inodes to be reclaimed are simply tagged in a
> > radix tree so the shrinker can reclaim inodes in optimal IO order
> > rather strict LRU order. It simply does not match a zone-based
> 
> This is another problem, similar to what we have in pagecache. In
> the pagecache, we need to clean pages in optimal IO order, but we
> still reclaim them according to some LRU order.
> 
> If you reclaim them in optimal IO order, cache efficiency will go
> down because you sacrifice recency/frequency information. If you
> IO in reclaim order, IO efficiency goes down. The solution is to
> decouple them with like writeout versus reclaim.
> 
> But anyway, that's kind of an "aside": inode caches are reclaimed
> in LRU, IO-suboptimal order today anyway. Per-zone LRU doesn't
> change that in the slightest.
> 
> > shrinker implementation in any way, shape or form, nor does it's
> > inherent parallelism match that of the way shrinkers are called.
> > 
> > Any change in shrinker infrastructure needs to be able to handle
> > these sorts of impedance mismatches between the VM and the cache
> > subsystem. The current API doesn't handle this very well, either,
> > so it's something that we need to fix so that scalability is easy
> > for everyone.
> > 
> > Anyway, my main point is that tying the LRU and shrinker scaling to
> > the implementation of the VM is a one-off solution that doesn't work
> > for generic infrastructure.
> 
> No it isn't. It worked for the pagecache, and it works for dcache.
> 
> 
> > Other subsystems need the same
> > large-machine scaling treatment, and there's no way we should be
> > tying them all into the struct zone. It needs further abstraction.
> 
> An abstraction? Other than the zone? What do you suggest? Invent
> something that the VM has no concept of and try to use that?
> 
> No. The zone is the right thing to base it on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
