Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3398E6B007D
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 14:57:09 -0500 (EST)
Date: Tue, 26 Jan 2010 19:56:55 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 19 of 31] clear page compound
Message-ID: <20100126195655.GV16468@csn.ul.ie>
References: <patchbomb.1264513915@v2.random> <fdc4060ac52e26d9e91f.1264513934@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <fdc4060ac52e26d9e91f.1264513934@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 02:52:14PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> split_huge_page must transform a compound page to a regular page and needs
> ClearPageCompound.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -349,7 +349,7 @@ static inline void set_page_writeback(st
>   * tests can be used in performance sensitive paths. PageCompound is
>   * generally not used in hot code paths.
>   */
> -__PAGEFLAG(Head, head)
> +__PAGEFLAG(Head, head) CLEARPAGEFLAG(Head, head)
>  __PAGEFLAG(Tail, tail)
>  
>  static inline int PageCompound(struct page *page)
> @@ -357,6 +357,13 @@ static inline int PageCompound(struct pa
>  	return page->flags & ((1L << PG_head) | (1L << PG_tail));
>  
>  }
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static inline void ClearPageCompound(struct page *page)
> +{
> +	BUG_ON(!PageHead(page));
> +	ClearPageHead(page);
> +}
> +#endif
>  #else
>  /*
>   * Reduce page flag use as much as possible by overlapping
> @@ -394,6 +401,14 @@ static inline void __ClearPageTail(struc
>  	page->flags &= ~PG_head_tail_mask;
>  }
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static inline void ClearPageCompound(struct page *page)
> +{
> +	BUG_ON(page->flags & PG_head_tail_mask != (1L << PG_compound));

1L?

> +	ClearPageCompound(page);
> +}
> +#endif
> +
>  #endif /* !PAGEFLAGS_EXTENDED */
>  
>  #ifdef CONFIG_MMU
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
