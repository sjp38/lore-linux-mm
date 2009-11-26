Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4C96E6B0098
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 11:20:20 -0500 (EST)
Date: Thu, 26 Nov 2009 16:20:12 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/9] ksm: fix mlockfreed to munlocked
Message-ID: <20091126162011.GG13095@csn.ul.ie>
References: <Pine.LNX.4.64.0911241634170.24427@sister.anvils> <Pine.LNX.4.64.0911241638130.25288@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0911241638130.25288@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 24, 2009 at 04:40:55PM +0000, Hugh Dickins wrote:
> When KSM merges an mlocked page, it has been forgetting to munlock it:
> that's been left to free_page_mlock(), which reports it in /proc/vmstat
> as unevictable_pgs_mlockfreed instead of unevictable_pgs_munlocked (and
> whinges "Page flag mlocked set for process" in mmotm, whereas mainline
> is silently forgiving).  Call munlock_vma_page() to fix that.
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
> Is this a fix that I ought to backport to 2.6.32?  It does rely on part of
> an earlier patch (moved unlock_page down), so does not apply cleanly as is.
> 
>  mm/internal.h |    3 ++-
>  mm/ksm.c      |    4 ++++
>  mm/mlock.c    |    4 ++--
>  3 files changed, 8 insertions(+), 3 deletions(-)
> 
> --- ksm0/mm/internal.h	2009-11-14 10:17:02.000000000 +0000
> +++ ksm1/mm/internal.h	2009-11-22 20:39:56.000000000 +0000
> @@ -105,9 +105,10 @@ static inline int is_mlocked_vma(struct
>  }
>  
>  /*
> - * must be called with vma's mmap_sem held for read, and page locked.
> + * must be called with vma's mmap_sem held for read or write, and page locked.
>   */
>  extern void mlock_vma_page(struct page *page);
> +extern void munlock_vma_page(struct page *page);
>  
>  /*
>   * Clear the page's PageMlocked().  This can be useful in a situation where
> --- ksm0/mm/ksm.c	2009-11-14 10:17:02.000000000 +0000
> +++ ksm1/mm/ksm.c	2009-11-22 20:39:56.000000000 +0000
> @@ -34,6 +34,7 @@
>  #include <linux/ksm.h>
>  
>  #include <asm/tlbflush.h>
> +#include "internal.h"
>  
>  /*
>   * A few notes about the KSM scanning process,
> @@ -762,6 +763,9 @@ static int try_to_merge_one_page(struct
>  	    pages_identical(page, kpage))
>  		err = replace_page(vma, page, kpage, orig_pte);
>  
> +	if ((vma->vm_flags & VM_LOCKED) && !err)
> +		munlock_vma_page(page);
> +
>  	unlock_page(page);
>  out:
>  	return err;
> --- ksm0/mm/mlock.c	2009-11-14 10:17:02.000000000 +0000
> +++ ksm1/mm/mlock.c	2009-11-22 20:39:56.000000000 +0000
> @@ -99,14 +99,14 @@ void mlock_vma_page(struct page *page)
>   * not get another chance to clear PageMlocked.  If we successfully
>   * isolate the page and try_to_munlock() detects other VM_LOCKED vmas
>   * mapping the page, it will restore the PageMlocked state, unless the page
> - * is mapped in a non-linear vma.  So, we go ahead and SetPageMlocked(),
> + * is mapped in a non-linear vma.  So, we go ahead and ClearPageMlocked(),
>   * perhaps redundantly.
>   * If we lose the isolation race, and the page is mapped by other VM_LOCKED
>   * vmas, we'll detect this in vmscan--via try_to_munlock() or try_to_unmap()
>   * either of which will restore the PageMlocked state by calling
>   * mlock_vma_page() above, if it can grab the vma's mmap sem.
>   */
> -static void munlock_vma_page(struct page *page)
> +void munlock_vma_page(struct page *page)
>  {
>  	BUG_ON(!PageLocked(page));
>  
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
