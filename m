Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id C0B736B0036
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 14:07:33 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w62so22289wes.1
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 11:07:33 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.13])
        by mx.google.com with ESMTPS id mu3si29188972wic.38.2014.07.22.11.07.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jul 2014 11:07:32 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv4 5/5] arm64: Add atomic pool for non-coherent and CMA allocations.
Date: Tue, 22 Jul 2014 20:06:44 +0200
References: <1404324218-4743-1-git-send-email-lauraa@codeaurora.org> <1404324218-4743-6-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1404324218-4743-6-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201407222006.44666.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Laura Abbott <lauraa@codeaurora.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, David Riley <davidriley@chromium.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ritesh Harjain <ritesh.harjani@gmail.com>

On Wednesday 02 July 2014, Laura Abbott wrote:
> +       pgprot_t prot = __pgprot(PROT_NORMAL_NC);
> +       unsigned long nr_pages = atomic_pool_size >> PAGE_SHIFT;
> +       struct page *page;
> +       void *addr;
> +
> +
> +       if (dev_get_cma_area(NULL))
> +               page = dma_alloc_from_contiguous(NULL, nr_pages,
> +                                       get_order(atomic_pool_size));
> +       else
> +               page = alloc_pages(GFP_KERNEL, get_order(atomic_pool_size));
> +
> +
> +       if (page) {
> +               int ret;
> +
> +               atomic_pool = gen_pool_create(PAGE_SHIFT, -1);
> +               if (!atomic_pool)
> +                       goto free_page;
> +
> +               addr = dma_common_contiguous_remap(page, atomic_pool_size,
> +                                       VM_USERMAP, prot, atomic_pool_init);
> +

I just stumbled over this thread and noticed the code here: When you do
alloc_pages() above, you actually get pages that are already mapped into
the linear kernel mapping as cacheable pages. Your new
dma_common_contiguous_remap tries to map them as noncacheable. This
seems broken because it allows the CPU to treat both mappings as
cacheable, and that won't be coherent with device DMA.

> +               if (!addr)
> +                       goto destroy_genpool;
> +
> +               memset(addr, 0, atomic_pool_size);
> +               __dma_flush_range(addr, addr + atomic_pool_size);

It also seems weird to flush the cache on a virtual address of
an uncacheable mapping. Is that well-defined? In the CMA case, the
original mapping should already be uncached here, so you don't need
to flush it. In the alloc_pages() case, I think you need to unmap
the pages from the linear mapping instead.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
