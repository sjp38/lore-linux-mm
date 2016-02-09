Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 55A176B0005
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 16:26:10 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id c10so68129pfc.2
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 13:26:10 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y23si573155pfi.45.2016.02.09.13.26.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 13:26:09 -0800 (PST)
Date: Tue, 9 Feb 2016 13:26:08 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2] mm: Some arch may want to use HPAGE_PMD related
 values as variables
Message-Id: <20160209132608.814f08a0c3670b4f9d807441@linux-foundation.org>
In-Reply-To: <1455034304-15301-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1455034304-15301-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: mpe@ellerman.id.au, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue,  9 Feb 2016 21:41:44 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> With next generation power processor, we are having a new mmu model
> [1] that require us to maintain a different linux page table format.
> 
> Inorder to support both current and future ppc64 systems with a single
> kernel we need to make sure kernel can select between different page
> table format at runtime. With the new MMU (radix MMU) added, we will
> have two different pmd hugepage size 16MB for hash model and 2MB for
> Radix model. Hence make HPAGE_PMD related values as a variable.
> 
> [1] http://ibm.biz/power-isa3 (Needs registration).
> 
> ...
>
> --- a/include/linux/bug.h
> +++ b/include/linux/bug.h
> @@ -20,6 +20,7 @@ struct pt_regs;
>  #define BUILD_BUG_ON_MSG(cond, msg) (0)
>  #define BUILD_BUG_ON(condition) (0)
>  #define BUILD_BUG() (0)
> +#define MAYBE_BUILD_BUG_ON(cond) (0)
>  #else /* __CHECKER__ */
>  
>  /* Force a compilation error if a constant expression is not a power of 2 */
> @@ -83,6 +84,14 @@ struct pt_regs;
>   */
>  #define BUILD_BUG() BUILD_BUG_ON_MSG(1, "BUILD_BUG failed")
>  
> +#define MAYBE_BUILD_BUG_ON(cond)			\
> +	do {						\
> +		if (__builtin_constant_p((cond)))       \
> +			BUILD_BUG_ON(cond);             \
> +		else                                    \
> +			BUG_ON(cond);                   \
> +	} while (0)
> +

hm.  I suppose so.

> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -111,9 +111,6 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  			__split_huge_pmd(__vma, __pmd, __address);	\
>  	}  while (0)
>  
> -#if HPAGE_PMD_ORDER >= MAX_ORDER
> -#error "hugepages can't be allocated by the buddy allocator"
> -#endif
>  extern int hugepage_madvise(struct vm_area_struct *vma,
>  			    unsigned long *vm_flags, int advice);
>  extern void vma_adjust_trans_huge(struct vm_area_struct *vma,
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index cd26f3f14cab..350410e9019e 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -83,7 +83,7 @@ unsigned long transparent_hugepage_flags __read_mostly =
>  	(1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
>  
>  /* default scan 8*512 pte (or vmas) every 30 second */
> -static unsigned int khugepaged_pages_to_scan __read_mostly = HPAGE_PMD_NR*8;
> +static unsigned int khugepaged_pages_to_scan __read_mostly;
>  static unsigned int khugepaged_pages_collapsed;
>  static unsigned int khugepaged_full_scans;
>  static unsigned int khugepaged_scan_sleep_millisecs __read_mostly = 10000;
> @@ -98,7 +98,7 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
>   * it would have happened if the vma was large enough during page
>   * fault.
>   */
> -static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR-1;
> +static unsigned int khugepaged_max_ptes_none __read_mostly;
>  
>  static int khugepaged(void *none);
>  static int khugepaged_slab_init(void);
> @@ -660,6 +660,18 @@ static int __init hugepage_init(void)
>  		return -EINVAL;
>  	}
>  
> +	khugepaged_pages_to_scan = HPAGE_PMD_NR * 8;
> +	khugepaged_max_ptes_none = HPAGE_PMD_NR - 1;

I don't understand this change.  We change the initialization from
at-compile-time to at-run-time, but nothing useful appears to have been
done.

> +	/*
> +	 * hugepages can't be allocated by the buddy allocator
> +	 */
> +	MAYBE_BUILD_BUG_ON(HPAGE_PMD_ORDER >= MAX_ORDER);
> +	/*
> +	 * we use page->mapping and page->index in second tail page
> +	 * as list_head: assuming THP order >= 2
> +	 */
> +	MAYBE_BUILD_BUG_ON(HPAGE_PMD_ORDER < 2);
> +
>  	err = hugepage_init_sysfs(&hugepage_kobj);
>  	if (err)
>  		goto err_sysfs;
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
