Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E28566B0038
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 05:57:00 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c4so58410016pfb.7
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 02:57:00 -0800 (PST)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id b3si10263702plb.131.2016.11.24.02.56.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 02:56:59 -0800 (PST)
Received: by mail-pf0-x232.google.com with SMTP id i88so9696969pfk.2
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 02:56:59 -0800 (PST)
Date: Thu, 24 Nov 2016 19:56:30 +0900
From: AKASHI Takahiro <takahiro.akashi@linaro.org>
Subject: Re: [RFC PATCH v3 1/2] Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20161124105629.GA23034@linaro.org>
References: <20160914071901.8127-1-juerg.haefliger@hpe.com>
 <20161104144534.14790-1-juerg.haefliger@hpe.com>
 <20161104144534.14790-2-juerg.haefliger@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161104144534.14790-2-juerg.haefliger@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juerg Haefliger <juerg.haefliger@hpe.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-x86_64@vger.kernel.org, vpk@cs.columbia.edu

Hi,

I'm trying to give it a spin on arm64, but ...

On Fri, Nov 04, 2016 at 03:45:33PM +0100, Juerg Haefliger wrote:
> This patch adds support for XPFO which protects against 'ret2dir' kernel
> attacks. The basic idea is to enforce exclusive ownership of page frames
> by either the kernel or userspace, unless explicitly requested by the
> kernel. Whenever a page destined for userspace is allocated, it is
> unmapped from physmap (the kernel's page table). When such a page is
> reclaimed from userspace, it is mapped back to physmap.
> 
> Additional fields in the page_ext struct are used for XPFO housekeeping.
> Specifically two flags to distinguish user vs. kernel pages and to tag
> unmapped pages and a reference counter to balance kmap/kunmap operations
> and a lock to serialize access to the XPFO fields.
> 
> Known issues/limitations:
>   - Only supports x86-64 (for now)
>   - Only supports 4k pages (for now)
>   - There are most likely some legitimate uses cases where the kernel needs
>     to access userspace which need to be made XPFO-aware
>   - Performance penalty
> 
> Reference paper by the original patch authors:
>   http://www.cs.columbia.edu/~vpk/papers/ret2dir.sec14.pdf
> 
> Suggested-by: Vasileios P. Kemerlis <vpk@cs.columbia.edu>
> Signed-off-by: Juerg Haefliger <juerg.haefliger@hpe.com>
> ---
>  arch/x86/Kconfig         |   3 +-
>  arch/x86/mm/init.c       |   2 +-
>  drivers/ata/libata-sff.c |   4 +-
>  include/linux/highmem.h  |  15 +++-
>  include/linux/page_ext.h |   7 ++
>  include/linux/xpfo.h     |  39 +++++++++
>  lib/swiotlb.c            |   3 +-
>  mm/Makefile              |   1 +
>  mm/page_alloc.c          |   2 +
>  mm/page_ext.c            |   4 +
>  mm/xpfo.c                | 206 +++++++++++++++++++++++++++++++++++++++++++++++
>  security/Kconfig         |  19 +++++
>  12 files changed, 298 insertions(+), 7 deletions(-)
>  create mode 100644 include/linux/xpfo.h
>  create mode 100644 mm/xpfo.c
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index bada636d1065..38b334f8fde5 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -165,6 +165,7 @@ config X86
>  	select HAVE_STACK_VALIDATION		if X86_64
>  	select ARCH_USES_HIGH_VMA_FLAGS		if X86_INTEL_MEMORY_PROTECTION_KEYS
>  	select ARCH_HAS_PKEYS			if X86_INTEL_MEMORY_PROTECTION_KEYS
> +	select ARCH_SUPPORTS_XPFO		if X86_64
>  
>  config INSTRUCTION_DECODER
>  	def_bool y
> @@ -1361,7 +1362,7 @@ config ARCH_DMA_ADDR_T_64BIT
>  
>  config X86_DIRECT_GBPAGES
>  	def_bool y
> -	depends on X86_64 && !DEBUG_PAGEALLOC && !KMEMCHECK
> +	depends on X86_64 && !DEBUG_PAGEALLOC && !KMEMCHECK && !XPFO
>  	---help---
>  	  Certain kernel features effectively disable kernel
>  	  linear 1 GB mappings (even if the CPU otherwise
> diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
> index 22af912d66d2..a6fafbae02bb 100644
> --- a/arch/x86/mm/init.c
> +++ b/arch/x86/mm/init.c
> @@ -161,7 +161,7 @@ static int page_size_mask;
>  
>  static void __init probe_page_size_mask(void)
>  {
> -#if !defined(CONFIG_KMEMCHECK)
> +#if !defined(CONFIG_KMEMCHECK) && !defined(CONFIG_XPFO)
>  	/*
>  	 * For CONFIG_KMEMCHECK or pagealloc debugging, identity mapping will
>  	 * use small pages.
> diff --git a/drivers/ata/libata-sff.c b/drivers/ata/libata-sff.c
> index 051b6158d1b7..58af734be25d 100644
> --- a/drivers/ata/libata-sff.c
> +++ b/drivers/ata/libata-sff.c
> @@ -715,7 +715,7 @@ static void ata_pio_sector(struct ata_queued_cmd *qc)
>  
>  	DPRINTK("data %s\n", qc->tf.flags & ATA_TFLAG_WRITE ? "write" : "read");
>  
> -	if (PageHighMem(page)) {
> +	if (PageHighMem(page) || xpfo_page_is_unmapped(page)) {
>  		unsigned long flags;
>  
>  		/* FIXME: use a bounce buffer */
> @@ -860,7 +860,7 @@ static int __atapi_pio_bytes(struct ata_queued_cmd *qc, unsigned int bytes)
>  
>  	DPRINTK("data %s\n", qc->tf.flags & ATA_TFLAG_WRITE ? "write" : "read");
>  
> -	if (PageHighMem(page)) {
> +	if (PageHighMem(page) || xpfo_page_is_unmapped(page)) {
>  		unsigned long flags;
>  
>  		/* FIXME: use bounce buffer */
> diff --git a/include/linux/highmem.h b/include/linux/highmem.h
> index bb3f3297062a..7a17c166532f 100644
> --- a/include/linux/highmem.h
> +++ b/include/linux/highmem.h
> @@ -7,6 +7,7 @@
>  #include <linux/mm.h>
>  #include <linux/uaccess.h>
>  #include <linux/hardirq.h>
> +#include <linux/xpfo.h>
>  
>  #include <asm/cacheflush.h>
>  
> @@ -55,24 +56,34 @@ static inline struct page *kmap_to_page(void *addr)
>  #ifndef ARCH_HAS_KMAP
>  static inline void *kmap(struct page *page)
>  {
> +	void *kaddr;
> +
>  	might_sleep();
> -	return page_address(page);
> +	kaddr = page_address(page);
> +	xpfo_kmap(kaddr, page);
> +	return kaddr;
>  }
>  
>  static inline void kunmap(struct page *page)
>  {
> +	xpfo_kunmap(page_address(page), page);
>  }
>  
>  static inline void *kmap_atomic(struct page *page)
>  {
> +	void *kaddr;
> +
>  	preempt_disable();
>  	pagefault_disable();
> -	return page_address(page);
> +	kaddr = page_address(page);
> +	xpfo_kmap(kaddr, page);
> +	return kaddr;
>  }
>  #define kmap_atomic_prot(page, prot)	kmap_atomic(page)
>  
>  static inline void __kunmap_atomic(void *addr)
>  {
> +	xpfo_kunmap(addr, virt_to_page(addr));
>  	pagefault_enable();
>  	preempt_enable();
>  }
> diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
> index 9298c393ddaa..0e451a42e5a3 100644
> --- a/include/linux/page_ext.h
> +++ b/include/linux/page_ext.h
> @@ -29,6 +29,8 @@ enum page_ext_flags {
>  	PAGE_EXT_DEBUG_POISON,		/* Page is poisoned */
>  	PAGE_EXT_DEBUG_GUARD,
>  	PAGE_EXT_OWNER,
> +	PAGE_EXT_XPFO_KERNEL,		/* Page is a kernel page */
> +	PAGE_EXT_XPFO_UNMAPPED,		/* Page is unmapped */
>  #if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)
>  	PAGE_EXT_YOUNG,
>  	PAGE_EXT_IDLE,
> @@ -44,6 +46,11 @@ enum page_ext_flags {
>   */
>  struct page_ext {
>  	unsigned long flags;
> +#ifdef CONFIG_XPFO
> +	int inited;		/* Map counter and lock initialized */
> +	atomic_t mapcount;	/* Counter for balancing map/unmap requests */
> +	spinlock_t maplock;	/* Lock to serialize map/unmap requests */
> +#endif
>  };
>  
>  extern void pgdat_page_ext_init(struct pglist_data *pgdat);
> diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
> new file mode 100644
> index 000000000000..77187578ca33
> --- /dev/null
> +++ b/include/linux/xpfo.h
> @@ -0,0 +1,39 @@
> +/*
> + * Copyright (C) 2016 Hewlett Packard Enterprise Development, L.P.
> + * Copyright (C) 2016 Brown University. All rights reserved.
> + *
> + * Authors:
> + *   Juerg Haefliger <juerg.haefliger@hpe.com>
> + *   Vasileios P. Kemerlis <vpk@cs.brown.edu>
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License version 2 as published by
> + * the Free Software Foundation.
> + */
> +
> +#ifndef _LINUX_XPFO_H
> +#define _LINUX_XPFO_H
> +
> +#ifdef CONFIG_XPFO
> +
> +extern struct page_ext_operations page_xpfo_ops;
> +
> +extern void xpfo_kmap(void *kaddr, struct page *page);
> +extern void xpfo_kunmap(void *kaddr, struct page *page);
> +extern void xpfo_alloc_page(struct page *page, int order, gfp_t gfp);
> +extern void xpfo_free_page(struct page *page, int order);
> +
> +extern bool xpfo_page_is_unmapped(struct page *page);
> +
> +#else /* !CONFIG_XPFO */
> +
> +static inline void xpfo_kmap(void *kaddr, struct page *page) { }
> +static inline void xpfo_kunmap(void *kaddr, struct page *page) { }
> +static inline void xpfo_alloc_page(struct page *page, int order, gfp_t gfp) { }
> +static inline void xpfo_free_page(struct page *page, int order) { }
> +
> +static inline bool xpfo_page_is_unmapped(struct page *page) { return false; }
> +
> +#endif /* CONFIG_XPFO */
> +
> +#endif /* _LINUX_XPFO_H */
> diff --git a/lib/swiotlb.c b/lib/swiotlb.c
> index 22e13a0e19d7..455eff44604e 100644
> --- a/lib/swiotlb.c
> +++ b/lib/swiotlb.c
> @@ -390,8 +390,9 @@ static void swiotlb_bounce(phys_addr_t orig_addr, phys_addr_t tlb_addr,
>  {
>  	unsigned long pfn = PFN_DOWN(orig_addr);
>  	unsigned char *vaddr = phys_to_virt(tlb_addr);
> +	struct page *page = pfn_to_page(pfn);
>  
> -	if (PageHighMem(pfn_to_page(pfn))) {
> +	if (PageHighMem(page) || xpfo_page_is_unmapped(page)) {
>  		/* The buffer does not have a mapping.  Map it in and copy */
>  		unsigned int offset = orig_addr & ~PAGE_MASK;
>  		char *buffer;
> diff --git a/mm/Makefile b/mm/Makefile
> index 295bd7a9f76b..175680f516aa 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -100,3 +100,4 @@ obj-$(CONFIG_IDLE_PAGE_TRACKING) += page_idle.o
>  obj-$(CONFIG_FRAME_VECTOR) += frame_vector.o
>  obj-$(CONFIG_DEBUG_PAGE_REF) += debug_page_ref.o
>  obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
> +obj-$(CONFIG_XPFO) += xpfo.o
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8fd42aa7c4bd..100e80e008e2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1045,6 +1045,7 @@ static __always_inline bool free_pages_prepare(struct page *page,
>  	kernel_poison_pages(page, 1 << order, 0);
>  	kernel_map_pages(page, 1 << order, 0);
>  	kasan_free_pages(page, order);
> +	xpfo_free_page(page, order);
>  
>  	return true;
>  }
> @@ -1745,6 +1746,7 @@ inline void post_alloc_hook(struct page *page, unsigned int order,
>  	kernel_map_pages(page, 1 << order, 1);
>  	kernel_poison_pages(page, 1 << order, 1);
>  	kasan_alloc_pages(page, order);
> +	xpfo_alloc_page(page, order, gfp_flags);
>  	set_page_owner(page, order, gfp_flags);
>  }
>  
> diff --git a/mm/page_ext.c b/mm/page_ext.c
> index 121dcffc4ec1..ba6dbcacc2db 100644
> --- a/mm/page_ext.c
> +++ b/mm/page_ext.c
> @@ -7,6 +7,7 @@
>  #include <linux/kmemleak.h>
>  #include <linux/page_owner.h>
>  #include <linux/page_idle.h>
> +#include <linux/xpfo.h>
>  
>  /*
>   * struct page extension
> @@ -68,6 +69,9 @@ static struct page_ext_operations *page_ext_ops[] = {
>  #if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)
>  	&page_idle_ops,
>  #endif
> +#ifdef CONFIG_XPFO
> +	&page_xpfo_ops,
> +#endif
>  };
>  
>  static unsigned long total_usage;
> diff --git a/mm/xpfo.c b/mm/xpfo.c
> new file mode 100644
> index 000000000000..8e3a6a694b6a
> --- /dev/null
> +++ b/mm/xpfo.c
> @@ -0,0 +1,206 @@
> +/*
> + * Copyright (C) 2016 Hewlett Packard Enterprise Development, L.P.
> + * Copyright (C) 2016 Brown University. All rights reserved.
> + *
> + * Authors:
> + *   Juerg Haefliger <juerg.haefliger@hpe.com>
> + *   Vasileios P. Kemerlis <vpk@cs.brown.edu>
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License version 2 as published by
> + * the Free Software Foundation.
> + */
> +
> +#include <linux/mm.h>
> +#include <linux/module.h>
> +#include <linux/page_ext.h>
> +#include <linux/xpfo.h>
> +
> +#include <asm/tlbflush.h>
> +
> +DEFINE_STATIC_KEY_FALSE(xpfo_inited);
> +
> +static bool need_xpfo(void)
> +{
> +	return true;
> +}
> +
> +static void init_xpfo(void)
> +{
> +	printk(KERN_INFO "XPFO enabled\n");
> +	static_branch_enable(&xpfo_inited);
> +}
> +
> +struct page_ext_operations page_xpfo_ops = {
> +	.need = need_xpfo,
> +	.init = init_xpfo,
> +};
> +
> +/*
> + * Update a single kernel page table entry
> + */
> +static inline void set_kpte(struct page *page, unsigned long kaddr,
> +			    pgprot_t prot) {
> +	unsigned int level;
> +	pte_t *kpte = lookup_address(kaddr, &level);
> +
> +	/* We only support 4k pages for now */
> +	BUG_ON(!kpte || level != PG_LEVEL_4K);
> +
> +	set_pte_atomic(kpte, pfn_pte(page_to_pfn(page), canon_pgprot(prot)));
> +}

As lookup_address() and set_pte_atomic() (and PG_LEVEL_4K), are arch-specific,
would it be better to put the whole definition into arch-specific part?

> +
> +void xpfo_alloc_page(struct page *page, int order, gfp_t gfp)
> +{
> +	int i, flush_tlb = 0;
> +	struct page_ext *page_ext;
> +	unsigned long kaddr;
> +
> +	if (!static_branch_unlikely(&xpfo_inited))
> +		return;
> +
> +	for (i = 0; i < (1 << order); i++)  {
> +		page_ext = lookup_page_ext(page + i);
> +
> +		BUG_ON(test_bit(PAGE_EXT_XPFO_UNMAPPED, &page_ext->flags));
> +
> +		/* Initialize the map lock and map counter */
> +		if (!page_ext->inited) {
> +			spin_lock_init(&page_ext->maplock);
> +			atomic_set(&page_ext->mapcount, 0);
> +			page_ext->inited = 1;
> +		}
> +		BUG_ON(atomic_read(&page_ext->mapcount));
> +
> +		if ((gfp & GFP_HIGHUSER) == GFP_HIGHUSER) {
> +			/*
> +			 * Flush the TLB if the page was previously allocated
> +			 * to the kernel.
> +			 */
> +			if (test_and_clear_bit(PAGE_EXT_XPFO_KERNEL,
> +					       &page_ext->flags))
> +				flush_tlb = 1;
> +		} else {
> +			/* Tag the page as a kernel page */
> +			set_bit(PAGE_EXT_XPFO_KERNEL, &page_ext->flags);
> +		}
> +	}
> +
> +	if (flush_tlb) {
> +		kaddr = (unsigned long)page_address(page);
> +		flush_tlb_kernel_range(kaddr, kaddr + (1 << order) *
> +				       PAGE_SIZE);
> +	}
> +}
> +
> +void xpfo_free_page(struct page *page, int order)
> +{
> +	int i;
> +	struct page_ext *page_ext;
> +	unsigned long kaddr;
> +
> +	if (!static_branch_unlikely(&xpfo_inited))
> +		return;
> +
> +	for (i = 0; i < (1 << order); i++) {
> +		page_ext = lookup_page_ext(page + i);
> +
> +		if (!page_ext->inited) {
> +			/*
> +			 * The page was allocated before page_ext was
> +			 * initialized, so it is a kernel page and it needs to
> +			 * be tagged accordingly.
> +			 */
> +			set_bit(PAGE_EXT_XPFO_KERNEL, &page_ext->flags);
> +			continue;
> +		}
> +
> +		/*
> +		 * Map the page back into the kernel if it was previously
> +		 * allocated to user space.
> +		 */
> +		if (test_and_clear_bit(PAGE_EXT_XPFO_UNMAPPED,
> +				       &page_ext->flags)) {
> +			kaddr = (unsigned long)page_address(page + i);
> +			set_kpte(page + i,  kaddr, __pgprot(__PAGE_KERNEL));

Why not PAGE_KERNEL?

> +		}
> +	}
> +}
> +
> +void xpfo_kmap(void *kaddr, struct page *page)
> +{
> +	struct page_ext *page_ext;
> +	unsigned long flags;
> +
> +	if (!static_branch_unlikely(&xpfo_inited))
> +		return;
> +
> +	page_ext = lookup_page_ext(page);
> +
> +	/*
> +	 * The page was allocated before page_ext was initialized (which means
> +	 * it's a kernel page) or it's allocated to the kernel, so nothing to
> +	 * do.
> +	 */
> +	if (!page_ext->inited ||
> +	    test_bit(PAGE_EXT_XPFO_KERNEL, &page_ext->flags))
> +		return;
> +
> +	spin_lock_irqsave(&page_ext->maplock, flags);
> +
> +	/*
> +	 * The page was previously allocated to user space, so map it back
> +	 * into the kernel. No TLB flush required.
> +	 */
> +	if ((atomic_inc_return(&page_ext->mapcount) == 1) &&
> +	    test_and_clear_bit(PAGE_EXT_XPFO_UNMAPPED, &page_ext->flags))
> +		set_kpte(page, (unsigned long)kaddr, __pgprot(__PAGE_KERNEL));
> +
> +	spin_unlock_irqrestore(&page_ext->maplock, flags);
> +}
> +EXPORT_SYMBOL(xpfo_kmap);
> +
> +void xpfo_kunmap(void *kaddr, struct page *page)
> +{
> +	struct page_ext *page_ext;
> +	unsigned long flags;
> +
> +	if (!static_branch_unlikely(&xpfo_inited))
> +		return;
> +
> +	page_ext = lookup_page_ext(page);
> +
> +	/*
> +	 * The page was allocated before page_ext was initialized (which means
> +	 * it's a kernel page) or it's allocated to the kernel, so nothing to
> +	 * do.
> +	 */
> +	if (!page_ext->inited ||
> +	    test_bit(PAGE_EXT_XPFO_KERNEL, &page_ext->flags))
> +		return;
> +
> +	spin_lock_irqsave(&page_ext->maplock, flags);
> +
> +	/*
> +	 * The page is to be allocated back to user space, so unmap it from the
> +	 * kernel, flush the TLB and tag it as a user page.
> +	 */
> +	if (atomic_dec_return(&page_ext->mapcount) == 0) {
> +		BUG_ON(test_bit(PAGE_EXT_XPFO_UNMAPPED, &page_ext->flags));
> +		set_bit(PAGE_EXT_XPFO_UNMAPPED, &page_ext->flags);
> +		set_kpte(page, (unsigned long)kaddr, __pgprot(0));
> +		__flush_tlb_one((unsigned long)kaddr);

Again __flush_tlb_one() is x86-specific.
flush_tlb_kernel_range() instead?

Thanks,
-Takahiro AKASHI

> +	}
> +
> +	spin_unlock_irqrestore(&page_ext->maplock, flags);
> +}
> +EXPORT_SYMBOL(xpfo_kunmap);
> +
> +inline bool xpfo_page_is_unmapped(struct page *page)
> +{
> +	if (!static_branch_unlikely(&xpfo_inited))
> +		return false;
> +
> +	return test_bit(PAGE_EXT_XPFO_UNMAPPED, &lookup_page_ext(page)->flags);
> +}
> +EXPORT_SYMBOL(xpfo_page_is_unmapped);
> diff --git a/security/Kconfig b/security/Kconfig
> index 118f4549404e..4502e15c8419 100644
> --- a/security/Kconfig
> +++ b/security/Kconfig
> @@ -6,6 +6,25 @@ menu "Security options"
>  
>  source security/keys/Kconfig
>  
> +config ARCH_SUPPORTS_XPFO
> +	bool
> +
> +config XPFO
> +	bool "Enable eXclusive Page Frame Ownership (XPFO)"
> +	default n
> +	depends on ARCH_SUPPORTS_XPFO
> +	select PAGE_EXTENSION
> +	help
> +	  This option offers protection against 'ret2dir' kernel attacks.
> +	  When enabled, every time a page frame is allocated to user space, it
> +	  is unmapped from the direct mapped RAM region in kernel space
> +	  (physmap). Similarly, when a page frame is freed/reclaimed, it is
> +	  mapped back to physmap.
> +
> +	  There is a slight performance impact when this option is enabled.
> +
> +	  If in doubt, say "N".
> +
>  config SECURITY_DMESG_RESTRICT
>  	bool "Restrict unprivileged access to the kernel syslog"
>  	default n
> -- 
> 2.10.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
