Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9B99D620202
	for <linux-mm@kvack.org>; Tue, 25 May 2010 10:34:23 -0400 (EDT)
Date: Wed, 26 May 2010 00:34:09 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
Message-ID: <20100525143409.GP5087@laptop>
References: <20100521211452.659982351@quilx.com>
 <20100524070309.GU2516@laptop>
 <alpine.DEB.2.00.1005240852580.5045@router.home>
 <20100525020629.GA5087@laptop>
 <alpine.DEB.2.00.1005250859050.28941@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1005250859050.28941@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 25, 2010 at 09:13:37AM -0500, Christoph Lameter wrote:
> On Tue, 25 May 2010, Nick Piggin wrote:
> 
> > On Mon, May 24, 2010 at 10:06:08AM -0500, Christoph Lameter wrote:
> > This is the kind of handwavings that need to be put into a testable
> > form. I repeatedly asked you for examples of where the jitter is
> > excessive or where the TLB improvements help, but you never provided
> > any testable case. I'm not saying they don't exist, but we have to be
> > reational about this.
> 
> The initial test that showed the improvements was on IA64 (16K page size)
> and that was the measurement that was accepted for the initial merge. Mel
> was able to verify those numbers.

And there is nothing to prevent a SLAB type allocator from using higher
order allocations, except for the fact that it usually wouldn't because
far more often than not it is a bad idea.

Also, people actually want to use hugepages in userspace. The more that
other allocations use them, the worse problems with fragmentation and
reclaim become.

 
> While it will be easily possible to have less higher order allocations
> with SLEB I still think that higher order allocations are desirable to
> increase data locality and TLB pressure. Its easy though to set the
> defaults to order 1 (like SLAB) though and then allow manual override if
> desired.
> 
> Fundamentally it is still the case that memory sizes are increasing and
> that management overhead of 4K pages will therefore increasingly become an
> issue. Support for larger page sizes and huge pages is critical for all
> kernel components to compete in the future.

Numbers haven't really shown that SLUB is better because of higher order
allocations. Besides, as I said, higher order allocations can be used
by others.

 
> > > > I hope we can move forward now with some objective, testable
> > > > comparisons and criteria for selecting one main slab allocator.
> > >
> > > If can find criteria that are universally agreed upon then yes but that is
> > > doubtful.
> >
> > I think we can agree that perfect is the enemy of good, and that no
> > allocator will do the perfect thing for everybody. I think we have to
> > come up with a way to a single allocator.
> 
> Yes but SLAB is not really the way to go. The code is too messy. Thats why

That's a weak reason. SLUB has taken years to prove that it's not a
suitable replacement, so more big changes to it is not make it more
suitable now. We should just admit the rip and replace idea has
failed, and go with more reasonable incremental improvements rather
than subject everyone to another round of testing.

This is why I stopped pushing SLQB TBH, even though it showed some
promise.

The hard part is clearly NOT the code cleanup. It is the design and
all the testing and tuning.


> I think the best way to go at this point is to merge the clean SLUB design
> and add the SLAB features needed and try to keep the NUMA stuff cleaner.

I think it is to get rid of SLUB and add SLUB features gradually to
SLAB if/when they prove themselves.

 
> I am not entirely sure that I want to get rid of SLUB. Certainly if you
> want minimal latency (like in my field) and more determinism then you
> would want a SLUB design instead of periodic queue handling. Also SLUB has
> a minimal memory footprint due to the linked list architecture.

I disagree completely. The queues can be shrunk to a similar size as
the SLUB queues (which are just implicit by design), and periodic
shrinking can be disabled like SLUB. It's not a fundamental design
property.

Also, there were no numbers or test cases, simply handwaving. I don't
disagree it might be a problem, but the way to solve problems is to
provide a test case or numbers.


> The queues sacrifice a lot there. The linked list does not allow managing
> cache cold objects like SLAB does because you always need to touch the
> object and this will cause regressions against SLAB. I think this is also
> one of the weaknesses of SLQB.

But this is just more handwaving. That's what got us into this situation
we are in now.

What we know is that SLAB is still used by all high performance
enterprise distros (and google). And it is used by Altixes in production
as well as all other large NUMA machines that Linux runs on.

Given that information, how can you still say that SLUB+more big changes
is the right way to proceed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
