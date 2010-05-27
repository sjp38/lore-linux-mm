Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A868A600385
	for <linux-mm@kvack.org>; Thu, 27 May 2010 09:48:51 -0400 (EDT)
Received: by pzk11 with SMTP id 11so4073412pzk.28
        for <linux-mm@kvack.org>; Thu, 27 May 2010 06:48:50 -0700 (PDT)
Date: Thu, 27 May 2010 22:48:41 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 3/5] track the root (oldest) anon_vma
Message-ID: <20100527134841.GC2112@barrios-desktop>
References: <20100526153819.6e5cec0d@annuminas.surriel.com>
 <20100526154010.3904df5c@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100526154010.3904df5c@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2010 at 03:40:10PM -0400, Rik van Riel wrote:
> Subject: track the root (oldest) anon_vma
> 
> Track the root (oldest) anon_vma in each anon_vma tree.   Because we only
> take the lock on the root anon_vma, we cannot use the lock on higher-up
> anon_vmas to lock anything.  This makes it impossible to do an indirect
> lookup of the root anon_vma, since the data structures could go away from
> under us.
> 
> However, a direct pointer is safe because the root anon_vma is always the
> last one that gets freed on munmap or exit, by virtue of the same_vma list
> order and unlink_anon_vmas walking the list forward.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Except below one minor type. 

> ---
>  include/linux/rmap.h |    1 +
>  mm/rmap.c            |   18 ++++++++++++++++--
>  2 files changed, 17 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6.34/include/linux/rmap.h
> ===================================================================
> --- linux-2.6.34.orig/include/linux/rmap.h
> +++ linux-2.6.34/include/linux/rmap.h
> @@ -26,6 +26,7 @@
>   */
>  struct anon_vma {
>  	spinlock_t lock;	/* Serialize access to vma list */
> +	struct anon_vma *root;	/* Root of this anon_vma tree */
>  #if defined(CONFIG_KSM) || defined(CONFIG_MIGRATION)
>  
>  	/*
> Index: linux-2.6.34/mm/rmap.c
> ===================================================================
> --- linux-2.6.34.orig/mm/rmap.c
> +++ linux-2.6.34/mm/rmap.c
> @@ -132,6 +132,11 @@ int anon_vma_prepare(struct vm_area_stru
>  			if (unlikely(!anon_vma))
>  				goto out_enomem_free_avc;
>  			allocated = anon_vma;
> +			/*
> +			 * This VMA had no anon_vma yet.  This anon_vma is
> +			 * the root of any anon_vma tree that might form.
> +			 */
> +			anon_vma->root = anon_vma;
>  		}
>  
>  		anon_vma_lock(anon_vma);
> @@ -224,9 +229,15 @@ int anon_vma_fork(struct vm_area_struct 
>  	avc = anon_vma_chain_alloc();
>  	if (!avc)
>  		goto out_error_free_anon_vma;
> -	anon_vma_chain_link(vma, avc, anon_vma);
> +
> +	/*
> +	 * The root anon_vm's spinlock is the lock actually used when we
                    anon_vma's
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
