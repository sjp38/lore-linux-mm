Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id C4F866B0044
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 18:44:09 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id bs8so19231wib.5
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 15:44:09 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id lm4si219822wic.116.2014.04.16.15.44.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 15:44:07 -0700 (PDT)
Date: Wed, 16 Apr 2014 23:43:24 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: kmalloc and uncached memory
Message-ID: <20140416224324.GO24070@n2100.arm.linux.org.uk>
References: <CAF1ivSaAQ_8byv+a9NQebtL4kBYFEPOTJHn-JA-bYY=wLFpv2Q@mail.gmail.com> <534ECCEB.6090007@codeaurora.org> <CAF1ivSaMRj_V_NHBBDfPmNmZ+CNfCnAywfWGudpoAv_8j_FrwA@mail.gmail.com> <534ED412.1040909@codeaurora.org> <CAF1ivSafFWU6xmPrAxCWbcY3weZRuHyhDY+yOVGRAPqkYMqfRA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAF1ivSafFWU6xmPrAxCWbcY3weZRuHyhDY+yOVGRAPqkYMqfRA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Ming <minggr@gmail.com>
Cc: Laura Abbott <lauraa@codeaurora.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, Apr 16, 2014 at 02:28:45PM -0700, Lin Ming wrote:
> On Wed, Apr 16, 2014 at 12:03 PM, Laura Abbott <lauraa@codeaurora.org> wrote:
> > On 4/16/2014 11:50 AM, Lin Ming wrote:
> >> On Wed, Apr 16, 2014 at 11:33 AM, Laura Abbott <lauraa@codeaurora.org> wrote:
> >>> On 4/16/2014 11:11 AM, Lin Ming wrote:
> >>>> Hi Peter,
> >>>>
> >>>> I have a performance problem(on ARM board) that cpu is very bus at
> >>>> cache invalidation.
> >>>> So I'm trying to alloc an uncached memory to eliminate cache invalidation.
> >>>>
> >>>> But I also have problem with dma_alloc_coherent().
> >>>> If I don't use dma_alloc_coherent(), is it OK to use below code to
> >>>> alloc uncached memory?
> >>>>
> >>>> struct page *page;
> >>>> pgd_t *pgd;
> >>>> pud_t *pud;
> >>>> pmd_t *pmd;
> >>>> pte_t *pte;
> >>>> void *cpu_addr;
> >>>> dma_addr_t dma_addr;
> >>>> unsigned int vaddr;
> >>>>
> >>>> cpu_addr = kmalloc(PAGE_SIZE, GFP_KERNEL);
> >>>> dma_addr = pci_map_single(NULL, cpu_addr, PAGE_SIZE, (int)DMA_FROM_DEVICE);
> >>>> vaddr = (unsigned int)uncached->cpu_addr;
> >>>> pgd = pgd_offset_k(vaddr);
> >>>> pud = pud_offset(pgd, vaddr);
> >>>> pmd = pmd_offset(pud, vaddr);
> >>>> pte = pte_offset_kernel(pmd, vaddr);
> >>>> page = virt_to_page(vaddr);
> >>>> set_pte_ext(pte, mk_pte(page,  pgprot_dmacoherent(pgprot_kernel)), 0);
> >>>>
> >>>> /* This kmalloc memory won't be freed  */
> >>>>
> >>>
> >>> No, that will not work. lowmem pages are mapped with 1MB sections underneath
> >>> which cannot be (easily) changed at runtime. You really want to be using
> >>> dma_alloc_coherent here.
> >>
> >> For "lowmem pages", do you mean the first 16M physical memory?
> >> How about that if I only use highmem pages(>16M)?
> >>
> >
> > By lowmem pages I am referring to the direct mapped kernel area. Highmem refers
> > to pages which do not have a permanent mapping in the kernel address space. If
> > you are calling kmalloc with GFP_KERNEL you will be getting a page from the lowmem
> > region.
> 
> Thanks for the explanation.
> 
> >
> > What's the reason you can't use dma_alloc_coherent?
> 
> I'm actually testing WIFI RX performance on a ARM based AP.
> WIFI to Ethernet traffic, that is WIFI driver RX packets and then
> Ethernet driver TX packets.
> 
> I used dma_alloc_coherent() to allocate uncached buffer in WIFI driver
> to receive packets.
> But then Ethernet driver can't send packets successfully.
> 
> If I used kmalloc() to allocate buffers in WIFI driver, then everything is OK.
> 
> I know this is too platform/drivers specific problem, but any
> suggestion would be appreciated.

So why are you trying to map the memory into userspace?

Given your fragment above, what you're doing there will be no different
from using dma_alloc_coherent() - think about what type of mapping you
end up with.

You have two options on ARM:

1. Use dma_alloc_coherent() - recommended for data which both the CPU and
   DMA can update simultaneously - eg, descriptor ring buffers typically
   found on ethernet devices.

2. Use dma_map_page/dma_map_single() for what we call streaming support,
   which can use kmalloc memory.  *But* there is only exactly *one* owner
   of the buffer at any one time - either the CPU owns it *or* the DMA
   device owns it.  *Only* the current owner may access the buffer.
   Such mappings must be unmapped before they are freed.

Since there's the requirement for ownership in (2), these are not really
suitable to be mapped into userspace while DMA is happening - accesses to
the buffer while DMA is in progress /can/ corrupt the data.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
