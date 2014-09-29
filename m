Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3BC736B0035
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 17:53:13 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id et14so3452007pad.31
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 14:53:12 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id ib4si24753419pbc.249.2014.09.29.14.53.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 14:53:12 -0700 (PDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so5224673pad.2
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 14:53:11 -0700 (PDT)
Date: Mon, 29 Sep 2014 14:51:25 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH V4 1/6] mm: Introduce a general RCU
 get_user_pages_fast.
In-Reply-To: <1411740233-28038-2-git-send-email-steve.capper@linaro.org>
Message-ID: <alpine.LSU.2.11.1409291443210.2800@eggly.anvils>
References: <1411740233-28038-1-git-send-email-steve.capper@linaro.org> <1411740233-28038-2-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-arch@vger.kernel.org, linux-mm@kvack.org, will.deacon@arm.com, gary.robertson@linaro.org, christoffer.dall@linaro.org, peterz@infradead.org, anders.roxell@linaro.org, dann.frazier@canonical.com, mark.rutland@arm.com, mgorman@suse.de, hughd@google.com

On Fri, 26 Sep 2014, Steve Capper wrote:

> get_user_pages_fast attempts to pin user pages by walking the page
> tables directly and avoids taking locks. Thus the walker needs to be
> protected from page table pages being freed from under it, and needs
> to block any THP splits.
> 
> One way to achieve this is to have the walker disable interrupts, and
> rely on IPIs from the TLB flushing code blocking before the page table
> pages are freed.
> 
> On some platforms we have hardware broadcast of TLB invalidations, thus
> the TLB flushing code doesn't necessarily need to broadcast IPIs; and
> spuriously broadcasting IPIs can hurt system performance if done too
> often.
> 
> This problem has been solved on PowerPC and Sparc by batching up page
> table pages belonging to more than one mm_user, then scheduling an
> rcu_sched callback to free the pages. This RCU page table free logic
> has been promoted to core code and is activated when one enables
> HAVE_RCU_TABLE_FREE. Unfortunately, these architectures implement
> their own get_user_pages_fast routines.
> 
> The RCU page table free logic coupled with a an IPI broadcast on THP
> split (which is a rare event), allows one to protect a page table
> walker by merely disabling the interrupts during the walk.
> 
> This patch provides a general RCU implementation of get_user_pages_fast
> that can be used by architectures that perform hardware broadcast of
> TLB invalidations.
> 
> It is based heavily on the PowerPC implementation by Nick Piggin.
> 
> Signed-off-by: Steve Capper <steve.capper@linaro.org>
> Tested-by: Dann Frazier <dann.frazier@canonical.com>
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

Acked-by: Hugh Dickins <hughd@google.com>

Thanks for making all those clarifications, Steve: this looks very
good to me now.  I'm not sure which tree you're hoping will take this
and the arm+arm64 patches 2-6: although this one would normally go
through akpm, I expect it's easier for you to synchronize if it goes
in along with the arm+arm64 2-6 - would that be okay with you, Andrew?
I see no clash with what's currently in mmotm.

> ---
> Changed in V4:
>  * Added pte_numa and pmd_numa calls.
>  * Added comments to clarify what assumptions are being made by the
>    implementation.
>  * Cleaned up formatting for checkpatch.
> 
> Catalin, I've kept your Reviewed-by, please shout if you dislike the
> pte_numa and pmd_numa calls.
> ---
>  mm/Kconfig |   3 +
>  mm/gup.c   | 354 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 357 insertions(+)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 886db21..0ceb8a5 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -137,6 +137,9 @@ config HAVE_MEMBLOCK_NODE_MAP
>  config HAVE_MEMBLOCK_PHYS_MAP
>  	boolean
>  
> +config HAVE_GENERIC_RCU_GUP
> +	boolean
> +
>  config ARCH_DISCARD_MEMBLOCK
>  	boolean
>  
> diff --git a/mm/gup.c b/mm/gup.c
> index 91d044b..35c0160 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -10,6 +10,10 @@
>  #include <linux/swap.h>
>  #include <linux/swapops.h>
>  
> +#include <linux/sched.h>
> +#include <linux/rwsem.h>
> +#include <asm/pgtable.h>
> +
>  #include "internal.h"
>  
>  static struct page *no_page_table(struct vm_area_struct *vma,
> @@ -672,3 +676,353 @@ struct page *get_dump_page(unsigned long addr)
>  	return page;
>  }
>  #endif /* CONFIG_ELF_CORE */
> +
> +/**
> + * Generic RCU Fast GUP
> + *
> + * get_user_pages_fast attempts to pin user pages by walking the page
> + * tables directly and avoids taking locks. Thus the walker needs to be
> + * protected from page table pages being freed from under it, and should
> + * block any THP splits.
> + *
> + * One way to achieve this is to have the walker disable interrupts, and
> + * rely on IPIs from the TLB flushing code blocking before the page table
> + * pages are freed. This is unsuitable for architectures that do not need
> + * to broadcast an IPI when invalidating TLBs.
> + *
> + * Another way to achieve this is to batch up page table containing pages
> + * belonging to more than one mm_user, then rcu_sched a callback to free those
> + * pages. Disabling interrupts will allow the fast_gup walker to both block
> + * the rcu_sched callback, and an IPI that we broadcast for splitting THPs
> + * (which is a relatively rare event). The code below adopts this strategy.
> + *
> + * Before activating this code, please be aware that the following assumptions
> + * are currently made:
> + *
> + *  *) HAVE_RCU_TABLE_FREE is enabled, and tlb_remove_table is used to free
> + *      pages containing page tables.
> + *
> + *  *) THP splits will broadcast an IPI, this can be achieved by overriding
> + *      pmdp_splitting_flush.
> + *
> + *  *) ptes can be read atomically by the architecture.
> + *
> + *  *) access_ok is sufficient to validate userspace address ranges.
> + *
> + * The last two assumptions can be relaxed by the addition of helper functions.
> + *
> + * This code is based heavily on the PowerPC implementation by Nick Piggin.
> + */
> +#ifdef CONFIG_HAVE_GENERIC_RCU_GUP
> +
> +#ifdef __HAVE_ARCH_PTE_SPECIAL
> +static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
> +			 int write, struct page **pages, int *nr)
> +{
> +	pte_t *ptep, *ptem;
> +	int ret = 0;
> +
> +	ptem = ptep = pte_offset_map(&pmd, addr);
> +	do {
> +		/*
> +		 * In the line below we are assuming that the pte can be read
> +		 * atomically. If this is not the case for your architecture,
> +		 * please wrap this in a helper function!
> +		 *
> +		 * for an example see gup_get_pte in arch/x86/mm/gup.c
> +		 */
> +		pte_t pte = ACCESS_ONCE(*ptep);
> +		struct page *page;
> +
> +		/*
> +		 * Similar to the PMD case below, NUMA hinting must take slow
> +		 * path
> +		 */
> +		if (!pte_present(pte) || pte_special(pte) ||
> +			pte_numa(pte) || (write && !pte_write(pte)))
> +			goto pte_unmap;
> +
> +		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
> +		page = pte_page(pte);
> +
> +		if (!page_cache_get_speculative(page))
> +			goto pte_unmap;
> +
> +		if (unlikely(pte_val(pte) != pte_val(*ptep))) {
> +			put_page(page);
> +			goto pte_unmap;
> +		}
> +
> +		pages[*nr] = page;
> +		(*nr)++;
> +
> +	} while (ptep++, addr += PAGE_SIZE, addr != end);
> +
> +	ret = 1;
> +
> +pte_unmap:
> +	pte_unmap(ptem);
> +	return ret;
> +}
> +#else
> +
> +/*
> + * If we can't determine whether or not a pte is special, then fail immediately
> + * for ptes. Note, we can still pin HugeTLB and THP as these are guaranteed not
> + * to be special.
> + *
> + * For a futex to be placed on a THP tail page, get_futex_key requires a
> + * __get_user_pages_fast implementation that can pin pages. Thus it's still
> + * useful to have gup_huge_pmd even if we can't operate on ptes.
> + */
> +static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
> +			 int write, struct page **pages, int *nr)
> +{
> +	return 0;
> +}
> +#endif /* __HAVE_ARCH_PTE_SPECIAL */
> +
> +static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
> +		unsigned long end, int write, struct page **pages, int *nr)
> +{
> +	struct page *head, *page, *tail;
> +	int refs;
> +
> +	if (write && !pmd_write(orig))
> +		return 0;
> +
> +	refs = 0;
> +	head = pmd_page(orig);
> +	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
> +	tail = page;
> +	do {
> +		VM_BUG_ON_PAGE(compound_head(page) != head, page);
> +		pages[*nr] = page;
> +		(*nr)++;
> +		page++;
> +		refs++;
> +	} while (addr += PAGE_SIZE, addr != end);
> +
> +	if (!page_cache_add_speculative(head, refs)) {
> +		*nr -= refs;
> +		return 0;
> +	}
> +
> +	if (unlikely(pmd_val(orig) != pmd_val(*pmdp))) {
> +		*nr -= refs;
> +		while (refs--)
> +			put_page(head);
> +		return 0;
> +	}
> +
> +	/*
> +	 * Any tail pages need their mapcount reference taken before we
> +	 * return. (This allows the THP code to bump their ref count when
> +	 * they are split into base pages).
> +	 */
> +	while (refs--) {
> +		if (PageTail(tail))
> +			get_huge_page_tail(tail);
> +		tail++;
> +	}
> +
> +	return 1;
> +}
> +
> +static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
> +		unsigned long end, int write, struct page **pages, int *nr)
> +{
> +	struct page *head, *page, *tail;
> +	int refs;
> +
> +	if (write && !pud_write(orig))
> +		return 0;
> +
> +	refs = 0;
> +	head = pud_page(orig);
> +	page = head + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
> +	tail = page;
> +	do {
> +		VM_BUG_ON_PAGE(compound_head(page) != head, page);
> +		pages[*nr] = page;
> +		(*nr)++;
> +		page++;
> +		refs++;
> +	} while (addr += PAGE_SIZE, addr != end);
> +
> +	if (!page_cache_add_speculative(head, refs)) {
> +		*nr -= refs;
> +		return 0;
> +	}
> +
> +	if (unlikely(pud_val(orig) != pud_val(*pudp))) {
> +		*nr -= refs;
> +		while (refs--)
> +			put_page(head);
> +		return 0;
> +	}
> +
> +	while (refs--) {
> +		if (PageTail(tail))
> +			get_huge_page_tail(tail);
> +		tail++;
> +	}
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
> +		pmd_t pmd = ACCESS_ONCE(*pmdp);
> +
> +		next = pmd_addr_end(addr, end);
> +		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
> +			return 0;
> +
> +		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd))) {
> +			/*
> +			 * NUMA hinting faults need to be handled in the GUP
> +			 * slowpath for accounting purposes and so that they
> +			 * can be serialised against THP migration.
> +			 */
> +			if (pmd_numa(pmd))
> +				return 0;
> +
> +			if (!gup_huge_pmd(pmd, pmdp, addr, next, write,
> +				pages, nr))
> +				return 0;
> +
> +		} else if (!gup_pte_range(pmd, addr, next, write, pages, nr))
> +				return 0;
> +	} while (pmdp++, addr = next, addr != end);
> +
> +	return 1;
> +}
> +
> +static int gup_pud_range(pgd_t *pgdp, unsigned long addr, unsigned long end,
> +		int write, struct page **pages, int *nr)
> +{
> +	unsigned long next;
> +	pud_t *pudp;
> +
> +	pudp = pud_offset(pgdp, addr);
> +	do {
> +		pud_t pud = ACCESS_ONCE(*pudp);
> +
> +		next = pud_addr_end(addr, end);
> +		if (pud_none(pud))
> +			return 0;
> +		if (pud_huge(pud)) {
> +			if (!gup_huge_pud(pud, pudp, addr, next, write,
> +					pages, nr))
> +				return 0;
> +		} else if (!gup_pmd_range(pud, addr, next, write, pages, nr))
> +			return 0;
> +	} while (pudp++, addr = next, addr != end);
> +
> +	return 1;
> +}
> +
> +/*
> + * Like get_user_pages_fast() except its IRQ-safe in that it won't fall
> + * back to the regular GUP. It will only return non-negative values.
> + */
> +int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
> +			  struct page **pages)
> +{
> +	struct mm_struct *mm = current->mm;
> +	unsigned long addr, len, end;
> +	unsigned long next, flags;
> +	pgd_t *pgdp;
> +	int nr = 0;
> +
> +	start &= PAGE_MASK;
> +	addr = start;
> +	len = (unsigned long) nr_pages << PAGE_SHIFT;
> +	end = start + len;
> +
> +	if (unlikely(!access_ok(write ? VERIFY_WRITE : VERIFY_READ,
> +					start, len)))
> +		return 0;
> +
> +	/*
> +	 * Disable interrupts, we use the nested form as we can already
> +	 * have interrupts disabled by get_futex_key.
> +	 *
> +	 * With interrupts disabled, we block page table pages from being
> +	 * freed from under us. See mmu_gather_tlb in asm-generic/tlb.h
> +	 * for more details.
> +	 *
> +	 * We do not adopt an rcu_read_lock(.) here as we also want to
> +	 * block IPIs that come from THPs splitting.
> +	 */
> +
> +	local_irq_save(flags);
> +	pgdp = pgd_offset(mm, addr);
> +	do {
> +		next = pgd_addr_end(addr, end);
> +		if (pgd_none(*pgdp))
> +			break;
> +		else if (!gup_pud_range(pgdp, addr, next, write, pages, &nr))
> +			break;
> +	} while (pgdp++, addr = next, addr != end);
> +	local_irq_restore(flags);
> +
> +	return nr;
> +}
> +
> +/**
> + * get_user_pages_fast() - pin user pages in memory
> + * @start:	starting user address
> + * @nr_pages:	number of pages from start to pin
> + * @write:	whether pages will be written to
> + * @pages:	array that receives pointers to the pages pinned.
> + *		Should be at least nr_pages long.
> + *
> + * Attempt to pin user pages in memory without taking mm->mmap_sem.
> + * If not successful, it will fall back to taking the lock and
> + * calling get_user_pages().
> + *
> + * Returns number of pages pinned. This may be fewer than the number
> + * requested. If nr_pages is 0 or negative, returns 0. If no pages
> + * were pinned, returns -errno.
> + */
> +int get_user_pages_fast(unsigned long start, int nr_pages, int write,
> +			struct page **pages)
> +{
> +	struct mm_struct *mm = current->mm;
> +	int nr, ret;
> +
> +	start &= PAGE_MASK;
> +	nr = __get_user_pages_fast(start, nr_pages, write, pages);
> +	ret = nr;
> +
> +	if (nr < nr_pages) {
> +		/* Try to get the remaining pages with get_user_pages */
> +		start += nr << PAGE_SHIFT;
> +		pages += nr;
> +
> +		down_read(&mm->mmap_sem);
> +		ret = get_user_pages(current, mm, start,
> +				     nr_pages - nr, write, 0, pages, NULL);
> +		up_read(&mm->mmap_sem);
> +
> +		/* Have to be a bit careful with return values */
> +		if (nr > 0) {
> +			if (ret < 0)
> +				ret = nr;
> +			else
> +				ret += nr;
> +		}
> +	}
> +
> +	return ret;
> +}
> +
> +#endif /* CONFIG_HAVE_GENERIC_RCU_GUP */
> -- 
> 1.9.3
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
