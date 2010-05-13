Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 597076B021E
	for <linux-mm@kvack.org>; Thu, 13 May 2010 11:27:55 -0400 (EDT)
Date: Thu, 13 May 2010 16:27:37 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/7] hugetlb, rmap: add reverse mapping for hugepage
Message-ID: <20100513152737.GE27949@csn.ul.ie>
References: <1273737326-21211-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1273737326-21211-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1273737326-21211-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 13, 2010 at 04:55:20PM +0900, Naoya Horiguchi wrote:
> While hugepage is not currently swappable, rmapping can be useful
> for memory error handler.
> Using rmap, memory error handler can collect processes affected
> by hugepage errors and unmap them to contain error's effect.
> 

As a verification point, can you ensure that the libhugetlbfs "make
func" tests complete successfully with this patch applied? It's also
important that there is no oddness in the Hugepage-related counters in
/proc/meminfo. I'm not in the position to test it now unfortunately as
I'm on the road.

> Current status of hugepage rmap differs depending on mapping mode:
> - for shared hugepage:
>   we can collect processes using a hugepage through pagecache,
>   but can not unmap the hugepage because of the lack of mapcount.
> - for privately mapped hugepage:
>   we can neither collect processes nor unmap the hugepage.
> 
> To realize hugepage rmapping, this patch introduces mapcount for
> shared/private-mapped hugepage and anon_vma for private-mapped hugepage.
> 
> This patch can be the replacement of the following bug fix.
> 

Actually, you replace chunks but not all of that fix with this patch.
After this patch HUGETLB_POISON is never assigned but the definition still
exists in poison.h. You should also remove it if it is unnecessary.

>   commit 23be7468e8802a2ac1de6ee3eecb3ec7f14dc703
>   Author: Mel Gorman <mel@csn.ul.ie>
>   Date:   Fri Apr 23 13:17:56 2010 -0400
>   Subject: hugetlb: fix infinite loop in get_futex_key() when backed by huge pages
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Andi Kleen <andi@firstfloor.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> ---
>  include/linux/hugetlb.h |    1 +
>  mm/hugetlb.c            |   42 +++++++++++++++++++++++++++++++++++++++++-
>  mm/rmap.c               |   16 ++++++++++++++++
>  3 files changed, 58 insertions(+), 1 deletions(-)
> 
> diff --git v2.6.34-rc7/include/linux/hugetlb.h v2.6.34-rc7/include/linux/hugetlb.h
> index 78b4bc6..1d0c2a4 100644
> --- v2.6.34-rc7/include/linux/hugetlb.h
> +++ v2.6.34-rc7/include/linux/hugetlb.h
> @@ -108,6 +108,7 @@ static inline void hugetlb_report_meminfo(struct seq_file *m)
>  #define is_hugepage_only_range(mm, addr, len)	0
>  #define hugetlb_free_pgd_range(tlb, addr, end, floor, ceiling) ({BUG(); 0; })
>  #define hugetlb_fault(mm, vma, addr, flags)	({ BUG(); 0; })
> +#define huge_pte_offset(mm, address)	0
>  
>  #define hugetlb_change_protection(vma, address, end, newprot)
>  
> diff --git v2.6.34-rc7/mm/hugetlb.c v2.6.34-rc7/mm/hugetlb.c
> index ffbdfc8..149eb12 100644
> --- v2.6.34-rc7/mm/hugetlb.c
> +++ v2.6.34-rc7/mm/hugetlb.c
> @@ -18,6 +18,7 @@
>  #include <linux/bootmem.h>
>  #include <linux/sysfs.h>
>  #include <linux/slab.h>
> +#include <linux/rmap.h>
>  
>  #include <asm/page.h>
>  #include <asm/pgtable.h>
> @@ -2125,6 +2126,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
>  			entry = huge_ptep_get(src_pte);
>  			ptepage = pte_page(entry);
>  			get_page(ptepage);
> +			page_dup_rmap(ptepage);
>  			set_huge_pte_at(dst, addr, dst_pte, entry);
>  		}
>  		spin_unlock(&src->page_table_lock);
> @@ -2203,6 +2205,7 @@ void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
>  	flush_tlb_range(vma, start, end);
>  	mmu_notifier_invalidate_range_end(mm, start, end);
>  	list_for_each_entry_safe(page, tmp, &page_list, lru) {
> +		page_remove_rmap(page);
>  		list_del(&page->lru);
>  		put_page(page);
>  	}
> @@ -2268,6 +2271,26 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
>  	return 1;
>  }
>  
> +/*
> + * This is a counterpart of page_add_anon_rmap() for hugepage.
> + */
> +static void hugepage_add_anon_rmap(struct page *page,
> +			struct vm_area_struct *vma, unsigned long address)

So hugepage anon rmap is MAP_PRIVATE mappings.

> +{
> +	struct anon_vma *anon_vma = vma->anon_vma;
> +	int first;
> +
> +	BUG_ON(!anon_vma);
> +	BUG_ON(address < vma->vm_start || address >= vma->vm_end);
> +	first = atomic_inc_and_test(&page->_mapcount);
> +	if (first) {
> +		anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
> +		page->mapping = (struct address_space *) anon_vma;
> +		page->index = linear_page_index(vma, address)
> +			>> compound_order(page);

What was wrong with vma_hugecache_offset()? You can lookup the necessary
hstate with hstate_vma(). Even if they are similar functionally, the
use of hstate would match better how other parts of hugetlbfs handle
multiple page sizes.

> +	}
> +}

Ok, so this is against 2.6.34-rc7, right? For ordinary anon_vma's, there
is a chain of related vma's chained together via the anon_vma's. It's so
in the event of an unmapping, all the PTEs related to the page can be
found. Where are we doing the same here?

I think what you're getting with this is the ability to unmap MAP_PRIVATE pages
from one process but if there are multiple processes, the second process could
still end up referencing the poisoned MAP_PRIVATE page. Is this accurate? Even
if it is, I guess it's still an improvement over what currently happens.

> +
>  static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>  			unsigned long address, pte_t *ptep, pte_t pte,
>  			struct page *pagecache_page)
> @@ -2348,6 +2371,12 @@ retry_avoidcopy:
>  		huge_ptep_clear_flush(vma, address, ptep);
>  		set_huge_pte_at(mm, address, ptep,
>  				make_huge_pte(vma, new_page, 1));
> +		page_remove_rmap(old_page);
> +		/*
> +		 * We need not call anon_vma_prepare() because anon_vma
> +		 * is already prepared when the process fork()ed.
> +		 */
> +		hugepage_add_anon_rmap(new_page, vma, address);

This means that the anon_vma is shared between parent and child even
after fork. Does this not mean that the behaviour of anon_vma differs
between the core VM and hugetlb?

>  		/* Make the old page be freed below */
>  		new_page = old_page;
>  	}
> @@ -2450,7 +2479,11 @@ retry:
>  			spin_unlock(&inode->i_lock);
>  		} else {
>  			lock_page(page);
> -			page->mapping = HUGETLB_POISON;
> +			if (unlikely(anon_vma_prepare(vma))) {
> +				ret = VM_FAULT_OOM;
> +				goto backout_unlocked;
> +			}
> +			hugepage_add_anon_rmap(page, vma, address);

Seems ok for private pages at least.

>  		}
>  	}
>  
> @@ -2479,6 +2512,13 @@ retry:
>  				&& (vma->vm_flags & VM_SHARED)));
>  	set_huge_pte_at(mm, address, ptep, new_pte);
>  
> +	/*
> +	 * For privately mapped hugepage, _mapcount is incremented
> +	 * in hugetlb_cow(), so only increment for shared hugepage here.
> +	 */
> +	if (vma->vm_flags & VM_MAYSHARE)
> +		page_dup_rmap(page);
> +

What happens when try_to_unmap_file is called on a hugetlb page?

>  	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
>  		/* Optimization, do the COW without a second fault */
>  		ret = hugetlb_cow(mm, vma, address, ptep, new_pte, page);
> diff --git v2.6.34-rc7/mm/rmap.c v2.6.34-rc7/mm/rmap.c
> index 0feeef8..58cd2f9 100644
> --- v2.6.34-rc7/mm/rmap.c
> +++ v2.6.34-rc7/mm/rmap.c
> @@ -56,6 +56,7 @@
>  #include <linux/memcontrol.h>
>  #include <linux/mmu_notifier.h>
>  #include <linux/migrate.h>
> +#include <linux/hugetlb.h>
>  
>  #include <asm/tlbflush.h>
>  
> @@ -326,6 +327,8 @@ vma_address(struct page *page, struct vm_area_struct *vma)
>  	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
>  	unsigned long address;
>  
> +	if (unlikely(is_vm_hugetlb_page(vma)))
> +		pgoff = page->index << compound_order(page);

Again, it would be nice to use hstate information if possible just so
how the pagesize is discovered is consistent.

>  	address = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
>  	if (unlikely(address < vma->vm_start || address >= vma->vm_end)) {
>  		/* page should be within @vma mapping range */
> @@ -369,6 +372,12 @@ pte_t *page_check_address(struct page *page, struct mm_struct *mm,
>  	pte_t *pte;
>  	spinlock_t *ptl;
>  
> +	if (unlikely(PageHuge(page))) {
> +		pte = huge_pte_offset(mm, address);
> +		ptl = &mm->page_table_lock;
> +		goto check;
> +	}
> +
>  	pgd = pgd_offset(mm, address);
>  	if (!pgd_present(*pgd))
>  		return NULL;
> @@ -389,6 +398,7 @@ pte_t *page_check_address(struct page *page, struct mm_struct *mm,
>  	}
>  
>  	ptl = pte_lockptr(mm, pmd);
> +check:
>  	spin_lock(ptl);
>  	if (pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte)) {
>  		*ptlp = ptl;
> @@ -873,6 +883,12 @@ void page_remove_rmap(struct page *page)
>  		page_clear_dirty(page);
>  		set_page_dirty(page);
>  	}
> +	/*
> +	 * Mapping for Hugepages are not counted in NR_ANON_PAGES nor
> +	 * NR_FILE_MAPPED and no charged by memcg for now.
> +	 */
> +	if (unlikely(PageHuge(page)))
> +		return;
>  	if (PageAnon(page)) {
>  		mem_cgroup_uncharge_page(page);
>  		__dec_zone_page_state(page, NR_ANON_PAGES);

I don't see anything obviously wrong with this but it's a bit rushed and
there are a few snarls that I pointed out above. I'd like to hear it passed
the libhugetlbfs regression tests for different sizes without any oddness
in the counters.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
