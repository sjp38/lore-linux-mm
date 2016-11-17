Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id D5F866B0353
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 14:41:39 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id d33so148917780uad.2
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 11:41:39 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id l1si1309253ual.50.2016.11.17.11.41.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 11:41:39 -0800 (PST)
Subject: Re: [PATCH 15/33] userfaultfd: hugetlbfs: add __mcopy_atomic_hugetlb
 for huge page UFFDIO_COPY
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
 <1478115245-32090-16-git-send-email-aarcange@redhat.com>
 <074501d235bb$3766dbd0$a6349370$@alibaba-inc.com>
 <c9c59023-35ee-1012-1da7-13c3aa89ba61@oracle.com>
 <31d06dc7-ea2d-4ca3-821a-f14ea69de3e9@oracle.com>
 <20161104193626.GU4611@redhat.com>
 <1805f956-1777-471c-1401-46c984189c88@oracle.com>
 <20161116182809.GC26185@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <e17bb1cf-b78d-2b94-ad16-d9bd4d127f39@oracle.com>
Date: Thu, 17 Nov 2016 11:41:25 -0800
MIME-Version: 1.0
In-Reply-To: <20161116182809.GC26185@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Shaohua Li' <shli@fb.com>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Mike Rapoport' <rppt@linux.vnet.ibm.com>

On 11/16/2016 10:28 AM, Andrea Arcangeli wrote:
> Hello Mike,
> 
> On Tue, Nov 08, 2016 at 01:06:06PM -0800, Mike Kravetz wrote:
>> -- 
>> Mike Kravetz
>>
>> From: Mike Kravetz <mike.kravetz@oracle.com>
>>
>> userfaultfd: hugetlbfs: fix __mcopy_atomic_hugetlb retry/error processing
>>
>> The new routine copy_huge_page_from_user() uses kmap_atomic() to map
>> PAGE_SIZE pages.  However, this prevents page faults in the subsequent
>> call to copy_from_user().  This is OK in the case where the routine
>> is copied with mmap_sema held.  However, in another case we want to
>> allow page faults.  So, add a new argument allow_pagefault to indicate
>> if the routine should allow page faults.
>>
>> A patch (mm/hugetlb: fix huge page reservation leak in private mapping
>> error paths) was recently submitted and is being added to -mm tree.  It
>> addresses the issue huge page reservations when a huge page is allocated,
>> and free'ed before being instantiated in an address space.  This would
>> typically happen in error paths.  The routine __mcopy_atomic_hugetlb has
>> such an error path, so it will need to call restore_reserve_on_error()
>> before free'ing the huge page.  restore_reserve_on_error is currently
>> only visible in mm/hugetlb.c.  So, add it to a header file so that it
>> can be used in mm/userfaultfd.c.  Another option would be to move
>> __mcopy_atomic_hugetlb into mm/hugetlb.c
> 
> It would have been better to split this in two patches.
> 
>> @@ -302,8 +302,10 @@ static __always_inline ssize_t
>> __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
>>  out_unlock:
>>  	up_read(&dst_mm->mmap_sem);
>>  out:
>> -	if (page)
>> +	if (page) {
>> +		restore_reserve_on_error(h, dst_vma, dst_addr, page);
>>  		put_page(page);
>> +	}
>>  	BUG_ON(copied < 0);
> 
> If the revalidation fails dst_vma could even be NULL.
> 
> We get there with page not NULL only if something in the revalidation
> fails effectively... I'll have to drop the above change as the fix
> will hurt more than the vma reservation not being restored. Didn't
> think too much about it, but there was no obvious way to restore the
> reservation of a vma, after we drop the mmap_sem. However if we don't
> drop the mmap_sem, we'd recurse into it, and it'll deadlock in current
> implementation if a down_write is already pending somewhere else. In
> this specific case fairness is not an issue, but it's not checking
> it's the same thread taking it again, so it's doesn't allow to recurse
> (checking it's the same thread would make it slower).
> 
> I also fixed the gup support for userfaultfd, could you review it?
> Beware, untested... will test it shortly with qemu postcopy live
> migration with hugetlbfs instead of THP (that currently gracefully
> complains about FAULT_FLAG_ALLOW_RETRY missing, KVM ioctl returns
> badaddr and DEBUG_VM=y clearly showed the stack trace of where
> FAULT_FLAG_ALLOW_RETRY was missing).
> 
> I think this enhancement is needed by Oracle too, so that you don't
> get an error from I/O syscalls, and you instead get an userfault.
> 
> We need to update the selftest to trigger userfaults not only with the
> CPU but with O_DIRECT too.
> 
> Note, the FOLL_NOWAIT is needed to offload the userfaults to async
> page faults. KVM tries an async fault first (FOLL_NOWAIT, nonblocking
> = NULL), if that fails it offload a blocking (*nonblocking = 1) fault
> through async page fault kernel thread while guest scheduler schedule
> away the blocked process. So the userfaults behave like SSD swapins
> from disk hitting on a single guest thread and not the whole host vcpu
> thread. Clearly hugetlbfs cannot ever block for I/O, FOLL_NOWAIT is
> only useful to avoid blocking in the vcpu thread in
> handle_userfault().
> 
> From ff1ce62ee0acb14ed71621ba99f01f008a5d212d Mon Sep 17 00:00:00 2001
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Wed, 16 Nov 2016 18:34:20 +0100
> Subject: [PATCH 1/1] userfaultfd: hugetlbfs: gup: support VM_FAULT_RETRY
> 
> Add support for VM_FAULT_RETRY to follow_hugetlb_page() so that
> get_user_pages_unlocked/locked and "nonblocking/FOLL_NOWAIT" features
> will work on hugetlbfs. This is required for fully functional
> userfaultfd non-present support on hugetlbfs.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
-- 
Mike Kravetz

> ---
>  include/linux/hugetlb.h |  5 +++--
>  mm/gup.c                |  2 +-
>  mm/hugetlb.c            | 48 ++++++++++++++++++++++++++++++++++++++++--------
>  3 files changed, 44 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index bf02b7e..542416d 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -65,7 +65,8 @@ int hugetlb_mempolicy_sysctl_handler(struct ctl_table *, int,
>  int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
>  long follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *,
>  			 struct page **, struct vm_area_struct **,
> -			 unsigned long *, unsigned long *, long, unsigned int);
> +			 unsigned long *, unsigned long *, long, unsigned int,
> +			 int *);
>  void unmap_hugepage_range(struct vm_area_struct *,
>  			  unsigned long, unsigned long, struct page *);
>  void __unmap_hugepage_range_final(struct mmu_gather *tlb,
> @@ -138,7 +139,7 @@ static inline unsigned long hugetlb_total_pages(void)
>  	return 0;
>  }
>  
> -#define follow_hugetlb_page(m,v,p,vs,a,b,i,w)	({ BUG(); 0; })
> +#define follow_hugetlb_page(m,v,p,vs,a,b,i,w,n)	({ BUG(); 0; })
>  #define follow_huge_addr(mm, addr, write)	ERR_PTR(-EINVAL)
>  #define copy_hugetlb_page_range(src, dst, vma)	({ BUG(); 0; })
>  static inline void hugetlb_report_meminfo(struct seq_file *m)
> diff --git a/mm/gup.c b/mm/gup.c
> index ec4f827..36e88a9 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -572,7 +572,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  			if (is_vm_hugetlb_page(vma)) {
>  				i = follow_hugetlb_page(mm, vma, pages, vmas,
>  						&start, &nr_pages, i,
> -						gup_flags);
> +						gup_flags, nonblocking);
>  				continue;
>  			}
>  		}
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 9ce8ecb..022750d 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4039,7 +4039,7 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
>  long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  			 struct page **pages, struct vm_area_struct **vmas,
>  			 unsigned long *position, unsigned long *nr_pages,
> -			 long i, unsigned int flags)
> +			 long i, unsigned int flags, int *nonblocking)
>  {
>  	unsigned long pfn_offset;
>  	unsigned long vaddr = *position;
> @@ -4102,16 +4102,43 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		    ((flags & FOLL_WRITE) &&
>  		      !huge_pte_write(huge_ptep_get(pte)))) {
>  			int ret;
> +			unsigned int fault_flags = 0;
>  
>  			if (pte)
>  				spin_unlock(ptl);
> -			ret = hugetlb_fault(mm, vma, vaddr,
> -				(flags & FOLL_WRITE) ? FAULT_FLAG_WRITE : 0);
> -			if (!(ret & VM_FAULT_ERROR))
> -				continue;
> -
> -			remainder = 0;
> -			break;
> +			if (flags & FOLL_WRITE)
> +				fault_flags |= FAULT_FLAG_WRITE;
> +			if (nonblocking)
> +				fault_flags |= FAULT_FLAG_ALLOW_RETRY;
> +			if (flags & FOLL_NOWAIT)
> +				fault_flags |= FAULT_FLAG_ALLOW_RETRY |
> +					FAULT_FLAG_RETRY_NOWAIT;
> +			if (flags & FOLL_TRIED) {
> +				VM_WARN_ON_ONCE(fault_flags &
> +						FAULT_FLAG_ALLOW_RETRY);
> +				fault_flags |= FAULT_FLAG_TRIED;
> +			}
> +			ret = hugetlb_fault(mm, vma, vaddr, fault_flags);
> +			if (ret & VM_FAULT_ERROR) {
> +				remainder = 0;
> +				break;
> +			}
> +			if (ret & VM_FAULT_RETRY) {
> +				if (nonblocking)
> +					*nonblocking = 0;
> +				*nr_pages = 0;
> +				/*
> +				 * VM_FAULT_RETRY must not return an
> +				 * error, it will return zero
> +				 * instead.
> +				 *
> +				 * No need to update "position" as the
> +				 * caller will not check it after
> +				 * *nr_pages is set to 0.
> +				 */
> +				return i;
> +			}
> +			continue;
>  		}
>  
>  		pfn_offset = (vaddr & ~huge_page_mask(h)) >> PAGE_SHIFT;
> @@ -4140,6 +4167,11 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		spin_unlock(ptl);
>  	}
>  	*nr_pages = remainder;
> +	/*
> +	 * setting position is actually required only if remainder is
> +	 * not zero but it's faster not to add a "if (remainder)"
> +	 * branch.
> +	 */
>  	*position = vaddr;
>  
>  	return i ? i : -EFAULT;
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
