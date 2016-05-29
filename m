Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A87F66B0253
	for <linux-mm@kvack.org>; Sun, 29 May 2016 10:28:15 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id n2so18538570wma.0
        for <linux-mm@kvack.org>; Sun, 29 May 2016 07:28:15 -0700 (PDT)
Received: from mail-lf0-x229.google.com (mail-lf0-x229.google.com. [2a00:1450:4010:c07::229])
        by mx.google.com with ESMTPS id l200si6118202lfb.24.2016.05.29.07.28.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 May 2016 07:28:13 -0700 (PDT)
Received: by mail-lf0-x229.google.com with SMTP id s64so39023087lfe.0
        for <linux-mm@kvack.org>; Sun, 29 May 2016 07:28:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160524183018.GA4769@cherokee.in.rdlabs.hpecorp.net>
References: <20160524183018.GA4769@cherokee.in.rdlabs.hpecorp.net>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 29 May 2016 16:27:53 +0200
Message-ID: <CACT4Y+ZBSEpqi+aUFdKZk9ncRzAxPpBRLV8DGrEuSWSBNbdpAQ@mail.gmail.com>
Subject: Re: [PATCH v3 1/2] mm, kasan: improve double-free detection
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Yury Norov <ynorov@caviumnetworks.com>

On Tue, May 24, 2016 at 8:30 PM, Kuthonuzo Luruo
<kuthonuzo.luruo@hpe.com> wrote:
> Currently, KASAN may fail to detect concurrent deallocations of the same
> object due to a race in kasan_slab_free(). This patch makes double-free
> detection more reliable by serializing access to KASAN object metadata.
> New functions kasan_meta_lock() and kasan_meta_unlock() are provided to
> lock/unlock per-object metadata. Double-free errors are now reported via
> kasan_report().
>
> Per-object lock concept from suggestion/observations by Dmitry Vyukov.
>
> Testing:
> - Tested with a modified version of the 'slab_test' microbenchmark where
>   allocs occur on CPU 0; then all other CPUs concurrently attempt to free
>   the same object.
> - Tested with new double-free tests for 'test_kasan' in accompanying patch.
>
> Signed-off-by: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
> ---
>
> Changes in v3:
> - simplified kasan_meta_lock()/unlock() to use generic bit spinlock apis;
>   kasan_alloc_meta structure modified accordingly.
> - introduced a 'safety valve' for kasan_meta_lock() to prevent a kfree from
>   getting stuck when a prior out-of-bounds write clobbers the object
>   header.
> - removed potentially unsafe __builtin_return_address(1) from
>   kasan_report() call per review comment from Yury Norov; callee now passed
>   into kasan_slab_free().
>
> ---
>  include/linux/kasan.h |    7 +++-
>  mm/kasan/kasan.c      |   88 ++++++++++++++++++++++++++++++++++---------------
>  mm/kasan/kasan.h      |   44 +++++++++++++++++++++++-
>  mm/kasan/quarantine.c |    2 +
>  mm/kasan/report.c     |   28 ++++++++++++++--
>  mm/slab.c             |    3 +-
>  mm/slub.c             |    2 +-
>  7 files changed, 138 insertions(+), 36 deletions(-)
>
> diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> index 611927f..3db974b 100644
> --- a/include/linux/kasan.h
> +++ b/include/linux/kasan.h
> @@ -53,6 +53,7 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
>  void kasan_cache_shrink(struct kmem_cache *cache);
>  void kasan_cache_destroy(struct kmem_cache *cache);
>
> +void kasan_init_object(struct kmem_cache *cache, void *object);
>  void kasan_poison_slab(struct page *page);
>  void kasan_unpoison_object_data(struct kmem_cache *cache, void *object);
>  void kasan_poison_object_data(struct kmem_cache *cache, void *object);
> @@ -65,7 +66,7 @@ void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size,
>  void kasan_krealloc(const void *object, size_t new_size, gfp_t flags);
>
>  void kasan_slab_alloc(struct kmem_cache *s, void *object, gfp_t flags);
> -bool kasan_slab_free(struct kmem_cache *s, void *object);
> +bool kasan_slab_free(struct kmem_cache *s, void *object, unsigned long caller);
>  void kasan_poison_slab_free(struct kmem_cache *s, void *object);
>
>  struct kasan_cache {
> @@ -94,6 +95,7 @@ static inline void kasan_cache_create(struct kmem_cache *cache,
>  static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
>  static inline void kasan_cache_destroy(struct kmem_cache *cache) {}
>
> +static inline void kasan_init_object(struct kmem_cache *s, void *object) {}
>  static inline void kasan_poison_slab(struct page *page) {}
>  static inline void kasan_unpoison_object_data(struct kmem_cache *cache,
>                                         void *object) {}
> @@ -110,7 +112,8 @@ static inline void kasan_krealloc(const void *object, size_t new_size,
>
>  static inline void kasan_slab_alloc(struct kmem_cache *s, void *object,
>                                    gfp_t flags) {}
> -static inline bool kasan_slab_free(struct kmem_cache *s, void *object)
> +static inline bool kasan_slab_free(struct kmem_cache *s, void *object,
> +               unsigned long caller)
>  {
>         return false;
>  }
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 18b6a2b..ab82e24 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -402,6 +402,35 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
>                         cache->object_size +
>                         optimal_redzone(cache->object_size)));
>  }
> +
> +void kasan_init_object(struct kmem_cache *cache, void *object)
> +{
> +       if (cache->flags & SLAB_KASAN) {
> +               struct kasan_alloc_meta *alloc_info;
> +
> +               alloc_info = get_alloc_info(cache, object);
> +               __memset(alloc_info, 0, sizeof(*alloc_info));
> +       }
> +}
> +
> +/* flags shadow for object header if it has been overwritten. */
> +void kasan_mark_bad_meta(struct kasan_alloc_meta *alloc_info,
> +               struct kasan_access_info *info)
> +{
> +       u8 *datap = (u8 *)&alloc_info->data;
> +
> +       if ((((u8 *)info->access_addr + info->access_size) > datap) &&
> +                       ((u8 *)info->first_bad_addr <= datap) &&
> +                       info->is_write)
> +               kasan_poison_shadow((void *)datap, KASAN_SHADOW_SCALE_SIZE,
> +                               KASAN_KMALLOC_BAD_META);


Is it only to prevent deadlocks in kasan_meta_lock?

If so, it is still unrelable because an OOB write can happen in
non-instrumented code. Or, kasan_meta_lock can successfully lock
overwritten garbage before noticing KASAN_KMALLOC_BAD_META. Or, two
threads can assume lock ownership after noticing
KASAN_KMALLOC_BAD_META.

After the first report we continue working in kind of best effort
mode: we can try to mitigate some things, but generally all bets are
off. Because of that there is no need to build something complex,
global (and still unrelable). I would just wait for at most, say, 10
seconds in kasan_meta_lock, if we can't get the lock -- print an error
and return. That's simple, local and won't deadlock under any
circumstances.
The error message will be helpful, because there are chances we will
report a double-free on free of the corrupted object.
 e
Tests can be arranged so that they write 0 (unlocked) into the meta
(if necessary).




> +}
> +
> +static void kasan_unmark_bad_meta(struct kasan_alloc_meta *alloc_info)
> +{
> +       kasan_poison_shadow((void *)&alloc_info->data, KASAN_SHADOW_SCALE_SIZE,
> +                       KASAN_KMALLOC_REDZONE);
> +}
>  #endif
>
>  void kasan_cache_shrink(struct kmem_cache *cache)
> @@ -431,13 +460,6 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object)
>         kasan_poison_shadow(object,
>                         round_up(cache->object_size, KASAN_SHADOW_SCALE_SIZE),
>                         KASAN_KMALLOC_REDZONE);
> -#ifdef CONFIG_SLAB
> -       if (cache->flags & SLAB_KASAN) {
> -               struct kasan_alloc_meta *alloc_info =
> -                       get_alloc_info(cache, object);
> -               alloc_info->state = KASAN_STATE_INIT;
> -       }
> -#endif
>  }
>
>  #ifdef CONFIG_SLAB
> @@ -520,35 +542,41 @@ void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
>         kasan_poison_shadow(object, rounded_up_size, KASAN_KMALLOC_FREE);
>  }
>
> -bool kasan_slab_free(struct kmem_cache *cache, void *object)
> +bool kasan_slab_free(struct kmem_cache *cache, void *object,
> +               unsigned long caller)
>  {
>  #ifdef CONFIG_SLAB
> +       struct kasan_alloc_meta *alloc_info;
> +       struct kasan_free_meta *free_info;
> +
>         /* RCU slabs could be legally used after free within the RCU period */
>         if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
>                 return false;
>
> -       if (likely(cache->flags & SLAB_KASAN)) {
> -               struct kasan_alloc_meta *alloc_info =
> -                       get_alloc_info(cache, object);
> -               struct kasan_free_meta *free_info =
> -                       get_free_info(cache, object);
> -
> -               switch (alloc_info->state) {
> -               case KASAN_STATE_ALLOC:
> -                       alloc_info->state = KASAN_STATE_QUARANTINE;
> -                       quarantine_put(free_info, cache);
> -                       set_track(&free_info->track, GFP_NOWAIT);
> -                       kasan_poison_slab_free(cache, object);
> -                       return true;
> +       if (unlikely(!(cache->flags & SLAB_KASAN)))
> +               return false;
> +
> +       alloc_info = get_alloc_info(cache, object);
> +       kasan_meta_lock(alloc_info);
> +       if (alloc_info->state == KASAN_STATE_ALLOC) {
> +               free_info = get_free_info(cache, object);
> +               quarantine_put(free_info, cache);
> +               set_track(&free_info->track, GFP_NOWAIT);
> +               kasan_poison_slab_free(cache, object);
> +               alloc_info->state = KASAN_STATE_QUARANTINE;
> +               kasan_meta_unlock(alloc_info);
> +               return true;
> +       }
> +       switch (alloc_info->state) {
>                 case KASAN_STATE_QUARANTINE:
>                 case KASAN_STATE_FREE:
> -                       pr_err("Double free");
> -                       dump_stack();
> -                       break;
> +                       kasan_report((unsigned long)object, 0, false, caller);
> +                       kasan_meta_unlock(alloc_info);
> +                       return true;
>                 default:

Please at least print some here (it is not meant to happen, right?).


>                         break;
> -               }
>         }
> +       kasan_meta_unlock(alloc_info);
>         return false;
>  #else
>         kasan_poison_slab_free(cache, object);
> @@ -580,10 +608,16 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
>         if (cache->flags & SLAB_KASAN) {
>                 struct kasan_alloc_meta *alloc_info =
>                         get_alloc_info(cache, object);
> +               unsigned long flags;
>
> +               local_irq_save(flags);
> +               kasan_meta_lock(alloc_info);
>                 alloc_info->state = KASAN_STATE_ALLOC;
> -               alloc_info->alloc_size = size;
> +               alloc_info->size_delta = cache->object_size - size;
>                 set_track(&alloc_info->track, flags);
> +               kasan_unmark_bad_meta(alloc_info);
> +               kasan_meta_unlock(alloc_info);
> +               local_irq_restore(flags);
>         }
>  #endif
>  }
> @@ -636,7 +670,7 @@ void kasan_kfree(void *ptr)
>                 kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
>                                 KASAN_FREE_PAGE);
>         else
> -               kasan_slab_free(page->slab_cache, ptr);
> +               kasan_slab_free(page->slab_cache, ptr, _RET_IP_);
>  }
>
>  void kasan_kfree_large(const void *ptr)
> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> index fb87923..ceaf016 100644
> --- a/mm/kasan/kasan.h
> +++ b/mm/kasan/kasan.h
> @@ -3,12 +3,14 @@
>
>  #include <linux/kasan.h>
>  #include <linux/stackdepot.h>
> +#include <linux/bit_spinlock.h>
>
>  #define KASAN_SHADOW_SCALE_SIZE (1UL << KASAN_SHADOW_SCALE_SHIFT)
>  #define KASAN_SHADOW_MASK       (KASAN_SHADOW_SCALE_SIZE - 1)
>
>  #define KASAN_FREE_PAGE         0xFF  /* page was freed */
>  #define KASAN_PAGE_REDZONE      0xFE  /* redzone for kmalloc_large allocations */
> +#define KASAN_KMALLOC_BAD_META  0xFD  /* slab object header was overwritten */
>  #define KASAN_KMALLOC_REDZONE   0xFC  /* redzone inside slub object */
>  #define KASAN_KMALLOC_FREE      0xFB  /* object was freed (kmem_cache_free/kfree) */
>  #define KASAN_GLOBAL_REDZONE    0xFA  /* redzone for global variable */
> @@ -74,9 +76,17 @@ struct kasan_track {
>  };
>
>  struct kasan_alloc_meta {
> +       union {
> +               u64 data;
> +               struct {
> +                       u32 lock : 1;           /* lock bit */


Add a comment that kasan_meta_lock expects this to be the first bit.

> +                       u32 state : 2;          /* enum kasan_state */
> +                       u32 size_delta : 23;    /* object_size - alloc size */
> +                       u32 unused1 : 6;
> +                       u32 unused2;
> +               };
> +       };
>         struct kasan_track track;
> -       u32 state : 2;  /* enum kasan_state */
> -       u32 alloc_size : 30;
>  };
>
>  struct qlist_node {
> @@ -114,6 +124,36 @@ void kasan_report(unsigned long addr, size_t size,
>  void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
>  void quarantine_reduce(void);
>  void quarantine_remove_cache(struct kmem_cache *cache);
> +
> +/* acquire per-object lock for access to KASAN metadata. */
> +static inline void kasan_meta_lock(struct kasan_alloc_meta *alloc_info)
> +{
> +       unsigned long *lockp = (unsigned long *)&alloc_info->data;
> +
> +       while (unlikely(!bit_spin_trylock(0, lockp))) {
> +               u8 *shadow = (u8 *)kasan_mem_to_shadow((void *)lockp);
> +
> +               if (READ_ONCE(*shadow) == KASAN_KMALLOC_BAD_META) {
> +                       /*
> +                        * a prior out-of-bounds access overwrote object header,
> +                        * flipping lock bit; break out to allow deallocation.
> +                        */
> +                       preempt_disable();
> +                       return;
> +               }
> +               while (test_bit(0, lockp))
> +                       cpu_relax();
> +       }
> +}
> +
> +/* release lock after a kasan_meta_lock(). */
> +static inline void kasan_meta_unlock(struct kasan_alloc_meta *alloc_info)
> +{
> +       __bit_spin_unlock(0, (unsigned long *)&alloc_info->data);
> +}
> +
> +void kasan_mark_bad_meta(struct kasan_alloc_meta *alloc_info,
> +               struct kasan_access_info *info);
>  #else
>  static inline void quarantine_put(struct kasan_free_meta *info,
>                                 struct kmem_cache *cache) { }
> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
> index 4973505..c4d45cb 100644
> --- a/mm/kasan/quarantine.c
> +++ b/mm/kasan/quarantine.c
> @@ -148,7 +148,9 @@ static void qlink_free(struct qlist_node *qlink, struct kmem_cache *cache)
>         unsigned long flags;
>
>         local_irq_save(flags);
> +       kasan_meta_lock(alloc_info);
>         alloc_info->state = KASAN_STATE_FREE;
> +       kasan_meta_unlock(alloc_info);
>         ___cache_free(cache, object, _THIS_IP_);
>         local_irq_restore(flags);
>  }
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index b3c122d..4d0d70d 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -53,6 +53,17 @@ static void print_error_description(struct kasan_access_info *info)
>         const char *bug_type = "unknown-crash";
>         u8 *shadow_addr;
>
> +#ifdef CONFIG_SLAB
> +       if (!info->access_size) {
> +               bug_type = "double-free";
> +               pr_err("BUG: KASAN: %s attempt in %pS on object at addr %p\n",
> +                               bug_type, (void *)info->ip, info->access_addr);
> +               pr_err("%s by task %s/%d\n", bug_type, current->comm,
> +                               task_pid_nr(current));
> +               info->first_bad_addr = info->access_addr;
> +               return;
> +       }
> +#endif
>         info->first_bad_addr = find_first_bad_addr(info->access_addr,
>                                                 info->access_size);
>
> @@ -75,6 +86,7 @@ static void print_error_description(struct kasan_access_info *info)
>                 break;
>         case KASAN_PAGE_REDZONE:
>         case KASAN_KMALLOC_REDZONE:
> +       case KASAN_KMALLOC_BAD_META:
>                 bug_type = "slab-out-of-bounds";
>                 break;
>         case KASAN_GLOBAL_REDZONE:
> @@ -131,7 +143,7 @@ static void print_track(struct kasan_track *track)
>  }
>
>  static void object_err(struct kmem_cache *cache, struct page *page,
> -                       void *object, char *unused_reason)
> +                       void *object, struct kasan_access_info *info)
>  {
>         struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
>         struct kasan_free_meta *free_info;
> @@ -140,20 +152,22 @@ static void object_err(struct kmem_cache *cache, struct page *page,
>         pr_err("Object at %p, in cache %s\n", object, cache->name);
>         if (!(cache->flags & SLAB_KASAN))
>                 return;
> +       if (info->access_size)
> +               kasan_meta_lock(alloc_info);
>         switch (alloc_info->state) {
>         case KASAN_STATE_INIT:
>                 pr_err("Object not allocated yet\n");
>                 break;
>         case KASAN_STATE_ALLOC:
>                 pr_err("Object allocated with size %u bytes.\n",
> -                      alloc_info->alloc_size);
> +                               (cache->object_size - alloc_info->size_delta));
>                 pr_err("Allocation:\n");
>                 print_track(&alloc_info->track);
>                 break;
>         case KASAN_STATE_FREE:
>         case KASAN_STATE_QUARANTINE:
>                 pr_err("Object freed, allocated with size %u bytes\n",
> -                      alloc_info->alloc_size);
> +                               (cache->object_size - alloc_info->size_delta));
>                 free_info = get_free_info(cache, object);
>                 pr_err("Allocation:\n");
>                 print_track(&alloc_info->track);
> @@ -161,6 +175,10 @@ static void object_err(struct kmem_cache *cache, struct page *page,
>                 print_track(&free_info->track);
>                 break;
>         }
> +       if (info->access_size) {
> +               kasan_mark_bad_meta(alloc_info, info);
> +               kasan_meta_unlock(alloc_info);
> +       }
>  }
>  #endif
>
> @@ -177,8 +195,12 @@ static void print_address_description(struct kasan_access_info *info)
>                         struct kmem_cache *cache = page->slab_cache;
>                         object = nearest_obj(cache, page,
>                                                 (void *)info->access_addr);
> +#ifdef CONFIG_SLAB
> +                       object_err(cache, page, object, info);
> +#else
>                         object_err(cache, page, object,
>                                         "kasan: bad access detected");
> +#endif
>                         return;
>                 }
>                 dump_page(page, "kasan: bad access detected");
> diff --git a/mm/slab.c b/mm/slab.c
> index cc8bbc1..f7addb3 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2651,6 +2651,7 @@ static void cache_init_objs(struct kmem_cache *cachep,
>                         cachep->ctor(objp);
>                         kasan_poison_object_data(cachep, objp);
>                 }
> +               kasan_init_object(cachep, index_to_obj(cachep, page, i));
>
>                 if (!shuffled)
>                         set_free_obj(page, i, i);
> @@ -3548,7 +3549,7 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
>                                 unsigned long caller)
>  {
>         /* Put the object into the quarantine, don't touch it for now. */
> -       if (kasan_slab_free(cachep, objp))
> +       if (kasan_slab_free(cachep, objp, _RET_IP_))
>                 return;
>
>         ___cache_free(cachep, objp, caller);
> diff --git a/mm/slub.c b/mm/slub.c
> index 825ff45..21c2b78 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1344,7 +1344,7 @@ static inline void slab_free_hook(struct kmem_cache *s, void *x)
>         if (!(s->flags & SLAB_DEBUG_OBJECTS))
>                 debug_check_no_obj_freed(x, s->object_size);
>
> -       kasan_slab_free(s, x);
> +       kasan_slab_free(s, x, _RET_IP_);
>  }
>
>  static inline void slab_free_freelist_hook(struct kmem_cache *s,
> --
> 1.7.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
