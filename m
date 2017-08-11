Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 28ECF6B025F
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 14:01:52 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id d136so20916878qkg.11
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 11:01:52 -0700 (PDT)
Received: from mail-qt0-f179.google.com (mail-qt0-f179.google.com. [209.85.216.179])
        by mx.google.com with ESMTPS id v4si1278041qtb.16.2017.08.11.11.01.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 11:01:51 -0700 (PDT)
Received: by mail-qt0-f179.google.com with SMTP id 16so25262592qtz.4
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 11:01:50 -0700 (PDT)
Subject: Re: [kernel-hardening] [PATCH v5 05/10] arm64/mm: Add support for
 XPFO
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-6-tycho@docker.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <b883c93d-93fa-2536-b050-e67360246530@redhat.com>
Date: Fri, 11 Aug 2017 11:01:46 -0700
MIME-Version: 1.0
In-Reply-To: <20170809200755.11234-6-tycho@docker.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>

On 08/09/2017 01:07 PM, Tycho Andersen wrote:
> From: Juerg Haefliger <juerg.haefliger@hpe.com>
> 
> Enable support for eXclusive Page Frame Ownership (XPFO) for arm64 and
> provide a hook for updating a single kernel page table entry (which is
> required by the generic XPFO code).
> 
> At the moment, only 64k page sizes are supported.
> 

Can you add a note somewhere explaining this limitation or what's
on the TODO list?

> Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
> Tested-by: Tycho Andersen <tycho@docker.com>
> ---
>  arch/arm64/Kconfig     |  1 +
>  arch/arm64/mm/Makefile |  2 ++
>  arch/arm64/mm/xpfo.c   | 64 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 67 insertions(+)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index dfd908630631..2ddae41e0793 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -121,6 +121,7 @@ config ARM64
>  	select SPARSE_IRQ
>  	select SYSCTL_EXCEPTION_TRACE
>  	select THREAD_INFO_IN_TASK
> +	select ARCH_SUPPORTS_XPFO if ARM64_64K_PAGES
>  	help
>  	  ARM 64-bit (AArch64) Linux support.
>  
> diff --git a/arch/arm64/mm/Makefile b/arch/arm64/mm/Makefile
> index 9b0ba191e48e..22e5cab543d8 100644
> --- a/arch/arm64/mm/Makefile
> +++ b/arch/arm64/mm/Makefile
> @@ -11,3 +11,5 @@ KASAN_SANITIZE_physaddr.o	+= n
>  
>  obj-$(CONFIG_KASAN)		+= kasan_init.o
>  KASAN_SANITIZE_kasan_init.o	:= n
> +
> +obj-$(CONFIG_XPFO)		+= xpfo.o
> diff --git a/arch/arm64/mm/xpfo.c b/arch/arm64/mm/xpfo.c
> new file mode 100644
> index 000000000000..de03a652d48a
> --- /dev/null
> +++ b/arch/arm64/mm/xpfo.c
> @@ -0,0 +1,64 @@
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
> +	BUG_ON(pgd_bad(*pgd));
> +
> +	pud = pud_offset(pgd, addr);
> +	if (pud_none(*pud))
> +		return NULL;
> +
> +	BUG_ON(pud_bad(*pud));
> +
> +	pmd = pmd_offset(pud, addr);
> +	if (pmd_none(*pmd))
> +		return NULL;
> +
> +	BUG_ON(pmd_bad(*pmd));
> +
> +	return pte_offset_kernel(pmd, addr);
> +}

We already have much of this logic implemented for kernel_page_present
in arch/arm64/mm/pageattr.c, we should move this into there and
make this common, similar to x86

> +
> +/* Update a single kernel page table entry */
> +inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot)
> +{
> +	pte_t *pte = lookup_address((unsigned long)kaddr);
> +
> +	set_pte(pte, pfn_pte(page_to_pfn(page), prot));
> +}
> +
> +inline void xpfo_flush_kernel_page(struct page *page, int order)
> +{
> +	unsigned long kaddr = (unsigned long)page_address(page);
> +	unsigned long size = PAGE_SIZE;
> +
> +	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
> +}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
