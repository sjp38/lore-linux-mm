Subject: Re: [RFC][PATCH 2/2] fix large pages in pagemap
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20080606173138.9BFE6272@kernel>
References: <20080606173137.24513039@kernel>
	 <20080606173138.9BFE6272@kernel>
Content-Type: text/plain
Date: Fri, 06 Jun 2008 13:14:16 -0500
Message-Id: <1212776056.14718.21.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Hans Rosenfeld <hans.rosenfeld@amd.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-06-06 at 10:31 -0700, Dave Hansen wrote:
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
>  linux-2.6.git-dave/fs/proc/task_mmu.c |    8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff -puN fs/proc/task_mmu.c~fix-large-pages-in-pagemap fs/proc/task_mmu.c
> --- linux-2.6.git/fs/proc/task_mmu.c~fix-large-pages-in-pagemap	2008-06-06 09:44:45.000000000 -0700
> +++ linux-2.6.git-dave/fs/proc/task_mmu.c	2008-06-06 09:48:44.000000000 -0700
> @@ -567,12 +567,19 @@ static u64 swap_pte_to_pagemap_entry(pte
>  static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  			     struct mm_walk *walk)
>  {
> +	struct vm_area_struct *vma = NULL;
>  	struct pagemapread *pm = walk->private;
>  	pte_t *pte;
>  	int err = 0;
>  
>  	for (; addr != end; addr += PAGE_SIZE) {
>  		u64 pfn = PM_NOT_PRESENT;
> +
> +		if (!vma || addr >= vma->vm_end)
> +			vma = find_vma(walk->mm, addr);
> +		if (vma && is_vm_hugetlb_page(vma)) {
> +			goto add:
>
>  		pte = pte_offset_map(pmd, addr);
>  		if (is_swap_pte(*pte))
>  			pfn = PM_PFRAME(swap_pte_to_pagemap_entry(*pte))
> @@ -582,6 +589,7 @@ static int pagemap_pte_range(pmd_t *pmd,
>  				| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT;
>  		/* unmap so we're not in atomic when we copy to userspace */
>  		pte_unmap(pte);
> +	add:
>  		err = add_to_pagemap(addr, pfn, pm);
>  		if (err)
>  			return err;

This makes me frown a bit. First, there's a spurious '{' before 'goto
add'. Second, it'd be cleaner to invert the sense of the if and do the
pte junk in the body, rather than have a goto, no?

I'm also worried that calling find_vma for every pte in an unmapped
space is going to be slow.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
