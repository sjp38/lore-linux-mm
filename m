Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 32B3E828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 09:06:06 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id g62so26841736wme.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 06:06:06 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id n132si5463445wmd.34.2016.02.18.06.06.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 06:06:04 -0800 (PST)
Received: by mail-wm0-x232.google.com with SMTP id g62so27083199wme.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 06:06:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160201024715.GC32125@js1304-P5Q-DELUXE>
References: <cover.1453918525.git.glider@google.com>
	<1cec06645310eeb495bcae7bed0807dbf2235f3a.1453918525.git.glider@google.com>
	<20160201024715.GC32125@js1304-P5Q-DELUXE>
Date: Thu, 18 Feb 2016 15:06:03 +0100
Message-ID: <CAG_fn=W2C=aOgPQgkCi6ntA1tCMOaiF0LjbKtuo1TCFbH58HEg@mail.gmail.com>
Subject: Re: [PATCH v1 8/8] mm: kasan: Initial memory quarantine implementation
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Feb 1, 2016 at 3:47 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> On Wed, Jan 27, 2016 at 07:25:13PM +0100, Alexander Potapenko wrote:
>> Quarantine isolates freed objects in a separate queue. The objects are
>> returned to the allocator later, which helps to detect use-after-free
>> errors.
>>
>> Freed objects are first added to per-cpu quarantine queues.
>> When a cache is destroyed or memory shrinking is requested, the objects
>> are moved into the global quarantine queue. Whenever a kmalloc call
>> allows memory reclaiming, the oldest objects are popped out of the
>> global queue until the total size of objects in quarantine is less than
>> 3/4 of the maximum quarantine size (which is a fraction of installed
>> physical memory).
>
> Just wondering why not using time based approach rather than size
> based one. In heavy load condition, how much time do the object stay in
> quarantine?
>
>>
>> Right now quarantine support is only enabled in SLAB allocator.
>> Unification of KASAN features in SLAB and SLUB will be done later.
>>
>> This patch is based on the "mm: kasan: quarantine" patch originally
>> prepared by Dmitry Chernenkov.
>>
>> Signed-off-by: Alexander Potapenko <glider@google.com>
>> ---
>>  include/linux/kasan.h |  30 ++++--
>>  lib/test_kasan.c      |  29 ++++++
>>  mm/kasan/Makefile     |   2 +-
>>  mm/kasan/kasan.c      |  68 +++++++++++-
>>  mm/kasan/kasan.h      |  11 +-
>>  mm/kasan/quarantine.c | 284 +++++++++++++++++++++++++++++++++++++++++++=
+++++++
>>  mm/kasan/report.c     |   3 +-
>>  mm/mempool.c          |   7 +-
>>  mm/page_alloc.c       |   2 +-
>>  mm/slab.c             |  12 ++-
>>  mm/slab.h             |   4 +
>>  mm/slab_common.c      |   2 +
>>  mm/slub.c             |   4 +-
>>  13 files changed, 435 insertions(+), 23 deletions(-)
>>
>
> ...
>
>> +bool kasan_slab_free(struct kmem_cache *cache, void *object)
>> +{
>> +#ifdef CONFIG_SLAB
>> +     /* RCU slabs could be legally used after free within the RCU perio=
d */
>> +     if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
>> +             return false;
>> +
>> +     if (likely(cache->flags & SLAB_KASAN)) {
>> +             struct kasan_alloc_meta *alloc_info =3D
>> +                     get_alloc_info(cache, object);
>> +             struct kasan_free_meta *free_info =3D
>> +                     get_free_info(cache, object);
>> +
>> +             switch (alloc_info->state) {
>> +             case KASAN_STATE_ALLOC:
>> +                     alloc_info->state =3D KASAN_STATE_QUARANTINE;
>> +                     quarantine_put(free_info, cache);
>
> quarantine_put() can be called regardless of SLAB_DESTROY_BY_RCU,
> although it's not much meaningful without poisoning. But, I have an
> idea to poison object on SLAB_DESTROY_BY_RCU cache.
>
> quarantine_put() moves per cpu list to global queue when
> list size reaches QUARANTINE_PERCPU_SIZE. If we call synchronize_rcu()
> at that time, after then, we can poison objects. With appropriate size
> setup, it would not be intrusive.
>
Won't this slow the quarantine down unpredictably (e.g. in the case
there're no RCU slabs in quarantine we'll still be waiting for
synchronize_rcu())?
Yet this is something worth looking into. Do you want RCU to be
handled in this patch set?

>> +                     set_track(&free_info->track, GFP_NOWAIT);
>
> set_track() can be called regardless of SLAB_DESTROY_BY_RCU.
Agreed, I can fix that if we decide to handle RCU in this patch
(otherwise it will lead to confusion).

>
>> +                     kasan_poison_slab_free(cache, object);
>> +                     return true;
>> +             case KASAN_STATE_QUARANTINE:
>> +             case KASAN_STATE_FREE:
>> +                     pr_err("Double free");
>> +                     dump_stack();
>> +                     break;
>> +             default:
>> +                     break;
>> +             }
>> +     }
>> +     return false;
>> +#else
>> +     kasan_poison_slab_free(cache, object);
>> +     return false;
>> +#endif
>> +}
>> +
>
> ...
>
>> +void quarantine_reduce(void)
>> +{
>> +     size_t new_quarantine_size;
>> +     unsigned long flags;
>> +     struct qlist to_free =3D QLIST_INIT;
>> +     size_t size_to_free =3D 0;
>> +     void **last;
>> +
>> +     if (likely(ACCESS_ONCE(global_quarantine.bytes) <=3D
>> +                smp_load_acquire(&quarantine_size)))
>> +             return;
>> +
>> +     spin_lock_irqsave(&quarantine_lock, flags);
>> +
>> +     /* Update quarantine size in case of hotplug. Allocate a fraction =
of
>> +      * the installed memory to quarantine minus per-cpu queue limits.
>> +      */
>> +     new_quarantine_size =3D (ACCESS_ONCE(totalram_pages) << PAGE_SHIFT=
) /
>> +             QUARANTINE_FRACTION;
>> +     new_quarantine_size -=3D QUARANTINE_PERCPU_SIZE * num_online_cpus(=
);
>> +     smp_store_release(&quarantine_size, new_quarantine_size);
>> +
>> +     last =3D global_quarantine.head;
>> +     while (last) {
>> +             struct kmem_cache *cache =3D qlink_to_cache(last);
>> +
>> +             size_to_free +=3D cache->size;
>> +             if (!*last || size_to_free >
>> +                 global_quarantine.bytes - QUARANTINE_LOW_SIZE)
>> +                     break;
>> +             last =3D (void **) *last;
>> +     }
>> +     qlist_move(&global_quarantine, last, &to_free, size_to_free);
>> +
>> +     spin_unlock_irqrestore(&quarantine_lock, flags);
>> +
>> +     qlist_free_all(&to_free, NULL);
>> +}
>
> Isn't it better to call quarantine_reduce() in shrink_slab()?
> It will help to maximize quarantine time.
This is true, however if we don't call quarantine_reduce() from
kmalloc()/kfree() the size of the quarantine will be unpredictable.
There's a tradeoff between efficiency and space here, and at least in
some cases we may want to trade efficiency for space.
>
>> +
>> +static inline void qlist_move_cache(struct qlist *from,
>> +                                struct qlist *to,
>> +                                struct kmem_cache *cache)
>> +{
>> +     void ***prev;
>> +
>> +     if (unlikely(empty_qlist(from)))
>> +             return;
>> +
>> +     prev =3D &from->head;
>> +     while (*prev) {
>> +             void **qlink =3D *prev;
>> +             struct kmem_cache *obj_cache =3D qlink_to_cache(qlink);
>> +
>> +             if (obj_cache =3D=3D cache) {
>> +                     if (unlikely(from->tail =3D=3D qlink))
>> +                             from->tail =3D (void **) prev;
>> +                     *prev =3D (void **) *qlink;
>> +                     from->bytes -=3D cache->size;
>> +                     qlist_put(to, qlink, cache->size);
>> +             } else
>> +                     prev =3D (void ***) *prev;
>> +     }
>> +}
>> +
>> +static void per_cpu_remove_cache(void *arg)
>> +{
>> +     struct kmem_cache *cache =3D arg;
>> +     struct qlist to_free =3D QLIST_INIT;
>> +     struct qlist *q;
>> +     unsigned long flags;
>> +
>> +     local_irq_save(flags);
>> +     q =3D this_cpu_ptr(&cpu_quarantine);
>> +     qlist_move_cache(q, &to_free, cache);
>> +     local_irq_restore(flags);
>> +
>> +     qlist_free_all(&to_free, cache);
>> +}
>> +
>> +void quarantine_remove_cache(struct kmem_cache *cache)
>> +{
>> +     unsigned long flags;
>> +     struct qlist to_free =3D QLIST_INIT;
>> +
>> +     on_each_cpu(per_cpu_remove_cache, cache, 0);
>
> Should be called with wait =3D 1.
Agreed, thank you.

>> +
>> +     spin_lock_irqsave(&quarantine_lock, flags);
>> +     qlist_move_cache(&global_quarantine, &to_free, cache);
>> +     spin_unlock_irqrestore(&quarantine_lock, flags);
>> +
>> +     qlist_free_all(&to_free, cache);
>> +}
>> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
>> index 6c4afcd..a4dca25 100644
>> --- a/mm/kasan/report.c
>> +++ b/mm/kasan/report.c
>> @@ -148,7 +148,8 @@ static void print_object(struct kmem_cache *cache, v=
oid *object)
>>               print_track(&alloc_info->track);
>>               break;
>>       case KASAN_STATE_FREE:
>> -             pr_err("Object freed, allocated with size %u bytes\n",
>> +     case KASAN_STATE_QUARANTINE:
>> +             pr_err("Object freed, allocated with size %lu bytes\n",
>>                      alloc_info->alloc_size);
>>               free_info =3D get_free_info(cache, object);
>>               pr_err("Allocation:\n");
>> diff --git a/mm/mempool.c b/mm/mempool.c
>> index b47c8a7..4beeeef 100644
>> --- a/mm/mempool.c
>> +++ b/mm/mempool.c
>> @@ -105,11 +105,12 @@ static inline void poison_element(mempool_t *pool,=
 void *element)
>>  static void kasan_poison_element(mempool_t *pool, void *element)
>>  {
>>       if (pool->alloc =3D=3D mempool_alloc_slab)
>> -             kasan_slab_free(pool->pool_data, element);
>> +             kasan_poison_slab_free(pool->pool_data, element);
>>       if (pool->alloc =3D=3D mempool_kmalloc)
>> -             kasan_kfree(element);
>> +             kasan_poison_kfree(element);
>>       if (pool->alloc =3D=3D mempool_alloc_pages)
>> -             kasan_free_pages(element, (unsigned long)pool->pool_data);
>> +             kasan_poison_free_pages(element,
>> +                                     (unsigned long)pool->pool_data);
>>  }
>>
>>  static void kasan_unpoison_element(mempool_t *pool, void *element, gfp_=
t flags)
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 63358d9..4f65587 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -980,7 +980,7 @@ static bool free_pages_prepare(struct page *page, un=
signed int order)
>>
>>       trace_mm_page_free(page, order);
>>       kmemcheck_free_shadow(page, order);
>> -     kasan_free_pages(page, order);
>> +     kasan_poison_free_pages(page, order);
>>
>>       if (PageAnon(page))
>>               page->mapping =3D NULL;
>> diff --git a/mm/slab.c b/mm/slab.c
>> index 0ec7aa3..e2fac67 100644
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -3374,9 +3374,19 @@ free_done:
>>  static inline void __cache_free(struct kmem_cache *cachep, void *objp,
>>                               unsigned long caller)
>>  {
>> +#ifdef CONFIG_KASAN
>> +     if (!kasan_slab_free(cachep, objp))
>> +             /* The object has been put into the quarantine, don't touc=
h it
>> +              * for now.
>> +              */
>> +             nokasan_free(cachep, objp, caller);
>> +}
>> +
>> +void nokasan_free(struct kmem_cache *cachep, void *objp, unsigned long =
caller)
>> +{
>> +#endif
>
> It looks not good to me.
> Converting __cache_free() to ____cache_free() and making
> __cache_free() call ____cache_free() if (!kasan_slab_free()) looks
> better to me and less error-prone.
Fixed. Will upload the new patchset soonish.

> Thanks.



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
Diese E-Mail ist vertraulich. Wenn Sie nicht der richtige Adressat sind,
leiten Sie diese bitte nicht weiter, informieren Sie den
Absender und l=C3=B6schen Sie die E-Mail und alle Anh=C3=A4nge. Vielen Dank=
.
This e-mail is confidential. If you are not the right addressee please
do not forward it, please inform the sender, and please erase this
e-mail including any attachments. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
