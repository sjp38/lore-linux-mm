From: Andi Kleen <ak@suse.de>
Subject: Re: [patch] shared page table for hugetlb page
Date: Thu, 8 Jun 2006 03:25:19 +0200
References: <000101c68a74$16aeed40$d534030a@amr.corp.intel.com>
In-Reply-To: <000101c68a74$16aeed40$d534030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606080325.19994.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Dave McCracken <dmccr@us.ibm.com>, 'Hugh Dickins' <hugh@veritas.com>, 'Andrew Morton' <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> diff -Nurp linux-2.6.16/arch/i386/mm/hugetlbpage.c linux-2.6.16.ken/arch/i386/mm/hugetlbpage.c
> --- linux-2.6.16/arch/i386/mm/hugetlbpage.c	2006-06-07 08:07:52.000000000 -0700
> +++ linux-2.6.16.ken/arch/i386/mm/hugetlbpage.c	2006-06-07 10:44:31.000000000 -0700
> @@ -18,16 +18,102 @@
>  #include <asm/tlb.h>
>  #include <asm/tlbflush.h>
>  
> +#ifdef CONFIG_X86_64

Why is this done for x86-64 only? 

> +int huge_pte_put(struct vm_area_struct *vma, unsigned long *addr, pte_t *ptep)
> +{
> +	pgd_t *pgd = pgd_offset(vma->vm_mm, *addr);
> +	pud_t *pud = pud_offset(pgd, *addr);
> +
> +	if (page_count(virt_to_page(ptep)) <= 1)
> +		return 0;
> +
> +	pud_clear(pud);
> +	put_page(virt_to_page(ptep));

You could cache page in a local variable.

> +	*addr = ALIGN(*addr, HPAGE_SIZE * PTRS_PER_PTE) - HPAGE_SIZE;
> +	return 1;
> +}
> +#else
> +void pmd_share(struct vm_area_struct *vma, pud_t *pud, unsigned long addr)
> +{
> +}
> +#endif
> +
>  pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr)
>  {
> +	/*
> +	 * to be fixed: pass me the darn vma pointer.
> +	 */

Just fix it?

Overall it looks nice&clean though.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
