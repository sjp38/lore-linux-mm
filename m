Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C029D6B004D
	for <linux-mm@kvack.org>; Sun, 15 Nov 2009 17:17:04 -0500 (EST)
Date: Sun, 15 Nov 2009 22:16:54 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 2/6] mm: mlocking in try_to_unmap_one
In-Reply-To: <20091113151554.33C2.A69D9226@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0911152209350.29917@sister.anvils>
References: <Pine.LNX.4.64.0911102142570.2272@sister.anvils>
 <Pine.LNX.4.64.0911102151500.2816@sister.anvils> <20091113151554.33C2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 13 Nov 2009, KOSAKI Motohiro wrote:
> 
> Very small nit. How about this?

Yes, that takes it a stage further, I prefer that, thanks: but better
redo against mmotm, I removed the "MLOCK_PAGES && " in a later patch.

Hugh

> 
> 
> ------------------------------------------------------------
> From 9d4b507572eccf88dcaa02e650df59874216528c Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Fri, 13 Nov 2009 15:00:04 +0900
> Subject: [PATCH] Simplify try_to_unmap_one()
> 
> SWAP_MLOCK mean "We marked the page as PG_MLOCK, please move it to
> unevictable-lru". So, following code is easy confusable.
> 
> 	if (vma->vm_flags & VM_LOCKED) {
> 		ret = SWAP_MLOCK;
> 		goto out_unmap;
> 	}
> 
> Plus, if the VMA doesn't have VM_LOCKED, We don't need to check
> the needed of calling mlock_vma_page().
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/rmap.c |   25 ++++++++++++-------------
>  1 files changed, 12 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 4440a86..81a168c 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -784,10 +784,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  	 * skipped over this mm) then we should reactivate it.
>  	 */
>  	if (!(flags & TTU_IGNORE_MLOCK)) {
> -		if (vma->vm_flags & VM_LOCKED) {
> -			ret = SWAP_MLOCK;
> -			goto out_unmap;
> -		}
> +		if (vma->vm_flags & VM_LOCKED)
> +			goto out_unlock;
>  		if (MLOCK_PAGES && TTU_ACTION(flags) == TTU_MUNLOCK)
>  			goto out_unmap;
>  	}
> @@ -856,18 +854,19 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  
>  out_unmap:
>  	pte_unmap_unlock(pte, ptl);
> +out:
> +	return ret;
>  
> -	if (MLOCK_PAGES && ret == SWAP_MLOCK) {
> -		ret = SWAP_AGAIN;
> -		if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
> -			if (vma->vm_flags & VM_LOCKED) {
> -				mlock_vma_page(page);
> -				ret = SWAP_MLOCK;
> -			}
> -			up_read(&vma->vm_mm->mmap_sem);
> +out_unlock:
> +	pte_unmap_unlock(pte, ptl);
> +
> +	if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
> +		if (vma->vm_flags & VM_LOCKED) {
> +			mlock_vma_page(page);
> +			ret = SWAP_MLOCK;
>  		}
> +		up_read(&vma->vm_mm->mmap_sem);
>  	}
> -out:
>  	return ret;
>  }
>  
> -- 
> 1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
