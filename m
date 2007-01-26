Date: Fri, 26 Jan 2007 21:02:47 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] Don't allow the stack to grow into hugetlb reserved
 regions
In-Reply-To: <20070125214052.22841.33449.stgit@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0701262025590.22196@blonde.wat.veritas.com>
References: <20070125214052.22841.33449.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, William Irwin <wli@holomorphy.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jan 2007, Adam Litke wrote:

> When expanding the stack, we don't currently check if the VMA will cross into
> an area of the address space that is reserved for hugetlb pages.  Subsequent
> faults on the expanded portion of such a VMA will confuse the low-level MMU
> code, resulting in an OOPS.  Check for this.

Good point, and your patch looks good; but a couple of reservations.

Trivial: I'd have preferred your error return to be -ENOMEM like all
the rest there, I can't see a good reason for this one to say -EFAULT.
Though apparently nothing cares just so long as it's non-zero.

Less trivial (and I wonder whether you've come to this from an ia64
or a powerpc direction): I notice that ia64 has more stringent REGION
checks in its ia64_do_page_fault, before calling expand_stack or
expand_upwards.  So on that path, the usual path, I think your
new check in acct_stack_growth is unnecessary on ia64; whereas
coming from the get_user_pages find_extend_vma direction,
your check is inadequate?

I'd dearly like to believe that get_user_pages shouldn't be needing
find_extend_vma (it ends up using the wrong task's rlimits); but last
time I researched that, it looked very deliberate, that ptrace be
allowed to expand the stack - I think there's something out there
which would break if that weren't allowed, but I don't know what.

Hugh

> 
> Signed-off-by: Adam Litke <agl@us.ibm.com>
> ---
> 
>  mm/mmap.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 9717337..2c6b163 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1477,6 +1477,7 @@ static int acct_stack_growth(struct vm_area_struct * vma, unsigned long size, un
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	struct rlimit *rlim = current->signal->rlim;
> +	unsigned long new_start;
>  
>  	/* address space limit tests */
>  	if (!may_expand_vm(mm, grow))
> @@ -1496,6 +1497,12 @@ static int acct_stack_growth(struct vm_area_struct * vma, unsigned long size, un
>  			return -ENOMEM;
>  	}
>  
> +	/* Check to make the stack will not grow into a hugetlb-only region. */
> +	new_start = (vma->vm_flags & VM_GROWSUP) ? vma->vm_start :
> +			vma->vm_end - size;
> +	if (is_hugepage_only_range(vma->vm_mm, new_start, size))
> +		return -EFAULT;
> +
>  	/*
>  	 * Overcommit..  This must be the final test, as it will
>  	 * update security statistics.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
