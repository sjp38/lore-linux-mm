Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 18A426B01B8
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 11:41:39 -0400 (EDT)
Date: Tue, 29 Jun 2010 10:31:03 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q 08/16] slub: remove dynamic dma slab allocation
In-Reply-To: <alpine.DEB.2.00.1006261643360.27174@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006291026470.16135@router.home>
References: <20100625212026.810557229@quilx.com> <20100625212105.765531312@quilx.com> <alpine.DEB.2.00.1006261643360.27174@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Sat, 26 Jun 2010, David Rientjes wrote:

> > -	page = new_slab(kmalloc_caches, gfpflags, node);
> > +	page = new_slab(kmalloc_caches, GFP_KERNEL, node);
> >
> >  	BUG_ON(!page);
> >  	if (page_to_nid(page) != node) {
>
> This still passes GFP_KERNEL to the page allocator when not allowed by
> gfp_allowed_mask for early (non SLAB_CACHE_DMA) users of
> create_kmalloc_cache().

Right a later patch changes that. I could fold that hunk in here.

> > @@ -2157,11 +2157,11 @@ static int init_kmem_cache_nodes(struct
> >  		struct kmem_cache_node *n;
> >
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
> slab_state != DOWN is still not an indication that GFP_KERNEL is safe; in
> fact, all users of GFP_KERNEL from kmem_cache_init() are unsafe.  These
> need to be GFP_NOWAIT.

slab_state == DOWN is a sure indicator that kmem_cache_alloc_node is not
functional. That is what we need to know here.

> > +#ifdef CONFIG_ZONE_DMA
> > +	int i;
> > +
> > +	for (i = 0; i < SLUB_PAGE_SHIFT; i++) {
> > +		struct kmem_cache *s = &kmalloc_caches[i];
> > +
> > +		if (s && s->size) {
> > +			char *name = kasprintf(GFP_KERNEL,
> > +				 "dma-kmalloc-%d", s->objsize);
> > +
>
> You're still not handling the case where !name, which kasprintf() can
> return both here and in kmem_cache_init().  Nameless caches aren't allowed
> for CONFIG_SLUB_DEBUG.

It was not handled before either. I can come up with a patch but frankly
this is a rare corner case that does not have too high priority to get
done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
