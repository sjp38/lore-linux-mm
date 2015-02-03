Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 30B066B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 11:13:09 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id k14so45475215wgh.8
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 08:13:08 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.24])
        by mx.google.com with ESMTPS id p1si29770140wiy.93.2015.02.03.08.13.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Feb 2015 08:13:07 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Linaro-mm-sig] [RFCv3 2/2] dma-buf: add helpers for sharing attacher constraints with dma-parms
Date: Tue, 03 Feb 2015 17:12:40 +0100
Message-ID: <6906596.JU5vQoa1jV@wuerfel>
In-Reply-To: <20150203155404.GV8656@n2100.arm.linux.org.uk>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org> <3783167.LiVXgA35gN@wuerfel> <20150203155404.GV8656@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linaro-mm-sig@lists.linaro.org, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Robin Murphy <robin.murphy@arm.com>, LKML <linux-kernel@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rob Clark <robdclark@gmail.com>, Daniel Vetter <daniel@ffwll.ch>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, linux-arm-kernel@lists.infradead.org, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

On Tuesday 03 February 2015 15:54:04 Russell King - ARM Linux wrote:
> On Tue, Feb 03, 2015 at 04:31:13PM +0100, Arnd Bergmann wrote:
> > The dma_map_* interfaces assign the virtual addresses internally,
> > using typically either a global address space for all devices, or one
> > address space per device.
> 
> We shouldn't be doing one address space per device for precisely this
> reason.  We should be doing one address space per *bus*.  I did have
> a nice diagram to illustrate the point in my previous email, but I
> deleted it, I wish I hadn't... briefly:
> 
> Fig. 1.
>                                                  +------------------+
>                                                  |+-----+  device   |
> CPU--L1cache--L2cache--Memory--SysMMU---<iobus>----IOMMU-->         |
>                                                  |+-----+           |
>                                                  +------------------+
> 
> Fig.1 represents what I'd call the "GPU" issue that we're talking about
> in this thread.
> 
> Fig. 2.
> CPU--L1cache--L2cache--Memory--SysMMU---<iobus>--IOMMU--device
> 
> The DMA API should be responsible (at the very least) for everything on
> the left of "<iobus>" in and should be providing a dma_addr_t which is
> representative of what the device (in Fig.1) as a whole sees.  That's
> the "system" part.  
> 
> I believe this is the approach which is taken by x86 and similar platforms,
> simply because they tend not to have an IOMMU on individual devices (and
> if they did, eg, on a PCI card, it's clearly the responsibility of the
> device driver.)
> 
> Whether the DMA API also handles the IOMMU in Fig.1 or 2 is questionable.
> For fig.2, it is entirely possible that the same device could appear
> without an IOMMU, and in that scenario, you would want the IOMMU to be
> handled transparently.
> 
> However, by doing so for everything, you run into exactly the problem
> which is being discussed here - the need to separate out the cache
> coherency from the IOMMU aspects.  You probably also have a setup very
> similar to fig.1 (which is certainly true of Vivante GPUs.)
> 
> If you have the need to separately control both, then using the DMA API
> to encapsulate both does not make sense - at which point, the DMA API
> should be responsible for the minimum only - in other words, everything
> to the left of <iobus> (so including the system MMU.)  The control of
> the device IOMMU should be the responsibility of device driver in this
> case.
> 
> So, dma_map_sg() would be responsible for dealing with the CPU cache
> coherency issues, and setting up the system MMU.  dma_sync_*() would
> be responsible for the CPU cache coherency issues, and dma_unmap_sg()
> would (again) deal with the CPU cache and tear down the system MMU
> mappings.
> 
> Meanwhile, the device driver has ultimate control over its IOMMU, the
> creation and destruction of mappings and context switches at the
> appropriate times.

I agree for the case you are describing here. From what I understood
from Rob was that he is looking at something more like:

Fig 3
CPU--L1cache--L2cache--Memory--IOMMU---<iobus>--device

where the IOMMU controls one or more contexts per device, and is
shared across GPU and non-GPU devices. Here, we need to use the
dmap-mapping interface to set up the IO page table for any device
that is unable to address all of system RAM, and we can use it
for purposes like isolation of the devices. There are also cases
where using the IOMMU is not optional.

So unlike the scenario you describe, the driver cannot at the
same time control the cache (using the dma-mapping API) and
the I/O page tables (using the iommu API or some internal
functions).

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
