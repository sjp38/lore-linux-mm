Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 488E16B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 13:47:44 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id k15so4065580qaq.12
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 10:47:44 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id 96si1848236qgh.88.2015.02.11.10.47.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 11 Feb 2015 10:47:43 -0800 (PST)
Date: Wed, 11 Feb 2015 12:47:41 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] Slab infrastructure for array operations
In-Reply-To: <alpine.DEB.2.10.1502101542030.15535@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.11.1502111243380.3887@gentwo.org>
References: <20150210194804.288708936@linux.com> <20150210194811.787556326@linux.com> <alpine.DEB.2.10.1502101542030.15535@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Tue, 10 Feb 2015, David Rientjes wrote:

> > +int kmem_cache_alloc_array(struct kmem_cache *s,
> > +		gfp_t flags, size_t nr, void **p)
> > +{
> > +	int i = 0;
> > +
> > +#ifdef _HAVE_SLAB_ALLOCATOR_ARRAY_OPERATIONS
> > +	/*

...

> > +		i += slab_array_alloc_from_local(s, nr - i, p + i);
> > +
> > +#endif
>
> This patch is referencing functions that don't exist and can do so since
> it's not compiled, but I think this belongs in the next patch.  I also
> think that this particular implementation may be slub-specific so I would
> have expected just a call to an allocator-defined
> __kmem_cache_alloc_array() here with i = __kmem_cache_alloc_array().

The implementation is generic and can be used in the same way for SLAB.
SLOB does not have these types of object though.

> return 0 instead of using _HAVE_SLAB_ALLOCATOR_ARRAY_OPERATIONS at all.

Ok that is a good idea. I'll just drop that macro and have all allocators
provide dummy functions.

> > +#ifndef _HAVE_SLAB_ALLOCATOR_ARRAY_OPERATIONS
> > +void kmem_cache_free_array(struct kmem_cache *s, size_t nr, void **p)
> > +{
> > +	__kmem_cache_free_array(s, nr, p);
> > +}
> > +EXPORT_SYMBOL(kmem_cache_free_array);
> > +#endif
> > +
>
> Hmm, not sure why the allocator would be required to do the
> EXPORT_SYMBOL() if it defines kmem_cache_free_array() itself.  This

Keeping the EXPORT with the definition is the custom as far as I could
tell.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
