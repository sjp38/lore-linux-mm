Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0AEEF6B0022
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:19:25 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id j8so3880468qti.23
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:19:25 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s86si1802722qki.394.2018.03.21.12.19.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 12:19:24 -0700 (PDT)
Date: Wed, 21 Mar 2018 15:19:22 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.DEB.2.20.1803211354170.13978@nuc-kabylake>
Message-ID: <alpine.LRH.2.02.1803211500570.26409@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com> <20180320173512.GA19669@bombadil.infradead.org> <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake> <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake> <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake> <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211354170.13978@nuc-kabylake>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>



On Wed, 21 Mar 2018, Christopher Lameter wrote:

> On Wed, 21 Mar 2018, Mikulas Patocka wrote:
> 
> > So, what would you recommend for allocating 640KB objects while minimizing
> > wasted space?
> > * alloc_pages - rounds up to the next power of two
> > * kmalloc - rounds up to the next power of two
> > * alloc_pages_exact - O(n*log n) complexity; and causes memory
> >   fragmentation if used excesivelly
> > * vmalloc - horrible performance (modifies page tables and that causes
> >   synchronization across all CPUs)
> >
> > anything else?
> 
> Need to find it but there is a way to allocate N pages in sequence
> somewhere. Otherwise mempools are something that would work.

There's also continuous-memory-allocator, but it needs its memory to be 
reserved at boot time. It is intended for misdesigned hardware devices 
that need continuous memory for DMA. As it's intended for one-time 
allocations when loading drivers, it lacks the performance and scalability 
of the slab cache and alloc_pages.

> > > > > What kind of problem could be caused here?
> > > >
> > > > Unlocked accesses are generally considered bad. For example, see this
> > > > piece of code in calculate_sizes:
> > > >         s->allocflags = 0;
> > > >         if (order)
> > > >                 s->allocflags |= __GFP_COMP;
> > > >
> > > >         if (s->flags & SLAB_CACHE_DMA)
> > > >                 s->allocflags |= GFP_DMA;
> > > >
> > > >         if (s->flags & SLAB_RECLAIM_ACCOUNT)
> > > >                 s->allocflags |= __GFP_RECLAIMABLE;
> > > >
> > > > If you are running this while the cache is in use (i.e. when the user
> > > > writes /sys/kernel/slab/<cache>/order), then other processes will see
> > > > invalid s->allocflags for a short time.
> > >
> > > Calculating sizes is done when the slab has only a single accessor. Thus
> > > no locking is neeed.
> >
> > The calculation is done whenever someone writes to
> > "/sys/kernel/slab/*/order"
> 
> But the flags you are mentioning do not change and the size of the object
> does not change. What changes is the number of objects in the slab page.

See this code again:
> > >         s->allocflags = 0;
> > >         if (order)
> > >                 s->allocflags |= __GFP_COMP;
> > >
> > >         if (s->flags & SLAB_CACHE_DMA)
> > >                 s->allocflags |= GFP_DMA;
> > >
> > >         if (s->flags & SLAB_RECLAIM_ACCOUNT)
> > >                 s->allocflags |= __GFP_RECLAIMABLE;
when this function is called, the value s->allocflags does change. At the 
end, s->allocflags holds the same value as before, but it changes 
temporarily.

For example, if someone creates a slab cache with the flag SLAB_CACHE_DMA, 
and he allocates an object from this cache and this allocation races with 
the user writing to /sys/kernel/slab/cache/order - then the allocator can 
for a small period of time see "s->allocflags == 0" and allocate a non-DMA 
page. That is a bug.

Mikulas
