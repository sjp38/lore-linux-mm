Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B13906B024D
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 09:23:06 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from eu_spt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L5Y00J4GNUDQY80@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 22 Jul 2010 14:23:01 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L5Y005EYNUD8M@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 22 Jul 2010 14:23:01 +0100 (BST)
Date: Thu, 22 Jul 2010 15:24:26 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
In-reply-to: <20100722124559.GH4737@rakim.wolfsonmicro.main>
Message-id: <op.vf8x60wi7p4s8u@pikus>
Content-transfer-encoding: Quoted-Printable
References: <1279649724.26765.23.camel@c-dwalke-linux.qualcomm.com>
 <op.vf5o28st7p4s8u@pikus> <20100721135229.GC10930@sirena.org.uk>
 <op.vf66mxka7p4s8u@pikus> <20100721182457.GE10930@sirena.org.uk>
 <op.vf7h6ysh7p4s8u@pikus> <20100722090602.GF10930@sirena.org.uk>
 <000901cb297f$e28f2b10$a7ad8130$%szyprowski@samsung.com>
 <20100722105203.GD4737@rakim.wolfsonmicro.main> <op.vf8sxqro7p4s8u@pikus>
 <20100722124559.GH4737@rakim.wolfsonmicro.main>
Sender: owner-linux-mm@kvack.org
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, 'Daniel Walker' <dwalker@codeaurora.org>, linux-mm@kvack.org, Pawel Osciak <p.osciak@samsung.com>, 'Xiaolin Zhang' <xiaolin.zhang@intel.com>, 'Hiremath Vaibhav' <hvaibhav@ti.com>, 'Robert Fekete' <robert.fekete@stericsson.com>, 'Marcus Lorentzon' <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Thu, Jul 22, 2010 at 01:30:52PM +0200, Micha=C5=82 Nazarewicz wrote=
:
>> The first one, I believe, should be there as to specify the regions
>> that are to be reserved.  Drivers and platform will still be able to
>> add their own regions but I believe that in vest majority of cases,
>> it will be enough to just pass the list of region on a command line.

On Thu, 22 Jul 2010 14:46:00 +0200, Mark Brown <broonie@opensource.wolfs=
onmicro.com> wrote:
> The command line is a real pain for stuff like this since it's not
> usually committed to revision control so robustly and it's normally mo=
re
> painful to change the bootloader to pass the desired command line in
> than it is to change either the kernel or userspace (some bootloaders
> are just completely unconfigurable without reflashing, and if your onl=
y
> recovery mechanism is JTAG that can be a bit of a concern).

That's why command line is only intended as a way to overwrite the
defaults which are provided by the platform.  In a final product,
configuration should be specified in platform code and not on
command line.

>> Alternatively, instead of the textual description of platform could
>> provide an array of regions it want reserved.  It would remove like
>> 50 lines of code from CMA core (in the version I have on my drive at
>> least, where part of the syntax was simplified) however it would
>> remove the possibility to easily change the configuration from
>> command line (ie. no need to recompile which is handy when you need
>> to optimise this and test various configurations) and would add more
>> code to the platform initialisation code, ie: instead of:
>>
>> 	cma_defaults("reg1=3D20M;reg2=3D20M", NULL);
>
>> one would have to define an array with the regions descriptors.
>> Personally, I don't see much benefits from this.
>
> I think it'd be vastly more legible, especially if the list of regions=

> gets large.  I had thought the only reason for the text format was to
> put it onto the command line.

Command line was one of the reasons for using textual interface.  I sure=
ly
wouldn't go with parsing the strings if I could manage without it allowi=
ng
easy platform-level configuration at the same time.

>> I agree that parsing it is not nice but thanks to it, all you need to=

>> do in the driver is:
>>
>> 	cma_alloc(dev, "a", ...)
>> 	cma_alloc(dev, "b", ...)
>> 	cma_alloc(dev, "f", ...)
>>
>> Without cma_map you'd have to pass names of the region to the driver
>> and make the driver use those.
>
> I agree that a mapping facility for the names is essential, especially=

> if drivers need to share regions.
>
>> What I'm trying to say is that I'm trying to move complexity out of
>> the drivers into the framework (as I believe that's what frameworks
>> are for).
>
> It sounds like apart from the way you're passing the configuration in
> you're doing roughly what I'd suggest.  I'd expect that in a lot of
> cases the map could be satisfied from the default region so there'd be=

> no need to explicitly set one up.

Platform can specify something like:

	cma_defaults("reg=3D20M", "*/*=3Dreg");

which would make all the drivers share 20 MiB region by default.  I'm al=
so
thinking if something like:

	cma_defaults("reg=3D20M", "*/*=3D*");

(ie. asterisk instead of list of regions) should be allowed.  It would m=
ake
the default to be that all allocations are performed from all named regi=
ons.
I'll see how much coding is that and maybe add it.

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
