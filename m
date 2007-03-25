In-reply-to: <1174824756.5149.29.camel@lappy> (message from Peter Zijlstra on
	Sun, 25 Mar 2007 14:12:36 +0200)
Subject: Re: [patch 3/3] update ctime and mtime for mmaped write
References: <E1HVEOB-0006fX-00@dorka.pomaz.szeredi.hu>
	 <E1HVERx-0006gx-00@dorka.pomaz.szeredi.hu> <1174824756.5149.29.camel@lappy>
Message-Id: <E1HVZwW-0008SG-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Sun, 25 Mar 2007 23:08:00 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> A few comments..

Thanks for reviewing.

> > Index: linux-2.6.21-rc4-mm1/mm/rmap.c
> > ===================================================================
> > --- linux-2.6.21-rc4-mm1.orig/mm/rmap.c	2007-03-24 19:03:11.000000000 +0100
> > +++ linux-2.6.21-rc4-mm1/mm/rmap.c	2007-03-24 19:34:30.000000000 +0100
> > @@ -507,6 +507,43 @@ int page_mkclean(struct page *page)
> >  EXPORT_SYMBOL_GPL(page_mkclean);
> >  
> >  /**
> > + * test_clear_page_modified - check and clear the dirty bit for all mappings of a page
> > + * @page:	the page to check
> > + */
> > +bool test_clear_page_modified(struct page *page)
> > +{
> > +	struct address_space *mapping = page->mapping;
> 
> page_mapping(page)? Otherwise that BUG_ON(!mapping) a few lines down
> isn't of much use.

OK, removed BUG_ON().  This is called with page locked and mapping
checked, so there's no need to use page_mapping().

> > +	spin_lock(&mapping->i_mmap_lock);
> > +	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
> > +		if (vma->vm_flags & VM_SHARED) {
> > +			struct mm_struct *mm = vma->vm_mm;
> > +			unsigned long addr = vma_address(page, vma);
> > +			pte_t *pte;
> > +			spinlock_t *ptl;
> > +
> > +			if (addr != -EFAULT &&
> > +			    (pte = page_check_address(page, mm, addr, &ptl))) {
> > +				if (ptep_clear_flush_dirty(vma, addr, pte))
> > +					modified = true;
> > +				pte_unmap_unlock(pte, ptl);
> > +			}
> 
> Its against coding style to do assignments in conditionals.

OK, cleaned up.

> > +	if (page_test_and_clear_dirty(page))
> > +		modified = true;
> > +	return modified;
> > +}
> 
> Why not parametrize page_mkclean() to conditionally wrprotect clean
> pages? Something like:

Well, I don't really like this, because for msync, there's really no
need to do the complex ptep operations.  Using ptep_clear_flush_dirty()
can save a couple of cycles.

> > +	mapping = vma->vm_file->f_mapping;
> > +	modified = test_and_clear_bit(AS_CMTIME, &mapping->flags);
> > +
> > +	pagevec_init(&pvec, 0);
> > +	index = linear_page_index(vma, start);
> > +	end_index = linear_page_index(vma, end);
> > +	while (index < end_index) {
> > +		int i;
> > +		int nr_pages = min(end_index - index, (pgoff_t) PAGEVEC_SIZE);
> > +
> > +		if (mapping_cap_account_dirty(mapping))
> > +			nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
> > +					PAGECACHE_TAG_DIRTY, nr_pages);
> > +		else
> > +			nr_pages = pagevec_lookup(&pvec, mapping, index,
> > +						  nr_pages);
> > +		if (!nr_pages)
> > +			break;
> > +
> > +		for (i = 0; i < nr_pages; i++) {
> > +			struct page *page = pvec.pages[i];
> > +
> > +			/* Skip pages which are just being read */
> > +			if (!PageUptodate(page))
> > +				continue;
> > +
> > +			lock_page(page);
> > +			index = page->index + 1;
> > +			if (page->mapping == mapping &&
> > +			    test_clear_page_modified(page)) {
> 
> page_mkclean(page, 0)
> 
> > +				set_page_dirty(page);
> 
> set_page_dirty_mapping() ?

That would cause the file times to be updated twice, which is wrong.

But if AS_CMTIME were tested/cleared after walking the pages, this
would work.  Fixed.

Also realized, that setting AS_CMTIME from the page fault can also
cause a double update, since the PTE dirty bit is also set there.

And also realized, that doing the file update from munmap can also
cause a double update, if this is not the last mapping of the inode.

Fixed all these in the updated patch.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
