Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 12C736B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 10:03:51 -0500 (EST)
Message-ID: <50FD5844.1010201@web.de>
Date: Mon, 21 Jan 2013 16:01:24 +0100
From: Soeren Moch <smoch@web.de>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: dmapool: use provided gfp flags for all dma_alloc_coherent()
 calls
References: <20121119144826.f59667b2.akpm@linux-foundation.org> <201301172026.45514.arnd@arndb.de> <50FABBED.1020905@web.de> <201301192005.20093.arnd@arndb.de>
In-Reply-To: <201301192005.20093.arnd@arndb.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Jason Cooper <jason@lakedaemon.net>, Greg KH <gregkh@linuxfoundation.org>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Andrew Lunn <andrew@lunn.ch>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

On 01/19/13 21:05, Arnd Bergmann wrote:
> I found at least one source line that incorrectly uses an atomic
> allocation, in ehci_mem_init():
>
>                  dma_alloc_coherent (ehci_to_hcd(ehci)->self.controller,
>                          ehci->periodic_size * sizeof(__le32),
>                          &ehci->periodic_dma, 0);
>
> The last argument is the GFP_ flag, which should never be zero, as
> that is implicit !wait. This function is called only once, so it
> is not the actual culprit, but there could be other instances
> where we accidentally allocate something as GFP_ATOMIC.
>
> The total number of allocations I found for each type are
>
> sata_mv: 66 pages (270336 bytes)
> mv643xx_eth: 4 pages == (16384 bytes)
> orion_ehci: 154 pages (630784 bytes)
> orion_ehci (atomic): 256 pages (1048576 bytes)
>
> from the distribution of the numbers, it seems that there is exactly 1 MB
> of data allocated between bus addresses 0x1f90000 and 0x1f9ffff, allocated
> in individual pages. This matches the size of your pool, so it's definitely
> something coming from USB, and no single other allocation, but it does not
> directly point to a specific line of code.
Very interesting, so this is no fragmentation problem nor something 
caused by sata or ethernet.
> One thing I found was that the ARM dma-mapping code seems buggy in the way
> that it does a bitwise and between the gfp mask and GFP_ATOMIC, which does
> not work because GFP_ATOMIC is defined by the absence of __GFP_WAIT.
>
> I believe we need the patch below, but it is not clear to me if that issue
> is related to your problem or now.
Out of curiosity I checked include/linux/gfp.h. GFP_ATOMIC is defined as 
__GFP_HIGH (which means 'use emergency pool', and no wait), so this 
patch should not make any difference for "normal" (GPF_ATOMIC / 
GFP_KERNEL) allocations, only for gfp_flags accidentally set to zero. 
So, can a new test with this patch help to debug the pool exhaustion?
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 6b2fb87..c57975f 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -640,7 +641,7 @@ static void *__dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
>   
>   	if (is_coherent || nommu())
>   		addr = __alloc_simple_buffer(dev, size, gfp, &page);
> -	else if (gfp & GFP_ATOMIC)
> +	else if (!(gfp & __GFP_WAIT))
>   		addr = __alloc_from_pool(size, &page);
>   	else if (!IS_ENABLED(CONFIG_CMA))
>   		addr = __alloc_remap_buffer(dev, size, gfp, prot, &page, caller);
> @@ -1272,7 +1273,7 @@ static void *arm_iommu_alloc_attrs(struct device *dev, size_t size,
>   	*handle = DMA_ERROR_CODE;
>   	size = PAGE_ALIGN(size);
>   
> -	if (gfp & GFP_ATOMIC)
> +	if (!(gfp & __GFP_WAIT))
>   		return __iommu_alloc_atomic(dev, size, handle);
>   
>   	pages = __iommu_alloc_buffer(dev, size, gfp, attrs);
> 8<-------
>
> There is one more code path I could find, which is usb_submit_urb() =>
> usb_hcd_submit_urb => ehci_urb_enqueue() => submit_async() =>
> qh_append_tds() => qh_make(GFP_ATOMIC) => ehci_qh_alloc() =>
> dma_pool_alloc() => pool_alloc_page() => dma_alloc_coherent()
>
> So even for a GFP_KERNEL passed into usb_submit_urb, the ehci driver
> causes the low-level allocation to be GFP_ATOMIC, because
> qh_append_tds() is called under a spinlock. If we have hundreds
> of URBs in flight, that will exhaust the pool rather quickly.
>
Maybe there are hundreds of URBs in flight in my application, I have no 
idea how to check this. It seems to me that bad reception conditions 
(lost lock / regained lock messages for some dvb channels) accelerate 
the buffer exhaustion. But even with a 4MB coherent pool I see the 
error. Is there any chance to fix this in the usb or dvb subsystem (or 
wherever)? Should I try to further increase the pool size, or what else 
can I do besides using an older kernel?

   Soeren

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
