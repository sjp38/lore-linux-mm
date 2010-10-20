Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8F8D96B00F1
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 06:02:54 -0400 (EDT)
Date: Wed, 20 Oct 2010 21:02:42 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: [patch 31/35] fs: icache per-zone inode LRU
Message-ID: <20101020100242.GA5853@amd>
References: <20101019034216.319085068@kernel.dk>
 <20101019034658.744504135@kernel.dk>
 <20101019123852.GA12506@dastard>
 <20101020023556.GC3740@amd>
 <20101020031256.GA4095@amd>
 <20101020094302.GE12506@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101020094302.GE12506@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 20, 2010 at 08:43:02PM +1100, Dave Chinner wrote:
> > On Wed, Oct 20, 2010 at 01:35:56PM +1100, Nick Piggin wrote:
> > > 
> > > It's very fundamental. We allocate memory from, and have to reclaim
> > > memory from -- zones. Memory reclaim is driven based on how the VM
> > > wants to reclaim memory: nothing you can do to avoid some linkage
> > > between the two.
> 
> The allocation API exposes per-node allocation, not zones. The zones
> are the internal implementation of the API, not what people use
> directly for allocation...

Of course it exposes zones (with GFP flags). In fact they were exposed
before the zone concept was extended to NUMA.


> > > > As an example: XFS inodes to be reclaimed are simply tagged in a
> > > > radix tree so the shrinker can reclaim inodes in optimal IO order
> > > > rather strict LRU order. It simply does not match a zone-based
> ....
> > > But anyway, that's kind of an "aside": inode caches are reclaimed
> > > in LRU, IO-suboptimal order today anyway. Per-zone LRU doesn't
> > > change that in the slightest.
> 
> I suspect you didn't read what I wrote, so I'll repeat it. XFS has
> reclaimed inodes in optimal IO order for several releases and so
> per-zone LRU would change that drastically.

You were talking about XFS's own inode reclaim code? My patches
of course don't change that. I would like to see them usable by
XFS as well of course, but I'm not forcing anything to be
shoehorned in where it doesn't fit properly yet.

The Linux inode reclaimer is pretty well "random" from POV of
disk order, as you know.

I don't have the complete answer about how to write back required
inode information in IO optimal order, and at the same time make
reclaim optimal reclaiming choices.

It could be that a 2 stage reclaim process is enough (have the
Linux inode reclaim make the thing and make it eligible for IO
and real reclaiming, then have an inode writeout pass that does
IO optimal reclaiming from those).

That is really quite speculative and out of scope of this patch set.
But the point is that this patch set doesn't prohibit anything like
that happening, does not change XFS's reclaim currently.


> > > > Other subsystems need the same
> > > > large-machine scaling treatment, and there's no way we should be
> > > > tying them all into the struct zone. It needs further abstraction.
> > > 
> > > An abstraction? Other than the zone? What do you suggest? Invent
> > > something that the VM has no concept of and try to use that?
> 
> I think you answered that question yourself a moment ago:
> 
> > > The structure is not frequent -- a couple per NUMA node.
> 
> Sounds to me like a per-node LRU/shrinker arrangement is an
> abstraction that the VM could work with.

The zone really is the right place. If you do it per node, then
you can still have shortages in one node in a zone but not
another, causing the same excessive reclaim problem.


> Indeed, make it run only
> from the *per-node kswapd* instead of from direct reclaim, and we'd
> also solve the unbound reclaim parallelism problem at the same
> time...

That's also out of scope, but it is among things being
considered, as far as I know (along with capping number of
threads in reclaim etc). But doing zone LRUs doesn't change
this either -- kswapd pagecache reclaim also works per node,
by simply processing all the zones that belong to the node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
