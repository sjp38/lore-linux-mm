Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4CFAD6B0038
	for <linux-mm@kvack.org>; Sat, 11 Apr 2015 17:40:57 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so61870863pdb.0
        for <linux-mm@kvack.org>; Sat, 11 Apr 2015 14:40:57 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id gw3si8714832pac.117.2015.04.11.14.40.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Apr 2015 14:40:56 -0700 (PDT)
Received: by paboj16 with SMTP id oj16so59158258pab.0
        for <linux-mm@kvack.org>; Sat, 11 Apr 2015 14:40:55 -0700 (PDT)
Date: Sat, 11 Apr 2015 14:40:46 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 4/4] mm: make every pte dirty on do_swap_page
In-Reply-To: <1426036838-18154-4-git-send-email-minchan@kernel.org>
Message-ID: <alpine.LSU.2.11.1504111433230.3227@eggly.anvils>
References: <1426036838-18154-1-git-send-email-minchan@kernel.org> <1426036838-18154-4-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mm-commits@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Yalin Wang <Yalin.Wang@sonymobile.com>, Hugh Dickins <hughd@google.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@parallels.com>, Yalin Wang <yalin.wang@sonymobile.com>

On Wed, 11 Mar 2015, Minchan Kim wrote:

> Bascially, MADV_FREE relys on the pte dirty to decide whether
> it allows VM to discard the page. However, if there is swap-in,
> pte pointed out the page has no pte_dirty. So, MADV_FREE checks
> PageDirty and PageSwapCache for those pages to not discard it
> because swapped-in page could live on swap cache or PageDirty
> when it is removed from swapcache.
> 
> The problem in here is that anonymous pages can have PageDirty if
> it is removed from swapcache so that VM cannot parse those pages
> as freeable even if we did madvise_free. Look at below example.
> 
> ptr = malloc();
> memset(ptr);
> ..
> heavy memory pressure -> swap-out all of pages
> ..
> out of memory pressure so there are lots of free pages
> ..
> var = *ptr; -> swap-in page/remove the page from swapcache. so pte_clean
>                but SetPageDirty
> 
> madvise_free(ptr);
> ..
> ..
> heavy memory pressure -> VM cannot discard the page by PageDirty.
> 
> PageDirty for anonymous page aims for avoiding duplicating
> swapping out. In other words, if a page have swapped-in but
> live swapcache(ie, !PageDirty), we could save swapout if the page
> is selected as victim by VM in future because swap device have
> kept previous swapped-out contents of the page.
> 
> So, rather than relying on the PG_dirty for working madvise_free,
> pte_dirty is more straightforward. Inherently, swapped-out page was
> pte_dirty so this patch restores the dirtiness when swap-in fault
> happens so madvise_free doesn't rely on the PageDirty any more.
> 
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Cyrill Gorcunov <gorcunov@gmail.com>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Reported-by: Yalin Wang <yalin.wang@sonymobile.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Sorry, but NAK to this patch,
mm-make-every-pte-dirty-on-do_swap_page.patch in akpm's mm tree
(I hope it hasn't reached linux-next yet).

You may well be right that pte_dirty<->PageDirty can be handled
differently, in a way more favourable to MADV_FREE.  And this patch
may be a step in the right direction, but I've barely given it thought.

As it stands, it segfaults more than any patch I've seen in years:
I just tried applying it to 4.0-rc7-mm1, and running kernel builds
in low memory with swap.  Even if I leave KSM out, and memcg out, and
swapoff out, and THP out, and tmpfs out, it still SIGSEGVs very soon.

I have a choice: spend a few hours tracking down the errors, and
post a fix patch on top of yours?  But even then I'd want to spend
a lot longer thinking through every dirty/Dirty in the source before
I'd feel comfortable to give an ack.

This is users' data, and we need to be very careful with it: errors
in MADV_FREE are one thing, for now that's easy to avoid; but in this
patch you're changing the rules for Anon PageDirty for everyone.

I think for now I'll have to leave it to you to do much more source
diligence and testing, before coming back with a corrected patch for
us then to review, slowly and carefully.

Hugh

> ---
>  mm/madvise.c | 1 -
>  mm/memory.c  | 9 +++++++--
>  mm/rmap.c    | 2 +-
>  mm/vmscan.c  | 3 +--
>  4 files changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 22e8f0c..a045798 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -325,7 +325,6 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>  				continue;
>  			}
>  
> -			ClearPageDirty(page);
>  			unlock_page(page);
>  		}
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index 0f96a4a..40428a5 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2521,9 +2521,14 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  
>  	inc_mm_counter_fast(mm, MM_ANONPAGES);
>  	dec_mm_counter_fast(mm, MM_SWAPENTS);
> -	pte = mk_pte(page, vma->vm_page_prot);
> +
> +	/*
> +	 * Every page swapped-out was pte_dirty so we make pte dirty again.
> +	 * MADV_FREE relies on it.
> +	 */
> +	pte = pte_mkdirty(mk_pte(page, vma->vm_page_prot));
>  	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
> -		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
> +		pte = maybe_mkwrite(pte, vma);
>  		flags &= ~FAULT_FLAG_WRITE;
>  		ret |= VM_FAULT_WRITE;
>  		exclusive = 1;
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 47b3ba8..34c1d66 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1268,7 +1268,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  
>  		if (flags & TTU_FREE) {
>  			VM_BUG_ON_PAGE(PageSwapCache(page), page);
> -			if (!dirty && !PageDirty(page)) {
> +			if (!dirty) {
>  				/* It's a freeable page by MADV_FREE */
>  				dec_mm_counter(mm, MM_ANONPAGES);
>  				goto discard;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 260c413..3357ffa 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -805,8 +805,7 @@ static enum page_references page_check_references(struct page *page,
>  		return PAGEREF_KEEP;
>  	}
>  
> -	if (PageAnon(page) && !pte_dirty && !PageSwapCache(page) &&
> -			!PageDirty(page))
> +	if (PageAnon(page) && !pte_dirty && !PageSwapCache(page))
>  		*freeable = true;
>  
>  	/* Reclaim if clean, defer dirty pages to writeback */
> -- 
> 1.9.3
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
