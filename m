Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 406B96B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 01:59:04 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e189so231543866pfa.2
        for <linux-mm@kvack.org>; Sun, 10 Jul 2016 22:59:04 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id hf8si1933380pac.23.2016.07.10.22.59.02
        for <linux-mm@kvack.org>;
        Sun, 10 Jul 2016 22:59:03 -0700 (PDT)
Date: Mon, 11 Jul 2016 15:02:43 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v6] mm, kasan: switch SLUB to stackdepot, enable memory
 quarantine for SLUB
Message-ID: <20160711060243.GA14107@js1304-P5Q-DELUXE>
References: <1467974210-117852-1-git-send-email-glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467974210-117852-1-git-send-email-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, rostedt@goodmis.org, kcc@google.com, aryabinin@virtuozzo.com, kuthonuzo.luruo@hpe.com, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 08, 2016 at 12:36:50PM +0200, Alexander Potapenko wrote:
> For KASAN builds:
>  - switch SLUB allocator to using stackdepot instead of storing the
>    allocation/deallocation stacks in the objects;
>  - change the freelist hook so that parts of the freelist can be put
>    into the quarantine.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---
> v6: - addressed comments by Andrey Ryabinin:
>       - move nearest_obj() back to header files
>       - fix check_pad_bytes() to address problems with poisoning
>       - don't define __OBJECT_POISON to 0
>       - simplify slab_free_freelist_hook() implementation
>       - move KASAN definintions used by SLUB code to include/linux/kasan.h
>       - fix minor nits
> v5: - addressed comments by Andrey Ryabinin:
>       - don't define SLAB_RED_ZONE, SLAB_POISON, SLAB_STORE_USER to 0
>       - account for left redzone size when SLAB_RED_ZONE is used
>     - incidentally moved the implementations of nearest_obj() to mm/sl[au]b.c
> v4: - addressed comments by Andrey Ryabinin:
>       - don't set slub_debug by default for everyone;
>       - introduce the ___cache_free() helper function.
> v3: - addressed comments by Andrey Ryabinin:
>       - replaced KMALLOC_MAX_CACHE_SIZE with KMALLOC_MAX_SIZE in
>         kasan_cache_create();
>       - for caches with SLAB_KASAN flag set, their alloc_meta_offset and
>         free_meta_offset are always valid.
> v2: - incorporated kbuild fixes by Andrew Morton
> ---
>  include/linux/kasan.h    | 23 ++++++++++++++++++
>  include/linux/slab_def.h |  3 ++-
>  include/linux/slub_def.h | 13 +++++++----
>  lib/Kconfig.kasan        |  4 ++--
>  mm/kasan/Makefile        |  3 +--
>  mm/kasan/kasan.c         | 61 ++++++++++++++++++++++++++----------------------
>  mm/kasan/kasan.h         | 26 +--------------------
>  mm/kasan/report.c        |  8 +++----
>  mm/slab.h                |  5 +++-
>  mm/slub.c                | 44 +++++++++++++++++++++++++++-------
>  10 files changed, 114 insertions(+), 76 deletions(-)
> 
> diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> index 611927f..99b9ffc 100644
> --- a/include/linux/kasan.h
> +++ b/include/linux/kasan.h
> @@ -2,6 +2,7 @@
>  #define _LINUX_KASAN_H
>  
>  #include <linux/sched.h>
> +#include <linux/stackdepot.h>
>  #include <linux/types.h>
>  
>  struct kmem_cache;
> @@ -20,6 +21,28 @@ extern pte_t kasan_zero_pte[PTRS_PER_PTE];
>  extern pmd_t kasan_zero_pmd[PTRS_PER_PMD];
>  extern pud_t kasan_zero_pud[PTRS_PER_PUD];
>  
> +struct kasan_track {
> +	u32 pid;
> +	depot_stack_handle_t stack;
> +};
> +
> +struct kasan_alloc_meta {
> +	struct kasan_track track;
> +	u32 state : 2;	/* enum kasan_state */
> +	u32 alloc_size : 30;
> +};
> +
> +struct qlist_node {
> +	struct qlist_node *next;
> +};
> +struct kasan_free_meta {
> +	/* This field is used while the object is in the quarantine.
> +	 * Otherwise it might be used for the allocator freelist.
> +	 */
> +	struct qlist_node quarantine_link;
> +	struct kasan_track track;
> +};
> +
>  void kasan_populate_zero_shadow(const void *shadow_start,
>  				const void *shadow_end);
>  
> diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
> index 8694f7a..6f35df7 100644
> --- a/include/linux/slab_def.h
> +++ b/include/linux/slab_def.h
> @@ -88,7 +88,8 @@ struct kmem_cache {
>  };
>  
>  static inline void *nearest_obj(struct kmem_cache *cache, struct page *page,
> -				void *x) {
> +				void *x)
> +{
>  	void *object = x - (x - page->s_mem) % cache->size;
>  	void *last_object = page->s_mem + (cache->num - 1) * cache->size;
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

As Andrey saids, it should be a separate patch. And, can we use
wrapper function, fixup_red_left()?

>  }
>  
>  #endif /* _LINUX_SLUB_DEF_H */
> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> index 67d8c68..bd38aab 100644
> --- a/lib/Kconfig.kasan
> +++ b/lib/Kconfig.kasan
> @@ -5,9 +5,9 @@ if HAVE_ARCH_KASAN
>  
>  config KASAN
>  	bool "KASan: runtime memory debugger"
> -	depends on SLUB_DEBUG || (SLAB && !DEBUG_SLAB)
> +	depends on SLUB || (SLAB && !DEBUG_SLAB)
>  	select CONSTRUCTORS
> -	select STACKDEPOT if SLAB
> +	select STACKDEPOT
>  	help
>  	  Enables kernel address sanitizer - runtime memory debugger,
>  	  designed to find out-of-bounds accesses and use-after-free bugs.
> diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
> index 1548749..2976a9e 100644
> --- a/mm/kasan/Makefile
> +++ b/mm/kasan/Makefile
> @@ -7,5 +7,4 @@ CFLAGS_REMOVE_kasan.o = -pg
>  # see: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=63533
>  CFLAGS_kasan.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
>  
> -obj-y := kasan.o report.o kasan_init.o
> -obj-$(CONFIG_SLAB) += quarantine.o
> +obj-y := kasan.o report.o kasan_init.o quarantine.o
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 28439ac..03aa2a7 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -351,7 +351,6 @@ void kasan_free_pages(struct page *page, unsigned int order)
>  				KASAN_FREE_PAGE);
>  }
>  
> -#ifdef CONFIG_SLAB
>  /*
>   * Adaptive redzone policy taken from the userspace AddressSanitizer runtime.
>   * For larger allocations larger redzones are used.
> @@ -373,16 +372,10 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
>  			unsigned long *flags)
>  {
>  	int redzone_adjust;
> -	/* Make sure the adjusted size is still less than
> -	 * KMALLOC_MAX_CACHE_SIZE.
> -	 * TODO: this check is only useful for SLAB, but not SLUB. We'll need
> -	 * to skip it for SLUB when it starts using kasan_cache_create().
> -	 */
> -	if (*size > KMALLOC_MAX_CACHE_SIZE -
> -	    sizeof(struct kasan_alloc_meta) -
> -	    sizeof(struct kasan_free_meta))
> -		return;
> -	*flags |= SLAB_KASAN;
> +#ifdef CONFIG_SLAB
> +	int orig_size = *size;
> +#endif
> +
>  	/* Add alloc meta. */
>  	cache->kasan_info.alloc_meta_offset = *size;
>  	*size += sizeof(struct kasan_alloc_meta);
> @@ -392,17 +385,36 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
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
> -	*size = min(KMALLOC_MAX_CACHE_SIZE,
> +
> +#ifdef CONFIG_SLAB
> +	*size = min(KMALLOC_MAX_SIZE,
>  		    max(*size,
>  			cache->object_size +
>  			optimal_redzone(cache->object_size)));
> -}
> +	/*
> +	 * If the metadata doesn't fit, don't enable KASAN at all.
> +	 */
> +	if (*size <= cache->kasan_info.alloc_meta_offset ||
> +			*size <= cache->kasan_info.free_meta_offset) {
> +		*size = orig_size;
> +		return;
> +	}
> +#else
> +	*size = max(*size,
> +			cache->object_size +
> +			optimal_redzone(cache->object_size));
> +
>  #endif

Hmm... could you explain why SLAB needs min(KMALLOC_MAX_SIZE, XX) but
not SLUB?

> +	*flags |= SLAB_KASAN;
> +}
>  
>  void kasan_cache_shrink(struct kmem_cache *cache)
>  {
> @@ -431,16 +443,13 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object)
>  	kasan_poison_shadow(object,
>  			round_up(cache->object_size, KASAN_SHADOW_SCALE_SIZE),
>  			KASAN_KMALLOC_REDZONE);
> -#ifdef CONFIG_SLAB
>  	if (cache->flags & SLAB_KASAN) {
>  		struct kasan_alloc_meta *alloc_info =
>  			get_alloc_info(cache, object);
>  		alloc_info->state = KASAN_STATE_INIT;
>  	}
> -#endif
>  }
>  
> -#ifdef CONFIG_SLAB
>  static inline int in_irqentry_text(unsigned long ptr)
>  {
>  	return (ptr >= (unsigned long)&__irqentry_text_start &&
> @@ -501,7 +510,6 @@ struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
>  	BUILD_BUG_ON(sizeof(struct kasan_free_meta) > 32);
>  	return (void *)object + cache->kasan_info.free_meta_offset;
>  }
> -#endif
>  
>  void kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
>  {
> @@ -522,16 +530,16 @@ void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
>  
>  bool kasan_slab_free(struct kmem_cache *cache, void *object)
>  {
> -#ifdef CONFIG_SLAB
>  	/* RCU slabs could be legally used after free within the RCU period */
>  	if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
>  		return false;
>  
>  	if (likely(cache->flags & SLAB_KASAN)) {
> -		struct kasan_alloc_meta *alloc_info =
> -			get_alloc_info(cache, object);
> -		struct kasan_free_meta *free_info =
> -			get_free_info(cache, object);
> +		struct kasan_alloc_meta *alloc_info;
> +		struct kasan_free_meta *free_info;
> +
> +		alloc_info = get_alloc_info(cache, object);
> +		free_info = get_free_info(cache, object);
>  
>  		switch (alloc_info->state) {
>  		case KASAN_STATE_ALLOC:
> @@ -550,10 +558,6 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object)
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
> @@ -568,6 +572,9 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
>  	if (unlikely(object == NULL))
>  		return;
>  
> +	if (!(cache->flags & SLAB_KASAN))
> +		return;
> +
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
> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> index fb87923..d1dee1d 100644
> --- a/mm/kasan/kasan.h
> +++ b/mm/kasan/kasan.h
> @@ -2,7 +2,6 @@
>  #define __MM_KASAN_KASAN_H
>  
>  #include <linux/kasan.h>
> -#include <linux/stackdepot.h>
>  
>  #define KASAN_SHADOW_SCALE_SIZE (1UL << KASAN_SHADOW_SCALE_SHIFT)
>  #define KASAN_SHADOW_MASK       (KASAN_SHADOW_SCALE_SIZE - 1)
> @@ -68,34 +67,11 @@ enum kasan_state {
>  
>  #define KASAN_STACK_DEPTH 64
>  
> -struct kasan_track {
> -	u32 pid;
> -	depot_stack_handle_t stack;
> -};
> -
> -struct kasan_alloc_meta {
> -	struct kasan_track track;
> -	u32 state : 2;	/* enum kasan_state */
> -	u32 alloc_size : 30;
> -};
> -
> -struct qlist_node {
> -	struct qlist_node *next;
> -};
> -struct kasan_free_meta {
> -	/* This field is used while the object is in the quarantine.
> -	 * Otherwise it might be used for the allocator freelist.
> -	 */
> -	struct qlist_node quarantine_link;
> -	struct kasan_track track;
> -};
> -
>  struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
>  					const void *object);
>  struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
>  					const void *object);
>  
> -
>  static inline const void *kasan_shadow_to_mem(const void *shadow_addr)
>  {
>  	return (void *)(((unsigned long)shadow_addr - KASAN_SHADOW_OFFSET)
> @@ -110,7 +86,7 @@ static inline bool kasan_report_enabled(void)
>  void kasan_report(unsigned long addr, size_t size,
>  		bool is_write, unsigned long ip);
>  
> -#ifdef CONFIG_SLAB
> +#if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
>  void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
>  void quarantine_reduce(void);
>  void quarantine_remove_cache(struct kmem_cache *cache);
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index b3c122d..861b977 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -116,7 +116,6 @@ static inline bool init_task_stack_addr(const void *addr)
>  			sizeof(init_thread_union.stack));
>  }
>  
> -#ifdef CONFIG_SLAB
>  static void print_track(struct kasan_track *track)
>  {
>  	pr_err("PID = %u\n", track->pid);
> @@ -130,8 +129,8 @@ static void print_track(struct kasan_track *track)
>  	}
>  }
>  
> -static void object_err(struct kmem_cache *cache, struct page *page,
> -			void *object, char *unused_reason)
> +static void kasan_object_err(struct kmem_cache *cache, struct page *page,
> +				void *object, char *unused_reason)
>  {
>  	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
>  	struct kasan_free_meta *free_info;
> @@ -162,7 +161,6 @@ static void object_err(struct kmem_cache *cache, struct page *page,
>  		break;
>  	}
>  }
> -#endif
>  
>  static void print_address_description(struct kasan_access_info *info)
>  {
> @@ -177,7 +175,7 @@ static void print_address_description(struct kasan_access_info *info)
>  			struct kmem_cache *cache = page->slab_cache;
>  			object = nearest_obj(cache, page,
>  						(void *)info->access_addr);
> -			object_err(cache, page, object,
> +			kasan_object_err(cache, page, object,
>  					"kasan: bad access detected");
>  			return;
>  		}
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
>  
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
> +

Perhaps, print_trailer() also needs to adjust offset? Could you check
it?

And, it would be better to move this snippet to down, to be consistent
with sequence of size calculation in calculate_sizes().

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
>  
>  static inline void slab_free_freelist_hook(struct kmem_cache *s,
> @@ -2753,6 +2759,9 @@ slab_empty:
>  	discard_slab(s, page);
>  }
>  
> +static void do_slab_free(struct kmem_cache *s, struct page *page,
> +		void *head, void *tail, int cnt, unsigned long addr);
> +
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

Could you add similar comment on slab_free_hook(), too? It's
non-trivial that kasan_slab_free() could put the items into quarantine.

And, I guess slab_free_freelist_hook() should be changed because after
slab_free_hook() put the items into quarantine, we cannot make sure if
get_freepointer() returns next object on this list. Theoretically,
quarantine reduction could happen and freepointer of this object could
be changed.

Thanks.

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
> -- 
> 2.8.0.rc3.226.g39d4020
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
