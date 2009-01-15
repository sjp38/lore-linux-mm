Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 535A56B0055
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 15:06:08 -0500 (EST)
Date: Thu, 15 Jan 2009 14:05:55 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <20090115060330.GB17810@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0901151320250.26467@quilx.com>
References: <20090114090449.GE2942@wotan.suse.de>
 <84144f020901140253s72995188vb35a79501c38eaa3@mail.gmail.com>
 <20090114114707.GA24673@wotan.suse.de> <84144f020901140544v56b856a4w80756b90f5b59f26@mail.gmail.com>
 <20090114142200.GB25401@wotan.suse.de> <84144f020901140645o68328e01ne0e10ace47555e19@mail.gmail.com>
 <20090114150900.GC25401@wotan.suse.de> <Pine.LNX.4.64.0901141158090.26507@quilx.com>
 <20090115060330.GB17810@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Jan 2009, Nick Piggin wrote:

> > The higher orders can fail and will then result in the allocator doing
> > order 0 allocs. It is not a failure condition.
>
> But they increase pressure on the resource and reduce availability to
> other higher order allocations. They accelerate the breakdown of the
> anti-frag heuristics, and they make slab internal fragmentation worse.
> They also simply cost more to allocate and free and reclaim.

The costs are less since there is no need to have metadata for each of
the 4k sized pages. Instead there is one contiguous chunk that can be
tracked as a whole.

> > Higher orders are an
> > advantage because they localize variables of the same type and therefore
> > reduce TLB pressure.
>
> They are also a disadvantage. The disadvantages are very real. The
> advantage is a bit theoretical (how much really is it going to help
> going from 4K to 32K, if you still have hundreds or thousands of
> slabs anyway?). Also, there is no reason why the other allocators
> cannot use higher orer allocations, but their big advantage is that
> they don't need to.

The benefit of going from 4k to 32k is that 8 times as many objects may be
handled by the same 2M TLB covering a 32k page. If the 4k pages are
dispersed then you may need 8 2M tlbs (which covers already a quarter of
the available 2M TLBs on nehalem f.e.) for which the larger alloc just
needs a single one.

> > > The idea of removing queues doesn't seem so good to me. Queues are good.
> > > You amortize or avoid all sorts of things with queues. We have them
> > > everywhere in the kernel ;)
> >
> > Queues require maintenance which introduces variability because queue
> > cleaning has to be done periodically and the queues grow in number if NUMA
> > scenarios have to be handled effectively. This is a big problem for low
> > latency applications (like in HPC). Spending far too much time optimizing
> > queue cleaning in SLAB lead to the SLUB idea.
>
> I'd like to see any real numbers showing this is a problem. Queue
> trimming in SLQB can easily be scaled or tweaked to change latency
> characteristics. The fact is that it isn't a very critical or highly
> tuned operation. It happens _very_ infrequently in the large scheme
> of things, and could easily be changed if there is a problem.

Queue trimming can be configured in the same way in SLAB. But this means
that you are forever tuning these things as loads vary. Thats one of the
frustrations that led to the SLUB design. Also if the objects in queues
are not bound to particular page (as in slub) then traversal of the queues
can be very TLB fault intensive.

> What you have in SLUB IMO is not obviously better because it effectively
> has sizeable queues in higher order partial and free pages and the
> active page, which simply never get trimmed, AFAIKS. This can be harmful
> for slab internal fragmentation as well in some situations.

It has lists of free objects that are bound to a particular page. That
simplifies numa handling since all the objects in a "queue" (or page) have
the same NUMA characteristics. There is no moving between queues
(there is one exception but in general that is true) because the page list can
become the percpu list by just using the pointer to the head object.

Slab internal fragmentation is already a problem in SLAB. The solution
would be a targeted reclaim mechanism. Something like what I proposed in
with the slab defrag patches.

There is no need for trimming since there is no queue in the SLAB sense. A
page is assigned to a processor and then that processor takes objects off
the freelist and may free objects back to the freelist of that page that
was assigned to a processor. Memory wastage may only occur because
each processor needs to have a separate page from which to allocate. SLAB
like designs needs to put a large number of objects in queues which may
keep a number of pages in the allocated pages pool although all objects
are unused. That does not occur with slub.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
