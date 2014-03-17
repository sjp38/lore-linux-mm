Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 960AF6B007B
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 05:39:41 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so4264266wgh.15
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 02:39:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id oy1si4852306wjb.123.2014.03.17.02.39.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 02:39:39 -0700 (PDT)
Date: Mon, 17 Mar 2014 10:39:37 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/3] vrange: Add purged page detection on setting memory
 non-volatile
Message-ID: <20140317093937.GB2210@quack.suse.cz>
References: <1394822013-23804-1-git-send-email-john.stultz@linaro.org>
 <1394822013-23804-3-git-send-email-john.stultz@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1394822013-23804-3-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dgiani@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri 14-03-14 11:33:32, John Stultz wrote:
> Users of volatile ranges will need to know if memory was discarded.
> This patch adds the purged state tracking required to inform userland
> when it marks memory as non-volatile that some memory in that range
> was purged and needs to be regenerated.
> 
> This simplified implementation which uses some of the logic from
> Minchan's earlier efforts, so credit to Minchan for his work.
  Some minor comments below...

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
> Cc: Dhaval Giani <dgiani@mozilla.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> Cc: Michel Lespinasse <walken@google.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: linux-mm@kvack.org <linux-mm@kvack.org>
> Signed-off-by: John Stultz <john.stultz@linaro.org>
> ---
>  include/linux/swap.h   | 15 +++++++++++--
>  include/linux/vrange.h | 13 ++++++++++++
>  mm/vrange.c            | 57 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 83 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 46ba0c6..18c12f9 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -70,8 +70,19 @@ static inline int current_is_kswapd(void)
>  #define SWP_HWPOISON_NUM 0
>  #endif
>  
> -#define MAX_SWAPFILES \
> -	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
> +
> +/*
> + * Purged volatile range pages
> + */
> +#define SWP_VRANGE_PURGED_NUM 1
> +#define SWP_VRANGE_PURGED (MAX_SWAPFILES + SWP_HWPOISON_NUM + SWP_MIGRATION_NUM)
> +
> +
> +#define MAX_SWAPFILES ((1 << MAX_SWAPFILES_SHIFT)	\
> +				- SWP_MIGRATION_NUM	\
> +				- SWP_HWPOISON_NUM	\
> +				- SWP_VRANGE_PURGED_NUM	\
> +			)
>  
>  /*
>   * Magic header for a swap area. The first part of the union is
> diff --git a/include/linux/vrange.h b/include/linux/vrange.h
> index 652396b..c4a1616 100644
> --- a/include/linux/vrange.h
> +++ b/include/linux/vrange.h
> @@ -1,7 +1,20 @@
>  #ifndef _LINUX_VRANGE_H
>  #define _LINUX_VRANGE_H
>  
> +#include <linux/swap.h>
> +#include <linux/swapops.h>
> +
>  #define VRANGE_NONVOLATILE 0
>  #define VRANGE_VOLATILE 1
>  
> +static inline swp_entry_t swp_entry_mk_vrange_purged(void)
> +{
> +	return swp_entry(SWP_VRANGE_PURGED, 0);
> +}
> +
> +static inline int entry_is_vrange_purged(swp_entry_t entry)
> +{
> +	return swp_type(entry) == SWP_VRANGE_PURGED;
> +}
> +
>  #endif /* _LINUX_VRANGE_H */
> diff --git a/mm/vrange.c b/mm/vrange.c
> index acb4356..844571b 100644
> --- a/mm/vrange.c
> +++ b/mm/vrange.c
> @@ -8,6 +8,60 @@
>  #include <linux/mm_inline.h>
>  #include "internal.h"
>  
> +struct vrange_walker {
> +	struct vm_area_struct *vma;
> +	int pages_purged;
  Maybe call this 'was_page_purged'? To better suggest the value is bool
and not a number of pages... Or make that 'bool' instead of 'int'?

> +};
> +
> +static int vrange_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
> +				struct mm_walk *walk)
> +{
> +	struct vrange_walker *vw = walk->private;
> +	pte_t *pte;
> +	spinlock_t *ptl;
> +
> +	if (pmd_trans_huge(*pmd))
> +		return 0;
> +	if (pmd_trans_unstable(pmd))
> +		return 0;
> +
> +	pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
> +	for (; addr != end; pte++, addr += PAGE_SIZE) {
> +		if (!pte_present(*pte)) {
> +			swp_entry_t vrange_entry = pte_to_swp_entry(*pte);
> +
> +			if (unlikely(entry_is_vrange_purged(vrange_entry))) {
> +				vw->pages_purged = 1;
> +				break;
> +			}
> +		}
> +	}
> +	pte_unmap_unlock(pte - 1, ptl);
> +	cond_resched();
> +
> +	return 0;
> +}
> +
> +static unsigned long vrange_check_purged(struct mm_struct *mm,
  What's the point of this function returning ulong when everything else
expects 'int'?

> +					 struct vm_area_struct *vma,
> +					 unsigned long start,
> +					 unsigned long end)
> +{
> +	struct vrange_walker vw;
> +	struct mm_walk vrange_walk = {
> +		.pmd_entry = vrange_pte_range,
> +		.mm = vma->vm_mm,
> +		.private = &vw,
> +	};
> +	vw.pages_purged = 0;
> +	vw.vma = vma;
> +
> +	walk_page_range(start, end, &vrange_walk);
> +
> +	return vw.pages_purged;
> +
> +}
> +
>  static ssize_t do_vrange(struct mm_struct *mm, unsigned long start,
>  				unsigned long end, int mode, int *purged)
>  {
> @@ -57,6 +111,9 @@ static ssize_t do_vrange(struct mm_struct *mm, unsigned long start,
>  			break;
>  		case VRANGE_NONVOLATILE:
>  			new_flags &= ~VM_VOLATILE;
> +			lpurged |= vrange_check_purged(mm, vma,
> +							vma->vm_start,
> +							vma->vm_end);
  Hum, why don't you actually just call vrange_check_purge() once for the
whole syscall range? walk_page_range() seems to handle multiple vmas just
fine...

>  		}
>  
>  		pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
> -- 
> 1.8.3.2
> 
								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
