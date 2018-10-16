Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id EEBA06B0003
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 20:39:28 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id t10-v6so1411701plh.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 17:39:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h4-v6sor2852730plk.55.2018.10.15.17.39.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Oct 2018 17:39:27 -0700 (PDT)
Date: Mon, 15 Oct 2018 17:39:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, slab: avoid high-order slab pages when it does not
 reduce waste
In-Reply-To: <0100016679e3c96f-c78df4e2-9ab8-48db-8796-271c4b439f16-000000@email.amazonses.com>
Message-ID: <alpine.DEB.2.21.1810151715220.21338@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1810121424420.116562@chino.kir.corp.google.com> <20181012151341.286cd91321cdda9b6bde4de9@linux-foundation.org> <0100016679e3c96f-c78df4e2-9ab8-48db-8796-271c4b439f16-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 15 Oct 2018, Christopher Lameter wrote:

> > > If the amount of waste is the same at higher cachep->gfporder values,
> > > there is no significant benefit to allocating higher order memory.  There
> > > will be fewer calls to the page allocator, but each call will require
> > > zone->lock and finding the page of best fit from the per-zone free areas.
> 
> There is a benefit because the management overhead is halved.
> 

It depends on (1) how difficult it is to allocate higher order memory and 
(2) the long term affects of preferring high order memory over order 0.

For (1), slab has no minimum order fallback like slub does so the 
allocation either succeeds at cachep->gfporder or it fails.  If memory 
fragmentation is such that order-1 memory is not possible, this is fixing 
an issue where the slab allocation would succeed but now fails 
unnecessarily.  If that order-1 memory is painful to allocate, we've 
reclaimed and compacted unnecessarily when order-0 pages are available 
from the pcp list.

For (2), high-order slab allocations increase fragmentation of the zone 
under memory pressure.  If the per-zone free area is void of 
MIGRATE_UNMOVABLE pageblocks such that it must fallback, which it is under 
memory pressure, these order-1 pages can be returned from pageblocks that 
are filled with movable memory, or otherwise free.  This ends up making 
hugepages difficult to allocate from (to the extent where 1.5GB of slab on 
a node is spread over 100GB of pageblocks).  This occurs even though there 
may be MIGRATE_UNMOVABLE pages available on pcp lists.  Using this patch, 
it is possible to backfill the pcp list up to the batchcount with 
MIGRATE_UNMOVABLE order-0 pages that we can subsequently allocate and 
free to, which turns out to be optimized for caches like TCPv6 that result 
in both faster page allocation and less slab fragmentation.

> > > Instead, it is better to allocate order-0 memory if possible so that pages
> > > can be returned from the per-cpu pagesets (pcp).
> 
> Have a benchmark that shows this?
> 

I'm not necessarily approaching this from a performance point of view, but 
rather as a means to reduce slab fragmentation when fallback to order-0 
memory, especially when completely legitimate, is prohibited.  From a 
performance standpoint, this will depend on separately on fragmentation 
and contention on zone->lock which both don't exist for order-0 memory 
until fallback is required and then the pcp are filled with up to 
batchcount pages.

> >
> > > There are two reasons to prefer this over allocating high order memory:
> > >
> > >  - allocating from the pcp lists does not require a per-zone lock, and
> > >
> > >  - this reduces stranding of MIGRATE_UNMOVABLE pageblocks on pcp lists
> > >    that increases slab fragmentation across a zone.
> 
> The slab allocators generally buffer pages from the page allocator to
> avoid this effect given the slowness of page allocator operations anyways.
> 

It is possible to buffer the same number of pages once they are allocated, 
absent memory pressure, and does not require high-order memory.  This 
seems like a separate issue.

> > > We are particularly interested in the second point to eliminate cases
> > > where all other pages on a pageblock are movable (or free) and fallback to
> > > pageblocks of other migratetypes from the per-zone free areas causes
> > > high-order slab memory to be allocated from them rather than from free
> > > MIGRATE_UNMOVABLE pages on the pcp.
> 
> Well does this actually do some good?
> 

Examining pageblocks via tools/vm/page-types under memory pressure that 
show all B (buddy) and UlAMab (anon mapped) pages and then a single 
order-1 S (slab) page would suggest that the pageblock would not be 
exempted from ever being allocated for a hugepage until the slab is 
completely freed (indeterminate amount of time) if there are any pages on 
the MIGRATE_UNMOVABLE pcp list.

This change is eliminating the exemption from allocating from unmovable 
pages that are readily available instead of preferring to expensively 
allocate order-1 with no reduction in waste.

For users of slab_max_order, which we are not for obvious reasons, I can 
change this to only consider when testing gfporder == 0 since that 
logically makes sense if you prefer.
