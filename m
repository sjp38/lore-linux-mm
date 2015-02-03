Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id B72336B006C
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 16:43:34 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id x12so46995473wgg.7
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 13:43:34 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.130])
        by mx.google.com with ESMTPS id eg8si203888wic.99.2015.02.03.13.43.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Feb 2015 13:43:32 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Linaro-mm-sig] [RFCv3 2/2] dma-buf: add helpers for sharing attacher constraints with dma-parms
Date: Tue, 03 Feb 2015 22:42:26 +0100
Message-ID: <3327782.QV7DJfvifL@wuerfel>
In-Reply-To: <20150203200435.GX14009@phenom.ffwll.local>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org> <7233574.nKiRa7HnXU@wuerfel> <20150203200435.GX14009@phenom.ffwll.local>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linaro-mm-sig@lists.linaro.org
Cc: Daniel Vetter <daniel@ffwll.ch>, linaro-kernel@lists.linaro.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Robin Murphy <robin.murphy@arm.com>, LKML <linux-kernel@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rob Clark <robdclark@gmail.com>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

On Tuesday 03 February 2015 21:04:35 Daniel Vetter wrote:

> - On many soc people love to reuse iommus with the same or similar
>   interface all over the place. The solution thus far adopted on arm
>   platforms is to write an iommu driver for those and then implement the
>   dma-api on top of this iommu.
> 
>   But if we unconditionally do this then we rob the gpu driver's ability
>   to control its private iommu like it wants to, because a lot of the
>   functionality is lost behind the dma api abstraction.

I believe in case of rockchips, msm, exynos and tegra, the same
iommu is used directly by the DRM driver while it is used 
implicitly by the dma-mapping API. We have run into some problems
with this in 3.19, but they should be solvable.

> Again assuming I'm not confused can't we just solve this by pushing the
> dma api abstraction down one layer for just the gpu, and let it use its
> private iommmu directly? Steps for binding a buffer would be:
> 1. dma_map_sg
> 2. Noodle the dma_addr_t out of the sg table and feed those into a 2nd
> level mapping set up through the iommu api for the gpu-private mmu.

If you want to do that, you run into the problem of telling the driver
core about it. We associate the device with an iommu in the device
tree, describing there how it is wired up.

The driver core creates a platform_device for this and checks if it
an iommu mapping is required or wanted for the device, which is then
set up. When the device driver wants to create its own iommu mapping,
this conflicts with the one that is already there. We can't just
skip the iommu setup for all devices because it may be needed sometimes,
and I don't really want to see hacks where the driver core knows which
devices are GPUs and skips the mapping for them, which would be a
layering violation.

> Again, this is what i915 and all the ttm based drivers already do, except
> that we don't use the generic iommu interfaces but have our own (i915 has
> its interface in i915_gem_gtt.c, ttm just calls them tt for translation
> tables ...).

Right, if you have a private iommu, there is no problem. The tricky part
is using a single driver for the system-level translation and the gpu
private mappings when there is only one type of iommu in the system.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
