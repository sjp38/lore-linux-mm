Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 820506B0005
	for <linux-mm@kvack.org>; Mon, 14 May 2018 23:25:46 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id y7-v6so17606896qtn.3
        for <linux-mm@kvack.org>; Mon, 14 May 2018 20:25:46 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id f21-v6si1940108qtm.14.2018.05.14.20.25.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 20:25:42 -0700 (PDT)
Subject: Re: [PATCH -mm] mm, hugetlb: Pass fault address to no page handler
References: <20180515005756.28942-1-ying.huang@intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <2f97bdea-d873-19d7-ff55-9a625bdfdd67@oracle.com>
Date: Mon, 14 May 2018 20:25:23 -0700
MIME-Version: 1.0
In-Reply-To: <20180515005756.28942-1-ying.huang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, Christopher Lameter <cl@linux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Punit Agrawal <punit.agrawal@arm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

On 05/14/2018 05:57 PM, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> This is to take better advantage of huge page clearing
> optimization (c79b57e462b5d, "mm: hugetlb: clear target sub-page last
> when clearing huge page").  Which will clear to access sub-page last
> to avoid the cache lines of to access sub-page to be evicted when
> clearing other sub-pages.  This needs to get the address of the
> sub-page to access, that is, the fault address inside of the huge
> page.  So the hugetlb no page fault handler is changed to pass that
> information.  This will benefit workloads which don't access the begin
> of the huge page after page fault.
> 
> With this patch, the throughput increases ~28.1% in vm-scalability
> anon-w-seq test case with 88 processes on a 2 socket Xeon E5 2699 v4
> system (44 cores, 88 threads).  The test case creates 88 processes,
> each process mmap a big anonymous memory area and writes to it from
> the end to the begin.  For each process, other processes could be seen
> as other workload which generates heavy cache pressure.  At the same
> time, the cache miss rate reduced from ~36.3% to ~25.6%, the
> IPC (instruction per cycle) increased from 0.3 to 0.37, and the time
> spent in user space is reduced ~19.3%

Since this patch only addresses hugetlbfs huge pages, I would suggest
making that more explicit in the commit message.  Other than that, the
changes look fine to me.

> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
-- 
Mike Kravetz

> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Andi Kleen <andi.kleen@intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Shaohua Li <shli@fb.com>
> Cc: Christopher Lameter <cl@linux.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Punit Agrawal <punit.agrawal@arm.com>
> Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
>  mm/hugetlb.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 129088710510..3de6326abf39 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3677,7 +3677,7 @@ int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
>  
>  static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  			   struct address_space *mapping, pgoff_t idx,
> -			   unsigned long address, pte_t *ptep, unsigned int flags)
> +			   unsigned long faddress, pte_t *ptep, unsigned int flags)
>  {
>  	struct hstate *h = hstate_vma(vma);
>  	int ret = VM_FAULT_SIGBUS;
> @@ -3686,6 +3686,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	struct page *page;
>  	pte_t new_pte;
>  	spinlock_t *ptl;
> +	unsigned long address = faddress & huge_page_mask(h);
>  
>  	/*
>  	 * Currently, we are forced to kill the process in the event the
> @@ -3749,7 +3750,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  				ret = VM_FAULT_SIGBUS;
>  			goto out;
>  		}
> -		clear_huge_page(page, address, pages_per_huge_page(h));
> +		clear_huge_page(page, faddress, pages_per_huge_page(h));
>  		__SetPageUptodate(page);
>  		set_page_huge_active(page);
>  
> @@ -3871,7 +3872,7 @@ u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
>  #endif
>  
>  int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> -			unsigned long address, unsigned int flags)
> +			unsigned long faddress, unsigned int flags)
>  {
>  	pte_t *ptep, entry;
>  	spinlock_t *ptl;
> @@ -3883,8 +3884,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	struct hstate *h = hstate_vma(vma);
>  	struct address_space *mapping;
>  	int need_wait_lock = 0;
> -
> -	address &= huge_page_mask(h);
> +	unsigned long address = faddress & huge_page_mask(h);
>  
>  	ptep = huge_pte_offset(mm, address, huge_page_size(h));
>  	if (ptep) {
> @@ -3914,7 +3914,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  
>  	entry = huge_ptep_get(ptep);
>  	if (huge_pte_none(entry)) {
> -		ret = hugetlb_no_page(mm, vma, mapping, idx, address, ptep, flags);
> +		ret = hugetlb_no_page(mm, vma, mapping, idx, faddress, ptep, flags);
>  		goto out_mutex;
>  	}
>  
> 
