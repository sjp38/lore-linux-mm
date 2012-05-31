Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id ED2296B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 21:56:38 -0400 (EDT)
Received: by dakp5 with SMTP id p5so704761dak.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 18:56:38 -0700 (PDT)
Date: Wed, 30 May 2012 18:56:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -V7 04/14] hugetlb: use mmu_gather instead of a temporary
 linked list for accumulating pages
In-Reply-To: <1338388739-22919-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1205301844010.25774@chino.kir.corp.google.com>
References: <1338388739-22919-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1338388739-22919-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, dhillf@gmail.com, mhocko@suse.cz, Andrew Morton <akpm@linux-foundation.org>, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On Wed, 30 May 2012, Aneesh Kumar K.V wrote:

> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index cc9281b..ff233e4 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -416,8 +416,8 @@ hugetlb_vmtruncate_list(struct prio_tree_root *root, pgoff_t pgoff)
>  		else
>  			v_offset = 0;
>  
> -		__unmap_hugepage_range(vma,
> -				vma->vm_start + v_offset, vma->vm_end, NULL);
> +		unmap_hugepage_range(vma, vma->vm_start + v_offset,
> +				     vma->vm_end, NULL);
>  	}
>  }
>  
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 217f528..c21e136 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -7,6 +7,7 @@
>  
>  struct ctl_table;
>  struct user_struct;
> +struct mmu_gather;
>  
>  #ifdef CONFIG_HUGETLB_PAGE
>  
> @@ -40,9 +41,10 @@ int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *,
>  			struct page **, struct vm_area_struct **,
>  			unsigned long *, int *, int, unsigned int flags);
>  void unmap_hugepage_range(struct vm_area_struct *,
> -			unsigned long, unsigned long, struct page *);
> -void __unmap_hugepage_range(struct vm_area_struct *,
> -			unsigned long, unsigned long, struct page *);
> +			  unsigned long, unsigned long, struct page *);
> +void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vms,

s/vms/vma/

> +				unsigned long start, unsigned long end,
> +				struct page *ref_page);
>  int hugetlb_prefault(struct address_space *, struct vm_area_struct *);
>  void hugetlb_report_meminfo(struct seq_file *);
>  int hugetlb_report_node_meminfo(int, char *);
> @@ -98,7 +100,6 @@ static inline unsigned long hugetlb_total_pages(void)
>  #define follow_huge_addr(mm, addr, write)	ERR_PTR(-EINVAL)
>  #define copy_hugetlb_page_range(src, dst, vma)	({ BUG(); 0; })
>  #define hugetlb_prefault(mapping, vma)		({ BUG(); 0; })
> -#define unmap_hugepage_range(vma, start, end, page)	BUG()
>  static inline void hugetlb_report_meminfo(struct seq_file *m)
>  {
>  }

Why?

> @@ -112,13 +113,24 @@ static inline void hugetlb_report_meminfo(struct seq_file *m)
>  #define hugetlb_free_pgd_range(tlb, addr, end, floor, ceiling) ({BUG(); 0; })
>  #define hugetlb_fault(mm, vma, addr, flags)	({ BUG(); 0; })
>  #define huge_pte_offset(mm, address)	0
> -#define dequeue_hwpoisoned_huge_page(page)	0
> +static inline int dequeue_hwpoisoned_huge_page(struct page *page)
> +{
> +	return 0;
> +}
> +

Unrelated from this patchset.

>  static inline void copy_huge_page(struct page *dst, struct page *src)
>  {
>  }
>  
>  #define hugetlb_change_protection(vma, address, end, newprot)
>  
> +static inline void __unmap_hugepage_range(struct mmu_gather *tlb,
> +			struct vm_area_struct *vma, unsigned long start,
> +			unsigned long end, struct page *ref_page)
> +{
> +	BUG();
> +}
> +

I think this should be done under the unmap_hugepage_range() definition 
you removed (and change it to be a static inline function as well).

>  #endif /* !CONFIG_HUGETLB_PAGE */
>  
>  #define HUGETLB_ANON_FILE "anon_hugepage"
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 9b97a5c..704a269 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -24,8 +24,9 @@
>  
>  #include <asm/page.h>
>  #include <asm/pgtable.h>
> -#include <linux/io.h>
> +#include <asm/tlb.h>
>  
> +#include <linux/io.h>
>  #include <linux/hugetlb.h>
>  #include <linux/node.h>
>  #include "internal.h"
> @@ -2310,30 +2311,26 @@ static int is_hugetlb_entry_hwpoisoned(pte_t pte)
>  		return 0;
>  }
>  
> -void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
> -			    unsigned long end, struct page *ref_page)
> +void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
> +			    unsigned long start, unsigned long end,
> +			    struct page *ref_page)
>  {
> +	int force_flush = 0;

Can this be bool?

>  	struct mm_struct *mm = vma->vm_mm;
>  	unsigned long address;
>  	pte_t *ptep;
>  	pte_t pte;
>  	struct page *page;
> -	struct page *tmp;
>  	struct hstate *h = hstate_vma(vma);
>  	unsigned long sz = huge_page_size(h);
>  
> -	/*
> -	 * A page gathering list, protected by per file i_mmap_mutex. The
> -	 * lock is used to avoid list corruption from multiple unmapping
> -	 * of the same page since we are using page->lru.
> -	 */
> -	LIST_HEAD(page_list);
> -
>  	WARN_ON(!is_vm_hugetlb_page(vma));
>  	BUG_ON(start & ~huge_page_mask(h));
>  	BUG_ON(end & ~huge_page_mask(h));
>  
> +	tlb_start_vma(tlb, vma);
>  	mmu_notifier_invalidate_range_start(mm, start, end);
> +again:
>  	spin_lock(&mm->page_table_lock);
>  	for (address = start; address < end; address += sz) {
>  		ptep = huge_pte_offset(mm, address);
> @@ -2372,30 +2369,45 @@ void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
>  		}
>  
>  		pte = huge_ptep_get_and_clear(mm, address, ptep);
> +		tlb_remove_tlb_entry(tlb, ptep, address);
>  		if (pte_dirty(pte))
>  			set_page_dirty(page);
> -		list_add(&page->lru, &page_list);
>  
> +		page_remove_rmap(page);
> +		force_flush = !__tlb_remove_page(tlb, page);
> +		if (force_flush)
> +			break;
>  		/* Bail out after unmapping reference page if supplied */
>  		if (ref_page)
>  			break;
>  	}
> -	flush_tlb_range(vma, start, end);
>  	spin_unlock(&mm->page_table_lock);
> -	mmu_notifier_invalidate_range_end(mm, start, end);
> -	list_for_each_entry_safe(page, tmp, &page_list, lru) {
> -		page_remove_rmap(page);
> -		list_del(&page->lru);
> -		put_page(page);
> +	/*
> +	 * mmu_gather ran out of room to batch pages, we break out of
> +	 * the PTE lock to avoid doing the potential expensive TLB invalidate
> +	 * and page-free while holding it.
> +	 */
> +	if (force_flush) {
> +		force_flush = 0;
> +		tlb_flush_mmu(tlb);
> +		if (address < end && !ref_page)
> +			goto again;

Shouldn't be copying "start" at the beginning of this function and then 
updating that copy now and use it as the loop initialization?

>  	}
> +	mmu_notifier_invalidate_range_end(mm, start, end);
> +	tlb_end_vma(tlb, vma);
>  }
>  
>  void unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
>  			  unsigned long end, struct page *ref_page)
>  {
> -	mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
> -	__unmap_hugepage_range(vma, start, end, ref_page);
> -	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
> +	struct mm_struct *mm;
> +	struct mmu_gather tlb;
> +
> +	mm = vma->vm_mm;
> +
> +	tlb_gather_mmu(&tlb, mm, 0);
> +	__unmap_hugepage_range(&tlb, vma, start, end, ref_page);
> +	tlb_finish_mmu(&tlb, start, end);
>  }
>  
>  /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
