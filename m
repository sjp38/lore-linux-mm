Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id A64AC6B0096
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 14:50:41 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id mc6so8285142lab.8
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 11:50:40 -0700 (PDT)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id u5si15684533laa.199.2014.04.16.11.50.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 11:50:39 -0700 (PDT)
Received: by mail-lb0-f176.google.com with SMTP id 10so8457865lbg.35
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 11:50:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <534ECCEB.6090007@codeaurora.org>
References: <CAF1ivSaAQ_8byv+a9NQebtL4kBYFEPOTJHn-JA-bYY=wLFpv2Q@mail.gmail.com>
	<534ECCEB.6090007@codeaurora.org>
Date: Wed, 16 Apr 2014 11:50:38 -0700
Message-ID: <CAF1ivSaMRj_V_NHBBDfPmNmZ+CNfCnAywfWGudpoAv_8j_FrwA@mail.gmail.com>
Subject: Re: kmalloc and uncached memory
From: Lin Ming <minggr@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, Apr 16, 2014 at 11:33 AM, Laura Abbott <lauraa@codeaurora.org> wrote:
> On 4/16/2014 11:11 AM, Lin Ming wrote:
>> Hi Peter,
>>
>> I have a performance problem(on ARM board) that cpu is very bus at
>> cache invalidation.
>> So I'm trying to alloc an uncached memory to eliminate cache invalidation.
>>
>> But I also have problem with dma_alloc_coherent().
>> If I don't use dma_alloc_coherent(), is it OK to use below code to
>> alloc uncached memory?
>>
>> struct page *page;
>> pgd_t *pgd;
>> pud_t *pud;
>> pmd_t *pmd;
>> pte_t *pte;
>> void *cpu_addr;
>> dma_addr_t dma_addr;
>> unsigned int vaddr;
>>
>> cpu_addr = kmalloc(PAGE_SIZE, GFP_KERNEL);
>> dma_addr = pci_map_single(NULL, cpu_addr, PAGE_SIZE, (int)DMA_FROM_DEVICE);
>> vaddr = (unsigned int)uncached->cpu_addr;
>> pgd = pgd_offset_k(vaddr);
>> pud = pud_offset(pgd, vaddr);
>> pmd = pmd_offset(pud, vaddr);
>> pte = pte_offset_kernel(pmd, vaddr);
>> page = virt_to_page(vaddr);
>> set_pte_ext(pte, mk_pte(page,  pgprot_dmacoherent(pgprot_kernel)), 0);
>>
>> /* This kmalloc memory won't be freed  */
>>
>
> No, that will not work. lowmem pages are mapped with 1MB sections underneath
> which cannot be (easily) changed at runtime. You really want to be using
> dma_alloc_coherent here.

For "lowmem pages", do you mean the first 16M physical memory?
How about that if I only use highmem pages(>16M)?

Thanks.

>
> Laura
>
> --
> Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
> hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
