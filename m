Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id CA6856B0075
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 14:11:42 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id p9so8492649lbv.32
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 11:11:41 -0700 (PDT)
Received: from mail-lb0-x22b.google.com (mail-lb0-x22b.google.com [2a00:1450:4010:c04::22b])
        by mx.google.com with ESMTPS id u5si15626223laa.178.2014.04.16.11.11.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 11:11:40 -0700 (PDT)
Received: by mail-lb0-f171.google.com with SMTP id w7so8352281lbi.2
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 11:11:40 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 16 Apr 2014 11:11:39 -0700
Message-ID: <CAF1ivSaAQ_8byv+a9NQebtL4kBYFEPOTJHn-JA-bYY=wLFpv2Q@mail.gmail.com>
Subject: kmalloc and uncached memory
From: Lin Ming <minggr@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

Hi Peter,

I have a performance problem(on ARM board) that cpu is very bus at
cache invalidation.
So I'm trying to alloc an uncached memory to eliminate cache invalidation.

But I also have problem with dma_alloc_coherent().
If I don't use dma_alloc_coherent(), is it OK to use below code to
alloc uncached memory?

struct page *page;
pgd_t *pgd;
pud_t *pud;
pmd_t *pmd;
pte_t *pte;
void *cpu_addr;
dma_addr_t dma_addr;
unsigned int vaddr;

cpu_addr = kmalloc(PAGE_SIZE, GFP_KERNEL);
dma_addr = pci_map_single(NULL, cpu_addr, PAGE_SIZE, (int)DMA_FROM_DEVICE);
vaddr = (unsigned int)uncached->cpu_addr;
pgd = pgd_offset_k(vaddr);
pud = pud_offset(pgd, vaddr);
pmd = pmd_offset(pud, vaddr);
pte = pte_offset_kernel(pmd, vaddr);
page = virt_to_page(vaddr);
set_pte_ext(pte, mk_pte(page,  pgprot_dmacoherent(pgprot_kernel)), 0);

/* This kmalloc memory won't be freed  */

Thanks,
Ming

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
