Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0D3ED6B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:54:23 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g7-v6so11879531wrb.19
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 23:54:22 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id b5-v6si10843345wrf.362.2018.04.23.23.54.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 23:54:21 -0700 (PDT)
Date: Tue, 24 Apr 2018 08:55:49 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 11/12] swiotlb: move the SWIOTLB config symbol to
	lib/Kconfig
Message-ID: <20180424065549.GA18468@lst.de>
References: <20180423170419.20330-1-hch@lst.de> <20180423170419.20330-12-hch@lst.de> <20180423235205.GH16141@n2100.armlinux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180423235205.GH16141@n2100.armlinux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Christoph Hellwig <hch@lst.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, linux-pci@vger.kernel.org, x86@kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Tue, Apr 24, 2018 at 12:52:05AM +0100, Russell King - ARM Linux wrote:
> On Mon, Apr 23, 2018 at 07:04:18PM +0200, Christoph Hellwig wrote:
> > This way we have one central definition of it, and user can select it as
> > needed.  Note that we also add a second ARCH_HAS_SWIOTLB symbol to
> > indicate the architecture supports swiotlb at all, so that we can still
> > make the usage optional for a few architectures that want this feature
> > to be user selectable.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> Hmm, this looks like we end up with NEED_SG_DMA_LENGTH=y on ARM by
> default, which probably isn't a good idea - ARM pre-dates the dma_length
> parameter in scatterlists, and I don't think all code is guaranteed to
> do the right thing if this is enabled.

We shouldn't end up with NEED_SG_DMA_LENGTH=y on ARM by default.
It is only select by ARM_DMA_USE_IOMMU before the patch, and it will
now also be selected by SWIOTLB, which for arm is never used or seleted
directly by anything but xen-swiotlb.

Then again looking at the series there shouldn't be any need to
even select NEED_SG_DMA_LENGTH for swiotlb, as we'll never merge segments,
so I'll fix that up.
