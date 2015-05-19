Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id D66DB6B00A8
	for <linux-mm@kvack.org>; Tue, 19 May 2015 08:43:49 -0400 (EDT)
Received: by wizk4 with SMTP id k4so115975343wiz.1
        for <linux-mm@kvack.org>; Tue, 19 May 2015 05:43:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dg10si16683383wjb.152.2015.05.19.05.43.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 19 May 2015 05:43:48 -0700 (PDT)
Message-ID: <555B3000.6040805@suse.cz>
Date: Tue, 19 May 2015 14:43:44 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv5 25/28] thp: reintroduce split_huge_page()
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-26-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-26-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/23/2015 11:04 PM, Kirill A. Shutemov wrote:
> This patch adds implementation of split_huge_page() for new
> refcountings.
>
> Unlike previous implementation, new split_huge_page() can fail if
> somebody holds GUP pin on the page. It also means that pin on page
> would prevent it from bening split under you. It makes situation in
> many places much cleaner.
>
> The basic scheme of split_huge_page():
>
>    - Check that sum of mapcounts of all subpage is equal to page_count()
>      plus one (caller pin). Foll off with -EBUSY. This way we can avoid
>      useless PMD-splits.
>
>    - Freeze the page counters by splitting all PMD and setup migration
>      PTEs.
>
>    - Re-check sum of mapcounts against page_count(). Page's counts are
>      stable now. -EBUSY if page is pinned.
>
>    - Split compound page.
>
>    - Unfreeze the page by removing migration entries.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>   include/linux/huge_mm.h |   7 +-
>   include/linux/pagemap.h |   9 +-
>   mm/huge_memory.c        | 322 ++++++++++++++++++++++++++++++++++++++++++++++++
>   mm/internal.h           |  26 +++-
>   mm/rmap.c               |  21 ----
>   5 files changed, 357 insertions(+), 28 deletions(-)
>
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index b7844c73b7db..3c0a50ed3eb8 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -92,8 +92,11 @@ extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
>
>   extern unsigned long transparent_hugepage_flags;
>
> -#define split_huge_page_to_list(page, list) BUILD_BUG()
> -#define split_huge_page(page) BUILD_BUG()
> +int split_huge_page_to_list(struct page *page, struct list_head *list);
> +static inline int split_huge_page(struct page *page)
> +{
> +	return split_huge_page_to_list(page, NULL);
> +}
>
>   void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>   		unsigned long address);
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 7c3790764795..ffbb23dbebba 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -387,10 +387,17 @@ static inline struct page *read_mapping_page(struct address_space *mapping,
>    */
>   static inline pgoff_t page_to_pgoff(struct page *page)
>   {
> +	pgoff_t pgoff;
> +
>   	if (unlikely(PageHeadHuge(page)))
>   		return page->index << compound_order(page);
> -	else
> +
> +	if (likely(!PageTransTail(page)))
>   		return page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> +
> +	pgoff = page->first_page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> +	pgoff += page - page->first_page;
> +	return pgoff;

This could use some comment or maybe separate preparatory patch?

>   }
>
>   /*
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 2f9e2e882bab..7ad338ab2ac8 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2704,3 +2704,325 @@ void __vma_adjust_trans_huge(struct vm_area_struct *vma,
>   			split_huge_pmd_address(next, nstart);
>   	}
>   }
> +
> +static void freeze_page_vma(struct vm_area_struct *vma, struct page *page,
> +		unsigned long address)
> +{
> +	spinlock_t *ptl;
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	pte_t *pte;
> +	int i;
> +
> +	pgd = pgd_offset(vma->vm_mm, address);
> +	if (!pgd_present(*pgd))
> +		return;
> +	pud = pud_offset(pgd, address);
> +	if (!pud_present(*pud))
> +		return;
> +	pmd = pmd_offset(pud, address);
> +	ptl = pmd_lock(vma->vm_mm, pmd);
> +	if (!pmd_present(*pmd)) {
> +		spin_unlock(ptl);
> +		return;
> +	}
> +	if (pmd_trans_huge(*pmd)) {
> +		if (page == pmd_page(*pmd))
> +			__split_huge_pmd_locked(vma, pmd, address, true);
> +		spin_unlock(ptl);
> +		return;
> +	}
> +	spin_unlock(ptl);
> +
> +	pte = pte_offset_map_lock(vma->vm_mm, pmd, address, &ptl);
> +	for (i = 0; i < HPAGE_PMD_NR; i++, address += PAGE_SIZE, page++) {
> +		pte_t entry, swp_pte;
> +		swp_entry_t swp_entry;
> +
> +		if (!pte_present(pte[i]))
> +			continue;
> +		if (page_to_pfn(page) != pte_pfn(pte[i]))
> +			continue;
> +		flush_cache_page(vma, address, page_to_pfn(page));
> +		entry = ptep_clear_flush(vma, address, pte + i);
> +		swp_entry = make_migration_entry(page, pte_write(entry));
> +		swp_pte = swp_entry_to_pte(swp_entry);
> +		if (pte_soft_dirty(entry))
> +			swp_pte = pte_swp_mksoft_dirty(swp_pte);
> +		set_pte_at(vma->vm_mm, address, pte + i, swp_pte);
> +	}
> +	pte_unmap_unlock(pte, ptl);
> +}
> +
> +static void freeze_page(struct anon_vma *anon_vma, struct page *page)
> +{
> +	struct anon_vma_chain *avc;
> +	pgoff_t pgoff = page_to_pgoff(page);
> +
> +	VM_BUG_ON_PAGE(!PageHead(page), page);
> +
> +	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff,
> +			pgoff + HPAGE_PMD_NR - 1) {
> +		unsigned long haddr;
> +
> +		haddr = __vma_address(page, avc->vma) & HPAGE_PMD_MASK;
> +		mmu_notifier_invalidate_range_start(avc->vma->vm_mm,
> +				haddr, haddr + HPAGE_PMD_SIZE);
> +		freeze_page_vma(avc->vma, page, haddr);
> +		mmu_notifier_invalidate_range_end(avc->vma->vm_mm,
> +				haddr, haddr + HPAGE_PMD_SIZE);
> +	}
> +}
> +
> +static void unfreeze_page_vma(struct vm_area_struct *vma, struct page *page,
> +		unsigned long address)
> +{
> +	spinlock_t *ptl;
> +	pmd_t *pmd;
> +	pte_t *pte, entry;
> +	swp_entry_t swp_entry;
> +
> +	pmd = mm_find_pmd(vma->vm_mm, address);
> +	if (!pmd)
> +		return;
> +	pte = pte_offset_map_lock(vma->vm_mm, pmd, address, &ptl);
> +
> +	if (!is_swap_pte(*pte))
> +		goto unlock;
> +
> +	swp_entry = pte_to_swp_entry(*pte);
> +	if (!is_migration_entry(swp_entry) ||
> +			migration_entry_to_page(swp_entry) != page)
> +		goto unlock;
> +
> +	entry = pte_mkold(mk_pte(page, vma->vm_page_prot));
> +	if (is_write_migration_entry(swp_entry))
> +		entry = maybe_mkwrite(entry, vma);
> +
> +	flush_dcache_page(page);
> +	set_pte_at(vma->vm_mm, address, pte, entry);
> +
> +	/* No need to invalidate - it was non-present before */
> +	update_mmu_cache(vma, address, pte);
> +unlock:
> +	pte_unmap_unlock(pte, ptl);
> +}
> +
> +static void unfreeze_page(struct anon_vma *anon_vma, struct page *page)
> +{
> +	struct anon_vma_chain *avc;
> +	pgoff_t pgoff = page_to_pgoff(page);
> +	int i;
> +
> +	for (i = 0; i < HPAGE_PMD_NR; i++, pgoff++, page++) {

In case of freeze_page() this cycle is the inner one and it can batch 
ptl lock. Why not here?

> +		if (!page_mapcount(page))
> +			continue;
> +
> +		anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root,
> +				pgoff, pgoff) {
> +			unsigned long address = vma_address(page, avc->vma);
> +
> +			mmu_notifier_invalidate_range_start(avc->vma->vm_mm,
> +					address, address + PAGE_SIZE);
> +			unfreeze_page_vma(avc->vma, page, address);
> +			mmu_notifier_invalidate_range_end(avc->vma->vm_mm,
> +					address, address + PAGE_SIZE);
> +		}
> +	}
> +}
> +
> +static int total_mapcount(struct page *page)
> +{
> +	int i, ret;
> +
> +	ret = compound_mapcount(page);
> +	for (i = 0; i < HPAGE_PMD_NR; i++)
> +		ret += atomic_read(&page[i]._mapcount) + 1;
> +
> +	/*
> +	 * Positive compound_mapcount() offsets ->_mapcount in every subpage by
> +	 * one. Let's substract it here.
> +	 */
> +	if (compound_mapcount(page))
> +		ret -= HPAGE_PMD_NR;
> +
> +	return ret;
> +}
> +
> +static int __split_huge_page_tail(struct page *head, int tail,
> +		struct lruvec *lruvec, struct list_head *list)
> +{
> +	int mapcount;
> +	struct page *page_tail = head + tail;
> +
> +	mapcount = page_mapcount(page_tail);
> +	BUG_ON(atomic_read(&page_tail->_count) != 0);

VM_BUG_ON?

> +
> +	/*
> +	 * tail_page->_count is zero and not changing from under us. But
> +	 * get_page_unless_zero() may be running from under us on the
> +	 * tail_page. If we used atomic_set() below instead of atomic_add(), we
> +	 * would then run atomic_set() concurrently with
> +	 * get_page_unless_zero(), and atomic_set() is implemented in C not
> +	 * using locked ops. spin_unlock on x86 sometime uses locked ops
> +	 * because of PPro errata 66, 92, so unless somebody can guarantee
> +	 * atomic_set() here would be safe on all archs (and not only on x86),
> +	 * it's safer to use atomic_add().
> +	 */
> +	atomic_add(page_mapcount(page_tail) + 1, &page_tail->_count);
> +
> +	/* after clearing PageTail the gup refcount can be released */
> +	smp_mb__after_atomic();
> +
> +	/*
> +	 * retain hwpoison flag of the poisoned tail page:
> +	 *   fix for the unsuitable process killed on Guest Machine(KVM)
> +	 *   by the memory-failure.
> +	 */
> +	page_tail->flags &= ~PAGE_FLAGS_CHECK_AT_PREP | __PG_HWPOISON;
> +	page_tail->flags |= (head->flags &
> +			((1L << PG_referenced) |
> +			 (1L << PG_swapbacked) |
> +			 (1L << PG_mlocked) |
> +			 (1L << PG_uptodate) |
> +			 (1L << PG_active) |
> +			 (1L << PG_locked) |
> +			 (1L << PG_unevictable)));
> +	page_tail->flags |= (1L << PG_dirty);
> +
> +	/* clear PageTail before overwriting first_page */
> +	smp_wmb();
> +
> +	/* ->mapping in first tail page is compound_mapcount */
> +	BUG_ON(tail != 1 && page_tail->mapping != TAIL_MAPPING);

VM_BUG_ON?

> +	page_tail->mapping = head->mapping;
> +
> +	page_tail->index = head->index + tail;
> +	page_cpupid_xchg_last(page_tail, page_cpupid_last(head));
> +	lru_add_page_tail(head, page_tail, lruvec, list);
> +
> +	return mapcount;
> +}
> +
> +static void __split_huge_page(struct page *page, struct list_head *list)
> +{
> +	struct page *head = compound_head(page);
> +	struct zone *zone = page_zone(head);
> +	struct lruvec *lruvec;
> +	int i, tail_mapcount;
> +
> +	/* prevent PageLRU to go away from under us, and freeze lru stats */
> +	spin_lock_irq(&zone->lru_lock);
> +	lruvec = mem_cgroup_page_lruvec(head, zone);
> +
> +	/* complete memcg works before add pages to LRU */
> +	mem_cgroup_split_huge_fixup(head);
> +
> +	tail_mapcount = 0;
> +	for (i = HPAGE_PMD_NR - 1; i >= 1; i--)
> +		tail_mapcount += __split_huge_page_tail(head, i, lruvec, list);
> +	atomic_sub(tail_mapcount, &head->_count);
> +
> +	ClearPageCompound(head);
> +	spin_unlock_irq(&zone->lru_lock);
> +
> +	unfreeze_page(page_anon_vma(head), head);
> +
> +	for (i = 0; i < HPAGE_PMD_NR; i++) {
> +		struct page *subpage = head + i;
> +		if (subpage == page)
> +			continue;
> +		unlock_page(subpage);
> +
> +		/*
> +		 * Subpages may be freed if there wasn't any mapping
> +		 * like if add_to_swap() is running on a lru page that
> +		 * had its mapping zapped. And freeing these pages
> +		 * requires taking the lru_lock so we do the put_page
> +		 * of the tail pages after the split is complete.
> +		 */
> +		put_page(subpage);
> +	}
> +}
> +
> +/*
> + * This function splits huge page into normal pages. @page can point to any
> + * subpage of huge page to split. Split doesn't change the position of @page.
> + *
> + * Only caller must hold pin on the @page, otherwise split fails with -EBUSY.
> + * The huge page must be locked.
> + *
> + * If @list is null, tail pages will be added to LRU list, otherwise, to @list.
> + *
> + * Both head page and tail pages will inherit mapping, flags, and so on from
> + * the hugepage.
> + *
> + * GUP pin and PG_locked transfered to @page. Rest subpages can be freed if
> + * they are not mapped.
> + *
> + * Returns 0 if the hugepage is split successfully.
> + * Returns -EBUSY if the page is pinned or if anon_vma disappeared from under
> + * us.
> + */
> +int split_huge_page_to_list(struct page *page, struct list_head *list)
> +{
> +	struct page *head = compound_head(page);
> +	struct anon_vma *anon_vma;
> +	int mapcount, ret;
> +
> +	BUG_ON(is_huge_zero_page(page));
> +	BUG_ON(!PageAnon(page));
> +	BUG_ON(!PageLocked(page));
> +	BUG_ON(!PageSwapBacked(page));
> +	BUG_ON(!PageCompound(page));

VM_BUG_ONs?

> +
> +	/*
> +	 * The caller does not necessarily hold an mmap_sem that would prevent
> +	 * the anon_vma disappearing so we first we take a reference to it
> +	 * and then lock the anon_vma for write. This is similar to
> +	 * page_lock_anon_vma_read except the write lock is taken to serialise
> +	 * against parallel split or collapse operations.
> +	 */
> +	anon_vma = page_get_anon_vma(head);
> +	if (!anon_vma) {
> +		ret = -EBUSY;
> +		goto out;
> +	}
> +	anon_vma_lock_write(anon_vma);
> +
> +	/*
> +	 * Racy check if we can split the page, before freeze_page() will
> +	 * split PMDs
> +	 */
> +	if (total_mapcount(head) != page_count(head) - 1) {
> +		ret = -EBUSY;
> +		goto out_unlock;
> +	}
> +
> +	freeze_page(anon_vma, head);
> +	VM_BUG_ON_PAGE(compound_mapcount(head), head);
> +
> +	mapcount = total_mapcount(head);
> +	if (mapcount == page_count(head) - 1) {
> +		__split_huge_page(page, list);
> +		ret = 0;
> +	} else if (mapcount > page_count(page) - 1) {

It's confusing to use page_count(head) in one test and page_count(page) 
in other, although I know it should be same. Also what if you read a 
different value because something broke?

> +		pr_alert("total_mapcount: %u, page_count(): %u\n",
> +				mapcount, page_count(page));

Here you determine page_count(page) again although it could have 
possibly changed (we are in path where something went wrong already) so 
you potentially print different value than the one that was tested.


> +		if (PageTail(page))
> +			dump_page(head, NULL);
> +		dump_page(page, "tail_mapcount > page_count(page) - 1");

Here you say "tail_mapcount" which means something else in different places.
Also isn't the whole "else if" test a DEBUG_VM material as well?

> +		BUG();
> +	} else {
> +		unfreeze_page(anon_vma, head);
> +		ret = -EBUSY;
> +	}
> +
> +out_unlock:
> +	anon_vma_unlock_write(anon_vma);
> +	put_anon_vma(anon_vma);
> +out:
> +	count_vm_event(!ret ? THP_SPLIT_PAGE : THP_SPLIT_PAGE_FAILED);
> +	return ret;
> +}
> diff --git a/mm/internal.h b/mm/internal.h
> index 98bce4d12a16..aee0f2566fdd 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -13,6 +13,7 @@
>
>   #include <linux/fs.h>
>   #include <linux/mm.h>
> +#include <linux/pagemap.h>
>
>   void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
>   		unsigned long floor, unsigned long ceiling);
> @@ -244,10 +245,27 @@ static inline void mlock_migrate_page(struct page *newpage, struct page *page)
>
>   extern pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma);
>
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -extern unsigned long vma_address(struct page *page,
> -				 struct vm_area_struct *vma);
> -#endif
> +/*
> + * At what user virtual address is page expected in @vma?
> + */
> +static inline unsigned long
> +__vma_address(struct page *page, struct vm_area_struct *vma)
> +{
> +	pgoff_t pgoff = page_to_pgoff(page);
> +	return vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
> +}
> +
> +static inline unsigned long
> +vma_address(struct page *page, struct vm_area_struct *vma)
> +{
> +	unsigned long address = __vma_address(page, vma);
> +
> +	/* page should be within @vma mapping range */
> +	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
> +
> +	return address;
> +}
> +
>   #else /* !CONFIG_MMU */
>   static inline void clear_page_mlock(struct page *page) { }
>   static inline void mlock_vma_page(struct page *page) { }
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 047953145710..723af5bbeb02 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -561,27 +561,6 @@ void page_unlock_anon_vma_read(struct anon_vma *anon_vma)
>   }
>
>   /*
> - * At what user virtual address is page expected in @vma?
> - */
> -static inline unsigned long
> -__vma_address(struct page *page, struct vm_area_struct *vma)
> -{
> -	pgoff_t pgoff = page_to_pgoff(page);
> -	return vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
> -}
> -
> -inline unsigned long
> -vma_address(struct page *page, struct vm_area_struct *vma)
> -{
> -	unsigned long address = __vma_address(page, vma);
> -
> -	/* page should be within @vma mapping range */
> -	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
> -
> -	return address;
> -}
> -
> -/*
>    * At what user virtual address is page expected in vma?
>    * Caller should check the page is actually part of the vma.
>    */
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
