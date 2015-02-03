Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 10F0C6B0073
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 10:22:32 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id l15so22517193wiw.0
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 07:22:31 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id pn2si8454217wjc.131.2015.02.03.07.22.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 07:22:30 -0800 (PST)
Date: Tue, 3 Feb 2015 15:22:05 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher
 constraints with dma-parms
Message-ID: <20150203152204.GU8656@n2100.arm.linux.org.uk>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org>
 <4689826.8DDCrX2ZhK@wuerfel>
 <20150203144109.GR8656@n2100.arm.linux.org.uk>
 <4830208.H6zxrGlT1D@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4830208.H6zxrGlT1D@wuerfel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, Rob Clark <robdclark@gmail.com>, Sumit Semwal <sumit.semwal@linaro.org>, LKML <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Daniel Vetter <daniel@ffwll.ch>

On Tue, Feb 03, 2015 at 03:52:48PM +0100, Arnd Bergmann wrote:
> On Tuesday 03 February 2015 14:41:09 Russell King - ARM Linux wrote:
> > I'd go as far as saying that the "DMA API on top of IOMMU" is more
> > intended to be for a system IOMMU for the bus in question, rather
> > than a device-level IOMMU.
> > 
> > If an IOMMU is part of a device, then the device should handle it
> > (maybe via an abstraction) and not via the DMA API.  The DMA API should
> > be handing the bus addresses to the device driver which the device's
> > IOMMU would need to generate.  (In other words, in this circumstance,
> > the DMA API shouldn't give you the device internal address.)
> 
> Exactly. And the abstraction that people choose at the moment is the
> iommu API, for better or worse. It makes a lot of sense to use this
> API if the same iommu is used for other devices as well (which is
> the case on Tegra and probably a lot of others). Unfortunately the
> iommu API lacks support for cache management, and probably other things
> as well, because this was not an issue for the original use case
> (device assignment on KVM/x86).
> 
> This could be done by adding explicit or implied cache management
> to the IOMMU mapping interfaces, or by extending the dma-mapping
> interfaces in a way that covers the use case of the device managing
> its own address space, in addition to the existing coherent and
> streaming interfaces.

Don't we already have those in the DMA API?  dma_sync_*() ?

dma_map_sg() - sets up the system MMU and deals with initial cache
coherency handling.  Device IOMMU being the responsibility of the
GPU driver.

The GPU can then do dma_sync_*() on the scatterlist as is necessary
to synchronise the cache coherency (while respecting the ownership
rules - which are very important on ARM to follow as some sync()s are
destructive to any dirty data in the CPU cache.)

dma_unmap_sg() tears down the system MMU and deals with the final cache
handling.

Why do we need more DMA API interfaces?

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
