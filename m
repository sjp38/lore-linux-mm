Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 27E896B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 05:30:16 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id b13so15376870wgh.6
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 02:30:15 -0700 (PDT)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id op7si7281012wjc.145.2014.08.27.02.30.13
        for <linux-mm@kvack.org>;
        Wed, 27 Aug 2014 02:30:14 -0700 (PDT)
Message-ID: <53FDA522.2010106@imgtec.com>
Date: Wed, 27 Aug 2014 10:30:10 +0100
From: James Hogan <james.hogan@imgtec.com>
MIME-Version: 1.0
Subject: Re: [PATCHv7 3/5] common: dma-mapping: Introduce common remapping
 functions
References: <1407800431-21566-1-git-send-email-lauraa@codeaurora.org>	<1407800431-21566-4-git-send-email-lauraa@codeaurora.org> <CAAG0J99=wrz4+c49HeDvL0W9rDZKk2HNLdVtHv4ZJxU4-OjewA@mail.gmail.com> <53FCBCC3.5040901@codeaurora.org>
In-Reply-To: <53FCBCC3.5040901@codeaurora.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>, Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Will Deacon <will.deacon@arm.com>, Russell King <linux@arm.linux.org.uk>, David Riley <davidriley@chromium.org>, ARM Kernel List <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thierry Reding <thierry.reding@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-next@vger.kernel.org

On 26/08/14 17:58, Laura Abbott wrote:
> On 8/26/2014 3:05 AM, James Hogan wrote:
>> On 12 August 2014 00:40, Laura Abbott <lauraa@codeaurora.org> wrote:
>>>
>>> For architectures without coherent DMA, memory for DMA may
>>> need to be remapped with coherent attributes. Factor out
>>> the the remapping code from arm and put it in a
>>> common location to reduce code duplication.
>>>
>>> As part of this, the arm APIs are now migrated away from
>>> ioremap_page_range to the common APIs which use map_vm_area for remapping.
>>> This should be an equivalent change and using map_vm_area is more
>>> correct as ioremap_page_range is intended to bring in io addresses
>>> into the cpu space and not regular kernel managed memory.
>>>
>>> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
>>> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
>>
>> This commit in linux-next () breaks the build for metag:
>>
>> drivers/base/dma-mapping.c: In function a??dma_common_contiguous_remapa??:
>> drivers/base/dma-mapping.c:294: error: implicit declaration of
>> function a??dma_common_pages_remapa??
>> drivers/base/dma-mapping.c:294: warning: assignment makes pointer from
>> integer without a cast
>> drivers/base/dma-mapping.c: At top level:
>> drivers/base/dma-mapping.c:308: error: conflicting types for
>> a??dma_common_pages_remapa??
>> drivers/base/dma-mapping.c:294: error: previous implicit declaration
>> of a??dma_common_pages_remapa?? was here
>>
>> Looks like metag isn't alone either:
>>
>> $ git grep -L dma-mapping-common arch/*/include/asm/dma-mapping.h
>> arch/arc/include/asm/dma-mapping.h
>> arch/avr32/include/asm/dma-mapping.h
>> arch/blackfin/include/asm/dma-mapping.h
>> arch/c6x/include/asm/dma-mapping.h
>> arch/cris/include/asm/dma-mapping.h
>> arch/frv/include/asm/dma-mapping.h
>> arch/m68k/include/asm/dma-mapping.h
>> arch/metag/include/asm/dma-mapping.h
>> arch/mn10300/include/asm/dma-mapping.h
>> arch/parisc/include/asm/dma-mapping.h
>> arch/xtensa/include/asm/dma-mapping.h
>>
>> I've checked a couple of these arches (blackfin, xtensa) which don't
>> include dma-mapping-common.h and their builds seem to be broken too.
>>
>> Cheers
>> James
>>
> 
> Thanks for the report. Would you mind giving the following patch
> a test (this is theoretical only but I think it should work)

It certainly fixes the build for metag.

Thanks
James

> 
> -----8<------
> 
> From 81c9a5504cbc1d72ff1df084d48502b248cd79d0 Mon Sep 17 00:00:00 2001
> From: Laura Abbott <lauraa@codeaurora.org>
> Date: Tue, 26 Aug 2014 09:50:49 -0700
> Subject: [PATCH] common: dma-mapping: Swap function order
> 
> Fix the order of dma_common_contiguous_remap and
> dma_common_pages_remap to avoid function declaration errors:
> 
> drivers/base/dma-mapping.c: In function 'dma_common_contiguous_remap':
> drivers/base/dma-mapping.c:294: error: implicit declaration of
> function 'dma_common_pages_remap'
> drivers/base/dma-mapping.c:294: warning: assignment makes pointer from
> integer without a cast
> drivers/base/dma-mapping.c: At top level:
> drivers/base/dma-mapping.c:308: error: conflicting types for
> 'dma_common_pages_remap'
> drivers/base/dma-mapping.c:294: error: previous implicit declaration
> of 'dma_common_pages_remap' was here
> 
> Change-Id: I65db739114e8f5816a24a279a2ff1a6dc92e2b83
> Reported-by: James Hogan <james.hogan@imgtec.com>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
> ---
>  drivers/base/dma-mapping.c | 44 ++++++++++++++++++++++----------------------
>  1 file changed, 22 insertions(+), 22 deletions(-)
> 
> diff --git a/drivers/base/dma-mapping.c b/drivers/base/dma-mapping.c
> index 1bc46df..056fd46 100644
> --- a/drivers/base/dma-mapping.c
> +++ b/drivers/base/dma-mapping.c
> @@ -271,6 +271,28 @@ int dma_common_mmap(struct device *dev, struct vm_area_struct *vma,
>  EXPORT_SYMBOL(dma_common_mmap);
>  
>  /*
> + * remaps an array of PAGE_SIZE pages into another vm_area
> + * Cannot be used in non-sleeping contexts
> + */
> +void *dma_common_pages_remap(struct page **pages, size_t size,
> +			unsigned long vm_flags, pgprot_t prot,
> +			const void *caller)
> +{
> +	struct vm_struct *area;
> +
> +	area = get_vm_area_caller(size, vm_flags, caller);
> +	if (!area)
> +		return NULL;
> +
> +	if (map_vm_area(area, prot, pages)) {
> +		vunmap(area->addr);
> +		return NULL;
> +	}
> +
> +	return area->addr;
> +}
> +
> +/*
>   * remaps an allocated contiguous region into another vm_area.
>   * Cannot be used in non-sleeping contexts
>   */
> @@ -299,28 +321,6 @@ void *dma_common_contiguous_remap(struct page *page, size_t size,
>  }
>  
>  /*
> - * remaps an array of PAGE_SIZE pages into another vm_area
> - * Cannot be used in non-sleeping contexts
> - */
> -void *dma_common_pages_remap(struct page **pages, size_t size,
> -			unsigned long vm_flags, pgprot_t prot,
> -			const void *caller)
> -{
> -	struct vm_struct *area;
> -
> -	area = get_vm_area_caller(size, vm_flags, caller);
> -	if (!area)
> -		return NULL;
> -
> -	if (map_vm_area(area, prot, pages)) {
> -		vunmap(area->addr);
> -		return NULL;
> -	}
> -
> -	return area->addr;
> -}
> -
> -/*
>   * unmaps a range previously mapped by dma_common_*_remap
>   */
>  void dma_common_free_remap(void *cpu_addr, size_t size, unsigned long vm_flags)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
