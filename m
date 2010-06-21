Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E6E7E6B01AD
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 15:56:35 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o5LJuSut020452
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 12:56:28 -0700
Received: from pwi3 (pwi3.prod.google.com [10.241.219.3])
	by wpaz17.hot.corp.google.com with ESMTP id o5LJu4IA015321
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 12:56:27 -0700
Received: by pwi3 with SMTP id 3so748912pwi.40
        for <linux-mm@kvack.org>; Mon, 21 Jun 2010 12:56:26 -0700 (PDT)
Date: Mon, 21 Jun 2010 12:56:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: slub: remove dynamic dma slab allocation
In-Reply-To: <alpine.DEB.2.00.1006210919400.4513@router.home>
Message-ID: <alpine.DEB.2.00.1006211234230.8367@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006151406120.10865@router.home> <alpine.DEB.2.00.1006181513060.20110@chino.kir.corp.google.com> <alpine.DEB.2.00.1006210919400.4513@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 21 Jun 2010, Christoph Lameter wrote:

> > >  		if (slab_state == DOWN) {
> > > -			early_kmem_cache_node_alloc(gfpflags, node);
> > > +			early_kmem_cache_node_alloc(node);
> > >  			continue;
> > >  		}
> > >  		n = kmem_cache_alloc_node(kmalloc_caches,
> > > -						gfpflags, node);
> > > +						GFP_KERNEL, node);
> > >
> > >  		if (!n) {
> > >  			free_kmem_cache_nodes(s);
> >
> > Same here, this can still lead to GFP_KERNEL allocations from
> > kmem_cache_init() because slab_state is PARTIAL or UP.
> 
> You cannot do that here because this function is also used later when the
> slab is up. There is more in the percpu allocator which we are also trying
> to use to avoid having static kmem_cache_cpu declarations. GFP_KERNEL
> needs to be usable during early boot otherwise functions will have to add
> special casing for boot situations.
> 

The gfp_allowed_mask only changes once irqs are enabled, so either the 
gfpflags need to be passed into init_kmem_cache_nodes again or we need to 
do something like

	gfp_t gfpflags = irqs_disabled() ? GFP_NOWAIT : GFP_KERNEL;

locally.

The cleanest solution would probably be to extend slab_state to be set in 
kmem_cache_init_late() to determine when we're fully initialized, though.

> > > +	for (i = 0; i < SLUB_PAGE_SHIFT; i++) {
> > > +		struct kmem_cache *s = &kmalloc_caches[i];
> > > +
> > > +		if (s && s->size) {
> > > +			char *name = kasprintf(GFP_KERNEL,
> > > +				 "dma-kmalloc-%d", s->objsize);
> >
> > kasprintf() can return NULL which isn't caught by kmem_cache_open().
> 
> Then we will have a nameless cache. We could catch this with a WARN_ON()
> but does this work that early?
> 

It works, but this seems to be a forced

	if (WARN_ON(!name))
		continue;

because although it appears that s->name can be NULL within the slub 
layer, the sysfs layer would result in a NULL pointer dereference for 
things like strcmp() when looking up the cache's dirent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
