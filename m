Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 587C36B0006
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 19:09:58 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id q143-v6so10359960pgq.12
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 16:09:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t5-v6sor2660284pfk.58.2018.10.12.16.09.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Oct 2018 16:09:57 -0700 (PDT)
Date: Fri, 12 Oct 2018 16:09:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, slab: avoid high-order slab pages when it does not
 reduce waste
In-Reply-To: <20181012151341.286cd91321cdda9b6bde4de9@linux-foundation.org>
Message-ID: <alpine.DEB.2.21.1810121559460.133019@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1810121424420.116562@chino.kir.corp.google.com> <20181012151341.286cd91321cdda9b6bde4de9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 12 Oct 2018, Andrew Morton wrote:

> > The slab allocator has a heuristic that checks whether the internal
> > fragmentation is satisfactory and, if not, increases cachep->gfporder to
> > try to improve this.
> > 
> > If the amount of waste is the same at higher cachep->gfporder values,
> > there is no significant benefit to allocating higher order memory.  There
> > will be fewer calls to the page allocator, but each call will require
> > zone->lock and finding the page of best fit from the per-zone free areas.
> > 
> > Instead, it is better to allocate order-0 memory if possible so that pages
> > can be returned from the per-cpu pagesets (pcp).
> > 
> > There are two reasons to prefer this over allocating high order memory:
> > 
> >  - allocating from the pcp lists does not require a per-zone lock, and
> > 
> >  - this reduces stranding of MIGRATE_UNMOVABLE pageblocks on pcp lists
> >    that increases slab fragmentation across a zone.
> 
> Confused.  Higher-order slab pages never go through the pcp lists, do
> they?

Nope.

> I'd have thought that by tending to increase the amount of
> order-0 pages which are used by slab, such stranding would be
> *increased*?
> 

These cpus have MIGRATE_UNMOVABLE pages on their pcp list.  But because 
they are order-1 instead of order-0, we take zone->lock and find the 
smallest possible page in the zone's free area that is of sufficient size.  
On low on memory situations, there are no pages of MIGRATE_UNMOVABLE 
migratetype at any order in the free area.  This calls 
__rmqueue_fallback() that steals pageblocks, MIGRATE_RECLAIMABLE and then 
MIGRATE_MOVABLE, and as MIGRATE_UNMOVABLE.

We rely on the pcp batch count to backfill MIGRATE_UNMOVABLE pages onto 
the pcp list so we don't need to take zone->lock, and as a result of these 
allocations being order-0 rather than order-1 we can then allocate from 
these pages when such slab caches are expanded rather than stranding them.

We noticed this when the amount of memory wasted for TCPv6 was the same 
for both order-0 and order-1 allocations (order-1 waste was two times the 
order-0 waste).  We had hundreds of cpus with pages on their 
MIGRATE_UNMOVABLE pcp list, but while allocating order-1 memory it would 
prefer to happily steal other pageblocks before calling reclaim and 
draining pcp lists.

> > We are particularly interested in the second point to eliminate cases
> > where all other pages on a pageblock are movable (or free) and fallback to
> > pageblocks of other migratetypes from the per-zone free areas causes
> > high-order slab memory to be allocated from them rather than from free
> > MIGRATE_UNMOVABLE pages on the pcp.
> > 
> >  mm/slab.c | 15 +++++++++++++++
> 
> Do slub and slob also suffer from this effect?
> 

SLOB should not, SLUB will typically increase the order to improve 
performance of the cpu cache; there's a drawback to changing out the cpu 
cache that SLAB does not have.  In the case that this patch is addressing, 
there is no greater memory utilization from the allocted slab pages.
