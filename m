Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CEBAE6B0047
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 07:03:37 -0400 (EDT)
Date: Mon, 20 Sep 2010 12:03:23 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 03/10] hugetlb: redefine hugepage copy functions
Message-ID: <20100920110323.GI1998@csn.ul.ie>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1283908781-13810-4-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1283908781-13810-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 08, 2010 at 10:19:34AM +0900, Naoya Horiguchi wrote:
> This patch modifies hugepage copy functions to have only destination
> and source hugepages as arguments for later use.
> The old ones are renamed from copy_{gigantic,huge}_page() to
> copy_user_{gigantic,huge}_page().
> This naming convention is consistent with that between copy_highpage()
> and copy_user_highpage().
> 
> ChangeLog since v4:
> - add blank line between local declaration and code
> - remove unnecessary might_sleep()
> 
> ChangeLog since v2:
> - change copy_huge_page() from macro to inline dummy function
>   to avoid compile warning when !CONFIG_HUGETLB_PAGE.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  include/linux/hugetlb.h |    4 ++++
>  mm/hugetlb.c            |   45 ++++++++++++++++++++++++++++++++++++++++-----
>  2 files changed, 44 insertions(+), 5 deletions(-)
> 
> diff --git v2.6.36-rc2/include/linux/hugetlb.h v2.6.36-rc2/include/linux/hugetlb.h
> index 0b73c53..9e51f77 100644
> --- v2.6.36-rc2/include/linux/hugetlb.h
> +++ v2.6.36-rc2/include/linux/hugetlb.h
> @@ -44,6 +44,7 @@ int hugetlb_reserve_pages(struct inode *inode, long from, long to,
>  						int acctflags);
>  void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
>  void __isolate_hwpoisoned_huge_page(struct page *page);
> +void copy_huge_page(struct page *dst, struct page *src);
>  
>  extern unsigned long hugepages_treat_as_movable;
>  extern const unsigned long hugetlb_zero, hugetlb_infinity;
> @@ -102,6 +103,9 @@ static inline void hugetlb_report_meminfo(struct seq_file *m)
>  #define hugetlb_fault(mm, vma, addr, flags)	({ BUG(); 0; })
>  #define huge_pte_offset(mm, address)	0
>  #define __isolate_hwpoisoned_huge_page(page)	0
> +static inline void copy_huge_page(struct page *dst, struct page *src)
> +{
> +}
>  
>  #define hugetlb_change_protection(vma, address, end, newprot)
>  
> diff --git v2.6.36-rc2/mm/hugetlb.c v2.6.36-rc2/mm/hugetlb.c
> index f526228..351f8d1 100644
> --- v2.6.36-rc2/mm/hugetlb.c
> +++ v2.6.36-rc2/mm/hugetlb.c
> @@ -423,14 +423,14 @@ static void clear_huge_page(struct page *page,
>  	}
>  }
>  
> -static void copy_gigantic_page(struct page *dst, struct page *src,
> +static void copy_user_gigantic_page(struct page *dst, struct page *src,
>  			   unsigned long addr, struct vm_area_struct *vma)
>  {
>  	int i;
>  	struct hstate *h = hstate_vma(vma);
>  	struct page *dst_base = dst;
>  	struct page *src_base = src;
> -	might_sleep();
> +

Why is this check removed?

>  	for (i = 0; i < pages_per_huge_page(h); ) {
>  		cond_resched();
>  		copy_user_highpage(dst, src, addr + i*PAGE_SIZE, vma);
> @@ -440,14 +440,15 @@ static void copy_gigantic_page(struct page *dst, struct page *src,
>  		src = mem_map_next(src, src_base, i);
>  	}
>  }
> -static void copy_huge_page(struct page *dst, struct page *src,
> +
> +static void copy_user_huge_page(struct page *dst, struct page *src,
>  			   unsigned long addr, struct vm_area_struct *vma)
>  {
>  	int i;
>  	struct hstate *h = hstate_vma(vma);
>  
>  	if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES)) {
> -		copy_gigantic_page(dst, src, addr, vma);
> +		copy_user_gigantic_page(dst, src, addr, vma);
>  		return;
>  	}
>  
> @@ -458,6 +459,40 @@ static void copy_huge_page(struct page *dst, struct page *src,
>  	}
>  }
>  
> +static void copy_gigantic_page(struct page *dst, struct page *src)
> +{
> +	int i;
> +	struct hstate *h = page_hstate(src);
> +	struct page *dst_base = dst;
> +	struct page *src_base = src;
> +
> +	for (i = 0; i < pages_per_huge_page(h); ) {
> +		cond_resched();

Should this function not have a might_sleep() check too?

> +		copy_highpage(dst, src);
> +
> +		i++;
> +		dst = mem_map_next(dst, dst_base, i);
> +		src = mem_map_next(src, src_base, i);
> +	}
> +}
> +
> +void copy_huge_page(struct page *dst, struct page *src)
> +{
> +	int i;
> +	struct hstate *h = page_hstate(src);
> +
> +	if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES)) {
> +		copy_gigantic_page(dst, src);
> +		return;
> +	}
> +
> +	might_sleep();
> +	for (i = 0; i < pages_per_huge_page(h); i++) {
> +		cond_resched();
> +		copy_highpage(dst + i, src + i);
> +	}
> +}
> +
>  static void enqueue_huge_page(struct hstate *h, struct page *page)
>  {
>  	int nid = page_to_nid(page);
> @@ -2415,7 +2450,7 @@ retry_avoidcopy:
>  	if (unlikely(anon_vma_prepare(vma)))
>  		return VM_FAULT_OOM;
>  
> -	copy_huge_page(new_page, old_page, address, vma);
> +	copy_user_huge_page(new_page, old_page, address, vma);
>  	__SetPageUptodate(new_page);
>  
>  	/*

Other than the removal of the might_sleep() check, this looks ok too.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
