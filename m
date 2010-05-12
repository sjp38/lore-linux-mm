Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 839966B01E3
	for <linux-mm@kvack.org>; Wed, 12 May 2010 16:58:15 -0400 (EDT)
Date: Wed, 12 May 2010 21:57:54 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/5] rename anon_vma_lock to vma_lock_anon_vma
Message-ID: <20100512205754.GM24989@csn.ul.ie>
References: <20100512133815.0d048a86@annuminas.surriel.com> <20100512133931.14c79d22@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100512133931.14c79d22@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 12, 2010 at 01:39:31PM -0400, Rik van Riel wrote:
> Subject: rename anon_vma_lock to vma_lock_anon_vma
> 
> Rename anon_vma_lock to vma_lock_anon_vma.  This matches the
> naming style used in page_lock_anon_vma and will come in really
> handy further down in this patch series.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
>  include/linux/rmap.h |    4 ++--
>  mm/mmap.c            |   14 +++++++-------
>  2 files changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index d25bd22..88cae59 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -90,14 +90,14 @@ static inline struct anon_vma *page_anon_vma(struct page *page)
>  	return page_rmapping(page);
>  }
>  
> -static inline void anon_vma_lock(struct vm_area_struct *vma)
> +static inline void vma_lock_anon_vma(struct vm_area_struct *vma)
>  {
>  	struct anon_vma *anon_vma = vma->anon_vma;
>  	if (anon_vma)
>  		spin_lock(&anon_vma->lock);
>  }
>  
> -static inline void anon_vma_unlock(struct vm_area_struct *vma)
> +static inline void vma_unlock_anon_vma(struct vm_area_struct *vma)
>  {
>  	struct anon_vma *anon_vma = vma->anon_vma;
>  	if (anon_vma)
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 456ec6f..d30bed3 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -452,12 +452,12 @@ static void vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
>  		spin_lock(&mapping->i_mmap_lock);
>  		vma->vm_truncate_count = mapping->truncate_count;
>  	}
> -	anon_vma_lock(vma);
> +	vma_lock_anon_vma(vma);
>  
>  	__vma_link(mm, vma, prev, rb_link, rb_parent);
>  	__vma_link_file(vma);
>  
> -	anon_vma_unlock(vma);
> +	vma_unlock_anon_vma(vma);
>  	if (mapping)
>  		spin_unlock(&mapping->i_mmap_lock);
>  
> @@ -1710,7 +1710,7 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
>  	 */
>  	if (unlikely(anon_vma_prepare(vma)))
>  		return -ENOMEM;
> -	anon_vma_lock(vma);
> +	vma_lock_anon_vma(vma);
>  
>  	/*
>  	 * vma->vm_start/vm_end cannot change under us because the caller
> @@ -1721,7 +1721,7 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
>  	if (address < PAGE_ALIGN(address+4))
>  		address = PAGE_ALIGN(address+4);
>  	else {
> -		anon_vma_unlock(vma);
> +		vma_unlock_anon_vma(vma);
>  		return -ENOMEM;
>  	}
>  	error = 0;
> @@ -1737,7 +1737,7 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
>  		if (!error)
>  			vma->vm_end = address;
>  	}
> -	anon_vma_unlock(vma);
> +	vma_unlock_anon_vma(vma);
>  	return error;
>  }
>  #endif /* CONFIG_STACK_GROWSUP || CONFIG_IA64 */
> @@ -1762,7 +1762,7 @@ static int expand_downwards(struct vm_area_struct *vma,
>  	if (error)
>  		return error;
>  
> -	anon_vma_lock(vma);
> +	vma_lock_anon_vma(vma);
>  
>  	/*
>  	 * vma->vm_start/vm_end cannot change under us because the caller
> @@ -1783,7 +1783,7 @@ static int expand_downwards(struct vm_area_struct *vma,
>  			vma->vm_pgoff -= grow;
>  		}
>  	}
> -	anon_vma_unlock(vma);
> +	vma_unlock_anon_vma(vma);
>  	return error;
>  }
>  
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
