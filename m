Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 563B86B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 07:57:11 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id b205so67019006wmb.1
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 04:57:11 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id u2si17675578wju.201.2016.02.19.04.57.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Feb 2016 04:57:09 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id g62so67539432wme.0
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 04:57:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAAmzW4M98a4pGF7kCx_273nPGNjsORY-MGSgx1y0+JzYNyAa1w@mail.gmail.com>
References: <cover.1453918525.git.glider@google.com>
	<7f497e194053c25e8a3debe3e1e738a187e38c16.1453918525.git.glider@google.com>
	<20160128074442.GB15426@js1304-P5Q-DELUXE>
	<CAG_fn=W_17XMtCmLRHHccJmzPaJTk1Jc4uCa4T_n4E5NwRR9Mg@mail.gmail.com>
	<CAG_fn=VTnFDOVuQzk3NgFGd6D+BoNDSqL4-MYyo0soq+eM76-g@mail.gmail.com>
	<20160201021501.GB32125@js1304-P5Q-DELUXE>
	<CAG_fn=W7tH3MG9kEtPwZdA+ni3d1aSnFT8vkxXEVVQLsdiqZ+A@mail.gmail.com>
	<CAAmzW4M98a4pGF7kCx_273nPGNjsORY-MGSgx1y0+JzYNyAa1w@mail.gmail.com>
Date: Fri, 19 Feb 2016 13:57:09 +0100
Message-ID: <CAG_fn=V1VkfFmf3FO6KGSUxaXRsK-h9u7gtE-mSmXuESyg1o7g@mail.gmail.com>
Subject: Re: [PATCH v1 2/8] mm, kasan: SLAB support
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, kasan-dev@googlegroups.com, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Dmitriy Vyukov <dvyukov@google.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrey Konovalov <adech.fo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>

Ah, yes, I see.
This patch was indeed missing the following bits in kasan_slab_free():

#ifdef CONFIG_SLAB
 if (cache->flags & SLAB_KASAN) {
 struct kasan_free_meta *free_info =3D
 get_free_info(cache, object);
 struct kasan_alloc_meta *alloc_info =3D
 get_alloc_info(cache, object);
 alloc_info->state =3D KASAN_STATE_FREE;
 set_track(&free_info->track);
 }
#endif

I'll include them in the next round of patches.

On Fri, Feb 19, 2016 at 2:41 AM, Joonsoo Kim <js1304@gmail.com> wrote:
>> On Mon, Feb 1, 2016 at 3:15 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wro=
te:
>>> On Thu, Jan 28, 2016 at 02:29:42PM +0100, Alexander Potapenko wrote:
>>>> On Thu, Jan 28, 2016 at 1:37 PM, Alexander Potapenko <glider@google.co=
m> wrote:
>>>> >
>>>> > On Jan 28, 2016 8:44 AM, "Joonsoo Kim" <iamjoonsoo.kim@lge.com> wrot=
e:
>>>> >>
>>>> >> On Wed, Jan 27, 2016 at 07:25:07PM +0100, Alexander Potapenko wrote=
:
>>>> >> > This patch adds KASAN hooks to SLAB allocator.
>>>> >> >
>>>> >> > This patch is based on the "mm: kasan: unified support for SLUB a=
nd
>>>> >> > SLAB allocators" patch originally prepared by Dmitry Chernenkov.
>>>> >> >
>>>> >> > Signed-off-by: Alexander Potapenko <glider@google.com>
>>>> >> > ---
>>>> >> >  Documentation/kasan.txt  |  5 ++-
>>>> >>
>>>> >> ...
>>>> >>
>>>> >> > +#ifdef CONFIG_SLAB
>>>> >> > +struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache=
,
>>>> >> > +                                     const void *object)
>>>> >> > +{
>>>> >> > +     return (void *)object + cache->kasan_info.alloc_meta_offset=
;
>>>> >> > +}
>>>> >> > +
>>>> >> > +struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
>>>> >> > +                                   const void *object)
>>>> >> > +{
>>>> >> > +     return (void *)object + cache->kasan_info.free_meta_offset;
>>>> >> > +}
>>>> >> > +#endif
>>>> >>
>>>> >> I cannot find the place to store stack info for free. get_free_info=
()
>>>> >> isn't used except print_object(). Plese let me know where.
>>>> >
>>>> > This is covered by other patches in this patchset.
>>>
>>> This should be covered by this patch. Stroing and printing free_info
>>> is already done on SLUB and it is meaningful without quarantain.
>
> 2016-02-18 21:58 GMT+09:00 Alexander Potapenko <glider@google.com>:
>> However this info is meaningless without saved stack traces, which are
>> only introduced in the stackdepot patch (see "[PATCH v1 5/8] mm,
>> kasan: Stackdepot implementation. Enable stackdepot for SLAB")
>
> Not meaningless. You already did it for allocation caller without saved
> stack traces. What makes difference between alloc/free?
>
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
