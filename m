Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id D19576B0038
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 16:56:13 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g32so3538463ioj.0
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 13:56:13 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c129sor3134490iof.189.2017.09.18.13.56.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Sep 2017 13:56:12 -0700 (PDT)
Date: Mon, 18 Sep 2017 14:56:09 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [kernel-hardening] [PATCH v6 10/11] mm: add a user_virt_to_phys
 symbol
Message-ID: <20170918205609.hntcd3nfaq2gjj64@docker>
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-11-tycho@docker.com>
 <20170914183401.GC1711@remoulade>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170914183401.GC1711@remoulade>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, linux-arm-kernel@lists.infradead.org, x86@kernel.org

Hi Mark,

On Thu, Sep 14, 2017 at 07:34:02PM +0100, Mark Rutland wrote:
> On Thu, Sep 07, 2017 at 11:36:08AM -0600, Tycho Andersen wrote:
> > We need someting like this for testing XPFO. Since it's architecture
> > specific, putting it in the test code is slightly awkward, so let's make it
> > an arch-specific symbol and export it for use in LKDTM.
> > 
> > v6: * add a definition of user_virt_to_phys in the !CONFIG_XPFO case
> > 
> > CC: linux-arm-kernel@lists.infradead.org
> > CC: x86@kernel.org
> > Signed-off-by: Tycho Andersen <tycho@docker.com>
> > Tested-by: Marco Benatto <marco.antonio.780@gmail.com>
> > ---
> >  arch/arm64/mm/xpfo.c | 51 ++++++++++++++++++++++++++++++++++++++++++++++
> >  arch/x86/mm/xpfo.c   | 57 ++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  include/linux/xpfo.h |  5 +++++
> >  3 files changed, 113 insertions(+)
> > 
> > diff --git a/arch/arm64/mm/xpfo.c b/arch/arm64/mm/xpfo.c
> > index 342a9ccb93c1..94a667d94e15 100644
> > --- a/arch/arm64/mm/xpfo.c
> > +++ b/arch/arm64/mm/xpfo.c
> > @@ -74,3 +74,54 @@ void xpfo_dma_map_unmap_area(bool map, const void *addr, size_t size,
> >  
> >  	xpfo_temp_unmap(addr, size, mapping, sizeof(mapping[0]) * num_pages);
> >  }
> > +
> > +/* Convert a user space virtual address to a physical address.
> > + * Shamelessly copied from slow_virt_to_phys() and lookup_address() in
> > + * arch/x86/mm/pageattr.c
> > + */
> 
> When can this be called? What prevents concurrent modification of the user page
> tables?
> 
> i.e. must mmap_sem be held?

Yes, it should be. Since we're moving this back into the lkdtm test
code I think it's less important, since nothing should be modifying
the tables while the thread is doing the lookup, but I'll add it in
the next version.

> > +phys_addr_t user_virt_to_phys(unsigned long addr)
> 
> Does this really need to be architecture specific?
> 
> Core mm code manages to walk user page tables just fine...

I think so since we don't support section mappings right now, so
p*d_sect will always be false.

> > +{
> > +	phys_addr_t phys_addr;
> > +	unsigned long offset;
> > +	pgd_t *pgd;
> > +	p4d_t *p4d;
> > +	pud_t *pud;
> > +	pmd_t *pmd;
> > +	pte_t *pte;
> > +
> > +	pgd = pgd_offset(current->mm, addr);
> > +	if (pgd_none(*pgd))
> > +		return 0;
> 
> Can we please separate the address and return value? e.g. pass the PA by
> reference and return an error code.
> 
> AFAIK, zero is a valid PA, and even if the tables exist, they might point there
> in the presence of an error.

Sure, I'll rearrange this.

> > +
> > +	p4d = p4d_offset(pgd, addr);
> > +	if (p4d_none(*p4d))
> > +		return 0;
> > +
> > +	pud = pud_offset(p4d, addr);
> > +	if (pud_none(*pud))
> > +		return 0;
> > +
> > +	if (pud_sect(*pud) || !pud_present(*pud)) {
> > +		phys_addr = (unsigned long)pud_pfn(*pud) << PAGE_SHIFT;
> 
> Was there some problem with:
> 
> 	phys_addr = pmd_page_paddr(*pud);
> 
> ... and similar for the other levels?
> 
> ... I'd rather introduce new helpers than more open-coded calculations.

I wasn't aware of these; we could define a similar set of functions
for x86 and then make it not arch-specific.

I wonder if we could also use follow_page_pte(), since we know that
the page is always present (given that it's been allocated).
Unfortunately follow_page_pte() is not exported.

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
