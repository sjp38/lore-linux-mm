Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4604B6B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 03:19:06 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so7252962pac.2
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 00:19:05 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ws2si191881pab.124.2015.06.16.00.19.04
        for <linux-mm@kvack.org>;
        Tue, 16 Jun 2015 00:19:05 -0700 (PDT)
Date: Tue, 16 Jun 2015 16:21:07 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/7] slub bulk alloc: extract objects from the per cpu
 slab
Message-ID: <20150616072107.GA13125@js1304-P5Q-DELUXE>
References: <20150615155053.18824.617.stgit@devil>
 <20150615155207.18824.8674.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150615155207.18824.8674.stgit@devil>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>

On Mon, Jun 15, 2015 at 05:52:07PM +0200, Jesper Dangaard Brouer wrote:
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
> Signed-off-by: Christoph Lameter <cl@linux.com>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>  mm/slub.c |   27 ++++++++++++++++++++++++++-
>  1 file changed, 26 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 80f17403e503..d18f8e195ac4 100644
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
> +	}
> +
> +	return __kmem_cache_alloc_bulk(s, flags, size, p);
>  }
>  EXPORT_SYMBOL(kmem_cache_alloc_bulk);

Now I found that we need to call slab_pre_alloc_hook() before any operation
on kmem_cache to support kmemcg accounting. And, we need to call
slab_post_alloc_hook() on every allocated objects to support many
debugging features like as kasan and kmemleak

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
