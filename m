Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id EAEB36B0005
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 12:59:30 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id k78so107849130ioi.2
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 09:59:30 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0133.outbound.protection.outlook.com. [104.47.1.133])
        by mx.google.com with ESMTPS id f130si3333018itf.47.2016.07.08.09.59.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 08 Jul 2016 09:59:29 -0700 (PDT)
Subject: Re: [PATCH v6] mm, kasan: switch SLUB to stackdepot, enable memory
 quarantine for SLUB
References: <1467974210-117852-1-git-send-email-glider@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <577FDC2C.9030400@virtuozzo.com>
Date: Fri, 8 Jul 2016 20:00:28 +0300
MIME-Version: 1.0
In-Reply-To: <1467974210-117852-1-git-send-email-glider@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, kuthonuzo.luruo@hpe.com
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 07/08/2016 01:36 PM, Alexander Potapenko wrote:
>  
> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> index d1faa01..07e4549 100644
> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h
> @@ -99,6 +99,10 @@ struct kmem_cache {
>  	 */
>  	int remote_node_defrag_ratio;
>  #endif
> +#ifdef CONFIG_KASAN
> +	struct kasan_cache kasan_info;
> +#endif
> +
>  	struct kmem_cache_node *node[MAX_NUMNODES];
>  };
>  
> @@ -119,10 +123,11 @@ static inline void *nearest_obj(struct kmem_cache *cache, struct page *page,
>  	void *object = x - (x - page_address(page)) % cache->size;
>  	void *last_object = page_address(page) +
>  		(page->objects - 1) * cache->size;
> -	if (unlikely(object > last_object))
> -		return last_object;
> -	else
> -		return object;
> +	void *result = (unlikely(object > last_object)) ? last_object : object;
> +
> +	if (cache->flags & SLAB_RED_ZONE)
> +		return ((char *)result + cache->red_left_pad);
> +	return result;

This fixes existing problem. It should be a separate patch. 


>  
>  void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
> @@ -568,6 +572,9 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
>  	if (unlikely(object == NULL))
>  		return;
>  
> +	if (!(cache->flags & SLAB_KASAN))
> +		return;
> +

I still think that this hunk should be removed.

>  	redzone_start = round_up((unsigned long)(object + size),
>  				KASAN_SHADOW_SCALE_SIZE);
>  	redzone_end = round_up((unsigned long)object + cache->object_size,
> @@ -576,7 +583,6 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
>  	kasan_unpoison_shadow(object, size);
>  	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
>  		KASAN_KMALLOC_REDZONE);
> -#ifdef CONFIG_SLAB
>  	if (cache->flags & SLAB_KASAN) {
>  		struct kasan_alloc_meta *alloc_info =
>  			get_alloc_info(cache, object);
> @@ -585,7 +591,6 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
>  		alloc_info->alloc_size = size;
>  		set_track(&alloc_info->track, flags);
>  	}
> -#endif
>  }
>  EXPORT_SYMBOL(kasan_kmalloc);
>  


...


> diff --git a/mm/slab.h b/mm/slab.h
> index dedb1a9..9a09d06 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -366,6 +366,8 @@ static inline size_t slab_ksize(const struct kmem_cache *s)
>  	if (s->flags & (SLAB_RED_ZONE | SLAB_POISON))
>  		return s->object_size;
>  # endif
> +	if (s->flags & SLAB_KASAN)
> +		return s->object_size;
>  	/*
>  	 * If we have the need to store the freelist pointer
>  	 * back there or track user information then we can
> @@ -462,6 +464,7 @@ void *slab_next(struct seq_file *m, void *p, loff_t *pos);
>  void slab_stop(struct seq_file *m, void *p);
>  int memcg_slab_show(struct seq_file *m, void *p);
>  
> -void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr);
> +void *nearest_obj(struct kmem_cache *cache, struct page *page, void *x);

Remove.

> +void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr);
>  #endif /* MM_SLAB_H */
> diff --git a/mm/slub.c b/mm/slub.c
> index 825ff45..72ecffa 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -454,8 +454,6 @@ static inline void *restore_red_left(struct kmem_cache *s, void *p)
>   */
>  #if defined(CONFIG_SLUB_DEBUG_ON)
>  static int slub_debug = DEBUG_DEFAULT_FLAGS;
> -#elif defined(CONFIG_KASAN)
> -static int slub_debug = SLAB_STORE_USER;
>  #else
>  static int slub_debug;
>  #endif
> @@ -783,6 +781,14 @@ static int check_pad_bytes(struct kmem_cache *s, struct page *page, u8 *p)
>  		/* Freepointer is placed after the object. */
>  		off += sizeof(void *);
>  
> +#ifdef CONFIG_KASAN
> +	if (s->kasan_info.alloc_meta_offset)
> +		off += sizeof(struct kasan_alloc_meta);
> +
> +	if (s->kasan_info.free_meta_offset)
> +		off += sizeof(struct kasan_free_meta);
> +#endif

That's ugly.

Following is not ugly:
	off += kasan_metadata_size();


>  	if (s->flags & SLAB_STORE_USER)
>  		/* We also have user information there */
>  		off += 2 * sizeof(struct track);
> @@ -1322,7 +1328,7 @@ static inline void kfree_hook(const void *x)
>  	kasan_kfree_large(x);
>  }
>  
> -static inline void slab_free_hook(struct kmem_cache *s, void *x)
> +static inline bool slab_free_hook(struct kmem_cache *s, void *x)
>  {
>  	kmemleak_free_recursive(x, s->flags);
>  
> @@ -1344,7 +1350,7 @@ static inline void slab_free_hook(struct kmem_cache *s, void *x)
>  	if (!(s->flags & SLAB_DEBUG_OBJECTS))
>  		debug_check_no_obj_freed(x, s->object_size);
>  
> -	kasan_slab_free(s, x);
> +	return kasan_slab_free(s, x);
>  }

Change it back, return value is not unused anymore.


>  
>  static inline void slab_free_freelist_hook(struct kmem_cache *s,
> @@ -2753,6 +2759,9 @@ slab_empty:
>  	discard_slab(s, page);
>  }
>  
> +static void do_slab_free(struct kmem_cache *s, struct page *page,
> +		void *head, void *tail, int cnt, unsigned long addr);
> +

You can just place slab_free() after do_slab_free().

>  /*
>   * Fastpath with forced inlining to produce a kfree and kmem_cache_free that
>   * can perform fastpath freeing without additional function calls.
> @@ -2772,12 +2781,23 @@ static __always_inline void slab_free(struct kmem_cache *s, struct page *page,
>  				      void *head, void *tail, int cnt,
>  				      unsigned long addr)
>  {
> +	slab_free_freelist_hook(s, head, tail);
> +	/*
> +	 * slab_free_freelist_hook() could have put the items into quarantine.
> +	 * If so, no need to free them.
> +	 */
> +	if (s->flags & SLAB_KASAN && !(s->flags & SLAB_DESTROY_BY_RCU))
> +		return;
> +	do_slab_free(s, page, head, tail, cnt, addr);
> +}
> +
> +static __always_inline void do_slab_free(struct kmem_cache *s,
> +				struct page *page, void *head, void *tail,
> +				int cnt, unsigned long addr)
> +{
>  	void *tail_obj = tail ? : head;
>  	struct kmem_cache_cpu *c;
>  	unsigned long tid;
> -
> -	slab_free_freelist_hook(s, head, tail);
> -
>  redo:
>  	/*
>  	 * Determine the currently cpus per cpu slab.
> @@ -2811,6 +2831,11 @@ redo:
>  
>  }
>  
> +void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr)
> +{
> +	do_slab_free(cache, virt_to_head_page(x), x, NULL, 1, addr);
> +}
> +

Probably would be better to hide this under #ifdef CONFIG_KASAN. It has no other users, and it might be relatively
large function because do_slab_free() is always inlined.


>  void kmem_cache_free(struct kmem_cache *s, void *x)
>  {
>  	s = cache_from_obj(s, x);
> @@ -3252,7 +3277,7 @@ static void set_min_partial(struct kmem_cache *s, unsigned long min)
>  static int calculate_sizes(struct kmem_cache *s, int forced_order)
>  {
>  	unsigned long flags = s->flags;
> -	unsigned long size = s->object_size;
> +	size_t size = s->object_size;
>  	int order;
>  
>  	/*
> @@ -3311,7 +3336,10 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
>  		 * the object.
>  		 */
>  		size += 2 * sizeof(struct track);
> +#endif
>  
> +	kasan_cache_create(s, &size, &s->flags);
> +#ifdef CONFIG_SLUB_DEBUG
>  	if (flags & SLAB_RED_ZONE) {
>  		/*
>  		 * Add some empty padding so that we can catch
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
