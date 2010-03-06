Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6A1EB6B0047
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 21:01:02 -0500 (EST)
Date: Sat, 6 Mar 2010 03:00:48 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] rmap: Fix Bugzilla Bug #5493
Message-ID: <20100306020048.GA16967@cmpxchg.org>
References: <20100305093834.GG17078@lisa.in-ulm.de> <4B9110ED.5000703@redhat.com> <20100306010212.GH17078@lisa.in-ulm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100306010212.GH17078@lisa.in-ulm.de>
Sender: owner-linux-mm@kvack.org
To: Christian Ehrhardt <uni@c--e.de>
Cc: Rik van Riel <riel@redhat.com>, Christian Ehrhardt <lk@c--e.de>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christian,

On Sat, Mar 06, 2010 at 02:02:12AM +0100, Christian Ehrhardt wrote:
> diff --git a/arch/arm/mm/fault-armv.c b/arch/arm/mm/fault-armv.c
> index c9b97e9..4b8d01f 100644
> --- a/arch/arm/mm/fault-armv.c
> +++ b/arch/arm/mm/fault-armv.c
> @@ -117,7 +117,8 @@ make_coherent(struct address_space *mapping, struct vm_area_struct *vma,
>  	 * cache coherency.
>  	 */
>  	flush_dcache_mmap_lock(mapping);
> -	vma_prio_tree_foreach(mpnt, &iter, &mapping->i_mmap, pgoff, pgoff) {
> +	vma_prio_tree_foreach(mpnt, struct vm_area_struct, shared, &iter,
> +				&mapping->i_mmap, pgoff, pgoff) {

How about vma_file_tree_foreach() vs. vma_anon_tree_foreach()?  I found that
to be more descriptive (and it fits the users into a single line again ;).

>  #define INIT_PRIO_TREE_ROOT(ptr)	__INIT_PRIO_TREE_ROOT(ptr, 0)
> -#define INIT_RAW_PRIO_TREE_ROOT(ptr)	__INIT_PRIO_TREE_ROOT(ptr, 1)
> +#define INIT_SHARED_PRIO_TREE_ROOT(ptr)	__INIT_PRIO_TREE_ROOT(ptr, 1)
> +#define INIT_ANON_PRIO_TREE_ROOT(ptr)	__INIT_PRIO_TREE_ROOT(ptr, 2)

SHARED vs. PRIVATE?

> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -207,7 +207,7 @@ static void __remove_shared_vm_struct(struct vm_area_struct *vma,
>  	if (unlikely(vma->vm_flags & VM_NONLINEAR))
>  		list_del_init(&vma->shared.vm_set.list);
>  	else
> -		vma_prio_tree_remove(vma, &mapping->i_mmap);
> +		vma_prio_tree_remove(&vma->shared, &mapping->i_mmap);
>  	flush_dcache_mmap_unlock(mapping);
>  }
>  
> @@ -430,7 +430,7 @@ static void __vma_link_file(struct vm_area_struct *vma)
>  		if (unlikely(vma->vm_flags & VM_NONLINEAR))
>  			vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
>  		else
> -			vma_prio_tree_insert(vma, &mapping->i_mmap);
> +			vma_prio_tree_insert(&vma->shared, &mapping->i_mmap);
>  		flush_dcache_mmap_unlock(mapping);
>  	}
>  }
> @@ -593,9 +593,9 @@ again:			remove_next = 1 + (end > next->vm_end);
>  
>  	if (root) {
>  		flush_dcache_mmap_lock(mapping);
> -		vma_prio_tree_remove(vma, root);
> +		vma_prio_tree_remove(&vma->shared, root);
>  		if (adjust_next)
> -			vma_prio_tree_remove(next, root);
> +			vma_prio_tree_remove(&next->shared, root);
>  	}
>  
>  	vma->vm_start = start;
> @@ -608,8 +608,8 @@ again:			remove_next = 1 + (end > next->vm_end);
>  
>  	if (root) {
>  		if (adjust_next)
> -			vma_prio_tree_insert(next, root);
> -		vma_prio_tree_insert(vma, root);
> +			vma_prio_tree_insert(&next->shared, root);
> +		vma_prio_tree_insert(&vma->shared, root);
>  		flush_dcache_mmap_unlock(mapping);
>  	}

What's with expand_stack()?  This changes the radix index or the heap
index, depending on the direction in which the stack grows, but it
does not adjust the tree and so its order is violated.  Did you make
sure that this is fine?
  
	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
