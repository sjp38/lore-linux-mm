Date: Fri, 24 Aug 2007 06:00:04 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC 2/9] Use NOMEMALLOC reclaim to allow reclaim if PF_MEMALLOC is set
Message-ID: <20070824040003.GF6989@wotan.suse.de>
References: <20070814153501.305923060@sgi.com> <20070818071035.GA4667@ucw.cz> <Pine.LNX.4.64.0708201158270.28863@schroedinger.engr.sgi.com> <1187641056.5337.32.camel@lappy> <Pine.LNX.4.64.0708201323590.30053@schroedinger.engr.sgi.com> <1187644449.5337.48.camel@lappy> <20070821003922.GD8414@wotan.suse.de> <1187705235.6114.247.camel@twins> <20070823033826.GE18788@wotan.suse.de> <1187861208.6114.342.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1187861208.6114.342.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Nikita Danilov <nikita@clusterfs.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 23, 2007 at 11:26:48AM +0200, Peter Zijlstra wrote:
> On Thu, 2007-08-23 at 05:38 +0200, Nick Piggin wrote:
> > On Tue, Aug 21, 2007 at 04:07:15PM +0200, Peter Zijlstra wrote:
> > > On Tue, 2007-08-21 at 02:39 +0200, Nick Piggin wrote:
> > > > 
> > > > Although interestingly, we are not guaranteed to have enough memory to
> > > > completely initialise writeout of a single page.
> > > 
> > > Yes, that is due to the unbounded nature of direct reclaim, no?
> >  
> > Even writing out a single page to a plain old block backed filesystem
> > can take a fair chunk of memory. I'm not really sure how problematic
> > this is with a "real" filesystem, but even with something pretty simple,
> > you might have to do block allocation, which itself might have to do
> > indirect block allocation (which itself can be 3 or 4 levels), all of
> > which have to actually update block bitmaps (which themselves may be
> > many pages big). Then you also may have to even just allocate the
> > buffer_head structure itself. And that's just to write out a single
> > buffer in the page (on a 64K page system, there might be 64 of these).
> 
> Right, nikita once talked me though all that when we talked about
> clustered writeout.
> 
> IIRC filesystems were supposed to keep mempools big enough to do this
> for a single writepage at a time. Not sure its actually done though.
 
It isn't ;) At least I don't think so for the minix-derived ones
I've seen. But no matter, this is going a bit off topic anyway.


> > But again, on the pragmatic side, the best behaviour I think is just
> > to have writeouts not allocate from reserves without first trying to
> > reclaim some clean memory, and also limit the number of users of the
> > reserve. We want this anyway, right, because we don't want regular
> > reclaim to start causing things like atomic allocation failures when
> > load goes up.
> 
> My idea is to extend kswapd, run cpus_per_node instances of kswapd per
> node for each of GFP_KERNEL, GFP_NOFS, GFP_NOIO. (basically 3 kswapds
> per cpu)
> 
> whenever we would hit direct reclaim, add ourselves to a special
> waitqueue corresponding to the type of GFP and kick all the
> corresponding kswapds.

I don't know what this is solving? You don't need to run all reclaim
from kswapd process in order to limit concurrency. Just explicitly
limit it when a process applies for PF_MEMALLOC reserves. I had a
patch to do this at one point, but it never got much testing -- I
think there were other problems iwth a single process able to do
unbounded writeout and such anyway. But yeah, I don't think getting
rid of direct reclaim will do anything magical.

 
> Now Linus' big objection is that all these processes would hit a wall
> and not progress until the watermarks are high again.
> 
> Here is were the 'special' part of the waitqueue comes into order.
> 
> Instead of freeing pages to the page allocator, these kswapds would hand
> out pages to the waiting processes in a round robin fashion. Only if
> there are no more waiting processes left, would the page go to the buddy
> system.

Directly getting back pages (and having more than 1 kswapd per node)
may be things worth exploring at some point. But I don't see how muchi
bearing they have to any deadlock problems.


> > > And then there is the deadlock in add_to_swap() that I still have to
> > > look into, I hope it can eventually be solved using reserve based
> > > allocation.
> > 
> > Yes it should have a reserve. It wouldn't be hard, all you need is
> > enough memory to be able to swap out a single page I would think (ie.
> > one preload's worth).
> 
> Yeah, just need to look at the locking an batching, and ensure it has
> enough preload to survive one batch, once all the locks are dropped it
> can breathe again :-)

I don't think you'd need to do anything remotely fancy ;) Just so long
as it can allocate a swapcache entry for a single page to write out, that
page will be written and eventually reclaimed, along with its radix tree
nodes.  


> > > The biggest issue is receiving the completion notification. Network
> > > needs to fall back to a state where it does not blindly consumes memory
> > > or drops _all_ packets. An intermediate state is required, one where we
> > > can receive and inspect incoming packets but commit to very few.
> >  
> > Yes, I understand this is the main problem. But it is not _helped_ by
> > the fact that reclaim reserves include the atomic allocation reserves.
> > I haven't run this problem for a long time, but I'd venture to guess the
> > _main_ reason the deadlock is hit is not because of networking allocating
> > a lot of other irrelevant data, but because of reclaim using up most of
> > the atomic allocation reserves.
> 
> Ah, interesting notion.
> 
> > And this observation is not tied to recurisve reclaim: if we somehow had
> > a reserve for atomic allocations that was aside from the reclaim reserve,
> > I think such a system would be practically free of deadlock for more
> > anonymous-intensive workloads too.
> 
> One could get quite far, however the scenario of shutting down the
> remote swap server while other network traffic is present will surely
> still deadlock.

I guess it would still have all the same theoretical holes, and some
could surely still be tickled, yes ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
