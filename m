Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA7886B000E
	for <linux-mm@kvack.org>; Tue, 15 May 2018 06:30:37 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e7-v6so9122000pfi.8
        for <linux-mm@kvack.org>; Tue, 15 May 2018 03:30:37 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d68-v6si7468049pgc.197.2018.05.15.03.30.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 15 May 2018 03:30:36 -0700 (PDT)
Date: Tue, 15 May 2018 07:30:23 -0300
From: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Subject: Re: Are media drivers abusing of GFP_DMA? - was: Re: [LSF/MM TOPIC
 NOTES] x86 ZONE_DMA love
Message-ID: <20180515073023.6b1712f7@vento.lan>
In-Reply-To: <2362912.ePyn3BKvGt@avalon>
References: <20180426215406.GB27853@wotan.suse.de>
	<20180514073857.7fd69136@vento.lan>
	<63607d94-b974-2bcd-c15e-fcb9350d8470@st.com>
	<2362912.ePyn3BKvGt@avalon>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Cc: Fabien DESSENNE <fabien.dessenne@st.com>, Jean Christophe TROTIN <jean-christophe.trotin@st.com>, Yasunari Takiguchi <Yasunari.Takiguchi@sony.com>, Sakari Ailus <sakari.ailus@linux.intel.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

Hi Laurent,

Em Tue, 15 May 2018 11:27:44 +0300
Laurent Pinchart <laurent.pinchart@ideasonboard.com> escreveu:

> Hello,
> 
> On Tuesday, 15 May 2018 10:30:28 EEST Fabien DESSENNE wrote:
> > On 14/05/18 12:39, Mauro Carvalho Chehab wrote:  
> > > Em Mon, 14 May 2018 07:35:03 -0300 Mauro Carvalho Chehab escreveu:  
> > >> Em Mon, 14 May 2018 08:00:37 +0000 Fabien DESSENNE escreveu:  
> > >>> On 07/05/18 17:19, Mauro Carvalho Chehab wrote:  
> > >>>> Em Mon, 07 May 2018 16:26:08 +0300 Laurent Pinchart escreveu:  
> > >>>>> On Saturday, 5 May 2018 19:08:15 EEST Mauro Carvalho Chehab wrote:
> > >>>>>   
> > >>>>>> There was a recent discussion about the use/abuse of GFP_DMA flag
> > >>>>>> when allocating memories at LSF/MM 2018 (see Luis notes enclosed).
> > >>>>>>
> > >>>>>> The idea seems to be to remove it, using CMA instead. Before doing
> > >>>>>> that, better to check if what we have on media is are valid use cases
> > >>>>>> for it, or if it is there just due to some misunderstanding (or
> > >>>>>> because it was copied from some other code).
> > >>>>>>
> > >>>>>> Hans de Goede sent us today a patch stopping abuse at gspca, and I'm
> > >>>>>> also posting today two other patches meant to stop abuse of it on
> > >>>>>> USB drivers. Still, there are 4 platform drivers using it:
> > >>>>>>
> > >>>>>> 	$ git grep -l -E "GFP_DMA\\b" drivers/media/
> > >>>>>> 	drivers/media/platform/omap3isp/ispstat.c
> > >>>>>> 	drivers/media/platform/sti/bdisp/bdisp-hw.c
> > >>>>>> 	drivers/media/platform/sti/hva/hva-mem.c  
> > >>>
> > >>> The two STI drivers (bdisp-hw.c and hva-mem.c) are only expected to run
> > >>> on ARM platforms, not on x86. Since this thread deals with x86 & DMA
> > >>> trouble, I am not sure that we actually have a problem for the sti
> > >>> drivers.
> > >>>
> > >>> There are some other sti drivers that make use of this GFP_DMA flag
> > >>> (drivers/gpu/drm/sti/sti_*.c) and it does not seem to be a problem.
> > >>>
> > >>> Nevertheless I can see that the media sti drivers depend on COMPILE_TEST
> > >>> (which is not the case for the DRM ones).
> > >>> Would it be an acceptable solution to remove the COMPILE_TEST
> > >>> dependency?  
> > >> 
> > >> This has nothing to do with either x86 or COMPILE_TEST. The thing is
> > >> that there's a plan for removing GFP_DMA from the Kernel[1], as it was
> > >> originally meant to be used only by old PCs, where the DMA controllers
> > >> used only  on the bottom 16 MB memory address (24 bits). IMHO, it is
> > >> very unlikely that any ARM SoC have such limitation.
> > >>
> > >> [1] https://lwn.net/Articles/753273/ (article will be freely available
> > >> on May, 17)  
> > > 
> > > Btw, you can also read about that at:
> > > 
> > > 	https://lwn.net/Articles/753274/
> > >  
> > >> Anyway, before the removal of GFP_DMA happens, I'd like to better
> > >> understand why we're using it at media, and if we can, instead,
> > >> set the DMA bit mask, just like almost all other media drivers
> > >> that require to confine DMA into a certain range do. In the case
> > >> of ARM, this is what we currently have:
> > >>
> > >> drivers/media/platform/exynos-gsc/gsc-core.c:  
> > >> vb2_dma_contig_set_max_seg_size(dev, DMA_BIT_MASK(32));
> > >> drivers/media/platform/exynos4-is/fimc-core.c: 
> > >> vb2_dma_contig_set_max_seg_size(dev, DMA_BIT_MASK(32));
> > >> drivers/media/platform/exynos4-is/fimc-is.c:   
> > >> vb2_dma_contig_set_max_seg_size(dev, DMA_BIT_MASK(32));
> > >> drivers/media/platform/exynos4-is/fimc-lite.c: 
> > >> vb2_dma_contig_set_max_seg_size(dev, DMA_BIT_MASK(32));
> > >> drivers/media/platform/mtk-mdp/mtk_mdp_core.c: 
> > >> vb2_dma_contig_set_max_seg_size(&pdev->dev, DMA_BIT_MASK(32));
> > >> drivers/media/platform/omap3isp/isp.c:  ret =
> > >> dma_coerce_mask_and_coherent(isp->dev, DMA_BIT_MASK(32));
> > >> drivers/media/platform/s5p-g2d/g2d.c:  
> > >> vb2_dma_contig_set_max_seg_size(&pdev->dev, DMA_BIT_MASK(32));
> > >> drivers/media/platform/s5p-jpeg/jpeg-core.c:   
> > >> vb2_dma_contig_set_max_seg_size(&pdev->dev, DMA_BIT_MASK(32));
> > >> drivers/media/platform/s5p-mfc/s5p_mfc.c:                               
> > >>        DMA_BIT_MASK(32));
> > >> drivers/media/platform/s5p-mfc/s5p_mfc.c:     
> > >>                                  DMA_BIT_MASK(32));
> > >> drivers/media/platform/s5p-mfc/s5p_mfc.c:      
> > >> vb2_dma_contig_set_max_seg_size(dev, DMA_BIT_MASK(32));  
> > 
> > That's clearer now, thank you for the clarification
> > I am about to send patches for the sti drivers (set the DMA bit mask)  
> 
> Some drivers call vb2_dma_contig_set_max_seg_size() and some call 
> dma_coerce_mask_and_coherent(). Both are likely needed, the former telling the 
> DMA mapping API about the maximum size of a scatter-gather chunk that the 
> device supports (when using vb2-dma-contig that size should really be the full 
> address space supported by the device as we want DMA-contiguous buffers), and 
> the latter telling the DMA mapping API about the address space that is 
> accessible through DMA (and thus in which address range buffers must be 
> placed).
> 
> I wonder why the omap3isp driver works without a 
> vb2_dma_contig_set_max_seg_size() call. Sakari, any insight ?

I checked the usage of vb2_dma_contig_set_max_seg_size(). What it
does is to allocate dev->dma_parms and call dma_set_max_seg_size().

Allocating dev->dma_parms change the behavior of 2 function pairs 
(inlined at dma_mapping.h):

1) dma_get_seg_boundary() / dma_set_seg_boundary()

As no media drivers use dev->dma_parms->segment_boundary_mask,
it will keep returning DMA_BIT_MASK(32), either calling or not
the VB2-specific function.

1) dma_get_max_seg_size() / dma_set_max_seg_size()

Checking where dma_get_max_seg_size() is used returns:

$ git grep dma_get_max_seg_size
arch/alpha/kernel/pci_iommu.c:  max_seg_size = dev ? dma_get_max_seg_size(dev) : 0;
arch/arm/mm/dma-mapping.c:      unsigned int max = dma_get_max_seg_size(dev);
arch/ia64/hp/common/sba_iommu.c:        unsigned int max_seg_size = dma_get_max_seg_size(dev);
arch/powerpc/kernel/iommu.c:    max_seg_size = dma_get_max_seg_size(dev);
arch/s390/pci/pci_dma.c:        unsigned int max = dma_get_max_seg_size(dev);
arch/sparc/kernel/iommu.c:      max_seg_size = dma_get_max_seg_size(dev);
arch/sparc/kernel/pci_sun4v.c:  max_seg_size = dma_get_max_seg_size(dev);
arch/x86/kernel/amd_gart_64.c:  max_seg_size    = dma_get_max_seg_size(dev);
drivers/firewire/sbp2.c:        if (dma_get_max_seg_size(device->card->device) > SBP2_MAX_SEG_SIZE)
drivers/iio/buffer/industrialio-buffer-dmaengine.c:     dmaengine_buffer->max_size = dma_get_max_seg_size(chan->device->dev);
drivers/iommu/dma-iommu.c:      unsigned int cur_len = 0, max_len = dma_get_max_seg_size(dev);
drivers/media/common/videobuf2/videobuf2-dma-contig.c:  if (dma_get_max_seg_size(dev) < size)
drivers/mmc/host/mmci.c:                unsigned int max_seg_size = dma_get_max_seg_size(dev);
drivers/mmc/host/mmci.c:                unsigned int max_seg_size = dma_get_max_seg_size(dev);
drivers/mmc/host/mxcmmc.c:              mmc->max_seg_size = dma_get_max_seg_size(
drivers/mmc/host/mxs-mmc.c:     mmc->max_seg_size = dma_get_max_seg_size(ssp->dmach->device->dev);
drivers/parisc/iommu-helpers.h: unsigned int max_seg_size = min(dma_get_max_seg_size(dev),
drivers/scsi/scsi_lib.c:        blk_queue_max_segment_size(q, dma_get_max_seg_size(dev));
drivers/spi/spi.c:      unsigned int max_seg_size = dma_get_max_seg_size(dev);
include/linux/dma-mapping.h:static inline unsigned int dma_get_max_seg_size(struct device *dev)
lib/dma-debug.c:        unsigned int max_range = dma_get_max_seg_size(ref->dev);
sound/soc/soc-generic-dmaengine-pcm.c:  hw.period_bytes_max = dma_get_max_seg_size(dma_dev);

As vb2_dma_contig_set_max_seg_size() is called only on ARM drivers
for Exynos and Mediatek, we only need to check where it is used inside
arch/arm/mm/dma-mapping.c. There, only __iommu_map_sg() function
calls it. So, except if mis-named, I would be expecting it to be used
only for Scatter/Gather DMA.

So, it seems that, with the current code, setting it for dma_contig 
probably does nothing.

Please double-check, as things like that can be tricky.

IMO, it is worth removing vb2_dma_contig_set_max_seg_size() and be sure that
the drivers calls it are calling dma_coerce_mask_and_coherent().

Thanks,
Mauro
