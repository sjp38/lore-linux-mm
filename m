Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 744C96B0005
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 09:37:38 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a2so7542778lfe.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 06:37:38 -0700 (PDT)
Received: from mail-lf0-x230.google.com (mail-lf0-x230.google.com. [2a00:1450:4010:c07::230])
        by mx.google.com with ESMTPS id f16si852175lfe.214.2016.06.15.06.37.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 06:37:36 -0700 (PDT)
Received: by mail-lf0-x230.google.com with SMTP id l188so10428881lfe.2
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 06:37:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAG_fn=VugG67CgjOC_K0gtRNCFdAheEELurHSHMGmRXEOd3OQQ@mail.gmail.com>
References: <1465411243-102618-1-git-send-email-glider@google.com>
 <57599D1C.2080701@virtuozzo.com> <CAG_fn=VugG67CgjOC_K0gtRNCFdAheEELurHSHMGmRXEOd3OQQ@mail.gmail.com>
From: Alexander Potapenko <glider@google.com>
Date: Wed, 15 Jun 2016 15:37:35 +0200
Message-ID: <CAG_fn=UP=9xdFf6K4-TByLjvJPwAJJ3TdcDkfqHZ2FBUSS0ruw@mail.gmail.com>
Subject: Re: [PATCH] mm, kasan: switch SLUB to stackdepot, enable memory
 quarantine for SLUB
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 9, 2016 at 8:22 PM, Alexander Potapenko <glider@google.com> wro=
te:
> On Thu, Jun 9, 2016 at 6:45 PM, Andrey Ryabinin <aryabinin@virtuozzo.com>=
 wrote:
>>
>>
>> On 06/08/2016 09:40 PM, Alexander Potapenko wrote:
>>> For KASAN builds:
>>>  - switch SLUB allocator to using stackdepot instead of storing the
>>>    allocation/deallocation stacks in the objects;
>>>  - define SLAB_RED_ZONE, SLAB_POISON, SLAB_STORE_USER to zero,
>>>    effectively disabling these debug features, as they're redundant in
>>>    the presence of KASAN;
>>
>> Instead of having duplicated functionality, I think it might be better t=
o switch SLAB_STORE_USER to stackdepot instead.
>> Because now, we have two piles of code which do basically the same thing=
, but
>> do differently.
> Fine, I'll try that out.
>>>  - refactor the slab freelist hook, put freed memory into the quarantin=
e.
>>>
>>
>> What you did with slab_freelist_hook() is not refactoring, it's an obfus=
cation.
> Whatever you call it.
> The problem is that if a list of heterogeneous objects is passed into
> slab_free_freelist_hook(), some of them may end up in the quarantine,
> while others will not.
> Therefore we need to filter that list and remove the objects that
> don't need to be freed from it.
>>
>>>  }
>>>
>>> -#ifdef CONFIG_SLAB
>>>  /*
>>>   * Adaptive redzone policy taken from the userspace AddressSanitizer r=
untime.
>>>   * For larger allocations larger redzones are used.
>>> @@ -372,17 +371,21 @@ static size_t optimal_redzone(size_t object_size)
>>>  void kasan_cache_create(struct kmem_cache *cache, size_t *size,
>>>                       unsigned long *flags)
>>>  {
>>> -     int redzone_adjust;
>>> -     /* Make sure the adjusted size is still less than
>>> -      * KMALLOC_MAX_CACHE_SIZE.
>>> -      * TODO: this check is only useful for SLAB, but not SLUB. We'll =
need
>>> -      * to skip it for SLUB when it starts using kasan_cache_create().
>>> +     int redzone_adjust, orig_size =3D *size;
>>> +
>>> +#ifdef CONFIG_SLAB
>>> +     /*
>>> +      * Make sure the adjusted size is still less than
>>> +      * KMALLOC_MAX_CACHE_SIZE, i.e. we don't use the page allocator.
>>>        */
>>> +
>>>       if (*size > KMALLOC_MAX_CACHE_SIZE -
>>
>> This is wrong. You probably wanted KMALLOC_MAX_SIZE here.
> Yeah, sonds right.
>> However, we should get rid of SLAB_KASAN altogether. It's absolutely use=
less, and only complicates
>> the code. And if we don't fit in KMALLOC_MAX_SIZE, just don't create cac=
he.
> Thanks, I'll look into this. Looks like you are right, once we remove
> this check every existing cache will have SLAB_KASAN set.
> It's handy for debugging, but not really needed.
Turns out we cannot just skip cache creation if we don't fit in
KMALLOC_MAX_SIZE, because SLAB, among others, creates kmalloc-4194304.
So we must keep an attribute that denotes that this is a KASAN-enabled
slab (i.e. the SLAB_KASAN flag), or set alloc_meta_offset and
free_meta_offset to -1, which isn't so convenient.
I suggest we stick with SLAB_KASAN.
>>
>>>           sizeof(struct kasan_alloc_meta) -
>>>           sizeof(struct kasan_free_meta))
>>>               return;
>>> +#endif
>>>       *flags |=3D SLAB_KASAN;
>>> +
>>>       /* Add alloc meta. */
>>>       cache->kasan_info.alloc_meta_offset =3D *size;
>>>       *size +=3D sizeof(struct kasan_alloc_meta);
>>> @@ -392,17 +395,37 @@ void kasan_cache_create(struct kmem_cache *cache,=
 size_t *size,
>>>           cache->object_size < sizeof(struct kasan_free_meta)) {
>>>               cache->kasan_info.free_meta_offset =3D *size;
>>>               *size +=3D sizeof(struct kasan_free_meta);
>>> +     } else {
>>> +             cache->kasan_info.free_meta_offset =3D 0;
>>>       }
>>>       redzone_adjust =3D optimal_redzone(cache->object_size) -
>>>               (*size - cache->object_size);
>>> +
>>>       if (redzone_adjust > 0)
>>>               *size +=3D redzone_adjust;
>>> +
>>> +#ifdef CONFIG_SLAB
>>>       *size =3D min(KMALLOC_MAX_CACHE_SIZE,
>>>                   max(*size,
>>>                       cache->object_size +
>>>                       optimal_redzone(cache->object_size)));
>>> -}
>>> +     /*
>>> +      * If the metadata doesn't fit, disable KASAN at all.
>>> +      */
>>> +     if (*size <=3D cache->kasan_info.alloc_meta_offset ||
>>> +                     *size <=3D cache->kasan_info.free_meta_offset) {
>>> +             *flags &=3D ~SLAB_KASAN;
>>> +             *size =3D orig_size;
>>> +             cache->kasan_info.alloc_meta_offset =3D -1;
>>> +             cache->kasan_info.free_meta_offset =3D -1;
>>> +     }
>>> +#else
>>> +     *size =3D max(*size,
>>> +                     cache->object_size +
>>> +                     optimal_redzone(cache->object_size));
>>> +
>>>  #endif
>>> +}
>>>
>>>  void kasan_cache_shrink(struct kmem_cache *cache)
>>>  {
>>> @@ -431,16 +454,14 @@ void kasan_poison_object_data(struct kmem_cache *=
cache, void *object)
>>>       kasan_poison_shadow(object,
>>>                       round_up(cache->object_size, KASAN_SHADOW_SCALE_S=
IZE),
>>>                       KASAN_KMALLOC_REDZONE);
>>> -#ifdef CONFIG_SLAB
>>>       if (cache->flags & SLAB_KASAN) {
>>>               struct kasan_alloc_meta *alloc_info =3D
>>>                       get_alloc_info(cache, object);
>>> -             alloc_info->state =3D KASAN_STATE_INIT;
>>> +             if (alloc_info)
>>
>> If I read the code right alloc_info can be NULL only if SLAB_KASAN is se=
t.
> This has been left over from tracking down some nasty bugs, but, yes,
> we can assume alloc_info and free_info are always valid.
>>
>>> +                     alloc_info->state =3D KASAN_STATE_INIT;
>>>       }
>>> -#endif
>>>  }
>>>
>>> -#ifdef CONFIG_SLAB
>>>  static inline int in_irqentry_text(unsigned long ptr)
>>>  {
>>>       return (ptr >=3D (unsigned long)&__irqentry_text_start &&
>>> @@ -492,6 +513,8 @@ struct kasan_alloc_meta *get_alloc_info(struct kmem=
_cache *cache,
>>>                                       const void *object)
>>>  {
>>>       BUILD_BUG_ON(sizeof(struct kasan_alloc_meta) > 32);
>>> +     if (cache->kasan_info.alloc_meta_offset =3D=3D -1)
>>> +             return NULL;
>>
>> What's the point of this ? This should be always false.
> Agreed, will remove this (and other similar cases).
>>>       return (void *)object + cache->kasan_info.alloc_meta_offset;
>>>  }
>>>
>>> @@ -499,9 +522,10 @@ struct kasan_free_meta *get_free_info(struct kmem_=
cache *cache,
>>>                                     const void *object)
>>>  {
>>>       BUILD_BUG_ON(sizeof(struct kasan_free_meta) > 32);
>>> +     if (cache->kasan_info.free_meta_offset =3D=3D -1)
>>> +             return NULL;
>>>       return (void *)object + cache->kasan_info.free_meta_offset;
>>>  }
>>> -#endif
>>>
>>>  void kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t fl=
ags)
>>>  {
>>> @@ -522,7 +546,6 @@ void kasan_poison_slab_free(struct kmem_cache *cach=
e, void *object)
>>>
>>>  bool kasan_slab_free(struct kmem_cache *cache, void *object)
>>>  {
>>> -#ifdef CONFIG_SLAB
>>>       /* RCU slabs could be legally used after free within the RCU peri=
od */
>>>       if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
>>>               return false;
>>> @@ -532,7 +555,10 @@ bool kasan_slab_free(struct kmem_cache *cache, voi=
d *object)
>>>                       get_alloc_info(cache, object);
>>>               struct kasan_free_meta *free_info =3D
>>>                       get_free_info(cache, object);
>>> -
>>> +             WARN_ON(!alloc_info);
>>> +             WARN_ON(!free_info);
>>> +             if (!alloc_info || !free_info)
>>> +                     return;
>>
>> Again, never possible.
>>
>>
>>>               switch (alloc_info->state) {
>>>               case KASAN_STATE_ALLOC:
>>>                       alloc_info->state =3D KASAN_STATE_QUARANTINE;
>>> @@ -550,10 +576,6 @@ bool kasan_slab_free(struct kmem_cache *cache, voi=
d *object)
>>>               }
>>>       }
>>>       return false;
>>> -#else
>>> -     kasan_poison_slab_free(cache, object);
>>> -     return false;
>>> -#endif
>>>  }
>>>
>>>  void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_=
t size,
>>> @@ -568,24 +590,29 @@ void kasan_kmalloc(struct kmem_cache *cache, cons=
t void *object, size_t size,
>>>       if (unlikely(object =3D=3D NULL))
>>>               return;
>>>
>>> +     if (!(cache->flags & SLAB_KASAN))
>>> +             return;
>>> +
>>>       redzone_start =3D round_up((unsigned long)(object + size),
>>>                               KASAN_SHADOW_SCALE_SIZE);
>>>       redzone_end =3D round_up((unsigned long)object + cache->object_si=
ze,
>>>                               KASAN_SHADOW_SCALE_SIZE);
>>>
>>>       kasan_unpoison_shadow(object, size);
>>> +     WARN_ON(redzone_start > redzone_end);
>>> +     if (redzone_start > redzone_end)
>>
>> How that's can happen?
> This was possible because of incorrect ksize implementation, should be
> now ok. Removed.
>>> +             return;
>>>       kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_=
start,
>>>               KASAN_KMALLOC_REDZONE);
>>> -#ifdef CONFIG_SLAB
>>>       if (cache->flags & SLAB_KASAN) {
>>>               struct kasan_alloc_meta *alloc_info =3D
>>>                       get_alloc_info(cache, object);
>>> -
>>> -             alloc_info->state =3D KASAN_STATE_ALLOC;
>>> -             alloc_info->alloc_size =3D size;
>>> -             set_track(&alloc_info->track, flags);
>>> +             if (alloc_info) {
>>
>> And again...
>>
>>
>>> +                     alloc_info->state =3D KASAN_STATE_ALLOC;
>>> +                     alloc_info->alloc_size =3D size;
>>> +                     set_track(&alloc_info->track, flags);
>>> +             }
>>>       }
>>> -#endif
>>>  }
>>>  EXPORT_SYMBOL(kasan_kmalloc);
>>>
>>
>>
>> [..]
>>
>>> diff --git a/mm/slab.h b/mm/slab.h
>>> index dedb1a9..fde1fea 100644
>>> --- a/mm/slab.h
>>> +++ b/mm/slab.h
>>> @@ -366,6 +366,10 @@ static inline size_t slab_ksize(const struct kmem_=
cache *s)
>>>       if (s->flags & (SLAB_RED_ZONE | SLAB_POISON))
>>>               return s->object_size;
>>>  # endif
>>> +# ifdef CONFIG_KASAN
>>
>> Gush, you love ifdefs, don't you? Hint: it's redundant here.
>>
>>> +     if (s->flags & SLAB_KASAN)
>>> +             return s->object_size;
>>> +# endif
>>>       /*
>>>        * If we have the need to store the freelist pointer
>> ...
>
>
>
> --
> Alexander Potapenko
> Software Engineer
>
> Google Germany GmbH
> Erika-Mann-Stra=C3=9Fe, 33
> 80636 M=C3=BCnchen
>
> Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
> Registergericht und -nummer: Hamburg, HRB 86891
> Sitz der Gesellschaft: Hamburg



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
