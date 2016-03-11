Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6CB6D6B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 12:12:41 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id p65so25892881wmp.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 09:12:41 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id b77si3756428wmf.115.2016.03.11.09.12.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 09:12:40 -0800 (PST)
Received: by mail-wm0-x22e.google.com with SMTP id l68so25909326wml.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 09:12:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAG_fn=UkgkHw5Ed72hPkYYzhXcH5gy5ubTeS8SvggvzZDxFdJw@mail.gmail.com>
References: <cover.1457519440.git.glider@google.com>
	<bdd59cc00ee49b7849ad60a11c6a4704c3e4856b.1457519440.git.glider@google.com>
	<20160309122148.1250854b862349399591dabf@linux-foundation.org>
	<CAG_fn=UkgkHw5Ed72hPkYYzhXcH5gy5ubTeS8SvggvzZDxFdJw@mail.gmail.com>
Date: Fri, 11 Mar 2016 18:12:39 +0100
Message-ID: <CAG_fn=Xo3BGbik8H9mfaQhXFdseZkqyyDz4c_4Ji-TCqT0kuZg@mail.gmail.com>
Subject: Re: [PATCH v5 7/7] mm: kasan: Initial memory quarantine implementation
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Mar 10, 2016 at 2:50 PM, Alexander Potapenko <glider@google.com> wr=
ote:
> On Wed, Mar 9, 2016 at 9:21 PM, Andrew Morton <akpm@linux-foundation.org>=
 wrote:
>> On Wed,  9 Mar 2016 12:05:48 +0100 Alexander Potapenko <glider@google.co=
m> wrote:
>>
>>> Quarantine isolates freed objects in a separate queue. The objects are
>>> returned to the allocator later, which helps to detect use-after-free
>>> errors.
>>
>> I'd like to see some more details on precisely *how* the parking of
>> objects in the qlists helps "detect use-after-free"?
> When the object is freed, its state changes from KASAN_STATE_ALLOC to
> KASAN_STATE_QUARANTINE. The object is poisoned and put into quarantine
> instead of being returned to the allocator, therefore every subsequent
> access to that object triggers a KASAN error, and the error handler is
> able to say where the object has been allocated and deallocated.
> When it's time for the object to leave quarantine, its state becomes
> KASAN_STATE_FREE and it's returned to the allocator. From now on the
> allocator may reuse it for another allocation.
> Before that happens, it's still possible to detect a use-after free on
> that object (it retains the allocation/deallocation stacks).
> When the allocator reuses this object, the shadow is unpoisoned and
> old allocation/deallocation stacks are wiped. Therefore a use of this
> object, even an incorrect one, won't trigger ASan warning.
> Without the quarantine, it's not guaranteed that the objects aren't
> reused immediately, that's why the probability of catching a
> use-after-free is lower than with quarantine in place.
>
>>> Freed objects are first added to per-cpu quarantine queues.
>>> When a cache is destroyed or memory shrinking is requested, the objects
>>> are moved into the global quarantine queue. Whenever a kmalloc call
>>> allows memory reclaiming, the oldest objects are popped out of the
>>> global queue until the total size of objects in quarantine is less than
>>> 3/4 of the maximum quarantine size (which is a fraction of installed
>>> physical memory).
>>>
>>> Right now quarantine support is only enabled in SLAB allocator.
>>> Unification of KASAN features in SLAB and SLUB will be done later.
>>>
>>> This patch is based on the "mm: kasan: quarantine" patch originally
>>> prepared by Dmitry Chernenkov.
>>>
>>
>> qlists look awfully like list_heads.  Some explanation of why a new
>> container mechanism was needed would be good to see - wht are existing
>> ones unsuitable?
> Most of the code in quarantine.c is actually the code that moves the
> queues around (merges them, frees a given portion of the quarantine,
> filters the elements belonging to a specific cache) and calculates the
> sizes. I don't think there're off-the-shelf solutions for this.
> qlist is a FIFO queue that keeps pointers to the head and the tail of
> a linked list. That's semantically different from list_head.
> There's include/linux/kfifo.h, but that also appears to be completely dif=
ferent.
>
>>
>>>
>>> ...
>>>
>>> +void kasan_cache_shrink(struct kmem_cache *cache)
>>> +{
>>> +#ifdef CONFIG_SLAB
>>> +     quarantine_remove_cache(cache);
>>> +#endif
>>> +}
>>> +
>>> +void kasan_cache_destroy(struct kmem_cache *cache)
>>> +{
>>> +#ifdef CONFIG_SLAB
>>> +     quarantine_remove_cache(cache);
>>> +#endif
>>> +}
>>
>> We could avoid th4ese ifdefs in the usual way: an empty version of
>> quarantine_remove_cache() if CONFIG_SLAB=3Dn.
After thinking a while, I don't think it's necessary to get rid of
these ifdefs right now.
Right now the kernel depends on mm/kasan/quarantine.c iff CONFIG_SLAB is on=
.
If we declare empty quarantine_remove_cache() and friends, we'll have
to either do it in slub.c (and then remove it after we make SLUB also
use quarantine), or add the dependency on quarantine.c and put the
ifdefs there.
Given that the number of ifdefs is small, and I'm planning to
follow-up with a patch that switches SLUB to using quarantine, I
suppose it should be fine to keep the ifdefs for the transition
period.
Hope you're fine with that.
> Yes, agreed.
> I am sorry, I don't fully understand the review process now, when
> you've pulled the patches into mm-tree.
> Shall I send the new patch series version, as before, or is anything
> else needs to be done?
> Do I need to rebase against mm- or linux-next? Thanks in advance.
>>>
>>> ...
>>>
>>> @@ -493,6 +532,11 @@ void kasan_kmalloc(struct kmem_cache *cache, const=
 void *object, size_t size,
>>>       unsigned long redzone_start;
>>>       unsigned long redzone_end;
>>>
>>> +#ifdef CONFIG_SLAB
>>> +     if (flags & __GFP_RECLAIM)
>>> +             quarantine_reduce();
>>> +#endif
>>
>> Here also.
> Ack.
>>
>>>       if (unlikely(object =3D=3D NULL))
>>>               return;
>>>
>>> --- /dev/null
>>> +++ b/mm/kasan/quarantine.c
>>> @@ -0,0 +1,306 @@
>>> +/*
>>> + * KASAN quarantine.
>>> + *
>>> + * Author: Alexander Potapenko <glider@google.com>
>>> + * Copyright (C) 2016 Google, Inc.
>>> + *
>>> + * Based on code by Dmitry Chernenkov.
>>> + *
>>> + * This program is free software; you can redistribute it and/or
>>> + * modify it under the terms of the GNU General Public License
>>> + * version 2 as published by the Free Software Foundation.
>>> + *
>>> + * This program is distributed in the hope that it will be useful, but
>>> + * WITHOUT ANY WARRANTY; without even the implied warranty of
>>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
>>> + * General Public License for more details.
>>> + *
>>> + */
>>> +
>>> +#include <linux/gfp.h>
>>> +#include <linux/hash.h>
>>> +#include <linux/kernel.h>
>>> +#include <linux/mm.h>
>>> +#include <linux/percpu.h>
>>> +#include <linux/printk.h>
>>> +#include <linux/shrinker.h>
>>> +#include <linux/slab.h>
>>> +#include <linux/string.h>
>>> +#include <linux/types.h>
>>> +
>>> +#include "../slab.h"
>>> +#include "kasan.h"
>>> +
>>> +/* Data structure and operations for quarantine queues. */
>>> +
>>> +/* Each queue is a signled-linked list, which also stores the total si=
ze of
>>
>> tpyo
> Ack.
>>
>>> + * objects inside of it.
>>> + */
>>> +struct qlist {
>>> +     void **head;
>>> +     void **tail;
>>> +     size_t bytes;
>>> +};
>>> +
>>> +#define QLIST_INIT { NULL, NULL, 0 }
>>> +
>>> +static inline bool empty_qlist(struct qlist *q)
>>> +{
>>> +     return !q->head;
>>> +}
>>
>> Should be "qlist_empty()".
> Ack.
>>
>>> +static inline void init_qlist(struct qlist *q)
>>> +{
>>> +     q->head =3D q->tail =3D NULL;
>>> +     q->bytes =3D 0;
>>> +}
>>
>> "qlist_init()"
> Ack.
>>
>>> +static inline void qlist_put(struct qlist *q, void **qlink, size_t siz=
e)
>>> +{
>>> +     if (unlikely(empty_qlist(q)))
>>> +             q->head =3D qlink;
>>> +     else
>>> +             *q->tail =3D qlink;
>>> +     q->tail =3D qlink;
>>> +     *qlink =3D NULL;
>>> +     q->bytes +=3D size;
>>> +}
>>> +
>>> +static inline void **qlist_remove(struct qlist *q, void ***prev,
>>> +                              size_t size)
>>> +{
>>> +     void **qlink =3D *prev;
>>> +
>>> +     *prev =3D *qlink;
>>> +     if (q->tail =3D=3D qlink) {
>>> +             if (q->head =3D=3D qlink)
>>> +                     q->tail =3D NULL;
>>> +             else
>>> +                     q->tail =3D (void **)prev;
>>> +     }
>>> +     q->bytes -=3D size;
>>> +
>>> +     return qlink;
>>> +}
>>> +
>>> +static inline void qlist_move_all(struct qlist *from, struct qlist *to=
)
>>> +{
>>> +     if (unlikely(empty_qlist(from)))
>>> +             return;
>>> +
>>> +     if (empty_qlist(to)) {
>>> +             *to =3D *from;
>>> +             init_qlist(from);
>>> +             return;
>>> +     }
>>> +
>>> +     *to->tail =3D from->head;
>>> +     to->tail =3D from->tail;
>>> +     to->bytes +=3D from->bytes;
>>> +
>>> +     init_qlist(from);
>>> +}
>>> +
>>> +static inline void qlist_move(struct qlist *from, void **last, struct =
qlist *to,
>>> +                       size_t size)
>>> +{
>>> +     if (unlikely(last =3D=3D from->tail)) {
>>> +             qlist_move_all(from, to);
>>> +             return;
>>> +     }
>>> +     if (empty_qlist(to))
>>> +             to->head =3D from->head;
>>> +     else
>>> +             *to->tail =3D from->head;
>>> +     to->tail =3D last;
>>> +     from->head =3D *last;
>>> +     *last =3D NULL;
>>> +     from->bytes -=3D size;
>>> +     to->bytes +=3D size;
>>> +}
>>
>> The above code is a candidate for hoisting out into a generic library
>> facility, so let's impement it that way (ie: get the naming right).
> Ack.
>> All the inlining looks excessive, and the compiler will defeat it
>> anyway if it thinks that is best.
> Ack.
>>>
>>> ...
>>>
>>
>>
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
