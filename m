Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3A9716B0253
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 06:10:57 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l89so7930590lfi.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 03:10:57 -0700 (PDT)
Received: from mail-lf0-x22a.google.com (mail-lf0-x22a.google.com. [2a00:1450:4010:c07::22a])
        by mx.google.com with ESMTPS id 16si745858lfv.416.2016.07.12.03.10.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 03:10:54 -0700 (PDT)
Received: by mail-lf0-x22a.google.com with SMTP id h129so8496680lfh.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 03:10:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <577FDC2C.9030400@virtuozzo.com>
References: <1467974210-117852-1-git-send-email-glider@google.com> <577FDC2C.9030400@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 12 Jul 2016 12:10:52 +0200
Message-ID: <CAG_fn=WSNVnSOYtZLO-TLcc_RQOecTtP+Xc=_nj0xCQmR-VvKA@mail.gmail.com>
Subject: Re: [PATCH v6] mm, kasan: switch SLUB to stackdepot, enable memory
 quarantine for SLUB
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 8, 2016 at 7:00 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> w=
rote:
>
>
> On 07/08/2016 01:36 PM, Alexander Potapenko wrote:
>>
>> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
>> index d1faa01..07e4549 100644
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
>> @@ -119,10 +123,11 @@ static inline void *nearest_obj(struct kmem_cache =
*cache, struct page *page,
>>       void *object =3D x - (x - page_address(page)) % cache->size;
>>       void *last_object =3D page_address(page) +
>>               (page->objects - 1) * cache->size;
>> -     if (unlikely(object > last_object))
>> -             return last_object;
>> -     else
>> -             return object;
>> +     void *result =3D (unlikely(object > last_object)) ? last_object : =
object;
>> +
>> +     if (cache->flags & SLAB_RED_ZONE)
>> +             return ((char *)result + cache->red_left_pad);
>> +     return result;
>
> This fixes existing problem. It should be a separate patch.
Done.
>
>>
>>  void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t=
 size,
>> @@ -568,6 +572,9 @@ void kasan_kmalloc(struct kmem_cache *cache, const v=
oid *object, size_t size,
>>       if (unlikely(object =3D=3D NULL))
>>               return;
>>
>> +     if (!(cache->flags & SLAB_KASAN))
>> +             return;
>> +
>
> I still think that this hunk should be removed.
Got it. Indeed, you're right, we're checking SLAB_KASAN twice in this funct=
ion.

>>       redzone_start =3D round_up((unsigned long)(object + size),
>>                               KASAN_SHADOW_SCALE_SIZE);
>>       redzone_end =3D round_up((unsigned long)object + cache->object_siz=
e,
>> @@ -576,7 +583,6 @@ void kasan_kmalloc(struct kmem_cache *cache, const v=
oid *object, size_t size,
>>       kasan_unpoison_shadow(object, size);
>>       kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_s=
tart,
>>               KASAN_KMALLOC_REDZONE);
>> -#ifdef CONFIG_SLAB
>>       if (cache->flags & SLAB_KASAN) {
>>               struct kasan_alloc_meta *alloc_info =3D
>>                       get_alloc_info(cache, object);
>> @@ -585,7 +591,6 @@ void kasan_kmalloc(struct kmem_cache *cache, const v=
oid *object, size_t size,
>>               alloc_info->alloc_size =3D size;
>>               set_track(&alloc_info->track, flags);
>>       }
>> -#endif
>>  }
>>  EXPORT_SYMBOL(kasan_kmalloc);
>>
>
>
> ...
>
>
>> diff --git a/mm/slab.h b/mm/slab.h
>> index dedb1a9..9a09d06 100644
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
>> @@ -462,6 +464,7 @@ void *slab_next(struct seq_file *m, void *p, loff_t =
*pos);
>>  void slab_stop(struct seq_file *m, void *p);
>>  int memcg_slab_show(struct seq_file *m, void *p);
>>
>> -void ___cache_free(struct kmem_cache *cache, void *x, unsigned long add=
r);
>> +void *nearest_obj(struct kmem_cache *cache, struct page *page, void *x)=
;
>
> Remove.
Done.
>> +void ___cache_free(struct kmem_cache *cache, void *x, unsigned long add=
r);
>>  #endif /* MM_SLAB_H */
>> diff --git a/mm/slub.c b/mm/slub.c
>> index 825ff45..72ecffa 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -454,8 +454,6 @@ static inline void *restore_red_left(struct kmem_cac=
he *s, void *p)
>>   */
>>  #if defined(CONFIG_SLUB_DEBUG_ON)
>>  static int slub_debug =3D DEBUG_DEFAULT_FLAGS;
>> -#elif defined(CONFIG_KASAN)
>> -static int slub_debug =3D SLAB_STORE_USER;
>>  #else
>>  static int slub_debug;
>>  #endif
>> @@ -783,6 +781,14 @@ static int check_pad_bytes(struct kmem_cache *s, st=
ruct page *page, u8 *p)
>>               /* Freepointer is placed after the object. */
>>               off +=3D sizeof(void *);
>>
>> +#ifdef CONFIG_KASAN
>> +     if (s->kasan_info.alloc_meta_offset)
>> +             off +=3D sizeof(struct kasan_alloc_meta);
>> +
>> +     if (s->kasan_info.free_meta_offset)
>> +             off +=3D sizeof(struct kasan_free_meta);
>> +#endif
>
> That's ugly.
>
> Following is not ugly:
>         off +=3D kasan_metadata_size();
Fixed. Also moved kasan_{alloc,free}_meta declarations back.
>
>>       if (s->flags & SLAB_STORE_USER)
>>               /* We also have user information there */
>>               off +=3D 2 * sizeof(struct track);
>> @@ -1322,7 +1328,7 @@ static inline void kfree_hook(const void *x)
>>       kasan_kfree_large(x);
>>  }
>>
>> -static inline void slab_free_hook(struct kmem_cache *s, void *x)
>> +static inline bool slab_free_hook(struct kmem_cache *s, void *x)
>>  {
>>       kmemleak_free_recursive(x, s->flags);
>>
>> @@ -1344,7 +1350,7 @@ static inline void slab_free_hook(struct kmem_cach=
e *s, void *x)
>>       if (!(s->flags & SLAB_DEBUG_OBJECTS))
>>               debug_check_no_obj_freed(x, s->object_size);
>>
>> -     kasan_slab_free(s, x);
>> +     return kasan_slab_free(s, x);
>>  }
>
> Change it back, return value is not unused anymore.
Done.
>
>>
>>  static inline void slab_free_freelist_hook(struct kmem_cache *s,
>> @@ -2753,6 +2759,9 @@ slab_empty:
>>       discard_slab(s, page);
>>  }
>>
>> +static void do_slab_free(struct kmem_cache *s, struct page *page,
>> +             void *head, void *tail, int cnt, unsigned long addr);
>> +
>
> You can just place slab_free() after do_slab_free().
Done. I've retained the comment below, but it's now attributed to
do_slab_free().
>>  /*
>>   * Fastpath with forced inlining to produce a kfree and kmem_cache_free=
 that
>>   * can perform fastpath freeing without additional function calls.
>> @@ -2772,12 +2781,23 @@ static __always_inline void slab_free(struct kme=
m_cache *s, struct page *page,
>>                                     void *head, void *tail, int cnt,
>>                                     unsigned long addr)
>>  {
>> +     slab_free_freelist_hook(s, head, tail);
>> +     /*
>> +      * slab_free_freelist_hook() could have put the items into quarant=
ine.
>> +      * If so, no need to free them.
>> +      */
>> +     if (s->flags & SLAB_KASAN && !(s->flags & SLAB_DESTROY_BY_RCU))
>> +             return;
>> +     do_slab_free(s, page, head, tail, cnt, addr);
>> +}
>> +
>> +static __always_inline void do_slab_free(struct kmem_cache *s,
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
>> @@ -2811,6 +2831,11 @@ redo:
>>
>>  }
>>
>> +void ___cache_free(struct kmem_cache *cache, void *x, unsigned long add=
r)
>> +{
>> +     do_slab_free(cache, virt_to_head_page(x), x, NULL, 1, addr);
>> +}
>> +
>
> Probably would be better to hide this under #ifdef CONFIG_KASAN. It has n=
o other users, and it might be relatively
> large function because do_slab_free() is always inlined.
Done.
>
>>  void kmem_cache_free(struct kmem_cache *s, void *x)
>>  {
>>       s =3D cache_from_obj(s, x);
>> @@ -3252,7 +3277,7 @@ static void set_min_partial(struct kmem_cache *s, =
unsigned long min)
>>  static int calculate_sizes(struct kmem_cache *s, int forced_order)
>>  {
>>       unsigned long flags =3D s->flags;
>> -     unsigned long size =3D s->object_size;
>> +     size_t size =3D s->object_size;
>>       int order;
>>
>>       /*
>> @@ -3311,7 +3336,10 @@ static int calculate_sizes(struct kmem_cache *s, =
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
>>



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
