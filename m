Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7929B6B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 03:47:45 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id m7-v6so21386887wrb.16
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 00:47:45 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id 89-v6si10772314wri.279.2018.04.24.00.47.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 00:47:42 -0700 (PDT)
Date: Tue, 24 Apr 2018 08:47:27 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 11/12] swiotlb: move the SWIOTLB config symbol to
 lib/Kconfig
Message-ID: <20180424074726.GI16141@n2100.armlinux.org.uk>
References: <20180423170419.20330-1-hch@lst.de>
 <20180423170419.20330-12-hch@lst.de>
 <20180423235205.GH16141@n2100.armlinux.org.uk>
 <20180424065549.GA18468@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180424065549.GA18468@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, linux-pci@vger.kernel.org, x86@kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Tue, Apr 24, 2018 at 08:55:49AM +0200, Christoph Hellwig wrote:
> On Tue, Apr 24, 2018 at 12:52:05AM +0100, Russell King - ARM Linux wrote:
> > On Mon, Apr 23, 2018 at 07:04:18PM +0200, Christoph Hellwig wrote:
> > > This way we have one central definition of it, and user can select it as
> > > needed.  Note that we also add a second ARCH_HAS_SWIOTLB symbol to
> > > indicate the architecture supports swiotlb at all, so that we can still
> > > make the usage optional for a few architectures that want this feature
> > > to be user selectable.
> > > 
> > > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > 
> > Hmm, this looks like we end up with NEED_SG_DMA_LENGTH=y on ARM by
> > default, which probably isn't a good idea - ARM pre-dates the dma_length
> > parameter in scatterlists, and I don't think all code is guaranteed to
> > do the right thing if this is enabled.
> 
> We shouldn't end up with NEED_SG_DMA_LENGTH=y on ARM by default.

Your patch as sent would end up with:

ARM selects ARCH_HAS_SWIOTLB
SWIOTLB is defaulted to ARCH_HAS_SWIOTLB
SWIOTLB selects NEED_SG_DMA_LENGTH

due to:

@@ -106,6 +106,7 @@ config ARM
        select REFCOUNT_FULL
        select RTC_LIB
        select SYS_SUPPORTS_APM_EMULATION
+       select ARCH_HAS_SWIOTLB

and:

+config SWIOTLB
+       bool "SWIOTLB support"
+       default ARCH_HAS_SWIOTLB
+       select NEED_SG_DMA_LENGTH

Therefore, the default state for SWIOTLB and hence NEED_SG_DMA_LENGTH
becomes 'y' on ARM, and any defconfig file that does not mention SWIOTLB
explicitly ends up with both these enabled.

> It is only select by ARM_DMA_USE_IOMMU before the patch, and it will
> now also be selected by SWIOTLB, which for arm is never used or seleted
> directly by anything but xen-swiotlb.

See above.

> Then again looking at the series there shouldn't be any need to
> even select NEED_SG_DMA_LENGTH for swiotlb, as we'll never merge segments,
> so I'll fix that up.

That would help to avoid any regressions along the lines I've spotted
by review.

It does look a bit weird though - patch 10 arranged stuff so that we
didn't end up with SWIOTLB always enabled, but this patch reintroduces
that with the allowance that the user can disable if so desired.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
