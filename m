Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C951D6B02A4
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 14:09:20 -0400 (EDT)
Received: from eu_spt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0L5X00B6L6HHIO@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 21 Jul 2010 19:10:29 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L5X001106HHCF@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Jul 2010 19:10:29 +0100 (BST)
Date: Wed, 21 Jul 2010 20:11:53 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
In-reply-to: <1279733750.31376.14.camel@c-dwalke-linux.qualcomm.com>
Message-id: <op.vf7gt3qy7p4s8u@pikus>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-transfer-encoding: Quoted-Printable
References: <cover.1279639238.git.m.nazarewicz@samsung.com>
 <d6d104950c1391eaf3614d56615617cee5722fb4.1279639238.git.m.nazarewicz@samsung.com>
 <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com>
 <1279649724.26765.23.camel@c-dwalke-linux.qualcomm.com>
 <op.vf5o28st7p4s8u@pikus>
 <1279654698.26765.31.camel@c-dwalke-linux.qualcomm.com>
 <op.vf6zo9vb7p4s8u@pikus>
 <1279733750.31376.14.camel@c-dwalke-linux.qualcomm.com>
Sender: owner-linux-mm@kvack.org
To: Daniel Walker <dwalker@codeaurora.org>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Pawel Osciak <p.osciak@samsung.com>, Xiaolin Zhang <xiaolin.zhang@intel.com>, Hiremath Vaibhav <hvaibhav@ti.com>, Robert Fekete <robert.fekete@stericsson.com>, Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jul 2010 19:35:50 +0200, Daniel Walker <dwalker@codeaurora.or=
g> wrote:

> On Wed, 2010-07-21 at 14:01 +0200, Micha=C5=82 Nazarewicz wrote:
>
>> What you are asking for is:
>>
>> 	cma=3Da=3D100M cma_map=3D*/*=3Da
>>
>> All devices will share the same region so that "if the video driver i=
sn't
>> using the memory" then "something else can use it". (please excuse me=
 quoting
>> you, it was stronger then me ;) ).
>
> Ok ..
>
>> Driver has to little information to say whether it really stopped usi=
ng
>> memory.  Maybe the next call will be to allocate buffers for frames a=
nd
>> initialise the chip?  Sure, some =E2=80=9Cgood enough=E2=80=9D defaul=
ts can be provided
>> (and the framework allows that) but still platform architect might ne=
ed
>> more power.
>
> I think your talking more about optimization .. You can take that into=

> account ..

Well, yes, that's one of the points: to minimise amount of memory reserv=
ed
for devices.

>> > (btw, these strings your creating yikes, talk about confusing ..)
>>
>> They are not that scary really.  Let's look at cma:
>>
>> 	a=3D10M;b=3D10M
>>
>> Split it on semicolon:
>>
>> 	a=3D10M
>> 	b=3D10M
>>
>> and you see that it defines two regions (a and b) 10M each.
>
> I think your assuming a lot .. I've never seen the notation before I
> wouldn't assuming there's regions or whatever ..

That's why there is documentation with grammar included. :)

>> As of cma_map:
>>
>> 	camera,video=3Da;jpeg,scaler=3Db
>>
>> Again split it on semicolon:
>>
>> 	camera,video=3Da
>> 	jpeg,scaler=3Db
>>
>> Now, substitute equal sign by "use(s) region(s)":
>>
>> 	camera,video	use(s) region(s):	a
>> 	jpeg,scaler	use(s) region(s):	b
>>
>> No black magic here. ;)
>
> It way too complicated .. Users (i.e. not programmers) has to use
> this ..

Not really.  This will probably be used mostly on embedded systems
where users don't have much to say as far as hardware included on the
platform is concerned, etc.  Once a phone, tablet, etc. is released
users will have little need for customising those strings.

On desktop computers on the other hand, the whole framework may be
completely useless as devices are more likely to have IO map or scatter/=
getter
capabilities.

Plus, as I mentioned above, some =E2=80=9Cgood enough=E2=80=9D defaults =
can be provided.

>> >> One of the purposes of the CMA framework is to make it let device
>> >> drivers completely forget about the memory management and enjoy
>> >> a simple API.
>> >
>> > The driver, and it's maintainer, are really the best people to know=
 how
>> > much memory they need and when it's used/unused. You don't really w=
ant
>> > to architect them out.
>>
>> This might be true if there is only one device but even then it's not=

>> always the case.  If many devices need physically-contiguous memory
>> there is no way for them to communicate and share memory.  For best
>> performance someone must look at them and say who gets what.
>
> How do you think regular memory allocation work? I mean there's many
> devices that all need different amounts of memory and they get along.
> Yet your saying it's not possible .

Regular memory allocation either does not allow you to allocate big chun=
ks
of memory (kmalloc) or uses MMU (vmalloc).  The purpose of CMA is to pro=
vide
a framework for allocators of big physically-contiguous chunks of memory=
.

If a driver needs several KiB it just uses kmalloc() which handles such
allocations just fine.  However, we are taking about 6MiB full-HD frame
or a photo from 5 megapixel camera.

Currently, drivers are developed which create their own mechanism for
allocating such chunks of memory.  Often based on bootmem.  CMA will uni=
fy
all those mechanism and let it easier to manage them plus will allow for=

many drivers to share regions.

-- =

Best regards,                                        _     _
| Humble Liege of Serenely Enlightened Majesty of  o' \,=3D./ `o
| Computer Science,  Micha=C5=82 "mina86" Nazarewicz       (o o)
+----[mina86*mina86.com]---[mina86*jabber.org]----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
