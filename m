Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 112A46B01E7
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 10:28:50 -0400 (EDT)
Date: Mon, 21 Jun 2010 09:25:27 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: slub: remove dynamic dma slab allocation
In-Reply-To: <alpine.DEB.2.00.1006181513060.20110@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006210919400.4513@router.home>
References: <alpine.DEB.2.00.1006151406120.10865@router.home> <alpine.DEB.2.00.1006181513060.20110@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 Jun 2010, David Rientjes wrote:

> On Tue, 15 Jun 2010, Christoph Lameter wrote:
>
> > Index: linux-2.6/mm/slub.c
> > ===================================================================
> > --- linux-2.6.orig/mm/slub.c	2010-06-15 12:40:58.000000000 -0500
> > +++ linux-2.6/mm/slub.c	2010-06-15 12:41:36.000000000 -0500
> > @@ -2070,7 +2070,7 @@ init_kmem_cache_node(struct kmem_cache_n
> >
> >  static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[KMALLOC_CACHES]);
> >
> > -static inline int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
> > +static inline int alloc_kmem_cache_cpus(struct kmem_cache *s)
> >  {
> >  	if (s < kmalloc_caches + KMALLOC_CACHES && s >= kmalloc_caches)
>
> Looks like it'll conflict with "SLUB: is_kmalloc_cache" in slub/cleanups.

Yes I thought we dropped those.

> > @@ -2105,7 +2105,7 @@ static void early_kmem_cache_node_alloc(
> >
> >  	BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
> >
> > -	page = new_slab(kmalloc_caches, gfpflags, node);
> > +	page = new_slab(kmalloc_caches, GFP_KERNEL, node);
> >
> >  	BUG_ON(!page);
> >  	if (page_to_nid(page) != node) {
>
> Hmm, not sure of this.  We can't do GFP_KERNEL allocations in
> kmem_cache_init(), they must be deferred to kmem_cache_init_late().  So
> this will be allocating the kmem_cache_node cache while slab_state is
> still DOWN and yet passing GFP_KERNEL via early_kmem_cache_node_alloc().
>
> I think this has to be GFP_NOWAIT instead.

Ok we could use GFP_NOWAIT in this case.

> >  		if (slab_state == DOWN) {
> > -			early_kmem_cache_node_alloc(gfpflags, node);
> > +			early_kmem_cache_node_alloc(node);
> >  			continue;
> >  		}
> >  		n = kmem_cache_alloc_node(kmalloc_caches,
> > -						gfpflags, node);
> > +						GFP_KERNEL, node);
> >
> >  		if (!n) {
> >  			free_kmem_cache_nodes(s);
>
> Same here, this can still lead to GFP_KERNEL allocations from
> kmem_cache_init() because slab_state is PARTIAL or UP.

You cannot do that here because this function is also used later when the
slab is up. There is more in the percpu allocator which we are also trying
to use to avoid having static kmem_cache_cpu declarations. GFP_KERNEL
needs to be usable during early boot otherwise functions will have to add
special casing for boot situations.

> > +	for (i = 0; i < SLUB_PAGE_SHIFT; i++) {
> > +		struct kmem_cache *s = &kmalloc_caches[i];
> > +
> > +		if (s && s->size) {
> > +			char *name = kasprintf(GFP_KERNEL,
> > +				 "dma-kmalloc-%d", s->objsize);
>
> kasprintf() can return NULL which isn't caught by kmem_cache_open().

Then we will have a nameless cache. We could catch this with a WARN_ON()
but does this work that early?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
