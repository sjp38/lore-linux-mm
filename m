Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 91FF56B0003
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 11:17:58 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id y201-v6so24209860qka.1
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 08:17:58 -0700 (PDT)
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id 42si5432459qvn.159.2018.10.16.08.17.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 16 Oct 2018 08:17:57 -0700 (PDT)
Date: Tue, 16 Oct 2018 15:17:56 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [patch] mm, slab: avoid high-order slab pages when it does not
 reduce waste
In-Reply-To: <alpine.DEB.2.21.1810151715220.21338@chino.kir.corp.google.com>
Message-ID: <010001667d7476a2-f91dcf12-5e90-4ade-97e8-9fd651f7bf17-000000@email.amazonses.com>
References: <alpine.DEB.2.21.1810121424420.116562@chino.kir.corp.google.com> <20181012151341.286cd91321cdda9b6bde4de9@linux-foundation.org> <0100016679e3c96f-c78df4e2-9ab8-48db-8796-271c4b439f16-000000@email.amazonses.com>
 <alpine.DEB.2.21.1810151715220.21338@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 15 Oct 2018, David Rientjes wrote:

> On Mon, 15 Oct 2018, Christopher Lameter wrote:
>
> > > > If the amount of waste is the same at higher cachep->gfporder values,
> > > > there is no significant benefit to allocating higher order memory.  There
> > > > will be fewer calls to the page allocator, but each call will require
> > > > zone->lock and finding the page of best fit from the per-zone free areas.
> >
> > There is a benefit because the management overhead is halved.
> >
>
> It depends on (1) how difficult it is to allocate higher order memory and
> (2) the long term affects of preferring high order memory over order 0.

The overhead of the page allocator is orders of magnitudes bigger than
slab allocation. Higher order may be faster because the pcp overhead is
not there. It all depends. Please come up with some benchmarking to
substantiate these ideas.

>
> For (1), slab has no minimum order fallback like slub does so the
> allocation either succeeds at cachep->gfporder or it fails.  If memory
> fragmentation is such that order-1 memory is not possible, this is fixing
> an issue where the slab allocation would succeed but now fails
> unnecessarily.  If that order-1 memory is painful to allocate, we've
> reclaimed and compacted unnecessarily when order-0 pages are available
> from the pcp list.
>

Ok that sounds good but the performance impact is still an issue. Also we
agreed that the page allocator will provide allocations up to
COSTLY_ORDER without too much fuss. Other system components may fail if
these smaller order pages are not available.

> > Have a benchmark that shows this?
> >
>
> I'm not necessarily approaching this from a performance point of view, but
> rather as a means to reduce slab fragmentation when fallback to order-0
> memory, especially when completely legitimate, is prohibited.  From a
> performance standpoint, this will depend on separately on fragmentation
> and contention on zone->lock which both don't exist for order-0 memory
> until fallback is required and then the pcp are filled with up to
> batchcount pages.

Fragmentation is a performance issue and causes degradation of Linux MM
performance over time.  There are pretty complex mechanism that need to be
played against one another.

Come up with some metrics to get meaningful data that allows us to see the
impact.

I think what would be beneficial to have is a load that gradually
degrade as another process causes fragmentation. Any patch like the one
proposed should have an effect on the degree of fragmentation after a
certain time.

Having something like that could lead to a whole serial of optimizations.
Ideally we would like to have a MM subsystem that does not degrade as
today.
