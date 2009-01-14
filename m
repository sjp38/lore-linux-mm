Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 94B796B006A
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 09:22:08 -0500 (EST)
Date: Wed, 14 Jan 2009 15:22:00 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090114142200.GB25401@wotan.suse.de>
References: <20090114090449.GE2942@wotan.suse.de> <84144f020901140253s72995188vb35a79501c38eaa3@mail.gmail.com> <20090114114707.GA24673@wotan.suse.de> <84144f020901140544v56b856a4w80756b90f5b59f26@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020901140544v56b856a4w80756b90f5b59f26@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 14, 2009 at 03:44:44PM +0200, Pekka Enberg wrote:
> Hi Nick,
> 
> On Wed, Jan 14, 2009 at 1:47 PM, Nick Piggin <npiggin@suse.de> wrote:
> > The core allocator algorithms are so completely different that it is
> > obviously as different from SLUB as SLUB is from SLAB (apart from peripheral
> > support code and code structure). So it may as well be a patch against
> > SLAB.
> >
> > I will also prefer to maintain it myself because as I've said I don't
> > really agree with choices made in SLUB (and ergo SLUB developers don't
> > agree with SLQB).
> 
> Just for the record, I am only interesting in getting rid of SLAB (and
> SLOB if we can serve the embedded folks as well in the future, sorry
> Matt). Now, if that means we have to replace SLUB with SLQB, I am fine
> with that. Judging from the SLAB -> SLUB experience, though, I am not
> so sure adding a completely separate allocator is the way to get
> there.

The problem is there was apparently no plan for resolving the SLAB vs SLUB
strategy. And then features and things were added to one or the other one.
But on the other hand, the SLUB experience was a success in a way because
there were a lot of performance regressions found and fixed after it was
merged, for example.

I'd love to be able to justify replacing SLAB and SLUB today, but actually
it is simply never going to be trivial to discover performance regressions.
So I don't think outright replacement is great either (consider if SLUB
had replaced SLAB completely).


> On Wed, Jan 14, 2009 at 1:47 PM, Nick Piggin <npiggin@suse.de> wrote:
> > Note that I'm not trying to be nasty here. Of course I raised objections
> > to things I don't like, and I don't think I'm right by default. Just IMO
> > SLUB has some problems. As do SLAB and SLQB of course. Nothing is
> > perfect.
> >
> > Also, I don't want to propose replacing any of the other allocators yet,
> > until more performance data is gathered. People need to compare each one.
> > SLQB definitely is not a clear winner in all tests. At the moment I want
> > to see healthy competition and hopefully one day decide on just one of
> > the main 3.
> 
> OK, then it is really up to Andrew and Linus to decide whether they
> want to merge it or not. I'm not violently against it, it's just that
> there's some maintenance overhead for API changes and for external
> code like kmemcheck, kmemtrace, and failslab, that need hooks in the
> slab allocator.

Sure. On the slab side, I would be happy to do that work.

We split the user base, which is a big problem if it drags out for years
like SLAB/SLUB. But if it is a very deliberate use of testing resources
in order to make progress on the issue, then that can be a positive.


 
> On Wed, Jan 14, 2009 at 1:47 PM, Nick Piggin <npiggin@suse.de> wrote:
> > Cache colouring was just brought over from SLAB. prefetching was done
> > by looking at cache misses generally, and attempting to reduce them.
> > But you end up barely making a significant difference or just pushing
> > the cost elsewhere really. Down to the level of prefetching it is
> > going to hugely depend on the exact behaviour of the workload and
> > the allocator.
> 
> As far as I understood, the prefetch optimizations can produce
> unexpected results on some systems (yes, bit of hand-waving here), so
> I would consider ripping them out. Even if cache coloring isn't a huge
> win on most systems, it's probably not going to hurt either.

I hit problems on some microbenchmark where I was prefetching a NULL pointer in
some cases, which must have been causing the CPU to trap internally and alloc
overhead suddenly got much higher ;) 

Possibly sometimes if you prefetch too early or when various queues are
already full, then it ends up causing slowdowns too.

 
> On Wed, Jan 14, 2009 at 1:47 PM, Nick Piggin <npiggin@suse.de> wrote:
> >> > +   object = page->freelist;
> >> > +   page->freelist = get_freepointer(s, object);
> >> > +   if (page->freelist)
> >> > +           prefetchw(page->freelist);
> >>
> >> I don't understand this prefetchw(). Who exactly is going to be updating
> >> contents of page->freelist?
> >
> > Again, it is for the next allocation. This was shown to reduce cache
> > misses here in IIRC tbench, but I'm not sure if that translated to a
> > significant performance improvement.
> 
> I'm not sure why you would want to optimize for the next allocation. I
> mean, I'd expect us to optimize for the kmalloc() + do some work +
> kfree() case where prefetching is likely to hurt more than help. Not
> that I have any numbers on this.

That's true, OTOH if the time between allocations is large, then an
extra prefetch is just a small cost. If the time between them is
short, it might be a bigger win.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
