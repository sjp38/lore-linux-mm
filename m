Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3AEF06B0035
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 02:03:35 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so275294pad.11
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 23:03:34 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id th10si10966747pab.18.2014.07.14.23.03.32
        for <linux-mm@kvack.org>;
        Mon, 14 Jul 2014 23:03:34 -0700 (PDT)
Date: Tue, 15 Jul 2014 15:09:32 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC/PATCH RESEND -next 15/21] mm: slub: add kernel address
 sanitizer hooks to slub allocator
Message-ID: <20140715060932.GJ11317@js1304-P5Q-DELUXE>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1404905415-9046-16-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404905415-9046-16-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On Wed, Jul 09, 2014 at 03:30:09PM +0400, Andrey Ryabinin wrote:
> With this patch kasan will be able to catch bugs in memory allocated
> by slub.
> Allocated slab page, this whole page marked as unaccessible
> in corresponding shadow memory.
> On allocation of slub object requested allocation size marked as
> accessible, and the rest of the object (including slub's metadata)
> marked as redzone (unaccessible).
> 
> We also mark object as accessible if ksize was called for this object.
> There is some places in kernel where ksize function is called to inquire
> size of really allocated area. Such callers could validly access whole
> allocated memory, so it should be marked as accessible by kasan_krealloc call.
> 
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> ---
>  include/linux/kasan.h |  22 ++++++++++
>  include/linux/slab.h  |  19 +++++++--
>  lib/Kconfig.kasan     |   2 +
>  mm/kasan/kasan.c      | 110 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/kasan/kasan.h      |   5 +++
>  mm/kasan/report.c     |  23 +++++++++++
>  mm/slab.h             |   2 +-
>  mm/slab_common.c      |   9 +++--
>  mm/slub.c             |  24 ++++++++++-
>  9 files changed, 208 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> index 4adc0a1..583c011 100644
> --- a/include/linux/kasan.h
> +++ b/include/linux/kasan.h
> @@ -20,6 +20,17 @@ void kasan_init_shadow(void);
>  void kasan_alloc_pages(struct page *page, unsigned int order);
>  void kasan_free_pages(struct page *page, unsigned int order);
>  
> +void kasan_kmalloc_large(const void *ptr, size_t size);
> +void kasan_kfree_large(const void *ptr);
> +void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size);
> +void kasan_krealloc(const void *object, size_t new_size);
> +
> +void kasan_slab_alloc(struct kmem_cache *s, void *object);
> +void kasan_slab_free(struct kmem_cache *s, void *object);
> +
> +void kasan_alloc_slab_pages(struct page *page, int order);
> +void kasan_free_slab_pages(struct page *page, int order);
> +
>  #else /* CONFIG_KASAN */
>  
>  static inline void unpoison_shadow(const void *address, size_t size) {}
> @@ -34,6 +45,17 @@ static inline void kasan_alloc_shadow(void) {}
>  static inline void kasan_alloc_pages(struct page *page, unsigned int order) {}
>  static inline void kasan_free_pages(struct page *page, unsigned int order) {}
>  
> +static inline void kasan_kmalloc_large(void *ptr, size_t size) {}
> +static inline void kasan_kfree_large(const void *ptr) {}
> +static inline void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size) {}
> +static inline void kasan_krealloc(const void *object, size_t new_size) {}
> +
> +static inline void kasan_slab_alloc(struct kmem_cache *s, void *object) {}
> +static inline void kasan_slab_free(struct kmem_cache *s, void *object) {}
> +
> +static inline void kasan_alloc_slab_pages(struct page *page, int order) {}
> +static inline void kasan_free_slab_pages(struct page *page, int order) {}
> +
>  #endif /* CONFIG_KASAN */
>  
>  #endif /* LINUX_KASAN_H */
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 68b1feab..a9513e9 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -104,6 +104,7 @@
>  				(unsigned long)ZERO_SIZE_PTR)
>  
>  #include <linux/kmemleak.h>
> +#include <linux/kasan.h>
>  
>  struct mem_cgroup;
>  /*
> @@ -444,6 +445,8 @@ static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
>   */
>  static __always_inline void *kmalloc(size_t size, gfp_t flags)
>  {
> +	void *ret;
> +
>  	if (__builtin_constant_p(size)) {
>  		if (size > KMALLOC_MAX_CACHE_SIZE)
>  			return kmalloc_large(size, flags);
> @@ -454,8 +457,12 @@ static __always_inline void *kmalloc(size_t size, gfp_t flags)
>  			if (!index)
>  				return ZERO_SIZE_PTR;
>  
> -			return kmem_cache_alloc_trace(kmalloc_caches[index],
> +			ret = kmem_cache_alloc_trace(kmalloc_caches[index],
>  					flags, size);
> +
> +			kasan_kmalloc(kmalloc_caches[index], ret, size);
> +
> +			return ret;
>  		}
>  #endif
>  	}
> @@ -485,6 +492,8 @@ static __always_inline int kmalloc_size(int n)
>  static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
>  {
>  #ifndef CONFIG_SLOB
> +	void *ret;
> +
>  	if (__builtin_constant_p(size) &&
>  		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & GFP_DMA)) {
>  		int i = kmalloc_index(size);
> @@ -492,8 +501,12 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
>  		if (!i)
>  			return ZERO_SIZE_PTR;
>  
> -		return kmem_cache_alloc_node_trace(kmalloc_caches[i],
> -						flags, node, size);
> +		ret = kmem_cache_alloc_node_trace(kmalloc_caches[i],
> +						  flags, node, size);
> +
> +		kasan_kmalloc(kmalloc_caches[i], ret, size);
> +
> +		return ret;
>  	}
>  #endif
>  	return __kmalloc_node(size, flags, node);
> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> index 2bfff78..289a624 100644
> --- a/lib/Kconfig.kasan
> +++ b/lib/Kconfig.kasan
> @@ -5,6 +5,8 @@ if HAVE_ARCH_KASAN
>  
>  config KASAN
>  	bool "AddressSanitizer: dynamic memory error detector"
> +	depends on SLUB
> +	select STACKTRACE
>  	default n
>  	help
>  	  Enables AddressSanitizer - dynamic memory error detector,
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 109478e..9b5182a 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -177,6 +177,116 @@ void __init kasan_init_shadow(void)
>  	}
>  }
>  
> +void kasan_alloc_slab_pages(struct page *page, int order)
> +{
> +	if (unlikely(!kasan_initialized))
> +		return;
> +
> +	poison_shadow(page_address(page), PAGE_SIZE << order, KASAN_SLAB_REDZONE);
> +}
> +
> +void kasan_free_slab_pages(struct page *page, int order)
> +{
> +	if (unlikely(!kasan_initialized))
> +		return;
> +
> +	poison_shadow(page_address(page), PAGE_SIZE << order, KASAN_SLAB_FREE);
> +}
> +
> +void kasan_slab_alloc(struct kmem_cache *cache, void *object)
> +{
> +	if (unlikely(!kasan_initialized))
> +		return;
> +
> +	if (unlikely(object == NULL))
> +		return;
> +
> +	poison_shadow(object, cache->size, KASAN_KMALLOC_REDZONE);
> +	unpoison_shadow(object, cache->alloc_size);
> +}
> +
> +void kasan_slab_free(struct kmem_cache *cache, void *object)
> +{
> +	unsigned long size = cache->size;
> +	unsigned long rounded_up_size = round_up(size, KASAN_SHADOW_SCALE_SIZE);
> +
> +	if (unlikely(!kasan_initialized))
> +		return;
> +
> +	poison_shadow(object, rounded_up_size, KASAN_KMALLOC_FREE);
> +}
> +
> +void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size)
> +{
> +	unsigned long redzone_start;
> +	unsigned long redzone_end;
> +
> +	if (unlikely(!kasan_initialized))
> +		return;
> +
> +	if (unlikely(object == NULL))
> +		return;
> +
> +	redzone_start = round_up((unsigned long)(object + size),
> +				KASAN_SHADOW_SCALE_SIZE);
> +	redzone_end = (unsigned long)object + cache->size;
> +
> +	unpoison_shadow(object, size);
> +	poison_shadow((void *)redzone_start, redzone_end - redzone_start,
> +		KASAN_KMALLOC_REDZONE);
> +
> +}
> +EXPORT_SYMBOL(kasan_kmalloc);
> +
> +void kasan_kmalloc_large(const void *ptr, size_t size)
> +{
> +	struct page *page;
> +	unsigned long redzone_start;
> +	unsigned long redzone_end;
> +
> +	if (unlikely(!kasan_initialized))
> +		return;
> +
> +	if (unlikely(ptr == NULL))
> +		return;
> +
> +	page = virt_to_page(ptr);
> +	redzone_start = round_up((unsigned long)(ptr + size),
> +				KASAN_SHADOW_SCALE_SIZE);
> +	redzone_end = (unsigned long)ptr + (PAGE_SIZE << compound_order(page));
> +
> +	unpoison_shadow(ptr, size);
> +	poison_shadow((void *)redzone_start, redzone_end - redzone_start,
> +		KASAN_PAGE_REDZONE);
> +}
> +EXPORT_SYMBOL(kasan_kmalloc_large);
> +
> +void kasan_krealloc(const void *object, size_t size)
> +{
> +	struct page *page;
> +
> +	if (unlikely(object == ZERO_SIZE_PTR))
> +		return;
> +
> +	page = virt_to_head_page(object);
> +
> +	if (unlikely(!PageSlab(page)))
> +		kasan_kmalloc_large(object, size);
> +	else
> +		kasan_kmalloc(page->slab_cache, object, size);
> +}
> +
> +void kasan_kfree_large(const void *ptr)
> +{
> +	struct page *page;
> +
> +	if (unlikely(!kasan_initialized))
> +		return;
> +
> +	page = virt_to_page(ptr);
> +	poison_shadow(ptr, PAGE_SIZE << compound_order(page), KASAN_FREE_PAGE);
> +}
> +
>  void kasan_alloc_pages(struct page *page, unsigned int order)
>  {
>  	if (unlikely(!kasan_initialized))
> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> index be9597e..f925d03 100644
> --- a/mm/kasan/kasan.h
> +++ b/mm/kasan/kasan.h
> @@ -6,6 +6,11 @@
>  #define KASAN_SHADOW_MASK       (KASAN_SHADOW_SCALE_SIZE - 1)
>  
>  #define KASAN_FREE_PAGE         0xFF  /* page was freed */
> +#define KASAN_PAGE_REDZONE      0xFE  /* redzone for kmalloc_large allocations */
> +#define KASAN_SLAB_REDZONE      0xFD  /* Slab page redzone, does not belong to any slub object */
> +#define KASAN_KMALLOC_REDZONE   0xFC  /* redzone inside slub object */
> +#define KASAN_KMALLOC_FREE      0xFB  /* object was freed (kmem_cache_free/kfree) */
> +#define KASAN_SLAB_FREE         0xFA  /* free slab page */
>  #define KASAN_SHADOW_GAP        0xF9  /* address belongs to shadow memory */
>  
>  struct access_info {
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index 6ef9e57..6d829af 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -43,10 +43,15 @@ static void print_error_description(struct access_info *info)
>  	u8 shadow_val = *(u8 *)kasan_mem_to_shadow(info->access_addr);
>  
>  	switch (shadow_val) {
> +	case KASAN_PAGE_REDZONE:
> +	case KASAN_SLAB_REDZONE:
> +	case KASAN_KMALLOC_REDZONE:
>  	case 0 ... KASAN_SHADOW_SCALE_SIZE - 1:
>  		bug_type = "buffer overflow";
>  		break;
>  	case KASAN_FREE_PAGE:
> +	case KASAN_SLAB_FREE:
> +	case KASAN_KMALLOC_FREE:
>  		bug_type = "use after free";
>  		break;
>  	case KASAN_SHADOW_GAP:
> @@ -70,7 +75,25 @@ static void print_address_description(struct access_info *info)
>  	page = virt_to_page(info->access_addr);
>  
>  	switch (shadow_val) {
> +	case KASAN_SLAB_REDZONE:
> +		cache = virt_to_cache((void *)info->access_addr);
> +		slab_err(cache, page, "access to slab redzone");

We need head page of invalid access address for slab_err() since head
page has all meta data of this slab. So, instead of, virt_to_cache,
use virt_to_head_page() and page->slab_cache.

> +		dump_stack();
> +		break;
> +	case KASAN_KMALLOC_FREE:
> +	case KASAN_KMALLOC_REDZONE:
> +	case 1 ... KASAN_SHADOW_SCALE_SIZE - 1:
> +		if (PageSlab(page)) {
> +			cache = virt_to_cache((void *)info->access_addr);
> +			slab_start = page_address(virt_to_head_page((void *)info->access_addr));
> +			object = virt_to_obj(cache, slab_start,
> +					(void *)info->access_addr);
> +			object_err(cache, page, object, "kasan error");
> +			break;
> +		}

Same here, page should be head page.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
