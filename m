Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 83EB16B0005
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 08:22:28 -0400 (EDT)
Received: by mail-lb0-f174.google.com with SMTP id x1so20103923lbj.3
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 05:22:28 -0700 (PDT)
Received: from mail-lb0-x22a.google.com (mail-lb0-x22a.google.com. [2a00:1450:4010:c04::22a])
        by mx.google.com with ESMTPS id qk4si12845412lbb.210.2016.03.15.05.22.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Mar 2016 05:22:26 -0700 (PDT)
Received: by mail-lb0-x22a.google.com with SMTP id x1so20103227lbj.3
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 05:22:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAG_fn=WNy=wyA5LFJO8Kg7kK9m7LC9AkNHkYxwjdrQjzyK4uoQ@mail.gmail.com>
References: <cover.1457949315.git.glider@google.com>
	<4f6880ee0c1545b3ae9c25cfe86a879d724c4e7b.1457949315.git.glider@google.com>
	<CAPAsAGx58NuvRB7=qeXr27VFE8PoabLxvNGVGP66MV1WkhDA+g@mail.gmail.com>
	<CAG_fn=WNy=wyA5LFJO8Kg7kK9m7LC9AkNHkYxwjdrQjzyK4uoQ@mail.gmail.com>
Date: Tue, 15 Mar 2016 15:22:26 +0300
Message-ID: <CAPAsAGzo5VTmi1-bMdmCQmG06rjdfk+vt1i0Fv6eFXd7s+a2LQ@mail.gmail.com>
Subject: Re: [PATCH v7 5/7] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2016-03-15 12:27 GMT+03:00 Alexander Potapenko <glider@google.com>:
> On Mon, Mar 14, 2016 at 5:56 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com>=
 wrote:
>> 2016-03-14 13:43 GMT+03:00 Alexander Potapenko <glider@google.com>:
>>
>>> +
>>> +       rec =3D this_cpu_ptr(&depot_recursion);
>>> +       /* Don't store the stack if we've been called recursively. */
>>> +       if (unlikely(*rec))
>>> +               goto fast_exit;
>>> +       *rec =3D true;
>>
>>
>> This just can't work. As long as preemption enabled, task could
>> migrate on another cpu anytime.
> Ah, you're right.
> Do you think disabling preemption around memory allocation is an option h=
ere?

It's definitely not an option. Flag on current doesn't have any
disadvantage over per-cpu approach
and it doesn't require preemption safe context.
However, making the allocation in a separate context would be a better
way to eliminate recursion.
i.e. instead of allocating memory depot_save_stack() kicks a work
which allocates memory.


>> You could use per-task flag, although it's possible to miss some
>> in-irq stacktraces:
>>
>> depot_save_stack()
>>     if (current->stackdeport_recursion)
>>           goto fast_exit;
>>     current->stackdepot_recursion++
>>     <IRQ>
>>            ....
>>            depot_save_stack()
>>                  if (current->stackdeport_recursion)
>>                       goto fast_exit;
>>
>>
>>
>>> +       if (unlikely(!smp_load_acquire(&next_slab_inited))) {
>>> +               /* Zero out zone modifiers, as we don't have specific z=
one
>>> +                * requirements. Keep the flags related to allocation i=
n atomic
>>> +                * contexts and I/O.
>>> +                */
>>> +               alloc_flags &=3D ~GFP_ZONEMASK;
>>> +               alloc_flags &=3D (GFP_ATOMIC | GFP_KERNEL);
>>> +               /* When possible, allocate using vmalloc() to reduce ph=
ysical
>>> +                * address space fragmentation. vmalloc() doesn't work =
if
>>> +                * kmalloc caches haven't been initialized or if it's b=
eing
>>> +                * called from an interrupt handler.
>>> +                */
>>> +               if (kmalloc_caches[KMALLOC_SHIFT_HIGH] && !in_interrupt=
()) {
>>
>> This is clearly a wrong way to check whether is slab available or not.
> Well, I don't think either vmalloc() or kmalloc() provide any
> interface to check if they are available.
>
>> Besides you need to check
>> vmalloc() for availability, not slab.
> The problem was in kmalloc caches being unavailable, although I can
> imagine other problems could have arose.
> Perhaps we can drill a hole to get the value of vmap_initialized?
>> Given that STAC_ALLOC_ORDER is 2 now, I think it should be fine to use
>> alloc_pages() all the time.
>> Or fix condition, up to you.
> Ok, I'm going to drop vmalloc() for now, we can always implement this lat=
er.
> Note that this also removes the necessity to check for recursion.
>>> +                       prealloc =3D __vmalloc(
>>> +                               STACK_ALLOC_SIZE, alloc_flags, PAGE_KER=
NEL);
>>> +               } else {
>>> +                       page =3D alloc_pages(alloc_flags, STACK_ALLOC_O=
RDER);
>>> +                       if (page)
>>> +                               prealloc =3D page_address(page);
>>> +               }
>>> +       }
>>> +
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
