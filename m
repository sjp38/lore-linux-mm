Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id D18976B006C
	for <linux-mm@kvack.org>; Thu, 18 Dec 2014 17:06:32 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id n3so68424wiv.17
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 14:06:32 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ki1si14026448wjc.118.2014.12.18.14.06.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Dec 2014 14:06:32 -0800 (PST)
Date: Thu, 18 Dec 2014 14:06:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Slab infrastructure for array operations
Message-Id: <20141218140629.393972c7bd8b3b884507264c@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.11.1412181031520.2962@gentwo.org>
References: <alpine.DEB.2.11.1412181031520.2962@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, akpm@linuxfoundation.org, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>

On Thu, 18 Dec 2014 10:33:23 -0600 (CST) Christoph Lameter <cl@linux.com> wrote:

> This patch adds the basic infrastructure for alloc / free operations
> on pointer arrays.

Please provide the justification/reason for making this change.

> It includes a fallback function.

I don't know what this means.  Something to do with
_HAVE_SLAB_ALLOCATOR_OPERATIONS perhaps.

> Allocators must define _HAVE_SLAB_ALLOCATOR_OPERATIONS in their
> header files in order to implement their own fast version for
> these array operations.

Why?  What's driving this?

The changelog is far too skimpy, sorry.  It makes the patch
unreviewable.

> --- linux.orig/include/linux/slab.h	2014-12-16 09:27:26.369447763 -0600
> +++ linux/include/linux/slab.h	2014-12-18 10:30:33.394927526 -0600
> @@ -123,6 +123,7 @@ struct kmem_cache *memcg_create_kmem_cac
>  void kmem_cache_destroy(struct kmem_cache *);
>  int kmem_cache_shrink(struct kmem_cache *);
>  void kmem_cache_free(struct kmem_cache *, void *);
> +void kmem_cache_free_array(struct kmem_cache *, int, void **);

These declarations are much more useful if they include the argument
names.

> --- linux.orig/mm/slab_common.c	2014-12-12 10:27:49.360799479 -0600
> +++ linux/mm/slab_common.c	2014-12-18 10:25:41.695889129 -0600
> @@ -105,6 +105,31 @@ static inline int kmem_cache_sanity_chec
>  }
>  #endif
> 
> +#ifndef _HAVE_SLAB_ALLOCATOR_ARRAY_OPERATIONS
> +int kmem_cache_alloc_array(struct kmem_cache *s, gfp_t flags, int nr, void **p)
> +{
> +	int i;
> +
> +	for (i=0; i < nr; i++) {
> +		void *x = p[i] = kmem_cache_alloc(s, flags);
> +		if (!x)
> +			return i;
> +	}
> +	return nr;
> +}
> +EXPORT_SYMBOL(kmem_cache_alloc_array);

Please use checkpatch.

This function very much needs documentation.  Particularly concerning
the return value, and the caller's responsibility at cleanup time.

And that return value is weird.  What's the point in returning a
partial result?

Why is the memory exhaustion handling implemented this way rather than
zeroing out the rest of the array, so the caller doesn't have to
remember the return value for kmem_cache_free_array()?

> +void kmem_cache_free_array(struct kmem_cache *s, int nr, void **p)
> +{
> +	int i;
> +
> +	for (i=0; i < nr; i++)
> +		kmem_cache_free(s, p[i]);
> +}
> +EXPORT_SYMBOL(kmem_cache_free_array);

Possibly `nr' and `i' should be size_t, dunno.  They certainly don't
need to be signed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
