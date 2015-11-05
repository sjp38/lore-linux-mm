Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f45.google.com (mail-lf0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id EC7A482F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 11:18:23 -0500 (EST)
Received: by lfgh9 with SMTP id h9so59840216lfg.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 08:18:23 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id j185si4860499lfg.59.2015.11.05.08.18.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 08:18:22 -0800 (PST)
Date: Thu, 5 Nov 2015 19:18:05 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH V2 1/2] slub: fix kmem cgroup bug in kmem_cache_alloc_bulk
Message-ID: <20151105161805.GH29259@esperanza>
References: <20151105153704.1115.10475.stgit@firesoul>
 <20151105153744.1115.38620.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151105153744.1115.38620.stgit@firesoul>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On Thu, Nov 05, 2015 at 04:37:51PM +0100, Jesper Dangaard Brouer wrote:
...
> @@ -1298,7 +1298,6 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s,
>  	flags &= gfp_allowed_mask;
>  	kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
>  	kmemleak_alloc_recursive(object, s->object_size, 1, s->flags, flags);
> -	memcg_kmem_put_cache(s);
>  	kasan_slab_alloc(s, object);
>  }
>  
> @@ -2557,6 +2556,7 @@ redo:
>  		memset(object, 0, s->object_size);
>  
>  	slab_post_alloc_hook(s, gfpflags, object);
> +	memcg_kmem_put_cache(s);

Asymmetric - not good IMO. What about passing array of allocated objects
to slab_post_alloc_hook? Then we could leave memcg_kmem_put_cache where
it is now. I.e here we'd have

	slab_post_alloc_hook(s, gfpflags, &object, 1);

while in kmem_cache_alloc_bulk it'd look like

	slab_post_alloc_hook(s, flags, p, size);

right before return.

>  
>  	return object;
>  }
> @@ -2906,6 +2906,11 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
>  	struct kmem_cache_cpu *c;
>  	int i;
>  
> +	/* memcg and kmem_cache debug support */
> +	s = slab_pre_alloc_hook(s, flags);
> +	if (unlikely(!s))
> +		return false;
> +
>  	/*
>  	 * Drain objects in the per cpu slab, while disabling local
>  	 * IRQs, which protects against PREEMPT and interrupts
> @@ -2931,11 +2936,6 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
>  			continue; /* goto for-loop */
>  		}
>  
> -		/* kmem_cache debug support */
> -		s = slab_pre_alloc_hook(s, flags);
> -		if (unlikely(!s))
> -			goto error;
> -
>  		c->freelist = get_freepointer(s, object);
>  		p[i] = object;
>  
> @@ -2953,9 +2953,11 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
>  			memset(p[j], 0, s->object_size);
>  	}
>  
> +	memcg_kmem_put_cache(s);
>  	return true;
>  
>  error:
> +	memcg_kmem_put_cache(s);

It drops a reference to the cache so better to call it after you are
done with the cache, i.e. right before 'return false'.

Thanks,
Vladimir

>  	__kmem_cache_free_bulk(s, i, p);
>  	local_irq_enable();
>  	return false;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
