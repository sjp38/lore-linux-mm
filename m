Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 06F066B0272
	for <linux-mm@kvack.org>; Thu, 24 May 2018 18:27:49 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id t143-v6so2343501qke.18
        for <linux-mm@kvack.org>; Thu, 24 May 2018 15:27:48 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id o13-v6si7905870qtc.295.2018.05.24.15.27.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 15:27:48 -0700 (PDT)
Subject: Re: [PATCH -V2 -mm 4/4] mm, hugetlbfs: Pass fault address to cow
 handler
References: <20180524005851.4079-1-ying.huang@intel.com>
 <20180524005851.4079-5-ying.huang@intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <e44930ce-8735-b910-a738-3957d4897f35@oracle.com>
Date: Thu, 24 May 2018 15:27:32 -0700
MIME-Version: 1.0
In-Reply-To: <20180524005851.4079-5-ying.huang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, Christopher Lameter <cl@linux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Punit Agrawal <punit.agrawal@arm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

On 05/23/2018 05:58 PM, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> This is to take better advantage of the general huge page copying
> optimization.  Where, the target subpage will be copied last to avoid
> the cache lines of target subpage to be evicted when copying other
> subpages.  This works better if the address of the target subpage is
> available when copying huge page.  So hugetlbfs page fault handlers
> are changed to pass that information to hugetlb_cow().  This will
> benefit workloads which don't access the begin of the hugetlbfs huge
> page after the page fault under heavy cache contention.
> 
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
-- 
Mike Kravetz

> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Rientjes <rientjes@google.com>
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
> ---
>  mm/hugetlb.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index ad3bec2ed269..1df974af34c1 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3500,7 +3500,7 @@ static void unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
>   * Keep the pte_same checks anyway to make transition from the mutex easier.
>   */
>  static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
> -		       unsigned long haddr, pte_t *ptep,
> +		       unsigned long address, pte_t *ptep,
>  		       struct page *pagecache_page, spinlock_t *ptl)
>  {
>  	pte_t pte;
> @@ -3509,6 +3509,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>  	int ret = 0, outside_reserve = 0;
>  	unsigned long mmun_start;	/* For mmu_notifiers */
>  	unsigned long mmun_end;		/* For mmu_notifiers */
> +	unsigned long haddr = address & huge_page_mask(h);
>  
>  	pte = huge_ptep_get(ptep);
>  	old_page = pte_page(pte);
> @@ -3583,7 +3584,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>  		goto out_release_all;
>  	}
>  
> -	copy_user_huge_page(new_page, old_page, haddr, vma,
> +	copy_user_huge_page(new_page, old_page, address, vma,
>  			    pages_per_huge_page(h));
>  	__SetPageUptodate(new_page);
>  	set_page_huge_active(new_page);
> @@ -3817,7 +3818,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	hugetlb_count_add(pages_per_huge_page(h), mm);
>  	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
>  		/* Optimization, do the COW without a second fault */
> -		ret = hugetlb_cow(mm, vma, haddr, ptep, page, ptl);
> +		ret = hugetlb_cow(mm, vma, address, ptep, page, ptl);
>  	}
>  
>  	spin_unlock(ptl);
> @@ -3971,7 +3972,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  
>  	if (flags & FAULT_FLAG_WRITE) {
>  		if (!huge_pte_write(entry)) {
> -			ret = hugetlb_cow(mm, vma, haddr, ptep,
> +			ret = hugetlb_cow(mm, vma, address, ptep,
>  					  pagecache_page, ptl);
>  			goto out_put_page;
>  		}
> 
