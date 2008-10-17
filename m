Subject: Re: [patch][rfc] mm: have expand_stack honour VM_LOCKED
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20081017050120.GA28605@wotan.suse.de>
References: <20081017050120.GA28605@wotan.suse.de>
Content-Type: text/plain
Date: Fri, 17 Oct 2008 08:48:18 -0400
Message-Id: <1224247698.1736.22.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-10-17 at 07:01 +0200, Nick Piggin wrote:
> Is this valid?
> 
??? not sure I can answer that, however...
> 
> It appears that direct callers of expand_stack may not properly lock the newly
> expanded stack if they don't call make_pages_present (page fault handlers do
> this).
> 
> Catch all these cases by moving make_pages_present to expand_stack.

in current -mm/mmotm [and, I hope, upstream soon?] we've replaced
make_pages_present() with mlock_vma_pages_range() [sound familiar? :)]
when we want to populate an mlocked range.  Vis a vis stack locking, see
find_extend_vma() in mmotm.  The patch is:
mmap-handle-mlocked-pages-during-map-remap-unmap.patch
and the plethora of unfolded tweaks thereto.

If there's any chance of the unevictable lru patches making the .28
merge window [Andrew?], you might want to recast this patch atop mmotm.
But, if you do decide to leave it as make_pages_present(), we'll "cull"
them during reclaim.  We'll just have to do a little extra work that
could have been avoided by using mlock_vma_pages_range() in
expand_stack().  

Lee

> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
> Index: linux-2.6/mm/mmap.c
> ===================================================================
> --- linux-2.6.orig/mm/mmap.c
> +++ linux-2.6/mm/mmap.c
> @@ -1590,6 +1590,7 @@ static inline
>  #endif
>  int expand_upwards(struct vm_area_struct *vma, unsigned long address)
>  {
> +	unsigned long grow = 0;
>  	int error;
>  
>  	if (!(vma->vm_flags & VM_GROWSUP))
> @@ -1619,7 +1620,7 @@ int expand_upwards(struct vm_area_struct
>  
>  	/* Somebody else might have raced and expanded it already */
>  	if (address > vma->vm_end) {
> -		unsigned long size, grow;
> +		unsigned long size;
>  
>  		size = address - vma->vm_start;
>  		grow = (address - vma->vm_end) >> PAGE_SHIFT;
> @@ -1629,6 +1630,11 @@ int expand_upwards(struct vm_area_struct
>  			vma->vm_end = address;
>  	}
>  	anon_vma_unlock(vma);
> +
> +	if (grow && vma->vm_flags & VM_LOCKED)
> +		make_pages_present(vma->vm_end - (grow << PAGE_SHIFT),
> +								vma->vm_end);
> +
>  	return error;
>  }
>  #endif /* CONFIG_STACK_GROWSUP || CONFIG_IA64 */
> @@ -1639,6 +1645,7 @@ int expand_upwards(struct vm_area_struct
>  static inline int expand_downwards(struct vm_area_struct *vma,
>  				   unsigned long address)
>  {
> +	unsigned long grow = 0;
>  	int error;
>  
>  	/*
> @@ -1663,7 +1670,7 @@ static inline int expand_downwards(struc
>  
>  	/* Somebody else might have raced and expanded it already */
>  	if (address < vma->vm_start) {
> -		unsigned long size, grow;
> +		unsigned long size;
>  
>  		size = vma->vm_end - address;
>  		grow = (vma->vm_start - address) >> PAGE_SHIFT;
> @@ -1675,6 +1682,11 @@ static inline int expand_downwards(struc
>  		}
>  	}
>  	anon_vma_unlock(vma);
> +
> +	if (grow && vma->vm_flags & VM_LOCKED)
> +		make_pages_present(vma->vm_start,
> +				vma->vm_start + (grow << PAGE_SHIFT));
> +
>  	return error;
>  }
>  
> @@ -1700,8 +1712,6 @@ find_extend_vma(struct mm_struct *mm, un
>  		return vma;
>  	if (!prev || expand_stack(prev, addr))
>  		return NULL;
> -	if (prev->vm_flags & VM_LOCKED)
> -		make_pages_present(addr, prev->vm_end);
>  	return prev;
>  }
>  #else
> @@ -1727,8 +1737,6 @@ find_extend_vma(struct mm_struct * mm, u
>  	start = vma->vm_start;
>  	if (expand_stack(vma, addr))
>  		return NULL;
> -	if (vma->vm_flags & VM_LOCKED)
> -		make_pages_present(addr, start);
>  	return vma;
>  }
>  #endif
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
