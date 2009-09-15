Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5F3EE6B0055
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 08:26:23 -0400 (EDT)
Date: Tue, 15 Sep 2009 13:26:32 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] Helper which returns the huge page at a given
	address (Take 3)
Message-ID: <20090915122632.GC31840@csn.ul.ie>
References: <202cde0e0909132218k70c31a5u922636914e603ad4@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <202cde0e0909132218k70c31a5u922636914e603ad4@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolex@gmail.com>
Cc: Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 14, 2009 at 05:18:53PM +1200, Alexey Korolev wrote:
> This patch provides helper function which returns the huge page at a
> given address for population before the page has been faulted.
> It is possible to call hugetlb_get_user_page function in file mmap
> procedure to get pages before they have been requested by user level.
> 

Worth spelling out that this is similar in principal to get_user_pages()
but not as painful to use in this specific context.

> include/linux/hugetlb.h |    3 +++
> mm/hugetlb.c            |   23 +++++++++++++++++++++++
> 2 files changed, 26 insertions(+)
> 
> ---
> Signed-off-by: Alexey Korolev <akorolev@infradead.org>

Patch formatting nit.

diffstat goes below the --- and signed-off-bys go above it.

> 
> diff -aurp clean/include/linux/hugetlb.h patched/include/linux/hugetlb.h
> --- clean/include/linux/hugetlb.h	2009-09-11 15:33:48.000000000 +1200
> +++ patched/include/linux/hugetlb.h	2009-09-11 20:09:02.000000000 +1200
> @@ -39,6 +39,8 @@ int hugetlb_reserve_pages(struct inode *
>  						struct vm_area_struct *vma,
>  						int acctflags);
>  void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
> +struct page *hugetlb_get_user_page(struct vm_area_struct *vma,
> +						unsigned long address);
> 
>  extern unsigned long hugepages_treat_as_movable;
>  extern const unsigned long hugetlb_zero, hugetlb_infinity;
> @@ -100,6 +102,7 @@ static inline void hugetlb_report_meminf
>  #define is_hugepage_only_range(mm, addr, len)	0
>  #define hugetlb_free_pgd_range(tlb, addr, end, floor, ceiling) ({BUG(); 0; })
>  #define hugetlb_fault(mm, vma, addr, flags)	({ BUG(); 0; })
> +#define hugetlb_get_user_page(vma, address)	ERR_PTR(-EINVAL)
> 
>  #define hugetlb_change_protection(vma, address, end, newprot)
> 
> diff -aurp clean/mm/hugetlb.c patched/mm/hugetlb.c
> --- clean/mm/hugetlb.c	2009-09-06 11:38:12.000000000 +1200
> +++ patched/mm/hugetlb.c	2009-09-11 08:34:00.000000000 +1200
> @@ -2187,6 +2187,29 @@ static int huge_zeropage_ok(pte_t *ptep,
>  		return huge_pte_none(huge_ptep_get(ptep));
>  }
> 
> +/*
> + * hugetlb_get_user_page returns the page at a given address for population
> + * before the page has been faulted.
> + */
> +struct page *hugetlb_get_user_page(struct vm_area_struct *vma,
> +				    unsigned long address)
> +{

Your leader and comments say that the function can be used before the pages
have been faulted. It would presumably require that this function be called
from within a mmap() handler.

What is happening because you call follow_hugetlb_page() is that the pages
get faulted as part of your mmap() operation. This might make the overall
operation more expensive than you expected. I don't know if what you really
intended was to allocate the huge page, insert it into the page cache and
have it faulted later if the process actually references the page.

Similarly the leader and comments imply that you expect this to be
called as part of the mmap() operation. However, nothing would appear to
prevent the driver calling this function once the page is already
faulted. Is this intentional?


> +	int ret;
> +	int cnt = 1;
> +	struct page *pg;
> +	struct hstate *h = hstate_vma(vma);
> +
> +	address = address & huge_page_mask(h);
> +	ret = follow_hugetlb_page(vma->vm_mm, vma, &pg,
> +				NULL, &address, &cnt, 0, 0);
> +	if (ret < 0)
> +		return ERR_PTR(ret);
> +	put_page(pg);
> +
> +	return pg;
> +}

I think the caller should be responsible for calling put_page().  Otherwise
there is an outside chance that the page would disappear from you unexpectedly
depending on exactly how the driver was implemented. It would also
behave slightly more like get_user_pages().

> +EXPORT_SYMBOL_GPL(hugetlb_get_user_page);
> +
>  int follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  			struct page **pages, struct vm_area_struct **vmas,
>  			unsigned long *position, int *length, int i,
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
