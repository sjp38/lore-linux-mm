Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 1E0B46B0007
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 16:27:43 -0500 (EST)
Date: Tue, 5 Feb 2013 13:27:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: introduce __linear_page_index()
Message-Id: <20130205132741.1e1a4e04.akpm@linux-foundation.org>
In-Reply-To: <1360047819-6669-1-git-send-email-b32955@freescale.com>
References: <1360047819-6669-1-git-send-email-b32955@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <b32955@freescale.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 5 Feb 2013 15:03:39 +0800
Huang Shijie <b32955@freescale.com> wrote:

> There are many places we should get the offset(in PAGE_SIZE unit) of
> an address within a non-hugetlb vma.
> 
> In order to simplify the code, add a new helper __linear_page_index()
> to do the work.
> 

Seems nice.

> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -310,15 +310,23 @@ static inline loff_t page_file_offset(struct page *page)
>  extern pgoff_t linear_hugepage_index(struct vm_area_struct *vma,
>  				     unsigned long address);
>  
> -static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
> +/* The offset for an address within a non-hugetlb vma, in PAGE_SIZE unit. */

"The offset into the mapped file for ..."

> +static inline pgoff_t __linear_page_index(struct vm_area_struct *vma,
>  					unsigned long address)
>  {
>  	pgoff_t pgoff;
> +
> +	pgoff = (address - vma->vm_start) >> PAGE_SHIFT;
> +	return pgoff + vma->vm_pgoff;
> +}
> +
> +static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
> +					unsigned long address)
> +{
>  	if (unlikely(is_vm_hugetlb_page(vma)))
>  		return linear_hugepage_index(vma, address);
> -	pgoff = (address - vma->vm_start) >> PAGE_SHIFT;
> -	pgoff += vma->vm_pgoff;
> -	return pgoff >> (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> +	return __linear_page_index(vma, address) >>
> +				(PAGE_CACHE_SHIFT - PAGE_SHIFT);
>  }

I don't think we need bother creating both linear_page_index() and
__linear_page_index().  Realistically, we won't be supporting
PAGE_SHIFT!=PAGE_CACHE_SHIFT.  And most (or all?) of the sites which
you changed should have been using PAGE_CACHE_SHIFT anyway!

> @@ -1201,8 +1199,7 @@ SYSCALL_DEFINE1(shmdt, char __user *, shmaddr)
>  
>  		/* finding a matching vma now does not alter retval */
>  		if ((vma->vm_ops == &shm_vm_ops) &&
> -			(vma->vm_start - addr)/PAGE_SIZE == vma->vm_pgoff)
> -
> +			0 == __linear_page_index(vma, addr))

erk, please don't do this - it makes kernel developers fall over in
shock.  Let's do

			__linear_page_index(vma, addr) == 0

(This won't compile if someone forgets a `=', so the usual reason for
the backward comparison isn't valid).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
