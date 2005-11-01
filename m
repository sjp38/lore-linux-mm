Date: Tue, 1 Nov 2005 00:59:41 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
In-Reply-To: <4366A8D1.7020507@yahoo.com.au>
Message-ID: <Pine.LNX.4.58.0510312333240.29390@skynet>
References: <20051030183354.22266.42795.sendpatchset@skynet.csn.ul.ie><20051031055725.GA3820@w-mikek2.ibm.com><4365BBC4.2090906@yahoo.com.au>
 <20051030235440.6938a0e9.akpm@osdl.org> <27700000.1130769270@[10.10.2.4]>
 <4366A8D1.7020507@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tue, 1 Nov 2005, Nick Piggin wrote:

> Martin J. Bligh wrote:
>
> > > We think that Mel's patches will allow us to reintroduce Rohit's
> > > optimisation.
> >
> >
> > ... frankly, it happens without Rohit's patch as well (under more stress).
> > If we want a OS that is robust, and supports higher order allocations,
> > we need to start caring about fragmentations. Not just for large pages,
> > and hotplug, but also for more common things like jumbo GigE frames,
> > CIFS, various device drivers, kernel stacks > 4K etc.
>
> But it doesn't seem to be a great problem right now, apart from hotplug
> and hugepages. Some jumbo GigE drivers use higher order allocations, but
> I think there are moves to get away from that (e1000, for example).
>

GigE drivers and any other subsystem will not use higher order allocations
if they know the underlying allocator is not going to satisfy the
request. These patches are the starting point for properly supporting
large allocations. I will admit that this set of patches is not going to
solve the whole problem, but it is a start that can be built upon.

> > To me, the question is "do we support higher order allocations, or not?".
> > Pretending we do, making a half-assed job of it, and then it not working
> > well under pressure is not helping anyone. I'm told, for instance, that
> > AMD64 requires > 4K stacks - that's pretty fundamental, as just one
>
> And i386 had required 8K stacks for a long long time too.
>
> > instance. I'd rather make Linux pretty bulletproof - the added feature
> > stuff is just a bonus that comes for free with that.
> >
>
> But this doesn't exactly make Linux bulletproof, AFAIKS it doesn't work
> well on small memory systems, and it can still get fragmented and not work.

Small memory systems are unlikely to care about satisfying large
allocations. These patches should not be adversely affecting small memory
systems but it is likely that a smaller value of MAX_ORDER would have to
be used to help with fragmentation.

You are right that we can still get fragmented. To prevent all
fragmentation would require more work but these patches would still be the
starting point. It makes sense to start with this patchset now and move on
the the more complex stuff later. If these patches are in, we could later
do stuff like;

o Configurable option that controls how strict fallback is. In a situation
  where we absolutely do not want to fragment, do not allow kernel
  allocations to fallback to EasyRclm zones. Instead, teach kswapd to
  reclaim pages from the Fallback and KernNoRclm areas.

o Configurable option that gets kswapd to keep the KernNoRclm, KernRclm
  and Fallback areas free of EasyRclm pages. This would prevent awkward
  kernel pages ending up in the wrong areas at the cost of more work for
  kswapd

o Linear scan memory to remove contiguous groups of large pages to satisfy
  larger allocations. The usemap gives hints to what regions are worth
  trying to reclaim. I have a set of patches that do something like this
  and it was able to satisfy large allocations reliably, but they are slow
  right now and need a lot of work.

All these ideas need a mechanism like this set of patches to group related
pages together. This set of patches still help fragmentation now, although
not in a 100% reliable fashion. My desktop which is running a kernel
patched with these patches has been running for 33 hours and managed to
allocate 80 order-10 blocks from ZONE_NORMAL which is about 42% of the
zone while xmms, X, konqueror and a pile of terminals were running. That
is pretty decent, even if it's not perfect.

With this approach, an easyrclm region can be reclaimed to help satisfy a
large allocation. This would be harder to do with a zone-based approach.
Obviously, stealing easyrclm pages to satisfy a high order allocation
could end up fragmenting the system given enough time. This worst-case
scenario would occur if high order allocations were in heavy demand, they
were kernel allocations *and* they were long lived.

If we find in the future that this worst-case scenario occurs frequently,
the easiest solution would be to use __GFP_KERNRCLM for high order short
lived allocations rather than it's current usage for caches like icaches.
This would set up areas that tend to have high order free blocks in them.

> IMO in order to make Linux bulletproof, just have fallbacks for anything
> greater than about order 2 allocations.
>

What sort of fallbacks? Private pools of pages of the larger order for
subsystems that need large pages is hardly desirable.

> From what I have seen, by far our biggest problems in the mm are due to
> page reclaim, and these patches will make our reclaim behaviour more
> complex I think.
>

This patchset does not touch reclaim at all. The lists that this patch
really affects is the zone freelists, not the LRU lists that page reclaim
are dealing with. It is only later when we want to try and guarantee
large-order allocations that we will have to change page reclaim.

-- 
Mel Gorman
Part-time Phd Student                          Java Applications Developer
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
