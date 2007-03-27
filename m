Date: Tue, 27 Mar 2007 18:07:53 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC] [patch] mm: fix xip issue with /dev/zero
In-Reply-To: <1175009868.8401.8.camel@cotte.boeblingen.de.ibm.com>
Message-ID: <Pine.LNX.4.64.0703271748010.29398@blonde.wat.veritas.com>
References: <1171628558.7328.16.camel@cotte.boeblingen.de.ibm.com>
 <Pine.LNX.4.64.0702181855230.16343@blonde.wat.veritas.com>
 <1172513050.5685.21.camel@cotte.boeblingen.de.ibm.com>
 <Pine.LNX.4.64.0703011808440.13472@blonde.wat.veritas.com>
 <1175009868.8401.8.camel@cotte.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Carsten Otte <cotte@de.ibm.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Mar 2007, Carsten Otte wrote:
> Am Donnerstag, den 01.03.2007, 18:59 +0000 schrieb Hugh Dickins:
> > Still not quite right, so I took your patch and reworked it below:
> > if you agree with that version, please send it on to akpm.
> Sorry for my late reply.

I am the last person anyone should apologize to for lateness!

> The patch does'nt apply on -mm anymore, because
> filemap_xip now uses fault instead of nopage. I modified your patch
> again to fit on current -mm. Did I miss something? If no, I will send it
> to Andrew. I've done some basic testing on it, all seems to work well.

Comparing against what I suggested, it looks just right to me:
do go ahead and send Andrew.

But that comparison does show one discrepancy, not in your patch
below, but where Nick and I independently fixed up the "error
reporting".  He interprets one failure of get_xip_page as
VM_FAULT_OOM then the next as VM_FAULT_SIGBUS, where I thought
them both NOPAGE_SIGBUS.

I'm inclined to agree with me on that, though it's hard to tell
without peering into the internals of ->get_xip_page()s.

Hmm, and in looking into that, the whole file seems quite confused
as to whether ->get_xip_page might return NULL page or not: some
places allow for it (one treating it as -EIO, another as -ENOMEM),
others don't allow for it at all.  Something to tidy up.

Hugh

> 
> This patch fixes the bug, that reading into xip mapping from /dev/zero
> fills the user page table with ZERO_PAGE() entries. Later on, xip cannot
> tell which pages have been ZERO_PAGE() filled by access to a sparse
> mapping, and which ones origin from /dev/zero. It will unmap ZERO_PAGE
> from all mappings when filling the sparse hole with data.
> xip does now use its own zeroed page for its sparse mappings.
> 
> Signed-off-by: Carsten Otte <cotte@de.ibm.com>
> ---
> 
> --- linux-2.6.21-rc5-mm2/mm/filemap_xip.c	2007-03-27 12:51:22.000000000 +0200
> +++ linux-2.6.21-rc5-mm2+patch/mm/filemap_xip.c	2007-03-27 15:37:44.000000000 +0200
> @@ -17,6 +17,29 @@
>  #include "filemap.h"
>  
>  /*
> + * We do use our own empty page to avoid interference with other users
> + * of ZERO_PAGE(), such as /dev/zero
> + */
> +static struct page *__xip_sparse_page;
> +
> +static struct page *xip_sparse_page(void)
> +{
> +	if (!__xip_sparse_page) {
> +		unsigned long zeroes = get_zeroed_page(GFP_HIGHUSER);
> +		if (zeroes) {
> +			static DEFINE_SPINLOCK(xip_alloc_lock);
> +			spin_lock(&xip_alloc_lock);
> +			if (!__xip_sparse_page)
> +				__xip_sparse_page = virt_to_page(zeroes);
> +			else
> +				free_page(zeroes);
> +			spin_unlock(&xip_alloc_lock);
> +		}
> +	}
> +	return __xip_sparse_page;
> +}
> +
> +/*
>   * This is a file read routine for execute in place files, and uses
>   * the mapping->a_ops->get_xip_page() function for the actual low-level
>   * stuff.
> @@ -162,7 +185,7 @@
>   * xip_write
>   *
>   * This function walks all vmas of the address_space and unmaps the
> - * ZERO_PAGE when found at pgoff. Should it go in rmap.c?
> + * __xip_sparse_page when found at pgoff.
>   */
>  static void
>  __xip_unmap (struct address_space * mapping,
> @@ -177,13 +200,16 @@
>  	spinlock_t *ptl;
>  	struct page *page;
>  
> +	page = __xip_sparse_page;
> +	if (!page)
> +		return;
> +
>  	spin_lock(&mapping->i_mmap_lock);
>  	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
>  		mm = vma->vm_mm;
>  		address = vma->vm_start +
>  			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
>  		BUG_ON(address < vma->vm_start || address >= vma->vm_end);
> -		page = ZERO_PAGE(0);
>  		pte = page_check_address(page, mm, address, &ptl);
>  		if (pte) {
>  			/* Nuke the page table entry. */
> @@ -245,8 +271,12 @@
>  		/* unmap page at pgoff from all other vmas */
>  		__xip_unmap(mapping, fdata->pgoff);
>  	} else {
> -		/* not shared and writable, use ZERO_PAGE() */
> -		page = ZERO_PAGE(0);
> +		/* not shared and writable, use xip_sparse_page() */
> +		page = xip_sparse_page();
> +		if (!page) {
> +	                fdata->type = VM_FAULT_OOM;
> +	                return NULL;
> +		}
>  	}
>  
>  out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
