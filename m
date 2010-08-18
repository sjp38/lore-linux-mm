Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C9AA06B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 10:46:29 -0400 (EDT)
Date: Wed, 18 Aug 2010 09:46:26 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q Cleanup 2/6] slub: remove dynamic dma slab allocation
In-Reply-To: <alpine.DEB.2.00.1008171615050.1563@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1008180919490.4025@router.home>
References: <20100817211118.958108012@linux.com> <20100817211135.529953112@linux.com> <alpine.DEB.2.00.1008171615050.1563@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Aug 2010, David Rientjes wrote:

> > -	page = new_slab(kmalloc_caches, gfpflags, node);
> > +	page = new_slab(kmalloc_caches, GFP_KERNEL, node);
> >
> >  	BUG_ON(!page);
> >  	if (page_to_nid(page) != node) {
>
> early_kmem_cache_node_alloc() is called when we don't have a
> gfp_allowed_mask, so this is actually GFP_NOWAIT.

The page allocator will do the conversion anyway but I will update it. We
cannot do this consistenly for code sections that can be run both at boot
time and later though.

> > +	for (i = 1; i < SLUB_PAGE_SHIFT; i++) {
> > +		struct kmem_cache *s = &kmalloc_caches[i];
> > +
> > +		if (s->size) {
> > +			char *name = kasprintf(GFP_KERNEL,
> > +				 "dma-kmalloc-%d", s->objsize);
>
> Same for this, it's GFP_NOWAIT.
>
> There's no actual bug with either of those since the bits get masked off,
> but the code is clearer if the allocation context is known to be during
> early boot.

Ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
