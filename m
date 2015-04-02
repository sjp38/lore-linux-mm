Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 98F826B0038
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 10:25:39 -0400 (EDT)
Received: by iedm5 with SMTP id m5so70209600ied.3
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 07:25:39 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id fs4si17739498igb.15.2015.04.02.07.25.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 02 Apr 2015 07:25:38 -0700 (PDT)
Date: Thu, 2 Apr 2015 09:25:37 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Slab infrastructure for bulk object allocation and freeing V2
In-Reply-To: <20150331142025.63249f2f0189aee231a6e0c8@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1504020922120.28416@gentwo.org>
References: <alpine.DEB.2.11.1503300927290.6646@gentwo.org> <20150331142025.63249f2f0189aee231a6e0c8@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linuxfoundation.org, Pekka Enberg <penberg@kernel.org>, iamjoonsoo@lge.com

On Tue, 31 Mar 2015, Andrew Morton wrote:

> This patch doesn't really do anything.  I guess nailing down the
> interface helps a bit.

Right.

> to modules.  And it isn't completely obvious, because the return
> semantics are weird.

Ok.

> What's the reason for returning a partial result when ENOMEM?  Some
> callers will throw away the partial result and simply fail out.  If a
> caller attempts to go ahead and use the partial result then great, but
> you can bet that nobody will actually runtime test this situation, so
> the interface is an invitation for us to release partially-tested code
> into the wild.

Just rely on the fact that small allocations never fail? The caller get
all the requested objects if the function returns?

> Instead of the above, did you consider doing
>
> int __weak kmem_cache_alloc_array(struct kmem_cache *s, gfp_t flags, size_t nr,
>
> ?
>
> This way we save a level of function call and all that wrapper code in
> the allocators simply disappears.

I think we will need the auxiliary function in the common code later
because that allows the allocations to only do the allocations that
can be optimized and for the rest just fall back to the generic
implementations. There may be situations in which the optimizations wont
work. For SLUB this may be the case f.e. if debug options are enabled.

> > --- linux.orig/mm/slab.c	2015-03-30 08:48:12.923927793 -0500
> > +++ linux/mm/slab.c	2015-03-30 08:49:08.398137844 -0500
> > @@ -3401,6 +3401,17 @@ void *kmem_cache_alloc(struct kmem_cache
> >  }
> >  EXPORT_SYMBOL(kmem_cache_alloc);
> >
> > +void kmem_cache_free_array(struct kmem_cache *s, size_t size, void **p) {
> > +	__kmem_cache_free_array(s, size, p);
> > +}
>
> Coding style is weird.

Ok. Will fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
