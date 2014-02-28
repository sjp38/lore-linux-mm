Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id D575B6B004D
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 19:31:41 -0500 (EST)
Received: by mail-we0-f170.google.com with SMTP id w61so1355wes.1
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 16:31:41 -0800 (PST)
Received: from jenni2.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id l41si1997980eew.249.2014.02.27.16.31.40
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 16:31:40 -0800 (PST)
Date: Fri, 28 Feb 2014 02:31:29 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 2/2] mm: implement ->map_pages for page cache
Message-ID: <20140228003129.GD8034@node.dhcp.inet.fi>
References: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1393530827-25450-3-git-send-email-kirill.shutemov@linux.intel.com>
 <20140227134711.329eb3c385098c8bce37c8d1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140227134711.329eb3c385098c8bce37c8d1@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Feb 27, 2014 at 01:47:11PM -0800, Andrew Morton wrote:
> On Thu, 27 Feb 2014 21:53:47 +0200 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > filemap_map_pages() is generic implementation of ->map_pages() for
> > filesystems who uses page cache.
> > 
> > It should be safe to use filemap_map_pages() for ->map_pages() if
> > filesystem use filemap_fault() for ->fault().
> > 
> > ...
> >
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1818,6 +1818,7 @@ extern void truncate_inode_pages_range(struct address_space *,
> >  
> >  /* generic vm_area_ops exported for stackable file systems */
> >  extern int filemap_fault(struct vm_area_struct *, struct vm_fault *);
> > +extern void filemap_map_pages(struct vm_area_struct *vma, struct vm_fault *vmf);
> >  extern int filemap_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf);
> >  
> >  /* mm/page-writeback.c */
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 7a13f6ac5421..1bc12a96060d 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -33,6 +33,7 @@
> >  #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
> >  #include <linux/memcontrol.h>
> >  #include <linux/cleancache.h>
> > +#include <linux/rmap.h>
> >  #include "internal.h"
> >  
> >  #define CREATE_TRACE_POINTS
> > @@ -1726,6 +1727,76 @@ page_not_uptodate:
> >  }
> >  EXPORT_SYMBOL(filemap_fault);
> >  
> > +void filemap_map_pages(struct vm_area_struct *vma, struct vm_fault *vmf)
> > +{
> > +	struct radix_tree_iter iter;
> > +	void **slot;
> > +	struct file *file = vma->vm_file;
> > +	struct address_space *mapping = file->f_mapping;
> > +	loff_t size;
> > +	struct page *page;
> > +	unsigned long address = (unsigned long) vmf->virtual_address;
> > +	unsigned long addr;
> > +	pte_t *pte;
> > +
> > +	rcu_read_lock();
> > +	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, vmf->pgoff) {
> > +		if (iter.index > vmf->max_pgoff)
> > +			break;
> > +repeat:
> > +		page = radix_tree_deref_slot(slot);
> > +		if (radix_tree_exception(page)) {
> > +			if (radix_tree_deref_retry(page))
> > +				break;
> > +			else
> > +				goto next;
> > +		}
> > +
> > +		if (!page_cache_get_speculative(page))
> > +			goto repeat;
> > +
> > +		/* Has the page moved? */
> > +		if (unlikely(page != *slot)) {
> > +			page_cache_release(page);
> > +			goto repeat;
> > +		}
> > +
> > +		if (!PageUptodate(page) ||
> > +				PageReadahead(page) ||
> > +				PageHWPoison(page))
> > +			goto skip;
> > +		if (!trylock_page(page))
> > +			goto skip;
> > +
> > +		if (page->mapping != mapping || !PageUptodate(page))
> > +			goto unlock;
> > +
> > +		size = i_size_read(mapping->host) + PAGE_CACHE_SIZE - 1;
> 
> Could perhaps use round_up here.

Okay, I'll update tomorrow.

> > +		if (page->index >= size	>> PAGE_CACHE_SHIFT)
> > +			goto unlock;
> > +		pte = vmf->pte + page->index - vmf->pgoff;
> > +		if (!pte_none(*pte))
> > +			goto unlock;
> > +
> > +		if (file->f_ra.mmap_miss > 0)
> > +			file->f_ra.mmap_miss--;
> 
> I'm wondering about this.  We treat every speculative faultahead as a
> hit, whether or not userspace will actually touch that page.
> 
> What's the effect of this?  To cause the amount of physical readahead
> to increase?  But if userspace is in fact touching the file in a sparse
> random fashion, that is exactly the wrong thing to do?

IIUC, it will not increase readahead window: readahead recalculate the
window when it hits PageReadahead() and we don't touch these pages.

It can increase number of readahead retry before give up.

I'm not sure what we should do here if anything. We could decrease
->mmap_miss by half of mapped pages or something. But I think
MMAP_LOTSAMISS is pretty arbitrary anyway.

> 
> > +		addr = address + (page->index - vmf->pgoff) * PAGE_SIZE;
> > +		do_set_pte(vma, addr, page, pte, false, false);
> > +		unlock_page(page);
> > +		goto next;
> > +unlock:
> > +		unlock_page(page);
> > +skip:
> > +		page_cache_release(page);
> > +next:
> > +		if (page->index == vmf->max_pgoff)
> > +			break;
> > +	}
> > +	rcu_read_unlock();
> > +}
> > +EXPORT_SYMBOL(filemap_map_pages);
> > +
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
