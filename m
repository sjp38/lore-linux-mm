Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D0F3B6008F9
	for <linux-mm@kvack.org>; Tue, 25 May 2010 07:00:19 -0400 (EDT)
Date: Tue, 25 May 2010 11:59:57 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/7] hugetlb, rmap: add reverse mapping for hugepage
Message-ID: <20100525105957.GD29038@csn.ul.ie>
References: <1273737326-21211-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1273737326-21211-2-git-send-email-n-horiguchi@ah.jp.nec.com> <20100513152737.GE27949@csn.ul.ie> <20100514074641.GD10000@spritzerA.linux.bs1.fc.nec.co.jp> <20100514095449.GB21481@csn.ul.ie> <20100524071516.GC11008@spritzerA.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100524071516.GC11008@spritzerA.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, May 24, 2010 at 04:15:16PM +0900, Naoya Horiguchi wrote:
> Hi,
> 
> On Fri, May 14, 2010 at 10:54:50AM +0100, Mel Gorman wrote:
> > ...
> > > Hmm. I failed libhugetlbfs test with a oops in "private mapped" test :(
> > >
> >
> > That's not a disaster - it's what the regression test is for. I haven't
> > restarted the review in this case. I'll wait for another version that
> > passes those regression tests.
> 
> I have fixed bugs on "rmap for hugepage" patch in the latest version,
> where 'make func' test passes with the same result as in vanilla kernel.
> Other HWPOISON patches have no change.
> 

I'd have preferred to see the whole series but still...

> <SNIP>
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Andi Kleen <andi@firstfloor.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Larry Woodman <lwoodman@redhat.com>
> Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> ---
>  include/linux/hugetlb.h |   11 +-----
>  include/linux/mm.h      |    9 +++++
>  include/linux/pagemap.h |    8 ++++-
>  include/linux/poison.h  |    9 -----
>  mm/hugetlb.c            |   85 +++++++++++++++++++++++++++++++++++++++++++++--
>  mm/rmap.c               |   16 +++++++++
>  6 files changed, 115 insertions(+), 23 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 78b4bc6..a574d09 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -14,11 +14,6 @@ struct user_struct;
>  
>  int PageHuge(struct page *page);
>  
> -static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
> -{
> -	return vma->vm_flags & VM_HUGETLB;
> -}
> -
>  void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
>  int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
>  int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
> @@ -77,11 +72,6 @@ static inline int PageHuge(struct page *page)
>  	return 0;
>  }
>  
> -static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
> -{
> -	return 0;
> -}
> -

You collapse two functions into one here and move them to another
header. Is there a reason why pagemap.h could not include hugetlb.h?
It adds another header dependency which is bad but moving hugetlb stuff
into mm.h seems bad too.

>  static inline void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
>  {
>  }
> @@ -108,6 +98,7 @@ static inline void hugetlb_report_meminfo(struct seq_file *m)
>  #define is_hugepage_only_range(mm, addr, len)	0
>  #define hugetlb_free_pgd_range(tlb, addr, end, floor, ceiling) ({BUG(); 0; })
>  #define hugetlb_fault(mm, vma, addr, flags)	({ BUG(); 0; })
> +#define huge_pte_offset(mm, address)	0
>  
>  #define hugetlb_change_protection(vma, address, end, newprot)
>  
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 462acaf..ee2c442 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -366,6 +366,15 @@ static inline void set_compound_order(struct page *page, unsigned long order)
>  	page[1].lru.prev = (void *)order;
>  }
>  
> +static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
> +{
> +#ifdef CONFIG_HUGETLBFS
> +	return vma->vm_flags & VM_HUGETLB;
> +#else
> +	return 0;
> +#endif
> +}
> +
>  /*
>   * Multiple processes may "see" the same page. E.g. for untouched
>   * mappings of /dev/null, all processes see the same page full of
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 3c62ed4..9e0bd64 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -281,10 +281,16 @@ static inline loff_t page_offset(struct page *page)
>  	return ((loff_t)page->index) << PAGE_CACHE_SHIFT;
>  }
>  
> +extern pgoff_t linear_hugepage_index(struct vm_area_struct *vma,
> +				     unsigned long address);
> +
>  static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
>  					unsigned long address)
>  {
> -	pgoff_t pgoff = (address - vma->vm_start) >> PAGE_SHIFT;
> +	pgoff_t pgoff;
> +	if (unlikely(is_vm_hugetlb_page(vma)))
> +		return linear_hugepage_index(vma, address);
> +	pgoff = (address - vma->vm_start) >> PAGE_SHIFT;
>  	pgoff += vma->vm_pgoff;
>  	return pgoff >> (PAGE_CACHE_SHIFT - PAGE_SHIFT);
>  }
> diff --git a/include/linux/poison.h b/include/linux/poison.h
> index 34066ff..2110a81 100644
> --- a/include/linux/poison.h
> +++ b/include/linux/poison.h
> @@ -48,15 +48,6 @@
>  #define POISON_FREE	0x6b	/* for use-after-free poisoning */
>  #define	POISON_END	0xa5	/* end-byte of poisoning */
>  
> -/********** mm/hugetlb.c **********/
> -/*
> - * Private mappings of hugetlb pages use this poisoned value for
> - * page->mapping. The core VM should not be doing anything with this mapping
> - * but futex requires the existence of some page->mapping value even though it
> - * is unused if PAGE_MAPPING_ANON is set.
> - */
> -#define HUGETLB_POISON	((void *)(0x00300300 + POISON_POINTER_DELTA + PAGE_MAPPING_ANON))
> -
>  /********** arch/$ARCH/mm/init.c **********/
>  #define POISON_FREE_INITMEM	0xcc
>  
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 4c9e6bb..b8b8ea4 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -18,6 +18,7 @@
>  #include <linux/bootmem.h>
>  #include <linux/sysfs.h>
>  #include <linux/slab.h>
> +#include <linux/rmap.h>
>  
>  #include <asm/page.h>
>  #include <asm/pgtable.h>
> @@ -220,6 +221,12 @@ static pgoff_t vma_hugecache_offset(struct hstate *h,
>  			(vma->vm_pgoff >> huge_page_order(h));
>  }
>  
> +pgoff_t linear_hugepage_index(struct vm_area_struct *vma,
> +				     unsigned long address)
> +{
> +	return vma_hugecache_offset(hstate_vma(vma), vma, address);
> +}
> +
>  /*
>   * Return the size of the pages allocated when backing a VMA. In the majority
>   * cases this will be same size as used by the page table entries.
> @@ -546,8 +553,8 @@ static void free_huge_page(struct page *page)
>  
>  	mapping = (struct address_space *) page_private(page);
>  	set_page_private(page, 0);
> -	page->mapping = NULL;
>  	BUG_ON(page_count(page));
> +	BUG_ON(page_mapcount(page));
>  	INIT_LIST_HEAD(&page->lru);
>  
>  	spin_lock(&hugetlb_lock);
> @@ -2125,6 +2132,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
>  			entry = huge_ptep_get(src_pte);
>  			ptepage = pte_page(entry);
>  			get_page(ptepage);
> +			page_dup_rmap(ptepage);
>  			set_huge_pte_at(dst, addr, dst_pte, entry);
>  		}
>  		spin_unlock(&src->page_table_lock);
> @@ -2203,6 +2211,7 @@ void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
>  	flush_tlb_range(vma, start, end);
>  	mmu_notifier_invalidate_range_end(mm, start, end);
>  	list_for_each_entry_safe(page, tmp, &page_list, lru) {
> +		page_remove_rmap(page);
>  		list_del(&page->lru);
>  		put_page(page);
>  	}
> @@ -2268,6 +2277,50 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
>  	return 1;
>  }
>  
> +/*
> + * The following three functions are counterparts of ones in mm/rmap.c.
> + * Unlike them, these functions don't have accounting code nor lru code,
> + * because we handle hugepages differently from common anonymous pages.
> + */
> +static void __hugepage_set_anon_rmap(struct page *page,
> +	struct vm_area_struct *vma, unsigned long address, int exclusive)
> +{
> +	struct anon_vma *anon_vma = vma->anon_vma;
> +	BUG_ON(!anon_vma);
> +	if (!exclusive) {
> +		struct anon_vma_chain *avc;
> +		avc = list_entry(vma->anon_vma_chain.prev,
> +				 struct anon_vma_chain, same_vma);
> +		anon_vma = avc->anon_vma;
> +	}
> +	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
> +	page->mapping = (struct address_space *) anon_vma;
> +	page->index = linear_page_index(vma, address);
> +}
> +
> +static void hugepage_add_anon_rmap(struct page *page,
> +			struct vm_area_struct *vma, unsigned long address)
> +{
> +	struct anon_vma *anon_vma = vma->anon_vma;
> +	int first;
> +	BUG_ON(!anon_vma);
> +	BUG_ON(address < vma->vm_start || address >= vma->vm_end);
> +	first = atomic_inc_and_test(&page->_mapcount);
> +	if (first)
> +		__hugepage_set_anon_rmap(page, vma, address, 0);
> +}
> +
> +void hugepage_add_new_anon_rmap(struct page *page,
> +	struct vm_area_struct *vma, unsigned long address)
> +{
> +	BUG_ON(address < vma->vm_start || address >= vma->vm_end);
> +	atomic_set(&page->_mapcount, 0);
> +	__hugepage_set_anon_rmap(page, vma, address, 1);
> +}
> +

Is it possible to move these to mm/rmap.c so all the anon rmap adding
code is in the same place? In the event that __page_set_anon_rmap() is
updated, there would be a greater chance the hugepage equivalent will be
noticed and updated.

I didn't spot anything particularly bad after this.  If these minor issues
could be addressed and the full series reposted, I'll test the hugetlb side
of things further just to be sure.

> +/*
> + * Hugetlb_cow() should be called with page lock of the original hugepage held.
> + */
>  static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>  			unsigned long address, pte_t *ptep, pte_t pte,
>  			struct page *pagecache_page)
> @@ -2282,8 +2335,10 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>  retry_avoidcopy:
>  	/* If no-one else is actually using this page, avoid the copy
>  	 * and just make the page writable */
> -	avoidcopy = (page_count(old_page) == 1);
> +	avoidcopy = (page_mapcount(old_page) == 1);
>  	if (avoidcopy) {
> +		if (PageAnon(old_page))
> +			page_move_anon_rmap(old_page, vma, address);
>  		set_huge_ptep_writable(vma, address, ptep);
>  		return 0;
>  	}
> @@ -2334,6 +2389,13 @@ retry_avoidcopy:
>  		return -PTR_ERR(new_page);
>  	}
>  
> +	/*
> +	 * When the original hugepage is shared one, it does not have
> +	 * anon_vma prepared.
> +	 */
> +	if (unlikely(anon_vma_prepare(vma)))
> +		return VM_FAULT_OOM;
> +
>  	copy_huge_page(new_page, old_page, address, vma);
>  	__SetPageUptodate(new_page);
>  
> @@ -2348,6 +2410,8 @@ retry_avoidcopy:
>  		huge_ptep_clear_flush(vma, address, ptep);
>  		set_huge_pte_at(mm, address, ptep,
>  				make_huge_pte(vma, new_page, 1));
> +		page_remove_rmap(old_page);
> +		hugepage_add_anon_rmap(new_page, vma, address);
>  		/* Make the old page be freed below */
>  		new_page = old_page;
>  	}
> @@ -2448,10 +2512,17 @@ retry:
>  			spin_lock(&inode->i_lock);
>  			inode->i_blocks += blocks_per_huge_page(h);
>  			spin_unlock(&inode->i_lock);
> +			page_dup_rmap(page);
>  		} else {
>  			lock_page(page);
> -			page->mapping = HUGETLB_POISON;
> +			if (unlikely(anon_vma_prepare(vma))) {
> +				ret = VM_FAULT_OOM;
> +				goto backout_unlocked;
> +			}
> +			hugepage_add_new_anon_rmap(page, vma, address);
>  		}
> +	} else {
> +		page_dup_rmap(page);
>  	}
>  
>  	/*
> @@ -2503,6 +2574,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	pte_t *ptep;
>  	pte_t entry;
>  	int ret;
> +	struct page *page = NULL;
>  	struct page *pagecache_page = NULL;
>  	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
>  	struct hstate *h = hstate_vma(vma);
> @@ -2544,6 +2616,11 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  								vma, address);
>  	}
>  
> +	if (!pagecache_page) {
> +		page = pte_page(entry);
> +		lock_page(page);
> +	}
> +
>  	spin_lock(&mm->page_table_lock);
>  	/* Check for a racing update before calling hugetlb_cow */
>  	if (unlikely(!pte_same(entry, huge_ptep_get(ptep))))
> @@ -2569,6 +2646,8 @@ out_page_table_lock:
>  	if (pagecache_page) {
>  		unlock_page(pagecache_page);
>  		put_page(pagecache_page);
> +	} else {
> +		unlock_page(page);
>  	}
>  
>  out_mutex:
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 0feeef8..4ec6b1c 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
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
> +		pgoff = page->index << huge_page_order(page_hstate(page));
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
> +	 * Hugepages are not counted in NR_ANON_PAGES nor NR_FILE_MAPPED
> +	 * and not charged by memcg for now.
> +	 */
> +	if (unlikely(PageHuge(page)))
> +		return;
>  	if (PageAnon(page)) {
>  		mem_cgroup_uncharge_page(page);
>  		__dec_zone_page_state(page, NR_ANON_PAGES);
> -- 
> 1.7.0
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
