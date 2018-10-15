Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 967946B026B
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 18:41:04 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id l6-v6so22316474qtc.12
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 15:41:04 -0700 (PDT)
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTPS id n30-v6si1277463qtl.92.2018.10.15.15.41.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 15 Oct 2018 15:41:03 -0700 (PDT)
Date: Mon, 15 Oct 2018 22:41:03 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [patch] mm, slab: avoid high-order slab pages when it does not
 reduce waste
In-Reply-To: <20181012151341.286cd91321cdda9b6bde4de9@linux-foundation.org>
Message-ID: <0100016679e3c96f-c78df4e2-9ab8-48db-8796-271c4b439f16-000000@email.amazonses.com>
References: <alpine.DEB.2.21.1810121424420.116562@chino.kir.corp.google.com> <20181012151341.286cd91321cdda9b6bde4de9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 12 Oct 2018, Andrew Morton wrote:

> > If the amount of waste is the same at higher cachep->gfporder values,
> > there is no significant benefit to allocating higher order memory.  There
> > will be fewer calls to the page allocator, but each call will require
> > zone->lock and finding the page of best fit from the per-zone free areas.

There is a benefit because the management overhead is halved.

> > Instead, it is better to allocate order-0 memory if possible so that pages
> > can be returned from the per-cpu pagesets (pcp).

Have a benchmark that shows this?

>
> > There are two reasons to prefer this over allocating high order memory:
> >
> >  - allocating from the pcp lists does not require a per-zone lock, and
> >
> >  - this reduces stranding of MIGRATE_UNMOVABLE pageblocks on pcp lists
> >    that increases slab fragmentation across a zone.

The slab allocators generally buffer pages from the page allocator to
avoid this effect given the slowness of page allocator operations anyways.


> Confused.  Higher-order slab pages never go through the pcp lists, do
> they?  I'd have thought that by tending to increase the amount of
> order-0 pages which are used by slab, such stranding would be
> *increased*?

Potentially.


> > We are particularly interested in the second point to eliminate cases
> > where all other pages on a pageblock are movable (or free) and fallback to
> > pageblocks of other migratetypes from the per-zone free areas causes
> > high-order slab memory to be allocated from them rather than from free
> > MIGRATE_UNMOVABLE pages on the pcp.

Well does this actually do some good?
