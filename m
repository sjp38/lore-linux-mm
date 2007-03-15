Date: Thu, 15 Mar 2007 19:49:24 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: fix madvise infinine loop
In-Reply-To: <20070310034942.GB13299@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0703151937350.7795@blonde.wat.veritas.com>
References: <20070310034942.GB13299@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 10 Mar 2007, Nick Piggin wrote:
> 
> This has been noticed when running a particular database server which I
> won't name. Please apply.
> 
> --
> madvise(MADV_REMOVE) can go into an infinite loop or cause an oops if
> the call covers a region from the start of a vma, and extending past that
> vma.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Good find,
Acked-by: Hugh Dickins <hugh@veritas.com>

>From the patch itself, it looks odd that you've added a prev arg to
madvise_remove, which could perfectly well be assigned by the caller.
But you're doing the right thing, to follow the established convention
there.  Or would we do better to preset *prev = vma in madvise_vma,
to prevent a similar error next time?  (No need to delay this fix,
just a question for the future, I'm uncertain.)

Hugh

> 
> Index: linux-2.6.16/mm/madvise.c
> ===================================================================
> --- linux-2.6.16.orig/mm/madvise.c
> +++ linux-2.6.16/mm/madvise.c
> @@ -155,11 +155,14 @@ static long madvise_dontneed(struct vm_a
>   * Other filesystems return -ENOSYS.
>   */
>  static long madvise_remove(struct vm_area_struct *vma,
> +				struct vm_area_struct **prev,
>  				unsigned long start, unsigned long end)
>  {
>  	struct address_space *mapping;
>          loff_t offset, endoff;
>  
> +	*prev = vma;
> +
>  	if (vma->vm_flags & (VM_LOCKED|VM_NONLINEAR|VM_HUGETLB))
>  		return -EINVAL;
>  
> @@ -199,7 +202,7 @@ madvise_vma(struct vm_area_struct *vma, 
>  		error = madvise_behavior(vma, prev, start, end, behavior);
>  		break;
>  	case MADV_REMOVE:
> -		error = madvise_remove(vma, start, end);
> +		error = madvise_remove(vma, prev, start, end);
>  		break;
>  
>  	case MADV_WILLNEED:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
