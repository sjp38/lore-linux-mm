Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id B64216B0080
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 18:53:06 -0400 (EDT)
Received: by pdea3 with SMTP id a3so130610462pde.3
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 15:53:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id hn5si7629388pac.180.2015.04.08.15.53.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Apr 2015 15:53:05 -0700 (PDT)
Date: Wed, 8 Apr 2015 15:53:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: slub bulk alloc: Extract objects from the per cpu slab
Message-Id: <20150408155304.4480f11f16b60f09879c350d@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.11.1504081311070.20469@gentwo.org>
References: <alpine.DEB.2.11.1504081311070.20469@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: brouer@redhat.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Wed, 8 Apr 2015 13:13:29 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:

> First piece: accelleration of retrieval of per cpu objects
> 
> 
> If we are allocating lots of objects then it is advantageous to
> disable interrupts and avoid the this_cpu_cmpxchg() operation to
> get these objects faster. Note that we cannot do the fast operation
> if debugging is enabled.

Why can't we do it if debugging is enabled?

> Note also that the requirement of having
> interrupts disabled avoids having to do processor flag operations.
> 
> Allocate as many objects as possible in the fast way and then fall
> back to the generic implementation for the rest of the objects.

Seems sane.  What's the expected success rate of the initial bulk
allocation attempt?

> --- linux.orig/mm/slub.c
> +++ linux/mm/slub.c
> @@ -2761,7 +2761,32 @@ EXPORT_SYMBOL(kmem_cache_free_bulk);
>  bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
>  								void **p)
>  {
> -	return kmem_cache_alloc_bulk(s, flags, size, p);
> +	if (!kmem_cache_debug(s)) {
> +		struct kmem_cache_cpu *c;
> +
> +		/* Drain objects in the per cpu slab */
> +		local_irq_disable();
> +		c = this_cpu_ptr(s->cpu_slab);
> +
> +		while (size) {
> +			void *object = c->freelist;
> +
> +			if (!object)
> +				break;
> +
> +			c->freelist = get_freepointer(s, object);
> +			*p++ = object;
> +			size--;
> +
> +			if (unlikely(flags & __GFP_ZERO))
> +				memset(object, 0, s->object_size);
> +		}
> +		c->tid = next_tid(c->tid);
> +
> +		local_irq_enable();
> +	}
> +
> +	return __kmem_cache_alloc_bulk(s, flags, size, p);

This kmem_cache_cpu.tid logic is a bit opaque.  The low-level
operations seem reasonably well documented but I couldn't find anywhere
which tells me how it all actually works - what is "disambiguation
during cmpxchg" and how do we achieve it?


I'm in two minds about putting
slab-infrastructure-for-bulk-object-allocation-and-freeing-v3.patch and
slub-bulk-alloc-extract-objects-from-the-per-cpu-slab.patch into 4.1. 
They're standalone (ie: no in-kernel callers!) hence harmless, and
merging them will make Jesper's life a bit easier.  But otoh they are
unproven and have no in-kernel callers, so formally they shouldn't be
merged yet.  I suppose we can throw them away again if things don't
work out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
