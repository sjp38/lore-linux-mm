Date: Thu, 23 Aug 2007 05:02:38 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
Message-ID: <20070823030238.GD18788@wotan.suse.de>
References: <20070814142103.204771292@sgi.com> <20070815122253.GA15268@wotan.suse.de> <1187183526.6114.45.camel@twins> <20070816032921.GA32197@wotan.suse.de> <1187581894.6114.169.camel@twins> <20070821002830.GB8414@wotan.suse.de> <1187710167.6114.258.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1187710167.6114.258.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 21, 2007 at 05:29:27PM +0200, Peter Zijlstra wrote:
> [ now with CCs ]
> 
> On Tue, 2007-08-21 at 02:28 +0200, Nick Piggin wrote:
> 
> > I do of course. There is one thing to have a real lock deadlock
> > in some core path, and another to have this memory deadlock in a
> > known-to-be-dodgy configuration (Linus said last year that he didn't
> > want to go out of our way to support this, right?)... But if you can
> > solve it without impacting fastpaths etc. then I don't see any
> > objection to it.
> 
> That has been my intention, getting the problem solved without touching
> fast paths and with minimal changes to how things are currently done.
> 
> > I don't mean for correctness, but for throughput. If you're doing a
> > lot of network operations right near the memory limit, then it could
> > be possible that these deadlock paths get triggered relatively often.
> > With Christoph's patches, I think it would tend to be less.
> 
> Christoph's patches all rely on file backed memory being predominant.
> [ and to a certain degree fully ignore anonymous memory loads :-( ]

Yes. 


> Whereas quite a few realistic loads strive to minimise these - I'll
> again fall back to my MPI cluster example, they would want to use so
> much anonymous memory to preform their calculations that everything
> except the hot paths of code are present in memory. In these scenarios 1
> MB of text would already be a lot.

OK, I don't know exactly about MPI workloads. But I mean a few basic
things like the C and MPI libraries could already be quite big before
you even consider the application text (OK it won't be all paged in).

Maybe it won't be enough, but I think some form of recurive reclaim
will be better than our current scheme. Even assuming your patches are
in the kernel, don't you think it is a good idea to _not_ have potentially
complex writeout from reclaim just default to using up memory reserves?

 
> > > > How are your deadlock patches going anyway? AFAIK they are mostly a network
> > > > issue and I haven't been keeping up with them for a while. 
> > > 
> > > They really do rely on some VM interaction too, network does not have
> > > enough information to break out of the deadlock on its own.
> > 
> > The thing I don't much like about your patches is the addition of more
> > of these global reserve type things in the allocators. They kind of
> > suck (not your code, just the concept of them in general -- ie. including
> > the PF_MEMALLOC reserve). I'd like to eventually reach a model where
> > reclaimable memory from a given subsystem is always backed by enough
> > resources to be able to reclaim it. What stopped you from going that
> > route with the network subsystem? (too much churn, or something
> > fundamental?)
> 
> I'm wanting to keep the patches as non-intrusive as possible, exactly
> because some people consider this a fringe functionality. Doing as you
> say does sound like a noble goal, but would require massive overhauls.

But the code would end up better, wouldn't it? And it could be done
incrementally?

 
> Also, I'm not quite sure how this would apply to networking. It
> generally doesn't have much reclaimable memory sitting around, and it
> heavily relies on kmalloc so an alloc/free cycle accounting system would
> quickly involve a lot of the things I'm already doing.

It wouldn't use reclaimable memory as such, but would have some small
amounts of reserve memory for allocating all those things required to
get a response from critical sockets. NBD for example would also then
be sure to reserve enough memory to at least clean one page etc. That's
the way the block layer has gone, which seems to be pretty good and I
think much better than having it in the buddy allocator.

> (also one advantage of keeping it all in the buddy allocator is that it
> can more easily form larger order pages)

I don't know if that is a really good advantage. The amount of memory
involved should just be pretty small. I mean it is an advantage, but
there are other disadvantages (imagine the mess if other subsystems used
their own global reserves in the allocator rather than mempools etc). I
don't see why networking is fundamentally more deserving of its own pools
in the allocator than anybody else.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
