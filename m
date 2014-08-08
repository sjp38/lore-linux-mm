Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB446B003A
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 18:45:59 -0400 (EDT)
Received: by mail-ig0-f175.google.com with SMTP id uq10so1775238igb.2
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 15:45:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cm8si18843012icc.80.2014.08.08.15.45.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Aug 2014 15:45:58 -0700 (PDT)
Date: Fri, 8 Aug 2014 15:45:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv6 3/5] common: dma-mapping: Introduce common remapping
 functions
Message-Id: <20140808154556.11c7bf68d1bcf2714c148e3b@linux-foundation.org>
In-Reply-To: <1407529397-6642-3-git-send-email-lauraa@codeaurora.org>
References: <1407529397-6642-1-git-send-email-lauraa@codeaurora.org>
	<1407529397-6642-3-git-send-email-lauraa@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Russell King <linux@arm.linux.org.uk>, David Riley <davidriley@chromium.org>, linux-arm-kernel@lists.infradead.org, Ritesh Harjain <ritesh.harjani@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thierry Reding <thierry.reding@gmail.com>, Arnd Bergmann <arnd@arndb.de>

On Fri,  8 Aug 2014 13:23:15 -0700 Laura Abbott <lauraa@codeaurora.org> wrote:

> 
> For architectures without coherent DMA, memory for DMA may
> need to be remapped with coherent attributes. Factor out
> the the remapping code from arm and put it in a
> common location to reduce code duplication.
> 
> As part of this, the arm APIs are now migrated away from
> ioremap_page_range to the common APIs which use map_vm_area for remapping.
> This should be an equivalent change and using map_vm_area is more
> correct as ioremap_page_range is intended to bring in io addresses
> into the cpu space and not regular kernel managed memory.
> 
> ...
>
> @@ -267,3 +269,68 @@ int dma_common_mmap(struct device *dev, struct vm_area_struct *vma,
>  	return ret;
>  }
>  EXPORT_SYMBOL(dma_common_mmap);
> +
> +/*
> + * remaps an allocated contiguous region into another vm_area.
> + * Cannot be used in non-sleeping contexts
> + */
> +
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

Assumes a single mem_map[] array.  That's not the case for sparsemem
(at least).


> +	ptr = dma_common_pages_remap(pages, size, vm_flags, prot, caller);
> +
> +	kfree(pages);
> +
> +	return ptr;
> +}
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
