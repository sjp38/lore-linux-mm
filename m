Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id DAB6F82BDC
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 00:48:37 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id cm18so5521145qab.0
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 21:48:37 -0700 (PDT)
Received: from mail-qg0-x22a.google.com (mail-qg0-x22a.google.com [2607:f8b0:400d:c04::22a])
        by mx.google.com with ESMTPS id e93si4808634qge.84.2014.09.25.21.48.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Sep 2014 21:48:37 -0700 (PDT)
Received: by mail-qg0-f42.google.com with SMTP id z60so7254275qgd.15
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 21:48:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1411562649-28231-10-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1411562649-28231-1-git-send-email-a.ryabinin@samsung.com> <1411562649-28231-10-git-send-email-a.ryabinin@samsung.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 25 Sep 2014 21:48:16 -0700
Message-ID: <CACT4Y+a0DMk8vyCcesrsKt7rXVDD2LZsfnGemJAgeRiVbMxxxw@mail.gmail.com>
Subject: Re: [PATCH v3 09/13] mm: slub: add kernel address sanitizer support
 for slub allocator
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On Wed, Sep 24, 2014 at 5:44 AM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> With this patch kasan will be able to catch bugs in memory allocated
> by slub.
> Initially all objects in newly allocated slab page, marked as free.
> Later, when allocation of slub object happens, requested by caller
> number of bytes marked as accessible, and the rest of the object
> (including slub's metadata) marked as redzone (inaccessible).
>
> We also mark object as accessible if ksize was called for this object.
> There is some places in kernel where ksize function is called to inquire
> size of really allocated area. Such callers could validly access whole
> allocated memory, so it should be marked as accessible.
>
> Code in slub.c and slab_common.c files could validly access to object's
> metadata, so instrumentation for this files are disabled.
>
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> ---
>  include/linux/kasan.h | 24 +++++++++++++
>  include/linux/slab.h  | 11 ++++--
>  lib/Kconfig.kasan     |  1 +
>  mm/Makefile           |  3 ++
>  mm/kasan/kasan.c      | 97 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/kasan/kasan.h      |  5 +++
>  mm/kasan/report.c     | 27 ++++++++++++++
>  mm/slab_common.c      |  5 ++-
>  mm/slub.c             | 36 +++++++++++++++++--
>  9 files changed, 203 insertions(+), 6 deletions(-)
>
> diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> index 9714fba..4b866fa 100644
> --- a/include/linux/kasan.h
> +++ b/include/linux/kasan.h
> @@ -32,6 +32,17 @@ void kasan_unpoison_shadow(const void *address, size_t size);
>
>  void kasan_alloc_pages(struct page *page, unsigned int order);
>  void kasan_free_pages(struct page *page, unsigned int order);
> +void kasan_mark_slab_padding(struct kmem_cache *s, void *object);
> +
> +void kasan_kmalloc_large(const void *ptr, size_t size);
> +void kasan_kfree_large(const void *ptr);
> +void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size);
> +void kasan_krealloc(const void *object, size_t new_size);
> +
> +void kasan_slab_alloc(struct kmem_cache *s, void *object);
> +void kasan_slab_free(struct kmem_cache *s, void *object);
> +
> +void kasan_free_slab_pages(struct page *page, int order);
>
>  #else /* CONFIG_KASAN */
>
> @@ -42,6 +53,19 @@ static inline void kasan_disable_local(void) {}
>
>  static inline void kasan_alloc_pages(struct page *page, unsigned int order) {}
>  static inline void kasan_free_pages(struct page *page, unsigned int order) {}
> +static inline void kasan_mark_slab_padding(struct kmem_cache *s,
> +                                       void *object) {}
> +
> +static inline void kasan_kmalloc_large(void *ptr, size_t size) {}
> +static inline void kasan_kfree_large(const void *ptr) {}
> +static inline void kasan_kmalloc(struct kmem_cache *s, const void *object,
> +                               size_t size) {}
> +static inline void kasan_krealloc(const void *object, size_t new_size) {}
> +
> +static inline void kasan_slab_alloc(struct kmem_cache *s, void *object) {}
> +static inline void kasan_slab_free(struct kmem_cache *s, void *object) {}
> +
> +static inline void kasan_free_slab_pages(struct page *page, int order) {}
>
>  #endif /* CONFIG_KASAN */
>
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index c265bec..5f97037 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -104,6 +104,7 @@
>                                 (unsigned long)ZERO_SIZE_PTR)
>
>  #include <linux/kmemleak.h>
> +#include <linux/kasan.h>
>
>  struct mem_cgroup;
>  /*
> @@ -326,7 +327,10 @@ kmem_cache_alloc_node_trace(struct kmem_cache *s,
>  static __always_inline void *kmem_cache_alloc_trace(struct kmem_cache *s,
>                 gfp_t flags, size_t size)
>  {
> -       return kmem_cache_alloc(s, flags);
> +       void *ret = kmem_cache_alloc(s, flags);
> +
> +       kasan_kmalloc(s, ret, size);
> +       return ret;
>  }
>
>  static __always_inline void *
> @@ -334,7 +338,10 @@ kmem_cache_alloc_node_trace(struct kmem_cache *s,
>                               gfp_t gfpflags,
>                               int node, size_t size)
>  {
> -       return kmem_cache_alloc_node(s, gfpflags, node);
> +       void *ret = kmem_cache_alloc_node(s, gfpflags, node);
> +
> +       kasan_kmalloc(s, ret, size);
> +       return ret;
>  }
>  #endif /* CONFIG_TRACING */
>
> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> index b458a00..d16b899 100644
> --- a/lib/Kconfig.kasan
> +++ b/lib/Kconfig.kasan
> @@ -6,6 +6,7 @@ if HAVE_ARCH_KASAN
>  config KASAN
>         bool "AddressSanitizer: runtime memory debugger"
>         depends on !MEMORY_HOTPLUG
> +       depends on SLUB_DEBUG


What does SLUB_DEBUG do? I think that generally we don't want any
other *heavy* debug checks to be required for kasan.


>         help
>           Enables address sanitizer - runtime memory debugger,
>           designed to find out-of-bounds accesses and use-after-free bugs.
> diff --git a/mm/Makefile b/mm/Makefile
> index 7a4b87e..c08a70f 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -2,6 +2,9 @@
>  # Makefile for the linux memory manager.
>  #
>
> +KASAN_SANITIZE_slab_common.o := n
> +KASAN_SANITIZE_slub.o := n
> +
>  mmu-y                  := nommu.o
>  mmu-$(CONFIG_MMU)      := gup.o highmem.o madvise.o memory.o mincore.o \
>                            mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 7cfc1fe..3c1687a 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -30,6 +30,7 @@
>  #include <linux/kasan.h>
>
>  #include "kasan.h"
> +#include "../slab.h"
>
>  /*
>   * Poisons the shadow memory for 'size' bytes starting from 'addr'.
> @@ -265,6 +266,102 @@ void kasan_free_pages(struct page *page, unsigned int order)
>                                 KASAN_FREE_PAGE);
>  }
>
> +void kasan_free_slab_pages(struct page *page, int order)

Doesn't this callback followed by actually freeing the pages, and so
kasan_free_pages callback that will poison the range? If so, I would
prefer to not double poison.


> +{
> +       kasan_poison_shadow(page_address(page),
> +                       PAGE_SIZE << order, KASAN_SLAB_FREE);
> +}
> +
> +void kasan_mark_slab_padding(struct kmem_cache *s, void *object)
> +{
> +       unsigned long object_end = (unsigned long)object + s->size;
> +       unsigned long padding_end = round_up(object_end, PAGE_SIZE);
> +       unsigned long padding_start = round_up(object_end,
> +                                       KASAN_SHADOW_SCALE_SIZE);
> +       size_t size = padding_end - padding_start;
> +
> +       if (size)
> +               kasan_poison_shadow((void *)padding_start,
> +                               size, KASAN_SLAB_PADDING);
> +}
> +
> +void kasan_slab_alloc(struct kmem_cache *cache, void *object)
> +{
> +       kasan_kmalloc(cache, object, cache->object_size);
> +}
> +
> +void kasan_slab_free(struct kmem_cache *cache, void *object)
> +{
> +       unsigned long size = cache->size;
> +       unsigned long rounded_up_size = round_up(size, KASAN_SHADOW_SCALE_SIZE);
> +

Add a comment saying that SLAB_DESTROY_BY_RCU objects can be "legally"
used after free.

> +       if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
> +               return;
> +
> +       kasan_poison_shadow(object, rounded_up_size, KASAN_KMALLOC_FREE);
> +}
> +
> +void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size)
> +{
> +       unsigned long redzone_start;
> +       unsigned long redzone_end;
> +
> +       if (unlikely(object == NULL))
> +               return;
> +
> +       redzone_start = round_up((unsigned long)(object + size),
> +                               KASAN_SHADOW_SCALE_SIZE);
> +       redzone_end = (unsigned long)object + cache->size;
> +
> +       kasan_unpoison_shadow(object, size);
> +       kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
> +               KASAN_KMALLOC_REDZONE);
> +
> +}
> +EXPORT_SYMBOL(kasan_kmalloc);
> +
> +void kasan_kmalloc_large(const void *ptr, size_t size)
> +{
> +       struct page *page;
> +       unsigned long redzone_start;
> +       unsigned long redzone_end;
> +
> +       if (unlikely(ptr == NULL))
> +               return;
> +
> +       page = virt_to_page(ptr);
> +       redzone_start = round_up((unsigned long)(ptr + size),
> +                               KASAN_SHADOW_SCALE_SIZE);
> +       redzone_end = (unsigned long)ptr + (PAGE_SIZE << compound_order(page));

If size == N*PAGE_SIZE - KASAN_SHADOW_SCALE_SIZE - 1, the object does
not receive any redzone at all. Can we pass full memory block size
from above to fix it? Will compound_order(page) do?

> +
> +       kasan_unpoison_shadow(ptr, size);
> +       kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
> +               KASAN_PAGE_REDZONE);
> +}
> +
> +void kasan_krealloc(const void *object, size_t size)
> +{
> +       struct page *page;
> +
> +       if (unlikely(object == ZERO_SIZE_PTR))
> +               return;
> +
> +       page = virt_to_head_page(object);
> +
> +       if (unlikely(!PageSlab(page)))
> +               kasan_kmalloc_large(object, size);
> +       else
> +               kasan_kmalloc(page->slab_cache, object, size);
> +}
> +
> +void kasan_kfree_large(const void *ptr)
> +{
> +       struct page *page = virt_to_page(ptr);
> +
> +       kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
> +                       KASAN_FREE_PAGE);
> +}
> +
>  void __asan_load1(unsigned long addr)
>  {
>         check_memory_region(addr, 1, false);
> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> index 5e61799..b3974c7 100644
> --- a/mm/kasan/kasan.h
> +++ b/mm/kasan/kasan.h
> @@ -7,6 +7,11 @@
>  #define KASAN_SHADOW_MASK       (KASAN_SHADOW_SCALE_SIZE - 1)
>
>  #define KASAN_FREE_PAGE         0xFF  /* page was freed */
> +#define KASAN_PAGE_REDZONE      0xFE  /* redzone for kmalloc_large allocations */
> +#define KASAN_SLAB_PADDING      0xFD  /* Slab page padding, does not belong to any slub object */
> +#define KASAN_KMALLOC_REDZONE   0xFC  /* redzone inside slub object */
> +#define KASAN_KMALLOC_FREE      0xFB  /* object was freed (kmem_cache_free/kfree) */
> +#define KASAN_SLAB_FREE         0xFA  /* free slab page */
>  #define KASAN_SHADOW_GAP        0xF9  /* address belongs to shadow memory */
>
>  struct access_info {
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index f9d4e8d..c42f6ba 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -24,6 +24,7 @@
>  #include <linux/kasan.h>
>
>  #include "kasan.h"
> +#include "../slab.h"
>
>  /* Shadow layout customization. */
>  #define SHADOW_BYTES_PER_BLOCK 1
> @@ -54,10 +55,15 @@ static void print_error_description(struct access_info *info)
>         shadow_val = *(u8 *)kasan_mem_to_shadow(info->first_bad_addr);
>
>         switch (shadow_val) {
> +       case KASAN_PAGE_REDZONE:
> +       case KASAN_SLAB_PADDING:
> +       case KASAN_KMALLOC_REDZONE:
>         case 0 ... KASAN_SHADOW_SCALE_SIZE - 1:
>                 bug_type = "out of bounds access";
>                 break;
>         case KASAN_FREE_PAGE:
> +       case KASAN_SLAB_FREE:
> +       case KASAN_KMALLOC_FREE:
>                 bug_type = "use after free";
>                 break;
>         case KASAN_SHADOW_GAP:
> @@ -73,12 +79,33 @@ static void print_error_description(struct access_info *info)
>  static void print_address_description(struct access_info *info)
>  {
>         struct page *page;
> +       struct kmem_cache *cache;
>         u8 shadow_val = *(u8 *)kasan_mem_to_shadow(info->first_bad_addr);
>
>         page = virt_to_head_page((void *)info->access_addr);
>
>         switch (shadow_val) {
> +       case KASAN_SLAB_PADDING:
> +               cache = page->slab_cache;
> +               slab_err(cache, page, "access to slab redzone");
> +               dump_stack();
> +               break;
> +       case KASAN_KMALLOC_FREE:
> +       case KASAN_KMALLOC_REDZONE:
> +       case 1 ... KASAN_SHADOW_SCALE_SIZE - 1:
> +               if (PageSlab(page)) {
> +                       void *object;
> +                       void *slab_page = page_address(page);
> +
> +                       cache = page->slab_cache;
> +                       object = virt_to_obj(cache, slab_page,
> +                                       (void *)info->access_addr);
> +                       object_err(cache, page, object, "kasan error");
> +                       break;
> +               }
> +       case KASAN_PAGE_REDZONE:
>         case KASAN_FREE_PAGE:
> +       case KASAN_SLAB_FREE:
>                 dump_page(page, "kasan error");
>                 dump_stack();
>                 break;
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 3a6e0cf..33868b4 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -795,6 +795,7 @@ void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
>         page = alloc_kmem_pages(flags, order);
>         ret = page ? page_address(page) : NULL;
>         kmemleak_alloc(ret, size, 1, flags);
> +       kasan_kmalloc_large(ret, size);
>         return ret;
>  }
>  EXPORT_SYMBOL(kmalloc_order);
> @@ -969,8 +970,10 @@ static __always_inline void *__do_krealloc(const void *p, size_t new_size,
>         if (p)
>                 ks = ksize(p);
>
> -       if (ks >= new_size)
> +       if (ks >= new_size) {
> +               kasan_krealloc((void *)p, new_size);
>                 return (void *)p;
> +       }
>
>         ret = kmalloc_track_caller(new_size, flags);
>         if (ret && p)
> diff --git a/mm/slub.c b/mm/slub.c
> index 9b1f75c..12ffdd0 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -33,6 +33,7 @@
>  #include <linux/stacktrace.h>
>  #include <linux/prefetch.h>
>  #include <linux/memcontrol.h>
> +#include <linux/kasan.h>
>
>  #include <trace/events/kmem.h>
>
> @@ -469,10 +470,12 @@ static int disable_higher_order_debug;
>
>  static inline void metadata_access_enable(void)
>  {
> +       kasan_disable_local();
>  }
>
>  static inline void metadata_access_disable(void)
>  {
> +       kasan_enable_local();
>  }
>
>  /*
> @@ -1242,11 +1245,13 @@ static inline void dec_slabs_node(struct kmem_cache *s, int node,
>  static inline void kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
>  {
>         kmemleak_alloc(ptr, size, 1, flags);
> +       kasan_kmalloc_large(ptr, size);
>  }
>
>  static inline void kfree_hook(const void *x)
>  {
>         kmemleak_free(x);
> +       kasan_kfree_large(x);
>  }
>
>  static inline int slab_pre_alloc_hook(struct kmem_cache *s, gfp_t flags)
> @@ -1264,11 +1269,13 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s,
>         flags &= gfp_allowed_mask;
>         kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
>         kmemleak_alloc_recursive(object, s->object_size, 1, s->flags, flags);
> +       kasan_slab_alloc(s, object);
>  }
>
>  static inline void slab_free_hook(struct kmem_cache *s, void *x)
>  {
>         kmemleak_free_recursive(x, s->flags);
> +       kasan_slab_free(s, x);
>
>         /*
>          * Trouble is that we may no longer disable interrupts in the fast path
> @@ -1381,8 +1388,11 @@ static void setup_object(struct kmem_cache *s, struct page *page,
>                                 void *object)
>  {
>         setup_object_debug(s, page, object);
> -       if (unlikely(s->ctor))
> +       if (unlikely(s->ctor)) {
> +               kasan_slab_alloc(s, object);
>                 s->ctor(object);
> +       }
> +       kasan_slab_free(s, object);
>  }
>
>  static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
> @@ -1416,8 +1426,10 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
>                 setup_object(s, page, p);
>                 if (likely(idx < page->objects))
>                         set_freepointer(s, p, p + s->size);

Sorry, I don't fully follow this code, so I will just ask some questions.
Can we have some slab padding after last object in this case as well?

> -               else
> +               else {
>                         set_freepointer(s, p, NULL);
> +                       kasan_mark_slab_padding(s, p);

kasan_mark_slab_padding poisons only up to end of the page. Can there
be multiple pages that we need to poison?

> +               }
>         }
>
>         page->freelist = start;
> @@ -1442,6 +1454,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
>         }
>
>         kmemcheck_free_shadow(page, compound_order(page));
> +       kasan_free_slab_pages(page, compound_order(page));
>
>         mod_zone_page_state(page_zone(page),
>                 (s->flags & SLAB_RECLAIM_ACCOUNT) ?
> @@ -2488,6 +2501,7 @@ void *kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size)
>  {
>         void *ret = slab_alloc(s, gfpflags, _RET_IP_);
>         trace_kmalloc(_RET_IP_, ret, size, s->size, gfpflags);
> +       kasan_kmalloc(s, ret, size);
>         return ret;
>  }
>  EXPORT_SYMBOL(kmem_cache_alloc_trace);
> @@ -2514,6 +2528,8 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
>
>         trace_kmalloc_node(_RET_IP_, ret,
>                            size, s->size, gfpflags, node);
> +
> +       kasan_kmalloc(s, ret, size);
>         return ret;
>  }
>  EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
> @@ -2897,6 +2913,7 @@ static void early_kmem_cache_node_alloc(int node)
>         init_object(kmem_cache_node, n, SLUB_RED_ACTIVE);
>         init_tracking(kmem_cache_node, n);
>  #endif
> +       kasan_kmalloc(kmem_cache_node, n, sizeof(struct kmem_cache_node));
>         init_kmem_cache_node(n);
>         inc_slabs_node(kmem_cache_node, node, page->objects);
>
> @@ -3269,6 +3286,8 @@ void *__kmalloc(size_t size, gfp_t flags)
>
>         trace_kmalloc(_RET_IP_, ret, size, s->size, flags);
>
> +       kasan_kmalloc(s, ret, size);
> +
>         return ret;
>  }
>  EXPORT_SYMBOL(__kmalloc);
> @@ -3312,12 +3331,14 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
>
>         trace_kmalloc_node(_RET_IP_, ret, size, s->size, flags, node);
>
> +       kasan_kmalloc(s, ret, size);
> +
>         return ret;
>  }
>  EXPORT_SYMBOL(__kmalloc_node);
>  #endif
>
> -size_t ksize(const void *object)
> +static size_t __ksize(const void *object)
>  {
>         struct page *page;
>
> @@ -3333,6 +3354,15 @@ size_t ksize(const void *object)
>
>         return slab_ksize(page->slab_cache);
>  }
> +
> +size_t ksize(const void *object)
> +{
> +       size_t size = __ksize(object);
> +       /* We assume that ksize callers could use whole allocated area,
> +          so we need unpoison this area. */
> +       kasan_krealloc(object, size);
> +       return size;
> +}
>  EXPORT_SYMBOL(ksize);
>
>  void kfree(const void *x)
> --
> 2.1.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
