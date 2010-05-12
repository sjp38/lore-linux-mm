Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 334D16B01EE
	for <linux-mm@kvack.org>; Wed, 12 May 2010 16:58:43 -0400 (EDT)
Date: Wed, 12 May 2010 21:58:21 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/5] change direct call of spin_lock(anon_vma->lock) to
	inline function
Message-ID: <20100512205821.GN24989@csn.ul.ie>
References: <20100512133815.0d048a86@annuminas.surriel.com> <20100512134118.4a261072@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100512134118.4a261072@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 12, 2010 at 01:41:18PM -0400, Rik van Riel wrote:
> Subject: change direct call of spin_lock(anon_vma->lock) to inline function
> 
> Subsitute a direct call of spin_lock(anon_vma->lock) with
> an inline function doing exactly the same.
> 
> This makes it easier to do the substitution to the root
> anon_vma lock in a following patch.
> 
> We will deal with the handful of special locks (nested,
> dec_and_lock, etc) separately.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
>  include/linux/rmap.h |   10 ++++++++++
>  mm/ksm.c             |   18 +++++++++---------
>  mm/mmap.c            |    2 +-
>  mm/rmap.c            |   20 ++++++++++----------
>  4 files changed, 30 insertions(+), 20 deletions(-)
> 
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index 88cae59..72ecd87 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -104,6 +104,16 @@ static inline void vma_unlock_anon_vma(struct vm_area_struct *vma)
>  		spin_unlock(&anon_vma->lock);
>  }
>  
> +static inline void anon_vma_lock(struct anon_vma *anon_vma)
> +{
> +	spin_lock(&anon_vma->lock);
> +}
> +
> +static inline void anon_vma_unlock(struct anon_vma *anon_vma)
> +{
> +	spin_unlock(&anon_vma->lock);
> +}
> +
>  /*
>   * anon_vma helper functions.
>   */
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 956880f..d488012 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -327,7 +327,7 @@ static void drop_anon_vma(struct rmap_item *rmap_item)
>  
>  	if (atomic_dec_and_lock(&anon_vma->ksm_refcount, &anon_vma->lock)) {
>  		int empty = list_empty(&anon_vma->head);
> -		spin_unlock(&anon_vma->lock);
> +		anon_vma_unlock(anon_vma);
>  		if (empty)
>  			anon_vma_free(anon_vma);
>  	}
> @@ -1566,7 +1566,7 @@ again:
>  		struct anon_vma_chain *vmac;
>  		struct vm_area_struct *vma;
>  
> -		spin_lock(&anon_vma->lock);
> +		anon_vma_lock(anon_vma);
>  		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
>  			vma = vmac->vma;
>  			if (rmap_item->address < vma->vm_start ||
> @@ -1589,7 +1589,7 @@ again:
>  			if (!search_new_forks || !mapcount)
>  				break;
>  		}
> -		spin_unlock(&anon_vma->lock);
> +		anon_vma_unlock(anon_vma);
>  		if (!mapcount)
>  			goto out;
>  	}
> @@ -1619,7 +1619,7 @@ again:
>  		struct anon_vma_chain *vmac;
>  		struct vm_area_struct *vma;
>  
> -		spin_lock(&anon_vma->lock);
> +		anon_vma_lock(anon_vma);
>  		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
>  			vma = vmac->vma;
>  			if (rmap_item->address < vma->vm_start ||
> @@ -1637,11 +1637,11 @@ again:
>  			ret = try_to_unmap_one(page, vma,
>  					rmap_item->address, flags);
>  			if (ret != SWAP_AGAIN || !page_mapped(page)) {
> -				spin_unlock(&anon_vma->lock);
> +				anon_vma_unlock(anon_vma);
>  				goto out;
>  			}
>  		}
> -		spin_unlock(&anon_vma->lock);
> +		anon_vma_unlock(anon_vma);
>  	}
>  	if (!search_new_forks++)
>  		goto again;
> @@ -1671,7 +1671,7 @@ again:
>  		struct anon_vma_chain *vmac;
>  		struct vm_area_struct *vma;
>  
> -		spin_lock(&anon_vma->lock);
> +		anon_vma_lock(anon_vma);
>  		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
>  			vma = vmac->vma;
>  			if (rmap_item->address < vma->vm_start ||
> @@ -1688,11 +1688,11 @@ again:
>  
>  			ret = rmap_one(page, vma, rmap_item->address, arg);
>  			if (ret != SWAP_AGAIN) {
> -				spin_unlock(&anon_vma->lock);
> +				anon_vma_unlock(anon_vma);
>  				goto out;
>  			}
>  		}
> -		spin_unlock(&anon_vma->lock);
> +		anon_vma_unlock(anon_vma);
>  	}
>  	if (!search_new_forks++)
>  		goto again;
> diff --git a/mm/mmap.c b/mm/mmap.c
> index d30bed3..f70bc65 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2589,7 +2589,7 @@ static void vm_unlock_anon_vma(struct anon_vma *anon_vma)
>  		if (!__test_and_clear_bit(0, (unsigned long *)
>  					  &anon_vma->head.next))
>  			BUG();
> -		spin_unlock(&anon_vma->lock);
> +		anon_vma_unlock(anon_vma);
>  	}
>  }
>  
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 07fc947..4eb8937 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -134,7 +134,7 @@ int anon_vma_prepare(struct vm_area_struct *vma)
>  			allocated = anon_vma;
>  		}
>  
> -		spin_lock(&anon_vma->lock);
> +		anon_vma_lock(anon_vma);
>  		/* page_table_lock to protect against threads */
>  		spin_lock(&mm->page_table_lock);
>  		if (likely(!vma->anon_vma)) {
> @@ -147,7 +147,7 @@ int anon_vma_prepare(struct vm_area_struct *vma)
>  			avc = NULL;
>  		}
>  		spin_unlock(&mm->page_table_lock);
> -		spin_unlock(&anon_vma->lock);
> +		anon_vma_unlock(anon_vma);
>  
>  		if (unlikely(allocated))
>  			anon_vma_free(allocated);
> @@ -170,9 +170,9 @@ static void anon_vma_chain_link(struct vm_area_struct *vma,
>  	avc->anon_vma = anon_vma;
>  	list_add(&avc->same_vma, &vma->anon_vma_chain);
>  
> -	spin_lock(&anon_vma->lock);
> +	anon_vma_lock(anon_vma);
>  	list_add_tail(&avc->same_anon_vma, &anon_vma->head);
> -	spin_unlock(&anon_vma->lock);
> +	anon_vma_unlock(anon_vma);
>  }
>  
>  /*
> @@ -246,12 +246,12 @@ static void anon_vma_unlink(struct anon_vma_chain *anon_vma_chain)
>  	if (!anon_vma)
>  		return;
>  
> -	spin_lock(&anon_vma->lock);
> +	anon_vma_lock(anon_vma);
>  	list_del(&anon_vma_chain->same_anon_vma);
>  
>  	/* We must garbage collect the anon_vma if it's empty */
>  	empty = list_empty(&anon_vma->head) && !ksm_refcount(anon_vma);
> -	spin_unlock(&anon_vma->lock);
> +	anon_vma_unlock(anon_vma);
>  
>  	if (empty)
>  		anon_vma_free(anon_vma);
> @@ -302,7 +302,7 @@ struct anon_vma *page_lock_anon_vma(struct page *page)
>  		goto out;
>  
>  	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
> -	spin_lock(&anon_vma->lock);
> +	anon_vma_lock(anon_vma);
>  	return anon_vma;
>  out:
>  	rcu_read_unlock();
> @@ -311,7 +311,7 @@ out:
>  
>  void page_unlock_anon_vma(struct anon_vma *anon_vma)
>  {
> -	spin_unlock(&anon_vma->lock);
> +	anon_vma_unlock(anon_vma);
>  	rcu_read_unlock();
>  }
>  
> @@ -1364,7 +1364,7 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
>  	anon_vma = page_anon_vma(page);
>  	if (!anon_vma)
>  		return ret;
> -	spin_lock(&anon_vma->lock);
> +	anon_vma_lock(anon_vma);
>  	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
>  		struct vm_area_struct *vma = avc->vma;
>  		unsigned long address = vma_address(page, vma);
> @@ -1374,7 +1374,7 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
>  		if (ret != SWAP_AGAIN)
>  			break;
>  	}
> -	spin_unlock(&anon_vma->lock);
> +	anon_vma_unlock(anon_vma);
>  	return ret;
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
