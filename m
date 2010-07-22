Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 989526B02A5
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 06:52:07 -0400 (EDT)
Date: Thu, 22 Jul 2010 11:52:03 +0100
From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
Message-ID: <20100722105203.GD4737@rakim.wolfsonmicro.main>
References: <d6d104950c1391eaf3614d56615617cee5722fb4.1279639238.git.m.nazarewicz@samsung.com>
 <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com>
 <1279649724.26765.23.camel@c-dwalke-linux.qualcomm.com>
 <op.vf5o28st7p4s8u@pikus>
 <20100721135229.GC10930@sirena.org.uk>
 <op.vf66mxka7p4s8u@pikus>
 <20100721182457.GE10930@sirena.org.uk>
 <op.vf7h6ysh7p4s8u@pikus>
 <20100722090602.GF10930@sirena.org.uk>
 <000901cb297f$e28f2b10$a7ad8130$%szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000901cb297f$e28f2b10$a7ad8130$%szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Michal Nazarewicz <m.nazarewicz@samsung.com>, 'Daniel Walker' <dwalker@codeaurora.org>, linux-mm@kvack.org, Pawel Osciak <p.osciak@samsung.com>, 'Xiaolin Zhang' <xiaolin.zhang@intel.com>, 'Hiremath Vaibhav' <hvaibhav@ti.com>, 'Robert Fekete' <robert.fekete@stericsson.com>, 'Marcus Lorentzon' <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 22, 2010 at 11:25:48AM +0200, Marek Szyprowski wrote:

> The driver may specify memory requirements (like memory address range or
> alignment), but it cannot provide enough information to avoid or reduce
> memory fragmentation. More than one memory region can be perfectly used
> to reduce memory fragmentation IF common usage patterns are known. In
> embedded world usually not all integrated device are being used at the
> same time. This way some memory regions can be shared by 2 or more devices. 

I do have some passing familiarity with the area, typically a lot of the
features of a SoC won't get used at all at runtime on any given system.

> Just assume that gfx accelerator allocates memory is rather small chunks,
> but keeps it while relevant surface is being displayed or processed by
> application. It is not surprising that GUI (accelerated by the hardware
> engine) is used almost all the time on a mobile device. This usage pattern
> would produce a lot of fragmentation in the memory pool that is used by gfx
> accelerator. Then we want to run a camera capture device to take a 8Mpix

I'd expect that the devices would be able to reserve blocks of memory to
play with separately to the actual allocations (ie, allocate regions
like those on the command line) and things like the GPU would make use
of that.  I think you're already doing part of this?

> photo. This require a large contiguous buffer. If we try to allocate it from
> common pool it might happen that it is not possible (because of the
> fragmentation).

Sure, but none of this is saying to me that it's specifically important
to supply a static configuration via this textual configuration language
on the command line - half the problem is that you're trying to write
the configuration down in a format which is fairly tightly constrained
by needing to be there.  If the configuration is more dynamic there's a
lot more flexibility to either allow the system to figure things out
dynamically (which will hopefully work a lot of the time, for example in
your use case only the GPU really needs memory reserving).

Remember also that if you can configure this at runtime (as you say
you're working towards) then even if you have a fairly static
configuration you can inject it into the kernel from the application
layer rather than having to either hard code it in the image or bodge it
in via the command line.  This keeps the resource allocation joined up
with the application layer (which is after all what determines the
resource usage).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
