Subject: Re: [RFC v3][PATCH 2/2] fix large pages in pagemap
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <1213142787.7261.27.camel@nimitz>
References: <20080606185521.38CA3421@kernel>
	 <20080606185522.89DF8EEE@kernel>  <1213140376.20045.33.camel@calx>
	 <1213142787.7261.27.camel@nimitz>
Content-Type: text/plain
Date: Wed, 11 Jun 2008 10:27:46 -0500
Message-Id: <1213198066.20045.42.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Hans Rosenfeld <hans.rosenfeld@amd.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-06-10 at 17:06 -0700, Dave Hansen wrote:
>  
> +static unsigned long pte_to_pagemap_entry(pte_t pte)
> +{
> +	unsigned long pme = 0;
> +	if (is_swap_pte(pte))
> +		pme = PM_PFRAME(swap_pte_to_pagemap_entry(pte))
> +			| PM_PSHIFT(PAGE_SHIFT) | PM_SWAP;
> +	else if (pte_present(pte))
> +		pme = PM_PFRAME(pte_pfn(pte))
> +			| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT;
> +	return pme;
> +}
> +
>  static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  			     struct mm_walk *walk)
>  {
> +	struct vm_area_struct *vma;
>  	struct pagemapread *pm = walk->private;
>  	pte_t *pte;
>  	int err = 0;
>  
> +	/* find the first VMA at or above 'addr' */
> +       	vma = find_vma(walk->mm, addr);

Tab weirdness.

>  	for (; addr != end; addr += PAGE_SIZE) {
>  		u64 pfn = PM_NOT_PRESENT;
> -		pte = pte_offset_map(pmd, addr);
> -		if (is_swap_pte(*pte))
> -			pfn = PM_PFRAME(swap_pte_to_pagemap_entry(*pte))
> -				| PM_PSHIFT(PAGE_SHIFT) | PM_SWAP;
> -		else if (pte_present(*pte))
> -			pfn = PM_PFRAME(pte_pfn(*pte))
> -				| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT;
> -		/* unmap so we're not in atomic when we copy to userspace */
> -		pte_unmap(pte);
> +
> +		/* check to see if we've left 'vma' behind
> +		 * and need a new, higher one */
> +		if (vma && (addr >= vma->vm_end))
> +			vma = find_vma(walk->mm, addr);
> +
> +		/* check that 'vma' actually covers this address,
> +		 * and that it isn't a huge page vma */
> +		if (vma && (vma->vm_start <= addr) &&
> +		    !is_vm_hugetlb_page(vma)) {
> +			pte = pte_offset_map(pmd, addr);
> +			pfn = pte_to_pagemap_entry(*pte);
> +			/*
> +			 * unmap so we're not in atomic
> +			 * when we copy to userspace
> +			 */
> +			pte_unmap(pte);

This barely warranted a one line comment but now its four. But anyway,
this and 1/2:

Acked-by: Matt Mackall <mpm@selenic.com>

Thanks for getting back to this.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
