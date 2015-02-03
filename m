Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id B758E6B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 09:53:49 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id bs8so22333998wib.5
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 06:53:49 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id t10si29395370wia.44.2015.02.03.06.53.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Feb 2015 06:53:48 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher constraints with dma-parms
Date: Tue, 03 Feb 2015 15:52:48 +0100
Message-ID: <4830208.H6zxrGlT1D@wuerfel>
In-Reply-To: <20150203144109.GR8656@n2100.arm.linux.org.uk>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org> <4689826.8DDCrX2ZhK@wuerfel> <20150203144109.GR8656@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, Rob Clark <robdclark@gmail.com>, Sumit Semwal <sumit.semwal@linaro.org>, LKML <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Daniel Vetter <daniel@ffwll.ch>

On Tuesday 03 February 2015 14:41:09 Russell King - ARM Linux wrote:
> On Tue, Feb 03, 2015 at 03:17:27PM +0100, Arnd Bergmann wrote:
> > On Tuesday 03 February 2015 09:04:03 Rob Clark wrote:
> > > Since I'm stuck w/ an iommu, instead of built in mmu, my plan was to
> > > drop use of dma-mapping entirely (incl the current call to dma_map_sg,
> > > which I just need until we can use drm_cflush on arm), and
> > > attach/detach iommu domains directly to implement context switches.
> > > At that point, dma_addr_t really has no sensible meaning for me.
> > 
> > I think what you see here is a quite common hardware setup and we really
> > lack the right abstraction for it at the moment. Everybody seems to
> > work around it with a mix of the dma-mapping API and the iommu API.
> > These are doing different things, and even though the dma-mapping API
> > can be implemented on top of the iommu API, they are not really compatible.
> 
> I'd go as far as saying that the "DMA API on top of IOMMU" is more
> intended to be for a system IOMMU for the bus in question, rather
> than a device-level IOMMU.
> 
> If an IOMMU is part of a device, then the device should handle it
> (maybe via an abstraction) and not via the DMA API.  The DMA API should
> be handing the bus addresses to the device driver which the device's
> IOMMU would need to generate.  (In other words, in this circumstance,
> the DMA API shouldn't give you the device internal address.)

Exactly. And the abstraction that people choose at the moment is the
iommu API, for better or worse. It makes a lot of sense to use this
API if the same iommu is used for other devices as well (which is
the case on Tegra and probably a lot of others). Unfortunately the
iommu API lacks support for cache management, and probably other things
as well, because this was not an issue for the original use case
(device assignment on KVM/x86).

This could be done by adding explicit or implied cache management
to the IOMMU mapping interfaces, or by extending the dma-mapping
interfaces in a way that covers the use case of the device managing
its own address space, in addition to the existing coherent and
streaming interfaces.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
