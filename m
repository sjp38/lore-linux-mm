Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0C0066B0087
	for <linux-mm@kvack.org>; Mon,  6 Dec 2010 23:48:27 -0500 (EST)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id oB74mNGd009692
	for <linux-mm@kvack.org>; Mon, 6 Dec 2010 20:48:24 -0800
Received: from pwi6 (pwi6.prod.google.com [10.241.219.6])
	by wpaz17.hot.corp.google.com with ESMTP id oB74mIkM029696
	for <linux-mm@kvack.org>; Mon, 6 Dec 2010 20:48:22 -0800
Received: by pwi6 with SMTP id 6so2373292pwi.28
        for <linux-mm@kvack.org>; Mon, 06 Dec 2010 20:48:22 -0800 (PST)
Date: Mon, 6 Dec 2010 20:48:18 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v4 7/7] Prevent activation of page in madvise_dontneed
In-Reply-To: <ca25c4e33beceeb3a96e8437671e5e0a188602fa.1291568905.git.minchan.kim@gmail.com>
Message-ID: <alpine.LSU.2.00.1012062027100.8572@tigran.mtv.corp.google.com>
References: <cover.1291568905.git.minchan.kim@gmail.com> <ca25c4e33beceeb3a96e8437671e5e0a188602fa.1291568905.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Dec 2010, Minchan Kim wrote:

> Now zap_pte_range alwayas activates pages which are pte_young &&
> !VM_SequentialReadHint(vma). But in case of calling MADV_DONTNEED,
> it's unnecessary since the page wouldn't use any more.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Nick Piggin <npiggin@kernel.dk>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> 
> Changelog since v3:
>  - Change variable name - suggested by Johannes
>  - Union ignore_references with zap_details - suggested by Hugh
> 
> Changelog since v2:
>  - remove unnecessary description
> 
> Changelog since v1:
>  - change word from promote to activate
>  - add activate argument to zap_pte_range and family function
> ---
>  include/linux/mm.h |    4 +++-
>  mm/madvise.c       |    6 +++---
>  mm/memory.c        |    5 ++++-
>  3 files changed, 10 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 6522ae4..e57190f 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -771,12 +771,14 @@ struct zap_details {
>  	pgoff_t last_index;			/* Highest page->index to unmap */
>  	spinlock_t *i_mmap_lock;		/* For unmap_mapping_range: */
>  	unsigned long truncate_count;		/* Compare vm_truncate_count */
> +	bool ignore_references;			/* For page activation */
>  };
>  
>  #define __ZAP_DETAILS_INITIALIZER(name) \
>                  { .nonlinear_vma = NULL \
>  		, .check_mapping = NULL \
> -		, .i_mmap_lock = NULL }
> +		, .i_mmap_lock = NULL	\
> +		, .ignore_references = false }

Okay.

>  
>  #define DEFINE_ZAP_DETAILS(name)		\
>  	struct zap_details name = __ZAP_DETAILS_INITIALIZER(name)
> diff --git a/mm/madvise.c b/mm/madvise.c
> index bfa17aa..8e7aba3 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -163,6 +163,7 @@ static long madvise_dontneed(struct vm_area_struct * vma,
>  			     unsigned long start, unsigned long end)
>  {
>  	DEFINE_ZAP_DETAILS(details);
> +	details.ignore_references = true;
>  
>  	*prev = vma;
>  	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
> @@ -173,10 +174,9 @@ static long madvise_dontneed(struct vm_area_struct * vma,
>  		details.last_index = ULONG_MAX;
>  
>  		zap_page_range(vma, start, end - start, &details);
> -	} else {
> -
> +	} else
>  		zap_page_range(vma, start, end - start, &details);
> -	}
> +

As in the previous patch, you have the same in the if {} and the else.

>  	return 0;
>  }
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index c0879bb..44d87e1 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -897,6 +897,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>  	pte_t *pte;
>  	spinlock_t *ptl;
>  	int rss[NR_MM_COUNTERS];
> +	bool ignore_references = details->ignore_references;
>  
>  	init_rss_vec(rss);
>  
> @@ -952,7 +953,8 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>  				if (pte_dirty(ptent))
>  					set_page_dirty(page);
>  				if (pte_young(ptent) &&
> -				    likely(!VM_SequentialReadHint(vma)))
> +				    likely(!VM_SequentialReadHint(vma)) &&
> +					!ignore_references)

I think ignore_references is about as likely as VM_SequentialReadHint:
I'd probably just omit that "likely()" nowadays, but you might prefer
to put your "|| !ignore_references" inside.

Hmm, actually it would probably be better to say something like

	mark_accessed = true;
	if (VM_SequentialReadHint(vma) ||
            (details && details->ignore_references))
		mark_accessed = false;

on entry to zap_pte_range().

>  					mark_page_accessed(page);
>  				rss[MM_FILEPAGES]--;
>  			}
> @@ -1218,6 +1220,7 @@ int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
>  		unsigned long size)
>  {
>  	DEFINE_ZAP_DETAILS(details);
> +	details.ignore_references = true;
>  	if (address < vma->vm_start || address + size > vma->vm_end ||
>  	    		!(vma->vm_flags & VM_PFNMAP))
>  		return -1;
> -- 

Unnecessary here (would make more sense in the truncation case,
but not necessary there either): zap_vma_ptes() is only being used on
GRU's un-cowable VM_PFNMAP area, so vm_normal_page() won't even give
you a non-NULL page to mark.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
