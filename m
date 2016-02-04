Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 302A24403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 01:21:37 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id 65so33835922pfd.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 22:21:37 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id ue3si14438412pab.154.2016.02.03.22.21.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Feb 2016 22:21:36 -0800 (PST)
Date: Thu, 4 Feb 2016 15:21:41 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm/slub: support left red zone
Message-ID: <20160204062140.GB14877@js1304-P5Q-DELUXE>
References: <1454566550-28288-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454566550-28288-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 04, 2016 at 03:15:50PM +0900, Joonsoo Kim wrote:
> SLUB already has red zone debugging feature. But, it is only positioned
> at the end of object(aka right red zone) so it cannot catch left oob.
> Although current object's right red zone acts as left red zone of
> previous object, first object in a slab cannot take advantage of

Oops... s/previous/next.

> this effect. This patch explicitly add left red zone to each objects
> to detect left oob more precisely.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  include/linux/slub_def.h |   1 +
>  mm/slub.c                | 158 ++++++++++++++++++++++++++++++++++-------------
>  2 files changed, 115 insertions(+), 44 deletions(-)
> 
> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> index b7e57927..a33869b 100644
> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h
> @@ -77,6 +77,7 @@ struct kmem_cache {
>  	int refcount;		/* Refcount for slab cache destroy */
>  	void (*ctor)(void *);
>  	int inuse;		/* Offset to metadata */
> +	int red_left_pad;	/* Left redzone padding size */
>  	int align;		/* Alignment */
>  	int reserved;		/* Reserved bytes at the end of slabs */
>  	const char *name;	/* Name (only for display!) */
> diff --git a/mm/slub.c b/mm/slub.c
> index 7b5a965..7216769 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -39,6 +39,10 @@
>  
>  #include "internal.h"
>  
> +#ifdef CONFIG_KASAN
> +#include "kasan/kasan.h"
> +#endif
> +
>  /*
>   * Lock order:
>   *   1. slab_mutex (Global Mutex)
> @@ -124,6 +128,14 @@ static inline int kmem_cache_debug(struct kmem_cache *s)
>  #endif
>  }
>  
> +static inline void *fixup_red_left(struct kmem_cache *s, void *p)
> +{
> +	if (kmem_cache_debug(s) && s->flags & SLAB_RED_ZONE)
> +		p += s->red_left_pad;
> +
> +	return p;
> +}
> +
>  static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
>  {
>  #ifdef CONFIG_SLUB_CPU_PARTIAL
> @@ -224,24 +236,6 @@ static inline void stat(const struct kmem_cache *s, enum stat_item si)
>   * 			Core slab cache functions
>   *******************************************************************/
>  
> -/* Verify that a pointer has an address that is valid within a slab page */
> -static inline int check_valid_pointer(struct kmem_cache *s,
> -				struct page *page, const void *object)
> -{
> -	void *base;
> -
> -	if (!object)
> -		return 1;
> -
> -	base = page_address(page);
> -	if (object < base || object >= base + page->objects * s->size ||
> -		(object - base) % s->size) {
> -		return 0;
> -	}
> -
> -	return 1;
> -}
> -
>  static inline void *get_freepointer(struct kmem_cache *s, void *object)
>  {
>  	return *(void **)(object + s->offset);
> @@ -435,6 +429,22 @@ static void get_map(struct kmem_cache *s, struct page *page, unsigned long *map)
>  		set_bit(slab_index(p, s, addr), map);
>  }
>  
> +static inline int size_from_object(struct kmem_cache *s)
> +{
> +	if (s->flags & SLAB_RED_ZONE)
> +		return s->size - s->red_left_pad;
> +
> +	return s->size;
> +}
> +
> +static inline void *restore_red_left(struct kmem_cache *s, void *p)
> +{
> +	if (s->flags & SLAB_RED_ZONE)
> +		p -= s->red_left_pad;
> +
> +	return p;
> +}
> +
>  /*
>   * Debug settings:
>   */
> @@ -468,6 +478,26 @@ static inline void metadata_access_disable(void)
>  /*
>   * Object debugging
>   */
> +
> +/* Verify that a pointer has an address that is valid within a slab page */
> +static inline int check_valid_pointer(struct kmem_cache *s,
> +				struct page *page, void *object)
> +{
> +	void *base;
> +
> +	if (!object)
> +		return 1;
> +
> +	base = page_address(page);
> +	object = restore_red_left(s, object);
> +	if (object < base || object >= base + page->objects * s->size ||
> +		(object - base) % s->size) {
> +		return 0;
> +	}
> +
> +	return 1;
> +}
> +
>  static void print_section(char *text, u8 *addr, unsigned int length)
>  {
>  	metadata_access_enable();
> @@ -607,7 +637,9 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
>  	pr_err("INFO: Object 0x%p @offset=%tu fp=0x%p\n\n",
>  	       p, p - addr, get_freepointer(s, p));
>  
> -	if (p > addr + 16)
> +	if (s->flags & SLAB_RED_ZONE)
> +		print_section("Redzone ", p - s->red_left_pad, s->red_left_pad);
> +	else if (p > addr + 16)
>  		print_section("Bytes b4 ", p - 16, 16);
>  
>  	print_section("Object ", p, min_t(unsigned long, s->object_size,
> @@ -624,9 +656,9 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
>  	if (s->flags & SLAB_STORE_USER)
>  		off += 2 * sizeof(struct track);
>  
> -	if (off != s->size)
> +	if (off != size_from_object(s))
>  		/* Beginning of the filler is the free pointer */
> -		print_section("Padding ", p + off, s->size - off);
> +		print_section("Padding ", p + off, size_from_object(s) - off);
>  
>  	dump_stack();
>  }
> @@ -656,6 +688,9 @@ static void init_object(struct kmem_cache *s, void *object, u8 val)
>  {
>  	u8 *p = object;
>  
> +	if (s->flags & SLAB_RED_ZONE)
> +		memset(p - s->red_left_pad, val, s->red_left_pad);
> +
>  	if (s->flags & __OBJECT_POISON) {
>  		memset(p, POISON_FREE, s->object_size - 1);
>  		p[s->object_size - 1] = POISON_END;
> @@ -748,11 +783,11 @@ static int check_pad_bytes(struct kmem_cache *s, struct page *page, u8 *p)
>  		/* We also have user information there */
>  		off += 2 * sizeof(struct track);
>  
> -	if (s->size == off)
> +	if (size_from_object(s) == off)
>  		return 1;
>  
>  	return check_bytes_and_report(s, page, p, "Object padding",
> -				p + off, POISON_INUSE, s->size - off);
> +			p + off, POISON_INUSE, size_from_object(s) - off);
>  }
>  
>  /* Check the pad bytes at the end of a slab page */
> @@ -797,6 +832,10 @@ static int check_object(struct kmem_cache *s, struct page *page,
>  
>  	if (s->flags & SLAB_RED_ZONE) {
>  		if (!check_bytes_and_report(s, page, object, "Redzone",
> +			object - s->red_left_pad, val, s->red_left_pad))
> +			return 0;
> +
> +		if (!check_bytes_and_report(s, page, object, "Redzone",
>  			endobject, val, s->inuse - s->object_size))
>  			return 0;
>  	} else {
> @@ -998,14 +1037,17 @@ static inline void dec_slabs_node(struct kmem_cache *s, int node, int objects)
>  }
>  
>  /* Object debug checks for alloc/free paths */
> -static void setup_object_debug(struct kmem_cache *s, struct page *page,
> +static void *setup_object_debug(struct kmem_cache *s, struct page *page,
>  								void *object)
>  {
>  	if (!(s->flags & (SLAB_STORE_USER|SLAB_RED_ZONE|__OBJECT_POISON)))
> -		return;
> +		return object;
>  
> +	object = fixup_red_left(s, object);
>  	init_object(s, object, SLUB_RED_INACTIVE);
>  	init_tracking(s, object);
> +
> +	return object;
>  }
>  
>  static noinline int alloc_debug_processing(struct kmem_cache *s,
> @@ -1202,8 +1244,8 @@ unsigned long kmem_cache_flags(unsigned long object_size,
>  	return flags;
>  }
>  #else /* !CONFIG_SLUB_DEBUG */
> -static inline void setup_object_debug(struct kmem_cache *s,
> -			struct page *page, void *object) {}
> +static inline void *setup_object_debug(struct kmem_cache *s,
> +			struct page *page, void *object) { return object; }
>  
>  static inline int alloc_debug_processing(struct kmem_cache *s,
>  	struct page *page, void *object, unsigned long addr) { return 0; }
> @@ -1306,15 +1348,17 @@ static inline void slab_free_freelist_hook(struct kmem_cache *s,
>  #endif
>  }
>  
> -static void setup_object(struct kmem_cache *s, struct page *page,
> +static void *setup_object(struct kmem_cache *s, struct page *page,
>  				void *object)
>  {
> -	setup_object_debug(s, page, object);
> +	object = setup_object_debug(s, page, object);
>  	if (unlikely(s->ctor)) {
>  		kasan_unpoison_object_data(s, object);
>  		s->ctor(object);
>  		kasan_poison_object_data(s, object);
>  	}
> +
> +	return object;
>  }
>  
>  /*
> @@ -1410,14 +1454,16 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  	kasan_poison_slab(page);
>  
>  	for_each_object_idx(p, idx, s, start, page->objects) {
> -		setup_object(s, page, p);
> -		if (likely(idx < page->objects))
> -			set_freepointer(s, p, p + s->size);
> -		else
> -			set_freepointer(s, p, NULL);
> +		void *object = setup_object(s, page, p);
> +
> +		if (likely(idx < page->objects)) {
> +			set_freepointer(s, object,
> +				fixup_red_left(s, p + s->size));
> +		} else
> +			set_freepointer(s, object, NULL);
>  	}
>  
> -	page->freelist = start;
> +	page->freelist = fixup_red_left(s, start);
>  	page->inuse = page->objects;
>  	page->frozen = 1;
>  
> @@ -1458,8 +1504,11 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
>  
>  		slab_pad_check(s, page);
>  		for_each_object(p, s, page_address(page),
> -						page->objects)
> -			check_object(s, page, p, SLUB_RED_INACTIVE);
> +						page->objects) {
> +			void *object = fixup_red_left(s, p);
> +
> +			check_object(s, page, object, SLUB_RED_INACTIVE);
> +		}
>  	}
>  
>  	kmemcheck_free_shadow(page, compound_order(page));
> @@ -3256,6 +3305,16 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
>  		 * of the object.
>  		 */
>  		size += sizeof(void *);
> +
> +	if (flags & SLAB_RED_ZONE) {
> +		s->red_left_pad = sizeof(void *);
> +#ifdef CONFIG_KASAN
> +		s->red_left_pad = min_t(int, s->red_left_pad,
> +				KASAN_SHADOW_SCALE_SIZE);
> +#endif
> +		s->red_left_pad = ALIGN(s->red_left_pad, s->align);
> +		size += s->red_left_pad;
> +	}
>  #endif
>  
>  	/*
> @@ -3392,10 +3451,12 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
>  
>  	get_map(s, page, map);
>  	for_each_object(p, s, addr, page->objects) {
> +		void *object = fixup_red_left(s, p);
>  
>  		if (!test_bit(slab_index(p, s, addr), map)) {
> -			pr_err("INFO: Object 0x%p @offset=%tu\n", p, p - addr);
> -			print_tracking(s, p);
> +			pr_err("INFO: Object 0x%p @offset=%tu\n",
> +					object, object - addr);
> +			print_tracking(s, object);
>  		}
>  	}
>  	slab_unlock(page);
> @@ -4064,15 +4125,21 @@ static int validate_slab(struct kmem_cache *s, struct page *page,
>  
>  	get_map(s, page, map);
>  	for_each_object(p, s, addr, page->objects) {
> +		void *object = fixup_red_left(s, p);
> +
>  		if (test_bit(slab_index(p, s, addr), map))
> -			if (!check_object(s, page, p, SLUB_RED_INACTIVE))
> +			if (!check_object(s, page, object, SLUB_RED_INACTIVE))
>  				return 0;
>  	}
>  
> -	for_each_object(p, s, addr, page->objects)
> +	for_each_object(p, s, addr, page->objects) {
> +		void *object = fixup_red_left(s, p);
> +
>  		if (!test_bit(slab_index(p, s, addr), map))
> -			if (!check_object(s, page, p, SLUB_RED_ACTIVE))
> +			if (!check_object(s, page, object, SLUB_RED_ACTIVE))
>  				return 0;
> +	}
> +
>  	return 1;
>  }
>  
> @@ -4270,9 +4337,12 @@ static void process_slab(struct loc_track *t, struct kmem_cache *s,
>  	bitmap_zero(map, page->objects);
>  	get_map(s, page, map);
>  
> -	for_each_object(p, s, addr, page->objects)
> +	for_each_object(p, s, addr, page->objects) {
> +		void *object = fixup_red_left(s, p);
> +
>  		if (!test_bit(slab_index(p, s, addr), map))
> -			add_location(t, s, get_track(s, p, alloc));
> +			add_location(t, s, get_track(s, object, alloc));
> +	}
>  }
>  
>  static int list_locations(struct kmem_cache *s, char *buf,
> -- 
> 1.9.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
