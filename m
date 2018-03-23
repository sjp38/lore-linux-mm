Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0E5556B000C
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 11:31:58 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 29so8092449qto.10
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 08:31:58 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g6si689576qto.11.2018.03.23.08.31.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 08:31:57 -0700 (PDT)
Date: Fri, 23 Mar 2018 11:31:54 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.DEB.2.20.1803230956420.4108@nuc-kabylake>
Message-ID: <alpine.LRH.2.02.1803231113410.22626@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com> <20180320173512.GA19669@bombadil.infradead.org> <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake> <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake> <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake> <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211354170.13978@nuc-kabylake> <alpine.LRH.2.02.1803211500570.26409@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211508560.17257@nuc-kabylake> <alpine.LRH.2.02.1803211613010.28365@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803230956420.4108@nuc-kabylake>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>



On Fri, 23 Mar 2018, Christopher Lameter wrote:

> On Wed, 21 Mar 2018, Mikulas Patocka wrote:
> 
> > > +	s->allocflags = allocflags;
> >
> > I'd also use "WRITE_ONCE(s->allocflags, allocflags)" here and when writing
> > s->oo and s->min to avoid some possible compiler misoptimizations.
> 
> It only matters that 0 etc is never written.

The C11 standard says that reads and writes of the same variable should't 
race (even if you write the same value as before), and consequently, the 
compiler can make transformations based on this assumption. For example, 
the compiler optimization may transform the following code

>       allocflags = 0;
>       if (order)
>               allocflags |= __GFP_COMP;
>       if (s->flags & SLAB_CACHE_DMA)
>               allocflags |= GFP_DMA;
>       if (s->flags & SLAB_RECLAIM_ACCOUNT)
>               allocflags |= __GFP_RECLAIMABLE;
>       s->allocflags = allocflags;

back into:
>	s->allocflags = 0;
>	if (order)
>		s->allocflags |= __GFP_COMP;
>	if (s->flags & SLAB_CACHE_DMA)
>		s->allocflags |= GFP_DMA;
>	if (s->flags & SLAB_RECLAIM_ACCOUNT)
>		s->allocflags |= __GFP_RECLAIMABLE;

Afaik, gcc currently doesn't do this transformation, but it's better to 
write standard-compliant code and use the macro WRITE_ONCE for variables 
that may be concurrently read and written.

> > Another problem is that it updates s->oo and later it updates s->max:
> >         s->oo = oo_make(order, size, s->reserved);
> >         s->min = oo_make(get_order(size), size, s->reserved);
> >         if (oo_objects(s->oo) > oo_objects(s->max))
> >                 s->max = s->oo;
> > --- so, the concurrently running code could see s->oo > s->max, which
> > could trigger some memory corruption.
> 
> Well s->max is only relevant for code that analyses the details of slab
> structures for diagnostics.
> 
> > s->max is only used in memory allocations -
> > kmalloc(BITS_TO_LONGS(oo_objects(s->max)) * sizeof(unsigned long)), so
> > perhaps we could fix the bug by removing s->max at all and always
> > allocating enough memory for the maximum possible number of objects?
> >
> > - kmalloc(BITS_TO_LONGS(oo_objects(s->max)) * sizeof(unsigned long), GFP_KERNEL);
> > + kmalloc(BITS_TO_LONGS(MAX_OBJS_PER_PAGE) * sizeof(unsigned long), GFP_KERNEL);
> 
> MAX_OBJS_PER_PAGE is 32k. So you are looking at contiguous allocations of
> 256kbyte. Not good.

I think it's one bit per object, so the total size of the allocation is 
4k. Allocating 4k shouldn't be a problem.

> The simplest measure would be to disallow the changing of the order while
> the slab contains objects.
> 
> 
> Subject: slub: Disallow order changes when objects exist in a slab
> 
> There seems to be a couple of races that would have to be
> addressed if the slab order would be changed during active use.
> 
> Lets disallow this in the same way as we also do not allow
> other changes of slab characteristics when objects are active.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c
> +++ linux/mm/slub.c
> @@ -4919,6 +4919,9 @@ static ssize_t order_store(struct kmem_c
>  	unsigned long order;
>  	int err;
> 
> +	if (any_slab_objects(s))
> +		return -EBUSY;
> +
>  	err = kstrtoul(buf, 10, &order);
>  	if (err)
>  		return err;

This test isn't locked against anything, so it may race with concurrent 
allocation. "any_slab_objects" may return false and a new object in the 
slab cache may appear immediatelly after that.

Mikulas
