Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6F8716B006A
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 11:35:06 -0500 (EST)
Date: Wed, 18 Nov 2009 16:34:51 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH]  [for mmotm-1113] mm: Simplify try_to_unmap_one()
In-Reply-To: <20091117173759.3DF6.A69D9226@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0911181633120.29205@sister.anvils>
References: <20091117173759.3DF6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Nov 2009, KOSAKI Motohiro wrote:

> SWAP_MLOCK mean "We marked the page as PG_MLOCK, please move it to
> unevictable-lru". So, following code is easy confusable.
> 
>         if (vma->vm_flags & VM_LOCKED) {
>                 ret = SWAP_MLOCK;
>                 goto out_unmap;
>         }
> 
> Plus, if the VMA doesn't have VM_LOCKED, We don't need to check
> the needed of calling mlock_vma_page().
> 
> Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

> ---
>  mm/rmap.c |   26 +++++++++++++-------------
>  1 files changed, 13 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 82e31fb..70dec01 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -779,10 +779,9 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  	 * skipped over this mm) then we should reactivate it.
>  	 */
>  	if (!(flags & TTU_IGNORE_MLOCK)) {
> -		if (vma->vm_flags & VM_LOCKED) {
> -			ret = SWAP_MLOCK;
> -			goto out_unmap;
> -		}
> +		if (vma->vm_flags & VM_LOCKED)
> +			goto out_mlock;
> +
>  		if (TTU_ACTION(flags) == TTU_MUNLOCK)
>  			goto out_unmap;
>  	}
> @@ -855,18 +854,19 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  
>  out_unmap:
>  	pte_unmap_unlock(pte, ptl);
> +out:
> +	return ret;
>  
> -	if (ret == SWAP_MLOCK) {
> -		ret = SWAP_AGAIN;
> -		if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
> -			if (vma->vm_flags & VM_LOCKED) {
> -				mlock_vma_page(page);
> -				ret = SWAP_MLOCK;
> -			}
> -			up_read(&vma->vm_mm->mmap_sem);
> +out_mlock:
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
