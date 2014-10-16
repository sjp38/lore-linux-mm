Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4BB6B0069
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 05:13:38 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id pv20so2480170lab.20
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 02:13:38 -0700 (PDT)
Received: from mail.efficios.com (mail.efficios.com. [78.47.125.74])
        by mx.google.com with ESMTP id tn9si33800364lbb.72.2014.10.16.02.13.36
        for <linux-mm@kvack.org>;
        Thu, 16 Oct 2014 02:13:37 -0700 (PDT)
Date: Thu, 16 Oct 2014 11:12:22 +0200
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v11 04/21] mm: Allow page fault handlers to perform the
 COW
Message-ID: <20141016091136.GC19075@thinkos.etherlink>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-5-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411677218-29146-5-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 25-Sep-2014 04:33:21 PM, Matthew Wilcox wrote:
> Currently COW of an XIP file is done by first bringing in a read-only
> mapping, then retrying the fault and copying the page.  It is much more
> efficient to tell the fault handler that a COW is being attempted (by
> passing in the pre-allocated page in the vm_fault structure), and allow
> the handler to perform the COW operation itself.
> 
> The handler cannot insert the page itself if there is already a read-only
> mapping at that address, so allow the handler to return VM_FAULT_LOCKED
> and set the fault_page to be NULL.  This indicates to the MM code that
> the i_mmap_mutex is held instead of the page lock.

Why test the value of fault_page pointer rather than just test return
flags to detect in which state the callee left i_mmap_mutex ?

> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  include/linux/mm.h |  1 +
>  mm/memory.c        | 33 ++++++++++++++++++++++++---------
>  2 files changed, 25 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 8981cc8..0a47817 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -208,6 +208,7 @@ struct vm_fault {
>  	pgoff_t pgoff;			/* Logical page offset based on vma */
>  	void __user *virtual_address;	/* Faulting virtual address */
>  
> +	struct page *cow_page;		/* Handler may choose to COW */

The page fault handler being very much performance sensitive, I'm
wondering if it would not be better to move cow_page near the end of
struct vm_fault, so that the "page" field can stay on the first
cache line.

>  	struct page *page;		/* ->fault handlers should return a
>  					 * page here, unless VM_FAULT_NOPAGE
>  					 * is set (which is also implied by
> diff --git a/mm/memory.c b/mm/memory.c
> index adeac30..3368785 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2000,6 +2000,7 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
>  	vmf.pgoff = page->index;
>  	vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
>  	vmf.page = page;
> +	vmf.cow_page = NULL;

Could we add a FAULT_FLAG_COW_PAGE to vmf.flags, so we don't have to set
cow_page to NULL in the common case (when it is not used) ?

Thanks,

Mathieu

>  
>  	ret = vma->vm_ops->page_mkwrite(vma, &vmf);
>  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
> @@ -2698,7 +2699,8 @@ oom:
>   * See filemap_fault() and __lock_page_retry().
>   */
>  static int __do_fault(struct vm_area_struct *vma, unsigned long address,
> -		pgoff_t pgoff, unsigned int flags, struct page **page)
> +			pgoff_t pgoff, unsigned int flags,
> +			struct page *cow_page, struct page **page)
>  {
>  	struct vm_fault vmf;
>  	int ret;
> @@ -2707,10 +2709,13 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
>  	vmf.pgoff = pgoff;
>  	vmf.flags = flags;
>  	vmf.page = NULL;
> +	vmf.cow_page = cow_page;
>  
>  	ret = vma->vm_ops->fault(vma, &vmf);
>  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
>  		return ret;
> +	if (!vmf.page)
> +		goto out;
>  
>  	if (unlikely(PageHWPoison(vmf.page))) {
>  		if (ret & VM_FAULT_LOCKED)
> @@ -2724,6 +2729,7 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
>  	else
>  		VM_BUG_ON_PAGE(!PageLocked(vmf.page), vmf.page);
>  
> + out:
>  	*page = vmf.page;
>  	return ret;
>  }
> @@ -2897,7 +2903,7 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  		pte_unmap_unlock(pte, ptl);
>  	}
>  
> -	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
> +	ret = __do_fault(vma, address, pgoff, flags, NULL, &fault_page);
>  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
>  		return ret;
>  
> @@ -2937,26 +2943,35 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  		return VM_FAULT_OOM;
>  	}
>  
> -	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
> +	ret = __do_fault(vma, address, pgoff, flags, new_page, &fault_page);
>  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
>  		goto uncharge_out;
>  
> -	copy_user_highpage(new_page, fault_page, address, vma);
> +	if (fault_page)
> +		copy_user_highpage(new_page, fault_page, address, vma);
>  	__SetPageUptodate(new_page);
>  
>  	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
>  	if (unlikely(!pte_same(*pte, orig_pte))) {
>  		pte_unmap_unlock(pte, ptl);
> -		unlock_page(fault_page);
> -		page_cache_release(fault_page);
> +		if (fault_page) {
> +			unlock_page(fault_page);
> +			page_cache_release(fault_page);
> +		} else {
> +			mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
> +		}
>  		goto uncharge_out;
>  	}
>  	do_set_pte(vma, address, new_page, pte, true, true);
>  	mem_cgroup_commit_charge(new_page, memcg, false);
>  	lru_cache_add_active_or_unevictable(new_page, vma);
>  	pte_unmap_unlock(pte, ptl);
> -	unlock_page(fault_page);
> -	page_cache_release(fault_page);
> +	if (fault_page) {
> +		unlock_page(fault_page);
> +		page_cache_release(fault_page);
> +	} else {
> +		mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
> +	}
>  	return ret;
>  uncharge_out:
>  	mem_cgroup_cancel_charge(new_page, memcg);
> @@ -2975,7 +2990,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	int dirtied = 0;
>  	int ret, tmp;
>  
> -	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
> +	ret = __do_fault(vma, address, pgoff, flags, NULL, &fault_page);
>  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
>  		return ret;
>  
> -- 
> 2.1.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com
Key fingerprint: 2A0B 4ED9 15F2 D3FA 45F5  B162 1728 0A97 8118 6ACF

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
