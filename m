Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id EB2B46B02A8
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 05:38:27 -0400 (EDT)
Received: from epmmp1. (mailout2.samsung.com [203.254.224.25])
 by mailout2.samsung.com
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0L5Y00M9RCXPNE50@mailout2.samsung.com> for linux-mm@kvack.org;
 Thu, 22 Jul 2010 18:27:25 +0900 (KST)
Received: from AMDC159 (unknown [106.116.37.153])
 by mmp1.samsung.com (Sun Java(tm) System Messaging Server 7u3-15.01 64bit
 (built Feb 12 2010)) with ESMTPA id <0L5Y00AV8CXA7LA0@mmp1.samsung.com> for
 linux-mm@kvack.org; Thu, 22 Jul 2010 18:27:25 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
References: <cover.1279639238.git.m.nazarewicz@samsung.com>
 <d6d104950c1391eaf3614d56615617cee5722fb4.1279639238.git.m.nazarewicz@samsung.com>
 <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com>
 <1279649724.26765.23.camel@c-dwalke-linux.qualcomm.com>
 <op.vf5o28st7p4s8u@pikus> <20100721135229.GC10930@sirena.org.uk>
 <op.vf66mxka7p4s8u@pikus> <20100721182457.GE10930@sirena.org.uk>
 <op.vf7h6ysh7p4s8u@pikus> <20100722090602.GF10930@sirena.org.uk>
In-reply-to: <20100722090602.GF10930@sirena.org.uk>
Subject: RE: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
Date: Thu, 22 Jul 2010 11:25:48 +0200
Message-id: <000901cb297f$e28f2b10$a7ad8130$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: pl
Sender: owner-linux-mm@kvack.org
To: 'Mark Brown' <broonie@opensource.wolfsonmicro.com>, Michal Nazarewicz <m.nazarewicz@samsung.com>
Cc: 'Daniel Walker' <dwalker@codeaurora.org>, linux-mm@kvack.org, Pawel Osciak <p.osciak@samsung.com>, 'Xiaolin Zhang' <xiaolin.zhang@intel.com>, 'Hiremath Vaibhav' <hvaibhav@ti.com>, 'Robert Fekete' <robert.fekete@stericsson.com>, 'Marcus Lorentzon' <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello,

On Thursday, July 22, 2010 11:06 AM Mark Brown wrote:

> On Wed, Jul 21, 2010 at 08:41:12PM +0200, Micha?? Nazarewicz wrote:
> > On Wed, 21 Jul 2010 20:24:58 +0200, Mark Brown
> <broonie@opensource.wolfsonmicro.com> wrote:
> 
> > >> I am currently working on making the whole thing more dynamic.  I
> imagine
> 
> > > Yes, I think it will be much easier to be able to grab the regions at
> > > startup but hopefully the allocation within those regions can be made
> > > much more dynamic.  This would render most of the configuration syntax
> > > unneeded.
> 
> > Not sure what you mean by the last sentence.  Maybe we have different
> > things in mind?
> 
> I mean that if the drivers are able to request things dynamically and
> have some knowledge of their own requirements then that removes the need
> to manually specify exactly which regions go to which drivers which
> means that most of the complexity of the existing syntax is not needed
> since it can be figured out at runtime.

The driver may specify memory requirements (like memory address range or
alignment), but it cannot provide enough information to avoid or reduce
memory fragmentation. More than one memory region can be perfectly used
to reduce memory fragmentation IF common usage patterns are known. In
embedded world usually not all integrated device are being used at the
same time. This way some memory regions can be shared by 2 or more devices. 

Just assume that gfx accelerator allocates memory is rather small chunks,
but keeps it while relevant surface is being displayed or processed by
application. It is not surprising that GUI (accelerated by the hardware
engine) is used almost all the time on a mobile device. This usage pattern
would produce a lot of fragmentation in the memory pool that is used by gfx
accelerator. Then we want to run a camera capture device to take a 8Mpix
photo. This require a large contiguous buffer. If we try to allocate it from
common pool it might happen that it is not possible (because of the
fragmentation).

With CMA approach we can create 2 memory regions for this case. One for gfx
accelerator and the other for camera capture device, video decoder or jpeg
decoder, because common usage analysis showed that these 3 devices usually
are not used at the same time.

Best regards
--
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
