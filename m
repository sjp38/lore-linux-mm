Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8C72F6B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 22:25:20 -0400 (EDT)
Date: Thu, 7 Oct 2010 10:25:15 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/2] Encode huge page size for VM_FAULT_HWPOISON errors
Message-ID: <20101007022515.GC5482@localhost>
References: <1286398641-11862-1-git-send-email-andi@firstfloor.org>
 <1286398641-11862-2-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1286398641-11862-2-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "x86@kernel.org" <x86@kernel.org>, Andi Kleen <ak@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 07, 2010 at 04:57:20AM +0800, Andi Kleen wrote:
> From: Andi Kleen <ak@linux.intel.com>
> 
> This fixes a problem introduced with the hugetlb hwpoison handling
> 
> The user space SIGBUS signalling wants to know the size of the hugepage
> that caused a HWPOISON fault.
> 
> Unfortunately the architecture page fault handlers do not have easy
> access to the struct page.
> 
> Pass the information out in the fault error code instead.
> 
> I added a separate VM_FAULT_HWPOISON_LARGE bit for this case and encode
> the hpage index in some free upper bits of the fault code. The small
> page hwpoison keeps stays with the VM_FAULT_HWPOISON name to minimize
> changes.
> 
> Also add code to hugetlb.h to convert that index into a page shift.

The use of hstate index is space efficient, however at the cost of
more code and tight coupling with hugetlb. If directly encoding
page_order-PAGE_SHIFT, a mask of 0x3f (6 bits) will be able to present
max order 63+12=75 which is sufficient large. We still have plenty of
free bits in the 32bit fault code :)

Thanks,
Fengguang

> Will be used in a further patch.
> 
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: fengguang.wu@intel.com
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> ---
>  include/linux/hugetlb.h |    6 ++++++
>  include/linux/mm.h      |   12 ++++++++++--
>  mm/hugetlb.c            |    6 ++++--
>  mm/memory.c             |    3 ++-
>  4 files changed, 22 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 796f30e..943c76b 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -307,6 +307,11 @@ static inline struct hstate *page_hstate(struct page *page)
>  	return size_to_hstate(PAGE_SIZE << compound_order(page));
>  }
>  
> +static inline unsigned hstate_index_to_shift(unsigned index)
> +{
> +	return hstates[index].order + PAGE_SHIFT;
> +}
> +
>  #else
>  struct hstate {};
>  #define alloc_huge_page_node(h, nid) NULL
> @@ -324,6 +329,7 @@ static inline unsigned int pages_per_huge_page(struct hstate *h)
>  {
>  	return 1;
>  }
> +#define hstate_index_to_shift(index) 0
>  #endif
>  
>  #endif /* _LINUX_HUGETLB_H */
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 74949fb..f7e9efc 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -718,12 +718,20 @@ static inline int page_mapped(struct page *page)
>  #define VM_FAULT_SIGBUS	0x0002
>  #define VM_FAULT_MAJOR	0x0004
>  #define VM_FAULT_WRITE	0x0008	/* Special case for get_user_pages */
> -#define VM_FAULT_HWPOISON 0x0010	/* Hit poisoned page */
> +#define VM_FAULT_HWPOISON 0x0010	/* Hit poisoned small page */
> +#define VM_FAULT_HWPOISON_LARGE 0x0020  /* Hit poisoned large page. Index encoded in upper bits */
>  
>  #define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
>  #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
>  
> -#define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_HWPOISON)
> +#define VM_FAULT_HWPOISON_LARGE_MASK 0xf000 /* encodes hpage index for large hwpoison */
> +
> +#define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_HWPOISON | \
> +			 VM_FAULT_HWPOISON_LARGE)
> +
> +/* Encode hstate index for a hwpoisoned large page */
> +#define VM_FAULT_SET_HINDEX(x) ((x) << 12)
> +#define VM_FAULT_GET_HINDEX(x) (((x) >> 12) & 0xf)
>  
>  /*
>   * Can be called by the pagefault handler when it gets a VM_FAULT_OOM.
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 67cd032..96991de 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2589,7 +2589,8 @@ retry:
>  		 * So we need to block hugepage fault by PG_hwpoison bit check.
>  		 */
>  		if (unlikely(PageHWPoison(page))) {
> -			ret = VM_FAULT_HWPOISON;
> +			ret = VM_FAULT_HWPOISON | 
> +			      VM_FAULT_SET_HINDEX(h - hstates);
>  			goto backout_unlocked;
>  		}
>  		page_dup_rmap(page);
> @@ -2656,7 +2657,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  			migration_entry_wait(mm, (pmd_t *)ptep, address);
>  			return 0;
>  		} else if (unlikely(is_hugetlb_entry_hwpoisoned(entry)))
> -			return VM_FAULT_HWPOISON;
> +			return VM_FAULT_HWPOISON_LARGE | 
> +			       VM_FAULT_SET_HINDEX(h - hstates);
>  	}
>  
>  	ptep = huge_pte_alloc(mm, address, huge_page_size(h));
> diff --git a/mm/memory.c b/mm/memory.c
> index 71b161b..8cea8f3 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1450,7 +1450,8 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  					if (ret & VM_FAULT_OOM)
>  						return i ? i : -ENOMEM;
>  					if (ret &
> -					    (VM_FAULT_HWPOISON|VM_FAULT_SIGBUS))
> +					    (VM_FAULT_HWPOISON|VM_FAULT_HWPOISON_LARGE|
> +					     VM_FAULT_SIGBUS))
>  						return i ? i : -EFAULT;
>  					BUG();
>  				}
> -- 
> 1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
