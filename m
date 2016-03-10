Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id B41286B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 11:58:42 -0500 (EST)
Received: by mail-lb0-f174.google.com with SMTP id xr8so116034740lbb.1
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 08:58:42 -0800 (PST)
Received: from mail-lb0-x22f.google.com (mail-lb0-x22f.google.com. [2a00:1450:4010:c04::22f])
        by mx.google.com with ESMTPS id v199si2256910lfd.235.2016.03.10.08.58.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 08:58:39 -0800 (PST)
Received: by mail-lb0-x22f.google.com with SMTP id xr8so116033181lbb.1
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 08:58:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAG_fn=Xby+PJtMQtZ68gPkSPCyxbF=RsOCVavYew7ZVDx25yow@mail.gmail.com>
References: <cover.1456504662.git.glider@google.com>
	<00e9fa7d4adeac2d37a42cf613837e74850d929a.1456504662.git.glider@google.com>
	<56D471F5.3010202@gmail.com>
	<CACT4Y+YPFEyuFdnM3_=2p1qANC7A1CKB0o1ySx2zexgE4kgVVw@mail.gmail.com>
	<56D58398.2010708@gmail.com>
	<CAG_fn=Xby+PJtMQtZ68gPkSPCyxbF=RsOCVavYew7ZVDx25yow@mail.gmail.com>
Date: Thu, 10 Mar 2016 19:58:37 +0300
Message-ID: <CAPAsAGzmFWCMEHhw=+15B1RO_7r3vUOMG0cZEPzQ=YcM5YP5MQ@mail.gmail.com>
Subject: Re: [PATCH v4 5/7] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2016-03-08 14:42 GMT+03:00 Alexander Potapenko <glider@google.com>:
> On Tue, Mar 1, 2016 at 12:57 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com>=
 wrote:
>>>>
>>>>> +                     page =3D alloc_pages(alloc_flags, STACK_ALLOC_O=
RDER);
>>>>
>>>> STACK_ALLOC_ORDER =3D 4 - that's a lot. Do you really need that much?
>>>
>>> Part of the issue the atomic context above. When we can't allocate
>>> memory we still want to save the stack trace. When we have less than
>>> STACK_ALLOC_ORDER memory, we try to preallocate another
>>> STACK_ALLOC_ORDER in advance. So in the worst case, we have
>>> STACK_ALLOC_ORDER memory and that should be enough to handle all
>>> kmalloc/kfree in the atomic context. 1 page does not look enough. I
>>> think Alex did some measuring of the failure race (when we are out of
>>> memory and can't allocate more).
>>>
>>
>> A lot of 4-order pages will lead to high fragmentation. You don't need p=
hysically contiguous memory here,
>> so try to use vmalloc(). It is slower, but fragmentation won't be proble=
m.
> I've tried using vmalloc(), but turned out it's calling KASAN hooks
> again. Dealing with reentrancy in this case sounds like an overkill.

We'll have to deal with recursion eventually. Using stackdepot for
page owner will cause recursion.

> Given that we only require 9 Mb most of the time, is allocating
> physical pages still a problem?
>

This is not about size, this about fragmentation. vmalloc allows to
utilize available low-order pages,
hence reduce the fragmentation.

>> And one more thing. Take a look at mempool, because it's generally used =
to solve the problem you have here
>> (guaranteed allocation in atomic context).
> As far as I understood the docs, mempools have a drawback of
> allocating too much memory which won't be available for any other use.

As far as I understood your code, it has a drawback of
allocating too much memory which won't be available for any other use ;)

However, now I think that mempool doesn't fit here. We never free
memory =3D> never return it to pool.
And this will cause 5sec delays between allocation retries in mempool_alloc=
().


> O'Reily's "Linux Device Drivers" even suggests not using mempools in
> any case when it's easier to deal with allocation failures (that
> advice is for device drivers, not sure if that stands for other
> subsystems though).
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
