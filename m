Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 952026B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 09:49:57 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l68so20653928wml.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 06:49:57 -0800 (PST)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id s203si3090221wmf.100.2016.03.11.06.49.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 06:49:56 -0800 (PST)
Received: by mail-wm0-x22d.google.com with SMTP id l68so21960556wml.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 06:49:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56E2AF71.2050800@gmail.com>
References: <cover.1456504662.git.glider@google.com>
	<00e9fa7d4adeac2d37a42cf613837e74850d929a.1456504662.git.glider@google.com>
	<56D471F5.3010202@gmail.com>
	<CACT4Y+YPFEyuFdnM3_=2p1qANC7A1CKB0o1ySx2zexgE4kgVVw@mail.gmail.com>
	<56D58398.2010708@gmail.com>
	<CAG_fn=Xby+PJtMQtZ68gPkSPCyxbF=RsOCVavYew7ZVDx25yow@mail.gmail.com>
	<CAPAsAGzmFWCMEHhw=+15B1RO_7r3vUOMG0cZEPzQ=YcM5YP5MQ@mail.gmail.com>
	<CAG_fn=UhykNnE7L1dHA3LFbLb9tp-x0nZ4Z7joUk_-vvHDtX5g@mail.gmail.com>
	<56E2AF71.2050800@gmail.com>
Date: Fri, 11 Mar 2016 15:49:55 +0100
Message-ID: <CAG_fn=Xg7=vvPet8xcNiLZde_Y98OMuH-DjCgvrcxn7eMaARYQ@mail.gmail.com>
Subject: Re: [PATCH v4 5/7] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Dmitry Vyukov <dvyukov@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Mar 11, 2016 at 12:43 PM, Andrey Ryabinin
<ryabinin.a.a@gmail.com> wrote:
>
>
> On 03/11/2016 02:18 PM, Alexander Potapenko wrote:
>> On Thu, Mar 10, 2016 at 5:58 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com=
> wrote:
>>> 2016-03-08 14:42 GMT+03:00 Alexander Potapenko <glider@google.com>:
>>>> On Tue, Mar 1, 2016 at 12:57 PM, Andrey Ryabinin <ryabinin.a.a@gmail.c=
om> wrote:
>>>>>>>
>>>>>>>> +                     page =3D alloc_pages(alloc_flags, STACK_ALLO=
C_ORDER);
>>>>>>>
>>>>>>> STACK_ALLOC_ORDER =3D 4 - that's a lot. Do you really need that muc=
h?
>>>>>>
>>>>>> Part of the issue the atomic context above. When we can't allocate
>>>>>> memory we still want to save the stack trace. When we have less than
>>>>>> STACK_ALLOC_ORDER memory, we try to preallocate another
>>>>>> STACK_ALLOC_ORDER in advance. So in the worst case, we have
>>>>>> STACK_ALLOC_ORDER memory and that should be enough to handle all
>>>>>> kmalloc/kfree in the atomic context. 1 page does not look enough. I
>>>>>> think Alex did some measuring of the failure race (when we are out o=
f
>>>>>> memory and can't allocate more).
>>>>>>
>>>>>
>>>>> A lot of 4-order pages will lead to high fragmentation. You don't nee=
d physically contiguous memory here,
>>>>> so try to use vmalloc(). It is slower, but fragmentation won't be pro=
blem.
>>>> I've tried using vmalloc(), but turned out it's calling KASAN hooks
>>>> again. Dealing with reentrancy in this case sounds like an overkill.
>>>
>>> We'll have to deal with recursion eventually. Using stackdepot for
>>> page owner will cause recursion.
>>>
>>>> Given that we only require 9 Mb most of the time, is allocating
>>>> physical pages still a problem?
>>>>
>>>
>>> This is not about size, this about fragmentation. vmalloc allows to
>>> utilize available low-order pages,
>>> hence reduce the fragmentation.
>> I've attempted to add __vmalloc(STACK_ALLOC_SIZE, alloc_flags,
>> PAGE_KERNEL) (also tried vmalloc(STACK_ALLOC_SIZE)) instead of
>> page_alloc() and am now getting a crash in
>> kmem_cache_alloc_node_trace() in mm/slab.c, because it doesn't allow
>> the kmem_cache pointer to be NULL (it's dereferenced when calling
>> trace_kmalloc_node()).
>>
>> Steven, do you know if this because of my code violating some contract
>> (e.g. I'm calling vmalloc() too early, when kmalloc_caches[] haven't
>> been initialized),
>
> Probably. kmem_cache_init() goes before vmalloc_init().
The solution I'm currently testing is to introduce a per-CPU recursion
flag that depot_save_stack() checks and bails out if it's set.
In addition I look at |kmalloc_caches[KMALLOC_SHIFT_HIGH]| and
in_interrupt() to see if vmalloc() is available.
In the case it is not, I fall back to alloc_pages().

Right now (after 20 minutes of running Trinity) vmalloc() has been
called 490 times, alloc_pages() - only 13 times.
I hope it's now much better from the fragmentation point of view.
>
>> or is this a bug in kmem_cache_alloc_node_trace()
>> itself?
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
