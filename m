Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9EF366B009C
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 12:10:36 -0400 (EDT)
Date: Mon, 28 Sep 2009 11:44:58 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] rmap : tidy the code
In-Reply-To: <1254128590-27826-1-git-send-email-shijie8@gmail.com>
Message-ID: <Pine.LNX.4.64.0909281131460.14446@sister.anvils>
References: <1254128590-27826-1-git-send-email-shijie8@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: Nikita Danilov <danilov@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Sep 2009, Huang Shijie wrote:

> Introduce is_page_mapped_in_vma() to merge the vma_address() and
> page_check_address().
> 
> Make the rmap codes more simple.

There is indeed a recurring pattern there; but personally, I prefer
that recurring pattern, to introducing another multi-argument layer.

I think it would make more sense to do the vma_address() inside (a
differently named) page_check_address(); but that would still have
to return the address, so I'll probably prefer what we have now.

(And that seems to have been Nikita's preference when he introduced
page_check_address(), to keep the vma_address() part of it separate.)

Other opinions?

Hugh

> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>
> ---
>  mm/rmap.c |   59 ++++++++++++++++++++++++++++-------------------------------
>  1 files changed, 28 insertions(+), 31 deletions(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 28aafe2..69e7314 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -307,6 +307,27 @@ pte_t *page_check_address(struct page *page, struct mm_struct *mm,
>  	return NULL;
>  }
>  
> +/*
> + * This helper function checks whether a page is mapped in a VMA.
> + * On success returns 1 with pte mapped and locked.
> + */
> +static inline bool
> +is_page_mapped_in_vma(struct page *page, struct vm_area_struct *vma,
> +		unsigned long *addr, pte_t **ptep, spinlock_t **ptlp, int sync)
> +{
> +	unsigned long address;
> +
> +	address = vma_address(page, vma);
> +	if (address == -EFAULT)
> +		return 0;
> +	*ptep = page_check_address(page, vma->vm_mm, address, ptlp, sync);
> +	if (!(*ptep))
> +		return 0;
> +
> +	*addr = address;
> +	return 1;
> +}
> +
>  /**
>   * page_mapped_in_vma - check whether a page is really mapped in a VMA
>   * @page: the page to test
> @@ -322,14 +343,9 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
>  	pte_t *pte;
>  	spinlock_t *ptl;
>  
> -	address = vma_address(page, vma);
> -	if (address == -EFAULT)		/* out of vma range */
> -		return 0;
> -	pte = page_check_address(page, vma->vm_mm, address, &ptl, 1);
> -	if (!pte)			/* the page is not in this mm */
> +	if (!is_page_mapped_in_vma(page, vma, &address, &pte, &ptl, 1))
>  		return 0;
>  	pte_unmap_unlock(pte, ptl);
> -
>  	return 1;
>  }
>  
> @@ -348,14 +364,8 @@ static int page_referenced_one(struct page *page,
>  	spinlock_t *ptl;
>  	int referenced = 0;
>  
> -	address = vma_address(page, vma);
> -	if (address == -EFAULT)
> -		goto out;
> -
> -	pte = page_check_address(page, mm, address, &ptl, 0);
> -	if (!pte)
> -		goto out;
> -
> +	if (!is_page_mapped_in_vma(page, vma, &address, &pte, &ptl, 0))
> +		return 0;
>  	/*
>  	 * Don't want to elevate referenced for mlocked page that gets this far,
>  	 * in order that it progresses to try_to_unmap and is moved to the
> @@ -388,7 +398,6 @@ static int page_referenced_one(struct page *page,
>  out_unmap:
>  	(*mapcount)--;
>  	pte_unmap_unlock(pte, ptl);
> -out:
>  	if (referenced)
>  		*vm_flags |= vma->vm_flags;
>  	return referenced;
> @@ -543,13 +552,8 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma)
>  	spinlock_t *ptl;
>  	int ret = 0;
>  
> -	address = vma_address(page, vma);
> -	if (address == -EFAULT)
> -		goto out;
> -
> -	pte = page_check_address(page, mm, address, &ptl, 1);
> -	if (!pte)
> -		goto out;
> +	if (!is_page_mapped_in_vma(page, vma, &address, &pte, &ptl, 1))
> +		return 0;
>  
>  	if (pte_dirty(*pte) || pte_write(*pte)) {
>  		pte_t entry;
> @@ -563,7 +567,6 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma)
>  	}
>  
>  	pte_unmap_unlock(pte, ptl);
> -out:
>  	return ret;
>  }
>  
> @@ -770,13 +773,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  	spinlock_t *ptl;
>  	int ret = SWAP_AGAIN;
>  
> -	address = vma_address(page, vma);
> -	if (address == -EFAULT)
> -		goto out;
> -
> -	pte = page_check_address(page, mm, address, &ptl, 0);
> -	if (!pte)
> -		goto out;
> +	if (!is_page_mapped_in_vma(page, vma, &address, &pte, &ptl, 0))
> +		return 0;
>  
>  	/*
>  	 * If the page is mlock()d, we cannot swap it out.
> @@ -855,7 +853,6 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  
>  out_unmap:
>  	pte_unmap_unlock(pte, ptl);
> -out:
>  	return ret;
>  }
>  
> -- 
> 1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
