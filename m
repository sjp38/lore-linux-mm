Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5F5526B0254
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 10:43:22 -0500 (EST)
Received: by ioir85 with SMTP id r85so63365490ioi.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 07:43:22 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id d16si13351896igo.8.2015.12.09.07.43.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 Dec 2015 07:43:21 -0800 (PST)
Date: Wed, 9 Dec 2015 09:43:20 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH V2 1/9] mm/slab: move SLUB alloc hooks to common
 mm/slab.h
In-Reply-To: <20151208161827.21945.25463.stgit@firesoul>
Message-ID: <alpine.DEB.2.20.1512090941200.30894@east.gentwo.org>
References: <20151208161751.21945.53936.stgit@firesoul> <20151208161827.21945.25463.stgit@firesoul>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 8 Dec 2015, Jesper Dangaard Brouer wrote:

> +/* Q: Howto handle this nicely? below includes are needed for alloc hooks
> + *
> + * e.g. mm/mempool.c and mm/slab_common.c does not include kmemcheck.h
> + * including it here solves the probem, but should they include it
> + * themselves?
> + */

Including in mm/slab.h is enough.

> +#ifdef CONFIG_SLUB

Move this into slab_ksize?

> +static inline size_t slab_ksize(const struct kmem_cache *s)
> +{
> +#ifdef CONFIG_SLUB_DEBUG
> +	/*
> +	 * Debugging requires use of the padding between object
> +	 * and whatever may come after it.
> +	 */
> +	if (s->flags & (SLAB_RED_ZONE | SLAB_POISON))
> +		return s->object_size;
> +#endif
> +	/*
> +	 * If we have the need to store the freelist pointer
> +	 * back there or track user information then we can
> +	 * only use the space before that information.
> +	 */
> +	if (s->flags & (SLAB_DESTROY_BY_RCU | SLAB_STORE_USER))
> +		return s->inuse;
> +	/*
> +	 * Else we can use all the padding etc for the allocation
> +	 */
> +	return s->size;
> +}
> +#else /* !CONFIG_SLUB */

Abnd drop the else branch?

> +static inline size_t slab_ksize(const struct kmem_cache *s)
> +{
> +	return s->object_size;
> +}
> +#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
