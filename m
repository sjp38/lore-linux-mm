Date: Sun, 18 Feb 2007 18:56:35 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: fix xip issue with /dev/zero
In-Reply-To: <1171628558.7328.16.camel@cotte.boeblingen.de.ibm.com>
Message-ID: <Pine.LNX.4.64.0702181855230.16343@blonde.wat.veritas.com>
References: <1171628558.7328.16.camel@cotte.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Carsten Otte <cotte@de.ibm.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, LinusTorvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 16 Feb 2007, Carsten Otte wrote:

> This patch removes usage of ZERO_PAGE for xip. We use our own zeroed
> page for mapping sparse holes to userland now. That gets us rid of
> dependencies with other users of ZERO_PAGE, such as /dev/zero. Thanks to
> Hugh for reporting this issue. I tested this briefly and it seems to
> work fine, please apply.

That's too vague a description of the bug.  The problem was that
a long read from /dev/zero into a private xip mapping would insert the
ZERO_PAGE into the userspace page table, but xip could not distinguish
that from its own use of the ZERO_PAGE where there's a hole: if the
hole gets filled in later, it would wrongly update the private mapping
from the zeroes read there to the data newly written into the file.

> 
> Signed-off-by: Carsten Otte <cotte@de.ibm.com>

Your patch is on the right lines, but not yet correct:
sorry if I misled you when I concentrated on the locking.

> 
> ---
> diff -ruN linux-2.6/mm/filemap_xip.c linux-2.6+fix/mm/filemap_xip.c

Please include the "-p" option in your diff flags, to show what
function each hunk falls in: this is a case where that would have
been helpful.

> --- linux-2.6/mm/filemap_xip.c	2007-02-02 13:02:58.000000000 +0100
> +++ linux-2.6+fix/mm/filemap_xip.c	2007-02-15 15:18:51.000000000 +0100
> @@ -17,6 +17,30 @@
>  #include "filemap.h"
>  
>  /*
> + * We do use our own empty page to avoid interference with other users
> + * of ZERO_PAGE(), such as /dev/zero
> + */
> +static struct page * __xip_sparse_page = NULL;
> +static spinlock_t   xip_alloc_lock = SPIN_LOCK_UNLOCKED;

(You tend to insert too many spaces for kernel CodingStyle,
but filemap_xip.c is already like that, so I won't worry now.)

> +
> +static inline struct page *
> +xip_sparse_page(void)

Leave it to gcc to decide whether this is right to inline,
and put the whole declaration on one line:

static struct page *xip_sparse_page(void)

> +{
> +	unsigned long tmp;
> +
> +	if (!__xip_sparse_page) {
> +		tmp = get_zeroed_page(GFP_KERNEL);

It's rare for a GFP_KERNEL allocation to fail, but it can happen
(last time I looked it could only happen if the calling process
has been chosen for OOM-kill; but details are subject to change).

You do need to allow for the 0 return here, and deal with it
in your callers: proceeding with virt_to_page(0) will turn a
temporary lack of memory into a crash for all subsequent users.

> +		spin_lock(&xip_alloc_lock);
> +		if (!__xip_sparse_page)
> +			__xip_sparse_page = virt_to_page(tmp);
> +		else
> +			free_page (tmp);;
> +		spin_unlock(&xip_alloc_lock);
> +	}
> +	return __xip_sparse_page;
> +}
> +
> +/*
>   * This is a file read routine for execute in place files, and uses
>   * the mapping->a_ops->get_xip_page() function for the actual low-level
>   * stuff.
> @@ -68,7 +92,7 @@
>  		if (unlikely(IS_ERR(page))) {
>  			if (PTR_ERR(page) == -ENODATA) {
>  				/* sparse */
> -				page = ZERO_PAGE(0);
> +				page = xip_sparse_page();
>  			} else {
>  				desc->error = PTR_ERR(page);
>  				goto out;
> @@ -162,7 +186,7 @@
>   * xip_write
>   *
>   * This function walks all vmas of the address_space and unmaps the
> - * ZERO_PAGE when found at pgoff. Should it go in rmap.c?
> + * xip_sparse_page() when found at pgoff.
>   */
>  static void
>  __xip_unmap (struct address_space * mapping,
> @@ -183,7 +207,7 @@
>  		address = vma->vm_start +
>  			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
>  		BUG_ON(address < vma->vm_start || address >= vma->vm_end);
> -		page = ZERO_PAGE(0);
> +		page = xip_sparse_page();

No: "diff -p" would show this one is in __xip_unmap, and here you're
inside spin_lock(&mapping->i_mmap_lock): it is not safe to allocate
a page with GFP_KERNEL here, nor is there any point in doing so.
__xip_unmap should return immediately if __xip_sparse_page has not
yet been set.

>  		pte = page_check_address(page, mm, address, &ptl);
>  		if (pte) {
>  			/* Nuke the page table entry. */
> @@ -245,8 +269,8 @@
>  		/* unmap page at pgoff from all other vmas */
>  		__xip_unmap(mapping, pgoff);
>  	} else {
> -		/* not shared and writable, use ZERO_PAGE() */
> -		page = ZERO_PAGE(0);
> +		/* not shared and writable, use xip_sparse_page() */
> +		page = xip_sparse_page();
>  	}
>  
>  out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
