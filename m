Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 689C46B0012
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:25:44 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id q19so3545549qta.17
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 09:25:44 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id z187si2514426qke.333.2018.03.21.09.25.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 09:25:43 -0700 (PDT)
Date: Wed, 21 Mar 2018 12:25:39 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake>
Message-ID: <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com> <20180320173512.GA19669@bombadil.infradead.org> <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake> <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake> <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>



On Wed, 21 Mar 2018, Christopher Lameter wrote:

> On Tue, 20 Mar 2018, Mikulas Patocka wrote:
> 
> > > > Another problem with slub_max_order is that it would pad all caches to
> > > > slub_max_order, even those that already have a power-of-two size (in that
> > > > case, the padding is counterproductive).
> > >
> > > No it does not. Slub will calculate the configuration with the least byte
> > > wastage. It is not the standard order but the maximum order to be used.
> > > Power of two caches below PAGE_SIZE will have order 0.
> >
> > Try to boot with slub_max_order=10 and you can see this in /proc/slabinfo:
> > kmalloc-8192         352    352   8192   32   64 : tunables    0    0    0 : slabdata     11     11      0
> 
> Yes it tries to create a slab size that will accomodate the minimum
> objects per slab.
> 
> > So it rounds up power-of-two sizes to high orders unnecessarily. Without
> > slub_max_order=10, the number of pages for the kmalloc-8192 cache is just
> > 8.
> 
> The kmalloc-8192 has 4 objects per slab on my system which means an
> allocation size of 32k = order 4.
> 
> In this case 4 objects fit tightly into a slab. There is no waste.
> 
> But then I thought you were talking about manually created slabs not
> about the kmalloc array?

For some workloads, dm-bufio needs caches with sizes that are a power of 
two (majority of workloads fall into this cathegory). For other workloads 
dm-bufio needs caches with sizes that are not a power of two.

Now - we don't want higher-order allocations for power-of-two caches 
(because higher-order allocations just cause memory fragmentation without 
any benefit), but we want higher-order allocations for non-power-of-two 
caches (because higher-order allocations minimize wasted space).

For example:
for 192K block size, the ideal order is 4MB (it takes 21 blocks)
for 448K block size, the ideal order is 4MB (it takes 9 blocks)
for 512K block size, the ideal order is 512KB (there is no benefit from 
	using higher order)
for 640K block size, the ideal order is 2MB (it takes 3 blocks, increasing 
	the allocation size to 4MB doesn't result in any benefit)
for 832K block size, the ideal order is 1MB (it takes 1 block, increasing
	the allocation to 2MB or 4MB doesn't result in any benefit)
for 1M block size, the ideal order is 1MB

The problem with "slub_max_order" is that it increases the order either 
always or never, but doesn't have the capability to calculate the ideal 
order for the given object size. The patch that I send just does this 
calculation.

Another problem wit "slub_max_order" is that the device driver that needs 
to create a slab cache cannot really set it - the device driver can't 
modify the kernel parameters.

> > I observe the same pathological rounding in dm-bufio caches.
> >
> > > There are some corner cases where extra metadata is needed per object or
> > > per page that will result in either object sizes that are no longer a
> > > power of two or in page sizes smaller than the whole page. Maybe you have
> > > a case like that? Can you show me a cache that has this issue?
> >
> > Here I have a patch set that changes the dm-bufio subsystem to support
> > buffer sizes that are not a power of two:
> > http://people.redhat.com/~mpatocka/patches/kernel/dm-bufio-arbitrary-sector-size/
> >
> > I need to change the slub cache to minimize wasted space - i.e. when
> > asking for a slab cache for 640kB objects, the slub system currently
> > allocates 1MB per object and 384kB is wasted. This is the reason why I'm
> > making this patch.
> 
> You should not be using the slab allocators for these. Allocate higher
> order pages or numbers of consecutive smaller pagess from the page
> allocator. The slab allocators are written for objects smaller than page
> size.

So, do you argue that I need to write my own slab cache functionality 
instead of using the existing slab code?

I can do it - but duplicating code is bad thing.

> > > > BTW. the function "order_store" in mm/slub.c modifies the structure
> > > > kmem_cache without taking any locks - is it a bug?
> > >
> > > The kmem_cache structure was just allocated. Only one thread can access it
> > > thus no locking is necessary.
> >
> > No - order_store is called when writing to /sys/kernel/slab/<cache>/order
> > - you can modify order for any existing cache - and the modification
> > happens without any locking.
> 
> Well it still does not matter. The size of the order of slab pages
> can be dynamic even within a slab. You can have pages of varying sizes.
> 
> What kind of problem could be caused here?

Unlocked accesses are generally considered bad. For example, see this 
piece of code in calculate_sizes:
        s->allocflags = 0;
        if (order)
                s->allocflags |= __GFP_COMP;

        if (s->flags & SLAB_CACHE_DMA)
                s->allocflags |= GFP_DMA;

        if (s->flags & SLAB_RECLAIM_ACCOUNT)
                s->allocflags |= __GFP_RECLAIMABLE;

If you are running this while the cache is in use (i.e. when the user 
writes /sys/kernel/slab/<cache>/order), then other processes will see 
invalid s->allocflags for a short time.

Mikulas
