Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id BEAA86B0031
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 16:37:13 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id a207so3850998qkb.23
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 13:37:13 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id k67si316219qkd.372.2018.03.21.13.37.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 13:37:12 -0700 (PDT)
Date: Wed, 21 Mar 2018 16:37:08 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.DEB.2.20.1803211508560.17257@nuc-kabylake>
Message-ID: <alpine.LRH.2.02.1803211613010.28365@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com> <20180320173512.GA19669@bombadil.infradead.org> <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake> <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake> <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake> <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211354170.13978@nuc-kabylake> <alpine.LRH.2.02.1803211500570.26409@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211508560.17257@nuc-kabylake>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>



On Wed, 21 Mar 2018, Christopher Lameter wrote:

> On Wed, 21 Mar 2018, Mikulas Patocka wrote:
> 
> > For example, if someone creates a slab cache with the flag SLAB_CACHE_DMA,
> > and he allocates an object from this cache and this allocation races with
> > the user writing to /sys/kernel/slab/cache/order - then the allocator can
> > for a small period of time see "s->allocflags == 0" and allocate a non-DMA
> > page. That is a bug.
> 
> True we need to fix that:
> 
> Subject: Avoid potentially visible allocflags without all flags set
> 
> During slab size recalculation s->allocflags may be temporarily set
> to 0 and thus the flags may not be set which may result in the wrong
> flags being passed. Slab size calculation happens in two cases:
> 
> 1. When a slab is created (which is safe since we cannot have
>    concurrent allocations)
> 
> 2. When the slab order is changed via /sysfs.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> 
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c
> +++ linux/mm/slub.c
> @@ -3457,6 +3457,7 @@ static void set_cpu_partial(struct kmem_
>  static int calculate_sizes(struct kmem_cache *s, int forced_order)
>  {
>  	slab_flags_t flags = s->flags;
> +	gfp_t allocflags;
>  	size_t size = s->object_size;
>  	int order;
> 
> @@ -3551,16 +3552,17 @@ static int calculate_sizes(struct kmem_c
>  	if (order < 0)
>  		return 0;
> 
> -	s->allocflags = 0;
> +	allocflags = 0;
>  	if (order)
> -		s->allocflags |= __GFP_COMP;
> +		allocflags |= __GFP_COMP;
> 
>  	if (s->flags & SLAB_CACHE_DMA)
> -		s->allocflags |= GFP_DMA;
> +		allocflags |= GFP_DMA;
> 
>  	if (s->flags & SLAB_RECLAIM_ACCOUNT)
> -		s->allocflags |= __GFP_RECLAIMABLE;
> +		allocflags |= __GFP_RECLAIMABLE;
> 
> +	s->allocflags = allocflags;

I'd also use "WRITE_ONCE(s->allocflags, allocflags)" here and when writing 
s->oo and s->min to avoid some possible compiler misoptimizations.

WRITE_ONCE should be used when writing a value that can be read 
simultaneously (but a lot of kernel code misses it).



Another problem is that it updates s->oo and later it updates s->max:
        s->oo = oo_make(order, size, s->reserved);
        s->min = oo_make(get_order(size), size, s->reserved);
        if (oo_objects(s->oo) > oo_objects(s->max))
                s->max = s->oo;
--- so, the concurrently running code could see s->oo > s->max, which 
could trigger some memory corruption.

s->max is only used in memory allocations - 
kmalloc(BITS_TO_LONGS(oo_objects(s->max)) * sizeof(unsigned long)), so 
perhaps we could fix the bug by removing s->max at all and always 
allocating enough memory for the maximum possible number of objects?

- kmalloc(BITS_TO_LONGS(oo_objects(s->max)) * sizeof(unsigned long), GFP_KERNEL);
+ kmalloc(BITS_TO_LONGS(MAX_OBJS_PER_PAGE) * sizeof(unsigned long), GFP_KERNEL);

Mikulas

>  	/*
>  	 * Determine the number of objects per slab
>  	 */
> 
