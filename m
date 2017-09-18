Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 07FD06B0038
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 17:27:39 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id v140so3697507ita.3
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 14:27:39 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x138sor3782043oix.224.2017.09.18.14.27.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Sep 2017 14:27:37 -0700 (PDT)
Date: Mon, 18 Sep 2017 15:27:34 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [kernel-hardening] [PATCH v6 05/11] arm64/mm: Add support for
 XPFO
Message-ID: <20170918212734.6ympyqfqzyd6kv35@docker>
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-6-tycho@docker.com>
 <20170914182205.GA1711@remoulade>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170914182205.GA1711@remoulade>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, linux-arm-kernel@lists.infradead.org

Hi Mark,

On Thu, Sep 14, 2017 at 07:22:08PM +0100, Mark Rutland wrote:
> Hi,
> 
> On Thu, Sep 07, 2017 at 11:36:03AM -0600, Tycho Andersen wrote:
> > From: Juerg Haefliger <juerg.haefliger@canonical.com>
> > 
> > Enable support for eXclusive Page Frame Ownership (XPFO) for arm64 and
> > provide a hook for updating a single kernel page table entry (which is
> > required by the generic XPFO code).
> > 
> > v6: use flush_tlb_kernel_range() instead of __flush_tlb_one()
> > 
> > CC: linux-arm-kernel@lists.infradead.org
> > Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
> > Signed-off-by: Tycho Andersen <tycho@docker.com>
> > ---
> >  arch/arm64/Kconfig     |  1 +
> >  arch/arm64/mm/Makefile |  2 ++
> >  arch/arm64/mm/xpfo.c   | 58 ++++++++++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 61 insertions(+)
> > 
> > diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> > index dfd908630631..44fa44ef02ec 100644
> > --- a/arch/arm64/Kconfig
> > +++ b/arch/arm64/Kconfig
> > @@ -121,6 +121,7 @@ config ARM64
> >  	select SPARSE_IRQ
> >  	select SYSCTL_EXCEPTION_TRACE
> >  	select THREAD_INFO_IN_TASK
> > +	select ARCH_SUPPORTS_XPFO
> 
> A bit of a nit, but this list is (intended to be) organised alphabetically.
> Could you please try to retain that?
> 
> i.e. place this between ARCH_SUPPORTS_NUMA_BALANCING and
> ARCH_WANT_COMPAT_IPC_PARSE_VERSION.

Will do.

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
> > index 000000000000..678e2be848eb
> > --- /dev/null
> > +++ b/arch/arm64/mm/xpfo.c
> > @@ -0,0 +1,58 @@
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
> 
> Is this intended for kernel VAs, user VAs, or both?
> 
> There are different constraints for fiddling with either (e.g. holding
> mmap_sem), so we should be clear regarding the intended use-case.

kernel only; I can add a comment noting this.

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
> > +	pud = pud_offset(pgd, addr);
> > +	if (pud_none(*pud))
> > +		return NULL;
> 
> What if it's not none, but not a table?
> 
> I think we chould check pud_sect() here, and/or pud_bad().
> 
> > +
> > +	pmd = pmd_offset(pud, addr);
> > +	if (pmd_none(*pmd))
> > +		return NULL;
> 
> Likewise.

In principle pud_sect() should be okay, because we say that XPFO
doesn't support section mappings yet. I'll add a check for pud_bad().

However, Christoph suggested that we move this to common code and
there it won't be okay.

> > +
> > +	return pte_offset_kernel(pmd, addr);
> > +}
> 
> Given this expects a pte, it might make more sense to call this
> lookup_address_pte() to make that clear.
> 
> > +
> > +/* Update a single kernel page table entry */
> > +inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot)
> > +{
> > +	pte_t *pte = lookup_address((unsigned long)kaddr);
> > +
> > +	set_pte(pte, pfn_pte(page_to_pfn(page), prot));
> 
> We can get NULL from lookup_address(), so this doesn't look right.
> 
> If NULL implies an error, drop a BUG_ON(!pte) before the set_pte.

It does, I'll add this (as a WARN() and then no-op), thanks.

> > +}
> > +
> > +inline void xpfo_flush_kernel_tlb(struct page *page, int order)
> > +{
> > +	unsigned long kaddr = (unsigned long)page_address(page);
> > +	unsigned long size = PAGE_SIZE;
> 
> unsigned long size = PAGE_SIZE << order;
> 
> > +
> > +	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
> 
> ... and this can be simpler.
> 
> I haven't brought myself back up to speed, so it might not be possible, but I
> still think it would be preferable for XPFO to call flush_tlb_kernel_range()
> directly.

I don't think we can, since on x86 it uses smp functions, and in some
cases those aren't safe.

Cheers,

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
