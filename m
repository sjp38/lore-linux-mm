Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id AC2046B0071
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 17:20:27 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so32786350pdb.1
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 14:20:27 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ur3si19889608pac.8.2015.03.31.14.20.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Mar 2015 14:20:26 -0700 (PDT)
Date: Tue, 31 Mar 2015 14:20:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Slab infrastructure for bulk object allocation and freeing V2
Message-Id: <20150331142025.63249f2f0189aee231a6e0c8@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.11.1503300927290.6646@gentwo.org>
References: <alpine.DEB.2.11.1503300927290.6646@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linuxfoundation.org, Pekka Enberg <penberg@kernel.org>, iamjoonsoo@lge.com

On Mon, 30 Mar 2015 09:31:19 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:

> After all of the earlier discussions I thought it would be better to
> first get agreement on the basic way to allow implementation of the
> bulk alloc in the common slab code. So this is a revision of the initial
> proposal and it just covers the first patch.
> 
> 
> 
> This patch adds the basic infrastructure for alloc / free operations
> on pointer arrays. It includes a generic function in the common
> slab code that is used in this infrastructure patch to
> create the unoptimized functionality for slab bulk operations.
> 
> Allocators can then provide optimized allocation functions
> for situations in which large numbers of objects are needed.
> These optimization may avoid taking locks repeatedly and
> bypass metadata creation if all objects in slab pages
> can be used to provide the objects required.

This patch doesn't really do anything.  I guess nailing down the
interface helps a bit.


> @@ -289,6 +289,8 @@ static __always_inline int kmalloc_index
>  void *__kmalloc(size_t size, gfp_t flags);
>  void *kmem_cache_alloc(struct kmem_cache *, gfp_t flags);
>  void kmem_cache_free(struct kmem_cache *, void *);
> +void kmem_cache_free_array(struct kmem_cache *, size_t, void **);
> +int kmem_cache_alloc_array(struct kmem_cache *, gfp_t, size_t, void **);
> 
>  #ifdef CONFIG_NUMA
>  void *__kmalloc_node(size_t size, gfp_t flags, int node);
> Index: linux/mm/slab_common.c
> ===================================================================
> --- linux.orig/mm/slab_common.c	2015-03-30 08:48:12.923927793 -0500
> +++ linux/mm/slab_common.c	2015-03-30 08:57:41.737572817 -0500
> @@ -105,6 +105,29 @@ static inline int kmem_cache_sanity_chec
>  }
>  #endif
> 
> +int __kmem_cache_alloc_array(struct kmem_cache *s, gfp_t flags, size_t nr,
> +								void **p)
> +{
> +	size_t i;
> +
> +	for (i = 0; i < nr; i++) {
> +		void *x = p[i] = kmem_cache_alloc(s, flags);
> +		if (!x)
> +			return i;
> +	}
> +	return nr;
> +}

Some documentation would be nice.  It's a major new interface, exported
to modules.  And it isn't completely obvious, because the return
semantics are weird.

What's the reason for returning a partial result when ENOMEM?  Some
callers will throw away the partial result and simply fail out.  If a
caller attempts to go ahead and use the partial result then great, but
you can bet that nobody will actually runtime test this situation, so
the interface is an invitation for us to release partially-tested code
into the wild.


Instead of the above, did you consider doing

int __weak kmem_cache_alloc_array(struct kmem_cache *s, gfp_t flags, size_t nr,

?

This way we save a level of function call and all that wrapper code in
the allocators simply disappears.

> --- linux.orig/mm/slab.c	2015-03-30 08:48:12.923927793 -0500
> +++ linux/mm/slab.c	2015-03-30 08:49:08.398137844 -0500
> @@ -3401,6 +3401,17 @@ void *kmem_cache_alloc(struct kmem_cache
>  }
>  EXPORT_SYMBOL(kmem_cache_alloc);
> 
> +void kmem_cache_free_array(struct kmem_cache *s, size_t size, void **p) {
> +	__kmem_cache_free_array(s, size, p);
> +}

Coding style is weird.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
