Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1853E6B0089
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 06:49:19 -0500 (EST)
Date: Thu, 18 Nov 2010 11:49:03 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 05 of 66] compound_lock
Message-ID: <20101118114902.GJ8135@csn.ul.ie>
References: <patchbomb.1288798055@v2.random> <fc2579c9bddbfcf78d72.1288798060@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <fc2579c9bddbfcf78d72.1288798060@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 03, 2010 at 04:27:40PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Add a new compound_lock() needed to serialize put_page against
> __split_huge_page_refcount().
> 

Does it only apply to a compound page? If I pass in a PageTail, what
happens? Could do with a beefier description on why it's needed but
maybe it's obvious later.

> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -14,6 +14,7 @@
>  #include <linux/mm_types.h>
>  #include <linux/range.h>
>  #include <linux/pfn.h>
> +#include <linux/bit_spinlock.h>
>  
>  struct mempolicy;
>  struct anon_vma;
> @@ -302,6 +303,40 @@ static inline int is_vmalloc_or_module_a
>  }
>  #endif
>  
> +static inline void compound_lock(struct page *page)
> +{
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	bit_spin_lock(PG_compound_lock, &page->flags);
> +#endif
> +}
> +
> +static inline void compound_unlock(struct page *page)
> +{
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	bit_spin_unlock(PG_compound_lock, &page->flags);
> +#endif
> +}
> +
> +static inline void compound_lock_irqsave(struct page *page,
> +					 unsigned long *flagsp)
> +{
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	unsigned long flags;
> +	local_irq_save(flags);
> +	compound_lock(page);
> +	*flagsp = flags;
> +#endif
> +}
> +

The pattern for spinlock irqsave passes in unsigned long, not unsigned
long *. It'd be nice if they matched.

> +static inline void compound_unlock_irqrestore(struct page *page,
> +					      unsigned long flags)
> +{
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	compound_unlock(page);
> +	local_irq_restore(flags);
> +#endif
> +}
> +
>  static inline struct page *compound_head(struct page *page)
>  {
>  	if (unlikely(PageTail(page)))
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -108,6 +108,9 @@ enum pageflags {
>  #ifdef CONFIG_MEMORY_FAILURE
>  	PG_hwpoison,		/* hardware poisoned page. Don't touch */
>  #endif
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	PG_compound_lock,
> +#endif
>  	__NR_PAGEFLAGS,
>  
>  	/* Filesystems */
> @@ -397,6 +400,12 @@ static inline void __ClearPageTail(struc
>  #define __PG_MLOCKED		0
>  #endif
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +#define __PG_COMPOUND_LOCK		(1 << PG_compound_lock)
> +#else
> +#define __PG_COMPOUND_LOCK		0
> +#endif
> +
>  /*
>   * Flags checked when a page is freed.  Pages being freed should not have
>   * these flags set.  It they are, there is a problem.
> @@ -406,7 +415,8 @@ static inline void __ClearPageTail(struc
>  	 1 << PG_private | 1 << PG_private_2 | \
>  	 1 << PG_buddy	 | 1 << PG_writeback | 1 << PG_reserved | \
>  	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
> -	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON)
> +	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON | \
> +	 __PG_COMPOUND_LOCK)
>  
>  /*
>   * Flags checked when a page is prepped for return by the page allocator.
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
