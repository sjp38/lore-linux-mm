Date: Fri, 17 Oct 2008 14:42:56 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch][rfc] mm: have expand_stack honour VM_LOCKED
In-Reply-To: <20081017050120.GA28605@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0810171416090.3111@blonde.site>
References: <20081017050120.GA28605@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Oct 2008, Nick Piggin wrote:

> Is this valid?

Well.  I find it really hard to get excited about the case of
a stack fault more than a page below the current stack pointer not
faulting in the intervening untouched pages when the stack is mlocked.

(That's what it amounts to, isn't it? though your description doesn't
make that at all clear.)

Do you have a case where it actually matters e.g. does get_user_pages
or something like it assume that every page in a VM_LOCKED area must
already be present?  Or do you worry that we might easily add such
an assumption?

I don't think your patch is wrong, but I'd feel a wee bit safer just
to leave things as is: somehow, I prefer the idea of the arch fault
routines faulting in the (normal case) one page for themselves, than
it happening underneath them in make_pages_present's get_user_pages.

One minor (ha ha) defect of doing it your way is that the minor fault
will get counted twice.

But I don't feel strongly about it.

Hugh

> 
> It appears that direct callers of expand_stack may not properly lock the newly
> expanded stack if they don't call make_pages_present (page fault handlers do
> this).

They do the don't.

> 
> Catch all these cases by moving make_pages_present to expand_stack.
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
