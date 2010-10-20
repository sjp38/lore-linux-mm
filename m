Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 446B56B00EF
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 05:43:13 -0400 (EDT)
Date: Wed, 20 Oct 2010 20:43:02 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch 31/35] fs: icache per-zone inode LRU
Message-ID: <20101020094302.GE12506@dastard>
References: <20101019034216.319085068@kernel.dk>
 <20101019034658.744504135@kernel.dk>
 <20101019123852.GA12506@dastard>
 <20101020023556.GC3740@amd>
 <20101020031256.GA4095@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101020031256.GA4095@amd>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Wed, Oct 20, 2010 at 01:35:56PM +1100, Nick Piggin wrote:
> > On Tue, Oct 19, 2010 at 11:38:52PM +1100, Dave Chinner wrote:
> > > On Tue, Oct 19, 2010 at 02:42:47PM +1100, npiggin@kernel.dk wrote:
> > > > Per-zone LRUs and shrinkers for inode cache.
> > > 
> > > Regardless of whether this is the right way to scale or not, I don't
> > > like the fact that this moves the cache LRUs into the memory
> > > management structures, and expands the use of MM specific structures
> > > throughout the code.
> > 
> > The zone structure really is the basic unit of memory abstraction
> > in the whole zoned VM concept (which covers different properties
> > of both physical address and NUMA cost).

[ snip lecture on NUMA VM 101 - I got that at SGI w.r.t. Irix more than
8 years ago, and Linux isn't any different. ]

> > > It ties the cache implementation to the current
> > > VM implementation. That, IMO, goes against all the principle of
> > > modularisation at the source code level, and it means we have to tie
> > > all shrinker implemenations to the current internal implementation
> > > of the VM. I don't think that is wise thing to do because of the
> > > dependencies and impedance mismatches it introduces.
> > 
> > It's very fundamental. We allocate memory from, and have to reclaim
> > memory from -- zones. Memory reclaim is driven based on how the VM
> > wants to reclaim memory: nothing you can do to avoid some linkage
> > between the two.

The allocation API exposes per-node allocation, not zones. The zones
are the internal implementation of the API, not what people use
directly for allocation...

> > > As an example: XFS inodes to be reclaimed are simply tagged in a
> > > radix tree so the shrinker can reclaim inodes in optimal IO order
> > > rather strict LRU order. It simply does not match a zone-based
....
> > But anyway, that's kind of an "aside": inode caches are reclaimed
> > in LRU, IO-suboptimal order today anyway. Per-zone LRU doesn't
> > change that in the slightest.

I suspect you didn't read what I wrote, so I'll repeat it. XFS has
reclaimed inodes in optimal IO order for several releases and so
per-zone LRU would change that drastically.

> > > Other subsystems need the same
> > > large-machine scaling treatment, and there's no way we should be
> > > tying them all into the struct zone. It needs further abstraction.
> > 
> > An abstraction? Other than the zone? What do you suggest? Invent
> > something that the VM has no concept of and try to use that?

I think you answered that question yourself a moment ago:

> > The structure is not frequent -- a couple per NUMA node.

Sounds to me like a per-node LRU/shrinker arrangement is an
abstraction that the VM could work with. Indeed, make it run only
from the *per-node kswapd* instead of from direct reclaim, and we'd
also solve the unbound reclaim parallelism problem at the same
time...

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
