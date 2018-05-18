Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B7B476B0648
	for <linux-mm@kvack.org>; Fri, 18 May 2018 13:20:21 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id b31-v6so5444497plb.5
        for <linux-mm@kvack.org>; Fri, 18 May 2018 10:20:21 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id f1-v6si8019374plf.453.2018.05.18.10.20.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 10:20:20 -0700 (PDT)
Subject: dma_sync_*_for_cpu and direction=TO_DEVICE (was Re: [PATCH 02/20]
 dma-mapping: provide a generic dma-noncoherent implementation)
References: <20180511075945.16548-1-hch@lst.de>
 <20180511075945.16548-3-hch@lst.de>
 <bad125dff49f6e49c895e818c9d1abb346a46e8e.camel@synopsys.com>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <5ac5b1e3-9b96-9c7c-4dfe-f65be45ec179@synopsys.com>
Date: Fri, 18 May 2018 10:20:02 -0700
MIME-Version: 1.0
In-Reply-To: <bad125dff49f6e49c895e818c9d1abb346a46e8e.camel@synopsys.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>, "hch@lst.de" <hch@lst.de>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "monstr@monstr.eu" <monstr@monstr.eu>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-c6x-dev@linux-c6x.org" <linux-c6x-dev@linux-c6x.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, "green.hu@gmail.com" <green.hu@gmail.com>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "nios2-dev@lists.rocketboards.org" <nios2-dev@lists.rocketboards.org>, "deanbo422@gmail.com" <deanbo422@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On 05/18/2018 06:11 AM, Alexey Brodkin wrote:
>   void arch_sync_dma_for_device(struct device *dev, phys_addr_t paddr,
>                  size_t size, enum dma_data_direction dir)
>   {
> +       if (dir != DMA_TO_DEVICE){
> +               dump_stack();
> +               printk(" *** %s@%d: DMA direction is %s instead of %s\n",
> +                      __func__, __LINE__, dir_to_str(dir), dir_to_str(DMA_TO_DEVICE));
> +       }
> +
>          return _dma_cache_sync(dev, paddr, size, dir);
>   }
>   
>   void arch_sync_dma_for_cpu(struct device *dev, phys_addr_t paddr,
>                  size_t size, enum dma_data_direction dir)
>   {
> +       if (dir != DMA_FROM_DEVICE) {
> +               dump_stack();
> +               printk(" *** %s@%d: DMA direction is %s instead of %s\n",
> +                      __func__, __LINE__, dir_to_str(dir), dir_to_str(DMA_FROM_DEVICE));
> +       }
> +
>          return _dma_cache_sync(dev, paddr, size, dir);
>   }

...
> In case of MMC/DW_MCI (AKA DesignWare MobileStorage controller) that's an execution flow:
> 1) __dw_mci_start_request()
> 2) dw_mci_pre_dma_transfer()
> 3) dma_map_sg(..., mmc_get_dma_dir(data))
>
> Note mmc_get_dma_dir() is just "data->flags & MMC_DATA_WRITE ? DMA_TO_DEVICE : DMA_FROM_DEVICE".
> I.e. if we're preparing for sending data dma_noncoherent_map_sg() will have DMA_TO_DEVICE which
> is quite OK for passing to dma_noncoherent_sync_sg_for_device() but in case of reading we'll have
> DMA_FROM_DEVICE which we'll pass to dma_noncoherent_sync_sg_for_device() in dma_noncoherent_map_sg().
>
> I'd say this is not entirely correct because IMHO arch_sync_dma_for_cpu() is supposed to only be used
> in case of DMA_FROM_DEVICE and arch_sync_dma_for_device() only in case of DMA_TO_DEVICE.

So roughly 10 years ago, some kernel rookie name Vineet Gupta, asked the exact 
same question :-)

http://kernelnewbies.kernelnewbies.narkive.com/aGW1QcDv/query-about-dma-sync-for-cpu-and-direction-to-device

I never understood the need for this direction. And if memory serves me right, at 
that time I was seeing twice the amount of cache flushing !

> But the real fix of my problem is:
> ---------------------------------------->8------------------------------------
> --- a/lib/dma-noncoherent.c
> +++ b/lib/dma-noncoherent.c
> @@ -35,7 +35,7 @@ static dma_addr_t dma_noncoherent_map_page(struct device *dev, struct page *page
>   
>          addr = dma_direct_map_page(dev, page, offset, size, dir, attrs);
>          if (!dma_mapping_error(dev, addr) && !(attrs & DMA_ATTR_SKIP_CPU_SYNC))
> -               arch_sync_dma_for_device(dev, page_to_phys(page), size, dir);
> +               arch_sync_dma_for_device(dev, page_to_phys(page) + offset, size, dir);
>          return addr;
>   }
> ---------------------------------------->8------------------------------------
>
> You seem to lost an offset in the page so if we happen to have a buffer not aligned to
> a page boundary then we were obviously corrupting data outside our data :)

Neat !
