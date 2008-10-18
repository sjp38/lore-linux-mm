Subject: Re: [patch] mm: fix anon_vma races
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20081018052046.GA26472@wotan.suse.de>
References: <20081016041033.GB10371@wotan.suse.de>
	 <1224285222.10548.22.camel@lappy.programming.kicks-ass.net>
	 <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org>
	 <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org>
	 <alpine.LFD.2.00.0810171801220.3438@nehalem.linux-foundation.org>
	 <20081018013258.GA3595@wotan.suse.de>
	 <alpine.LFD.2.00.0810171846180.3438@nehalem.linux-foundation.org>
	 <20081018022541.GA19018@wotan.suse.de>
	 <alpine.LFD.2.00.0810171949010.3438@nehalem.linux-foundation.org>
	 <20081018052046.GA26472@wotan.suse.de>
Content-Type: text/plain
Date: Sat, 18 Oct 2008 12:38:19 +0200
Message-Id: <1224326299.28131.132.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2008-10-18 at 07:20 +0200, Nick Piggin wrote:

> Index: linux-2.6/mm/rmap.c
> ===================================================================
> --- linux-2.6.orig/mm/rmap.c
> +++ linux-2.6/mm/rmap.c
> @@ -63,32 +63,42 @@ int anon_vma_prepare(struct vm_area_stru
>  	might_sleep();
>  	if (unlikely(!anon_vma)) {
>  		struct mm_struct *mm = vma->vm_mm;
> -		struct anon_vma *allocated, *locked;
> +		struct anon_vma *allocated;
>  
>  		anon_vma = find_mergeable_anon_vma(vma);
>  		if (anon_vma) {
>  			allocated = NULL;
> -			locked = anon_vma;
> -			spin_lock(&locked->lock);
>  		} else {
>  			anon_vma = anon_vma_alloc();
>  			if (unlikely(!anon_vma))
>  				return -ENOMEM;
>  			allocated = anon_vma;
> -			locked = NULL;
>  		}
>  
> +		/*
> +		 * The lock is required even for new anon_vmas, because as
> +		 * soon as we store vma->anon_vma = anon_vma, then the
> +		 * anon_vma becomes visible via the vma. This means another
> +		 * CPU can find the anon_vma, then store it into the struct
> +		 * page with page_add_anon_rmap. At this point, anon_vma can
> +		 * be loaded from the page with page_lock_anon_vma.
> +		 *
> +		 * So long as the anon_vma->lock is taken before looking at
> +		 * any fields in the anon_vma, the lock should take care of
> +		 * races and memory ordering issues WRT anon_vma fields.
> +		 */
> +		spin_lock(&anon_vma->lock);
> +
>  		/* page_table_lock to protect against threads */
>  		spin_lock(&mm->page_table_lock);
>  		if (likely(!vma->anon_vma)) {
> -			vma->anon_vma = anon_vma;
>  			list_add_tail(&vma->anon_vma_node, &anon_vma->head);
> +			vma->anon_vma = anon_vma;
>  			allocated = NULL;
>  		}
>  		spin_unlock(&mm->page_table_lock);
> +		spin_lock(&anon_vma->lock);

did you perchance mean, spin_unlock() ?

>  
> -		if (locked)
> -			spin_unlock(&locked->lock);
>  		if (unlikely(allocated))
>  			anon_vma_free(allocated);
>  	}
> @@ -171,6 +181,21 @@ static struct anon_vma *page_lock_anon_v
>  
>  	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
>  	spin_lock(&anon_vma->lock);
> +
> +	/*
> +	 * If the page is no longer mapped, we have no way to keep the
> +	 * anon_vma stable. It may be freed and even re-allocated for some
> +	 * other set of anonymous mappings at any point. If the page is
> +	 * mapped while we have the lock on the anon_vma, then we know
> +	 * anon_vma_unlink can't run and garbage collect the anon_vma
> +	 * (because unmapping the page happens before unlinking the anon_vma).
> +	 */
> +	if (unlikely(!page_mapped(page))) {
> +		spin_unlock(&anon_vma->lock);
> +		goto out;
> +	}
> +	BUG_ON(page->mapping != anon_mapping);
> +
>  	return anon_vma;
>  out:
>  	rcu_read_unlock();


fault_creation:

 anon_vma_prepare()
 page_add_new_anon_rmap();

expand_creation:

 anon_vma_prepare()
 anon_vma_lock();

rmap_lookup:

 page_referenced()/try_to_unmap()
   page_lock_anon_vma()

vma_lookup:

 vma_adjust()/vma_*
   vma->anon_vma

teardown:

 unmap_vmas()
   zap_range()
      page_remove_rmap()
      free_page()
 free_pgtables()
   anon_vma_unlink()
   free_range()
  
IOW we remove rmap, free the page (set mapping=NULL) and then unlink and
free the anon_vma.

But at that time vma->anon_vma is still set.


head starts to hurt,.. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
