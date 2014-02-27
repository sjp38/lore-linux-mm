Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7B2106B0031
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 16:47:14 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id bj1so3053777pad.31
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 13:47:14 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ey10si564368pab.256.2014.02.27.13.47.13
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 13:47:13 -0800 (PST)
Date: Thu, 27 Feb 2014 13:47:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv3 2/2] mm: implement ->map_pages for page cache
Message-Id: <20140227134711.329eb3c385098c8bce37c8d1@linux-foundation.org>
In-Reply-To: <1393530827-25450-3-git-send-email-kirill.shutemov@linux.intel.com>
References: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1393530827-25450-3-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 27 Feb 2014 21:53:47 +0200 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> filemap_map_pages() is generic implementation of ->map_pages() for
> filesystems who uses page cache.
> 
> It should be safe to use filemap_map_pages() for ->map_pages() if
> filesystem use filemap_fault() for ->fault().
> 
> ...
>
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1818,6 +1818,7 @@ extern void truncate_inode_pages_range(struct address_space *,
>  
>  /* generic vm_area_ops exported for stackable file systems */
>  extern int filemap_fault(struct vm_area_struct *, struct vm_fault *);
> +extern void filemap_map_pages(struct vm_area_struct *vma, struct vm_fault *vmf);
>  extern int filemap_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf);
>  
>  /* mm/page-writeback.c */
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 7a13f6ac5421..1bc12a96060d 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -33,6 +33,7 @@
>  #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
>  #include <linux/memcontrol.h>
>  #include <linux/cleancache.h>
> +#include <linux/rmap.h>
>  #include "internal.h"
>  
>  #define CREATE_TRACE_POINTS
> @@ -1726,6 +1727,76 @@ page_not_uptodate:
>  }
>  EXPORT_SYMBOL(filemap_fault);
>  
> +void filemap_map_pages(struct vm_area_struct *vma, struct vm_fault *vmf)
> +{
> +	struct radix_tree_iter iter;
> +	void **slot;
> +	struct file *file = vma->vm_file;
> +	struct address_space *mapping = file->f_mapping;
> +	loff_t size;
> +	struct page *page;
> +	unsigned long address = (unsigned long) vmf->virtual_address;
> +	unsigned long addr;
> +	pte_t *pte;
> +
> +	rcu_read_lock();
> +	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, vmf->pgoff) {
> +		if (iter.index > vmf->max_pgoff)
> +			break;
> +repeat:
> +		page = radix_tree_deref_slot(slot);
> +		if (radix_tree_exception(page)) {
> +			if (radix_tree_deref_retry(page))
> +				break;
> +			else
> +				goto next;
> +		}
> +
> +		if (!page_cache_get_speculative(page))
> +			goto repeat;
> +
> +		/* Has the page moved? */
> +		if (unlikely(page != *slot)) {
> +			page_cache_release(page);
> +			goto repeat;
> +		}
> +
> +		if (!PageUptodate(page) ||
> +				PageReadahead(page) ||
> +				PageHWPoison(page))
> +			goto skip;
> +		if (!trylock_page(page))
> +			goto skip;
> +
> +		if (page->mapping != mapping || !PageUptodate(page))
> +			goto unlock;
> +
> +		size = i_size_read(mapping->host) + PAGE_CACHE_SIZE - 1;

Could perhaps use round_up here.

> +		if (page->index >= size	>> PAGE_CACHE_SHIFT)
> +			goto unlock;
> +		pte = vmf->pte + page->index - vmf->pgoff;
> +		if (!pte_none(*pte))
> +			goto unlock;
> +
> +		if (file->f_ra.mmap_miss > 0)
> +			file->f_ra.mmap_miss--;

I'm wondering about this.  We treat every speculative faultahead as a
hit, whether or not userspace will actually touch that page.

What's the effect of this?  To cause the amount of physical readahead
to increase?  But if userspace is in fact touching the file in a sparse
random fashion, that is exactly the wrong thing to do?

> +		addr = address + (page->index - vmf->pgoff) * PAGE_SIZE;
> +		do_set_pte(vma, addr, page, pte, false, false);
> +		unlock_page(page);
> +		goto next;
> +unlock:
> +		unlock_page(page);
> +skip:
> +		page_cache_release(page);
> +next:
> +		if (page->index == vmf->max_pgoff)
> +			break;
> +	}
> +	rcu_read_unlock();
> +}
> +EXPORT_SYMBOL(filemap_map_pages);
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
