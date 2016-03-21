Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id B11136B0253
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 04:44:58 -0400 (EDT)
Received: by mail-io0-f175.google.com with SMTP id c63so22817303iof.0
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 01:44:58 -0700 (PDT)
Received: from g2t4623.austin.hp.com (g2t4623.austin.hp.com. [15.73.212.78])
        by mx.google.com with ESMTPS id t19si8890665igr.59.2016.03.21.01.44.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Mar 2016 01:44:57 -0700 (PDT)
Subject: Re: [RFC PATCH] Add support for eXclusive Page Frame Ownership (XPFO)
References: <1456496467-14247-1-git-send-email-juerg.haefliger@hpe.com>
 <56D4FA15.9060700@gmail.com>
From: Juerg Haefliger <juerg.haefliger@hpe.com>
Message-ID: <56EFB486.2090501@hpe.com>
Date: Mon, 21 Mar 2016 09:44:54 +0100
MIME-Version: 1.0
In-Reply-To: <56D4FA15.9060700@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: vpk@cs.brown.edu

Hi Balbir,

Apologies for the slow reply.


On 03/01/2016 03:10 AM, Balbir Singh wrote:
> 
> 
> On 27/02/16 01:21, Juerg Haefliger wrote:
>> This patch adds support for XPFO which protects against 'ret2dir' kernel
>> attacks. The basic idea is to enforce exclusive ownership of page frames
>> by either the kernel or userland, unless explicitly requested by the
>> kernel. Whenever a page destined for userland is allocated, it is
>> unmapped from physmap. When such a page is reclaimed from userland, it is
>> mapped back to physmap.
> physmap == xen physmap? Please clarify

No, it's not XEN related. I might have the terminology wrong. Physmap is what
the original authors used for describing <quote> a large, contiguous virtual
memory region inside kernel address space that contains a direct mapping of part
or all (depending on the architecture) physical memory. </quote>


>> Mapping/unmapping from physmap is accomplished by modifying the PTE
>> permission bits to allow/disallow access to the page.
>>
>> Additional fields are added to the page struct for XPFO housekeeping.
>> Specifically a flags field to distinguish user vs. kernel pages, a
>> reference counter to track physmap map/unmap operations and a lock to
>> protect the XPFO fields.
>>
>> Known issues/limitations:
>>   - Only supported on x86-64.
> Is it due to lack of porting or a design limitation?

Lack of porting. Support for other architectures will come later.


>>   - Only supports 4k pages.
>>   - Adds additional data to the page struct.
>>   - There are most likely some additional and legitimate uses cases where
>>     the kernel needs to access userspace. Those need to be identified and
>>     made XPFO-aware.
> Why not build an audit mode for it?

Can you elaborate what you mean by this?


>>   - There's a performance impact if XPFO is turned on. Per the paper
>>     referenced below it's in the 1-3% ballpark. More performance testing
>>     wouldn't hurt. What tests to run though?
>>
>> Reference paper by the original patch authors:
>>   http://www.cs.columbia.edu/~vpk/papers/ret2dir.sec14.pdf
>>
>> Suggested-by: Vasileios P. Kemerlis <vpk@cs.brown.edu>
>> Signed-off-by: Juerg Haefliger <juerg.haefliger@hpe.com>
> This patch needs to be broken down into smaller patches - a series

Agreed.


>> ---
>>  arch/x86/Kconfig         |   2 +-
>>  arch/x86/Kconfig.debug   |  17 +++++
>>  arch/x86/mm/Makefile     |   2 +
>>  arch/x86/mm/init.c       |   3 +-
>>  arch/x86/mm/xpfo.c       | 176 +++++++++++++++++++++++++++++++++++++++++++++++
>>  block/blk-map.c          |   7 +-
>>  include/linux/highmem.h  |  23 +++++--
>>  include/linux/mm_types.h |   4 ++
>>  include/linux/xpfo.h     |  88 ++++++++++++++++++++++++
>>  lib/swiotlb.c            |   3 +-
>>  mm/page_alloc.c          |   7 +-
>>  11 files changed, 323 insertions(+), 9 deletions(-)
>>  create mode 100644 arch/x86/mm/xpfo.c
>>  create mode 100644 include/linux/xpfo.h
>>
>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>> index c46662f..9d32b4a 100644
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -1343,7 +1343,7 @@ config ARCH_DMA_ADDR_T_64BIT
>>  
>>  config X86_DIRECT_GBPAGES
>>  	def_bool y
>> -	depends on X86_64 && !DEBUG_PAGEALLOC && !KMEMCHECK
>> +	depends on X86_64 && !DEBUG_PAGEALLOC && !KMEMCHECK && !XPFO
>>  	---help---
>>  	  Certain kernel features effectively disable kernel
>>  	  linear 1 GB mappings (even if the CPU otherwise
>> diff --git a/arch/x86/Kconfig.debug b/arch/x86/Kconfig.debug
>> index 9b18ed9..1331da5 100644
>> --- a/arch/x86/Kconfig.debug
>> +++ b/arch/x86/Kconfig.debug
>> @@ -5,6 +5,23 @@ config TRACE_IRQFLAGS_SUPPORT
>>  
>>  source "lib/Kconfig.debug"
>>  
>> +config XPFO
>> +	bool "Enable eXclusive Page Frame Ownership (XPFO)"
>> +	default n
>> +	depends on DEBUG_KERNEL
>> +	depends on X86_64
>> +	select DEBUG_TLBFLUSH
>> +	---help---
>> +	  This option offers protection against 'ret2dir' (kernel) attacks.
>> +	  When enabled, every time a page frame is allocated to user space, it
>> +	  is unmapped from the direct mapped RAM region in kernel space
>> +	  (physmap). Similarly, whenever page frames are freed/reclaimed, they
>> +	  are mapped back to physmap. Special care is taken to minimize the
>> +	  impact on performance by reducing TLB shootdowns and unnecessary page
>> +	  zero fills.
>> +
>> +	  If in doubt, say "N".
>> +
>>  config X86_VERBOSE_BOOTUP
>>  	bool "Enable verbose x86 bootup info messages"
>>  	default y
>> diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
>> index f9d38a4..8bf52b6 100644
>> --- a/arch/x86/mm/Makefile
>> +++ b/arch/x86/mm/Makefile
>> @@ -34,3 +34,5 @@ obj-$(CONFIG_ACPI_NUMA)		+= srat.o
>>  obj-$(CONFIG_NUMA_EMU)		+= numa_emulation.o
>>  
>>  obj-$(CONFIG_X86_INTEL_MPX)	+= mpx.o
>> +
>> +obj-$(CONFIG_XPFO)		+= xpfo.o
>> diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
>> index 493f541..27fc8a6 100644
>> --- a/arch/x86/mm/init.c
>> +++ b/arch/x86/mm/init.c
>> @@ -150,7 +150,8 @@ static int page_size_mask;
>>  
>>  static void __init probe_page_size_mask(void)
>>  {
>> -#if !defined(CONFIG_DEBUG_PAGEALLOC) && !defined(CONFIG_KMEMCHECK)
>> +#if !defined(CONFIG_DEBUG_PAGEALLOC) && !defined(CONFIG_KMEMCHECK) && \
>> +	!defined(CONFIG_XPFO)
>>  	/*
>>  	 * For CONFIG_DEBUG_PAGEALLOC, identity mapping will use small pages.
>>  	 * This will simplify cpa(), which otherwise needs to support splitting
>> diff --git a/arch/x86/mm/xpfo.c b/arch/x86/mm/xpfo.c
>> new file mode 100644
>> index 0000000..6bc24d3
>> --- /dev/null
>> +++ b/arch/x86/mm/xpfo.c
>> @@ -0,0 +1,176 @@
>> +/*
>> + * Copyright (C) 2016 Brown University. All rights reserved.
>> + * Copyright (C) 2016 Hewlett Packard Enterprise Development, L.P.
>> + *
>> + * Authors:
>> + *   Vasileios P. Kemerlis <vpk@cs.brown.edu>
>> + *   Juerg Haefliger <juerg.haefliger@hpe.com>
>> + *
>> + * This program is free software; you can redistribute it and/or modify it
>> + * under the terms of the GNU General Public License version 2 as published by
>> + * the Free Software Foundation.
>> + */
>> +
>> +#include <linux/mm.h>
>> +#include <linux/module.h>
>> +
>> +#include <asm/pgtable.h>
>> +#include <asm/tlbflush.h>
>> +
>> +#define TEST_XPFO_FLAG(flag, page) \
>> +	test_bit(PG_XPFO_##flag, &(page)->xpfo.flags)
>> +
>> +#define SET_XPFO_FLAG(flag, page)			\
>> +	__set_bit(PG_XPFO_##flag, &(page)->xpfo.flags)
>> +
>> +#define CLEAR_XPFO_FLAG(flag, page)			\
>> +	__clear_bit(PG_XPFO_##flag, &(page)->xpfo.flags)
>> +
>> +#define TEST_AND_CLEAR_XPFO_FLAG(flag, page)			\
>> +	__test_and_clear_bit(PG_XPFO_##flag, &(page)->xpfo.flags)
>> +
>> +/*
>> + * Update a single kernel page table entry
>> + */
>> +static inline void set_kpte(struct page *page, unsigned long kaddr,
>> +			    pgprot_t prot) {
>> +	unsigned int level;
>> +	pte_t *kpte = lookup_address(kaddr, &level);
>> +
>> +	/* We only support 4k pages for now */
>> +	BUG_ON(!kpte || level != PG_LEVEL_4K);
>> +
>> +	set_pte_atomic(kpte, pfn_pte(page_to_pfn(page), canon_pgprot(prot)));
>> +}
>> +
>> +inline void xpfo_clear_zap(struct page *page, int order)
>> +{
>> +	int i;
>> +
>> +	for (i = 0; i < (1 << order); i++)
>> +		CLEAR_XPFO_FLAG(zap, page + i);
>> +}
>> +
>> +inline int xpfo_test_and_clear_zap(struct page *page)
>> +{
>> +	return TEST_AND_CLEAR_XPFO_FLAG(zap, page);
>> +}
>> +
>> +inline int xpfo_test_kernel(struct page *page)
>> +{
>> +	return TEST_XPFO_FLAG(kernel, page);
>> +}
>> +
>> +inline int xpfo_test_user(struct page *page)
>> +{
>> +	return TEST_XPFO_FLAG(user, page);
>> +}
>> +
>> +void xpfo_alloc_page(struct page *page, int order, gfp_t gfp)
>> +{
>> +	int i, tlb_shoot = 0;
>> +	unsigned long kaddr;
>> +
>> +	for (i = 0; i < (1 << order); i++)  {
>> +		WARN_ON(TEST_XPFO_FLAG(user_fp, page + i) ||
>> +			TEST_XPFO_FLAG(user, page + i));
>> +
>> +		if (gfp & GFP_HIGHUSER) {
> Why GFP_HIGHUSER?

The check is wrong. It should be ((gfp & GFP_HIGHUSER) == GFP_HIGHUSER).

Thanks
...Juerg


>> +			/* Initialize the xpfo lock and map counter */
>> +			spin_lock_init(&(page + i)->xpfo.lock);
>> +			atomic_set(&(page + i)->xpfo.mapcount, 0);
>> +
>> +			/* Mark it as a user page */
>> +			SET_XPFO_FLAG(user_fp, page + i);
>> +
>> +			/*
>> +			 * Shoot the TLB if the page was previously allocated
>> +			 * to kernel space
>> +			 */
>> +			if (TEST_AND_CLEAR_XPFO_FLAG(kernel, page + i))
>> +				tlb_shoot = 1;
>> +		} else {
>> +			/* Mark it as a kernel page */
>> +			SET_XPFO_FLAG(kernel, page + i);
>> +		}
>> +	}
>> +
>> +	if (tlb_shoot) {
>> +		kaddr = (unsigned long)page_address(page);
>> +		flush_tlb_kernel_range(kaddr, kaddr + (1 << order) *
>> +				       PAGE_SIZE);
>> +	}
>> +}
>> +
>> +void xpfo_free_page(struct page *page, int order)
>> +{
>> +	int i;
>> +	unsigned long kaddr;
>> +
>> +	for (i = 0; i < (1 << order); i++) {
>> +
>> +		/* The page frame was previously allocated to user space */
>> +		if (TEST_AND_CLEAR_XPFO_FLAG(user, page + i)) {
>> +			kaddr = (unsigned long)page_address(page + i);
>> +
>> +			/* Clear the page and mark it accordingly */
>> +			clear_page((void *)kaddr);
>> +			SET_XPFO_FLAG(zap, page + i);
>> +
>> +			/* Map it back to kernel space */
>> +			set_kpte(page + i,  kaddr, __pgprot(__PAGE_KERNEL));
>> +
>> +			/* No TLB update */
>> +		}
>> +
>> +		/* Clear the xpfo fast-path flag */
>> +		CLEAR_XPFO_FLAG(user_fp, page + i);
>> +	}
>> +}
>> +
>> +void xpfo_kmap(void *kaddr, struct page *page)
>> +{
>> +	unsigned long flags;
>> +
>> +	/* The page is allocated to kernel space, so nothing to do */
>> +	if (TEST_XPFO_FLAG(kernel, page))
>> +		return;
>> +
>> +	spin_lock_irqsave(&page->xpfo.lock, flags);
>> +
>> +	/*
>> +	 * The page was previously allocated to user space, so map it back
>> +	 * into the kernel. No TLB update required.
>> +	 */
>> +	if ((atomic_inc_return(&page->xpfo.mapcount) == 1) &&
>> +	    TEST_XPFO_FLAG(user, page))
>> +		set_kpte(page, (unsigned long)kaddr, __pgprot(__PAGE_KERNEL));
>> +
>> +	spin_unlock_irqrestore(&page->xpfo.lock, flags);
>> +}
>> +EXPORT_SYMBOL(xpfo_kmap);
>> +
>> +void xpfo_kunmap(void *kaddr, struct page *page)
>> +{
>> +	unsigned long flags;
>> +
>> +	/* The page is allocated to kernel space, so nothing to do */
>> +	if (TEST_XPFO_FLAG(kernel, page))
>> +		return;
>> +
>> +	spin_lock_irqsave(&page->xpfo.lock, flags);
>> +
>> +	/*
>> +	 * The page frame is to be allocated back to user space. So unmap it
>> +	 * from the kernel, update the TLB and mark it as a user page.
>> +	 */
>> +	if ((atomic_dec_return(&page->xpfo.mapcount) == 0) &&
>> +	    (TEST_XPFO_FLAG(user_fp, page) || TEST_XPFO_FLAG(user, page))) {
>> +		set_kpte(page, (unsigned long)kaddr, __pgprot(0));
>> +		__flush_tlb_one((unsigned long)kaddr);
>> +		SET_XPFO_FLAG(user, page);
>> +	}
>> +
>> +	spin_unlock_irqrestore(&page->xpfo.lock, flags);
>> +}
>> +EXPORT_SYMBOL(xpfo_kunmap);
>> diff --git a/block/blk-map.c b/block/blk-map.c
>> index f565e11..b7b8302 100644
>> --- a/block/blk-map.c
>> +++ b/block/blk-map.c
>> @@ -107,7 +107,12 @@ int blk_rq_map_user_iov(struct request_queue *q, struct request *rq,
>>  		prv.iov_len = iov.iov_len;
>>  	}
>>  
>> -	if (unaligned || (q->dma_pad_mask & iter->count) || map_data)
>> +	/*
>> +	 * juergh: Temporary hack to force the use of a bounce buffer if XPFO
>> +	 * is enabled. Results in an XPFO page fault otherwise.
>> +	 */
> This does look like it might add a bunch of overhead
>> +	if (unaligned || (q->dma_pad_mask & iter->count) || map_data ||
>> +	    IS_ENABLED(CONFIG_XPFO))
>>  		bio = bio_copy_user_iov(q, map_data, iter, gfp_mask);
>>  	else
>>  		bio = bio_map_user_iov(q, iter, gfp_mask);
>> diff --git a/include/linux/highmem.h b/include/linux/highmem.h
>> index bb3f329..0ca9130 100644
>> --- a/include/linux/highmem.h
>> +++ b/include/linux/highmem.h
>> @@ -55,24 +55,37 @@ static inline struct page *kmap_to_page(void *addr)
>>  #ifndef ARCH_HAS_KMAP
>>  static inline void *kmap(struct page *page)
>>  {
>> +	void *kaddr;
>> +
>>  	might_sleep();
>> -	return page_address(page);
>> +
>> +	kaddr = page_address(page);
>> +	xpfo_kmap(kaddr, page);
>> +	return kaddr;
>>  }
>>  
>>  static inline void kunmap(struct page *page)
>>  {
>> +	xpfo_kunmap(page_address(page), page);
>>  }
>>  
>>  static inline void *kmap_atomic(struct page *page)
>>  {
>> +	void *kaddr;
>> +
>>  	preempt_disable();
>>  	pagefault_disable();
>> -	return page_address(page);
>> +
>> +	kaddr = page_address(page);
>> +	xpfo_kmap(kaddr, page);
>> +	return kaddr;
>>  }
>>  #define kmap_atomic_prot(page, prot)	kmap_atomic(page)
>>  
>>  static inline void __kunmap_atomic(void *addr)
>>  {
>> +	xpfo_kunmap(addr, virt_to_page(addr));
>> +
>>  	pagefault_enable();
>>  	preempt_enable();
>>  }
>> @@ -133,7 +146,8 @@ do {                                                            \
>>  static inline void clear_user_highpage(struct page *page, unsigned long vaddr)
>>  {
>>  	void *addr = kmap_atomic(page);
>> -	clear_user_page(addr, vaddr, page);
>> +	if (!xpfo_test_and_clear_zap(page))
>> +		clear_user_page(addr, vaddr, page);
>>  	kunmap_atomic(addr);
>>  }
>>  #endif
>> @@ -186,7 +200,8 @@ alloc_zeroed_user_highpage_movable(struct vm_area_struct *vma,
>>  static inline void clear_highpage(struct page *page)
>>  {
>>  	void *kaddr = kmap_atomic(page);
>> -	clear_page(kaddr);
>> +	if (!xpfo_test_and_clear_zap(page))
>> +		clear_page(kaddr);
>>  	kunmap_atomic(kaddr);
>>  }
>>  
>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>> index 624b78b..71c95aa 100644
>> --- a/include/linux/mm_types.h
>> +++ b/include/linux/mm_types.h
>> @@ -12,6 +12,7 @@
>>  #include <linux/cpumask.h>
>>  #include <linux/uprobes.h>
>>  #include <linux/page-flags-layout.h>
>> +#include <linux/xpfo.h>
>>  #include <asm/page.h>
>>  #include <asm/mmu.h>
>>  
>> @@ -215,6 +216,9 @@ struct page {
>>  #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
>>  	int _last_cpupid;
>>  #endif
>> +#ifdef CONFIG_XPFO
>> +	struct xpfo_info xpfo;
>> +#endif
>>  }
>>  /*
>>   * The struct page can be forced to be double word aligned so that atomic ops
>> diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
>> new file mode 100644
>> index 0000000..c4f0871
>> --- /dev/null
>> +++ b/include/linux/xpfo.h
>> @@ -0,0 +1,88 @@
>> +/*
>> + * Copyright (C) 2016 Brown University. All rights reserved.
>> + * Copyright (C) 2016 Hewlett Packard Enterprise Development, L.P.
>> + *
>> + * Authors:
>> + *   Vasileios P. Kemerlis <vpk@cs.brown.edu>
>> + *   Juerg Haefliger <juerg.haefliger@hpe.com>
>> + *
>> + * This program is free software; you can redistribute it and/or modify it
>> + * under the terms of the GNU General Public License version 2 as published by
>> + * the Free Software Foundation.
>> + */
>> +
>> +#ifndef _LINUX_XPFO_H
>> +#define _LINUX_XPFO_H
>> +
>> +#ifdef CONFIG_XPFO
>> +
>> +/*
>> + * XPFO page flags:
>> + *
>> + * PG_XPFO_user_fp denotes that the page is allocated to user space. This flag
>> + * is used in the fast path, where the page is marked accordingly but *not*
>> + * unmapped from the kernel. In most cases, the kernel will need access to the
>> + * page immediately after its acquisition so an unnecessary mapping operation
>> + * is avoided.
>> + *
>> + * PG_XPFO_user denotes that the page is destined for user space. This flag is
>> + * used in the slow path, where the page needs to be mapped/unmapped when the
>> + * kernel wants to access it. If a page is deallocated and this flag is set,
>> + * the page is cleared and mapped back into the kernel.
>> + *
>> + * PG_XPFO_kernel denotes a page that is destined to kernel space. This is used
>> + * for identifying pages that are first assigned to kernel space and then freed
>> + * and mapped to user space. In such cases, an expensive TLB shootdown is
>> + * necessary. Pages allocated to user space, freed, and subsequently allocated
>> + * to user space again, require only local TLB invalidation.
>> + *
>> + * PG_XPFO_zap indicates that the page has been zapped. This flag is used to
>> + * avoid zapping pages multiple times. Whenever a page is freed and was
>> + * previously mapped to user space, it needs to be zapped before mapped back
>> + * in to the kernel.
>> + */
>> +
>> +enum xpfo_pageflags {
>> +	PG_XPFO_user_fp,
>> +	PG_XPFO_user,
>> +	PG_XPFO_kernel,
>> +	PG_XPFO_zap,
>> +};
>> +
>> +struct xpfo_info {
>> +	unsigned long flags;	/* Flags for tracking the page's XPFO state */
>> +	atomic_t mapcount;	/* Counter for balancing page map/unmap
>> +				 * requests. Only the first map request maps
>> +				 * the page back to kernel space. Likewise,
>> +				 * only the last unmap request unmaps the page.
>> +				 */
>> +	spinlock_t lock;	/* Lock to serialize concurrent map/unmap
>> +				 * requests.
>> +				 */
>> +};
>> +
>> +extern void xpfo_clear_zap(struct page *page, int order);
>> +extern int xpfo_test_and_clear_zap(struct page *page);
>> +extern int xpfo_test_kernel(struct page *page);
>> +extern int xpfo_test_user(struct page *page);
>> +
>> +extern void xpfo_kmap(void *kaddr, struct page *page);
>> +extern void xpfo_kunmap(void *kaddr, struct page *page);
>> +extern void xpfo_alloc_page(struct page *page, int order, gfp_t gfp);
>> +extern void xpfo_free_page(struct page *page, int order);
>> +
>> +#else /* ifdef CONFIG_XPFO */
>> +
>> +static inline void xpfo_clear_zap(struct page *page, int order) { }
>> +static inline int xpfo_test_and_clear_zap(struct page *page) { return 0; }
>> +static inline int xpfo_test_kernel(struct page *page) { return 0; }
>> +static inline int xpfo_test_user(struct page *page) { return 0; }
>> +
>> +static inline void xpfo_kmap(void *kaddr, struct page *page) { }
>> +static inline void xpfo_kunmap(void *kaddr, struct page *page) { }
>> +static inline void xpfo_alloc_page(struct page *page, int order, gfp_t gfp) { }
>> +static inline void xpfo_free_page(struct page *page, int order) { }
>> +
>> +#endif /* ifdef CONFIG_XPFO */
>> +
>> +#endif /* ifndef _LINUX_XPFO_H */
>> diff --git a/lib/swiotlb.c b/lib/swiotlb.c
>> index 76f29ec..cf57ee9 100644
>> --- a/lib/swiotlb.c
>> +++ b/lib/swiotlb.c
>> @@ -390,8 +390,9 @@ static void swiotlb_bounce(phys_addr_t orig_addr, phys_addr_t tlb_addr,
>>  {
>>  	unsigned long pfn = PFN_DOWN(orig_addr);
>>  	unsigned char *vaddr = phys_to_virt(tlb_addr);
>> +	struct page *page = pfn_to_page(pfn);
>>  
>> -	if (PageHighMem(pfn_to_page(pfn))) {
>> +	if (PageHighMem(page) || xpfo_test_user(page)) {
>>  		/* The buffer does not have a mapping.  Map it in and copy */
>>  		unsigned int offset = orig_addr & ~PAGE_MASK;
>>  		char *buffer;
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 838ca8bb..47b42a3 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1003,6 +1003,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
>>  	}
>>  	arch_free_page(page, order);
>>  	kernel_map_pages(page, 1 << order, 0);
>> +	xpfo_free_page(page, order);
>>  
>>  	return true;
>>  }
>> @@ -1398,10 +1399,13 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
>>  	arch_alloc_page(page, order);
>>  	kernel_map_pages(page, 1 << order, 1);
>>  	kasan_alloc_pages(page, order);
>> +	xpfo_alloc_page(page, order, gfp_flags);
>>  
>>  	if (gfp_flags & __GFP_ZERO)
>>  		for (i = 0; i < (1 << order); i++)
>>  			clear_highpage(page + i);
>> +	else
>> +		xpfo_clear_zap(page, order);
>>  
>>  	if (order && (gfp_flags & __GFP_COMP))
>>  		prep_compound_page(page, order);
>> @@ -2072,10 +2076,11 @@ void free_hot_cold_page(struct page *page, bool cold)
>>  	}
>>  
>>  	pcp = &this_cpu_ptr(zone->pageset)->pcp;
>> -	if (!cold)
>> +	if (!cold && !xpfo_test_kernel(page))
>>  		list_add(&page->lru, &pcp->lists[migratetype]);
>>  	else
>>  		list_add_tail(&page->lru, &pcp->lists[migratetype]);
>> +
>>  	pcp->count++;
>>  	if (pcp->count >= pcp->high) {
>>  		unsigned long batch = READ_ONCE(pcp->batch);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
