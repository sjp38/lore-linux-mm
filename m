Subject: Re: [RFC v2][PATCH 2/2] fix large pages in pagemap
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20080606185522.89DF8EEE@kernel>
References: <20080606185521.38CA3421@kernel>
	 <20080606185522.89DF8EEE@kernel>
Content-Type: text/plain; charset=utf-8
Date: Tue, 10 Jun 2008 18:26:16 -0500
Message-Id: <1213140376.20045.33.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Hans Rosenfeld <hans.rosenfeld@amd.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-06-06 at 11:55 -0700, Dave Hansen wrote:
> We were walking right into huge page areas in the pagemap
> walker, and calling the pmds pmd_bad() and clearing them.
> 
> That leaked huge pages.  Bad.
> 
> This patch at least works around that for now.  It ignores
> huge pages in the pagemap walker for the time being, and
> won't leak those pages.
> 
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> ---
> 
>  linux-2.6.git-dave/fs/proc/task_mmu.c |   43 ++++++++++++++++++++++++++--------
>  1 file changed, 34 insertions(+), 9 deletions(-)
> 
> diff -puN fs/proc/task_mmu.c~fix-large-pages-in-pagemap fs/proc/task_mmu.c
> --- linux-2.6.git/fs/proc/task_mmu.c~fix-large-pages-in-pagemap	2008-06-06 11:31:48.000000000 -0700
> +++ linux-2.6.git-dave/fs/proc/task_mmu.c	2008-06-06 11:41:22.000000000 -0700
> @@ -563,24 +563,49 @@ static u64 swap_pte_to_pagemap_entry(pte
>  	return swp_type(e) | (swp_offset(e) << MAX_SWAPFILES_SHIFT);
>  }
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
> +	struct vm_area_struct *vma = find_vma(walk->mm, addr);
>  	struct pagemapread *pm = walk->private;
>  	pte_t *pte;
>  	int err = 0;
>  
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
> +		/*
> +		 * Remember that find_vma() returns the
> +		 * first vma with a vm_end > addr, but
> +		 * has no guarantee about addr and
> +		 * vm_start.  That means we'll always
> +		 * find a vma here, unless we're at
> +		 * an addr higher than the highest vma.
> +		 */

I don't like this comment much - I had to read it several times to
convince myself the code was correct. I think it should instead be three
pieces and perhaps a new variable name, like this:

i>>?          /* find the first VMA at or after our current address */
> +	struct vm_area_struct *targetvma = find_vma(walk->mm, addr);

          	/* find next target VMA if we leave current one */
> +		if (targetvma && (addr >= targetvma->vm_end))
> +			targetvma = find_vma(walk->mm, addr);

          	/* if inside non-huge target VMA, map it */
> +		if (targetvma && (targetvma->vm_start <= addr) &&
> +		    !is_vm_hugetlb_page(targetvma)) {

> +			pte = pte_offset_map(pmd, addr);
> +			pfn = pte_to_pagemap_entry(*pte);
> +			/*
> +			 * unmap so we're not in atomic
> +			 * when we copy to userspace
> +			 */
> +			pte_unmap(pte);

Also, might as well move the map/unmap inside the utility function if
we're going to have one, no?

Otherwise, I'm liking this.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
