Message-ID: <3D4E3AD6.2010A02B@zip.com.au>
Date: Mon, 05 Aug 2002 01:44:06 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: how not to write a search algorithm
References: <3D4CE74A.A827C9BC@zip.com.au> <Pine.LNX.4.44L.0208041015350.23404-100000@imladris.surriel.com> <3D4D87CE.25198C28@zip.com.au> <20020804203804.GD4010@holomorphy.com> <3D4D9802.D1F208F0@zip.com.au> <20020804220218.GF4010@holomorphy.com> <3D4DAE2C.F45BC9D4@zip.com.au> <20020804224736.GI4010@holomorphy.com> <3D4DEA4B.4BAB65FB@zip.com.au> <20020805074042.GL4010@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> William Lee Irwin III wrote:
> >> (2) only needs the reservation bits from the preceding post if it's
> >>         just dealing with kmem_cache_alloc() returning NULL.
> 
> On Sun, Aug 04, 2002 at 08:00:27PM -0700, Andrew Morton wrote:
> > Well I think we'll need a per-cpu-pages thing to amortise zone->lock
> > contention anyway.  So what we can do is:
> >       fill_up_the_per_cpu_buffer(GFP_KERNEL); /* disables preemption */
> >       spin_lock(lock);
> >       allocate(GFP_ATOMIC);
> >       spin_unlock(lock);
> >       preempt_enable();
> > We also prevent interrupt-time allocations from
> > stealing the final four pages from the per-cpu buffer.
> > The allocation is guaranteed to succeed, yes?   Can use
> > it for ratnodes as well.
> 
> NFI how this is supposed to work with slab caches and/or get around the
> GFP_ATOMIC failing.

The GFP_ATOMIC allocation can't fail.  We've gone and arranged for
this CPU to have (say) eight free pages, all to itself.  If we
also arrange for interrupt context to leave at least four behind,
we *know* that there are pages available to the atomic allocation.

So if the slab allocation needs a page, it will get it from the
cpu-local pool.

It can fail if the allocation is higher-order, but we won't do that.

The nice thing is that it 99% leverages a per-cpu-pages mechanism.

We'd have to make fill_up_the_per_cpu_buffer() loop for ever
(but the page allocator does that anyway) or handle a failure
from that.  Just loop, I'd say.  Provided the caller isn't holding any
semaphores.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
