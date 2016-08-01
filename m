Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 96B5E6B0269
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 11:27:30 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l4so84673693wml.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 08:27:30 -0700 (PDT)
Received: from mail-lf0-x233.google.com (mail-lf0-x233.google.com. [2a00:1450:4010:c07::233])
        by mx.google.com with ESMTPS id f65si14671888lff.360.2016.08.01.08.27.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 08:27:29 -0700 (PDT)
Received: by mail-lf0-x233.google.com with SMTP id f93so118233159lfi.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 08:27:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <579F669A.4090806@virtuozzo.com>
References: <1469719879-11761-1-git-send-email-glider@google.com>
 <1469719879-11761-3-git-send-email-glider@google.com> <579F62D3.8030605@virtuozzo.com>
 <CAG_fn=XOa9mrE-9=0j73qMZQZXNJDOT2X7EL+xU+6zL_W1cqsw@mail.gmail.com> <579F669A.4090806@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Mon, 1 Aug 2016 17:27:28 +0200
Message-ID: <CAG_fn=WSqvuDNi7GN=6wYQxmGtDb0=Z6RLDyUB-V_JJgf3ANLg@mail.gmail.com>
Subject: Re: [PATCH v8 2/3] mm, kasan: align free_meta_offset on sizeof(void*)
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Dmitriy Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Aug 1, 2016 at 5:11 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> w=
rote:
>
>
> On 08/01/2016 05:56 PM, Alexander Potapenko wrote:
>> On Mon, Aug 1, 2016 at 4:55 PM, Andrey Ryabinin <aryabinin@virtuozzo.com=
> wrote:
>>>
>>>
>>> On 07/28/2016 06:31 PM, Alexander Potapenko wrote:
>>>> When free_meta_offset is not zero, it is usually aligned on 4 bytes,
>>>> because the size of preceding kasan_alloc_meta is aligned on 4 bytes.
>>>> As a result, accesses to kasan_free_meta fields may be misaligned.
>>>>
>>>> Signed-off-by: Alexander Potapenko <glider@google.com>
>>>> ---
>>>>  mm/kasan/kasan.c | 3 ++-
>>>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
>>>> index 6845f92..0379551 100644
>>>> --- a/mm/kasan/kasan.c
>>>> +++ b/mm/kasan/kasan.c
>>>> @@ -390,7 +390,8 @@ void kasan_cache_create(struct kmem_cache *cache, =
size_t *size,
>>>>       /* Add free meta. */
>>>>       if (cache->flags & SLAB_DESTROY_BY_RCU || cache->ctor ||
>>>>           cache->object_size < sizeof(struct kasan_free_meta)) {
>>>> -             cache->kasan_info.free_meta_offset =3D *size;
>>>> +             cache->kasan_info.free_meta_offset =3D
>>>> +                     ALIGN(*size, sizeof(void *));
>>>
>>> This cannot work.
>> Well, it does, at least on my tests.
>
> JFYI. You aligned only meta offset, but didn't change the size, so after =
the '*size +=3D sizeof(struct kasan_free_meta);'
> *size may point into the middle of free_meta struct.
> Plus, alignment wasn't taken into account in kasan_metadata_size().
That's what I do in PATCH 3/3
(https://marc.info/?l=3Dlinux-mm&m=3D146971994204507&w=3D2)


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
