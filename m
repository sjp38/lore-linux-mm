Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id D28686B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 06:18:22 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id m64so32160184lfd.1
        for <linux-mm@kvack.org>; Wed, 11 May 2016 03:18:22 -0700 (PDT)
Received: from mail-lf0-x22f.google.com (mail-lf0-x22f.google.com. [2a00:1450:4010:c07::22f])
        by mx.google.com with ESMTPS id wj4si5137971lbb.194.2016.05.11.03.18.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 03:18:21 -0700 (PDT)
Received: by mail-lf0-x22f.google.com with SMTP id u64so44290357lff.3
        for <linux-mm@kvack.org>; Wed, 11 May 2016 03:18:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1462887534-30428-1-git-send-email-aryabinin@virtuozzo.com>
References: <1462887534-30428-1-git-send-email-aryabinin@virtuozzo.com>
Date: Wed, 11 May 2016 12:18:20 +0200
Message-ID: <CAG_fn=UdD=gvFXOSMh3b+PzHerh6HD0ydrDYTEeXf1gPgMuBZw@mail.gmail.com>
Subject: Re: [PATCH] mm-kasan-initial-memory-quarantine-implementation-v8-fix
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>

On Tue, May 10, 2016 at 3:38 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>  * Fix comment styles,
 yDid you remove the comments from include/linux/kasan.h because they
were put inconsistently, or was there any other reason?
>  * Get rid of some ifdefs
Thanks!
>  * Revert needless functions renames in quarantine patch
I believe right now the names are somewhat obscure. I agree however
the change should be done in a separate patch.
>  * Remove needless local_irq_save()/restore() in per_cpu_remove_cache()
Ack
>  * Add new 'struct qlist_node' instead of 'void **' types. This makes
>    code a bit more redable.
Nice, thank you!

How do I incorporate your changes? Is it ok if I merge it with the
next version of my patch and add a "Signed-off-by: Andrey Ryabinin
<aryabinin@virtuozzo.com>" line to the description?

>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> ---
>  include/linux/kasan.h |  17 +++-----
>  mm/kasan/Makefile     |   5 +--
>  mm/kasan/kasan.c      |  14 ++-----
>  mm/kasan/kasan.h      |  12 +++++-
>  mm/kasan/quarantine.c | 110 +++++++++++++++++++++++++-------------------=
------
>  mm/mempool.c          |   5 +--
>  mm/page_alloc.c       |   2 +-
>  mm/slab.c             |   7 +---
>  mm/slub.c             |   4 +-
>  9 files changed, 84 insertions(+), 92 deletions(-)
>
> diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> index 645c280..611927f 100644
> --- a/include/linux/kasan.h
> +++ b/include/linux/kasan.h
> @@ -46,7 +46,7 @@ void kasan_unpoison_shadow(const void *address, size_t =
size);
>  void kasan_unpoison_task_stack(struct task_struct *task);
>
>  void kasan_alloc_pages(struct page *page, unsigned int order);
> -void kasan_poison_free_pages(struct page *page, unsigned int order);
> +void kasan_free_pages(struct page *page, unsigned int order);
>
>  void kasan_cache_create(struct kmem_cache *cache, size_t *size,
>                         unsigned long *flags);
> @@ -58,15 +58,13 @@ void kasan_unpoison_object_data(struct kmem_cache *ca=
che, void *object);
>  void kasan_poison_object_data(struct kmem_cache *cache, void *object);
>
>  void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags);
> -void kasan_poison_kfree_large(const void *ptr);
> -void kasan_poison_kfree(void *ptr);
> +void kasan_kfree_large(const void *ptr);
> +void kasan_kfree(void *ptr);
>  void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size=
,
>                   gfp_t flags);
>  void kasan_krealloc(const void *object, size_t new_size, gfp_t flags);
>
>  void kasan_slab_alloc(struct kmem_cache *s, void *object, gfp_t flags);
> -/* kasan_slab_free() returns true if the object has been put into quaran=
tine.
> - */
>  bool kasan_slab_free(struct kmem_cache *s, void *object);
>  void kasan_poison_slab_free(struct kmem_cache *s, void *object);
>
> @@ -88,8 +86,7 @@ static inline void kasan_enable_current(void) {}
>  static inline void kasan_disable_current(void) {}
>
>  static inline void kasan_alloc_pages(struct page *page, unsigned int ord=
er) {}
> -static inline void kasan_poison_free_pages(struct page *page,
> -                                               unsigned int order) {}
> +static inline void kasan_free_pages(struct page *page, unsigned int orde=
r) {}
>
>  static inline void kasan_cache_create(struct kmem_cache *cache,
>                                       size_t *size,
> @@ -104,8 +101,8 @@ static inline void kasan_poison_object_data(struct km=
em_cache *cache,
>                                         void *object) {}
>
>  static inline void kasan_kmalloc_large(void *ptr, size_t size, gfp_t fla=
gs) {}
> -static inline void kasan_poison_kfree_large(const void *ptr) {}
> -static inline void kasan_poison_kfree(void *ptr) {}
> +static inline void kasan_kfree_large(const void *ptr) {}
> +static inline void kasan_kfree(void *ptr) {}
>  static inline void kasan_kmalloc(struct kmem_cache *s, const void *objec=
t,
>                                 size_t size, gfp_t flags) {}
>  static inline void kasan_krealloc(const void *object, size_t new_size,
> @@ -113,8 +110,6 @@ static inline void kasan_krealloc(const void *object,=
 size_t new_size,
>
>  static inline void kasan_slab_alloc(struct kmem_cache *s, void *object,
>                                    gfp_t flags) {}
> -/* kasan_slab_free() returns true if the object has been put into quaran=
tine.
> - */
>  static inline bool kasan_slab_free(struct kmem_cache *s, void *object)
>  {
>         return false;
> diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
> index 63b54aa..1548749 100644
> --- a/mm/kasan/Makefile
> +++ b/mm/kasan/Makefile
> @@ -8,7 +8,4 @@ CFLAGS_REMOVE_kasan.o =3D -pg
>  CFLAGS_kasan.o :=3D $(call cc-option, -fno-conserve-stack -fno-stack-pro=
tector)
>
>  obj-y :=3D kasan.o report.o kasan_init.o
> -
> -ifdef CONFIG_SLAB
> -       obj-y   +=3D quarantine.o
> -endif
> +obj-$(CONFIG_SLAB) +=3D quarantine.o
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index ef2e87b..8df666b 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -327,7 +327,7 @@ void kasan_alloc_pages(struct page *page, unsigned in=
t order)
>                 kasan_unpoison_shadow(page_address(page), PAGE_SIZE << or=
der);
>  }
>
> -void kasan_poison_free_pages(struct page *page, unsigned int order)
> +void kasan_free_pages(struct page *page, unsigned int order)
>  {
>         if (likely(!PageHighMem(page)))
>                 kasan_poison_shadow(page_address(page),
> @@ -390,16 +390,12 @@ void kasan_cache_create(struct kmem_cache *cache, s=
ize_t *size,
>
>  void kasan_cache_shrink(struct kmem_cache *cache)
>  {
> -#ifdef CONFIG_SLAB
>         quarantine_remove_cache(cache);
> -#endif
>  }
>
>  void kasan_cache_destroy(struct kmem_cache *cache)
>  {
> -#ifdef CONFIG_SLAB
>         quarantine_remove_cache(cache);
> -#endif
>  }
>
>  void kasan_poison_slab(struct page *page)
> @@ -550,10 +546,8 @@ void kasan_kmalloc(struct kmem_cache *cache, const v=
oid *object, size_t size,
>         unsigned long redzone_start;
>         unsigned long redzone_end;
>
> -#ifdef CONFIG_SLAB
>         if (flags & __GFP_RECLAIM)
>                 quarantine_reduce();
> -#endif
>
>         if (unlikely(object =3D=3D NULL))
>                 return;
> @@ -585,10 +579,8 @@ void kasan_kmalloc_large(const void *ptr, size_t siz=
e, gfp_t flags)
>         unsigned long redzone_start;
>         unsigned long redzone_end;
>
> -#ifdef CONFIG_SLAB
>         if (flags & __GFP_RECLAIM)
>                 quarantine_reduce();
> -#endif
>
>         if (unlikely(ptr =3D=3D NULL))
>                 return;
> @@ -618,7 +610,7 @@ void kasan_krealloc(const void *object, size_t size, =
gfp_t flags)
>                 kasan_kmalloc(page->slab_cache, object, size, flags);
>  }
>
> -void kasan_poison_kfree(void *ptr)
> +void kasan_kfree(void *ptr)
>  {
>         struct page *page;
>
> @@ -631,7 +623,7 @@ void kasan_poison_kfree(void *ptr)
>                 kasan_slab_free(page->slab_cache, ptr);
>  }
>
> -void kasan_poison_kfree_large(const void *ptr)
> +void kasan_kfree_large(const void *ptr)
>  {
>         struct page *page =3D virt_to_page(ptr);
>
> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> index 7da78a6..7f7ac51 100644
> --- a/mm/kasan/kasan.h
> +++ b/mm/kasan/kasan.h
> @@ -80,11 +80,14 @@ struct kasan_alloc_meta {
>         u32 reserved;
>  };
>
> +struct qlist_node {
> +       struct qlist_node *next;
> +};
>  struct kasan_free_meta {
>         /* This field is used while the object is in the quarantine.
>          * Otherwise it might be used for the allocator freelist.
>          */
> -       void **quarantine_link;
> +       struct qlist_node quarantine_link;
>         struct kasan_track track;
>  };
>
> @@ -108,8 +111,15 @@ static inline bool kasan_report_enabled(void)
>  void kasan_report(unsigned long addr, size_t size,
>                 bool is_write, unsigned long ip);
>
> +#ifdef CONFIG_SLAB
>  void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cac=
he);
>  void quarantine_reduce(void);
>  void quarantine_remove_cache(struct kmem_cache *cache);
> +#else
> +static inline void quarantine_put(struct kasan_free_meta *info,
> +                               struct kmem_cache *cache) { }
> +static inline void quarantine_reduce(void) { }
> +static inline void quarantine_remove_cache(struct kmem_cache *cache) { }
> +#endif
>
>  #endif
> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
> index 40159a6..1e687d7 100644
> --- a/mm/kasan/quarantine.c
> +++ b/mm/kasan/quarantine.c
> @@ -33,40 +33,42 @@
>
>  /* Data structure and operations for quarantine queues. */
>
> -/* Each queue is a signle-linked list, which also stores the total size =
of
> +/*
> + * Each queue is a signle-linked list, which also stores the total size =
of
>   * objects inside of it.
>   */
> -struct qlist {
> -       void **head;
> -       void **tail;
> +struct qlist_head {
> +       struct qlist_node *head;
> +       struct qlist_node *tail;
>         size_t bytes;
>  };
>
>  #define QLIST_INIT { NULL, NULL, 0 }
>
> -static bool qlist_empty(struct qlist *q)
> +static bool qlist_empty(struct qlist_head *q)
>  {
>         return !q->head;
>  }
>
> -static void qlist_init(struct qlist *q)
> +static void qlist_init(struct qlist_head *q)
>  {
>         q->head =3D q->tail =3D NULL;
>         q->bytes =3D 0;
>  }
>
> -static void qlist_put(struct qlist *q, void **qlink, size_t size)
> +static void qlist_put(struct qlist_head *q, struct qlist_node *qlink,
> +               size_t size)
>  {
>         if (unlikely(qlist_empty(q)))
>                 q->head =3D qlink;
>         else
> -               *q->tail =3D qlink;
> +               q->tail->next =3D qlink;
>         q->tail =3D qlink;
> -       *qlink =3D NULL;
> +       qlink->next =3D NULL;
>         q->bytes +=3D size;
>  }
>
> -static void qlist_move_all(struct qlist *from, struct qlist *to)
> +static void qlist_move_all(struct qlist_head *from, struct qlist_head *t=
o)
>  {
>         if (unlikely(qlist_empty(from)))
>                 return;
> @@ -77,15 +79,15 @@ static void qlist_move_all(struct qlist *from, struct=
 qlist *to)
>                 return;
>         }
>
> -       *to->tail =3D from->head;
> +       to->tail->next =3D from->head;
>         to->tail =3D from->tail;
>         to->bytes +=3D from->bytes;
>
>         qlist_init(from);
>  }
>
> -static void qlist_move(struct qlist *from, void **last, struct qlist *to=
,
> -                         size_t size)
> +static void qlist_move(struct qlist_head *from, struct qlist_node *last,
> +               struct qlist_head *to, size_t size)
>  {
>         if (unlikely(last =3D=3D from->tail)) {
>                 qlist_move_all(from, to);
> @@ -94,53 +96,56 @@ static void qlist_move(struct qlist *from, void **las=
t, struct qlist *to,
>         if (qlist_empty(to))
>                 to->head =3D from->head;
>         else
> -               *to->tail =3D from->head;
> +               to->tail->next =3D from->head;
>         to->tail =3D last;
> -       from->head =3D *last;
> -       *last =3D NULL;
> +       from->head =3D last->next;
> +       last->next =3D NULL;
>         from->bytes -=3D size;
>         to->bytes +=3D size;
>  }
>
>
> -/* The object quarantine consists of per-cpu queues and a global queue,
> +/*
> + * The object quarantine consists of per-cpu queues and a global queue,
>   * guarded by quarantine_lock.
>   */
> -static DEFINE_PER_CPU(struct qlist, cpu_quarantine);
> +static DEFINE_PER_CPU(struct qlist_head, cpu_quarantine);
>
> -static struct qlist global_quarantine;
> +static struct qlist_head global_quarantine;
>  static DEFINE_SPINLOCK(quarantine_lock);
>
>  /* Maximum size of the global queue. */
>  static unsigned long quarantine_size;
>
> -/* The fraction of physical memory the quarantine is allowed to occupy.
> +/*
> + * The fraction of physical memory the quarantine is allowed to occupy.
>   * Quarantine doesn't support memory shrinker with SLAB allocator, so we=
 keep
>   * the ratio low to avoid OOM.
>   */
>  #define QUARANTINE_FRACTION 32
>
> -/* smp_load_acquire() here pairs with smp_store_release() in
> +/*
> + * smp_load_acquire() here pairs with smp_store_release() in
>   * quarantine_reduce().
>   */
>  #define QUARANTINE_LOW_SIZE (smp_load_acquire(&quarantine_size) * 3 / 4)
>  #define QUARANTINE_PERCPU_SIZE (1 << 20)
>
> -static struct kmem_cache *qlink_to_cache(void **qlink)
> +static struct kmem_cache *qlink_to_cache(struct qlist_node *qlink)
>  {
>         return virt_to_head_page(qlink)->slab_cache;
>  }
>
> -static void *qlink_to_object(void **qlink, struct kmem_cache *cache)
> +static void *qlink_to_object(struct qlist_node *qlink, struct kmem_cache=
 *cache)
>  {
>         struct kasan_free_meta *free_info =3D
> -               container_of((void ***)qlink, struct kasan_free_meta,
> +               container_of(qlink, struct kasan_free_meta,
>                              quarantine_link);
>
>         return ((void *)free_info) - cache->kasan_info.free_meta_offset;
>  }
>
> -static void qlink_free(void **qlink, struct kmem_cache *cache)
> +static void qlink_free(struct qlist_node *qlink, struct kmem_cache *cach=
e)
>  {
>         void *object =3D qlink_to_object(qlink, cache);
>         struct kasan_alloc_meta *alloc_info =3D get_alloc_info(cache, obj=
ect);
> @@ -152,9 +157,9 @@ static void qlink_free(void **qlink, struct kmem_cach=
e *cache)
>         local_irq_restore(flags);
>  }
>
> -static void qlist_free_all(struct qlist *q, struct kmem_cache *cache)
> +static void qlist_free_all(struct qlist_head *q, struct kmem_cache *cach=
e)
>  {
> -       void **qlink;
> +       struct qlist_node *qlink;
>
>         if (unlikely(qlist_empty(q)))
>                 return;
> @@ -163,7 +168,7 @@ static void qlist_free_all(struct qlist *q, struct km=
em_cache *cache)
>         while (qlink) {
>                 struct kmem_cache *obj_cache =3D
>                         cache ? cache : qlink_to_cache(qlink);
> -               void **next =3D *qlink;
> +               struct qlist_node *next =3D qlink->next;
>
>                 qlink_free(qlink, obj_cache);
>                 qlink =3D next;
> @@ -174,13 +179,13 @@ static void qlist_free_all(struct qlist *q, struct =
kmem_cache *cache)
>  void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cac=
he)
>  {
>         unsigned long flags;
> -       struct qlist *q;
> -       struct qlist temp =3D QLIST_INIT;
> +       struct qlist_head *q;
> +       struct qlist_head temp =3D QLIST_INIT;
>
>         local_irq_save(flags);
>
>         q =3D this_cpu_ptr(&cpu_quarantine);
> -       qlist_put(q, (void **) &info->quarantine_link, cache->size);
> +       qlist_put(q, &info->quarantine_link, cache->size);
>         if (unlikely(q->bytes > QUARANTINE_PERCPU_SIZE))
>                 qlist_move_all(q, &temp);
>
> @@ -197,21 +202,22 @@ void quarantine_reduce(void)
>  {
>         size_t new_quarantine_size;
>         unsigned long flags;
> -       struct qlist to_free =3D QLIST_INIT;
> +       struct qlist_head to_free =3D QLIST_INIT;
>         size_t size_to_free =3D 0;
> -       void **last;
> +       struct qlist_node *last;
>
>         /* smp_load_acquire() here pairs with smp_store_release() below. =
*/
> -       if (likely(ACCESS_ONCE(global_quarantine.bytes) <=3D
> +       if (likely(READ_ONCE(global_quarantine.bytes) <=3D
>                    smp_load_acquire(&quarantine_size)))
>                 return;
>
>         spin_lock_irqsave(&quarantine_lock, flags);
>
> -       /* Update quarantine size in case of hotplug. Allocate a fraction=
 of
> +       /*
> +        * Update quarantine size in case of hotplug. Allocate a fraction=
 of
>          * the installed memory to quarantine minus per-cpu queue limits.
>          */
> -       new_quarantine_size =3D (ACCESS_ONCE(totalram_pages) << PAGE_SHIF=
T) /
> +       new_quarantine_size =3D (READ_ONCE(totalram_pages) << PAGE_SHIFT)=
 /
>                 QUARANTINE_FRACTION;
>         new_quarantine_size -=3D QUARANTINE_PERCPU_SIZE * num_online_cpus=
();
>         /* Pairs with smp_load_acquire() above and in QUARANTINE_LOW_SIZE=
. */
> @@ -222,10 +228,10 @@ void quarantine_reduce(void)
>                 struct kmem_cache *cache =3D qlink_to_cache(last);
>
>                 size_to_free +=3D cache->size;
> -               if (!*last || size_to_free >
> +               if (!last->next || size_to_free >
>                     global_quarantine.bytes - QUARANTINE_LOW_SIZE)
>                         break;
> -               last =3D (void **) *last;
> +               last =3D last->next;
>         }
>         qlist_move(&global_quarantine, last, &to_free, size_to_free);
>
> @@ -234,50 +240,46 @@ void quarantine_reduce(void)
>         qlist_free_all(&to_free, NULL);
>  }
>
> -static void qlist_move_cache(struct qlist *from,
> -                                  struct qlist *to,
> +static void qlist_move_cache(struct qlist_head *from,
> +                                  struct qlist_head *to,
>                                    struct kmem_cache *cache)
>  {
> -       void ***prev;
> +       struct qlist_node *prev;
>
>         if (unlikely(qlist_empty(from)))
>                 return;
>
> -       prev =3D &from->head;
> -       while (*prev) {
> -               void **qlink =3D *prev;
> +       prev =3D from->head;
> +       while (prev) {
> +               struct qlist_node *qlink =3D prev->next;
>                 struct kmem_cache *obj_cache =3D qlink_to_cache(qlink);
>
>                 if (obj_cache =3D=3D cache) {
>                         if (unlikely(from->tail =3D=3D qlink))
> -                               from->tail =3D (void **) prev;
> -                       *prev =3D (void **) *qlink;
> +                               from->tail =3D prev;
> +                       prev =3D qlink->next;
>                         from->bytes -=3D cache->size;
>                         qlist_put(to, qlink, cache->size);
>                 } else
> -                       prev =3D (void ***) *prev;
> +                       prev =3D prev->next;
>         }
>  }
>
>  static void per_cpu_remove_cache(void *arg)
>  {
>         struct kmem_cache *cache =3D arg;
> -       struct qlist to_free =3D QLIST_INIT;
> -       struct qlist *q;
> -       unsigned long flags;
> +       struct qlist_head to_free =3D QLIST_INIT;
> +       struct qlist_head *q;
>
> -       local_irq_save(flags);
>         q =3D this_cpu_ptr(&cpu_quarantine);
>         qlist_move_cache(q, &to_free, cache);
> -       local_irq_restore(flags);
> -
>         qlist_free_all(&to_free, cache);
>  }
>
>  void quarantine_remove_cache(struct kmem_cache *cache)
>  {
>         unsigned long flags;
> -       struct qlist to_free =3D QLIST_INIT;
> +       struct qlist_head to_free =3D QLIST_INIT;
>
>         on_each_cpu(per_cpu_remove_cache, cache, 1);
>
> diff --git a/mm/mempool.c b/mm/mempool.c
> index 8655831..9e075f8 100644
> --- a/mm/mempool.c
> +++ b/mm/mempool.c
> @@ -107,10 +107,9 @@ static void kasan_poison_element(mempool_t *pool, vo=
id *element)
>         if (pool->alloc =3D=3D mempool_alloc_slab)
>                 kasan_poison_slab_free(pool->pool_data, element);
>         if (pool->alloc =3D=3D mempool_kmalloc)
> -               kasan_poison_kfree(element);
> +               kasan_kfree(element);
>         if (pool->alloc =3D=3D mempool_alloc_pages)
> -               kasan_poison_free_pages(element,
> -                                       (unsigned long)pool->pool_data);
> +               kasan_free_pages(element, (unsigned long)pool->pool_data)=
;
>  }
>
>  static void kasan_unpoison_element(mempool_t *pool, void *element, gfp_t=
 flags)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 497befe..477d938 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -993,7 +993,7 @@ static __always_inline bool free_pages_prepare(struct=
 page *page,
>
>         trace_mm_page_free(page, order);
>         kmemcheck_free_shadow(page, order);
> -       kasan_poison_free_pages(page, order);
> +       kasan_free_pages(page, order);
>
>         /*
>          * Check tail pages before head page information is cleared to
> diff --git a/mm/slab.c b/mm/slab.c
> index 3f20800..cc8bbc1 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3547,13 +3547,10 @@ free_done:
>  static inline void __cache_free(struct kmem_cache *cachep, void *objp,
>                                 unsigned long caller)
>  {
> -#ifdef CONFIG_KASAN
> +       /* Put the object into the quarantine, don't touch it for now. */
>         if (kasan_slab_free(cachep, objp))
> -               /* The object has been put into the quarantine, don't tou=
ch it
> -                * for now.
> -                */
>                 return;
> -#endif
> +
>         ___cache_free(cachep, objp, caller);
>  }
>
> diff --git a/mm/slub.c b/mm/slub.c
> index f41360e..538c858 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1319,7 +1319,7 @@ static inline void kmalloc_large_node_hook(void *pt=
r, size_t size, gfp_t flags)
>  static inline void kfree_hook(const void *x)
>  {
>         kmemleak_free(x);
> -       kasan_poison_kfree_large(x);
> +       kasan_kfree_large(x);
>  }
>
>  static inline void slab_free_hook(struct kmem_cache *s, void *x)
> @@ -1344,7 +1344,7 @@ static inline void slab_free_hook(struct kmem_cache=
 *s, void *x)
>         if (!(s->flags & SLAB_DEBUG_OBJECTS))
>                 debug_check_no_obj_freed(x, s->object_size);
>
> -       kasan_poison_slab_free(s, x);
> +       kasan_slab_free(s, x);
>  }
>
>  static inline void slab_free_freelist_hook(struct kmem_cache *s,
> --
> 2.7.3
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
