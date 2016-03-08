Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id DC2666B0253
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 06:42:33 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id l68so146039120wml.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 03:42:33 -0800 (PST)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id 189si20430371wmi.4.2016.03.08.03.42.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 03:42:32 -0800 (PST)
Received: by mail-wm0-x22a.google.com with SMTP id l68so127320786wml.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 03:42:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56D58398.2010708@gmail.com>
References: <cover.1456504662.git.glider@google.com>
	<00e9fa7d4adeac2d37a42cf613837e74850d929a.1456504662.git.glider@google.com>
	<56D471F5.3010202@gmail.com>
	<CACT4Y+YPFEyuFdnM3_=2p1qANC7A1CKB0o1ySx2zexgE4kgVVw@mail.gmail.com>
	<56D58398.2010708@gmail.com>
Date: Tue, 8 Mar 2016 12:42:32 +0100
Message-ID: <CAG_fn=Xby+PJtMQtZ68gPkSPCyxbF=RsOCVavYew7ZVDx25yow@mail.gmail.com>
Subject: Re: [PATCH v4 5/7] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Mar 1, 2016 at 12:57 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com> w=
rote:
>
>
> On 02/29/2016 08:12 PM, Dmitry Vyukov wrote:
>
>>>> diff --git a/lib/Makefile b/lib/Makefile
>>>> index a7c26a4..10a4ae3 100644
>>>> --- a/lib/Makefile
>>>> +++ b/lib/Makefile
>>>> @@ -167,6 +167,13 @@ obj-$(CONFIG_SG_SPLIT) +=3D sg_split.o
>>>>  obj-$(CONFIG_STMP_DEVICE) +=3D stmp_device.o
>>>>  obj-$(CONFIG_IRQ_POLL) +=3D irq_poll.o
>>>>
>>>> +ifeq ($(CONFIG_KASAN),y)
>>>> +ifeq ($(CONFIG_SLAB),y)
>>>
>>> Just try to imagine that another subsystem wants to use stackdepot. How=
 this gonna look like?
>>>
>>> We have Kconfig to describe dependencies. So, this should be under CONF=
IG_STACKDEPOT.
>>> So any user of this feature can just do 'select STACKDEPOT' in Kconfig.
>>>
>>>> +     obj-y   +=3D stackdepot.o
>>>> +     KASAN_SANITIZE_slub.o :=3D n
>                         _stackdepot.o
>
>
>>>
>>>> +
>>>> +     stack->hash =3D hash;
>>>> +     stack->size =3D size;
>>>> +     stack->handle.slabindex =3D depot_index;
>>>> +     stack->handle.offset =3D depot_offset >> STACK_ALLOC_ALIGN;
>>>> +     __memcpy(stack->entries, entries, size * sizeof(unsigned long));
>>>
>>> s/__memcpy/memcpy/
>>
>> memcpy should be instrumented by asan/tsan, and we would like to avoid
>> that instrumentation here.
>
> KASAN_SANITIZE_* :=3D n already takes care about this.
> __memcpy() is a special thing solely for kasan internals and some assembl=
y code.
> And it's not available generally.
>
>
>>>> +     if (unlikely(!smp_load_acquire(&next_slab_inited))) {
>>>> +             if (!preempt_count() && !in_irq()) {
>>>
>>> If you trying to detect atomic context here, than this doesn't work. E.=
g. you can't know
>>> about held spinlocks in non-preemptible kernel.
>>> And I'm not sure why need this. You know gfp flags here, so allocation =
in atomic context shouldn't be problem.
>>
>>
>> We don't have gfp flags for kfree.
>> I wonder how CONFIG_DEBUG_ATOMIC_SLEEP handles this. Maybe it has the an=
swer.
>
> It hasn't. It doesn't guarantee that atomic context always will be detect=
ed.
>
>> Alternatively, we can always assume that we are in atomic context in kfr=
ee.
>>
>
> Or do this allocation in separate context, put in work queue.
>
>>
>>
>>>> +                     alloc_flags &=3D (__GFP_RECLAIM | __GFP_IO | __G=
FP_FS |
>>>> +                             __GFP_NOWARN | __GFP_NORETRY |
>>>> +                             __GFP_NOMEMALLOC | __GFP_DIRECT_RECLAIM)=
;
>>>
>>> I think blacklist approach would be better here.
>>>
>>>> +                     page =3D alloc_pages(alloc_flags, STACK_ALLOC_OR=
DER);
>>>
>>> STACK_ALLOC_ORDER =3D 4 - that's a lot. Do you really need that much?
>>
>> Part of the issue the atomic context above. When we can't allocate
>> memory we still want to save the stack trace. When we have less than
>> STACK_ALLOC_ORDER memory, we try to preallocate another
>> STACK_ALLOC_ORDER in advance. So in the worst case, we have
>> STACK_ALLOC_ORDER memory and that should be enough to handle all
>> kmalloc/kfree in the atomic context. 1 page does not look enough. I
>> think Alex did some measuring of the failure race (when we are out of
>> memory and can't allocate more).
>>
>
> A lot of 4-order pages will lead to high fragmentation. You don't need ph=
ysically contiguous memory here,
> so try to use vmalloc(). It is slower, but fragmentation won't be problem=
.
I've tried using vmalloc(), but turned out it's calling KASAN hooks
again. Dealing with reentrancy in this case sounds like an overkill.
Given that we only require 9 Mb most of the time, is allocating
physical pages still a problem?

> And one more thing. Take a look at mempool, because it's generally used t=
o solve the problem you have here
> (guaranteed allocation in atomic context).
As far as I understood the docs, mempools have a drawback of
allocating too much memory which won't be available for any other use.
O'Reily's "Linux Device Drivers" even suggests not using mempools in
any case when it's easier to deal with allocation failures (that
advice is for device drivers, not sure if that stands for other
subsystems though).


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
