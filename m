Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B97248E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 05:05:36 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id v2so3667815plg.6
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 02:05:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f68sor40321035pfh.22.2018.12.21.02.05.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 02:05:34 -0800 (PST)
Date: Fri, 21 Dec 2018 13:05:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 1/2] hugetlbfs: use i_mmap_rwsem for more pmd sharing
 synchronization
Message-ID: <20181221100528.bkvddcqom7qaxwbe@kshutemo-mobl1>
References: <20181218223557.5202-1-mike.kravetz@oracle.com>
 <20181218223557.5202-2-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181218223557.5202-2-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Tue, Dec 18, 2018 at 02:35:56PM -0800, Mike Kravetz wrote:
> While looking at BUGs associated with invalid huge page map counts,
> it was discovered and observed that a huge pte pointer could become
> 'invalid' and point to another task's page table.  Consider the
> following:
> 
> A task takes a page fault on a shared hugetlbfs file and calls
> huge_pte_alloc to get a ptep.  Suppose the returned ptep points to a
> shared pmd.
> 
> Now, another task truncates the hugetlbfs file.  As part of truncation,
> it unmaps everyone who has the file mapped.  If the range being
> truncated is covered by a shared pmd, huge_pmd_unshare will be called.
> For all but the last user of the shared pmd, huge_pmd_unshare will
> clear the pud pointing to the pmd.  If the task in the middle of the
> page fault is not the last user, the ptep returned by huge_pte_alloc
> now points to another task's page table or worse.  This leads to bad
> things such as incorrect page map/reference counts or invalid memory
> references.
> 
> To fix, expand the use of i_mmap_rwsem as follows:
> - i_mmap_rwsem is held in read mode whenever huge_pmd_share is called.
>   huge_pmd_share is only called via huge_pte_alloc, so callers of
>   huge_pte_alloc take i_mmap_rwsem before calling.  In addition, callers
>   of huge_pte_alloc continue to hold the semaphore until finished with
>   the ptep.
> - i_mmap_rwsem is held in write mode whenever huge_pmd_unshare is called.
> 
> Cc: <stable@vger.kernel.org>
> Fixes: 39dde65c9940 ("shared page table for hugetlb page")
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Other the few questions below. The patch looks reasonable to me.

> @@ -3252,11 +3253,23 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
>  
>  	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
>  		spinlock_t *src_ptl, *dst_ptl;
> +
>  		src_pte = huge_pte_offset(src, addr, sz);
>  		if (!src_pte)
>  			continue;
> +
> +		/*
> +		 * i_mmap_rwsem must be held to call huge_pte_alloc.
> +		 * Continue to hold until finished  with dst_pte, otherwise
> +		 * it could go away if part of a shared pmd.
> +		 *
> +		 * Technically, i_mmap_rwsem is only needed in the non-cow
> +		 * case as cow mappings are not shared.
> +		 */
> +		i_mmap_lock_read(mapping);

Any reason you do lock/unlock on each iteration rather than around whole
loop?

>  		dst_pte = huge_pte_alloc(dst, addr, sz);
>  		if (!dst_pte) {
> +			i_mmap_unlock_read(mapping);
>  			ret = -ENOMEM;
>  			break;
>  		}

...

> @@ -3772,14 +3789,18 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
>  			};
>  
>  			/*
> -			 * hugetlb_fault_mutex must be dropped before
> -			 * handling userfault.  Reacquire after handling
> -			 * fault to make calling code simpler.
> +			 * hugetlb_fault_mutex and i_mmap_rwsem must be
> +			 * dropped before handling userfault.  Reacquire
> +			 * after handling fault to make calling code simpler.
>  			 */
>  			hash = hugetlb_fault_mutex_hash(h, mm, vma, mapping,
>  							idx, haddr);
>  			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
> +			i_mmap_unlock_read(mapping);
> +

Do we have order of hugetlb_fault_mutex vs. i_mmap_lock documented?
I *looks* correct to me, but it's better to write it down somewhere.
Mayby add to the header of mm/rmap.c?

>  			ret = handle_userfault(&vmf, VM_UFFD_MISSING);
> +
> +			i_mmap_lock_read(mapping);
>  			mutex_lock(&hugetlb_fault_mutex_table[hash]);
>  			goto out;
>  		}

-- 
 Kirill A. Shutemov
