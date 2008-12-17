Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E0D856B00A2
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 06:38:09 -0500 (EST)
Subject: Re: [PATCH] mm: kill page_queue_congested()
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20081217202547.FF22.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081217202547.FF22.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Wed, 17 Dec 2008 12:39:50 +0100
Message-Id: <1229513990.9487.73.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-12-17 at 20:27 +0900, KOSAKI Motohiro wrote:
> ==
> Subject: [PATCH] mm: kill page_queue_congested()
> 
> page_queue_congested() was introduced at 2002.
> but it is unused until now at all.
> 
> it can be removed.

Or we can hook it up in vmscan, and skip congested pages on high scan
order or something..

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/swapfile.c |   20 --------------------
>  1 file changed, 20 deletions(-)
> 
> Index: b/mm/swapfile.c
> ===================================================================
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1203,26 +1203,6 @@ out:
>  	return ret;
>  }
>  
> -#if 0	/* We don't need this yet */
> -#include <linux/backing-dev.h>
> -int page_queue_congested(struct page *page)
> -{
> -	struct backing_dev_info *bdi;
> -
> -	BUG_ON(!PageLocked(page));	/* It pins the swap_info_struct */
> -
> -	if (PageSwapCache(page)) {
> -		swp_entry_t entry = { .val = page_private(page) };
> -		struct swap_info_struct *sis;
> -
> -		sis = get_swap_info_struct(swp_type(entry));
> -		bdi = sis->bdev->bd_inode->i_mapping->backing_dev_info;
> -	} else
> -		bdi = page->mapping->backing_dev_info;
> -	return bdi_write_congested(bdi);
> -}
> -#endif
> -
>  asmlinkage long sys_swapoff(const char __user * specialfile)
>  {
>  	struct swap_info_struct * p = NULL;
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
