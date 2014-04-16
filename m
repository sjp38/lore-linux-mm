Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 296346B008A
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 14:33:18 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so11155185pbb.36
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 11:33:17 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id bi5si13169997pbb.191.2014.04.16.11.33.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Apr 2014 11:33:16 -0700 (PDT)
Message-ID: <534ECCEB.6090007@codeaurora.org>
Date: Wed, 16 Apr 2014 11:33:15 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: kmalloc and uncached memory
References: <CAF1ivSaAQ_8byv+a9NQebtL4kBYFEPOTJHn-JA-bYY=wLFpv2Q@mail.gmail.com>
In-Reply-To: <CAF1ivSaAQ_8byv+a9NQebtL4kBYFEPOTJHn-JA-bYY=wLFpv2Q@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Ming <minggr@gmail.com>, Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 4/16/2014 11:11 AM, Lin Ming wrote:
> Hi Peter,
> 
> I have a performance problem(on ARM board) that cpu is very bus at
> cache invalidation.
> So I'm trying to alloc an uncached memory to eliminate cache invalidation.
> 
> But I also have problem with dma_alloc_coherent().
> If I don't use dma_alloc_coherent(), is it OK to use below code to
> alloc uncached memory?
> 
> struct page *page;
> pgd_t *pgd;
> pud_t *pud;
> pmd_t *pmd;
> pte_t *pte;
> void *cpu_addr;
> dma_addr_t dma_addr;
> unsigned int vaddr;
> 
> cpu_addr = kmalloc(PAGE_SIZE, GFP_KERNEL);
> dma_addr = pci_map_single(NULL, cpu_addr, PAGE_SIZE, (int)DMA_FROM_DEVICE);
> vaddr = (unsigned int)uncached->cpu_addr;
> pgd = pgd_offset_k(vaddr);
> pud = pud_offset(pgd, vaddr);
> pmd = pmd_offset(pud, vaddr);
> pte = pte_offset_kernel(pmd, vaddr);
> page = virt_to_page(vaddr);
> set_pte_ext(pte, mk_pte(page,  pgprot_dmacoherent(pgprot_kernel)), 0);
> 
> /* This kmalloc memory won't be freed  */
> 

No, that will not work. lowmem pages are mapped with 1MB sections underneath
which cannot be (easily) changed at runtime. You really want to be using
dma_alloc_coherent here.

Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
