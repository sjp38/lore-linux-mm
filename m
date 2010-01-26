Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 47C6B6B00B5
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 12:50:30 -0500 (EST)
Date: Tue, 26 Jan 2010 17:50:14 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 02 of 31] compound_lock
Message-ID: <20100126175014.GG16468@csn.ul.ie>
References: <patchbomb.1264513915@v2.random> <1037f5f6264364a9e4cc.1264513917@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1037f5f6264364a9e4cc.1264513917@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 02:51:57PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Add a new compound_lock() needed to serialize put_page against
> __split_huge_page_refcount().
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Other than the 32-bit aspects which have already been discussed.

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -12,6 +12,7 @@
>  #include <linux/prio_tree.h>
>  #include <linux/debug_locks.h>
>  #include <linux/mm_types.h>
> +#include <linux/bit_spinlock.h>
>  
>  struct mempolicy;
>  struct anon_vma;
> @@ -294,6 +295,16 @@ static inline int is_vmalloc_or_module_a
>  }
>  #endif
>  
> +static inline void compound_lock(struct page *page)
> +{
> +	bit_spin_lock(PG_compound_lock, &page->flags);
> +}
> +
> +static inline void compound_unlock(struct page *page)
> +{
> +	bit_spin_unlock(PG_compound_lock, &page->flags);
> +}
> +
>  static inline struct page *compound_head(struct page *page)
>  {
>  	if (unlikely(PageTail(page)))
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -108,6 +108,7 @@ enum pageflags {
>  #ifdef CONFIG_MEMORY_FAILURE
>  	PG_hwpoison,		/* hardware poisoned page. Don't touch */
>  #endif
> +	PG_compound_lock,
>  	__NR_PAGEFLAGS,
>  
>  	/* Filesystems */
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
