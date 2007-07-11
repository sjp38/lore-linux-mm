Date: Wed, 11 Jul 2007 14:03:28 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: -mm merge plans -- anti-fragmentation
Message-ID: <20070711130328.GA14807@shadowen.org>
References: <20070710102043.GA20303@skynet.ie> <200707100929.46153.dave.mccracken@oracle.com> <20070710152355.GI8779@wotan.suse.de> <200707101211.46003.dave.mccracken@oracle.com> <20070711025946.GD27475@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070711025946.GD27475@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Dave McCracken <dave.mccracken@oracle.com>, Mel Gorman <mel@skynet.ie>, Andrew Morton <akpm@linux-foundation.org>, kenchen@google.com, jschopp@austin.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, a.p.zijlstra@chello.nl, y-goto@jp.fujitsu.com, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 11, 2007 at 04:59:46AM +0200, Nick Piggin wrote:

> > Yes, these projects have workarounds, because they have to.  But the 
> > workarounds are painful and often require that the user specify in advance 
> > what memory they intend to use for this purpose, something users often have 
> > to learn by trial and error.  Mel's patches would eliminate this barrier to 
> > use of the features.
> > 
> > I don't see Mel's patches as "a fundamental change in direction".  I think 
> > you're overstating the case.  I see it as fixing a deficiency in the design 
> > of the page allocator, and a long overdue fix.
> 
> I would still say that with Mel's patches in, you need to have a fallback
> to order-0 because memory can still get fragemnted. But no Mel's patches
> are not exactly a fundamental change in direction itself, but introducing
> higher order allocations without fallbacks is a change (OK, order 1 or 2
> is used today, and mostly because of the nature of the allocator they're OK
> too, but if we're talking about like 64K+ of contiguous pages).

However much one improves fragmentation the chances of finding a
higher order page is always going to be lower than that of geting
an order-0, there are less of them for a start.  It is pretty much
inevitable that you would want to have a fallback for anything
which is critical for system continuation.  The thrust of the
anti-fragmentation work is not to claim a guarenteed availability but
to expand the range of order over which we find a high probability
of availability.  As you say elsewhere orders 0-2 pretty much work
with buddy even in the face of random allocation, where intution
might indicate it should not.  Simplistic reclaim can find us a page.
Indeed you then find that the kernel uses those sizes in preference
to order-0 for simplicity as they can be pretty much relied on, as
is done with the process kernel stacks.  Much of what is proposed
as uses for this work is an extension of this, using bigger pages
where available for performance or simplicity.  SLUB as an example is
making use of the fact that general availablity of near zero order
is virtually guarenteed.  Obviously as order increases cirtainly
decreases and you have to trade off the ramifications of failure
to allocate against the cost of handling that failure.

Specifically thinking about the pagecache, a fusion of Christoph's
high order pagecache with fsblocks ability to handle discontigious
pages at higher order sounds like it could be a very powerful
solution to both problems, offering contigious pages where available
and working regardless where not.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
