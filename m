Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6D61B6B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 12:35:02 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so910271eek.10
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 09:35:01 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u5si3476578een.173.2014.04.08.09.35.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 09:35:00 -0700 (PDT)
Date: Tue, 8 Apr 2014 18:34:57 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 02/22] Allow page fault handlers to perform the COW
Message-ID: <20140408163457.GD2713@quack.suse.cz>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <feee29988e167b019f5726cd497b1470b050a3ce.1395591795.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <feee29988e167b019f5726cd497b1470b050a3ce.1395591795.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Sun 23-03-14 15:08:28, Matthew Wilcox wrote:
> Currently COW of an XIP file is done by first bringing in a read-only
> mapping, then retrying the fault and copying the page.  It is much more
> efficient to tell the fault handler that a COW is being attempted (by
> passing in the pre-allocated page in the vm_fault structure), and allow
> the handler to perform the COW operation itself.
>
> Where the filemap code protects against truncation of the file until
> the PTE has been installed with the page lock, the XIP code use the
> i_mmap_mutex instead.  We must therefore unlock the i_mmap_mutex after
> inserting the PTE.
  Eww, leaking of locking details about DAX into generic fault code is
really ugly. It seems to me that once you pass the cow_page into the fault
handler (which looks OK to me), you can just directly install it in PTE
via vm_insert_page() and you don't have to rely on do_cow_fault() for that.
Thus you can return VM_FAULT_NOPAGE and be done with it? Basically cow
faults will then work the same way as other faults for DAX... Or am I
missing something?

								Honza

> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> ---
>  include/linux/mm.h |  2 ++
>  mm/memory.c        | 45 +++++++++++++++++++++++++++++++++------------
>  2 files changed, 35 insertions(+), 12 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index c1b7414..513b78a 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -205,6 +205,7 @@ struct vm_fault {
>  	pgoff_t pgoff;			/* Logical page offset based on vma */
>  	void __user *virtual_address;	/* Faulting virtual address */
>  
> +	struct page *cow_page;		/* Handler may choose to COW */
>  	struct page *page;		/* ->fault handlers should return a
>  					 * page here, unless VM_FAULT_NOPAGE
>  					 * is set (which is also implied by
> @@ -1010,6 +1011,7 @@ static inline int page_mapped(struct page *page)
>  #define VM_FAULT_HWPOISON 0x0010	/* Hit poisoned small page */
>  #define VM_FAULT_HWPOISON_LARGE 0x0020  /* Hit poisoned large page. Index encoded in upper bits */
>  
> +#define VM_FAULT_COWED	0x0080	/* ->fault COWed the page instead */
>  #define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
>  #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
>  #define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
> diff --git a/mm/memory.c b/mm/memory.c
> index 07b4287..2a2ecac 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2602,6 +2602,7 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
>  	vmf.pgoff = page->index;
>  	vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
>  	vmf.page = page;
> +	vmf.cow_page = NULL;
>  
>  	ret = vma->vm_ops->page_mkwrite(vma, &vmf);
>  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
> @@ -3288,7 +3289,8 @@ oom:
>  }
>  
>  static int __do_fault(struct vm_area_struct *vma, unsigned long address,
> -		pgoff_t pgoff, unsigned int flags, struct page **page)
> +			pgoff_t pgoff, unsigned int flags,
> +			struct page *cow_page, struct page **page)
>  {
>  	struct vm_fault vmf;
>  	int ret;
> @@ -3297,10 +3299,13 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
>  	vmf.pgoff = pgoff;
>  	vmf.flags = flags;
>  	vmf.page = NULL;
> +	vmf.cow_page = cow_page;
>  
>  	ret = vma->vm_ops->fault(vma, &vmf);
>  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
>  		return ret;
> +	if (unlikely(ret & VM_FAULT_COWED))
> +		goto out;
>  
>  	if (unlikely(PageHWPoison(vmf.page))) {
>  		if (ret & VM_FAULT_LOCKED)
> @@ -3314,6 +3319,7 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
>  	else
>  		VM_BUG_ON_PAGE(!PageLocked(vmf.page), vmf.page);
>  
> + out:
>  	*page = vmf.page;
>  	return ret;
>  }
> @@ -3351,7 +3357,7 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	pte_t *pte;
>  	int ret;
>  
> -	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
> +	ret = __do_fault(vma, address, pgoff, flags, NULL, &fault_page);
>  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
>  		return ret;
>  
> @@ -3368,6 +3374,12 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	return ret;
>  }
>  
> +/*
> + * If the fault handler performs the COW, it does not return a page,
> + * so cannot use the page's lock to protect against a concurrent truncate
> + * operation.  Instead it returns with the i_mmap_mutex held, which must
> + * be released after the PTE has been inserted.
> + */
>  static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  		unsigned long address, pmd_t *pmd,
>  		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
> @@ -3389,25 +3401,34 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  		return VM_FAULT_OOM;
>  	}
>  
> -	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
> +	ret = __do_fault(vma, address, pgoff, flags, new_page, &fault_page);
>  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
>  		goto uncharge_out;
>  
> -	copy_user_highpage(new_page, fault_page, address, vma);
> +	if (!(ret & VM_FAULT_COWED))
> +		copy_user_highpage(new_page, fault_page, address, vma);
>  	__SetPageUptodate(new_page);
>  
>  	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
> -	if (unlikely(!pte_same(*pte, orig_pte))) {
> -		pte_unmap_unlock(pte, ptl);
> +	if (unlikely(!pte_same(*pte, orig_pte)))
> +		goto unlock_out;
> +	do_set_pte(vma, address, new_page, pte, true, true);
> +	pte_unmap_unlock(pte, ptl);
> +	if (ret & VM_FAULT_COWED) {
> +		mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
> +	} else {
>  		unlock_page(fault_page);
>  		page_cache_release(fault_page);
> -		goto uncharge_out;
>  	}
> -	do_set_pte(vma, address, new_page, pte, true, true);
> -	pte_unmap_unlock(pte, ptl);
> -	unlock_page(fault_page);
> -	page_cache_release(fault_page);
>  	return ret;
> +unlock_out:
> +	pte_unmap_unlock(pte, ptl);
> +	if (ret & VM_FAULT_COWED) {
> +		mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
> +	} else {
> +		unlock_page(fault_page);
> +		page_cache_release(fault_page);
> +	}
>  uncharge_out:
>  	mem_cgroup_uncharge_page(new_page);
>  	page_cache_release(new_page);
> @@ -3424,7 +3445,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	int dirtied = 0;
>  	int ret, tmp;
>  
> -	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
> +	ret = __do_fault(vma, address, pgoff, flags, NULL, &fault_page);
>  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
>  		return ret;
>  
> -- 
> 1.9.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
