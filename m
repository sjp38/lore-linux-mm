Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 681CB6B00A7
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 00:47:36 -0500 (EST)
Date: Mon, 19 Jan 2009 06:47:30 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090119054730.GA22584@wotan.suse.de>
References: <20090114114707.GA24673@wotan.suse.de> <84144f020901140544v56b856a4w80756b90f5b59f26@mail.gmail.com> <20090114142200.GB25401@wotan.suse.de> <84144f020901140645o68328e01ne0e10ace47555e19@mail.gmail.com> <20090114150900.GC25401@wotan.suse.de> <Pine.LNX.4.64.0901141158090.26507@quilx.com> <20090115060330.GB17810@wotan.suse.de> <Pine.LNX.4.64.0901151320250.26467@quilx.com> <20090116031940.GL17810@wotan.suse.de> <Pine.LNX.4.64.0901161500080.27283@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0901161500080.27283@quilx.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 16, 2009 at 03:07:52PM -0600, Christoph Lameter wrote:
> On Fri, 16 Jan 2009, Nick Piggin wrote:
> 
> > > handled by the same 2M TLB covering a 32k page. If the 4k pages are
> > > dispersed then you may need 8 2M tlbs (which covers already a quarter of
> > > the available 2M TLBs on nehalem f.e.) for which the larger alloc just
> > > needs a single one.
> >
> > Yes I know that. But it's pretty theoretical IMO (and I could equally
> > describe a theoretical situation where increased fragmentation in higher
> > order slabs will result in worse TLB coverage).
> 
> Theoretical only for low sizes of memory. If you have terabytes of memory
> then this becomes significant in a pretty fast way.

I don't really buy that as a general statement with no other qualifiers.
If the huge system has a correspondingly increased number of slab
objects, then the potential win is much smaller as system sizes increases.
Say if you have a 1GB RAM system, with 128 2MB TLBs, and suppose you have
a slab that takes 25% of the RAM. Then if you optimally pack the slab for
TLB access of those objects in a random pattern, then you can get 100%
TLB hit for a given random access. And 25% in the case of random allocations.

In a 1TB RAM system, you have ~0.1% chance of TLB hit in the optimally packed
case and ~0.025% chance of hit in the random case. So in that case it is a
much smaller (negligable) possible gain from packing.

And note that we're talking about best possible packing scenario (ie. 2MB
pages vs 4K pages). The standard SLUB tune would not get anywhere near that.

The thing IMO you forget with all these doomsday scenarios about SGI's peta
scale systems is that no matter what you do, you can't avoid the fact that
computing is about locality. Even if you totally take the TLB out of the
equation, you still have the small detail of other caches. Code that jumps
all over that 1024 TB of memory with no locality is going to suck regardless
of what the kernel ever does, due to physical limitations of hardware.

Anyway, this is trivial for SLQB to tune this on those systems that really
care, giving SLUB no advantage. So we needn't really get sidetracked with
this in the context of SLQB.

 
> > > It has lists of free objects that are bound to a particular page. That
> > > simplifies numa handling since all the objects in a "queue" (or page) have
> > > the same NUMA characteristics.
> >
> > The same can be said of SLQB and SLAB as well.
> 
> Sorry not at all. SLAB and SLQB queue objects from different pages in the
> same queue.

The last sentence is what I was replying to. Ie. "simplification of
numa handling" does not follow from the SLUB implementation of per-page
freelists.

 
> > > was assigned to a processor. Memory wastage may only occur because
> > > each processor needs to have a separate page from which to allocate. SLAB
> > > like designs needs to put a large number of objects in queues which may
> > > keep a number of pages in the allocated pages pool although all objects
> > > are unused. That does not occur with slub.
> >
> > That's wrong. SLUB keeps completely free pages on its partial lists, and
> > also IIRC can keep free pages pinned in the per-cpu page. I have actually
> > seen SLQB use less memory than SLUB in some situations for this reason.
> 
> As I sad it pins a single page in the per cpu page and uses that in a way
> that you call a queue and I call a freelist.

And you found you have to increase the size of your pages because you
need bigger queues. (must we argue semantics? it is a list of free
objects)


> SLUB keeps a few pages on the partial list right now because it tries to
> avoid trips to the page allocator (which is quite slow). These could be
> eliminated if the page allocator would work effectively. However that
> number is a per node limit.

This is the practical vs theoretical I'm talking about.


> SLAB and SLUB can have large quantities of objects in their queues that
> each can keep a single page out of circulation if its the last
> object in that page. This is per queue thing and you have at least two

And if that were a problem, SLQB can easily be runtime tuned to keep no
objects in its object lists. But as I said, queueing is good, so why
would anybody want to get rid of it?


> queues per cpu. SLAB has queues per cpu, per pair of cpu, per node and per
> alien node for each node. That can pin quite a number of pages on large
> systems. Note that SLAB has one per cpu whereas you have already 2 per
> cpu? In SMP configurations this may mean that SLQB has more queues than
> SLAB.

Again, this doesn't really go anywhere while we disagree on the
fundamental goodliness of queueing. This is just describing the
implementation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
