Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 79C896B024D
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 08:46:01 -0400 (EDT)
Date: Thu, 22 Jul 2010 13:46:00 +0100
From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
Message-ID: <20100722124559.GH4737@rakim.wolfsonmicro.main>
References: <1279649724.26765.23.camel@c-dwalke-linux.qualcomm.com>
 <op.vf5o28st7p4s8u@pikus>
 <20100721135229.GC10930@sirena.org.uk>
 <op.vf66mxka7p4s8u@pikus>
 <20100721182457.GE10930@sirena.org.uk>
 <op.vf7h6ysh7p4s8u@pikus>
 <20100722090602.GF10930@sirena.org.uk>
 <000901cb297f$e28f2b10$a7ad8130$%szyprowski@samsung.com>
 <20100722105203.GD4737@rakim.wolfsonmicro.main>
 <op.vf8sxqro7p4s8u@pikus>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <op.vf8sxqro7p4s8u@pikus>
Sender: owner-linux-mm@kvack.org
To: =?utf-8?Q?Micha=C5=82?= Nazarewicz <m.nazarewicz@samsung.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, 'Daniel Walker' <dwalker@codeaurora.org>, linux-mm@kvack.org, Pawel Osciak <p.osciak@samsung.com>, 'Xiaolin Zhang' <xiaolin.zhang@intel.com>, 'Hiremath Vaibhav' <hvaibhav@ti.com>, 'Robert Fekete' <robert.fekete@stericsson.com>, 'Marcus Lorentzon' <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 22, 2010 at 01:30:52PM +0200, MichaA? Nazarewicz wrote:

> The first one, I believe, should be there as to specify the regions
> that are to be reserved.  Drivers and platform will still be able to
> add their own regions but I believe that in vest majority of cases,
> it will be enough to just pass the list of region on a command line.

The command line is a real pain for stuff like this since it's not
usually committed to revision control so robustly and it's normally more
painful to change the bootloader to pass the desired command line in
than it is to change either the kernel or userspace (some bootloaders
are just completely unconfigurable without reflashing, and if your only
recovery mechanism is JTAG that can be a bit of a concern).

> Alternatively, instead of the textual description of platform could
> provide an array of regions it want reserved.  It would remove like
> 50 lines of code from CMA core (in the version I have on my drive at
> least, where part of the syntax was simplified) however it would
> remove the possibility to easily change the configuration from
> command line (ie. no need to recompile which is handy when you need
> to optimise this and test various configurations) and would add more
> code to the platform initialisation code, ie: instead of:

> 	cma_defaults("reg1=20M;reg2=20M", NULL);

> one would have to define an array with the regions descriptors.
> Personally, I don't see much benefits from this.

I think it'd be vastly more legible, especially if the list of regions
gets large.  I had thought the only reason for the text format was to
put it onto the command line.

> I agree that parsing it is not nice but thanks to it, all you need to
> do in the driver is:

> 	cma_alloc(dev, "a", ...)
> 	cma_alloc(dev, "b", ...)
> 	cma_alloc(dev, "f", ...)

> Without cma_map you'd have to pass names of the region to the driver
> and make the driver use those.

I agree that a mapping facility for the names is essential, especially
if drivers need to share regions.

> What I'm trying to say is that I'm trying to move complexity out of
> the drivers into the framework (as I believe that's what frameworks
> are for).

It sounds like apart from the way you're passing the configuration in
you're doing roughly what I'd suggest.  I'd expect that in a lot of
cases the map could be satisfied from the default region so there'd be
no need to explicitly set one up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
