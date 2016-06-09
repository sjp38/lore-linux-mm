Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 96DD16B007E
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 12:44:33 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w9so51516067oia.3
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 09:44:33 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0135.outbound.protection.outlook.com. [157.56.112.135])
        by mx.google.com with ESMTPS id l73si3425208otl.74.2016.06.09.09.44.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 09 Jun 2016 09:44:32 -0700 (PDT)
Subject: Re: [PATCH] mm, kasan: switch SLUB to stackdepot, enable memory
 quarantine for SLUB
References: <1465411243-102618-1-git-send-email-glider@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <57599D1C.2080701@virtuozzo.com>
Date: Thu, 9 Jun 2016 19:45:16 +0300
MIME-Version: 1.0
In-Reply-To: <1465411243-102618-1-git-send-email-glider@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, kuthonuzo.luruo@hpe.com
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 06/08/2016 09:40 PM, Alexander Potapenko wrote:
> For KASAN builds:
>  - switch SLUB allocator to using stackdepot instead of storing the
>    allocation/deallocation stacks in the objects;
>  - define SLAB_RED_ZONE, SLAB_POISON, SLAB_STORE_USER to zero,
>    effectively disabling these debug features, as they're redundant in
>    the presence of KASAN;

Instead of having duplicated functionality, I think it might be better to switch SLAB_STORE_USER to stackdepot instead.
Because now, we have two piles of code which do basically the same thing, but
do differently.

>  - refactor the slab freelist hook, put freed memory into the quarantine.
> 

What you did with slab_freelist_hook() is not refactoring, it's an obfuscation.


>  }
>  
> -#ifdef CONFIG_SLAB
>  /*
>   * Adaptive redzone policy taken from the userspace AddressSanitizer runtime.
>   * For larger allocations larger redzones are used.
> @@ -372,17 +371,21 @@ static size_t optimal_redzone(size_t object_size)
>  void kasan_cache_create(struct kmem_cache *cache, size_t *size,
>  			unsigned long *flags)
>  {
> -	int redzone_adjust;
> -	/* Make sure the adjusted size is still less than
> -	 * KMALLOC_MAX_CACHE_SIZE.
> -	 * TODO: this check is only useful for SLAB, but not SLUB. We'll need
> -	 * to skip it for SLUB when it starts using kasan_cache_create().
> +	int redzone_adjust, orig_size = *size;
> +
> +#ifdef CONFIG_SLAB
> +	/*
> +	 * Make sure the adjusted size is still less than
> +	 * KMALLOC_MAX_CACHE_SIZE, i.e. we don't use the page allocator.
>  	 */
> +
>  	if (*size > KMALLOC_MAX_CACHE_SIZE -

This is wrong. You probably wanted KMALLOC_MAX_SIZE here.

However, we should get rid of SLAB_KASAN altogether. It's absolutely useless, and only complicates
the code. And if we don't fit in KMALLOC_MAX_SIZE, just don't create cache.

>  	    sizeof(struct kasan_alloc_meta) -
>  	    sizeof(struct kasan_free_meta))
>  		return;
> +#endif
>  	*flags |= SLAB_KASAN;
> +
>  	/* Add alloc meta. */
>  	cache->kasan_info.alloc_meta_offset = *size;
>  	*size += sizeof(struct kasan_alloc_meta);
> @@ -392,17 +395,37 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
>  	    cache->object_size < sizeof(struct kasan_free_meta)) {
>  		cache->kasan_info.free_meta_offset = *size;
>  		*size += sizeof(struct kasan_free_meta);
> +	} else {
> +		cache->kasan_info.free_meta_offset = 0;
>  	}
>  	redzone_adjust = optimal_redzone(cache->object_size) -
>  		(*size - cache->object_size);
> +
>  	if (redzone_adjust > 0)
>  		*size += redzone_adjust;
> +
> +#ifdef CONFIG_SLAB
>  	*size = min(KMALLOC_MAX_CACHE_SIZE,
>  		    max(*size,
>  			cache->object_size +
>  			optimal_redzone(cache->object_size)));
> -}
> +	/*
> +	 * If the metadata doesn't fit, disable KASAN at all.
> +	 */
> +	if (*size <= cache->kasan_info.alloc_meta_offset ||
> +			*size <= cache->kasan_info.free_meta_offset) {
> +		*flags &= ~SLAB_KASAN;
> +		*size = orig_size;
> +		cache->kasan_info.alloc_meta_offset = -1;
> +		cache->kasan_info.free_meta_offset = -1;
> +	}
> +#else
> +	*size = max(*size,
> +			cache->object_size +
> +			optimal_redzone(cache->object_size));
> +
>  #endif
> +}
>  
>  void kasan_cache_shrink(struct kmem_cache *cache)
>  {
> @@ -431,16 +454,14 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object)
>  	kasan_poison_shadow(object,
>  			round_up(cache->object_size, KASAN_SHADOW_SCALE_SIZE),
>  			KASAN_KMALLOC_REDZONE);
> -#ifdef CONFIG_SLAB
>  	if (cache->flags & SLAB_KASAN) {
>  		struct kasan_alloc_meta *alloc_info =
>  			get_alloc_info(cache, object);
> -		alloc_info->state = KASAN_STATE_INIT;
> +		if (alloc_info)

If I read the code right alloc_info can be NULL only if SLAB_KASAN is set.


> +			alloc_info->state = KASAN_STATE_INIT;
>  	}
> -#endif
>  }
>  
> -#ifdef CONFIG_SLAB
>  static inline int in_irqentry_text(unsigned long ptr)
>  {
>  	return (ptr >= (unsigned long)&__irqentry_text_start &&
> @@ -492,6 +513,8 @@ struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
>  					const void *object)
>  {
>  	BUILD_BUG_ON(sizeof(struct kasan_alloc_meta) > 32);
> +	if (cache->kasan_info.alloc_meta_offset == -1)
> +		return NULL;

What's the point of this ? This should be always false.

>  	return (void *)object + cache->kasan_info.alloc_meta_offset;
>  }
>  
> @@ -499,9 +522,10 @@ struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
>  				      const void *object)
>  {
>  	BUILD_BUG_ON(sizeof(struct kasan_free_meta) > 32);
> +	if (cache->kasan_info.free_meta_offset == -1)
> +		return NULL;
>  	return (void *)object + cache->kasan_info.free_meta_offset;
>  }
> -#endif
>  
>  void kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
>  {
> @@ -522,7 +546,6 @@ void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
>  
>  bool kasan_slab_free(struct kmem_cache *cache, void *object)
>  {
> -#ifdef CONFIG_SLAB
>  	/* RCU slabs could be legally used after free within the RCU period */
>  	if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
>  		return false;
> @@ -532,7 +555,10 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object)
>  			get_alloc_info(cache, object);
>  		struct kasan_free_meta *free_info =
>  			get_free_info(cache, object);
> -
> +		WARN_ON(!alloc_info);
> +		WARN_ON(!free_info);
> +		if (!alloc_info || !free_info)
> +			return;

Again, never possible.


>  		switch (alloc_info->state) {
>  		case KASAN_STATE_ALLOC:
>  			alloc_info->state = KASAN_STATE_QUARANTINE;
> @@ -550,10 +576,6 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object)
>  		}
>  	}
>  	return false;
> -#else
> -	kasan_poison_slab_free(cache, object);
> -	return false;
> -#endif
>  }
>  
>  void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
> @@ -568,24 +590,29 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
>  	if (unlikely(object == NULL))
>  		return;
>  
> +	if (!(cache->flags & SLAB_KASAN))
> +		return;
> +
>  	redzone_start = round_up((unsigned long)(object + size),
>  				KASAN_SHADOW_SCALE_SIZE);
>  	redzone_end = round_up((unsigned long)object + cache->object_size,
>  				KASAN_SHADOW_SCALE_SIZE);
>  
>  	kasan_unpoison_shadow(object, size);
> +	WARN_ON(redzone_start > redzone_end);
> +	if (redzone_start > redzone_end)

How that's can happen? 

> +		return;
>  	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
>  		KASAN_KMALLOC_REDZONE);
> -#ifdef CONFIG_SLAB
>  	if (cache->flags & SLAB_KASAN) {
>  		struct kasan_alloc_meta *alloc_info =
>  			get_alloc_info(cache, object);
> -
> -		alloc_info->state = KASAN_STATE_ALLOC;
> -		alloc_info->alloc_size = size;
> -		set_track(&alloc_info->track, flags);
> +		if (alloc_info) {

And again...


> +			alloc_info->state = KASAN_STATE_ALLOC;
> +			alloc_info->alloc_size = size;
> +			set_track(&alloc_info->track, flags);
> +		}
>  	}
> -#endif
>  }
>  EXPORT_SYMBOL(kasan_kmalloc);
>  


[..]

> diff --git a/mm/slab.h b/mm/slab.h
> index dedb1a9..fde1fea 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -366,6 +366,10 @@ static inline size_t slab_ksize(const struct kmem_cache *s)
>  	if (s->flags & (SLAB_RED_ZONE | SLAB_POISON))
>  		return s->object_size;
>  # endif
> +# ifdef CONFIG_KASAN

Gush, you love ifdefs, don't you? Hint: it's redundant here.

> +	if (s->flags & SLAB_KASAN)
> +		return s->object_size;
> +# endif
>  	/*
>  	 * If we have the need to store the freelist pointer
...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
