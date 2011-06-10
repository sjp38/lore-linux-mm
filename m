Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 182D16B004A
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 22:02:06 -0400 (EDT)
Subject: Re: [PATCH 5/7] tmpfs: simplify prealloc_page
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <alpine.LSU.2.00.1106091535510.2200@sister.anvils>
References: <alpine.LSU.2.00.1106091529060.2200@sister.anvils>
	 <alpine.LSU.2.00.1106091535510.2200@sister.anvils>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 10 Jun 2011 10:02:03 +0800
Message-ID: <1307671323.15392.76.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 2011-06-10 at 06:39 +0800, Hugh Dickins wrote:
> The prealloc_page handling in shmem_getpage_gfp() is unnecessarily
> complicated: first simplify that before going on to filepage/swappage.
> 
> That's right, don't report ENOMEM when the preallocation fails: we may
> or may not need the page.  But simply report ENOMEM once we find we do
> need it, instead of dropping lock, repeating allocation, unwinding on
> failure etc.  And leave the out label on the fast path, don't goto.
> 
> Fix something that looks like a bug but turns out not to be: set
> PageSwapBacked on prealloc_page before its mem_cgroup_cache_charge(),
> as the removed case was doing.  That's important before adding to LRU
> (determines which LRU the page goes on), and does affect which path it
> takes through memcontrol.c, but in the end MEM_CGROUP_CHANGE_TYPE_
> SHMEM is handled no differently from CACHE.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Shaohua Li <shaohua.li@intel.com>
> Cc: "Zhang, Yanmin" <yanmin.zhang@intel.com>
> Cc: Tim Chen <tim.c.chen@linux.intel.com>
> ---
>  mm/shmem.c |   59 ++++++++++++---------------------------------------
>  1 file changed, 15 insertions(+), 44 deletions(-)
> 
> --- linux.orig/mm/shmem.c	2011-06-09 11:39:32.361240481 -0700
> +++ linux/mm/shmem.c	2011-06-09 11:39:42.845292474 -0700
> @@ -1269,9 +1269,9 @@ repeat:
>  			goto failed;
>  		radix_tree_preload_end();
>  		if (sgp != SGP_READ && !prealloc_page) {
> -			/* We don't care if this fails */
>  			prealloc_page = shmem_alloc_page(gfp, info, idx);
>  			if (prealloc_page) {
> +				SetPageSwapBacked(prealloc_page);
>  				if (mem_cgroup_cache_charge(prealloc_page,
>  						current->mm, GFP_KERNEL)) {
>  					page_cache_release(prealloc_page);
> @@ -1403,7 +1403,8 @@ repeat:
>  			goto repeat;
>  		}
>  		spin_unlock(&info->lock);
> -	} else {
> +
> +	} else if (prealloc_page) {
>  		shmem_swp_unmap(entry);
>  		sbinfo = SHMEM_SB(inode->i_sb);
>  		if (sbinfo->max_blocks) {
> @@ -1419,41 +1420,8 @@ repeat:
>  		if (!filepage) {
>  			int ret;
>  
> -			if (!prealloc_page) {
> -				spin_unlock(&info->lock);
> -				filepage = shmem_alloc_page(gfp, info, idx);
> -				if (!filepage) {
> -					spin_lock(&info->lock);
> -					shmem_unacct_blocks(info->flags, 1);
> -					shmem_free_blocks(inode, 1);
> -					spin_unlock(&info->lock);
> -					error = -ENOMEM;
> -					goto failed;
> -				}
> -				SetPageSwapBacked(filepage);
> -
> -				/*
> -				 * Precharge page while we can wait, compensate
> -				 * after
> -				 */
> -				error = mem_cgroup_cache_charge(filepage,
> -					current->mm, GFP_KERNEL);
> -				if (error) {
> -					page_cache_release(filepage);
> -					spin_lock(&info->lock);
> -					shmem_unacct_blocks(info->flags, 1);
> -					shmem_free_blocks(inode, 1);
> -					spin_unlock(&info->lock);
> -					filepage = NULL;
> -					goto failed;
> -				}
> -
> -				spin_lock(&info->lock);
> -			} else {
> -				filepage = prealloc_page;
> -				prealloc_page = NULL;
> -				SetPageSwapBacked(filepage);
> -			}
> +			filepage = prealloc_page;
> +			prealloc_page = NULL;
>  
>  			entry = shmem_swp_alloc(info, idx, sgp, gfp);
>  			if (IS_ERR(entry))
> @@ -1492,11 +1460,19 @@ repeat:
>  		SetPageUptodate(filepage);
>  		if (sgp == SGP_DIRTY)
>  			set_page_dirty(filepage);
> +	} else {
Looks info->lock unlock is missed here.
Otherwise looks good to me.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
