From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [patch 2/2] lockless get_user_pages
References: <20080525144847.GB25747@wotan.suse.de>
	<20080525145227.GC25747@wotan.suse.de>
Date: Sun, 25 May 2008 19:18:06 +0200
In-Reply-To: <20080525145227.GC25747@wotan.suse.de> (Nick Piggin's message of
	"Sun, 25 May 2008 16:52:27 +0200")
Message-ID: <87fxs6xpyp.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, shaggy@austin.ibm.com, jens.axboe@oracle.com, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Hi Nick,

Nick Piggin <npiggin@suse.de> writes:

> Index: linux-2.6/arch/x86/mm/gup.c
> ===================================================================
> --- /dev/null
> +++ linux-2.6/arch/x86/mm/gup.c
> @@ -0,0 +1,244 @@
> +/*
> + * Lockless fast_gup for x86
> + *
> + * Copyright (C) 2008 Nick Piggin
> + * Copyright (C) 2008 Novell Inc.
> + */
> +#include <linux/sched.h>
> +#include <linux/mm.h>
> +#include <linux/vmstat.h>
> +#include <asm/pgtable.h>
> +
> +static inline pte_t gup_get_pte(pte_t *ptep)
> +{
> +#ifndef CONFIG_X86_PAE
> +	return *ptep;
> +#else
> +	/*
> +	 * With fast_gup, we walk down the pagetables without taking any locks.
> +	 * For this we would like to load the pointers atoimcally, but that is
> +	 * not possible (without expensive cmpxchg8b) on PAE.  What we do have
> +	 * is the guarantee that a pte will only either go from not present to
> +	 * present, or present to not present or both -- it will not switch to
> +	 * a completely different present page without a TLB flush in between;
> +	 * something that we are blocking by holding interrupts off.
> +	 *
> +	 * Setting ptes from not present to present goes:
> +	 * ptep->pte_high = h;
> +	 * smp_wmb();
> +	 * ptep->pte_low = l;
> +	 *
> +	 * And present to not present goes:
> +	 * ptep->pte_low = 0;
> +	 * smp_wmb();
> +	 * ptep->pte_high = 0;
> +	 *
> +	 * We must ensure here that the load of pte_low sees l iff
> +	 * pte_high sees h. We load pte_high *after* loading pte_low,
> +	 * which ensures we don't see an older value of pte_high.
> +	 * *Then* we recheck pte_low, which ensures that we haven't
> +	 * picked up a changed pte high. We might have got rubbish values
> +	 * from pte_low and pte_high, but we are guaranteed that pte_low
> +	 * will not have the present bit set *unless* it is 'l'. And
> +	 * fast_gup only operates on present ptes, so we're safe.
> +	 *
> +	 * gup_get_pte should not be used or copied outside gup.c without
> +	 * being very careful -- it does not atomically load the pte or
> +	 * anything that is likely to be useful for you.
> +	 */
> +	pte_t pte;
> +
> +retry:
> +	pte.pte_low = ptep->pte_low;
> +	smp_rmb();
> +	pte.pte_high = ptep->pte_high;
> +	smp_rmb();
> +	if (unlikely(pte.pte_low != ptep->pte_low))
> +		goto retry;
> +
> +	return pte;
> +#endif
> +}
> +
> +/*
> + * The performance critical leaf functions are made noinline otherwise gcc
> + * inlines everything into a single function which results in too much
> + * register pressure.
> + */
> +static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
> +		unsigned long end, int write, struct page **pages, int *nr)
> +{
> +	unsigned long mask;
> +	pte_t *ptep;
> +
> +	mask = _PAGE_PRESENT|_PAGE_USER;
> +	if (write)
> +		mask |= _PAGE_RW;
> +
> +	ptep = pte_offset_map(&pmd, addr);
> +	do {
> +		pte_t pte = gup_get_pte(ptep);
> +		struct page *page;
> +
> +		if ((pte_val(pte) & (mask | _PAGE_SPECIAL)) != mask)
> +			return 0;

Don't you leak the possbile high mapping here?

> +		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
> +		page = pte_page(pte);
> +		get_page(page);
> +		pages[*nr] = page;
> +		(*nr)++;
> +
> +	} while (ptep++, addr += PAGE_SIZE, addr != end);
> +	pte_unmap(ptep - 1);
> +
> +	return 1;
> +}
> +
> +static inline void get_head_page_multiple(struct page *page, int nr)
> +{
> +	VM_BUG_ON(page != compound_head(page));
> +	VM_BUG_ON(page_count(page) == 0);
> +	atomic_add(nr, &page->_count);
> +}
> +
> +static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
> +		unsigned long end, int write, struct page **pages, int *nr)
> +{
> +	unsigned long mask;
> +	pte_t pte = *(pte_t *)&pmd;
> +	struct page *head, *page;
> +	int refs;
> +
> +	mask = _PAGE_PRESENT|_PAGE_USER;
> +	if (write)
> +		mask |= _PAGE_RW;
> +	if ((pte_val(pte) & mask) != mask)
> +		return 0;
> +	/* hugepages are never "special" */
> +	VM_BUG_ON(pte_val(pte) & _PAGE_SPECIAL);
> +	VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
> +
> +	refs = 0;
> +	head = pte_page(pte);
> +	page = head + ((addr & ~HPAGE_MASK) >> PAGE_SHIFT);
> +	do {
> +		VM_BUG_ON(compound_head(page) != head);
> +		pages[*nr] = page;
> +		(*nr)++;
> +		page++;
> +		refs++;
> +	} while (addr += PAGE_SIZE, addr != end);
> +	get_head_page_multiple(head, refs);
> +
> +	return 1;
> +}
> +
> +static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
> +		int write, struct page **pages, int *nr)
> +{
> +	unsigned long next;
> +	pmd_t *pmdp;
> +
> +	pmdp = pmd_offset(&pud, addr);
> +	do {
> +		pmd_t pmd = *pmdp;
> +
> +		next = pmd_addr_end(addr, end);
> +		if (pmd_none(pmd))
> +			return 0;
> +		if (unlikely(pmd_large(pmd))) {
> +			if (!gup_huge_pmd(pmd, addr, next, write, pages, nr))
> +				return 0;
> +		} else {
> +			if (!gup_pte_range(pmd, addr, next, write, pages, nr))
> +				return 0;
> +		}
> +	} while (pmdp++, addr = next, addr != end);
> +
> +	return 1;
> +}
> +
> +static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end, int write, struct page **pages, int *nr)
> +{
> +	unsigned long next;
> +	pud_t *pudp;
> +
> +	pudp = pud_offset(&pgd, addr);
> +	do {
> +		pud_t pud = *pudp;
> +
> +		next = pud_addr_end(addr, end);
> +		if (pud_none(pud))
> +			return 0;
> +		if (!gup_pmd_range(pud, addr, next, write, pages, nr))
> +			return 0;
> +	} while (pudp++, addr = next, addr != end);
> +
> +	return 1;
> +}
> +
> +int fast_gup(unsigned long start, int nr_pages, int write, struct page **pages)
> +{
> +	struct mm_struct *mm = current->mm;
> +	unsigned long end = start + (nr_pages << PAGE_SHIFT);
> +	unsigned long addr = start;
> +	unsigned long next;
> +	pgd_t *pgdp;
> +	int nr = 0;
> +
> +	if (unlikely(!access_ok(write ? VERIFY_WRITE : VERIFY_READ,
> +					start, nr_pages*PAGE_SIZE)))
> +		goto slow_irqon;
> +
> +	/*
> +	 * XXX: batch / limit 'nr', to avoid large irq off latency
> +	 * needs some instrumenting to determine the common sizes used by
> +	 * important workloads (eg. DB2), and whether limiting the batch size
> +	 * will decrease performance.
> +	 *
> +	 * It seems like we're in the clear for the moment. Direct-IO is
> +	 * the main guy that batches up lots of get_user_pages, and even
> +	 * they are limited to 64-at-a-time which is not so many.
> +	 */
> +	/*
> +	 * This doesn't prevent pagetable teardown, but does prevent
> +	 * the pagetables and pages from being freed on x86.
> +	 *
> +	 * So long as we atomically load page table pointers versus teardown
> +	 * (which we do on x86, with the above PAE exception), we can follow the
> +	 * address down to the the page and take a ref on it.
> +	 */
> +	local_irq_disable();
> +	pgdp = pgd_offset(mm, addr);
> +	do {
> +		pgd_t pgd = *pgdp;
> +
> +		next = pgd_addr_end(addr, end);
> +		if (pgd_none(pgd))
> +			goto slow;
> +		if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
> +			goto slow;
> +	} while (pgdp++, addr = next, addr != end);
> +	local_irq_enable();
> +
> +	VM_BUG_ON(nr != (end - start) >> PAGE_SHIFT);
> +	return nr;
> +
> +	{
> +		int i, ret;
> +
> +slow:
> +		local_irq_enable();
> +slow_irqon:
> +		/* Could optimise this more by keeping what we've already got */
> +		for (i = 0; i < nr; i++)
> +			put_page(pages[i]);
> +
> +		down_read(&mm->mmap_sem);
> +		ret = get_user_pages(current, mm, start,
> +			(end - start) >> PAGE_SHIFT, write, 0, pages, NULL);
> +		up_read(&mm->mmap_sem);
> +
> +		return ret;
> +	}
> +}
> Index: linux-2.6/include/asm-x86/uaccess.h
> ===================================================================
> --- linux-2.6.orig/include/asm-x86/uaccess.h
> +++ linux-2.6/include/asm-x86/uaccess.h
> @@ -3,3 +3,8 @@
>  #else
>  # include "uaccess_64.h"
>  #endif
> +
> +#define __HAVE_ARCH_FAST_GUP
> +struct page;
> +int fast_gup(unsigned long start, int nr_pages, int write, struct page **pages);
> +
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
