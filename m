Date: Thu, 23 Aug 2007 05:38:27 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC 2/9] Use NOMEMALLOC reclaim to allow reclaim if PF_MEMALLOC is set
Message-ID: <20070823033826.GE18788@wotan.suse.de>
References: <20070814153021.446917377@sgi.com> <20070814153501.305923060@sgi.com> <20070818071035.GA4667@ucw.cz> <Pine.LNX.4.64.0708201158270.28863@schroedinger.engr.sgi.com> <1187641056.5337.32.camel@lappy> <Pine.LNX.4.64.0708201323590.30053@schroedinger.engr.sgi.com> <1187644449.5337.48.camel@lappy> <20070821003922.GD8414@wotan.suse.de> <1187705235.6114.247.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1187705235.6114.247.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 21, 2007 at 04:07:15PM +0200, Peter Zijlstra wrote:
> On Tue, 2007-08-21 at 02:39 +0200, Nick Piggin wrote:
> > 
> > Although interestingly, we are not guaranteed to have enough memory to
> > completely initialise writeout of a single page.
> 
> Yes, that is due to the unbounded nature of direct reclaim, no?
 
Even writing out a single page to a plain old block backed filesystem
can take a fair chunk of memory. I'm not really sure how problematic
this is with a "real" filesystem, but even with something pretty simple,
you might have to do block allocation, which itself might have to do
indirect block allocation (which itself can be 3 or 4 levels), all of
which have to actually update block bitmaps (which themselves may be
many pages big). Then you also may have to even just allocate the
buffer_head structure itself. And that's just to write out a single
buffer in the page (on a 64K page system, there might be 64 of these).

Unbounded direct reclaim surely doesn't help either :P


> I've been meaning to write some patches to address this problem in a way
> that does not introduce the hard wall Linus objects to. If only I had
> this extra day in the week :-/

For this problem I think the right way to go is to ensure everything
is allocated to do writeout at page-dirty-time. This is what fsblock
does (or at least _allows_ for: filesystems that do journalling or
delayed allocation etc. themselves will have to ensure they have
sufficient preallocations to do the manipulations they need at writeout
time).

But again, on the pragmatic side, the best behaviour I think is just
to have writeouts not allocate from reserves without first trying to
reclaim some clean memory, and also limit the number of users of the
reserve. We want this anyway, right, because we don't want regular
reclaim to start causing things like atomic allocation failures when
load goes up.


> And then there is the deadlock in add_to_swap() that I still have to
> look into, I hope it can eventually be solved using reserve based
> allocation.

Yes it should have a reserve. It wouldn't be hard, all you need is
enough memory to be able to swap out a single page I would think (ie.
one preload's worth).

 
> > The buffer layer doesn't require disk blocks to be allocated at page
> > dirty-time. Allocating disk blocks can require complex filesystem operations
> > and readin of buffer cache pages. The buffer_head structures themselves may
> > not even be present and must be allocated :P
> > 
> > In _practice_, this isn't such a problem because we have dirty limits, and
> > we're almost guaranteed to have some clean pages to be reclaimed. In this
> > same way, networked filesystems are not a problem in practice. However
> > network swap, because there is no dirty limits on swap, can actually see
> > the deadlock problems.
> 
> The main problem with networked swap is not so much sending out the
> pages (this has similar problems like the filesystems but is all bounded
> in its memory use).
> 
> The biggest issue is receiving the completion notification. Network
> needs to fall back to a state where it does not blindly consumes memory
> or drops _all_ packets. An intermediate state is required, one where we
> can receive and inspect incoming packets but commit to very few.
 
Yes, I understand this is the main problem. But it is not _helped_ by
the fact that reclaim reserves include the atomic allocation reserves.
I haven't run this problem for a long time, but I'd venture to guess the
_main_ reason the deadlock is hit is not because of networking allocating
a lot of other irrelevant data, but because of reclaim using up most of
the atomic allocation reserves.

And this observation is not tied to recurisve reclaim: if we somehow had
a reserve for atomic allocations that was aside from the reclaim reserve,
I think such a system would be practically free of deadlock for more
anonymous-intensive workloads too.


> In order to create such a network state and for it to be stable, a
> certain amount of memory needs to be available and an external trigger
> is needed to enter and leave this state - currently provided by there
> being more memory available than needed or not.

I do appreciate the deadlock and solution.  I'm puzzled by your last line
though? Currently we do not provide the required reserves in the network
layer, *at all*, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
