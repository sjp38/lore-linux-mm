Date: Fri, 12 Sep 2008 22:30:03 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH 0/4] Reclaim page capture v3
Message-ID: <20080912212937.GA7827@brain>
References: <1220610002-18415-1-git-send-email-apw@shadowen.org> <200809091331.43671.nickpiggin@yahoo.com.au> <20080909163559.GD21687@brain> <200809101319.01701.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200809101319.01701.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 10, 2008 at 01:19:01PM +1000, Nick Piggin wrote:
> On Wednesday 10 September 2008 02:35, Andy Whitcroft wrote:
> > On Tue, Sep 09, 2008 at 01:31:43PM +1000, Nick Piggin wrote:
> 
> > > Yeah, but blocking the whole pool gives a *much* bigger chance to
> > > coalesce freed pages. And I'm not just talking about massive order-10
> > > allocations or something where you have the targetted reclaim which
> > > improves chances of getting a free page within that range, but also for
> > > order-1/2/3 pages that might be more commonly used in normal kernel
> > > workloads but can still have a fairly high latency to succeed if there is
> > > a lot of other parallel allocation happening.
> >
> > Yes in isolation blocking the whole pool would give us a higher chance
> > of coalescing higher order pages.  The problem here is that we cannot
> > block the whole pool, we have to allow allocations for reclaim.  If we
> > have those occuring we risk loss of pages from the areas we are trying
> > to reclaim.
> 
> Allocations from reclaim should be pretty rare, I think you're too
> worried about them.

They are certainly there, particularly with journalled filesystems in
the mix.  But although I do worry about them, my solution has been to
allow all allocations in parallel with reclaim so they fall into the
same bucket.

> Actually, if you have queueing, you can do a simple form of capture
> just in the targetted reclaim path without all the stuff added to page
> alloc etc. Because you can hold off from freeing the targetted pages
> into the page allocator until you have built up a large number of them.
> That way, they won't be subject to recursive allocations and they will
> coalesce in the allocator; the queueing will ensure they don't get
> stolen or broken into smaller pages under us. Yes I really think queueing
> (perhaps with a much simplified form of capture) is the way to go.

It almost feels as if you think these patches do much more than they
actually do.  The primary source of captured pages is through collection
of pages as we complete synchronous targetted reclaim on them.  However we
do also collect and merge pages which are already free, and those which
are freed from outside the reclaim during the period of the capture.

>From your description I am getting the impression that your proposal is
that there be a queue on the allocator plus capture only for pages we
release during targetted reclaim.  We would then release our list and
try to allocate from the buddy.  Relying on buddy to coelesce them, and
then allocate from there.  The queue protects us from any stealing.

In the development and testing of capture, we actually started out with
simple version of capture, without the additional ability to collect the
already free pages, and those which free during capture.  (It is these
parts which bring the apparent complexity of change to page_alloc.c and I
am assuming is the bit you dislike particularly.)  Testing on this simple
version showed the chances of actually finding areas of the size requested
were close to zero and capture statistically worthless.  That seems to
indicate that for queue+simple capture to have any statistical chance
of improving things all allocations would need to be stopped for the
entire period of the capture.  Even if we assume reclaim allocations
never occur (which we cannot queue), that still leaves us with a singly
threaded allocator once reclaim starts.  Bearing in mind that for very
high order pages that would be periods equivalent to the time it takes
to write thousands of base pages.  That seems unreasonable at best.

> > > > I think we have our wires crossed here.  I was saying it would seem
> > > > unfair to block the allocator from giving out order-0 pages while we
> > > > are struggling to get an order-10 page for one process.  Having a queue
> > > > would seem to generate such behaviour.  What I am trying to achieve
> > > > with capture is to push areas likely to return us a page of the
> > > > requested size out of use, while we try and reclaim it without blocking
> > > > the rest of the allocator.
> > >
> > > We don't have our wires crossed. I just don't agree that it is unfair.
> > > It might be unfair to allow order-10 allocations at the same *rate* at
> > > order-0 allocations, which is why you could allow some priority in the
> > > queue. But when you decide you want to satisfy an order-10 allocation,
> > > do you want the other guys potentially mopping up your coalescing
> > > candidates? (and right, for targetted reclaim, maybe this is less of a
> > > problem, but I'm also thinking about a general solution for all orders
> > > of pages not just hugepages).
> >
> > When I am attempting to satisfy an order-10 allocation I clearly want to
> > protect that order-10 area from use for allocation to other allocators.
> > And that is the key thrust of the capture stuff, that is what it does.
> > Capture puts the pages in areas under targetted reclaim out of the
> > allocator during the reclaim pass.  Protecting those areas from any
> > parallel parallel allocators, either regular or PF_MEMALLOC; but only
> > protecting those areas.
> 
> And I've shown that by a principle of fairness, you don't need to protect
> just one area, but you can hold off reclaim on all areas, which should
> greatly increase your chances of getting a hugepage, and will allow you
> to do so fairly.
> 
> 
> > I think we have differing views on what a queuing alone can deliver.
> > Given that the allocator will have to allow allocations made during reclaim
> > in parallel with reclaim for higher orders it does not seem sufficient
> > to have a 'fair queue' alone.  That will not stop the smaller necessary
> > allocations from stealing our partial free buddies, allocations that we
> > know are not always short lived.  [continued below]
> 
> Queueing is a general and natural step which (hopefully) benefits everyone,
> so I think it should be tried before capture (which introduces new complexity
> solely for big allocations).

To be completely honest here, I do not think I have yet figured out what
form queueing you really envisage here.  Its name implies an ordering of
allocations based on request 'start' time.  The discussions in previous
emails imply more of a balancing of rates of allocations, at least in
terms of fairness.  Could you perhaps flesh out your queue idea here so
that we are arguing against the same object?

Some details of that would help to understand the version of fairness
you are trying to generate as well.  As there are a number of often
conflicting definitions of fairness which are valid in their own senses.
For example I could state that it is 'unfair that an allocator wanting
an order 10 page would stop me getting a single order 0 page', and yet
also state 'it is unfair that I cannot allocate a single order 10 page,
when you have allocated 1024 order-0 pages' both are reasonable
statements and yet very likely to be conflicting in implementation.

> > > > Sure you would be able to make some kind of more flexible decisions,
> > > > but that still seems like a heavy handed approach.  You are important
> > > > enough to takes pages (possibly from our mostly free high order page)
> > > > or not.
> > >
> > > I don't understand the thought process that leads you to these
> > > assertions. Where do you get your idea of fairness or importance?
> > >
> > > I would say that allowing 2^N order-0 allocations for every order-N
> > > allocations if both allocators are in a tight loop (and reserves are low,
> > > ie. reclaim is required) is a completely reasonable starting point for
> > > fairness. Do you disagree with that? How is it less fair than your
> > > approach?
> >
> > What I was trying to convey here is that given the limitation that we need
> > to allow allocation from within reclaim for reclaim to complete, that
> > even stopping other small allocations for the period of the high order
> > allocation is insufficient as those reclaim allocations are potentially
> > as damaging.  That even with a priority queue on the allocator you would
> > need something to prevent allocations falling within an area under reclaim
> > without preventing allocations completely, it is this problem that I
> > am trying to solve.  Trying to get the most beneficial result from the
> > effort put in during reclaim.  I actually think your idea of a priority
> > queue and what capture is trying to do are othogonal.
> 
> Yes they are orthogonal, but I would like to see if we can do without
> page capture. I'm not saying the theory or practice of it is wrong.
> 
> 
> > The current model uses direct reclaim as the 'fairness control'.  If you
> > are allocating a lot and the pool runs dry, you enter reclaim and are
> > penalised for your greed.  "If you want something big, you work to get it."
> > Someone entering reclaim for higher order is independant of lower order
> > allocators, and may even take pages from the pool without reclaim.
> > What you are proposing with the priority queue seems to be a replacement
> > for that.
> 
> For order-2,3 etc allocations that can be commonly used by the kernel but
> are not always in large supply, that fairness model doesn't really work.
> You can work to free things, then have another process allocate them, then
> exit direct reclaim to find none left etc.
>
> Even for order-0 pages there is a problem in theory (although statistically
> it probably evens out much better).

Yes that is entirely true.  As it happens we only apply capture here to
orders above COSTLY_ORDER in line with the kernels assumption that
statistically those orders are released during reclaim 'relativly
easily'.  If that assumption is wrong then it would seem logical to
apply capture down to order 0.

> > > Even for hugepages: if, with your capture patches, if process 0 comes in
> > > and does all this reclaim work and has nearly freed up some linear region
> > > of memory; then do you think it is reasonable if process-1 happens to
> > > come in and get lucky and find an subsequently coalesced hugepage and
> > > allocate it?
> >
> > Are you saying of capture fails to obtain the high order page, so all
> > the reclaim effort was wasted for that process, but then a subsequent
> > reclaimer comes in and reclaims a few pages, gets the whole page and
> > effectivly steals the work?  It is unfortuanate for sure.  Is it better
> > that the work was not completely wasted, yes.  By containing and protecting
> > the partial results we work to reduce the likely hood of this happening.
> 
> Yes.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
