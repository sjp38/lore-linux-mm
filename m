Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0E90E6B025F
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 16:19:21 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j194so4799338oib.15
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 13:19:21 -0700 (PDT)
Received: from mail-io0-x233.google.com (mail-io0-x233.google.com. [2607:f8b0:4001:c06::233])
        by mx.google.com with ESMTPS id 138si1190439oia.62.2017.08.11.13.19.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 13:19:19 -0700 (PDT)
Received: by mail-io0-x233.google.com with SMTP id g35so23829660ioi.3
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 13:19:19 -0700 (PDT)
Date: Fri, 11 Aug 2017 14:19:18 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [kernel-hardening] [PATCH v5 05/10] arm64/mm: Add support for
 XPFO
Message-ID: <20170811201918.rgolw5whuevxyg3k@smitten>
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-6-tycho@docker.com>
 <b883c93d-93fa-2536-b050-e67360246530@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b883c93d-93fa-2536-b050-e67360246530@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>

Hi Laura,

On Fri, Aug 11, 2017 at 11:01:46AM -0700, Laura Abbott wrote:
> On 08/09/2017 01:07 PM, Tycho Andersen wrote:
> > From: Juerg Haefliger <juerg.haefliger@hpe.com>
> > 
> > Enable support for eXclusive Page Frame Ownership (XPFO) for arm64 and
> > provide a hook for updating a single kernel page table entry (which is
> > required by the generic XPFO code).
> > 
> > At the moment, only 64k page sizes are supported.
> > 
> 
> Can you add a note somewhere explaining this limitation or what's
> on the TODO list?

I have a little TODO list in the cover letter, and fixing this is on
it.

As for what the limitation is, I'm not really sure. When I enable e.g.
4k pages, it just hangs as soon as the bootloader branches to the
kernel, and doesn't print the kernel's hello world or anything. This
is much before XPFO's initialization code is even run, so it's
probably something simple, but I haven't figured out what yet.

Cheers,

Tycho

> > Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
> > Tested-by: Tycho Andersen <tycho@docker.com>
> > ---
> >  arch/arm64/Kconfig     |  1 +
> >  arch/arm64/mm/Makefile |  2 ++
> >  arch/arm64/mm/xpfo.c   | 64 ++++++++++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 67 insertions(+)
> > 
> > diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> > index dfd908630631..2ddae41e0793 100644
> > --- a/arch/arm64/Kconfig
> > +++ b/arch/arm64/Kconfig
> > @@ -121,6 +121,7 @@ config ARM64
> >  	select SPARSE_IRQ
> >  	select SYSCTL_EXCEPTION_TRACE
> >  	select THREAD_INFO_IN_TASK
> > +	select ARCH_SUPPORTS_XPFO if ARM64_64K_PAGES
> >  	help
> >  	  ARM 64-bit (AArch64) Linux support.
> >  
> > diff --git a/arch/arm64/mm/Makefile b/arch/arm64/mm/Makefile
> > index 9b0ba191e48e..22e5cab543d8 100644
> > --- a/arch/arm64/mm/Makefile
> > +++ b/arch/arm64/mm/Makefile
> > @@ -11,3 +11,5 @@ KASAN_SANITIZE_physaddr.o	+= n
> >  
> >  obj-$(CONFIG_KASAN)		+= kasan_init.o
> >  KASAN_SANITIZE_kasan_init.o	:= n
> > +
> > +obj-$(CONFIG_XPFO)		+= xpfo.o
> > diff --git a/arch/arm64/mm/xpfo.c b/arch/arm64/mm/xpfo.c
> > new file mode 100644
> > index 000000000000..de03a652d48a
> > --- /dev/null
> > +++ b/arch/arm64/mm/xpfo.c
> > @@ -0,0 +1,64 @@
> > +/*
> > + * Copyright (C) 2017 Hewlett Packard Enterprise Development, L.P.
> > + * Copyright (C) 2016 Brown University. All rights reserved.
> > + *
> > + * Authors:
> > + *   Juerg Haefliger <juerg.haefliger@hpe.com>
> > + *   Vasileios P. Kemerlis <vpk@cs.brown.edu>
> > + *
> > + * This program is free software; you can redistribute it and/or modify it
> > + * under the terms of the GNU General Public License version 2 as published by
> > + * the Free Software Foundation.
> > + */
> > +
> > +#include <linux/mm.h>
> > +#include <linux/module.h>
> > +
> > +#include <asm/tlbflush.h>
> > +
> > +/*
> > + * Lookup the page table entry for a virtual address and return a pointer to
> > + * the entry. Based on x86 tree.
> > + */
> > +static pte_t *lookup_address(unsigned long addr)
> > +{
> > +	pgd_t *pgd;
> > +	pud_t *pud;
> > +	pmd_t *pmd;
> > +
> > +	pgd = pgd_offset_k(addr);
> > +	if (pgd_none(*pgd))
> > +		return NULL;
> > +
> > +	BUG_ON(pgd_bad(*pgd));
> > +
> > +	pud = pud_offset(pgd, addr);
> > +	if (pud_none(*pud))
> > +		return NULL;
> > +
> > +	BUG_ON(pud_bad(*pud));
> > +
> > +	pmd = pmd_offset(pud, addr);
> > +	if (pmd_none(*pmd))
> > +		return NULL;
> > +
> > +	BUG_ON(pmd_bad(*pmd));
> > +
> > +	return pte_offset_kernel(pmd, addr);
> > +}
> 
> We already have much of this logic implemented for kernel_page_present
> in arch/arm64/mm/pageattr.c, we should move this into there and
> make this common, similar to x86
> 
> > +
> > +/* Update a single kernel page table entry */
> > +inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot)
> > +{
> > +	pte_t *pte = lookup_address((unsigned long)kaddr);
> > +
> > +	set_pte(pte, pfn_pte(page_to_pfn(page), prot));
> > +}
> > +
> > +inline void xpfo_flush_kernel_page(struct page *page, int order)
> > +{
> > +	unsigned long kaddr = (unsigned long)page_address(page);
> > +	unsigned long size = PAGE_SIZE;
> > +
> > +	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
> > +}
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
