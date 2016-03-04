Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 376A66B0254
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 10:06:44 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id p65so32808575wmp.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 07:06:44 -0800 (PST)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id h8si4391306wmh.59.2016.03.04.07.06.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 07:06:43 -0800 (PST)
Received: by mail-wm0-x22c.google.com with SMTP id n186so38932093wmn.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 07:06:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPAsAGyoCmSGHNj3EJ-1TRonzR3-7A3Jk4+99NNQ4bfS6xXYvA@mail.gmail.com>
References: <cover.1456504662.git.glider@google.com>
	<00e9fa7d4adeac2d37a42cf613837e74850d929a.1456504662.git.glider@google.com>
	<56D471F5.3010202@gmail.com>
	<CACT4Y+YPFEyuFdnM3_=2p1qANC7A1CKB0o1ySx2zexgE4kgVVw@mail.gmail.com>
	<56D58398.2010708@gmail.com>
	<CAG_fn=Ux-_FaVR1sQ0457kKHAGLWEMUuFpPr-UF_GwjkqpdSnQ@mail.gmail.com>
	<CAPAsAGyoCmSGHNj3EJ-1TRonzR3-7A3Jk4+99NNQ4bfS6xXYvA@mail.gmail.com>
Date: Fri, 4 Mar 2016 16:06:42 +0100
Message-ID: <CAG_fn=XfqNjTry+kyXHVXNRX1Y7LL5=WTmAkNPzTg7XeR7DLww@mail.gmail.com>
Subject: Re: [PATCH v4 5/7] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Mar 4, 2016 at 4:01 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com> wr=
ote:
> 2016-03-04 17:52 GMT+03:00 Alexander Potapenko <glider@google.com>:
>> On Tue, Mar 1, 2016 at 12:57 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com=
> wrote:
>>>
>>>
>>> On 02/29/2016 08:12 PM, Dmitry Vyukov wrote:
>>>
>>>>>> diff --git a/lib/Makefile b/lib/Makefile
>>>>>> index a7c26a4..10a4ae3 100644
>>>>>> --- a/lib/Makefile
>>>>>> +++ b/lib/Makefile
>>>>>> @@ -167,6 +167,13 @@ obj-$(CONFIG_SG_SPLIT) +=3D sg_split.o
>>>>>>  obj-$(CONFIG_STMP_DEVICE) +=3D stmp_device.o
>>>>>>  obj-$(CONFIG_IRQ_POLL) +=3D irq_poll.o
>>>>>>
>>>>>> +ifeq ($(CONFIG_KASAN),y)
>>>>>> +ifeq ($(CONFIG_SLAB),y)
>>>>>
>>>>> Just try to imagine that another subsystem wants to use stackdepot. H=
ow this gonna look like?
>>>>>
>>>>> We have Kconfig to describe dependencies. So, this should be under CO=
NFIG_STACKDEPOT.
>>>>> So any user of this feature can just do 'select STACKDEPOT' in Kconfi=
g.
>>>>>
>>>>>> +     obj-y   +=3D stackdepot.o
>>>>>> +     KASAN_SANITIZE_slub.o :=3D n
>>>                         _stackdepot.o
>>>
>>>
>>>>>
>>>>>> +
>>>>>> +     stack->hash =3D hash;
>>>>>> +     stack->size =3D size;
>>>>>> +     stack->handle.slabindex =3D depot_index;
>>>>>> +     stack->handle.offset =3D depot_offset >> STACK_ALLOC_ALIGN;
>>>>>> +     __memcpy(stack->entries, entries, size * sizeof(unsigned long)=
);
>>>>>
>>>>> s/__memcpy/memcpy/
>>>>
>>>> memcpy should be instrumented by asan/tsan, and we would like to avoid
>>>> that instrumentation here.
>>>
>>> KASAN_SANITIZE_* :=3D n already takes care about this.
>>> __memcpy() is a special thing solely for kasan internals and some assem=
bly code.
>>> And it's not available generally.
>> As far as I can see, KASAN_SANITIZE_*:=3Dn does not guarantee it.
>> It just removes KASAN flags from GCC command line, it does not
>> necessarily replace memcpy() calls with some kind of a
>> non-instrumented memcpy().
>>
>
> With removed kasan cflags '__SANITIZE_ADDRESS__' is not defined,
> hence enable the following defines from arch/x86/include/asm/string_64.h:
>
> #if defined(CONFIG_KASAN) && !defined(__SANITIZE_ADDRESS__)
>
> /*
>  * For files that not instrumented (e.g. mm/slub.c) we
>  * should use not instrumented version of mem* functions.
>  */
>
> #undef memcpy
> #define memcpy(dst, src, len) __memcpy(dst, src, len)
> #define memmove(dst, src, len) __memmove(dst, src, len)
> #define memset(s, c, n) __memset(s, c, n)
> #endif
Nice!
What do you think about providing stub .c files to decouple the shared
code used by KASAN runtime from the rest of kernel?
(This is a completely different story though and can be done separately).


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
