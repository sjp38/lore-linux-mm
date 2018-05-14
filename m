Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 936D46B0007
	for <linux-mm@kvack.org>; Mon, 14 May 2018 06:35:21 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id l85-v6so10213652pfb.18
        for <linux-mm@kvack.org>; Mon, 14 May 2018 03:35:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l10-v6si8969605pfc.188.2018.05.14.03.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 14 May 2018 03:35:20 -0700 (PDT)
Date: Mon, 14 May 2018 07:35:03 -0300
From: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Subject: Re: Are media drivers abusing of GFP_DMA? - was: Re: [LSF/MM TOPIC
 NOTES] x86 ZONE_DMA love
Message-ID: <20180514073503.3da05fc6@vento.lan>
In-Reply-To: <547252fc-dc74-93c6-fc77-be1bfb558787@st.com>
References: <20180426215406.GB27853@wotan.suse.de>
	<20180505130815.53a26955@vento.lan>
	<3561479.qPIcrWnXEC@avalon>
	<20180507121916.4eb7f5b2@vento.lan>
	<547252fc-dc74-93c6-fc77-be1bfb558787@st.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fabien DESSENNE <fabien.dessenne@st.com>
Cc: Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Jean Christophe TROTIN <jean-christophe.trotin@st.com>, Yasunari Takiguchi <Yasunari.Takiguchi@sony.com>, Sakari Ailus <sakari.ailus@linux.intel.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

Hi Fabien,

Em Mon, 14 May 2018 08:00:37 +0000
Fabien DESSENNE <fabien.dessenne@st.com> escreveu:

> On 07/05/18 17:19, Mauro Carvalho Chehab wrote:
> > Em Mon, 07 May 2018 16:26:08 +0300
> > Laurent Pinchart <laurent.pinchart@ideasonboard.com> escreveu:
> >  
> >> Hi Mauro,
> >>
> >> On Saturday, 5 May 2018 19:08:15 EEST Mauro Carvalho Chehab wrote:  
> >>> There was a recent discussion about the use/abuse of GFP_DMA flag when
> >>> allocating memories at LSF/MM 2018 (see Luis notes enclosed).
> >>>
> >>> The idea seems to be to remove it, using CMA instead. Before doing that,
> >>> better to check if what we have on media is are valid use cases for it, or
> >>> if it is there just due to some misunderstanding (or because it was
> >>> copied from some other code).
> >>>
> >>> Hans de Goede sent us today a patch stopping abuse at gspca, and I'm
> >>> also posting today two other patches meant to stop abuse of it on USB
> >>> drivers. Still, there are 4 platform drivers using it:
> >>>
> >>> 	$ git grep -l -E "GFP_DMA\\b" drivers/media/
> >>> 	drivers/media/platform/omap3isp/ispstat.c
> >>> 	drivers/media/platform/sti/bdisp/bdisp-hw.c
> >>> 	drivers/media/platform/sti/hva/hva-mem.c  
> 
> Hi Mauro,
> 
> The two STI drivers (bdisp-hw.c and hva-mem.c) are only expected to run 
> on ARM platforms, not on x86.
> Since this thread deals with x86 & DMA trouble, I am not sure that we 
> actually have a problem for the sti drivers.
> 
> There are some other sti drivers that make use of this GFP_DMA flag 
> (drivers/gpu/drm/sti/sti_*.c) and it does not seem to be a problem.
> 
> Nevertheless I can see that the media sti drivers depend on COMPILE_TEST 
> (which is not the case for the DRM ones).
> Would it be an acceptable solution to remove the COMPILE_TEST dependency?

This has nothing to do with either x86 or COMPILE_TEST. The thing is
that there's a plan for removing GFP_DMA from the Kernel[1], as it was
originally meant to be used only by old PCs, where the DMA controllers
used only  on the bottom 16 MB memory address (24 bits). IMHO, it is 
very unlikely that any ARM SoC have such limitation.

[1] https://lwn.net/Articles/753273/ (article will be freely available
on May, 17)

Anyway, before the removal of GFP_DMA happens, I'd like to better 
understand why we're using it at media, and if we can, instead,
set the DMA bit mask, just like almost all other media drivers
that require to confine DMA into a certain range do. In the case
of ARM, this is what we currently have:

drivers/media/platform/exynos-gsc/gsc-core.c:   vb2_dma_contig_set_max_seg_size(dev, DMA_BIT_MASK(32));
drivers/media/platform/exynos4-is/fimc-core.c:  vb2_dma_contig_set_max_seg_size(dev, DMA_BIT_MASK(32));
drivers/media/platform/exynos4-is/fimc-is.c:    vb2_dma_contig_set_max_seg_size(dev, DMA_BIT_MASK(32));
drivers/media/platform/exynos4-is/fimc-lite.c:  vb2_dma_contig_set_max_seg_size(dev, DMA_BIT_MASK(32));
drivers/media/platform/mtk-mdp/mtk_mdp_core.c:  vb2_dma_contig_set_max_seg_size(&pdev->dev, DMA_BIT_MASK(32));
drivers/media/platform/omap3isp/isp.c:  ret = dma_coerce_mask_and_coherent(isp->dev, DMA_BIT_MASK(32));
drivers/media/platform/s5p-g2d/g2d.c:   vb2_dma_contig_set_max_seg_size(&pdev->dev, DMA_BIT_MASK(32));
drivers/media/platform/s5p-jpeg/jpeg-core.c:    vb2_dma_contig_set_max_seg_size(&pdev->dev, DMA_BIT_MASK(32));
drivers/media/platform/s5p-mfc/s5p_mfc.c:                                       DMA_BIT_MASK(32));
drivers/media/platform/s5p-mfc/s5p_mfc.c:                                       DMA_BIT_MASK(32));
drivers/media/platform/s5p-mfc/s5p_mfc.c:       vb2_dma_contig_set_max_seg_size(dev, DMA_BIT_MASK(32));

> 
> BR
> 
> Fabien
> 
> >>> 	drivers/media/spi/cxd2880-spi.c
> >>>
> >>> Could you please check if GFP_DMA is really needed there, or if it is
> >>> just because of some cut-and-paste from some other place?  
> >> I started looking at that for the omap3isp driver but Sakari beat me at
> >> submitting a patch. GFP_DMA isn't needed for omap3isp.
> >>  
> > Thank you both for looking into it.
> >
> > Regards,
> > Mauro
> >
> >
> >
> > Thanks,
> > Mauro  



Thanks,
Mauro
