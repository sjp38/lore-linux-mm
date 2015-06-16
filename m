Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 35D106B0032
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 17:48:42 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so22904632pdj.3
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 14:48:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s7si3073381pdl.14.2015.06.16.14.48.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 14:48:41 -0700 (PDT)
Date: Tue, 16 Jun 2015 14:48:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/7] slub bulk alloc: extract objects from the per cpu
 slab
Message-Id: <20150616144840.1b669e149d937365a4b54c1c@linux-foundation.org>
In-Reply-To: <20150615155207.18824.8674.stgit@devil>
References: <20150615155053.18824.617.stgit@devil>
	<20150615155207.18824.8674.stgit@devil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>

On Mon, 15 Jun 2015 17:52:07 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> From: Christoph Lameter <cl@linux.com>
> 
> [NOTICE: Already in AKPM's quilt-queue]
> 
> First piece: acceleration of retrieval of per cpu objects
> 
> If we are allocating lots of objects then it is advantageous to disable
> interrupts and avoid the this_cpu_cmpxchg() operation to get these objects
> faster.
> 
> Note that we cannot do the fast operation if debugging is enabled, because
> we would have to add extra code to do all the debugging checks.  And it
> would not be fast anyway.
> 
> Note also that the requirement of having interrupts disabled
> avoids having to do processor flag operations.
> 
> Allocate as many objects as possible in the fast way and then fall back to
> the generic implementation for the rest of the objects.
> 
> ...
>
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2759,7 +2759,32 @@ EXPORT_SYMBOL(kmem_cache_free_bulk);
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

It might be worth adding

		if (!size)
			return true;

here.  To avoid the pointless call to __kmem_cache_alloc_bulk().

It depends on the typical success rate of this allocation loop.  Do you
know what this is?

> +	}
> +
> +	return __kmem_cache_alloc_bulk(s, flags, size, p);
>  }
>  EXPORT_SYMBOL(kmem_cache_alloc_bulk);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
