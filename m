Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id D86DD6B0073
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 19:16:18 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id gl10so8914957lab.28
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 16:16:18 -0700 (PDT)
Received: from mail-la0-x22b.google.com (mail-la0-x22b.google.com [2a00:1450:4010:c03::22b])
        by mx.google.com with ESMTPS id w4si15990151lad.122.2014.04.16.16.16.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 16:16:17 -0700 (PDT)
Received: by mail-la0-f43.google.com with SMTP id e16so8816412lan.30
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 16:16:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140416224324.GO24070@n2100.arm.linux.org.uk>
References: <CAF1ivSaAQ_8byv+a9NQebtL4kBYFEPOTJHn-JA-bYY=wLFpv2Q@mail.gmail.com>
	<534ECCEB.6090007@codeaurora.org>
	<CAF1ivSaMRj_V_NHBBDfPmNmZ+CNfCnAywfWGudpoAv_8j_FrwA@mail.gmail.com>
	<534ED412.1040909@codeaurora.org>
	<CAF1ivSafFWU6xmPrAxCWbcY3weZRuHyhDY+yOVGRAPqkYMqfRA@mail.gmail.com>
	<20140416224324.GO24070@n2100.arm.linux.org.uk>
Date: Wed, 16 Apr 2014 16:16:16 -0700
Message-ID: <CAF1ivSZVvw0cYbVdH8RWkO97QfCL0QjL2JpT9YpyQgsV9YdnQQ@mail.gmail.com>
Subject: Re: kmalloc and uncached memory
From: Lin Ming <minggr@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Laura Abbott <lauraa@codeaurora.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, Apr 16, 2014 at 3:43 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Wed, Apr 16, 2014 at 02:28:45PM -0700, Lin Ming wrote:
>> On Wed, Apr 16, 2014 at 12:03 PM, Laura Abbott <lauraa@codeaurora.org> wrote:
>> > On 4/16/2014 11:50 AM, Lin Ming wrote:
>> >> On Wed, Apr 16, 2014 at 11:33 AM, Laura Abbott <lauraa@codeaurora.org> wrote:
>> >>> On 4/16/2014 11:11 AM, Lin Ming wrote:
>> >>>> Hi Peter,
>> >>>>
>> >>>> I have a performance problem(on ARM board) that cpu is very bus at
>> >>>> cache invalidation.
>> >>>> So I'm trying to alloc an uncached memory to eliminate cache invalidation.
>> >>>>
>> >>>> But I also have problem with dma_alloc_coherent().
>> >>>> If I don't use dma_alloc_coherent(), is it OK to use below code to
>> >>>> alloc uncached memory?
>> >>>>
>> >>>> struct page *page;
>> >>>> pgd_t *pgd;
>> >>>> pud_t *pud;
>> >>>> pmd_t *pmd;
>> >>>> pte_t *pte;
>> >>>> void *cpu_addr;
>> >>>> dma_addr_t dma_addr;
>> >>>> unsigned int vaddr;
>> >>>>
>> >>>> cpu_addr = kmalloc(PAGE_SIZE, GFP_KERNEL);
>> >>>> dma_addr = pci_map_single(NULL, cpu_addr, PAGE_SIZE, (int)DMA_FROM_DEVICE);
>> >>>> vaddr = (unsigned int)uncached->cpu_addr;
>> >>>> pgd = pgd_offset_k(vaddr);
>> >>>> pud = pud_offset(pgd, vaddr);
>> >>>> pmd = pmd_offset(pud, vaddr);
>> >>>> pte = pte_offset_kernel(pmd, vaddr);
>> >>>> page = virt_to_page(vaddr);
>> >>>> set_pte_ext(pte, mk_pte(page,  pgprot_dmacoherent(pgprot_kernel)), 0);
>> >>>>
>> >>>> /* This kmalloc memory won't be freed  */
>> >>>>
>> >>>
>> >>> No, that will not work. lowmem pages are mapped with 1MB sections underneath
>> >>> which cannot be (easily) changed at runtime. You really want to be using
>> >>> dma_alloc_coherent here.
>> >>
>> >> For "lowmem pages", do you mean the first 16M physical memory?
>> >> How about that if I only use highmem pages(>16M)?
>> >>
>> >
>> > By lowmem pages I am referring to the direct mapped kernel area. Highmem refers
>> > to pages which do not have a permanent mapping in the kernel address space. If
>> > you are calling kmalloc with GFP_KERNEL you will be getting a page from the lowmem
>> > region.
>>
>> Thanks for the explanation.
>>
>> >
>> > What's the reason you can't use dma_alloc_coherent?
>>
>> I'm actually testing WIFI RX performance on a ARM based AP.
>> WIFI to Ethernet traffic, that is WIFI driver RX packets and then
>> Ethernet driver TX packets.
>>
>> I used dma_alloc_coherent() to allocate uncached buffer in WIFI driver
>> to receive packets.
>> But then Ethernet driver can't send packets successfully.
>>
>> If I used kmalloc() to allocate buffers in WIFI driver, then everything is OK.
>>
>> I know this is too platform/drivers specific problem, but any
>> suggestion would be appreciated.
>
> So why are you trying to map the memory into userspace?

I didn't map the memory into userspace.
Or am I missing something obviously?

>
> Given your fragment above, what you're doing there will be no different
> from using dma_alloc_coherent() - think about what type of mapping you
> end up with.
>
> You have two options on ARM:
>
> 1. Use dma_alloc_coherent() - recommended for data which both the CPU and
>    DMA can update simultaneously - eg, descriptor ring buffers typically
>    found on ethernet devices.
>
> 2. Use dma_map_page/dma_map_single() for what we call streaming support,
>    which can use kmalloc memory.  *But* there is only exactly *one* owner
>    of the buffer at any one time - either the CPU owns it *or* the DMA
>    device owns it.  *Only* the current owner may access the buffer.
>    Such mappings must be unmapped before they are freed.

My WIFI RX driver did 2).
Here is a piece of perf_event log.
Seems the bottleneck is at CPU cache invalidate operation.

    33.86%  ksoftirqd/0  [kernel.kallsyms]  [k] v7_dma_inv_range
            |
            --- v7_dma_inv_range
               |
               |--51.46%-- ___dma_page_cpu_to_dev
               |          skb2rbd_attach
               |          vmac_rx_poll
               |          net_rx_action
               |          __do_softirq
               |          run_ksoftirqd
               |          kthread
               |          kernel_thread_exit
               |
                --48.54%-- ___dma_page_dev_to_cpu
                          vmac_rx_poll
                          net_rx_action
                          __do_softirq
                          run_ksoftirqd
                          kthread
                          kernel_thread_exit

So I try to do 1). Use dma_alloc_coherent() to eliminate cache
invalidate operation.
But for some reason, ethernet driver didn't TX successfully the
uncached buffer.

Thanks.

>
> Since there's the requirement for ownership in (2), these are not really
> suitable to be mapped into userspace while DMA is happening - accesses to
> the buffer while DMA is in progress /can/ corrupt the data.
>
> --
> FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
> improving, and getting towards what was expected from it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
