Date: Tue, 23 Jan 2007 20:55:47 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: mremap correct rmap accounting
In-Reply-To: <45B61967.5000302@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0701232041330.2461@blonde.wat.veritas.com>
References: <45B61967.5000302@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Ralf Baechle <ralf@linux-mips.org>
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jan 2007, Nick Piggin wrote:
> 
> When mremap()ing virtual addresses, some architectures (read: MIPS) switches
> underlying pages if encountering ZERO_PAGE(old_vaddr) != ZERO_PAGE(new_vaddr).
> 
> The problem is that the refcount and mapcount remain on the old page, while
> the actual pte is switched to the new one. This would counter underruns and
> confuse the rmap code.

Good point.  Nasty.

> 
> Fix it by actually moving accounting info to the new page. Would it be neater
> to do this in move_pte? maybe rmap.c? (nick mumbles something about not
> accounting ZERO_PAGE()s)

Tiresome, I can quite see why it brings you to mumbling.

Though it looks right, I do hate the patch cluttering up move_ptes()
like that: will the compiler be able to work out that that "unlikely"
means impossible (and optimize away the code) on all arches but MIPS?
Even if it can, I'd rather not see it there.

Could you make the MIPS move_pte() a proper function, say in
arch/mips/mm/init.c next to setup_zero_pages(), and do that tiresome
stuff there - should then be able to assume ZERO_PAGEs and skip the
BUG_ON embellishments.

Utter nit-of-nits: my sense of symmetry prefers that you put_page()
after page_remove_rmap() instead of before.

Hugh

> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> 
> Index: linux-2.6/mm/mremap.c
> ===================================================================
> --- linux-2.6.orig/mm/mremap.c	2007-01-24 01:00:53.000000000 +1100
> +++ linux-2.6/mm/mremap.c	2007-01-24 01:01:16.000000000 +1100
> @@ -18,6 +18,7 @@
>  #include <linux/highmem.h>
>  #include <linux/security.h>
>  #include <linux/syscalls.h>
> +#include <linux/rmap.h>
>  
>  #include <asm/uaccess.h>
>  #include <asm/cacheflush.h>
> @@ -72,7 +73,7 @@ static void move_ptes(struct vm_area_str
>  {
>  	struct address_space *mapping = NULL;
>  	struct mm_struct *mm = vma->vm_mm;
> -	pte_t *old_pte, *new_pte, pte;
> +	pte_t *old_pte, *new_pte;
>  	spinlock_t *old_ptl, *new_ptl;
>  
>  	if (vma->vm_file) {
> @@ -102,12 +103,28 @@ static void move_ptes(struct vm_area_str
>  
>  	for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
>  				   new_pte++, new_addr += PAGE_SIZE) {
> +		pte_t new, old;
> +
>  		if (pte_none(*old_pte))
>  			continue;
> -		pte = ptep_clear_flush(vma, old_addr, old_pte);
> +		old = ptep_clear_flush(vma, old_addr, old_pte);
>  		/* ZERO_PAGE can be dependant on virtual addr */
> -		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
> -		set_pte_at(mm, new_addr, new_pte, pte);
> +		new = move_pte(old, new_vma->vm_page_prot, old_addr, new_addr);
> +		if (unlikely(pte_pfn(old) != pte_pfn(new))) {
> +			struct page *page;
> +			/* must be different ZERO_PAGE()es. Update accounting */
> +
> +			page = vm_normal_page(vma, old_addr, old);
> +			BUG_ON(page != ZERO_PAGE(old_addr));
> +			put_page(page);
> +			page_remove_rmap(page, vma);
> +
> +			page = vm_normal_page(new_vma, new_addr, new);
> +			BUG_ON(page != ZERO_PAGE(new_addr));
> +			get_page(page);
> +			page_add_file_rmap(page);
> +		}
> +		set_pte_at(mm, new_addr, new_pte, new);
>  	}
>  
>  	arch_leave_lazy_mmu_mode();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
