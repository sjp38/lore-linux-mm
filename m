Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f50.google.com (mail-lf0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6BF906B0274
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:10:36 -0500 (EST)
Received: by mail-lf0-f50.google.com with SMTP id v124so196720lff.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 07:10:36 -0800 (PST)
Received: from mail-lf0-x22c.google.com (mail-lf0-x22c.google.com. [2a00:1450:4010:c07::22c])
        by mx.google.com with ESMTPS id 62si5846048lfw.65.2016.02.29.07.10.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 07:10:35 -0800 (PST)
Received: by mail-lf0-x22c.google.com with SMTP id v124so195648lff.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 07:10:33 -0800 (PST)
Subject: Re: [PATCH v4 2/7] mm, kasan: SLAB support
References: <cover.1456504662.git.glider@google.com>
 <5c5a22a3daee19ff5940605b946dc144515ebd63.1456504662.git.glider@google.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <56D45F67.8050508@gmail.com>
Date: Mon, 29 Feb 2016 18:10:31 +0300
MIME-Version: 1.0
In-Reply-To: <5c5a22a3daee19ff5940605b946dc144515ebd63.1456504662.git.glider@google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 02/26/2016 07:48 PM, Alexander Potapenko wrote:
> Add KASAN hooks to SLAB allocator.
> 
> This patch is based on the "mm: kasan: unified support for SLUB and
> SLAB allocators" patch originally prepared by Dmitry Chernenkov.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---
> v3: - minor description changes
>     - store deallocation info in kasan_slab_free()
> 
> v4: - fix kbuild compile-time warnings in print_track()
> ---


> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index bc0a8d8..d26ffb4 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -314,6 +314,59 @@ void kasan_free_pages(struct page *page, unsigned int order)
>  				KASAN_FREE_PAGE);
>  }
>  
> +#ifdef CONFIG_SLAB
> +/*
> + * Adaptive redzone policy taken from the userspace AddressSanitizer runtime.
> + * For larger allocations larger redzones are used.
> + */
> +static size_t optimal_redzone(size_t object_size)
> +{
> +	int rz =
> +		object_size <= 64        - 16   ? 16 :
> +		object_size <= 128       - 32   ? 32 :
> +		object_size <= 512       - 64   ? 64 :
> +		object_size <= 4096      - 128  ? 128 :
> +		object_size <= (1 << 14) - 256  ? 256 :
> +		object_size <= (1 << 15) - 512  ? 512 :
> +		object_size <= (1 << 16) - 1024 ? 1024 : 2048;
> +	return rz;
> +}
> +
> +void kasan_cache_create(struct kmem_cache *cache, size_t *size,
> +			unsigned long *flags)
> +{
> +	int redzone_adjust;
> +	/* Make sure the adjusted size is still less than
> +	 * KMALLOC_MAX_CACHE_SIZE.
> +	 * TODO: this check is only useful for SLAB, but not SLUB. We'll need
> +	 * to skip it for SLUB when it starts using kasan_cache_create().
> +	 */
> +	if (*size > KMALLOC_MAX_CACHE_SIZE -
> +	    sizeof(struct kasan_alloc_meta) -
> +	    sizeof(struct kasan_free_meta))
> +		return;
> +	*flags |= SLAB_KASAN;
> +	/* Add alloc meta. */
> +	cache->kasan_info.alloc_meta_offset = *size;
> +	*size += sizeof(struct kasan_alloc_meta);
> +
> +	/* Add free meta. */
> +	if (cache->flags & SLAB_DESTROY_BY_RCU || cache->ctor ||
> +	    cache->object_size < sizeof(struct kasan_free_meta)) {
> +		cache->kasan_info.free_meta_offset = *size;
> +		*size += sizeof(struct kasan_free_meta);
> +	}
> +	redzone_adjust = optimal_redzone(cache->object_size) -
> +		(*size - cache->object_size);
> +	if (redzone_adjust > 0)
> +		*size += redzone_adjust;
> +	*size = min(KMALLOC_MAX_CACHE_SIZE,
> +		    max(*size,
> +			cache->object_size +
> +			optimal_redzone(cache->object_size)));
> +}
> +#endif
> +




>  void kasan_poison_slab(struct page *page)
>  {
>  	kasan_poison_shadow(page_address(page),
> @@ -331,8 +384,36 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object)
>  	kasan_poison_shadow(object,
>  			round_up(cache->object_size, KASAN_SHADOW_SCALE_SIZE),
>  			KASAN_KMALLOC_REDZONE);
> +#ifdef CONFIG_SLAB
> +	if (cache->flags & SLAB_KASAN) {
> +		struct kasan_alloc_meta *alloc_info =
> +			get_alloc_info(cache, object);
> +		alloc_info->state = KASAN_STATE_INIT;
> +	}
> +#endif
> +}
> +
> +static inline void set_track(struct kasan_track *track)
> +{
> +	track->cpu = raw_smp_processor_id();
> +	track->pid = current->pid;
> +	track->when = jiffies;
>  }
>  
> +#ifdef CONFIG_SLAB
> +struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
> +					const void *object)
> +{
> +	return (void *)object + cache->kasan_info.alloc_meta_offset;
> +}
> +
> +struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
> +				      const void *object)
> +{
> +	return (void *)object + cache->kasan_info.free_meta_offset;
> +}
> +#endif
> +
>  void kasan_slab_alloc(struct kmem_cache *cache, void *object)
>  {
>  	kasan_kmalloc(cache, object, cache->object_size);
> @@ -347,6 +428,17 @@ void kasan_slab_free(struct kmem_cache *cache, void *object)
>  	if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
>  		return;
>  
> +#ifdef CONFIG_SLAB
> +	if (cache->flags & SLAB_KASAN) {
> +		struct kasan_free_meta *free_info =
> +			get_free_info(cache, object);
> +		struct kasan_alloc_meta *alloc_info =
> +			get_alloc_info(cache, object);
> +		alloc_info->state = KASAN_STATE_FREE;
> +		set_track(&free_info->track);
> +	}
> +#endif
> +
>  	kasan_poison_shadow(object, rounded_up_size, KASAN_KMALLOC_FREE);
>  }
>  
> @@ -366,6 +458,16 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size)
>  	kasan_unpoison_shadow(object, size);
>  	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
>  		KASAN_KMALLOC_REDZONE);
> +#ifdef CONFIG_SLAB
> +	if (cache->flags & SLAB_KASAN) {
> +		struct kasan_alloc_meta *alloc_info =
> +			get_alloc_info(cache, object);
> +
> +		alloc_info->state = KASAN_STATE_ALLOC;
> +		alloc_info->alloc_size = size;
> +		set_track(&alloc_info->track);
> +	}
> +#endif
>  }
>  EXPORT_SYMBOL(kasan_kmalloc);
>  
> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> index 4f6c62e..7b9e4ab9 100644
> --- a/mm/kasan/kasan.h
> +++ b/mm/kasan/kasan.h
> @@ -54,6 +54,40 @@ struct kasan_global {
>  #endif
>  };
>  
> +/**
> + * Structures to keep alloc and free tracks *
> + */
> +
> +enum kasan_state {
> +	KASAN_STATE_INIT,
> +	KASAN_STATE_ALLOC,
> +	KASAN_STATE_FREE
> +};
> +
> +struct kasan_track {
> +	u64 cpu : 6;			/* for NR_CPUS = 64 */
> +	u64 pid : 16;			/* 65536 processes */
> +	u64 when : 42;			/* ~140 years */
> +};
> +
> +struct kasan_alloc_meta {
> +	u32 state : 2;	/* enum kasan_state */
> +	u32 alloc_size : 30;
> +	struct kasan_track track;
> +};
> +
> +struct kasan_free_meta {
> +	/* Allocator freelist pointer, unused by KASAN. */
> +	void **freelist;
> +	struct kasan_track track;
> +};
> +
> +struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
> +					const void *object);
> +struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
> +					const void *object);
> +
> +

Basically, all this big pile of code above is implementation of yet another SLAB_STORE_USER and SLAB_RED_ZONE
exclusively for KASAN. It would be so much better to alter existing code to satisfy all you needs.

>  static inline const void *kasan_shadow_to_mem(const void *shadow_addr)
>  {
>  	return (void *)(((unsigned long)shadow_addr - KASAN_SHADOW_OFFSET)
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index 12f222d..2c1407f 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -115,6 +115,44 @@ static inline bool init_task_stack_addr(const void *addr)
>  			sizeof(init_thread_union.stack));
>  }
>  
> +#ifdef CONFIG_SLAB
> +static void print_track(struct kasan_track *track)
> +{
> +	pr_err("PID = %u, CPU = %u, timestamp = %lu\n", track->pid,
> +	       track->cpu, (unsigned long)track->when);
> +}
> +
> +static void print_object(struct kmem_cache *cache, void *object)
> +{
> +	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
> +	struct kasan_free_meta *free_info;
> +
> +	pr_err("Object at %p, in cache %s\n", object, cache->name);
> +	if (!(cache->flags & SLAB_KASAN))
> +		return;
> +	switch (alloc_info->state) {

'->state' seems useless. It's used only here, but object's state could be determined by shadow value.

> +	case KASAN_STATE_INIT:
> +		pr_err("Object not allocated yet\n");
> +		break;
> +	case KASAN_STATE_ALLOC:
> +		pr_err("Object allocated with size %u bytes.\n",
> +		       alloc_info->alloc_size);
> +		pr_err("Allocation:\n");
> +		print_track(&alloc_info->track);
> +		break;
> +	case KASAN_STATE_FREE:
> +		pr_err("Object freed, allocated with size %u bytes\n",
> +		       alloc_info->alloc_size);
> +		free_info = get_free_info(cache, object);
> +		pr_err("Allocation:\n");
> +		print_track(&alloc_info->track);
> +		pr_err("Deallocation:\n");
> +		print_track(&free_info->track);
> +		break;
> +	}
> +}
> +#endif
> +
>  static void print_address_description(struct kasan_access_info *info)
>  {
>  	const void *addr = info->access_addr;
> @@ -126,17 +164,14 @@ static void print_address_description(struct kasan_access_info *info)
>  		if (PageSlab(page)) {
>  			void *object;
>  			struct kmem_cache *cache = page->slab_cache;
> -			void *last_object;
> -
> -			object = virt_to_obj(cache, page_address(page), addr);
> -			last_object = page_address(page) +
> -				page->objects * cache->size;
> -
> -			if (unlikely(object > last_object))
> -				object = last_object; /* we hit into padding */
> -
> +			object = nearest_obj(cache, page,
> +						(void *)info->access_addr);
> +#ifdef CONFIG_SLAB
> +			print_object(cache, object);
> +#else

Instead of these ifdefs, please, make universal API for printing object's information.

>  			object_err(cache, page, object,
> -				"kasan: bad access detected");
> +					"kasan: bad access detected");
> +#endif
>  			return;
>  		}
>  		dump_page(page, "kasan: bad access detected");
> @@ -146,8 +181,9 @@ static void print_address_description(struct kasan_access_info *info)
>  		if (!init_task_stack_addr(addr))
>  			pr_err("Address belongs to variable %pS\n", addr);
>  	}
> -
> +#ifdef CONFIG_SLUB

???

>  	dump_stack();
> +#endif
>  }
>  
>  static bool row_is_guilty(const void *row, const void *guilty)
> @@ -233,6 +269,9 @@ static void kasan_report_error(struct kasan_access_info *info)
>  		dump_stack();
>  	} else {
>  		print_error_description(info);
> +#ifdef CONFIG_SLAB

I'm lost here. What's the point of reordering dump_stack() for CONFIG_SLAB=y? 

> +		dump_stack();
> +#endif
>  		print_address_description(info);
>  		print_shadow_for_address(info->first_bad_addr);
>  	}
> diff --git a/mm/slab.c b/mm/slab.c
> index 621fbcb..805b39b 100644



>  
>  	if (gfpflags_allow_blocking(local_flags))
> @@ -3364,7 +3374,10 @@ free_done:
>  static inline void __cache_free(struct kmem_cache *cachep, void *objp,
>  				unsigned long caller)
>  {
> -	struct array_cache *ac = cpu_cache_get(cachep);
> +	struct array_cache *ac;
> +
> +	kasan_slab_free(cachep, objp);
> +	ac = cpu_cache_get(cachep);

Why cpu_cache_get() was moved? Looks like unnecessary change.

>  
>  	check_irq_off();
>  	kmemleak_free_recursive(objp, cachep->flags);
> @@ -3403,6 +3416,8 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
>  void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
>  {
>  	void *ret = slab_alloc(cachep, flags, _RET_IP_);
> +	if (ret)

kasan_slab_alloc() should deal fine with ret == NULL.

> +		kasan_slab_alloc(cachep, ret);
>  
>  	trace_kmem_cache_alloc(_RET_IP_, ret,
>  			       cachep->object_size, cachep->size, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
