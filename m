Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 341AA9000BD
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 10:53:55 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/8] ARM: dma-mapping: implement dma_map_single on top of dma_map_page
Date: Mon, 27 Jun 2011 16:53:44 +0200
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com> <201106241724.21113.arnd@arndb.de> <000a01cc34d6$9e4576e0$dad064a0$%szyprowski@samsung.com>
In-Reply-To: <000a01cc34d6$9e4576e0$dad064a0$%szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201106271653.44892.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Joerg Roedel' <joro@8bytes.org>

On Monday 27 June 2011, Marek Szyprowski wrote:
> On Friday, June 24, 2011 5:24 PM Arnd Bergmann wrote:
> 
> > On Monday 20 June 2011, Marek Szyprowski wrote:
> > > > This also breaks dmabounce when used with a highmem-enabled system -
> > > > dmabounce refuses the dma_map_page() API but allows the
> > dma_map_single()
> > > > API.
> > >
> > > I really not sure how this change will break dma bounce code.
> > >
> > > Does it mean that it is allowed to call dma_map_single() on kmapped
> > > HIGH_MEM page?
> > 
> > dma_map_single on a kmapped page already doesn't work, the argument needs
> > to be inside of the linear mapping in order for virt_to_page to work.
> 
> Then I got really confused.
> 
> Documentation/DMA-mapping.txt says that dma_map_single() can be used only
> with kernel linear mapping, while dma_map_page() can be also called on 
> HIGHMEM pages.

Right, this is true in general.

> Now, lets go to arch/arm/common/dmabounce.c code:
> 
> dma_addr_t __dma_map_page(struct device *dev, struct page *page,
>                 unsigned long offset, size_t size, enum dma_data_direction dir)
> {
>         dev_dbg(dev, "%s(page=%p,off=%#lx,size=%zx,dir=%x)\n",
>                 __func__, page, offset, size, dir);
> 
>         BUG_ON(!valid_dma_direction(dir));
> 
>         if (PageHighMem(page)) {
>                 dev_err(dev, "DMA buffer bouncing of HIGHMEM pages "
>                              "is not supported\n");
>                 return ~0;
>         }
> 
>         return map_single(dev, page_address(page) + offset, size, dir);
> }
> EXPORT_SYMBOL(__dma_map_page);
>
> Am I right that there is something mixed here? I really don't get why there is
> high mem check in dma_map_page implementation. dma_map_single doesn't perform
> such check and works with kmapped highmem pages...
>
> Russell also pointed that my patch broke dma bounch with high mem enabled.

The version of __dma_map_page that you cited is the one used with dmabounce
enabled, when CONFIG_DMABOUNCE is disabled, the following version is used:

static inline dma_addr_t __dma_map_page(struct device *dev, struct page *page,
             unsigned long offset, size_t size, enum dma_data_direction dir)
{
        __dma_page_cpu_to_dev(page, offset, size, dir);
        return pfn_to_dma(dev, page_to_pfn(page)) + offset;
}

This does not have the check, because the kernel does not need to touch
the kernel mapping in that case.

If you pass a kmapped page into dma_map_single, it should also not
work because of the BUG_ON in ___dma_single_cpu_to_dev -- it warns
you that you would end up flushing the cache for the wrong page (if any).

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
