Date: Mon, 8 Sep 2008 17:41:53 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH 0/4] Reclaim page capture v3
Message-ID: <20080908164153.GC9190@brain>
References: <1220610002-18415-1-git-send-email-apw@shadowen.org> <200809081608.03793.nickpiggin@yahoo.com.au> <20080908114423.GE18694@brain> <200809082359.55288.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200809082359.55288.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 08, 2008 at 11:59:54PM +1000, Nick Piggin wrote:
> On Monday 08 September 2008 21:44, Andy Whitcroft wrote:
> > On Mon, Sep 08, 2008 at 04:08:03PM +1000, Nick Piggin wrote:
> > > On Friday 05 September 2008 20:19, Andy Whitcroft wrote:
> 
> > > > 		Absolute	Effective
> > > > x86-64		2.48%		 4.58%
> > > > powerpc		5.55%		25.22%
> > >
> > > These are the numbers for the improvement of hugepage allocation success?
> > > Then what do you mean by absolute and effective?
> >
> > The absolute improvement is the literal change in success percentage,
> > the literal percentage of all memory which may be allocated as huge
> > pages.  The effective improvement is percentage of the baseline success
> > rates that this change represents; for the powerpc results we get some
> > 20% of memory allocatable without the patches, and 25% with, 25% more
> > pages are allocatable with the patches.
> 
> OK.
> 
> > > What sort of constant stream of high order allocations are you talking
> > > about? In what "real" situations are you seeing higher order page
> > > allocation failures, and in those cases, how much do these patches help?
> >
> > The test case simulates a constant demand for huge pages, at various
> > rates.  This is intended to replicate the scenario where a system is
> > used with mixed small page and huge page applications, with a dynamic
> > huge page pool.  Particularly we are examining the effect of starting a
> > very large huge page job on a busy system.  Obviously starting hugepage
> > applications depends on hugepage availability as they are not swappable.
> > This test was chosen because it both tests the initial large page demand
> > and then pushes the system to the limit.
> 
> So... what does the non-simulation version (ie. the real app) say?

In the common use model, use of huge pages is all or nothing.  Either
there are sufficient pages allocatable at application start time or there
are not.  As huge pages are not swappable once allocated they stay there.
Applications either start using huge pages or they fallback to small pages
and continue.  This makes the real metric, how often does the customer get
annoyed becuase their application has fallen back to small pages and is
slow, or how often does their database fail to start.  It is very hard to
directly measure that and thus to get a comparitive figure.  Any attempt
to replicate that seems as necessarly artificial as the current test.

> > > I must say I don't really like this approach. IMO it might be better to
> > > put some sort of queue in the page allocator, so if memory becomes low,
> > > then processes will start queueing up and not be allowed to jump the
> > > queue and steal memory that has been freed by hard work of a direct
> > > reclaimer. That would improve a lot of fairness problems as well as
> > > improve coalescing for higher order allocations without introducing this
> > > capture stuff.
> >
> > The problem with queuing all allocators is two fold.  Firstly allocations
> > are obviously required for reclaim and those would have to be exempt
> > from the queue, and these are as likely to prevent coelesce of pages
> > as any other.
> 
> *Much* less likely, actually. Because there should be very little allocation
> required for reclaim (only dirty pages, and only when backed by filesystems
> that do silly things like not ensuring their own reserves before allowing
> the page to be dirtied).

Well yes and no.  A lot of filesystems do do such stupid things.
Allocating things like journal pages which have relativly long lives
during reclaim.  We have seen these getting placed into the memory we
have just freed and preventing higher order coelesce.

> Also, your scheme still doesn't avoid allocation for reclaim so I don't see
> how you can use that as a point against queueing but not capturing!

Obviously we cannot prevent allocations during reclaim.  But we can avoid
those allocations falling within the captured range.  All pages under
capture are marked.  Any page returning to the allocator that merges with a
buddy under capture, or that is a buddy under capture are kept separatly.
Such that any allocations from within reclaim will necessarily take
pages from elsewhere in the pool.  The key thing about capture is that it
effectivly marks ranges of pages out of use for allocations for the period
of the reclaim, so we have a number of small ranges blocked out, not the
whole pool.  This allows parallel allocations (reclaim and otherwise)
to succeed against the reserves (refilled by kswapd etc), whilst marking
the pages under capture out and preventing them from being used.

> > Secondly where a very large allocation is requested 
> > all allocators would be held while reclaim at that size is performed,
> > majorly increasing latency for those allocations.  Reclaim for an order
> > 0 page may target of the order of 32 pages, whereas reclaim for x86_64
> > hugepages is 1024 pages minimum.  It would be grosly unfair for a single
> > large allocation to hold up normal allocations.
> 
> I don't see why it should be unfair to allow a process to allocate 1024
> order-0 pages ahead of one order-10 page (actually, yes the order 10 page
> is I guess somewhat more valueable than the same number of fragmented
> pages, but you see where I'm coming from).

I think we have our wires crossed here.  I was saying it would seem
unfair to block the allocator from giving out order-0 pages while we are
struggling to get an order-10 page for one process.  Having a queue
would seem to generate such behaviour.  What I am trying to achieve with
capture is to push areas likely to return us a page of the requested
size out of use, while we try and reclaim it without blocking the rest
of the allocator.

> At least with queueing you are basing the idea on *some* reasonable policy,
> rather than purely random "whoever happens to take this lock at the right
> time will win" strategy, which might I add, can even be much more unfair
> than you might say queueing is.
> 
> However, queueing would still be able to allow some flexibility in priority.
> For example:
> 
> if (must_queue) {
>   if (queue_head_prio == 0)
>     join_queue(1<<order);
>   else {
>     queue_head_prio -= 1<<order;
>     skip_queue();
>   }
> }

Sure you would be able to make some kind of more flexible decisions, but
that still seems like a heavy handed approach.  You are important enough
to takes pages (possibly from our mostly free high order page) or not. 

In a perfect world we would be able to know in advance that an order-N
region would definatly come free if reclaimed and allocate that preemptivly
to the requestor, apply reclaim to it, and then actually allocate the page.

Obviously the world is not quite that perfect, but we are trying to
follow that model with capture.  Picking areas of the appropriate order,
applying reclaim to just those areas, and preventing any freed pages
getting back into the general population.  This behaviour should mark
the minimum memory out of use as possible.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
