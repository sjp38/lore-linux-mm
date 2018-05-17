Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1F5FA6B0524
	for <linux-mm@kvack.org>; Thu, 17 May 2018 13:57:05 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j33-v6so4491608qtc.18
        for <linux-mm@kvack.org>; Thu, 17 May 2018 10:57:05 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id w28-v6si4420145qtw.128.2018.05.17.10.57.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 10:57:04 -0700 (PDT)
Subject: Re: [PATCH -V2 -mm] mm, hugetlbfs: Pass fault address to no page
 handler
References: <20180517083539.9242-1-ying.huang@intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <2eba3615-5144-f08d-169a-6cfd417d00b9@oracle.com>
Date: Thu, 17 May 2018 10:56:45 -0700
MIME-Version: 1.0
In-Reply-To: <20180517083539.9242-1-ying.huang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, Christopher Lameter <cl@linux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Punit Agrawal <punit.agrawal@arm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>

On 05/17/2018 01:35 AM, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> This is to take better advantage of general huge page clearing
> optimization (c79b57e462b5d, "mm: hugetlb: clear target sub-page last
> when clearing huge page") for hugetlbfs.  In the general optimization
> patch, the sub-page to access will be cleared last to avoid the cache
> lines of to access sub-page to be evicted when clearing other
> sub-pages.  This works better if we have the address of the sub-page
> to access, that is, the fault address inside the huge page.  So the
> hugetlbfs no page fault handler is changed to pass that information.
> This will benefit workloads which don't access the begin of the
> hugetlbfs huge page after the page fault under heavy cache contention
> for shared last level cache.
> 
> The patch is a generic optimization which should benefit quite some
> workloads, not for a specific use case.  To demonstrate the performance
> benefit of the patch, we tested it with vm-scalability run on
> hugetlbfs.
> 
> With this patch, the throughput increases ~28.1% in vm-scalability
> anon-w-seq test case with 88 processes on a 2 socket Xeon E5 2699 v4
> system (44 cores, 88 threads).  The test case creates 88 processes,
> each process mmaps a big anonymous memory area with MAP_HUGETLB and
> writes to it from the end to the begin.  For each process, other
> processes could be seen as other workload which generates heavy cache
> pressure.  At the same time, the cache miss rate reduced from ~36.3%
> to ~25.6%, the IPC (instruction per cycle) increased from 0.3 to 0.37,
> and the time spent in user space is reduced ~19.3%.
> 

Agree with Michal that commit message looks better.

I went through updated patch with haddr naming so,
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
still applies.
-- 
Mike Kravetz

> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Andi Kleen <andi.kleen@intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Shaohua Li <shli@fb.com>
> Cc: Christopher Lameter <cl@linux.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Punit Agrawal <punit.agrawal@arm.com>
> Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/hugetlb.c | 42 +++++++++++++++++++++---------------------
>  1 file changed, 21 insertions(+), 21 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 129088710510..4f0682cb9414 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3686,6 +3686,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	struct page *page;
>  	pte_t new_pte;
>  	spinlock_t *ptl;
> +	unsigned long haddr = address & huge_page_mask(h);
>  
>  	/*
>  	 * Currently, we are forced to kill the process in the event the
> @@ -3716,7 +3717,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  			u32 hash;
>  			struct vm_fault vmf = {
>  				.vma = vma,
> -				.address = address,
> +				.address = haddr,
>  				.flags = flags,
>  				/*
>  				 * Hard to debug if it ends up being
> @@ -3733,14 +3734,14 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  			 * fault to make calling code simpler.
>  			 */
>  			hash = hugetlb_fault_mutex_hash(h, mm, vma, mapping,
> -							idx, address);
> +							idx, haddr);
>  			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
>  			ret = handle_userfault(&vmf, VM_UFFD_MISSING);
>  			mutex_lock(&hugetlb_fault_mutex_table[hash]);
>  			goto out;
>  		}
>  
> -		page = alloc_huge_page(vma, address, 0);
> +		page = alloc_huge_page(vma, haddr, 0);
>  		if (IS_ERR(page)) {
>  			ret = PTR_ERR(page);
>  			if (ret == -ENOMEM)
> @@ -3789,12 +3790,12 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	 * the spinlock.
>  	 */
>  	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
> -		if (vma_needs_reservation(h, vma, address) < 0) {
> +		if (vma_needs_reservation(h, vma, haddr) < 0) {
>  			ret = VM_FAULT_OOM;
>  			goto backout_unlocked;
>  		}
>  		/* Just decrements count, does not deallocate */
> -		vma_end_reservation(h, vma, address);
> +		vma_end_reservation(h, vma, haddr);
>  	}
>  
>  	ptl = huge_pte_lock(h, mm, ptep);
> @@ -3808,17 +3809,17 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  
>  	if (anon_rmap) {
>  		ClearPagePrivate(page);
> -		hugepage_add_new_anon_rmap(page, vma, address);
> +		hugepage_add_new_anon_rmap(page, vma, haddr);
>  	} else
>  		page_dup_rmap(page, true);
>  	new_pte = make_huge_pte(vma, page, ((vma->vm_flags & VM_WRITE)
>  				&& (vma->vm_flags & VM_SHARED)));
> -	set_huge_pte_at(mm, address, ptep, new_pte);
> +	set_huge_pte_at(mm, haddr, ptep, new_pte);
>  
>  	hugetlb_count_add(pages_per_huge_page(h), mm);
>  	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
>  		/* Optimization, do the COW without a second fault */
> -		ret = hugetlb_cow(mm, vma, address, ptep, page, ptl);
> +		ret = hugetlb_cow(mm, vma, haddr, ptep, page, ptl);
>  	}
>  
>  	spin_unlock(ptl);
> @@ -3830,7 +3831,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	spin_unlock(ptl);
>  backout_unlocked:
>  	unlock_page(page);
> -	restore_reserve_on_error(h, vma, address, page);
> +	restore_reserve_on_error(h, vma, haddr, page);
>  	put_page(page);
>  	goto out;
>  }
> @@ -3883,10 +3884,9 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	struct hstate *h = hstate_vma(vma);
>  	struct address_space *mapping;
>  	int need_wait_lock = 0;
> +	unsigned long haddr = address & huge_page_mask(h);
>  
> -	address &= huge_page_mask(h);
> -
> -	ptep = huge_pte_offset(mm, address, huge_page_size(h));
> +	ptep = huge_pte_offset(mm, haddr, huge_page_size(h));
>  	if (ptep) {
>  		entry = huge_ptep_get(ptep);
>  		if (unlikely(is_hugetlb_entry_migration(entry))) {
> @@ -3896,20 +3896,20 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  			return VM_FAULT_HWPOISON_LARGE |
>  				VM_FAULT_SET_HINDEX(hstate_index(h));
>  	} else {
> -		ptep = huge_pte_alloc(mm, address, huge_page_size(h));
> +		ptep = huge_pte_alloc(mm, haddr, huge_page_size(h));
>  		if (!ptep)
>  			return VM_FAULT_OOM;
>  	}
>  
>  	mapping = vma->vm_file->f_mapping;
> -	idx = vma_hugecache_offset(h, vma, address);
> +	idx = vma_hugecache_offset(h, vma, haddr);
>  
>  	/*
>  	 * Serialize hugepage allocation and instantiation, so that we don't
>  	 * get spurious allocation failures if two CPUs race to instantiate
>  	 * the same page in the page cache.
>  	 */
> -	hash = hugetlb_fault_mutex_hash(h, mm, vma, mapping, idx, address);
> +	hash = hugetlb_fault_mutex_hash(h, mm, vma, mapping, idx, haddr);
>  	mutex_lock(&hugetlb_fault_mutex_table[hash]);
>  
>  	entry = huge_ptep_get(ptep);
> @@ -3939,16 +3939,16 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	 * consumed.
>  	 */
>  	if ((flags & FAULT_FLAG_WRITE) && !huge_pte_write(entry)) {
> -		if (vma_needs_reservation(h, vma, address) < 0) {
> +		if (vma_needs_reservation(h, vma, haddr) < 0) {
>  			ret = VM_FAULT_OOM;
>  			goto out_mutex;
>  		}
>  		/* Just decrements count, does not deallocate */
> -		vma_end_reservation(h, vma, address);
> +		vma_end_reservation(h, vma, haddr);
>  
>  		if (!(vma->vm_flags & VM_MAYSHARE))
>  			pagecache_page = hugetlbfs_pagecache_page(h,
> -								vma, address);
> +								vma, haddr);
>  	}
>  
>  	ptl = huge_pte_lock(h, mm, ptep);
> @@ -3973,16 +3973,16 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  
>  	if (flags & FAULT_FLAG_WRITE) {
>  		if (!huge_pte_write(entry)) {
> -			ret = hugetlb_cow(mm, vma, address, ptep,
> +			ret = hugetlb_cow(mm, vma, haddr, ptep,
>  					  pagecache_page, ptl);
>  			goto out_put_page;
>  		}
>  		entry = huge_pte_mkdirty(entry);
>  	}
>  	entry = pte_mkyoung(entry);
> -	if (huge_ptep_set_access_flags(vma, address, ptep, entry,
> +	if (huge_ptep_set_access_flags(vma, haddr, ptep, entry,
>  						flags & FAULT_FLAG_WRITE))
> -		update_mmu_cache(vma, address, ptep);
> +		update_mmu_cache(vma, haddr, ptep);
>  out_put_page:
>  	if (page != pagecache_page)
>  		unlock_page(page);
> 
