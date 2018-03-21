Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 76C8B6B0012
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 11:35:50 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id t9so4682129ioa.9
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 08:35:50 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id 64-v6si3289773itw.85.2018.03.21.08.35.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 08:35:47 -0700 (PDT)
Date: Wed, 21 Mar 2018 10:35:46 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake>
References: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com> <20180320173512.GA19669@bombadil.infradead.org> <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake> <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake> <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>

On Tue, 20 Mar 2018, Mikulas Patocka wrote:

> > > Another problem with slub_max_order is that it would pad all caches to
> > > slub_max_order, even those that already have a power-of-two size (in that
> > > case, the padding is counterproductive).
> >
> > No it does not. Slub will calculate the configuration with the least byte
> > wastage. It is not the standard order but the maximum order to be used.
> > Power of two caches below PAGE_SIZE will have order 0.
>
> Try to boot with slub_max_order=10 and you can see this in /proc/slabinfo:
> kmalloc-8192         352    352   8192   32   64 : tunables    0    0    0 : slabdata     11     11      0

Yes it tries to create a slab size that will accomodate the minimum
objects per slab.

> So it rounds up power-of-two sizes to high orders unnecessarily. Without
> slub_max_order=10, the number of pages for the kmalloc-8192 cache is just
> 8.

The kmalloc-8192 has 4 objects per slab on my system which means an
allocation size of 32k = order 4.

In this case 4 objects fit tightly into a slab. There is no waste.

But then I thought you were talking about manually created slabs not
about the kmalloc array?

> I observe the same pathological rounding in dm-bufio caches.
>
> > There are some corner cases where extra metadata is needed per object or
> > per page that will result in either object sizes that are no longer a
> > power of two or in page sizes smaller than the whole page. Maybe you have
> > a case like that? Can you show me a cache that has this issue?
>
> Here I have a patch set that changes the dm-bufio subsystem to support
> buffer sizes that are not a power of two:
> http://people.redhat.com/~mpatocka/patches/kernel/dm-bufio-arbitrary-sector-size/
>
> I need to change the slub cache to minimize wasted space - i.e. when
> asking for a slab cache for 640kB objects, the slub system currently
> allocates 1MB per object and 384kB is wasted. This is the reason why I'm
> making this patch.

You should not be using the slab allocators for these. Allocate higher
order pages or numbers of consecutive smaller pagess from the page
allocator. The slab allocators are written for objects smaller than page
size.

> > > BTW. the function "order_store" in mm/slub.c modifies the structure
> > > kmem_cache without taking any locks - is it a bug?
> >
> > The kmem_cache structure was just allocated. Only one thread can access it
> > thus no locking is necessary.
>
> No - order_store is called when writing to /sys/kernel/slab/<cache>/order
> - you can modify order for any existing cache - and the modification
> happens without any locking.

Well it still does not matter. The size of the order of slab pages
can be dynamic even within a slab. You can have pages of varying sizes.

What kind of problem could be caused here?
