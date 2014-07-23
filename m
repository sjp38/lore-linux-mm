Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4E57F6B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 06:46:11 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id ft15so1406750pdb.31
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 03:46:10 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id gg2si2062724pbb.253.2014.07.23.03.46.09
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 03:46:10 -0700 (PDT)
Date: Wed, 23 Jul 2014 11:45:54 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCHv4 3/5] common: dma-mapping: Introduce common remapping
 functions
Message-ID: <20140723104554.GB1366@localhost>
References: <1406079308-5232-1-git-send-email-lauraa@codeaurora.org>
 <1406079308-5232-4-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1406079308-5232-4-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Will Deacon <Will.Deacon@arm.com>, David Riley <davidriley@chromium.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Russell King <linux@arm.linux.org.uk>, Thierry Reding <thierry.reding@gmail.com>, Arnd Bergmann <arnd@arndb.de>

On Wed, Jul 23, 2014 at 02:35:06AM +0100, Laura Abbott wrote:
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -298,37 +298,19 @@ static void *
>  __dma_alloc_remap(struct page *page, size_t size, gfp_t gfp, pgprot_t prot,
>  	const void *caller)
>  {
> -	struct vm_struct *area;
> -	unsigned long addr;
> -
>  	/*
>  	 * DMA allocation can be mapped to user space, so lets
>  	 * set VM_USERMAP flags too.
>  	 */
> -	area = get_vm_area_caller(size, VM_ARM_DMA_CONSISTENT | VM_USERMAP,
> -				  caller);
> -	if (!area)
> -		return NULL;
> -	addr = (unsigned long)area->addr;
> -	area->phys_addr = __pfn_to_phys(page_to_pfn(page));
> -
> -	if (ioremap_page_range(addr, addr + size, area->phys_addr, prot)) {
> -		vunmap((void *)addr);
> -		return NULL;
> -	}
> -	return (void *)addr;
> +	return dma_common_contiguous_remap(page, size,
> +			VM_ARM_DMA_CONSISTENT | VM_USERMAP,
> +			prot, caller);

I think we still need at least a comment in the commit log since the arm
code is moving from ioremap_page_range() to map_vm_area(). There is a
slight performance penalty with the addition of a kmalloc() on this
path.

Or even better (IMO), see below.

> --- a/drivers/base/dma-mapping.c
> +++ b/drivers/base/dma-mapping.c
[...]
> +void *dma_common_contiguous_remap(struct page *page, size_t size,
> +			unsigned long vm_flags,
> +			pgprot_t prot, const void *caller)
> +{
> +	int i;
> +	struct page **pages;
> +	void *ptr;
> +
> +	pages = kmalloc(sizeof(struct page *) << get_order(size), GFP_KERNEL);
> +	if (!pages)
> +		return NULL;
> +
> +	for (i = 0; i < (size >> PAGE_SHIFT); i++)
> +		pages[i] = page + i;
> +
> +	ptr = dma_common_pages_remap(pages, size, vm_flags, prot, caller);
> +
> +	kfree(pages);
> +
> +	return ptr;
> +}

You could avoid the dma_common_page_remap() here (and kmalloc) and
simply use ioremap_page_range(). We know that
dma_common_contiguous_remap() is only called with contiguous physical
range, so ioremap_page_range() is suitable. It also makes it a
non-functional change for arch/arm.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
