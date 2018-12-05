Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5D0806B7554
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 11:48:31 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e17so10035090edr.7
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 08:48:31 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f10-v6si3541373eja.11.2018.12.05.08.48.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 08:48:28 -0800 (PST)
Date: Wed, 5 Dec 2018 17:48:27 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 2/3] mm/mmu_notifier: use structure for
 invalidate_range_start/end calls v2
Message-ID: <20181205164827.GH30615@quack2.suse.cz>
References: <20181205053628.3210-1-jglisse@redhat.com>
 <20181205053628.3210-3-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181205053628.3210-3-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <zwisler@kernel.org>, Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Felix Kuehling <felix.kuehling@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Wed 05-12-18 00:36:27, jglisse@redhat.com wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> To avoid having to change many call sites everytime we want to add a
> parameter use a structure to group all parameters for the mmu_notifier
> invalidate_range_start/end cakks. No functional changes with this
> patch.
> 
> Changes since v1:
>     - introduce mmu_notifier_range_init() as an helper to initialize
>       the range structure allowing to optimize out the case when mmu
>       notifier is not enabled
>     - fix mm/migrate.c migrate_vma_collect()
> 
> Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> Acked-by: Christian König <christian.koenig@amd.com>

The patch looks good to me. You can add:

Acked-by: Jan Kara <jack@suse.cz>

								Honza


> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: Ross Zwisler <zwisler@kernel.org>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Radim Krčmář <rkrcmar@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Felix Kuehling <felix.kuehling@amd.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: kvm@vger.kernel.org
> Cc: dri-devel@lists.freedesktop.org
> Cc: linux-rdma@vger.kernel.org
> Cc: linux-fsdevel@vger.kernel.org
> ---
>  fs/dax.c                     |  8 +--
>  fs/proc/task_mmu.c           |  7 ++-
>  include/linux/mm.h           |  4 +-
>  include/linux/mmu_notifier.h | 87 +++++++++++++++++++++-----------
>  kernel/events/uprobes.c      | 10 ++--
>  mm/huge_memory.c             | 54 ++++++++++----------
>  mm/hugetlb.c                 | 52 ++++++++++---------
>  mm/khugepaged.c              | 10 ++--
>  mm/ksm.c                     | 21 ++++----
>  mm/madvise.c                 | 21 ++++----
>  mm/memory.c                  | 97 ++++++++++++++++++------------------
>  mm/migrate.c                 | 25 +++++-----
>  mm/mmu_notifier.c            | 35 +++----------
>  mm/mprotect.c                | 15 +++---
>  mm/mremap.c                  | 10 ++--
>  mm/oom_kill.c                | 17 ++++---
>  mm/rmap.c                    | 30 ++++++-----
>  17 files changed, 258 insertions(+), 245 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 9bcce89ea18e..874085bacaf5 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -758,7 +758,8 @@ static void dax_entry_mkclean(struct address_space *mapping, pgoff_t index,
>  
>  	i_mmap_lock_read(mapping);
>  	vma_interval_tree_foreach(vma, &mapping->i_mmap, index, index) {
> -		unsigned long address, start, end;
> +		struct mmu_notifier_range range;
> +		unsigned long address;
>  
>  		cond_resched();
>  
> @@ -772,7 +773,8 @@ static void dax_entry_mkclean(struct address_space *mapping, pgoff_t index,
>  		 * call mmu_notifier_invalidate_range_start() on our behalf
>  		 * before taking any lock.
>  		 */
> -		if (follow_pte_pmd(vma->vm_mm, address, &start, &end, &ptep, &pmdp, &ptl))
> +		if (follow_pte_pmd(vma->vm_mm, address, &range,
> +				   &ptep, &pmdp, &ptl))
>  			continue;
>  
>  		/*
> @@ -814,7 +816,7 @@ static void dax_entry_mkclean(struct address_space *mapping, pgoff_t index,
>  			pte_unmap_unlock(ptep, ptl);
>  		}
>  
> -		mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
> +		mmu_notifier_invalidate_range_end(&range);
>  	}
>  	i_mmap_unlock_read(mapping);
>  }
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 47c3764c469b..b3ddceb003bc 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1096,6 +1096,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  		return -ESRCH;
>  	mm = get_task_mm(task);
>  	if (mm) {
> +		struct mmu_notifier_range range;
>  		struct clear_refs_private cp = {
>  			.type = type,
>  		};
> @@ -1139,11 +1140,13 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  				downgrade_write(&mm->mmap_sem);
>  				break;
>  			}
> -			mmu_notifier_invalidate_range_start(mm, 0, -1);
> +
> +			mmu_notifier_range_init(&range, mm, 0, -1UL);
> +			mmu_notifier_invalidate_range_start(&range);
>  		}
>  		walk_page_range(0, mm->highest_vm_end, &clear_refs_walk);
>  		if (type == CLEAR_REFS_SOFT_DIRTY)
> -			mmu_notifier_invalidate_range_end(mm, 0, -1);
> +			mmu_notifier_invalidate_range_end(&range);
>  		tlb_finish_mmu(&tlb, 0, -1);
>  		up_read(&mm->mmap_sem);
>  out_mm:
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 5411de93a363..e7b6f2b30713 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1397,6 +1397,8 @@ struct mm_walk {
>  	void *private;
>  };
>  
> +struct mmu_notifier_range;
> +
>  int walk_page_range(unsigned long addr, unsigned long end,
>  		struct mm_walk *walk);
>  int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk);
> @@ -1405,7 +1407,7 @@ void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
>  int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
>  			struct vm_area_struct *vma);
>  int follow_pte_pmd(struct mm_struct *mm, unsigned long address,
> -			     unsigned long *start, unsigned long *end,
> +		 	     struct mmu_notifier_range *range,
>  			     pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp);
>  int follow_pfn(struct vm_area_struct *vma, unsigned long address,
>  	unsigned long *pfn);
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index 368f0c1a049d..39b06772427f 100644
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -220,11 +220,8 @@ extern int __mmu_notifier_test_young(struct mm_struct *mm,
>  				     unsigned long address);
>  extern void __mmu_notifier_change_pte(struct mm_struct *mm,
>  				      unsigned long address, pte_t pte);
> -extern int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end,
> -				  bool blockable);
> -extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end,
> +extern int __mmu_notifier_invalidate_range_start(struct mmu_notifier_range *);
> +extern void __mmu_notifier_invalidate_range_end(struct mmu_notifier_range *r,
>  				  bool only_end);
>  extern void __mmu_notifier_invalidate_range(struct mm_struct *mm,
>  				  unsigned long start, unsigned long end);
> @@ -268,33 +265,37 @@ static inline void mmu_notifier_change_pte(struct mm_struct *mm,
>  		__mmu_notifier_change_pte(mm, address, pte);
>  }
>  
> -static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end)
> +static inline void
> +mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
>  {
> -	if (mm_has_notifiers(mm))
> -		__mmu_notifier_invalidate_range_start(mm, start, end, true);
> +	if (mm_has_notifiers(range->mm)) {
> +		range->blockable = true;
> +		__mmu_notifier_invalidate_range_start(range);
> +	}
>  }
>  
> -static inline int mmu_notifier_invalidate_range_start_nonblock(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end)
> +static inline int
> +mmu_notifier_invalidate_range_start_nonblock(struct mmu_notifier_range *range)
>  {
> -	if (mm_has_notifiers(mm))
> -		return __mmu_notifier_invalidate_range_start(mm, start, end, false);
> +	if (mm_has_notifiers(range->mm)) {
> +		range->blockable = false;
> +		return __mmu_notifier_invalidate_range_start(range);
> +	}
>  	return 0;
>  }
>  
> -static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end)
> +static inline void
> +mmu_notifier_invalidate_range_end(struct mmu_notifier_range *range)
>  {
> -	if (mm_has_notifiers(mm))
> -		__mmu_notifier_invalidate_range_end(mm, start, end, false);
> +	if (mm_has_notifiers(range->mm))
> +		__mmu_notifier_invalidate_range_end(range, false);
>  }
>  
> -static inline void mmu_notifier_invalidate_range_only_end(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end)
> +static inline void
> +mmu_notifier_invalidate_range_only_end(struct mmu_notifier_range *range)
>  {
> -	if (mm_has_notifiers(mm))
> -		__mmu_notifier_invalidate_range_end(mm, start, end, true);
> +	if (mm_has_notifiers(range->mm))
> +		__mmu_notifier_invalidate_range_end(range, true);
>  }
>  
>  static inline void mmu_notifier_invalidate_range(struct mm_struct *mm,
> @@ -315,6 +316,17 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
>  		__mmu_notifier_mm_destroy(mm);
>  }
>  
> +
> +static inline void mmu_notifier_range_init(struct mmu_notifier_range *range,
> +					   struct mm_struct *mm,
> +					   unsigned long start,
> +					   unsigned long end)
> +{
> +	range->mm = mm;
> +	range->start = start;
> +	range->end = end;
> +}
> +
>  #define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
>  ({									\
>  	int __young;							\
> @@ -428,6 +440,23 @@ extern void mmu_notifier_synchronize(void);
>  
>  #else /* CONFIG_MMU_NOTIFIER */
>  
> +struct mmu_notifier_range {
> +	unsigned long start;
> +	unsigned long end;
> +};
> +
> +static inline void _mmu_notifier_range_init(struct mmu_notifier_range *range,
> +					    unsigned long start,
> +					    unsigned long end)
> +{
> +	range->start = start;
> +	range->end = end;
> +}
> +
> +#define mmu_notifier_range_init(range, mm, start, end) \
> +	_mmu_notifier_range_init(range, start, end)
> +
> +
>  static inline int mm_has_notifiers(struct mm_struct *mm)
>  {
>  	return 0;
> @@ -455,24 +484,24 @@ static inline void mmu_notifier_change_pte(struct mm_struct *mm,
>  {
>  }
>  
> -static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end)
> +static inline void
> +mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
>  {
>  }
>  
> -static inline int mmu_notifier_invalidate_range_start_nonblock(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end)
> +static inline int
> +mmu_notifier_invalidate_range_start_nonblock(struct mmu_notifier_range *range)
>  {
>  	return 0;
>  }
>  
> -static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end)
> +static inline
> +void mmu_notifier_invalidate_range_end(struct mmu_notifier_range *range)
>  {
>  }
>  
> -static inline void mmu_notifier_invalidate_range_only_end(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end)
> +static inline void
> +mmu_notifier_invalidate_range_only_end(struct mmu_notifier_range *range)
>  {
>  }
>  
> diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
> index 322e97bbb437..1fc8a93709c3 100644
> --- a/kernel/events/uprobes.c
> +++ b/kernel/events/uprobes.c
> @@ -171,11 +171,11 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
>  		.address = addr,
>  	};
>  	int err;
> -	/* For mmu_notifiers */
> -	const unsigned long mmun_start = addr;
> -	const unsigned long mmun_end   = addr + PAGE_SIZE;
> +	struct mmu_notifier_range range;
>  	struct mem_cgroup *memcg;
>  
> +	mmu_notifier_range_init(&range, mm, addr, addr + PAGE_SIZE);
> +
>  	VM_BUG_ON_PAGE(PageTransHuge(old_page), old_page);
>  
>  	err = mem_cgroup_try_charge(new_page, vma->vm_mm, GFP_KERNEL, &memcg,
> @@ -186,7 +186,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
>  	/* For try_to_free_swap() and munlock_vma_page() below */
>  	lock_page(old_page);
>  
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_start(&range);
>  	err = -EAGAIN;
>  	if (!page_vma_mapped_walk(&pvmw)) {
>  		mem_cgroup_cancel_charge(new_page, memcg, false);
> @@ -220,7 +220,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
>  
>  	err = 0;
>   unlock:
> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(&range);
>  	unlock_page(old_page);
>  	return err;
>  }
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 622cced74fd9..c1d3ce809416 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1144,8 +1144,7 @@ static vm_fault_t do_huge_pmd_wp_page_fallback(struct vm_fault *vmf,
>  	int i;
>  	vm_fault_t ret = 0;
>  	struct page **pages;
> -	unsigned long mmun_start;	/* For mmu_notifiers */
> -	unsigned long mmun_end;		/* For mmu_notifiers */
> +	struct mmu_notifier_range range;
>  
>  	pages = kmalloc_array(HPAGE_PMD_NR, sizeof(struct page *),
>  			      GFP_KERNEL);
> @@ -1183,9 +1182,9 @@ static vm_fault_t do_huge_pmd_wp_page_fallback(struct vm_fault *vmf,
>  		cond_resched();
>  	}
>  
> -	mmun_start = haddr;
> -	mmun_end   = haddr + HPAGE_PMD_SIZE;
> -	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start, mmun_end);
> +	mmu_notifier_range_init(&range, vma->vm_mm, haddr,
> +				haddr + HPAGE_PMD_SIZE);
> +	mmu_notifier_invalidate_range_start(&range);
>  
>  	vmf->ptl = pmd_lock(vma->vm_mm, vmf->pmd);
>  	if (unlikely(!pmd_same(*vmf->pmd, orig_pmd)))
> @@ -1230,8 +1229,7 @@ static vm_fault_t do_huge_pmd_wp_page_fallback(struct vm_fault *vmf,
>  	 * No need to double call mmu_notifier->invalidate_range() callback as
>  	 * the above pmdp_huge_clear_flush_notify() did already call it.
>  	 */
> -	mmu_notifier_invalidate_range_only_end(vma->vm_mm, mmun_start,
> -						mmun_end);
> +	mmu_notifier_invalidate_range_only_end(&range);
>  
>  	ret |= VM_FAULT_WRITE;
>  	put_page(page);
> @@ -1241,7 +1239,7 @@ static vm_fault_t do_huge_pmd_wp_page_fallback(struct vm_fault *vmf,
>  
>  out_free_pages:
>  	spin_unlock(vmf->ptl);
> -	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(&range);
>  	for (i = 0; i < HPAGE_PMD_NR; i++) {
>  		memcg = (void *)page_private(pages[i]);
>  		set_page_private(pages[i], 0);
> @@ -1258,8 +1256,7 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
>  	struct page *page = NULL, *new_page;
>  	struct mem_cgroup *memcg;
>  	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
> -	unsigned long mmun_start;	/* For mmu_notifiers */
> -	unsigned long mmun_end;		/* For mmu_notifiers */
> +	struct mmu_notifier_range range;
>  	gfp_t huge_gfp;			/* for allocation and charge */
>  	vm_fault_t ret = 0;
>  
> @@ -1349,9 +1346,9 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
>  				    vma, HPAGE_PMD_NR);
>  	__SetPageUptodate(new_page);
>  
> -	mmun_start = haddr;
> -	mmun_end   = haddr + HPAGE_PMD_SIZE;
> -	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start, mmun_end);
> +	mmu_notifier_range_init(&range, vma->vm_mm, haddr,
> +				haddr + HPAGE_PMD_SIZE);
> +	mmu_notifier_invalidate_range_start(&range);
>  
>  	spin_lock(vmf->ptl);
>  	if (page)
> @@ -1386,8 +1383,7 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
>  	 * No need to double call mmu_notifier->invalidate_range() callback as
>  	 * the above pmdp_huge_clear_flush_notify() did already call it.
>  	 */
> -	mmu_notifier_invalidate_range_only_end(vma->vm_mm, mmun_start,
> -					       mmun_end);
> +	mmu_notifier_invalidate_range_only_end(&range);
>  out:
>  	return ret;
>  out_unlock:
> @@ -2028,14 +2024,15 @@ void __split_huge_pud(struct vm_area_struct *vma, pud_t *pud,
>  		unsigned long address)
>  {
>  	spinlock_t *ptl;
> -	struct mm_struct *mm = vma->vm_mm;
> -	unsigned long haddr = address & HPAGE_PUD_MASK;
> +	struct mmu_notifier_range range;
>  
> -	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PUD_SIZE);
> -	ptl = pud_lock(mm, pud);
> +	mmu_notifier_range_init(&range, vma->vm_mm, address & HPAGE_PUD_MASK,
> +				(address & HPAGE_PUD_MASK) + HPAGE_PUD_SIZE);
> +	mmu_notifier_invalidate_range_start(&range);
> +	ptl = pud_lock(vma->vm_mm, pud);
>  	if (unlikely(!pud_trans_huge(*pud) && !pud_devmap(*pud)))
>  		goto out;
> -	__split_huge_pud_locked(vma, pud, haddr);
> +	__split_huge_pud_locked(vma, pud, range.start);
>  
>  out:
>  	spin_unlock(ptl);
> @@ -2043,8 +2040,7 @@ void __split_huge_pud(struct vm_area_struct *vma, pud_t *pud,
>  	 * No need to double call mmu_notifier->invalidate_range() callback as
>  	 * the above pudp_huge_clear_flush_notify() did already call it.
>  	 */
> -	mmu_notifier_invalidate_range_only_end(mm, haddr, haddr +
> -					       HPAGE_PUD_SIZE);
> +	mmu_notifier_invalidate_range_only_end(&range);
>  }
>  #endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
>  
> @@ -2244,11 +2240,12 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  		unsigned long address, bool freeze, struct page *page)
>  {
>  	spinlock_t *ptl;
> -	struct mm_struct *mm = vma->vm_mm;
> -	unsigned long haddr = address & HPAGE_PMD_MASK;
> +	struct mmu_notifier_range range;
>  
> -	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
> -	ptl = pmd_lock(mm, pmd);
> +	mmu_notifier_range_init(&range, vma->vm_mm, address & HPAGE_PMD_MASK,
> +				(address & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE);
> +	mmu_notifier_invalidate_range_start(&range);
> +	ptl = pmd_lock(vma->vm_mm, pmd);
>  
>  	/*
>  	 * If caller asks to setup a migration entries, we need a page to check
> @@ -2264,7 +2261,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  			clear_page_mlock(page);
>  	} else if (!(pmd_devmap(*pmd) || is_pmd_migration_entry(*pmd)))
>  		goto out;
> -	__split_huge_pmd_locked(vma, pmd, haddr, freeze);
> +	__split_huge_pmd_locked(vma, pmd, range.start, freeze);
>  out:
>  	spin_unlock(ptl);
>  	/*
> @@ -2280,8 +2277,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  	 *     any further changes to individual pte will notify. So no need
>  	 *     to call mmu_notifier->invalidate_range()
>  	 */
> -	mmu_notifier_invalidate_range_only_end(mm, haddr, haddr +
> -					       HPAGE_PMD_SIZE);
> +	mmu_notifier_invalidate_range_only_end(&range);
>  }
>  
>  void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 705a3e9cc910..e7c179cbcd75 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3239,16 +3239,16 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
>  	int cow;
>  	struct hstate *h = hstate_vma(vma);
>  	unsigned long sz = huge_page_size(h);
> -	unsigned long mmun_start;	/* For mmu_notifiers */
> -	unsigned long mmun_end;		/* For mmu_notifiers */
> +	struct mmu_notifier_range range;
>  	int ret = 0;
>  
>  	cow = (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
>  
> -	mmun_start = vma->vm_start;
> -	mmun_end = vma->vm_end;
> -	if (cow)
> -		mmu_notifier_invalidate_range_start(src, mmun_start, mmun_end);
> +	if (cow) {
> +		mmu_notifier_range_init(&range, src, vma->vm_start,
> +					vma->vm_end);
> +		mmu_notifier_invalidate_range_start(&range);
> +	}
>  
>  	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
>  		spinlock_t *src_ptl, *dst_ptl;
> @@ -3324,7 +3324,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
>  	}
>  
>  	if (cow)
> -		mmu_notifier_invalidate_range_end(src, mmun_start, mmun_end);
> +		mmu_notifier_invalidate_range_end(&range);
>  
>  	return ret;
>  }
> @@ -3341,8 +3341,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  	struct page *page;
>  	struct hstate *h = hstate_vma(vma);
>  	unsigned long sz = huge_page_size(h);
> -	unsigned long mmun_start = start;	/* For mmu_notifiers */
> -	unsigned long mmun_end   = end;		/* For mmu_notifiers */
> +	struct mmu_notifier_range range;
>  
>  	WARN_ON(!is_vm_hugetlb_page(vma));
>  	BUG_ON(start & ~huge_page_mask(h));
> @@ -3358,8 +3357,9 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  	/*
>  	 * If sharing possible, alert mmu notifiers of worst case.
>  	 */
> -	adjust_range_if_pmd_sharing_possible(vma, &mmun_start, &mmun_end);
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> +	mmu_notifier_range_init(&range, mm, start, end);
> +	adjust_range_if_pmd_sharing_possible(vma, &range.start, &range.end);
> +	mmu_notifier_invalidate_range_start(&range);
>  	address = start;
>  	for (; address < end; address += sz) {
>  		ptep = huge_pte_offset(mm, address, sz);
> @@ -3427,7 +3427,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  		if (ref_page)
>  			break;
>  	}
> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(&range);
>  	tlb_end_vma(tlb, vma);
>  }
>  
> @@ -3545,9 +3545,8 @@ static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>  	struct page *old_page, *new_page;
>  	int outside_reserve = 0;
>  	vm_fault_t ret = 0;
> -	unsigned long mmun_start;	/* For mmu_notifiers */
> -	unsigned long mmun_end;		/* For mmu_notifiers */
>  	unsigned long haddr = address & huge_page_mask(h);
> +	struct mmu_notifier_range range;
>  
>  	pte = huge_ptep_get(ptep);
>  	old_page = pte_page(pte);
> @@ -3626,9 +3625,8 @@ static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>  	__SetPageUptodate(new_page);
>  	set_page_huge_active(new_page);
>  
> -	mmun_start = haddr;
> -	mmun_end = mmun_start + huge_page_size(h);
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> +	mmu_notifier_range_init(&range, mm, haddr, haddr + huge_page_size(h));
> +	mmu_notifier_invalidate_range_start(&range);
>  
>  	/*
>  	 * Retake the page table lock to check for racing updates
> @@ -3641,7 +3639,7 @@ static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>  
>  		/* Break COW */
>  		huge_ptep_clear_flush(vma, haddr, ptep);
> -		mmu_notifier_invalidate_range(mm, mmun_start, mmun_end);
> +		mmu_notifier_invalidate_range(mm, range.start, range.end);
>  		set_huge_pte_at(mm, haddr, ptep,
>  				make_huge_pte(vma, new_page, 1));
>  		page_remove_rmap(old_page, true);
> @@ -3650,7 +3648,7 @@ static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>  		new_page = old_page;
>  	}
>  	spin_unlock(ptl);
> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(&range);
>  out_release_all:
>  	restore_reserve_on_error(h, vma, haddr, new_page);
>  	put_page(new_page);
> @@ -4339,21 +4337,21 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>  	pte_t pte;
>  	struct hstate *h = hstate_vma(vma);
>  	unsigned long pages = 0;
> -	unsigned long f_start = start;
> -	unsigned long f_end = end;
>  	bool shared_pmd = false;
> +	struct mmu_notifier_range range;
>  
>  	/*
>  	 * In the case of shared PMDs, the area to flush could be beyond
> -	 * start/end.  Set f_start/f_end to cover the maximum possible
> +	 * start/end.  Set range.start/range.end to cover the maximum possible
>  	 * range if PMD sharing is possible.
>  	 */
> -	adjust_range_if_pmd_sharing_possible(vma, &f_start, &f_end);
> +	mmu_notifier_range_init(&range, mm, start, end);
> +	adjust_range_if_pmd_sharing_possible(vma, &range.start, &range.end);
>  
>  	BUG_ON(address >= end);
> -	flush_cache_range(vma, f_start, f_end);
> +	flush_cache_range(vma, range.start, range.end);
>  
> -	mmu_notifier_invalidate_range_start(mm, f_start, f_end);
> +	mmu_notifier_invalidate_range_start(&range);
>  	i_mmap_lock_write(vma->vm_file->f_mapping);
>  	for (; address < end; address += huge_page_size(h)) {
>  		spinlock_t *ptl;
> @@ -4404,7 +4402,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>  	 * did unshare a page of pmds, flush the range corresponding to the pud.
>  	 */
>  	if (shared_pmd)
> -		flush_hugetlb_tlb_range(vma, f_start, f_end);
> +		flush_hugetlb_tlb_range(vma, range.start, range.end);
>  	else
>  		flush_hugetlb_tlb_range(vma, start, end);
>  	/*
> @@ -4414,7 +4412,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>  	 * See Documentation/vm/mmu_notifier.rst
>  	 */
>  	i_mmap_unlock_write(vma->vm_file->f_mapping);
> -	mmu_notifier_invalidate_range_end(mm, f_start, f_end);
> +	mmu_notifier_invalidate_range_end(&range);
>  
>  	return pages << h->order;
>  }
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 8e2ff195ecb3..7736f6c37f19 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -944,8 +944,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	int isolated = 0, result = 0;
>  	struct mem_cgroup *memcg;
>  	struct vm_area_struct *vma;
> -	unsigned long mmun_start;	/* For mmu_notifiers */
> -	unsigned long mmun_end;		/* For mmu_notifiers */
> +	struct mmu_notifier_range range;
>  	gfp_t gfp;
>  
>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> @@ -1017,9 +1016,8 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	pte = pte_offset_map(pmd, address);
>  	pte_ptl = pte_lockptr(mm, pmd);
>  
> -	mmun_start = address;
> -	mmun_end   = address + HPAGE_PMD_SIZE;
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> +	mmu_notifier_range_init(&range, mm, address, address + HPAGE_PMD_SIZE);
> +	mmu_notifier_invalidate_range_start(&range);
>  	pmd_ptl = pmd_lock(mm, pmd); /* probably unnecessary */
>  	/*
>  	 * After this gup_fast can't run anymore. This also removes
> @@ -1029,7 +1027,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	 */
>  	_pmd = pmdp_collapse_flush(vma, address, pmd);
>  	spin_unlock(pmd_ptl);
> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(&range);
>  
>  	spin_lock(pte_ptl);
>  	isolated = __collapse_huge_page_isolate(vma, address, pte);
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 5b0894b45ee5..6239d2df7a8e 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1042,8 +1042,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
>  	};
>  	int swapped;
>  	int err = -EFAULT;
> -	unsigned long mmun_start;	/* For mmu_notifiers */
> -	unsigned long mmun_end;		/* For mmu_notifiers */
> +	struct mmu_notifier_range range;
>  
>  	pvmw.address = page_address_in_vma(page, vma);
>  	if (pvmw.address == -EFAULT)
> @@ -1051,9 +1050,9 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
>  
>  	BUG_ON(PageTransCompound(page));
>  
> -	mmun_start = pvmw.address;
> -	mmun_end   = pvmw.address + PAGE_SIZE;
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> +	mmu_notifier_range_init(&range, mm, pvmw.address,
> +				pvmw.address + PAGE_SIZE);
> +	mmu_notifier_invalidate_range_start(&range);
>  
>  	if (!page_vma_mapped_walk(&pvmw))
>  		goto out_mn;
> @@ -1105,7 +1104,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
>  out_unlock:
>  	page_vma_mapped_walk_done(&pvmw);
>  out_mn:
> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(&range);
>  out:
>  	return err;
>  }
> @@ -1129,8 +1128,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
>  	spinlock_t *ptl;
>  	unsigned long addr;
>  	int err = -EFAULT;
> -	unsigned long mmun_start;	/* For mmu_notifiers */
> -	unsigned long mmun_end;		/* For mmu_notifiers */
> +	struct mmu_notifier_range range;
>  
>  	addr = page_address_in_vma(page, vma);
>  	if (addr == -EFAULT)
> @@ -1140,9 +1138,8 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
>  	if (!pmd)
>  		goto out;
>  
> -	mmun_start = addr;
> -	mmun_end   = addr + PAGE_SIZE;
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> +	mmu_notifier_range_init(&range, mm, addr, addr + PAGE_SIZE);
> +	mmu_notifier_invalidate_range_start(&range);
>  
>  	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
>  	if (!pte_same(*ptep, orig_pte)) {
> @@ -1188,7 +1185,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
>  	pte_unmap_unlock(ptep, ptl);
>  	err = 0;
>  out_mn:
> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(&range);
>  out:
>  	return err;
>  }
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 6cb1ca93e290..21a7881a2db4 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -458,29 +458,30 @@ static void madvise_free_page_range(struct mmu_gather *tlb,
>  static int madvise_free_single_vma(struct vm_area_struct *vma,
>  			unsigned long start_addr, unsigned long end_addr)
>  {
> -	unsigned long start, end;
>  	struct mm_struct *mm = vma->vm_mm;
> +	struct mmu_notifier_range range;
>  	struct mmu_gather tlb;
>  
>  	/* MADV_FREE works for only anon vma at the moment */
>  	if (!vma_is_anonymous(vma))
>  		return -EINVAL;
>  
> -	start = max(vma->vm_start, start_addr);
> -	if (start >= vma->vm_end)
> +	range.start = max(vma->vm_start, start_addr);
> +	if (range.start >= vma->vm_end)
>  		return -EINVAL;
> -	end = min(vma->vm_end, end_addr);
> -	if (end <= vma->vm_start)
> +	range.end = min(vma->vm_end, end_addr);
> +	if (range.end <= vma->vm_start)
>  		return -EINVAL;
> +	mmu_notifier_range_init(&range, mm, range.start, range.end);
>  
>  	lru_add_drain();
> -	tlb_gather_mmu(&tlb, mm, start, end);
> +	tlb_gather_mmu(&tlb, mm, range.start, range.end);
>  	update_hiwater_rss(mm);
>  
> -	mmu_notifier_invalidate_range_start(mm, start, end);
> -	madvise_free_page_range(&tlb, vma, start, end);
> -	mmu_notifier_invalidate_range_end(mm, start, end);
> -	tlb_finish_mmu(&tlb, start, end);
> +	mmu_notifier_invalidate_range_start(&range);
> +	madvise_free_page_range(&tlb, vma, range.start, range.end);
> +	mmu_notifier_invalidate_range_end(&range);
> +	tlb_finish_mmu(&tlb, range.start, range.end);
>  
>  	return 0;
>  }
> diff --git a/mm/memory.c b/mm/memory.c
> index 4ad2d293ddc2..574307f11464 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -973,8 +973,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  	unsigned long next;
>  	unsigned long addr = vma->vm_start;
>  	unsigned long end = vma->vm_end;
> -	unsigned long mmun_start;	/* For mmu_notifiers */
> -	unsigned long mmun_end;		/* For mmu_notifiers */
> +	struct mmu_notifier_range range;
>  	bool is_cow;
>  	int ret;
>  
> @@ -1008,11 +1007,11 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  	 * is_cow_mapping() returns true.
>  	 */
>  	is_cow = is_cow_mapping(vma->vm_flags);
> -	mmun_start = addr;
> -	mmun_end   = end;
> -	if (is_cow)
> -		mmu_notifier_invalidate_range_start(src_mm, mmun_start,
> -						    mmun_end);
> +
> +	if (is_cow) {
> +		mmu_notifier_range_init(&range, src_mm, addr, end);
> +		mmu_notifier_invalidate_range_start(&range);
> +	}
>  
>  	ret = 0;
>  	dst_pgd = pgd_offset(dst_mm, addr);
> @@ -1029,7 +1028,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
>  
>  	if (is_cow)
> -		mmu_notifier_invalidate_range_end(src_mm, mmun_start, mmun_end);
> +		mmu_notifier_invalidate_range_end(&range);
>  	return ret;
>  }
>  
> @@ -1332,12 +1331,13 @@ void unmap_vmas(struct mmu_gather *tlb,
>  		struct vm_area_struct *vma, unsigned long start_addr,
>  		unsigned long end_addr)
>  {
> -	struct mm_struct *mm = vma->vm_mm;
> +	struct mmu_notifier_range range;
>  
> -	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
> +	mmu_notifier_range_init(&range, vma->vm_mm, start_addr, end_addr);
> +	mmu_notifier_invalidate_range_start(&range);
>  	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next)
>  		unmap_single_vma(tlb, vma, start_addr, end_addr, NULL);
> -	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
> +	mmu_notifier_invalidate_range_end(&range);
>  }
>  
>  /**
> @@ -1351,18 +1351,18 @@ void unmap_vmas(struct mmu_gather *tlb,
>  void zap_page_range(struct vm_area_struct *vma, unsigned long start,
>  		unsigned long size)
>  {
> -	struct mm_struct *mm = vma->vm_mm;
> +	struct mmu_notifier_range range;
>  	struct mmu_gather tlb;
> -	unsigned long end = start + size;
>  
>  	lru_add_drain();
> -	tlb_gather_mmu(&tlb, mm, start, end);
> -	update_hiwater_rss(mm);
> -	mmu_notifier_invalidate_range_start(mm, start, end);
> -	for ( ; vma && vma->vm_start < end; vma = vma->vm_next)
> -		unmap_single_vma(&tlb, vma, start, end, NULL);
> -	mmu_notifier_invalidate_range_end(mm, start, end);
> -	tlb_finish_mmu(&tlb, start, end);
> +	mmu_notifier_range_init(&range, vma->vm_mm, start, start + size);
> +	tlb_gather_mmu(&tlb, vma->vm_mm, start, range.end);
> +	update_hiwater_rss(vma->vm_mm);
> +	mmu_notifier_invalidate_range_start(&range);
> +	for ( ; vma && vma->vm_start < range.end; vma = vma->vm_next)
> +		unmap_single_vma(&tlb, vma, start, range.end, NULL);
> +	mmu_notifier_invalidate_range_end(&range);
> +	tlb_finish_mmu(&tlb, start, range.end);
>  }
>  
>  /**
> @@ -1377,17 +1377,17 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
>  static void zap_page_range_single(struct vm_area_struct *vma, unsigned long address,
>  		unsigned long size, struct zap_details *details)
>  {
> -	struct mm_struct *mm = vma->vm_mm;
> +	struct mmu_notifier_range range;
>  	struct mmu_gather tlb;
> -	unsigned long end = address + size;
>  
>  	lru_add_drain();
> -	tlb_gather_mmu(&tlb, mm, address, end);
> -	update_hiwater_rss(mm);
> -	mmu_notifier_invalidate_range_start(mm, address, end);
> -	unmap_single_vma(&tlb, vma, address, end, details);
> -	mmu_notifier_invalidate_range_end(mm, address, end);
> -	tlb_finish_mmu(&tlb, address, end);
> +	mmu_notifier_range_init(&range, vma->vm_mm, address, address + size);
> +	tlb_gather_mmu(&tlb, vma->vm_mm, address, range.end);
> +	update_hiwater_rss(vma->vm_mm);
> +	mmu_notifier_invalidate_range_start(&range);
> +	unmap_single_vma(&tlb, vma, address, range.end, details);
> +	mmu_notifier_invalidate_range_end(&range);
> +	tlb_finish_mmu(&tlb, address, range.end);
>  }
>  
>  /**
> @@ -2247,9 +2247,8 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
>  	struct page *new_page = NULL;
>  	pte_t entry;
>  	int page_copied = 0;
> -	const unsigned long mmun_start = vmf->address & PAGE_MASK;
> -	const unsigned long mmun_end = mmun_start + PAGE_SIZE;
>  	struct mem_cgroup *memcg;
> +	struct mmu_notifier_range range;
>  
>  	if (unlikely(anon_vma_prepare(vma)))
>  		goto oom;
> @@ -2272,7 +2271,9 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
>  
>  	__SetPageUptodate(new_page);
>  
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> +	mmu_notifier_range_init(&range, mm, vmf->address & PAGE_MASK,
> +				(vmf->address & PAGE_MASK) + PAGE_SIZE);
> +	mmu_notifier_invalidate_range_start(&range);
>  
>  	/*
>  	 * Re-check the pte - we dropped the lock
> @@ -2349,7 +2350,7 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
>  	 * No need to double call mmu_notifier->invalidate_range() callback as
>  	 * the above ptep_clear_flush_notify() did already call it.
>  	 */
> -	mmu_notifier_invalidate_range_only_end(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_only_end(&range);
>  	if (old_page) {
>  		/*
>  		 * Don't let another task, with possibly unlocked vma,
> @@ -4030,7 +4031,7 @@ int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
>  #endif /* __PAGETABLE_PMD_FOLDED */
>  
>  static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
> -			    unsigned long *start, unsigned long *end,
> +			    struct mmu_notifier_range *range,
>  			    pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp)
>  {
>  	pgd_t *pgd;
> @@ -4058,10 +4059,10 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
>  		if (!pmdpp)
>  			goto out;
>  
> -		if (start && end) {
> -			*start = address & PMD_MASK;
> -			*end = *start + PMD_SIZE;
> -			mmu_notifier_invalidate_range_start(mm, *start, *end);
> +		if (range) {
> +			mmu_notifier_range_init(range, mm, address & PMD_MASK,
> +					     (address & PMD_MASK) + PMD_SIZE);
> +			mmu_notifier_invalidate_range_start(range);
>  		}
>  		*ptlp = pmd_lock(mm, pmd);
>  		if (pmd_huge(*pmd)) {
> @@ -4069,17 +4070,17 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
>  			return 0;
>  		}
>  		spin_unlock(*ptlp);
> -		if (start && end)
> -			mmu_notifier_invalidate_range_end(mm, *start, *end);
> +		if (range)
> +			mmu_notifier_invalidate_range_end(range);
>  	}
>  
>  	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
>  		goto out;
>  
> -	if (start && end) {
> -		*start = address & PAGE_MASK;
> -		*end = *start + PAGE_SIZE;
> -		mmu_notifier_invalidate_range_start(mm, *start, *end);
> +	if (range) {
> +		range->start = address & PAGE_MASK;
> +		range->end = range->start + PAGE_SIZE;
> +		mmu_notifier_invalidate_range_start(range);
>  	}
>  	ptep = pte_offset_map_lock(mm, pmd, address, ptlp);
>  	if (!pte_present(*ptep))
> @@ -4088,8 +4089,8 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
>  	return 0;
>  unlock:
>  	pte_unmap_unlock(ptep, *ptlp);
> -	if (start && end)
> -		mmu_notifier_invalidate_range_end(mm, *start, *end);
> +	if (range)
> +		mmu_notifier_invalidate_range_end(range);
>  out:
>  	return -EINVAL;
>  }
> @@ -4101,20 +4102,20 @@ static inline int follow_pte(struct mm_struct *mm, unsigned long address,
>  
>  	/* (void) is needed to make gcc happy */
>  	(void) __cond_lock(*ptlp,
> -			   !(res = __follow_pte_pmd(mm, address, NULL, NULL,
> +			   !(res = __follow_pte_pmd(mm, address, NULL,
>  						    ptepp, NULL, ptlp)));
>  	return res;
>  }
>  
>  int follow_pte_pmd(struct mm_struct *mm, unsigned long address,
> -			     unsigned long *start, unsigned long *end,
> +		 	     struct mmu_notifier_range *range,
>  			     pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp)
>  {
>  	int res;
>  
>  	/* (void) is needed to make gcc happy */
>  	(void) __cond_lock(*ptlp,
> -			   !(res = __follow_pte_pmd(mm, address, start, end,
> +			   !(res = __follow_pte_pmd(mm, address, range,
>  						    ptepp, pmdpp, ptlp)));
>  	return res;
>  }
> diff --git a/mm/migrate.c b/mm/migrate.c
> index f7e4bfdc13b7..74f5b3208c05 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -2303,6 +2303,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>   */
>  static void migrate_vma_collect(struct migrate_vma *migrate)
>  {
> +	struct mmu_notifier_range range;
>  	struct mm_walk mm_walk;
>  
>  	mm_walk.pmd_entry = migrate_vma_collect_pmd;
> @@ -2314,13 +2315,11 @@ static void migrate_vma_collect(struct migrate_vma *migrate)
>  	mm_walk.mm = migrate->vma->vm_mm;
>  	mm_walk.private = migrate;
>  
> -	mmu_notifier_invalidate_range_start(mm_walk.mm,
> -					    migrate->start,
> -					    migrate->end);
> +	mmu_notifier_range_init(&range, mm_walk.mm, migrate->start,
> +				migrate->end);
> +	mmu_notifier_invalidate_range_start(&range);
>  	walk_page_range(migrate->start, migrate->end, &mm_walk);
> -	mmu_notifier_invalidate_range_end(mm_walk.mm,
> -					  migrate->start,
> -					  migrate->end);
> +	mmu_notifier_invalidate_range_end(&range);
>  
>  	migrate->end = migrate->start + (migrate->npages << PAGE_SHIFT);
>  }
> @@ -2703,7 +2702,8 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
>  	const unsigned long start = migrate->start;
>  	struct vm_area_struct *vma = migrate->vma;
>  	struct mm_struct *mm = vma->vm_mm;
> -	unsigned long addr, i, mmu_start;
> +	struct mmu_notifier_range range;
> +	unsigned long addr, i;
>  	bool notified = false;
>  
>  	for (i = 0, addr = start; i < npages; addr += PAGE_SIZE, i++) {
> @@ -2722,11 +2722,11 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
>  				continue;
>  			}
>  			if (!notified) {
> -				mmu_start = addr;
>  				notified = true;
> -				mmu_notifier_invalidate_range_start(mm,
> -								mmu_start,
> -								migrate->end);
> +
> +				mmu_notifier_range_init(&range, mm, addr,
> +							migrate->end);
> +				mmu_notifier_invalidate_range_start(&range);
>  			}
>  			migrate_vma_insert_page(migrate, addr, newpage,
>  						&migrate->src[i],
> @@ -2767,8 +2767,7 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
>  	 * did already call it.
>  	 */
>  	if (notified)
> -		mmu_notifier_invalidate_range_only_end(mm, mmu_start,
> -						       migrate->end);
> +		mmu_notifier_invalidate_range_only_end(&range);
>  }
>  
>  /*
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> index 5f6665ae3ee2..4c52b3514c50 100644
> --- a/mm/mmu_notifier.c
> +++ b/mm/mmu_notifier.c
> @@ -174,28 +174,20 @@ void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
>  	srcu_read_unlock(&srcu, id);
>  }
>  
> -int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end,
> -				  bool blockable)
> +int __mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
>  {
> -	struct mmu_notifier_range _range, *range = &_range;
>  	struct mmu_notifier *mn;
>  	int ret = 0;
>  	int id;
>  
> -	range->blockable = blockable;
> -	range->start = start;
> -	range->end = end;
> -	range->mm = mm;
> -
>  	id = srcu_read_lock(&srcu);
> -	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
> +	hlist_for_each_entry_rcu(mn, &range->mm->mmu_notifier_mm->list, hlist) {
>  		if (mn->ops->invalidate_range_start) {
>  			int _ret = mn->ops->invalidate_range_start(mn, range);
>  			if (_ret) {
>  				pr_info("%pS callback failed with %d in %sblockable context.\n",
>  						mn->ops->invalidate_range_start, _ret,
> -						!blockable ? "non-" : "");
> +						!range->blockable ? "non-" : "");
>  				ret = _ret;
>  			}
>  		}
> @@ -206,27 +198,14 @@ int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
>  }
>  EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start);
>  
> -void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
> -					 unsigned long start,
> -					 unsigned long end,
> +void __mmu_notifier_invalidate_range_end(struct mmu_notifier_range *range,
>  					 bool only_end)
>  {
> -	struct mmu_notifier_range _range, *range = &_range;
>  	struct mmu_notifier *mn;
>  	int id;
>  
> -	/*
> -	 * The end call back will never be call if the start refused to go
> -	 * through because of blockable was false so here assume that we
> -	 * can block.
> -	 */
> -	range->blockable = true;
> -	range->start = start;
> -	range->end = end;
> -	range->mm = mm;
> -
>  	id = srcu_read_lock(&srcu);
> -	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
> +	hlist_for_each_entry_rcu(mn, &range->mm->mmu_notifier_mm->list, hlist) {
>  		/*
>  		 * Call invalidate_range here too to avoid the need for the
>  		 * subsystem of having to register an invalidate_range_end
> @@ -241,7 +220,9 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
>  		 * already happen under page table lock.
>  		 */
>  		if (!only_end && mn->ops->invalidate_range)
> -			mn->ops->invalidate_range(mn, mm, start, end);
> +			mn->ops->invalidate_range(mn, range->mm,
> +						  range->start,
> +						  range->end);
>  		if (mn->ops->invalidate_range_end)
>  			mn->ops->invalidate_range_end(mn, range);
>  	}
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 6d331620b9e5..36cb358db170 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -167,11 +167,12 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>  		pgprot_t newprot, int dirty_accountable, int prot_numa)
>  {
>  	pmd_t *pmd;
> -	struct mm_struct *mm = vma->vm_mm;
>  	unsigned long next;
>  	unsigned long pages = 0;
>  	unsigned long nr_huge_updates = 0;
> -	unsigned long mni_start = 0;
> +	struct mmu_notifier_range range;
> +
> +	range.start = 0;
>  
>  	pmd = pmd_offset(pud, addr);
>  	do {
> @@ -183,9 +184,9 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>  			goto next;
>  
>  		/* invoke the mmu notifier if the pmd is populated */
> -		if (!mni_start) {
> -			mni_start = addr;
> -			mmu_notifier_invalidate_range_start(mm, mni_start, end);
> +		if (!range.start) {
> +			mmu_notifier_range_init(&range, vma->vm_mm, addr, end);
> +			mmu_notifier_invalidate_range_start(&range);
>  		}
>  
>  		if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
> @@ -214,8 +215,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>  		cond_resched();
>  	} while (pmd++, addr = next, addr != end);
>  
> -	if (mni_start)
> -		mmu_notifier_invalidate_range_end(mm, mni_start, end);
> +	if (range.start)
> +		mmu_notifier_invalidate_range_end(&range);
>  
>  	if (nr_huge_updates)
>  		count_vm_numa_events(NUMA_HUGE_PTE_UPDATES, nr_huge_updates);
> diff --git a/mm/mremap.c b/mm/mremap.c
> index 7f9f9180e401..def01d86e36f 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -197,16 +197,14 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
>  		bool need_rmap_locks)
>  {
>  	unsigned long extent, next, old_end;
> +	struct mmu_notifier_range range;
>  	pmd_t *old_pmd, *new_pmd;
> -	unsigned long mmun_start;	/* For mmu_notifiers */
> -	unsigned long mmun_end;		/* For mmu_notifiers */
>  
>  	old_end = old_addr + len;
>  	flush_cache_range(vma, old_addr, old_end);
>  
> -	mmun_start = old_addr;
> -	mmun_end   = old_end;
> -	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start, mmun_end);
> +	mmu_notifier_range_init(&range, vma->vm_mm, old_addr, old_end);
> +	mmu_notifier_invalidate_range_start(&range);
>  
>  	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
>  		cond_resched();
> @@ -247,7 +245,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
>  			  new_pmd, new_addr, need_rmap_locks);
>  	}
>  
> -	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(&range);
>  
>  	return len + old_addr - old_end;	/* how much done */
>  }
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 6589f60d5018..1eea8b04f27a 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -516,19 +516,20 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
>  		 * count elevated without a good reason.
>  		 */
>  		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED)) {
> -			const unsigned long start = vma->vm_start;
> -			const unsigned long end = vma->vm_end;
> +			struct mmu_notifier_range range;
>  			struct mmu_gather tlb;
>  
> -			tlb_gather_mmu(&tlb, mm, start, end);
> -			if (mmu_notifier_invalidate_range_start_nonblock(mm, start, end)) {
> -				tlb_finish_mmu(&tlb, start, end);
> +			mmu_notifier_range_init(&range, mm, vma->vm_start,
> +						vma->vm_end);
> +			tlb_gather_mmu(&tlb, mm, range.start, range.end);
> +			if (mmu_notifier_invalidate_range_start_nonblock(&range)) {
> +				tlb_finish_mmu(&tlb, range.start, range.end);
>  				ret = false;
>  				continue;
>  			}
> -			unmap_page_range(&tlb, vma, start, end, NULL);
> -			mmu_notifier_invalidate_range_end(mm, start, end);
> -			tlb_finish_mmu(&tlb, start, end);
> +			unmap_page_range(&tlb, vma, range.start, range.end, NULL);
> +			mmu_notifier_invalidate_range_end(&range);
> +			tlb_finish_mmu(&tlb, range.start, range.end);
>  		}
>  	}
>  
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 85b7f9423352..c75f72f6fe0e 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -889,15 +889,17 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
>  		.address = address,
>  		.flags = PVMW_SYNC,
>  	};
> -	unsigned long start = address, end;
> +	struct mmu_notifier_range range;
>  	int *cleaned = arg;
>  
>  	/*
>  	 * We have to assume the worse case ie pmd for invalidation. Note that
>  	 * the page can not be free from this function.
>  	 */
> -	end = min(vma->vm_end, start + (PAGE_SIZE << compound_order(page)));
> -	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
> +	mmu_notifier_range_init(&range, vma->vm_mm, address,
> +				min(vma->vm_end, address +
> +				    (PAGE_SIZE << compound_order(page))));
> +	mmu_notifier_invalidate_range_start(&range);
>  
>  	while (page_vma_mapped_walk(&pvmw)) {
>  		unsigned long cstart;
> @@ -949,7 +951,7 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
>  			(*cleaned)++;
>  	}
>  
> -	mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
> +	mmu_notifier_invalidate_range_end(&range);
>  
>  	return true;
>  }
> @@ -1345,7 +1347,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  	pte_t pteval;
>  	struct page *subpage;
>  	bool ret = true;
> -	unsigned long start = address, end;
> +	struct mmu_notifier_range range;
>  	enum ttu_flags flags = (enum ttu_flags)arg;
>  
>  	/* munlock has nothing to gain from examining un-locked vmas */
> @@ -1369,15 +1371,18 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  	 * Note that the page can not be free in this function as call of
>  	 * try_to_unmap() must hold a reference on the page.
>  	 */
> -	end = min(vma->vm_end, start + (PAGE_SIZE << compound_order(page)));
> +	mmu_notifier_range_init(&range, vma->vm_mm, vma->vm_start,
> +				min(vma->vm_end, vma->vm_start +
> +				    (PAGE_SIZE << compound_order(page))));
>  	if (PageHuge(page)) {
>  		/*
>  		 * If sharing is possible, start and end will be adjusted
>  		 * accordingly.
>  		 */
> -		adjust_range_if_pmd_sharing_possible(vma, &start, &end);
> +		adjust_range_if_pmd_sharing_possible(vma, &range.start,
> +						     &range.end);
>  	}
> -	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
> +	mmu_notifier_invalidate_range_start(&range);
>  
>  	while (page_vma_mapped_walk(&pvmw)) {
>  #ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> @@ -1428,9 +1433,10 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  				 * we must flush them all.  start/end were
>  				 * already adjusted above to cover this range.
>  				 */
> -				flush_cache_range(vma, start, end);
> -				flush_tlb_range(vma, start, end);
> -				mmu_notifier_invalidate_range(mm, start, end);
> +				flush_cache_range(vma, range.start, range.end);
> +				flush_tlb_range(vma, range.start, range.end);
> +				mmu_notifier_invalidate_range(mm, range.start,
> +							      range.end);
>  
>  				/*
>  				 * The ref count of the PMD page was dropped
> @@ -1650,7 +1656,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  		put_page(page);
>  	}
>  
> -	mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
> +	mmu_notifier_invalidate_range_end(&range);
>  
>  	return ret;
>  }
> -- 
> 2.17.2
> 
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
