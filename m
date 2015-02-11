Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id DC7E96B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 15:18:14 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id bs8so7852614wib.4
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 12:18:14 -0800 (PST)
Received: from mail-we0-x235.google.com (mail-we0-x235.google.com. [2a00:1450:400c:c03::235])
        by mx.google.com with ESMTPS id wl10si3432285wjb.18.2015.02.11.12.18.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 12:18:13 -0800 (PST)
Received: by mail-we0-f181.google.com with SMTP id w62so5801462wes.12
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 12:18:13 -0800 (PST)
Date: Wed, 11 Feb 2015 12:18:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] Slab infrastructure for array operations
In-Reply-To: <alpine.DEB.2.11.1502111243380.3887@gentwo.org>
Message-ID: <alpine.DEB.2.10.1502111213151.16711@chino.kir.corp.google.com>
References: <20150210194804.288708936@linux.com> <20150210194811.787556326@linux.com> <alpine.DEB.2.10.1502101542030.15535@chino.kir.corp.google.com> <alpine.DEB.2.11.1502111243380.3887@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, 11 Feb 2015, Christoph Lameter wrote:

> > This patch is referencing functions that don't exist and can do so since
> > it's not compiled, but I think this belongs in the next patch.  I also
> > think that this particular implementation may be slub-specific so I would
> > have expected just a call to an allocator-defined
> > __kmem_cache_alloc_array() here with i = __kmem_cache_alloc_array().
> 
> The implementation is generic and can be used in the same way for SLAB.
> SLOB does not have these types of object though.
> 

Ok, I didn't know if the slab implementation would follow the same format 
with the same callbacks or whether this would need to be cleaned up later.  

> > return 0 instead of using _HAVE_SLAB_ALLOCATOR_ARRAY_OPERATIONS at all.
> 
> Ok that is a good idea. I'll just drop that macro and have all allocators
> provide dummy functions.
> 
> > > +#ifndef _HAVE_SLAB_ALLOCATOR_ARRAY_OPERATIONS
> > > +void kmem_cache_free_array(struct kmem_cache *s, size_t nr, void **p)
> > > +{
> > > +	__kmem_cache_free_array(s, nr, p);
> > > +}
> > > +EXPORT_SYMBOL(kmem_cache_free_array);
> > > +#endif
> > > +
> >
> > Hmm, not sure why the allocator would be required to do the
> > EXPORT_SYMBOL() if it defines kmem_cache_free_array() itself.  This
> 
> Keeping the EXPORT with the definition is the custom as far as I could
> tell.
> 

If you do dummy functions for all the allocators, then this should be as 
simple as unconditionally defining kmem_cache_free_array() and doing 
EXPORT_SYMBOL() here and then using your current implementation of 
__kmem_cache_free_array() for mm/slab.c.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
