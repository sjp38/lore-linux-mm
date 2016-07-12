Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C3CE26B0260
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 06:17:31 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o80so10019989wme.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 03:17:31 -0700 (PDT)
Received: from mail-lf0-x234.google.com (mail-lf0-x234.google.com. [2a00:1450:4010:c07::234])
        by mx.google.com with ESMTPS id a82si2195649lfa.412.2016.07.12.03.17.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 03:17:30 -0700 (PDT)
Received: by mail-lf0-x234.google.com with SMTP id f93so8640983lfi.2
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 03:17:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <577FC734.9000603@virtuozzo.com>
References: <1466617421-58518-1-git-send-email-glider@google.com>
 <5772AAFB.1070907@virtuozzo.com> <CAG_fn=Xe1hd_1kZN6NxnhvfZNs4zYCYm9674UkcPVxDeTreO9A@mail.gmail.com>
 <577FC734.9000603@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 12 Jul 2016 12:17:29 +0200
Message-ID: <CAG_fn=XFPFJKag3VeTuO0ELak1Y8fqfC7JH6hhKUdrAfQyR9rw@mail.gmail.com>
Subject: Re: [PATCH v5] mm, kasan: switch SLUB to stackdepot, enable memory
 quarantine for SLUB
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 8, 2016 at 5:31 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> w=
rote:
>
>
> On 07/08/2016 01:36 PM, Alexander Potapenko wrote:
>> On Tue, Jun 28, 2016 at 6:51 PM, Andrey Ryabinin
>> <aryabinin@virtuozzo.com> wrote:
>
>>>>       *flags |=3D SLAB_KASAN;
>>>> +
>>>>       /* Add alloc meta. */
>>>>       cache->kasan_info.alloc_meta_offset =3D *size;
>>>>       *size +=3D sizeof(struct kasan_alloc_meta);
>>>> @@ -392,17 +387,35 @@ void kasan_cache_create(struct kmem_cache *cache=
, size_t *size,
>>>>           cache->object_size < sizeof(struct kasan_free_meta)) {
>>>>               cache->kasan_info.free_meta_offset =3D *size;
>>>>               *size +=3D sizeof(struct kasan_free_meta);
>>>> +     } else {
>>>> +             cache->kasan_info.free_meta_offset =3D 0;
>>>
>>> Why is that required now?
>> Because we want to store the free metadata in the object when it's possi=
ble.
>
> We did the before this patch. free_meta_offset is 0 by default, thus ther=
e was no need to nullify it here.
> But now this patch suddenly adds reset of free_meta_offset. So I'm asking=
 why?
> Is free_meta_offset not 0 by default anymore?
Yes, since the new cache is created using zalloc() (which I didn't
know before) I'd better remove this assignment.
>
>
>>>>
>>>>  void kasan_kmalloc(struct kmem_cache *cache, const void *object, size=
_t size,
>>>> @@ -568,6 +573,9 @@ void kasan_kmalloc(struct kmem_cache *cache, const=
 void *object, size_t size,
>>>>       if (unlikely(object =3D=3D NULL))
>>>>               return;
>>>>
>>>> +     if (!(cache->flags & SLAB_KASAN))
>>>> +             return;
>>>> +
>>>
>>> This hunk is superfluous and wrong.
>> Can you please elaborate?
>> Do you mean we don't need to check for SLAB_KASAN here, or that we
>> don't need SLAB_KASAN at all?
>
> The former, we can poison/unpoison !SLAB_KASAN caches too.
>
>
>
>>>>  }
>>>>
>>>> @@ -2772,12 +2788,22 @@ static __always_inline void slab_free(struct k=
mem_cache *s, struct page *page,
>>>>                                     void *head, void *tail, int cnt,
>>>>                                     unsigned long addr)
>>>>  {
>>>> +     void *free_head =3D head, *free_tail =3D tail;
>>>> +
>>>> +     slab_free_freelist_hook(s, &free_head, &free_tail, &cnt);
>>>> +     /* slab_free_freelist_hook() could have emptied the freelist. */
>>>> +     if (cnt =3D=3D 0)
>>>> +             return;
>>>
>>> I suppose that we can do something like following, instead of that mess=
 in slab_free_freelist_hook() above
>>>
>>>         slab_free_freelist_hook(s, &free_head, &free_tail);
>>>         if (s->flags & SLAB_KASAN && s->flags & SLAB_DESTROY_BY_RCU)
>> Did you mean "&& !(s->flags & SLAB_DESTROY_BY_RCU)" ?
>
> Sure.
>
>>>                 return;
>> Yes, my code is overly complicated given that kasan_slab_free() should
>> actually return the same value for every element of the list.
>> (do you think it makes sense to check that?)
>
> IMO that's would be superfluous.
>
>> I can safely remove those freelist manipulations.
>>>
>>>



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
