Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A95026B02A4
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 07:29:31 -0400 (EDT)
Received: from eu_spt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0L5Y00AA2IL4UI@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 22 Jul 2010 12:29:28 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L5Y0044RIL3MW@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 22 Jul 2010 12:29:28 +0100 (BST)
Date: Thu, 22 Jul 2010 13:30:52 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
In-reply-to: <20100722105203.GD4737@rakim.wolfsonmicro.main>
Message-id: <op.vf8sxqro7p4s8u@pikus>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-transfer-encoding: Quoted-Printable
References: 
 <d6d104950c1391eaf3614d56615617cee5722fb4.1279639238.git.m.nazarewicz@samsung.com>
 <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com>
 <1279649724.26765.23.camel@c-dwalke-linux.qualcomm.com>
 <op.vf5o28st7p4s8u@pikus> <20100721135229.GC10930@sirena.org.uk>
 <op.vf66mxka7p4s8u@pikus> <20100721182457.GE10930@sirena.org.uk>
 <op.vf7h6ysh7p4s8u@pikus> <20100722090602.GF10930@sirena.org.uk>
 <000901cb297f$e28f2b10$a7ad8130$%szyprowski@samsung.com>
 <20100722105203.GD4737@rakim.wolfsonmicro.main>
Sender: owner-linux-mm@kvack.org
To: Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>
Cc: 'Daniel Walker' <dwalker@codeaurora.org>, linux-mm@kvack.org, Pawel Osciak <p.osciak@samsung.com>, 'Xiaolin Zhang' <xiaolin.zhang@intel.com>, 'Hiremath Vaibhav' <hvaibhav@ti.com>, 'Robert Fekete' <robert.fekete@stericsson.com>, 'Marcus Lorentzon' <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jul 2010 12:52:03 +0200, Mark Brown <broonie@opensource.wolfs=
onmicro.com> wrote:
> I'd expect that the devices would be able to reserve blocks of memory =
to
> play with separately to the actual allocations (ie, allocate regions
> like those on the command line) and things like the GPU would make use=

> of that.  I think you're already doing part of this?

In the patchset I've sent it is not possible but I already have a versio=
n that
supports this.  Regions can be registered at any time.  What's more, suc=
h
regions can be completely private to drivers that register them.

> Sure, but none of this is saying to me that it's specifically importan=
t
> to supply a static configuration via this textual configuration langua=
ge
> on the command line - half the problem is that you're trying to write
> the configuration down in a format which is fairly tightly constrained=

> by needing to be there.  If the configuration is more dynamic there's =
a
> lot more flexibility to either allow the system to figure things out
> dynamically (which will hopefully work a lot of the time, for example =
in
> your use case only the GPU really needs memory reserving).
>
> Remember also that if you can configure this at runtime (as you say
> you're working towards) then even if you have a fairly static
> configuration you can inject it into the kernel from the application
> layer rather than having to either hard code it in the image or bodge =
it
> in via the command line.  This keeps the resource allocation joined up=

> with the application layer (which is after all what determines the
> resource usage).

There are two command line arguments to consider: cma and cma_map.


The first one, I believe, should be there as to specify the regions
that are to be reserved.  Drivers and platform will still be able to
add their own regions but I believe that in vest majority of cases,
it will be enough to just pass the list of region on a command line.

Alternatively, instead of the textual description of platform could
provide an array of regions it want reserved.  It would remove like
50 lines of code from CMA core (in the version I have on my drive at
least, where part of the syntax was simplified) however it would
remove the possibility to easily change the configuration from
command line (ie. no need to recompile which is handy when you need
to optimise this and test various configurations) and would add more
code to the platform initialisation code, ie: instead of:

	cma_defaults("reg1=3D20M;reg2=3D20M", NULL);

one would have to define an array with the regions descriptors.
Personally, I don't see much benefits from this.


As of the second parameter, "cma_map", which validating and parsing
is like 150 lines of code, I consider it handy because you can manage
all the memory regions in one place and it moves some of the complexity
 from device drivers to CMA.  I'm also working on providing a sysfs
entry so that the it would be possible to change the mapping at runtime.=


For example, consider a driver I have mentioned before: video decoder
that needs to allocate memory from 3 different regions (for firmware,
the first bank of memory and the second bank of memory).  With CMA you
define the regions:

	cma=3Dvf=3D1M/128K;a=3D20M;b=3D20M@512M;

and then map video driver to them like so:

	cma_map=3Dvideo/a=3Da;video/b=3Db;video/f=3Dvf

I agree that parsing it is not nice but thanks to it, all you need to
do in the driver is:

	cma_alloc(dev, "a", ...)
	cma_alloc(dev, "b", ...)
	cma_alloc(dev, "f", ...)

Without cma_map you'd have to pass names of the region to the driver
and make the driver use those.

It would also make it impossible or hard to change the mapping once
the driver is loaded.


What I'm trying to say is that I'm trying to move complexity out of
the drivers into the framework (as I believe that's what frameworks
are for).


As of dynamic, runtime, automatic configuration, I don't really see
that.  I'm still wondering how to make as little configuration
necessary as possible but I don't think everything can be done
in such a way.

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
