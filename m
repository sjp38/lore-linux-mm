Date: Tue, 9 Sep 2008 17:35:59 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH 0/4] Reclaim page capture v3
Message-ID: <20080909163559.GD21687@brain>
References: <1220610002-18415-1-git-send-email-apw@shadowen.org> <200809082359.55288.nickpiggin@yahoo.com.au> <20080908164153.GC9190@brain> <200809091331.43671.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200809091331.43671.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 09, 2008 at 01:31:43PM +1000, Nick Piggin wrote:
> On Tuesday 09 September 2008 02:41, Andy Whitcroft wrote:
> > On Mon, Sep 08, 2008 at 11:59:54PM +1000, Nick Piggin wrote:
> 
> > > So... what does the non-simulation version (ie. the real app) say?
> >
> > In the common use model, use of huge pages is all or nothing.  Either
> > there are sufficient pages allocatable at application start time or there
> > are not.  As huge pages are not swappable once allocated they stay there.
> > Applications either start using huge pages or they fallback to small pages
> > and continue.  This makes the real metric, how often does the customer get
> > annoyed becuase their application has fallen back to small pages and is
> > slow, or how often does their database fail to start.  It is very hard to
> > directly measure that and thus to get a comparitive figure.  Any attempt
> > to replicate that seems as necessarly artificial as the current test.
> 
> But you have customers telling you they're getting annoyed because of
> this? Or you have your own "realistic" workloads that allocate hugepages
> on demand (OK, when I say realistic, something like specjbb or whatever
> is obviously a reasonable macrobenchmark even if it isn't strictly
> realistics).

We have customers complaining about usability of hugepages.  They are
keen to obtain the performance benefits from their use, but put off by
the difficulty in managing systems with them enabled.  That has led to
series of changes to improve availability and managability of hugepages,
including targetted reclaim, anti-fragmentation, and the dynamic pool.
We obviously test hugepages with a series of benchmarks but generally in
controlled environments where allocation of hugepages is guarenteed, to
understand the performance benefits of their use.  This is an acceptable
configuration for hugepage diehards, but limits their utility to the
wider community.  The focus of this work is availability of hugepages and
how that applies to managability.  A common use model for big systems
is batch oriented running a mix of jobs.  For this to work reliably we
need to move pages into and out of the hugepage pool on a regular basis.
For this we need effective high order reclaim.

> > > *Much* less likely, actually. Because there should be very little
> > > allocation required for reclaim (only dirty pages, and only when backed
> > > by filesystems that do silly things like not ensuring their own reserves
> > > before allowing the page to be dirtied).
> >
> > Well yes and no.  A lot of filesystems do do such stupid things.
> > Allocating things like journal pages which have relativly long lives
> > during reclaim.  We have seen these getting placed into the memory we
> > have just freed and preventing higher order coelesce.
> 
> They shouldn't, because that's sad and deadlocky. But yes I agree it
> happens sometimes.
> 
> > > Also, your scheme still doesn't avoid allocation for reclaim so I don't
> > > see how you can use that as a point against queueing but not capturing!
> >
> > Obviously we cannot prevent allocations during reclaim.  But we can avoid
> > those allocations falling within the captured range.  All pages under
> > capture are marked.  Any page returning to the allocator that merges with a
> > buddy under capture, or that is a buddy under capture are kept separatly.
> > Such that any allocations from within reclaim will necessarily take
> > pages from elsewhere in the pool.  The key thing about capture is that it
> > effectivly marks ranges of pages out of use for allocations for the period
> > of the reclaim, so we have a number of small ranges blocked out, not the
> > whole pool.  This allows parallel allocations (reclaim and otherwise)
> > to succeed against the reserves (refilled by kswapd etc), whilst marking
> > the pages under capture out and preventing them from being used.
> 
> Yeah, but blocking the whole pool gives a *much* bigger chance to coalesce
> freed pages. And I'm not just talking about massive order-10 allocations
> or something where you have the targetted reclaim which improves chances of
> getting a free page within that range, but also for order-1/2/3 pages
> that might be more commonly used in normal kernel workloads but can still
> have a fairly high latency to succeed if there is a lot of other parallel
> allocation happening.

Yes in isolation blocking the whole pool would give us a higher chance
of coalescing higher order pages.  The problem here is that we cannot
block the whole pool, we have to allow allocations for reclaim.  If we
have those occuring we risk loss of pages from the areas we are trying
to reclaim.

> > > I don't see why it should be unfair to allow a process to allocate 1024
> > > order-0 pages ahead of one order-10 page (actually, yes the order 10 page
> > > is I guess somewhat more valueable than the same number of fragmented
> > > pages, but you see where I'm coming from).
> >
> > I think we have our wires crossed here.  I was saying it would seem
> > unfair to block the allocator from giving out order-0 pages while we are
> > struggling to get an order-10 page for one process.  Having a queue
> > would seem to generate such behaviour.  What I am trying to achieve with
> > capture is to push areas likely to return us a page of the requested
> > size out of use, while we try and reclaim it without blocking the rest
> > of the allocator.
> 
> We don't have our wires crossed. I just don't agree that it is unfair.
> It might be unfair to allow order-10 allocations at the same *rate* at
> order-0 allocations, which is why you could allow some priority in the
> queue. But when you decide you want to satisfy an order-10 allocation,
> do you want the other guys potentially mopping up your coalescing
> candidates? (and right, for targetted reclaim, maybe this is less of a
> problem, but I'm also thinking about a general solution for all orders
> of pages not just hugepages).

When I am attempting to satisfy an order-10 allocation I clearly want to
protect that order-10 area from use for allocation to other allocators.
And that is the key thrust of the capture stuff, that is what it does.
Capture puts the pages in areas under targetted reclaim out of the
allocator during the reclaim pass.  Protecting those areas from any
parallel parallel allocators, either regular or PF_MEMALLOC; but only
protecting those areas.

I think we have differing views on what a queuing alone can deliver.
Given that the allocator will have to allow allocations made during reclaim
in parallel with reclaim for higher orders it does not seem sufficient
to have a 'fair queue' alone.  That will not stop the smaller necessary
allocations from stealing our partial free buddies, allocations that we
know are not always short lived.  [continued below]

> > > At least with queueing you are basing the idea on *some* reasonable
> > > policy, rather than purely random "whoever happens to take this lock at
> > > the right time will win" strategy, which might I add, can even be much
> > > more unfair than you might say queueing is.
> > >
> > > However, queueing would still be able to allow some flexibility in
> > > priority. For example:
> > >
> > > if (must_queue) {
> > >   if (queue_head_prio == 0)
> > >     join_queue(1<<order);
> > >   else {
> > >     queue_head_prio -= 1<<order;
> > >     skip_queue();
> > >   }
> > > }
> >
> > Sure you would be able to make some kind of more flexible decisions, but
> > that still seems like a heavy handed approach.  You are important enough
> > to takes pages (possibly from our mostly free high order page) or not.
> 
> I don't understand the thought process that leads you to these assertions. 
> Where do you get your idea of fairness or importance?
> 
> I would say that allowing 2^N order-0 allocations for every order-N
> allocations if both allocators are in a tight loop (and reserves are low,
> ie. reclaim is required) is a completely reasonable starting point for
> fairness. Do you disagree with that? How is it less fair than your
> approach?

What I was trying to convey here is that given the limitation that we need
to allow allocation from within reclaim for reclaim to complete, that
even stopping other small allocations for the period of the high order
allocation is insufficient as those reclaim allocations are potentially
as damaging.  That even with a priority queue on the allocator you would
need something to prevent allocations falling within an area under reclaim
without preventing allocations completely, it is this problem that I
am trying to solve.  Trying to get the most beneficial result from the
effort put in during reclaim.  I actually think your idea of a priority
queue and what capture is trying to do are othogonal.

The current model uses direct reclaim as the 'fairness control'.  If you
are allocating a lot and the pool runs dry, you enter reclaim and are
penalised for your greed.  "If you want something big, you work to get it."
Someone entering reclaim for higher order is independant of lower order
allocators, and may even take pages from the pool without reclaim.
What you are proposing with the priority queue seems to be a replacement
for that.

> > In a perfect world we would be able to know in advance that an order-N
> > region would definatly come free if reclaimed and allocate that preemptivly
> > to the requestor, apply reclaim to it, and then actually allocate the page.
> 
> But with my queueing you get effectively the same thing without having an
> oracle. Because you will wait for *any* order-N region to become free.
> 
> The "tradeoff" is blocking other allocators. But IMO that is actually a
> good thing because that equates to a general fairness model in our allocator
> for all allocation types in place of the existing, fairly random game of
> chance (especially for order-2/3+) that we have now.
> 
> Even for hugepages: if, with your capture patches, if process 0 comes in
> and does all this reclaim work and has nearly freed up some linear region
> of memory; then do you think it is reasonable if process-1 happens to come
> in and get lucky and find an subsequently coalesced hugepage and allocate
> it?

Are you saying of capture fails to obtain the high order page, so all
the reclaim effort was wasted for that process, but then a subsequent
reclaimer comes in and reclaims a few pages, gets the whole page and
effectivly steals the work?  It is unfortuanate for sure.  Is it better
that the work was not completely wasted, yes.  By containing and protecting
the partial results we work to reduce the likely hood of this happening.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
