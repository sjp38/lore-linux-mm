Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id B4DE08E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 09:25:22 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 80so2056596qkd.0
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 06:25:22 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id y31si990039qvf.184.2019.01.23.06.25.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 06:25:21 -0800 (PST)
Date: Wed, 23 Jan 2019 09:24:13 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFC PATCH v7 05/16] arm64/mm: Add support for XPFO
Message-ID: <20190123142410.GC19289@Konrads-MacBook-Pro.local>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
 <89f03091af87f5ab27bd6cafb032236d5bd81d65.1547153058.git.khalid.aziz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <89f03091af87f5ab27bd6cafb032236d5bd81d65.1547153058.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com, torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com, Juerg Haefliger <juerg.haefliger@canonical.com>, deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Tycho Andersen <tycho@docker.com>

On Thu, Jan 10, 2019 at 02:09:37PM -0700, Khalid Aziz wrote:
> From: Juerg Haefliger <juerg.haefliger@canonical.com>
> 
> Enable support for eXclusive Page Frame Ownership (XPFO) for arm64 and
> provide a hook for updating a single kernel page table entry (which is
> required by the generic XPFO code).
> 
> v6: use flush_tlb_kernel_range() instead of __flush_tlb_one()
> 
> CC: linux-arm-kernel@lists.infradead.org
> Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
> Signed-off-by: Tycho Andersen <tycho@docker.com>
> Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
> ---
>  arch/arm64/Kconfig     |  1 +
>  arch/arm64/mm/Makefile |  2 ++
>  arch/arm64/mm/xpfo.c   | 58 ++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 61 insertions(+)
>  create mode 100644 arch/arm64/mm/xpfo.c
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index ea2ab0330e3a..f0a9c0007d23 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -171,6 +171,7 @@ config ARM64
>  	select SWIOTLB
>  	select SYSCTL_EXCEPTION_TRACE
>  	select THREAD_INFO_IN_TASK
> +	select ARCH_SUPPORTS_XPFO
>  	help
>  	  ARM 64-bit (AArch64) Linux support.
>  
> diff --git a/arch/arm64/mm/Makefile b/arch/arm64/mm/Makefile
> index 849c1df3d214..cca3808d9776 100644
> --- a/arch/arm64/mm/Makefile
> +++ b/arch/arm64/mm/Makefile
> @@ -12,3 +12,5 @@ KASAN_SANITIZE_physaddr.o	+= n
>  
>  obj-$(CONFIG_KASAN)		+= kasan_init.o
>  KASAN_SANITIZE_kasan_init.o	:= n
> +
> +obj-$(CONFIG_XPFO)		+= xpfo.o
> diff --git a/arch/arm64/mm/xpfo.c b/arch/arm64/mm/xpfo.c
> new file mode 100644
> index 000000000000..678e2be848eb
> --- /dev/null
> +++ b/arch/arm64/mm/xpfo.c
> @@ -0,0 +1,58 @@
> +/*
> + * Copyright (C) 2017 Hewlett Packard Enterprise Development, L.P.
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
> +
> +#include <asm/tlbflush.h>
> +
> +/*
> + * Lookup the page table entry for a virtual address and return a pointer to
> + * the entry. Based on x86 tree.
> + */
> +static pte_t *lookup_address(unsigned long addr)
> +{
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +
> +	pgd = pgd_offset_k(addr);
> +	if (pgd_none(*pgd))
> +		return NULL;
> +
> +	pud = pud_offset(pgd, addr);
> +	if (pud_none(*pud))
> +		return NULL;
> +
> +	pmd = pmd_offset(pud, addr);
> +	if (pmd_none(*pmd))
> +		return NULL;
> +
> +	return pte_offset_kernel(pmd, addr);
> +}
> +
> +/* Update a single kernel page table entry */
> +inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot)
> +{
> +	pte_t *pte = lookup_address((unsigned long)kaddr);
> +
> +	set_pte(pte, pfn_pte(page_to_pfn(page), prot));

Thought on the other hand.. what if the page is PMD? Do you really want
to do this?

What if 'pte' is NULL?
> +}
> +
> +inline void xpfo_flush_kernel_tlb(struct page *page, int order)
> +{
> +	unsigned long kaddr = (unsigned long)page_address(page);
> +	unsigned long size = PAGE_SIZE;
> +
> +	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);

Ditto here. You are assuming it is PTE, but it may be PMD or such.
Or worts - the lookup_address could be NULL.

> +}
> -- 
> 2.17.1
> 
