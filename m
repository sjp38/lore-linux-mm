Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3F7906B01BC
	for <linux-mm@kvack.org>; Wed, 26 May 2010 16:30:18 -0400 (EDT)
Subject: Re: [PATCH 2/5] change direct call of spin_lock(anon_vma->lock) to
	inline function
From: Larry Woodman <lwoodman@redhat.com>
In-Reply-To: <20100526153926.1272945b@annuminas.surriel.com>
References: <20100526153819.6e5cec0d@annuminas.surriel.com>
	 <20100526153926.1272945b@annuminas.surriel.com>
Content-Type: text/plain
Date: Wed, 26 May 2010 16:33:58 -0400
Message-Id: <1274906038.20515.107.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-05-26 at 15:39 -0400, Rik van Riel wrote:
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
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Tested and Acked-by: Larry Woodman <lwoodman@redhat.com>

> ---
>  include/linux/rmap.h |   10 ++++++++++
>  mm/ksm.c             |   18 +++++++++---------
>  mm/migrate.c         |    2 +-
>  mm/mmap.c            |    2 +-
>  mm/rmap.c            |   22 +++++++++++-----------
>  5 files changed, 32 insertions(+), 22 deletions(-)
> 
> Index: linux-2.6.34/include/linux/rmap.h
> ===================================================================
> --- linux-2.6.34.orig/include/linux/rmap.h
> +++ linux-2.6.34/include/linux/rmap.h
> @@ -113,6 +113,16 @@ static inline void vma_unlock_anon_vma(s
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
> Index: linux-2.6.34/mm/ksm.c
> ===================================================================
> --- linux-2.6.34.orig/mm/ksm.c
> +++ linux-2.6.34/mm/ksm.c
> @@ -327,7 +327,7 @@ static void drop_anon_vma(struct rmap_it
>  
>  	if (atomic_dec_and_lock(&anon_vma->external_refcount, &anon_vma->lock)) {
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
> Index: linux-2.6.34/mm/mmap.c
> ===================================================================
> --- linux-2.6.34.orig/mm/mmap.c
> +++ linux-2.6.34/mm/mmap.c
> @@ -2589,7 +2589,7 @@ static void vm_unlock_anon_vma(struct an
>  		if (!__test_and_clear_bit(0, (unsigned long *)
>  					  &anon_vma->head.next))
>  			BUG();
> -		spin_unlock(&anon_vma->lock);
> +		anon_vma_unlock(anon_vma);
>  	}
>  }
>  
> Index: linux-2.6.34/mm/rmap.c
> ===================================================================
> --- linux-2.6.34.orig/mm/rmap.c
> +++ linux-2.6.34/mm/rmap.c
> @@ -134,7 +134,7 @@ int anon_vma_prepare(struct vm_area_stru
>  			allocated = anon_vma;
>  		}
>  
> -		spin_lock(&anon_vma->lock);
> +		anon_vma_lock(anon_vma);
>  		/* page_table_lock to protect against threads */
>  		spin_lock(&mm->page_table_lock);
>  		if (likely(!vma->anon_vma)) {
> @@ -147,7 +147,7 @@ int anon_vma_prepare(struct vm_area_stru
>  			avc = NULL;
>  		}
>  		spin_unlock(&mm->page_table_lock);
> -		spin_unlock(&anon_vma->lock);
> +		anon_vma_unlock(anon_vma);
>  
>  		if (unlikely(allocated))
>  			anon_vma_free(allocated);
> @@ -170,9 +170,9 @@ static void anon_vma_chain_link(struct v
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
> @@ -246,12 +246,12 @@ static void anon_vma_unlink(struct anon_
>  	if (!anon_vma)
>  		return;
>  
> -	spin_lock(&anon_vma->lock);
> +	anon_vma_lock(anon_vma);
>  	list_del(&anon_vma_chain->same_anon_vma);
>  
>  	/* We must garbage collect the anon_vma if it's empty */
>  	empty = list_empty(&anon_vma->head) && !anonvma_external_refcount(anon_vma);
> -	spin_unlock(&anon_vma->lock);
> +	anon_vma_unlock(anon_vma);
>  
>  	if (empty)
>  		anon_vma_free(anon_vma);
> @@ -303,10 +303,10 @@ again:
>  		goto out;
>  
>  	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
> -	spin_lock(&anon_vma->lock);
> +	anon_vma_lock(anon_vma);
>  
>  	if (page_rmapping(page) != anon_vma) {
> -		spin_unlock(&anon_vma->lock);
> +		anon_vma_unlock(anon_vma);
>  		goto again;
>  	}
>  
> @@ -318,7 +318,7 @@ out:
>  
>  void page_unlock_anon_vma(struct anon_vma *anon_vma)
>  {
> -	spin_unlock(&anon_vma->lock);
> +	anon_vma_unlock(anon_vma);
>  	rcu_read_unlock();
>  }
>  
> @@ -1396,7 +1396,7 @@ static int rmap_walk_anon(struct page *p
>  	anon_vma = page_anon_vma(page);
>  	if (!anon_vma)
>  		return ret;
> -	spin_lock(&anon_vma->lock);
> +	anon_vma_lock(anon_vma);
>  	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
>  		struct vm_area_struct *vma = avc->vma;
>  		unsigned long address = vma_address(page, vma);
> @@ -1406,7 +1406,7 @@ static int rmap_walk_anon(struct page *p
>  		if (ret != SWAP_AGAIN)
>  			break;
>  	}
> -	spin_unlock(&anon_vma->lock);
> +	anon_vma_unlock(anon_vma);
>  	return ret;
>  }
>  
> Index: linux-2.6.34/mm/migrate.c
> ===================================================================
> --- linux-2.6.34.orig/mm/migrate.c
> +++ linux-2.6.34/mm/migrate.c
> @@ -684,7 +684,7 @@ rcu_unlock:
>  	/* Drop an anon_vma reference if we took one */
>  	if (anon_vma && atomic_dec_and_lock(&anon_vma->external_refcount, &anon_vma->lock)) {
>  		int empty = list_empty(&anon_vma->head);
> -		spin_unlock(&anon_vma->lock);
> +		anon_vma_unlock(anon_vma);
>  		if (empty)
>  			anon_vma_free(anon_vma);
>  	}
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
