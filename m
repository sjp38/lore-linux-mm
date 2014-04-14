Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 384746B00CD
	for <linux-mm@kvack.org>; Sun, 13 Apr 2014 22:37:27 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id x10so7491002pdj.23
        for <linux-mm@kvack.org>; Sun, 13 Apr 2014 19:37:25 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id zt8si7963537pbc.144.2014.04.13.19.37.23
        for <linux-mm@kvack.org>;
        Sun, 13 Apr 2014 19:37:25 -0700 (PDT)
Date: Mon, 14 Apr 2014 11:37:56 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/4] mvolatile: Add purged page detection on setting
 memory non-volatile
Message-ID: <20140414023756.GB30991@bbox>
References: <1397247340-3365-1-git-send-email-john.stultz@linaro.org>
 <1397247340-3365-4-git-send-email-john.stultz@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1397247340-3365-4-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Keith Packard <keithp@keithp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Apr 11, 2014 at 01:15:39PM -0700, John Stultz wrote:
> Users of volatile ranges will need to know if memory was discarded.
> This patch adds the purged state tracking required to inform userland
> when it marks memory as non-volatile that some memory in that range
> was purged and needs to be regenerated.
> 
> This simplified implementation which uses some of the logic from
> Minchan's earlier efforts, so credit to Minchan for his work.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Android Kernel Team <kernel-team@android.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Robert Love <rlove@google.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Dave Hansen <dave@sr71.net>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
> Cc: Neil Brown <neilb@suse.de>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Mike Hommey <mh@glandium.org>
> Cc: Taras Glek <tglek@mozilla.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> Cc: Michel Lespinasse <walken@google.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Keith Packard <keithp@keithp.com>
> Cc: linux-mm@kvack.org <linux-mm@kvack.org>
> Acked-by: Jan Kara <jack@suse.cz>
> Signed-off-by: John Stultz <john.stultz@linaro.org>
> ---
>  include/linux/swap.h    |  5 +++
>  include/linux/swapops.h | 10 ++++++
>  mm/mvolatile.c          | 86 +++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 101 insertions(+)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index a90ea95..c372ca7 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -55,6 +55,7 @@ enum {
>  	 * 1<<MAX_SWPFILES_SHIFT), so to preserve the values insert
>  	 * new entries here at the top of the enum, not at the bottom
>  	 */
> +	SWP_MVOLATILE_PURGED_NR,
>  #ifdef CONFIG_MEMORY_FAILURE
>  	SWP_HWPOISON_NR,
>  #endif
> @@ -81,6 +82,10 @@ enum {
>  #define SWP_HWPOISON		(MAX_SWAPFILES + SWP_HWPOISON_NR)
>  #endif
>  
> +/*
> + * Purged volatile range pages
> + */
> +#define SWP_MVOLATILE_PURGED	(MAX_SWAPFILES + SWP_MVOLATILE_PURGED_NR)
>  
>  /*
>   * Magic header for a swap area. The first part of the union is
> diff --git a/include/linux/swapops.h b/include/linux/swapops.h
> index c0f7526..fe9c026 100644
> --- a/include/linux/swapops.h
> +++ b/include/linux/swapops.h
> @@ -161,6 +161,16 @@ static inline int is_write_migration_entry(swp_entry_t entry)
>  
>  #endif
>  
> +static inline swp_entry_t make_purged_entry(void)
> +{
> +	return swp_entry(SWP_MVOLATILE_PURGED, 0);
> +}
> +
> +static inline int is_purged_entry(swp_entry_t entry)
> +{
> +	return swp_type(entry) == SWP_MVOLATILE_PURGED;
> +}
> +
>  #ifdef CONFIG_MEMORY_FAILURE
>  /*
>   * Support for hardware poisoned pages
> diff --git a/mm/mvolatile.c b/mm/mvolatile.c
> index d4d2eed..38c8315 100644
> --- a/mm/mvolatile.c
> +++ b/mm/mvolatile.c
> @@ -12,8 +12,91 @@
>  #include <linux/hugetlb.h>
>  #include <linux/mmu_notifier.h>
>  #include <linux/mm_inline.h>
> +#include <linux/swap.h>
> +#include <linux/swapops.h>
>  #include "internal.h"
>  
> +struct mvolatile_walker {
> +	struct vm_area_struct *vma;
> +	int page_was_purged;
> +};
> +
> +
> +/**
> + * mvolatile_check_purged_pte - Checks ptes for purged pages
> + * @pmd: pmd to walk
> + * @addr: starting address
> + * @end: end address
> + * @walk: mm_walk ptr (contains ptr to mvolatile_walker)
> + *
> + * Iterates over the ptes in the pmd checking if they have
> + * purged swap entries.
> + *
> + * Sets the mvolatile_walker.page_was_purged to 1 if any were purged.

Just nitpick:

This function zaps ptes as well as checking purging so it would be better to
mention it and "Why we should do it" in description.


> + */
> +static int mvolatile_check_purged_pte(pmd_t *pmd, unsigned long addr,
> +					unsigned long end, struct mm_walk *walk)
> +{
> +	struct mvolatile_walker *vw = walk->private;
> +	pte_t *pte;
> +	spinlock_t *ptl;
> +	int ret = 0;
> +
> +	if (pmd_trans_huge(*pmd))
> +		return 0;
> +	if (pmd_trans_unstable(pmd))
> +		return 0;
> +
> +	pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
> +	for (; addr != end; pte++, addr += PAGE_SIZE) {
> +		if (!pte_present(*pte)) {
> +			swp_entry_t mvolatile_entry = pte_to_swp_entry(*pte);
> +
> +			if (unlikely(is_purged_entry(mvolatile_entry))) {
> +
> +				vw->page_was_purged = 1;
> +
> +				/* clear the pte swp entry */
> +				flush_cache_page(vw->vma, addr, pte_pfn(*pte));
> +				ptep_clear_flush(vw->vma, addr, pte);
> +			}
> +		}
> +	}
> +	pte_unmap_unlock(pte - 1, ptl);
> +	cond_resched();
> +
> +	return ret;
> +}
> +
> +
> +/**
> + * mvolatile_check_purged - Sets up a mm_walk to check for purged pages
> + * @vma: ptr to vma we're starting with
> + * @start: start address to walk
> + * @end: end address of walk
> + *
> + * Sets up and calls wa_page_range() to check for purge pages.
> + *
> + * Returns 1 if pages in the range were purged, 0 otherwise.
> + */
> +static int mvolatile_check_purged(struct vm_area_struct *vma,
> +					 unsigned long start,
> +					 unsigned long end)
> +{
> +	struct mvolatile_walker vw;
> +	struct mm_walk mvolatile_walk = {
> +		.pmd_entry = mvolatile_check_purged_pte,
> +		.mm = vma->vm_mm,
> +		.private = &vw,
> +	};
> +	vw.page_was_purged = 0;
> +	vw.vma = vma;
> +
> +	walk_page_range(start, end, &mvolatile_walk);

mvolatile_check_purged_pte could zap *all* of ptes so we need to invalidate
range for mmu_notifier if purge happend.

Anyway, it could make vrange syscall slow and I'm really worry about that.
If we assume most of volatile object which span two page abvoe is purged
altogether, just bail out as soon as purged pte found would make syscall
really fast.

Any idea? It's not necessary to implement it right now but if we don't
have a good idea(ie, syscall itself is very slow), I'm not sure how it
could be effectively useful for userspace folks.


> +
> +	return vw.page_was_purged;
> +
> +}
>  
>  /**
>   * do_mvolatile - Marks or clears VMAs in the range (start-end) as VM_VOLATILE
> @@ -119,6 +202,9 @@ success:
>  		vma = prev->vm_next;
>  	}
>  out:
> +	if (count && (mode == MVOLATILE_NONVOLATILE))
> +		*purged = mvolatile_check_purged(vma, orig_start,
> +							orig_start+count);
>  	up_write(&mm->mmap_sem);
>  
>  	/* report bytes successfully marked, even if we're exiting on error */
> -- 
> 1.8.3.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
