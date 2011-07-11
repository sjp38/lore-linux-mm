Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 520686B004A
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 13:33:34 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p6BHXU1K031874
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 10:33:30 -0700
Received: from iym1 (iym1.prod.google.com [10.241.52.1])
	by hpaq1.eem.corp.google.com with ESMTP id p6BHWKJj027975
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 10:33:29 -0700
Received: by iym1 with SMTP id 1so8126938iym.1
        for <linux-mm@kvack.org>; Mon, 11 Jul 2011 10:33:28 -0700 (PDT)
Date: Mon, 11 Jul 2011 10:33:11 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mmap: Fix and tidy up overcommit page arithmetic
In-Reply-To: <1310348510-16957-1-git-send-email-dmitry.fink@palm.com>
Message-ID: <alpine.LSU.2.00.1107111030480.1752@sister.anvils>
References: <CAEwNFnDRZwSXnVP3EdXqYnNBrumcrihQ+m=N4fb9xouNE=TKRg@mail.gmail.com> <1310348510-16957-1-git-send-email-dmitry.fink@palm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Fink <dmitry.fink@palm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sun, 10 Jul 2011, Dmitry Fink wrote:

> - shmem pages are not immediately available, but they are not
> potentially available either, even if we swap them out, they will
> just relocate from memory into swap, total amount of immediate and
> potentially available memory is not going to be affected, so we
> shouldn't count them as potentially free in the first place.
> 
> - nr_free_pages() is not an expensive operation anymore, there is
> no need to split the decision making in two halves and repeat code.
> 
> Signed-off-by: Dmitry Fink <dmitry.fink@palm.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Acked-by: Hugh Dickins <hughd@google.com>

Just right: thanks a lot for redoing it this way, Dmitry.

> ---
>  mm/mmap.c  |   34 +++++++++++++---------------------
>  mm/nommu.c |   34 +++++++++++++---------------------
>  2 files changed, 26 insertions(+), 42 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index d49736f..a65efd4 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -122,9 +122,17 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
>  		return 0;
>  
>  	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
> -		unsigned long n;
> +		free = global_page_state(NR_FREE_PAGES);
> +		free += global_page_state(NR_FILE_PAGES);
> +
> +		/*
> +		 * shmem pages shouldn't be counted as free in this
> +		 * case, they can't be purged, only swapped out, and
> +		 * that won't affect the overall amount of available
> +		 * memory in the system.
> +		 */
> +		free -= global_page_state(NR_SHMEM);
>  
> -		free = global_page_state(NR_FILE_PAGES);
>  		free += nr_swap_pages;
>  
>  		/*
> @@ -136,34 +144,18 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
>  		free += global_page_state(NR_SLAB_RECLAIMABLE);
>  
>  		/*
> -		 * Leave the last 3% for root
> -		 */
> -		if (!cap_sys_admin)
> -			free -= free / 32;
> -
> -		if (free > pages)
> -			return 0;
> -
> -		/*
> -		 * nr_free_pages() is very expensive on large systems,
> -		 * only call if we're about to fail.
> -		 */
> -		n = nr_free_pages();
> -
> -		/*
>  		 * Leave reserved pages. The pages are not for anonymous pages.
>  		 */
> -		if (n <= totalreserve_pages)
> +		if (free <= totalreserve_pages)
>  			goto error;
>  		else
> -			n -= totalreserve_pages;
> +			free -= totalreserve_pages;
>  
>  		/*
>  		 * Leave the last 3% for root
>  		 */
>  		if (!cap_sys_admin)
> -			n -= n / 32;
> -		free += n;
> +			free -= free / 32;
>  
>  		if (free > pages)
>  			return 0;
> diff --git a/mm/nommu.c b/mm/nommu.c
> index 9edc897..76f2b4b 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -1885,9 +1885,17 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
>  		return 0;
>  
>  	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
> -		unsigned long n;
> +		free = global_page_state(NR_FREE_PAGES);
> +		free += global_page_state(NR_FILE_PAGES);
> +
> +		/*
> +		 * shmem pages shouldn't be counted as free in this
> +		 * case, they can't be purged, only swapped out, and
> +		 * that won't affect the overall amount of available
> +		 * memory in the system.
> +		 */
> +		free -= global_page_state(NR_SHMEM);
>  
> -		free = global_page_state(NR_FILE_PAGES);
>  		free += nr_swap_pages;
>  
>  		/*
> @@ -1899,34 +1907,18 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
>  		free += global_page_state(NR_SLAB_RECLAIMABLE);
>  
>  		/*
> -		 * Leave the last 3% for root
> -		 */
> -		if (!cap_sys_admin)
> -			free -= free / 32;
> -
> -		if (free > pages)
> -			return 0;
> -
> -		/*
> -		 * nr_free_pages() is very expensive on large systems,
> -		 * only call if we're about to fail.
> -		 */
> -		n = nr_free_pages();
> -
> -		/*
>  		 * Leave reserved pages. The pages are not for anonymous pages.
>  		 */
> -		if (n <= totalreserve_pages)
> +		if (free <= totalreserve_pages)
>  			goto error;
>  		else
> -			n -= totalreserve_pages;
> +			free -= totalreserve_pages;
>  
>  		/*
>  		 * Leave the last 3% for root
>  		 */
>  		if (!cap_sys_admin)
> -			n -= n / 32;
> -		free += n;
> +			free -= free / 32;
>  
>  		if (free > pages)
>  			return 0;
> -- 
> 1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
