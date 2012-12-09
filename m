Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 811FE6B0078
	for <linux-mm@kvack.org>; Sun,  9 Dec 2012 09:06:57 -0500 (EST)
Date: Sun, 9 Dec 2012 16:06:53 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [RFCv2][PATCH 1/3] create slow_virt_to_phys()
Message-ID: <20121209140653.GA29003@redhat.com>
References: <20121207213023.AA3AFF11@kernel.stglabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121207213023.AA3AFF11@kernel.stglabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, mtosatti@redhat.com

Copying more people. Is this approach good? The alternative would be to
allocate NR_CPUS sized arrays in KVM.

On Fri, Dec 07, 2012 at 04:30:23PM -0500, Dave Hansen wrote:
> 
> This is necessary because __pa() does not work on some kinds of
> memory, like vmalloc() or the alloc_remap() areas on 32-bit
> NUMA systems.  We have some functions to do conversions _like_
> this in the vmalloc() code (like vmalloc_to_page()), but they
> do not work on sizes other than 4k pages.  We would potentially
> need to be able to handle all the page sizes that we use for
> the kernel linear mapping (4k, 2M, 1G).
> 
> In practice, on 32-bit NUMA systems, the percpu areas get stuck
> in the alloc_remap() area.  Any __pa() call on them will break
> and basically return garbage.
> 
> This patch introduces a new function slow_virt_to_phys(), which
> walks the kernel page tables on x86 and should do precisely
> the same logical thing as __pa(), but actually work on a wider
> range of memory.  It should work on the normal linear mapping,
> vmalloc(), kmap(), etc...
> 
> 
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> ---
> 
>  linux-2.6.git-dave/arch/x86/include/asm/pgtable_types.h |    1 
>  linux-2.6.git-dave/arch/x86/mm/pageattr.c               |   47 ++++++++++++++++
>  2 files changed, 48 insertions(+)
> 
> diff -puN arch/x86/include/asm/pgtable_types.h~create-slow_virt_to_phys arch/x86/include/asm/pgtable_types.h
> --- linux-2.6.git/arch/x86/include/asm/pgtable_types.h~create-slow_virt_to_phys	2012-12-07 16:25:16.317592189 -0500
> +++ linux-2.6.git-dave/arch/x86/include/asm/pgtable_types.h	2012-12-07 16:25:16.321592224 -0500
> @@ -332,6 +332,7 @@ static inline void update_page_count(int
>   * as a pte too.
>   */
>  extern pte_t *lookup_address(unsigned long address, unsigned int *level);
> +extern phys_addr_t slow_virt_to_phys(void *__address);
>  
>  #endif	/* !__ASSEMBLY__ */
>  
> diff -puN arch/x86/mm/pageattr.c~create-slow_virt_to_phys arch/x86/mm/pageattr.c
> --- linux-2.6.git/arch/x86/mm/pageattr.c~create-slow_virt_to_phys	2012-12-07 16:25:16.317592189 -0500
> +++ linux-2.6.git-dave/arch/x86/mm/pageattr.c	2012-12-07 16:28:20.675189758 -0500
> @@ -364,6 +364,53 @@ pte_t *lookup_address(unsigned long addr
>  EXPORT_SYMBOL_GPL(lookup_address);
>  
>  /*
> + * This is necessary because __pa() does not work on some
> + * kinds of memory, like vmalloc() or the alloc_remap()
> + * areas on 32-bit NUMA systems.  The percpu areas can
> + * end up in this kind of memory, for instance.
> + *
> + * This could be optimized, but it is only intended to be
> + * used at inititalization time, and keeping it
> + * unoptimized should increase the testing coverage for
> + * the more obscure platforms.
> + */
> +phys_addr_t slow_virt_to_phys(void *__virt_addr)
> +{
> +	unsigned long virt_addr = (unsigned long)__virt_addr;
> +	phys_addr_t phys_addr;
> +	unsigned long offset;
> +	unsigned int level = -1;
> +	unsigned long psize = 0;
> +	unsigned long pmask = 0;
> +	pte_t *pte;
> +
> +	pte = lookup_address(virt_addr, &level);
> +	BUG_ON(!pte);
> +	switch (level) {
> +	case PG_LEVEL_4K:
> +		psize = PAGE_SIZE;
> +		pmask = PAGE_MASK;
> +		break;
> +	case PG_LEVEL_2M:
> +		psize = PMD_PAGE_SIZE;
> +		pmask = PMD_PAGE_MASK;
> +		break;
> +#ifdef CONFIG_X86_64
> +	case PG_LEVEL_1G:
> +		psize = PUD_PAGE_SIZE;
> +		pmask = PUD_PAGE_MASK;
> +		break;
> +#endif
> +	default:
> +		BUG();
> +	}
> +	offset = virt_addr & ~pmask;
> +	phys_addr = pte_pfn(*pte) << PAGE_SHIFT;
> +	return (phys_addr | offset);
> +}
> +EXPORT_SYMBOL_GPL(slow_virt_to_phys);
> +
> +/*
>   * Set the new pmd in all the pgds we know about:
>   */
>  static void __set_pmd_pte(pte_t *kpte, unsigned long address, pte_t pte)
> _

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
