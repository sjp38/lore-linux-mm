Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C8EF6B0033
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 14:34:06 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id k101so1686853iod.1
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 11:34:06 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p83si10604932oia.529.2017.09.14.11.34.05
        for <linux-mm@kvack.org>;
        Thu, 14 Sep 2017 11:34:05 -0700 (PDT)
Date: Thu, 14 Sep 2017 19:34:02 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [kernel-hardening] [PATCH v6 10/11] mm: add a user_virt_to_phys
 symbol
Message-ID: <20170914183401.GC1711@remoulade>
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-11-tycho@docker.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170907173609.22696-11-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, linux-arm-kernel@lists.infradead.org, x86@kernel.org

On Thu, Sep 07, 2017 at 11:36:08AM -0600, Tycho Andersen wrote:
> We need someting like this for testing XPFO. Since it's architecture
> specific, putting it in the test code is slightly awkward, so let's make it
> an arch-specific symbol and export it for use in LKDTM.
> 
> v6: * add a definition of user_virt_to_phys in the !CONFIG_XPFO case
> 
> CC: linux-arm-kernel@lists.infradead.org
> CC: x86@kernel.org
> Signed-off-by: Tycho Andersen <tycho@docker.com>
> Tested-by: Marco Benatto <marco.antonio.780@gmail.com>
> ---
>  arch/arm64/mm/xpfo.c | 51 ++++++++++++++++++++++++++++++++++++++++++++++
>  arch/x86/mm/xpfo.c   | 57 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/xpfo.h |  5 +++++
>  3 files changed, 113 insertions(+)
> 
> diff --git a/arch/arm64/mm/xpfo.c b/arch/arm64/mm/xpfo.c
> index 342a9ccb93c1..94a667d94e15 100644
> --- a/arch/arm64/mm/xpfo.c
> +++ b/arch/arm64/mm/xpfo.c
> @@ -74,3 +74,54 @@ void xpfo_dma_map_unmap_area(bool map, const void *addr, size_t size,
>  
>  	xpfo_temp_unmap(addr, size, mapping, sizeof(mapping[0]) * num_pages);
>  }
> +
> +/* Convert a user space virtual address to a physical address.
> + * Shamelessly copied from slow_virt_to_phys() and lookup_address() in
> + * arch/x86/mm/pageattr.c
> + */

When can this be called? What prevents concurrent modification of the user page
tables?

i.e. must mmap_sem be held?

> +phys_addr_t user_virt_to_phys(unsigned long addr)

Does this really need to be architecture specific?

Core mm code manages to walk user page tables just fine...

> +{
> +	phys_addr_t phys_addr;
> +	unsigned long offset;
> +	pgd_t *pgd;
> +	p4d_t *p4d;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	pte_t *pte;
> +
> +	pgd = pgd_offset(current->mm, addr);
> +	if (pgd_none(*pgd))
> +		return 0;

Can we please separate the address and return value? e.g. pass the PA by
reference and return an error code.

AFAIK, zero is a valid PA, and even if the tables exist, they might point there
in the presence of an error.

> +
> +	p4d = p4d_offset(pgd, addr);
> +	if (p4d_none(*p4d))
> +		return 0;
> +
> +	pud = pud_offset(p4d, addr);
> +	if (pud_none(*pud))
> +		return 0;
> +
> +	if (pud_sect(*pud) || !pud_present(*pud)) {
> +		phys_addr = (unsigned long)pud_pfn(*pud) << PAGE_SHIFT;

Was there some problem with:

	phys_addr = pmd_page_paddr(*pud);

... and similar for the other levels?

... I'd rather introduce new helpers than more open-coded calculations.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
