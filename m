Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id C430F6B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 09:41:32 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id k48so45334899wev.9
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 06:41:32 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id n6si43282546wjx.24.2015.02.03.06.41.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 06:41:30 -0800 (PST)
Date: Tue, 3 Feb 2015 14:41:09 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher
 constraints with dma-parms
Message-ID: <20150203144109.GR8656@n2100.arm.linux.org.uk>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org>
 <20150203074856.GF14009@phenom.ffwll.local>
 <CAF6AEGu0-TgyE4BjiaSWXQCSk31VU7dogq=6xDRUhi79rGgbxg@mail.gmail.com>
 <4689826.8DDCrX2ZhK@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4689826.8DDCrX2ZhK@wuerfel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, Rob Clark <robdclark@gmail.com>, Sumit Semwal <sumit.semwal@linaro.org>, LKML <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Daniel Vetter <daniel@ffwll.ch>

On Tue, Feb 03, 2015 at 03:17:27PM +0100, Arnd Bergmann wrote:
> On Tuesday 03 February 2015 09:04:03 Rob Clark wrote:
> > Since I'm stuck w/ an iommu, instead of built in mmu, my plan was to
> > drop use of dma-mapping entirely (incl the current call to dma_map_sg,
> > which I just need until we can use drm_cflush on arm), and
> > attach/detach iommu domains directly to implement context switches.
> > At that point, dma_addr_t really has no sensible meaning for me.
> 
> I think what you see here is a quite common hardware setup and we really
> lack the right abstraction for it at the moment. Everybody seems to
> work around it with a mix of the dma-mapping API and the iommu API.
> These are doing different things, and even though the dma-mapping API
> can be implemented on top of the iommu API, they are not really compatible.

I'd go as far as saying that the "DMA API on top of IOMMU" is more
intended to be for a system IOMMU for the bus in question, rather
than a device-level IOMMU.

If an IOMMU is part of a device, then the device should handle it
(maybe via an abstraction) and not via the DMA API.  The DMA API should
be handing the bus addresses to the device driver which the device's
IOMMU would need to generate.  (In other words, in this circumstance,
the DMA API shouldn't give you the device internal address.)

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
