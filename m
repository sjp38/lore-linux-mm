Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7BCAA620202
	for <linux-mm@kvack.org>; Tue, 25 May 2010 10:16:54 -0400 (EDT)
Date: Tue, 25 May 2010 09:13:37 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
In-Reply-To: <20100525020629.GA5087@laptop>
Message-ID: <alpine.DEB.2.00.1005250859050.28941@router.home>
References: <20100521211452.659982351@quilx.com> <20100524070309.GU2516@laptop> <alpine.DEB.2.00.1005240852580.5045@router.home> <20100525020629.GA5087@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 May 2010, Nick Piggin wrote:

> On Mon, May 24, 2010 at 10:06:08AM -0500, Christoph Lameter wrote:
> > On Mon, 24 May 2010, Nick Piggin wrote:
> >
> > > Well I'm glad you've conceded that queues are useful for high
> > > performance computing, and that higher order allocations are not
> > > a free and unlimited resource.
> >
> > Ahem. I have never made any such claim and would never make them. And
> > "conceding" something ???
>
> Well, you were quite vocal about the subject.

I was always vocal about the huge amounts of queues and the complexity
coming with alien caches etc. The alien caches were introduced against my
objections on the development team that did the NUMA slab. But even SLUB
has "queues" as many have repeatedly pointed out. The queuing is
different though in order to minimize excessive NUMA queueing. IMHO the
NUMA design of SLAB has fundamental problems because it implements its own
"NUMAness" aside from the page allocator. I had to put lots of band aid on
the NUMA functionality in SLAB to make it correct.

One of the key things in SLEB is the question how to deal with the alien
issue. So far I think the best compromise would be to use the shared
caches of the remote node as a stand in for the alien cache. Problem is
that we will then free cache cold objects to the remote shared cache.
Maybe that can be addressed by freeing to the end of the queue instead of
freeing to the top.

> > The "unqueueing" was the result of excessive queue handling in SLAB due and
> > the higher order allocations are a natural move in HPC to gain performance.
>
> This is the kind of handwavings that need to be put into a testable
> form. I repeatedly asked you for examples of where the jitter is
> excessive or where the TLB improvements help, but you never provided
> any testable case. I'm not saying they don't exist, but we have to be
> reational about this.

The initial test that showed the improvements was on IA64 (16K page size)
and that was the measurement that was accepted for the initial merge. Mel
was able to verify those numbers.

While it will be easily possible to have less higher order allocations
with SLEB I still think that higher order allocations are desirable to
increase data locality and TLB pressure. Its easy though to set the
defaults to order 1 (like SLAB) though and then allow manual override if
desired.

Fundamentally it is still the case that memory sizes are increasing and
that management overhead of 4K pages will therefore increasingly become an
issue. Support for larger page sizes and huge pages is critical for all
kernel components to compete in the future.

> > > I hope we can move forward now with some objective, testable
> > > comparisons and criteria for selecting one main slab allocator.
> >
> > If can find criteria that are universally agreed upon then yes but that is
> > doubtful.
>
> I think we can agree that perfect is the enemy of good, and that no
> allocator will do the perfect thing for everybody. I think we have to
> come up with a way to a single allocator.

Yes but SLAB is not really the way to go. The code is too messy. Thats why
I think the best way to go at this point is to merge the clean SLUB design
and add the SLAB features needed and try to keep the NUMA stuff cleaner.

I am not entirely sure that I want to get rid of SLUB. Certainly if you
want minimal latency (like in my field) and more determinism then you
would want a SLUB design instead of periodic queue handling. Also SLUB has
a minimal memory footprint due to the linked list architecture.

The queues sacrifice a lot there. The linked list does not allow managing
cache cold objects like SLAB does because you always need to touch the
object and this will cause regressions against SLAB. I think this is also
one of the weaknesses of SLQB.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
