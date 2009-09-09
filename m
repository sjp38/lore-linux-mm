Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id ED8F36B007E
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 07:15:22 -0400 (EDT)
Date: Wed, 9 Sep 2009 12:14:38 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/8] mm: FOLL_DUMP replace FOLL_ANON
Message-ID: <20090909111438.GF24614@csn.ul.ie>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils> <Pine.LNX.4.64.0909072233240.15430@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0909072233240.15430@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jeff Chua <jeff.chua.linux@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 07, 2009 at 10:35:32PM +0100, Hugh Dickins wrote:
> The "FOLL_ANON optimization" and its use_zero_page() test have caused
> confusion and bugs: why does it test VM_SHARED? for the very good but
> unsatisfying reason that VMware crashed without.  As we look to maybe
> reinstating anonymous use of the ZERO_PAGE, we need to sort this out.
> 
> Easily done: it's silly for __get_user_pages() and follow_page() to
> be guessing whether it's safe to assume that they're being used for
> a coredump (which can take a shortcut snapshot where other uses must
> handle a fault) - just tell them with GUP_FLAGS_DUMP and FOLL_DUMP.
> 
> get_dump_page() doesn't even want a ZERO_PAGE: an error suits fine.
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
> 
>  include/linux/mm.h |    2 +-
>  mm/internal.h      |    1 +
>  mm/memory.c        |   43 ++++++++++++-------------------------------
>  3 files changed, 14 insertions(+), 32 deletions(-)
> 
> --- mm3/include/linux/mm.h	2009-09-07 13:16:32.000000000 +0100
> +++ mm4/include/linux/mm.h	2009-09-07 13:16:39.000000000 +0100
> @@ -1247,7 +1247,7 @@ struct page *follow_page(struct vm_area_
>  #define FOLL_WRITE	0x01	/* check pte is writable */
>  #define FOLL_TOUCH	0x02	/* mark page accessed */
>  #define FOLL_GET	0x04	/* do get_page on page */
> -#define FOLL_ANON	0x08	/* give ZERO_PAGE if no pgtable */
> +#define FOLL_DUMP	0x08	/* give error on hole if it would be zero */
>  
>  typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
>  			void *data);
> --- mm3/mm/internal.h	2009-09-07 13:16:22.000000000 +0100
> +++ mm4/mm/internal.h	2009-09-07 13:16:39.000000000 +0100
> @@ -252,6 +252,7 @@ static inline void mminit_validate_memmo
>  
>  #define GUP_FLAGS_WRITE		0x01
>  #define GUP_FLAGS_FORCE		0x02
> +#define GUP_FLAGS_DUMP		0x04
>  
>  int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  		     unsigned long start, int len, int flags,
> --- mm3/mm/memory.c	2009-09-07 13:16:32.000000000 +0100
> +++ mm4/mm/memory.c	2009-09-07 13:16:39.000000000 +0100
> @@ -1174,41 +1174,22 @@ no_page:
>  	pte_unmap_unlock(ptep, ptl);
>  	if (!pte_none(pte))
>  		return page;
> -	/* Fall through to ZERO_PAGE handling */
> +
>  no_page_table:
>  	/*
>  	 * When core dumping an enormous anonymous area that nobody
> -	 * has touched so far, we don't want to allocate page tables.
> +	 * has touched so far, we don't want to allocate unnecessary pages or
> +	 * page tables.  Return error instead of NULL to skip handle_mm_fault,
> +	 * then get_dump_page() will return NULL to leave a hole in the dump.
> +	 * But we can only make this optimization where a hole would surely
> +	 * be zero-filled if handle_mm_fault() actually did handle it.
>  	 */
> -	if (flags & FOLL_ANON) {
> -		page = ZERO_PAGE(0);
> -		if (flags & FOLL_GET)
> -			get_page(page);
> -		BUG_ON(flags & FOLL_WRITE);
> -	}
> +	if ((flags & FOLL_DUMP) &&
> +	    (!vma->vm_ops || !vma->vm_ops->fault))
> +		return ERR_PTR(-EFAULT);
>  	return page;
>  }
>  
> -/* Can we do the FOLL_ANON optimization? */
> -static inline int use_zero_page(struct vm_area_struct *vma)
> -{
> -	/*
> -	 * We don't want to optimize FOLL_ANON for make_pages_present()
> -	 * when it tries to page in a VM_LOCKED region. As to VM_SHARED,
> -	 * we want to get the page from the page tables to make sure
> -	 * that we serialize and update with any other user of that
> -	 * mapping.
> -	 */
> -	if (vma->vm_flags & (VM_LOCKED | VM_SHARED))
> -		return 0;
> -	/*
> -	 * And if we have a fault routine, it's not an anonymous region.
> -	 */
> -	return !vma->vm_ops || !vma->vm_ops->fault;
> -}
> -
> -
> -
>  int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  		     unsigned long start, int nr_pages, int flags,
>  		     struct page **pages, struct vm_area_struct **vmas)
> @@ -1288,8 +1269,8 @@ int __get_user_pages(struct task_struct
>  		foll_flags = FOLL_TOUCH;
>  		if (pages)
>  			foll_flags |= FOLL_GET;
> -		if (!write && use_zero_page(vma))
> -			foll_flags |= FOLL_ANON;
> +		if (flags & GUP_FLAGS_DUMP)
> +			foll_flags |= FOLL_DUMP;
>  
>  		do {
>  			struct page *page;
> @@ -1447,7 +1428,7 @@ struct page *get_dump_page(unsigned long
>  	struct page *page;
>  
>  	if (__get_user_pages(current, current->mm, addr, 1,
> -				GUP_FLAGS_FORCE, &page, &vma) < 1)
> +			GUP_FLAGS_FORCE | GUP_FLAGS_DUMP, &page, &vma) < 1)
>  		return NULL;
>  	if (page == ZERO_PAGE(0)) {
>  		page_cache_release(page);
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
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
