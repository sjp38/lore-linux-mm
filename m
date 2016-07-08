Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D57CA828E1
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 06:36:23 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id g18so27930217lfg.2
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 03:36:23 -0700 (PDT)
Received: from mail-lf0-x22b.google.com (mail-lf0-x22b.google.com. [2a00:1450:4010:c07::22b])
        by mx.google.com with ESMTPS id 91si1321700lfy.9.2016.07.08.03.36.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 03:36:22 -0700 (PDT)
Received: by mail-lf0-x22b.google.com with SMTP id l188so26851224lfe.2
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 03:36:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5772AAFB.1070907@virtuozzo.com>
References: <1466617421-58518-1-git-send-email-glider@google.com> <5772AAFB.1070907@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 8 Jul 2016 12:36:20 +0200
Message-ID: <CAG_fn=Xe1hd_1kZN6NxnhvfZNs4zYCYm9674UkcPVxDeTreO9A@mail.gmail.com>
Subject: Re: [PATCH v5] mm, kasan: switch SLUB to stackdepot, enable memory
 quarantine for SLUB
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jun 28, 2016 at 6:51 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
> On 06/22/2016 08:43 PM, Alexander Potapenko wrote:
>> For KASAN builds:
>>  - switch SLUB allocator to using stackdepot instead of storing the
>>    allocation/deallocation stacks in the objects;
>>  - change the freelist hook so that parts of the freelist can be put
>>    into the quarantine.
>>
>> Signed-off-by: Alexander Potapenko <glider@google.com>
>> ---
>> v5: - addressed comments by Andrey Ryabinin:
>>       - don't define SLAB_RED_ZONE, SLAB_POISON, SLAB_STORE_USER to 0
>
> check_pad_bytes() needs fixing. It should take into accout kasan metadata=
 size.
Done.
>
>>       - account for left redzone size when SLAB_RED_ZONE is used
>>     - incidentally moved the implementations of nearest_obj() to mm/sl[a=
u]b.c
>> v4: - addressed comments by Andrey Ryabinin:
>>       - don't set slub_debug by default for everyone;
>>       - introduce the ___cache_free() helper function.
>> v3: - addressed comments by Andrey Ryabinin:
>>       - replaced KMALLOC_MAX_CACHE_SIZE with KMALLOC_MAX_SIZE in
>>         kasan_cache_create();
>>       - for caches with SLAB_KASAN flag set, their alloc_meta_offset and
>>         free_meta_offset are always valid.
>> v2: - incorporated kbuild fixes by Andrew Morton
>> ---
>>  include/linux/slab_def.h | 11 -------
>>  include/linux/slub_def.h | 15 +++-------
>>  lib/Kconfig.kasan        |  4 +--
>>  mm/kasan/Makefile        |  3 +-
>>  mm/kasan/kasan.c         | 61 ++++++++++++++++++++------------------
>>  mm/kasan/kasan.h         |  2 +-
>>  mm/kasan/report.c        |  8 ++---
>>  mm/slab.c                | 11 +++++++
>>  mm/slab.h                |  9 ++++++
>>  mm/slub.c                | 76 +++++++++++++++++++++++++++++++++++++++--=
-------
>>  10 files changed, 126 insertions(+), 74 deletions(-)
>>
>> diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
>> index 8694f7a..a20e11c 100644
>> --- a/include/linux/slab_def.h
>> +++ b/include/linux/slab_def.h
>> @@ -87,15 +87,4 @@ struct kmem_cache {
>>       struct kmem_cache_node *node[MAX_NUMNODES];
>>  };
>>
>> -static inline void *nearest_obj(struct kmem_cache *cache, struct page *=
page,
>> -                             void *x) {
>> -     void *object =3D x - (x - page->s_mem) % cache->size;
>> -     void *last_object =3D page->s_mem + (cache->num - 1) * cache->size=
;
>> -
>> -     if (unlikely(object > last_object))
>> -             return last_object;
>> -     else
>> -             return object;
>> -}
>> -
>>  #endif       /* _LINUX_SLAB_DEF_H */
>> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
>> index d1faa01..da80e7f 100644
>> --- a/include/linux/slub_def.h
>> +++ b/include/linux/slub_def.h
>> @@ -99,6 +99,10 @@ struct kmem_cache {
>>        */
>>       int remote_node_defrag_ratio;
>>  #endif
>> +#ifdef CONFIG_KASAN
>> +     struct kasan_cache kasan_info;
>> +#endif
>> +
>>       struct kmem_cache_node *node[MAX_NUMNODES];
>>  };
>>
>> @@ -114,15 +118,4 @@ static inline void sysfs_slab_remove(struct kmem_ca=
che *s)
>>  void object_err(struct kmem_cache *s, struct page *page,
>>               u8 *object, char *reason);
>>
>> -static inline void *nearest_obj(struct kmem_cache *cache, struct page *=
page,
>> -                             void *x) {
>> -     void *object =3D x - (x - page_address(page)) % cache->size;
>> -     void *last_object =3D page_address(page) +
>> -             (page->objects - 1) * cache->size;
>> -     if (unlikely(object > last_object))
>> -             return last_object;
>> -     else
>> -             return object;
>> -}
>> -
>>  #endif /* _LINUX_SLUB_DEF_H */
>> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
>> index 67d8c68..bd38aab 100644
>> --- a/lib/Kconfig.kasan
>> +++ b/lib/Kconfig.kasan
>> @@ -5,9 +5,9 @@ if HAVE_ARCH_KASAN
>>
>>  config KASAN
>>       bool "KASan: runtime memory debugger"
>> -     depends on SLUB_DEBUG || (SLAB && !DEBUG_SLAB)
>> +     depends on SLUB || (SLAB && !DEBUG_SLAB)
>>       select CONSTRUCTORS
>> -     select STACKDEPOT if SLAB
>> +     select STACKDEPOT
>>       help
>>         Enables kernel address sanitizer - runtime memory debugger,
>>         designed to find out-of-bounds accesses and use-after-free bugs.
>> diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
>> index 1548749..2976a9e 100644
>> --- a/mm/kasan/Makefile
>> +++ b/mm/kasan/Makefile
>> @@ -7,5 +7,4 @@ CFLAGS_REMOVE_kasan.o =3D -pg
>>  # see: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=3D63533
>>  CFLAGS_kasan.o :=3D $(call cc-option, -fno-conserve-stack -fno-stack-pr=
otector)
>>
>> -obj-y :=3D kasan.o report.o kasan_init.o
>> -obj-$(CONFIG_SLAB) +=3D quarantine.o
>> +obj-y :=3D kasan.o report.o kasan_init.o quarantine.o
>> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
>> index 28439ac..3883e22 100644
>> --- a/mm/kasan/kasan.c
>> +++ b/mm/kasan/kasan.c
>> @@ -351,7 +351,6 @@ void kasan_free_pages(struct page *page, unsigned in=
t order)
>>                               KASAN_FREE_PAGE);
>>  }
>>
>> -#ifdef CONFIG_SLAB
>>  /*
>>   * Adaptive redzone policy taken from the userspace AddressSanitizer ru=
ntime.
>>   * For larger allocations larger redzones are used.
>> @@ -373,16 +372,12 @@ void kasan_cache_create(struct kmem_cache *cache, =
size_t *size,
>>                       unsigned long *flags)
>>  {
>>       int redzone_adjust;
>> -     /* Make sure the adjusted size is still less than
>> -      * KMALLOC_MAX_CACHE_SIZE.
>> -      * TODO: this check is only useful for SLAB, but not SLUB. We'll n=
eed
>> -      * to skip it for SLUB when it starts using kasan_cache_create().
>> -      */
>> -     if (*size > KMALLOC_MAX_CACHE_SIZE -
>> -         sizeof(struct kasan_alloc_meta) -
>> -         sizeof(struct kasan_free_meta))
>> -             return;
>> +#ifdef CONFIG_SLAB
>> +     int orig_size =3D *size;
>> +#endif
>> +
>>       *flags |=3D SLAB_KASAN;
>> +
>>       /* Add alloc meta. */
>>       cache->kasan_info.alloc_meta_offset =3D *size;
>>       *size +=3D sizeof(struct kasan_alloc_meta);
>> @@ -392,17 +387,35 @@ void kasan_cache_create(struct kmem_cache *cache, =
size_t *size,
>>           cache->object_size < sizeof(struct kasan_free_meta)) {
>>               cache->kasan_info.free_meta_offset =3D *size;
>>               *size +=3D sizeof(struct kasan_free_meta);
>> +     } else {
>> +             cache->kasan_info.free_meta_offset =3D 0;
>
> Why is that required now?
Because we want to store the free metadata in the object when it's possible=
.
>
>>       }
>>       redzone_adjust =3D optimal_redzone(cache->object_size) -
>>               (*size - cache->object_size);
>> +
>>       if (redzone_adjust > 0)
>>               *size +=3D redzone_adjust;
>> -     *size =3D min(KMALLOC_MAX_CACHE_SIZE,
>> +
>> +#ifdef CONFIG_SLAB
>> +     *size =3D min(KMALLOC_MAX_SIZE,
>>                   max(*size,
>>                       cache->object_size +
>>                       optimal_redzone(cache->object_size)));
>> -}
>> +     /*
>> +      * If the metadata doesn't fit, disable KASAN at all.
>> +      */
>> +     if (*size <=3D cache->kasan_info.alloc_meta_offset ||
>> +                     *size <=3D cache->kasan_info.free_meta_offset) {
>> +             *flags &=3D ~SLAB_KASAN;
>
> Why we change that flag back and forth instead of setting it once?
Agreed. I've fixed this.
>> +             *size =3D orig_size;
>> +     }
>> +#else
>> +     *size =3D max(*size,
>> +                     cache->object_size +
>> +                     optimal_redzone(cache->object_size));
>> +
>>  #endif
>> +}
>>
>>  void kasan_cache_shrink(struct kmem_cache *cache)
>>  {
>> @@ -431,16 +444,13 @@ void kasan_poison_object_data(struct kmem_cache *c=
ache, void *object)
>>       kasan_poison_shadow(object,
>>                       round_up(cache->object_size, KASAN_SHADOW_SCALE_SI=
ZE),
>>                       KASAN_KMALLOC_REDZONE);
>> -#ifdef CONFIG_SLAB
>>       if (cache->flags & SLAB_KASAN) {
>>               struct kasan_alloc_meta *alloc_info =3D
>>                       get_alloc_info(cache, object);
>>               alloc_info->state =3D KASAN_STATE_INIT;
>>       }
>> -#endif
>>  }
>>
>> -#ifdef CONFIG_SLAB
>>  static inline int in_irqentry_text(unsigned long ptr)
>>  {
>>       return (ptr >=3D (unsigned long)&__irqentry_text_start &&
>> @@ -501,7 +511,6 @@ struct kasan_free_meta *get_free_info(struct kmem_ca=
che *cache,
>>       BUILD_BUG_ON(sizeof(struct kasan_free_meta) > 32);
>>       return (void *)object + cache->kasan_info.free_meta_offset;
>>  }
>> -#endif
>>
>>  void kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t fla=
gs)
>>  {
>> @@ -522,16 +531,16 @@ void kasan_poison_slab_free(struct kmem_cache *cac=
he, void *object)
>>
>>  bool kasan_slab_free(struct kmem_cache *cache, void *object)
>>  {
>> -#ifdef CONFIG_SLAB
>>       /* RCU slabs could be legally used after free within the RCU perio=
d */
>>       if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
>>               return false;
>>
>>       if (likely(cache->flags & SLAB_KASAN)) {
>> -             struct kasan_alloc_meta *alloc_info =3D
>> -                     get_alloc_info(cache, object);
>> -             struct kasan_free_meta *free_info =3D
>> -                     get_free_info(cache, object);
>> +             struct kasan_alloc_meta *alloc_info;
>> +             struct kasan_free_meta *free_info;
>> +
>> +             alloc_info =3D get_alloc_info(cache, object);
>> +             free_info =3D get_free_info(cache, object);
>>
>>               switch (alloc_info->state) {
>>               case KASAN_STATE_ALLOC:
>> @@ -550,10 +559,6 @@ bool kasan_slab_free(struct kmem_cache *cache, void=
 *object)
>>               }
>>       }
>>       return false;
>> -#else
>> -     kasan_poison_slab_free(cache, object);
>> -     return false;
>> -#endif
>>  }
>>
>>  void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t=
 size,
>> @@ -568,6 +573,9 @@ void kasan_kmalloc(struct kmem_cache *cache, const v=
oid *object, size_t size,
>>       if (unlikely(object =3D=3D NULL))
>>               return;
>>
>> +     if (!(cache->flags & SLAB_KASAN))
>> +             return;
>> +
>
> This hunk is superfluous and wrong.
Can you please elaborate?
Do you mean we don't need to check for SLAB_KASAN here, or that we
don't need SLAB_KASAN at all?
>
>>       redzone_start =3D round_up((unsigned long)(object + size),
>>                               KASAN_SHADOW_SCALE_SIZE);
>>       redzone_end =3D round_up((unsigned long)object + cache->object_siz=
e,
>> @@ -576,16 +584,13 @@ void kasan_kmalloc(struct kmem_cache *cache, const=
 void *object, size_t size,
>>       kasan_unpoison_shadow(object, size);
>>       kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_s=
tart,
>>               KASAN_KMALLOC_REDZONE);
>> -#ifdef CONFIG_SLAB
>>       if (cache->flags & SLAB_KASAN) {
>>               struct kasan_alloc_meta *alloc_info =3D
>>                       get_alloc_info(cache, object);
>> -
>
> Keep the space please.
Done.
>
>>               alloc_info->state =3D KASAN_STATE_ALLOC;
>>               alloc_info->alloc_size =3D size;
>>               set_track(&alloc_info->track, flags);
>>       }
>> -#endif
>>  }
>>  EXPORT_SYMBOL(kasan_kmalloc);
>>
>> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
>> index fb87923..8c75953 100644
>> --- a/mm/kasan/kasan.h
>> +++ b/mm/kasan/kasan.h
>> @@ -110,7 +110,7 @@ static inline bool kasan_report_enabled(void)
>>  void kasan_report(unsigned long addr, size_t size,
>>               bool is_write, unsigned long ip);
>>
>> -#ifdef CONFIG_SLAB
>> +#if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
>>  void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *ca=
che);
>>  void quarantine_reduce(void);
>>  void quarantine_remove_cache(struct kmem_cache *cache);
>> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
>> index b3c122d..861b977 100644
>> --- a/mm/kasan/report.c
>> +++ b/mm/kasan/report.c
>> @@ -116,7 +116,6 @@ static inline bool init_task_stack_addr(const void *=
addr)
>>                       sizeof(init_thread_union.stack));
>>  }
>>
>> -#ifdef CONFIG_SLAB
>>  static void print_track(struct kasan_track *track)
>>  {
>>       pr_err("PID =3D %u\n", track->pid);
>> @@ -130,8 +129,8 @@ static void print_track(struct kasan_track *track)
>>       }
>>  }
>>
>> -static void object_err(struct kmem_cache *cache, struct page *page,
>> -                     void *object, char *unused_reason)
>> +static void kasan_object_err(struct kmem_cache *cache, struct page *pag=
e,
>> +                             void *object, char *unused_reason)
>>  {
>>       struct kasan_alloc_meta *alloc_info =3D get_alloc_info(cache, obje=
ct);
>>       struct kasan_free_meta *free_info;
>> @@ -162,7 +161,6 @@ static void object_err(struct kmem_cache *cache, str=
uct page *page,
>>               break;
>>       }
>>  }
>> -#endif
>>
>>  static void print_address_description(struct kasan_access_info *info)
>>  {
>> @@ -177,7 +175,7 @@ static void print_address_description(struct kasan_a=
ccess_info *info)
>>                       struct kmem_cache *cache =3D page->slab_cache;
>>                       object =3D nearest_obj(cache, page,
>>                                               (void *)info->access_addr)=
;
>> -                     object_err(cache, page, object,
>> +                     kasan_object_err(cache, page, object,
>>                                       "kasan: bad access detected");
>>                       return;
>>               }
>> diff --git a/mm/slab.c b/mm/slab.c
>> index cc8bbc1..e944171 100644
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -4506,3 +4506,14 @@ size_t ksize(const void *objp)
>>       return size;
>>  }
>>  EXPORT_SYMBOL(ksize);
>> +
>> +void *nearest_obj(struct kmem_cache *cache, struct page *page, void *x)
>> +{
>> +     void *object =3D x - (x - page->s_mem) % cache->size;
>> +     void *last_object =3D page->s_mem + (cache->num - 1) * cache->size=
;
>> +
>> +     if (unlikely(object > last_object))
>> +             return last_object;
>> +     else
>> +             return object;
>> +}
>
> This should be in header. Don't bloat CONFIG_KASAN=3Dn kernels.
Ok, I've moved it back.
>> diff --git a/mm/slab.h b/mm/slab.h
>> index dedb1a9..52edd1e 100644
>> --- a/mm/slab.h
>> +++ b/mm/slab.h
>> @@ -366,6 +366,8 @@ static inline size_t slab_ksize(const struct kmem_ca=
che *s)
>>       if (s->flags & (SLAB_RED_ZONE | SLAB_POISON))
>>               return s->object_size;
>>  # endif
>> +     if (s->flags & SLAB_KASAN)
>> +             return s->object_size;
>>       /*
>>        * If we have the need to store the freelist pointer
>>        * back there or track user information then we can
>> @@ -462,6 +464,13 @@ void *slab_next(struct seq_file *m, void *p, loff_t=
 *pos);
>>  void slab_stop(struct seq_file *m, void *p);
>>  int memcg_slab_show(struct seq_file *m, void *p);
>>
>> +void *nearest_obj(struct kmem_cache *cache, struct page *page, void *x)=
;
>> +
>>  void ___cache_free(struct kmem_cache *cache, void *x, unsigned long add=
r);
>> +#if defined(CONFIG_SLUB)
>> +void do_slab_free(struct kmem_cache *s,
>> +             struct page *page, void *head, void *tail,
>> +             int cnt, unsigned long addr);
>> +#endif
>>
>>  #endif /* MM_SLAB_H */
>> diff --git a/mm/slub.c b/mm/slub.c
>> index 825ff45..3ef06e3 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -191,7 +191,11 @@ static inline bool kmem_cache_has_cpu_partial(struc=
t kmem_cache *s)
>>  #define MAX_OBJS_PER_PAGE    32767 /* since page.objects is u15 */
>>
>>  /* Internal SLUB flags */
>> +#ifndef CONFIG_KASAN
>>  #define __OBJECT_POISON              0x80000000UL /* Poison object */
>> +#else
>> +#define __OBJECT_POISON              0x00000000UL /* Disable object poi=
soning */
>
> Again, why? It should just work.
Yeah, it appears to work now. Removed these bits.
>> +#endif
>>  #define __CMPXCHG_DOUBLE     0x40000000UL /* Use cmpxchg_double */
>>
>>  #ifdef CONFIG_SMP
>> @@ -454,8 +458,6 @@ static inline void *restore_red_left(struct kmem_cac=
he *s, void *p)
>>   */
>>  #if defined(CONFIG_SLUB_DEBUG_ON)
>>  static int slub_debug =3D DEBUG_DEFAULT_FLAGS;
>> -#elif defined(CONFIG_KASAN)
>> -static int slub_debug =3D SLAB_STORE_USER;
>>  #else
>>  static int slub_debug;
>>  #endif
>> @@ -1322,7 +1324,7 @@ static inline void kfree_hook(const void *x)
>>       kasan_kfree_large(x);
>>  }
>>
>> -static inline void slab_free_hook(struct kmem_cache *s, void *x)
>> +static inline bool slab_free_hook(struct kmem_cache *s, void *x)
>>  {
>>       kmemleak_free_recursive(x, s->flags);
>>
>> @@ -1344,11 +1346,11 @@ static inline void slab_free_hook(struct kmem_ca=
che *s, void *x)
>>       if (!(s->flags & SLAB_DEBUG_OBJECTS))
>>               debug_check_no_obj_freed(x, s->object_size);
>>
>> -     kasan_slab_free(s, x);
>> +     return kasan_slab_free(s, x);
>>  }
>>
>>  static inline void slab_free_freelist_hook(struct kmem_cache *s,
>> -                                        void *head, void *tail)
>> +                                        void **head, void **tail, int *=
cnt)
>>  {
>>  /*
>>   * Compiler cannot detect this function can be removed if slab_free_hoo=
k()
>> @@ -1360,13 +1362,27 @@ static inline void slab_free_freelist_hook(struc=
t kmem_cache *s,
>>       defined(CONFIG_DEBUG_OBJECTS_FREE) ||   \
>>       defined(CONFIG_KASAN)
>>
>> -     void *object =3D head;
>> -     void *tail_obj =3D tail ? : head;
>> +     void *object =3D *head, *prev =3D NULL, *next =3D NULL;
>> +     void *tail_obj =3D *tail ? : *head;
>> +     bool skip =3D false;
>>
>>       do {
>> -             slab_free_hook(s, object);
>> -     } while ((object !=3D tail_obj) &&
>> -              (object =3D get_freepointer(s, object)));
>> +             skip =3D slab_free_hook(s, object);
>> +             next =3D (object !=3D tail_obj) ?
>> +                     get_freepointer(s, object) : NULL;
>> +             if (skip) {
>> +                     if (!prev)
>> +                             *head =3D next;
>> +                     else
>> +                             set_freepointer(s, prev, next);
>> +                     if (object =3D=3D tail_obj)
>> +                             *tail =3D prev;
>> +                     (*cnt)--;
>> +             } else {
>> +                     prev =3D object;
>> +             }
>> +             object =3D next;
>> +     } while (next);
>>  #endif
>>  }
>>
>> @@ -2772,12 +2788,22 @@ static __always_inline void slab_free(struct kme=
m_cache *s, struct page *page,
>>                                     void *head, void *tail, int cnt,
>>                                     unsigned long addr)
>>  {
>> +     void *free_head =3D head, *free_tail =3D tail;
>> +
>> +     slab_free_freelist_hook(s, &free_head, &free_tail, &cnt);
>> +     /* slab_free_freelist_hook() could have emptied the freelist. */
>> +     if (cnt =3D=3D 0)
>> +             return;
>
> I suppose that we can do something like following, instead of that mess i=
n slab_free_freelist_hook() above
>
>         slab_free_freelist_hook(s, &free_head, &free_tail);
>         if (s->flags & SLAB_KASAN && s->flags & SLAB_DESTROY_BY_RCU)
Did you mean "&& !(s->flags & SLAB_DESTROY_BY_RCU)" ?
>                 return;
Yes, my code is overly complicated given that kasan_slab_free() should
actually return the same value for every element of the list.
(do you think it makes sense to check that?)
I can safely remove those freelist manipulations.
>
>
>> +     do_slab_free(s, page, free_head, free_tail, cnt, addr);
>> +}
>> +
>> +__always_inline void do_slab_free(struct kmem_cache *s,
>
> static
Done.
>> +                             struct page *page, void *head, void *tail,
>> +                             int cnt, unsigned long addr)
>> +{
>>       void *tail_obj =3D tail ? : head;
>>       struct kmem_cache_cpu *c;
>>       unsigned long tid;
>> -
>> -     slab_free_freelist_hook(s, head, tail);
>> -
>>  redo:
>>       /*
>>        * Determine the currently cpus per cpu slab.
>> @@ -2811,6 +2837,12 @@ redo:
>>
>>  }
>>
>> +/* Helper function to be used from qlink_free() in mm/kasan/quarantine.=
c */
>
> We have grep to locate all call sites. Unlike comments like this, grep re=
sults always uptodate.
Removed the comment.
>> +void ___cache_free(struct kmem_cache *cache, void *x, unsigned long add=
r)
>> +{
>> +     do_slab_free(cache, virt_to_head_page(x), x, NULL, 1, addr);
>> +}
>> +
>>  void kmem_cache_free(struct kmem_cache *s, void *x)
>>  {
>>       s =3D cache_from_obj(s, x);
>> @@ -3252,7 +3284,7 @@ static void set_min_partial(struct kmem_cache *s, =
unsigned long min)
>>  static int calculate_sizes(struct kmem_cache *s, int forced_order)
>>  {
>>       unsigned long flags =3D s->flags;
>> -     unsigned long size =3D s->object_size;
>> +     size_t size =3D s->object_size;
>>       int order;
>>
>>       /*
>> @@ -3311,7 +3343,10 @@ static int calculate_sizes(struct kmem_cache *s, =
int forced_order)
>>                * the object.
>>                */
>>               size +=3D 2 * sizeof(struct track);
>> +#endif
>>
>> +     kasan_cache_create(s, &size, &s->flags);
>> +#ifdef CONFIG_SLUB_DEBUG
>>       if (flags & SLAB_RED_ZONE) {
>>               /*
>>                * Add some empty padding so that we can catch
>> @@ -5585,3 +5620,16 @@ ssize_t slabinfo_write(struct file *file, const c=
har __user *buffer,
>>       return -EIO;
>>  }
>>  #endif /* CONFIG_SLABINFO */
>> +
>> +void *nearest_obj(struct kmem_cache *cache, struct page *page,
>> +                             void *x) {
>> +     void *object =3D x - (x - page_address(page)) % cache->size;
>> +     void *last_object =3D page_address(page) +
>> +             (page->objects - 1) * cache->size;
>> +     void *result =3D (unlikely(object > last_object)) ? last_object : =
object;
>> +
>> +     if (cache->flags & SLAB_RED_ZONE)
>> +             return (void *)((char *)result + cache->red_left_pad);
>
> red_left_pad is zero when SLAB_RED_ZONE is unset, so if/else is not neede=
d here.
Yet every use of red_left_pad in the codebase is preceded with a
SLAB_RED_ZONE check.
I find this logical.

> And it can be moved back to header now.
Done.

> Also, you don't need (void *) cast.
Done.
>
>> +     else
>> +             return result;
>> +}
>>
>
>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
