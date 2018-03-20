Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id D294D6B0005
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 15:22:07 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id t27so1593303qki.11
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 12:22:07 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id m63si3444757qkb.269.2018.03.20.12.22.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 12:22:06 -0700 (PDT)
Date: Tue, 20 Mar 2018 15:22:03 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake>
Message-ID: <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com> <20180320173512.GA19669@bombadil.infradead.org> <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>



On Tue, 20 Mar 2018, Christopher Lameter wrote:

> On Tue, 20 Mar 2018, Matthew Wilcox wrote:
> 
> > On Tue, Mar 20, 2018 at 01:25:09PM -0400, Mikulas Patocka wrote:
> > > The reason why we need this is that we are going to merge code that does
> > > block device deduplication (it was developed separatedly and sold as a
> > > commercial product), and the code uses block sizes that are not a power of
> > > two (block sizes 192K, 448K, 640K, 832K are used in the wild). The slab
> > > allocator rounds up the allocation to the nearest power of two, but that
> > > wastes a lot of memory. Performance of the solution depends on efficient
> > > memory usage, so we should minimize wasted as much as possible.
> >
> > The SLUB allocator also falls back to using the page (buddy) allocator
> > for allocations above 8kB, so this patch is going to have no effect on
> > slub.  You'd be better off using alloc_pages_exact() for this kind of
> > size, or managing your own pool of pages by using something like five
> > 192k blocks in a 1MB allocation.
> 
> The fallback is only effective for kmalloc caches. Manually created caches
> do not follow this rule.

Yes - the dm-bufio layer uses manually created caches.

> Note that you can already control the page orders for allocation and
> the objects per slab using
> 
> 	slub_min_order
> 	slub_max_order
> 	slub_min_objects
> 
> This is documented in linux/Documentation/vm/slub.txt
> 
> Maybe do the same thing for SLAB?

Yes, but I need to change it for a specific cache, not for all caches.

When the order is greater than 3 (PAGE_ALLOC_COSTLY_ORDER), the allocation 
becomes unreliable, thus it is a bad idea to increase slub_max_order 
system-wide.

Another problem with slub_max_order is that it would pad all caches to 
slub_max_order, even those that already have a power-of-two size (in that 
case, the padding is counterproductive).

BTW. the function "order_store" in mm/slub.c modifies the structure 
kmem_cache without taking any locks - is it a bug?

Mikulas
