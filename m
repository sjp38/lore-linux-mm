Date: Fri, 23 May 2008 13:31:12 +0100
Subject: Re: [patch 2/2] mm: lockless get_user_pages
Message-ID: <20080523123112.GA9357@shadowen.org>
References: <20080521115929.GB9030@wotan.suse.de> <20080521121114.GC9030@wotan.suse.de> <20080522102753.GA25370@shadowen.org> <20080523022732.GC30209@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080523022732.GC30209@wotan.suse.de>
From: apw@shadowen.org
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, shaggy@austin.ibm.com, axboe@oracle.com, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, May 23, 2008 at 04:27:33AM +0200, Nick Piggin wrote:
[...]
> > >  /*
> > > - * Do a copy-from-user while holding the mmap_semaphore for reading, in a
> > > - * manner safe from deadlocking with simultaneous mmap() (grabbing mmap_sem
> > > - * for writing) and page faulting on the user memory pointed to by src.
> > > - * This assumes that we will very rarely hit the partial != 0 path, or this
> > > - * will not be a win.
> > > - */
> > > -static int copy_from_user_mmap_sem(void *dst, const void __user *src, size_t n)
> > > -{
> > > -	int partial;
> > > -
> > > -	if (!access_ok(VERIFY_READ, src, n))
> > > -		return -EFAULT;
> > > -
> > > -	pagefault_disable();
> > > -	partial = __copy_from_user_inatomic(dst, src, n);
> > > -	pagefault_enable();
> > > -
> > > -	/*
> > > -	 * Didn't copy everything, drop the mmap_sem and do a faulting copy
> > > -	 */
> > > -	if (unlikely(partial)) {
> > > -		up_read(&current->mm->mmap_sem);
> > > -		partial = copy_from_user(dst, src, n);
> > > -		down_read(&current->mm->mmap_sem);
> > > -	}
> > > -
> > > -	return partial;
> > > -}
> > 
> > Why is this optimisation taken out as part of this patch.  From what I
> > an see the caller below does not move to fast_gup so it appears
> > (naively) that this would still be applicable, though the locking may be
> > hard.
> 
> The get_iovec_page_array caller AFAIKS does move to fast_gup.
> 
> That funny optimisation is an attempt to avoid taking and dropping the
> mmap_sem for each page if we can perform the copy without taking a
> fault. If the same conditions exist for fast_gup, then it can perform
> the get_user_pages operation without taking mmap_sem at all.

Yep see below though, the call site for this optimisation seems to go
to copy_from_user ...

> > > -/*
> > >   * Map an iov into an array of pages and offset/length tupples. With the
> > >   * partial_page structure, we can map several non-contiguous ranges into
> > >   * our ones pages[] map instead of splitting that operation into pieces.
> > > @@ -1189,8 +1159,6 @@ static int get_iovec_page_array(const st
> > >  {
> > >  	int buffers = 0, error = 0;
> > >  
> > > -	down_read(&current->mm->mmap_sem);
> > > -
> > >  	while (nr_vecs) {
> > >  		unsigned long off, npages;
> > >  		struct iovec entry;
> > > @@ -1199,7 +1167,7 @@ static int get_iovec_page_array(const st
> > >  		int i;
> > >  
> > >  		error = -EFAULT;
> > > -		if (copy_from_user_mmap_sem(&entry, iov, sizeof(entry)))
> > > +		if (copy_from_user(&entry, iov, sizeof(entry)))
> > >  			break;
> > >  
> > >  		base = entry.iov_base;
> > > @@ -1233,9 +1201,8 @@ static int get_iovec_page_array(const st
> > >  		if (npages > PIPE_BUFFERS - buffers)
> > >  			npages = PIPE_BUFFERS - buffers;
> > >  
> > > -		error = get_user_pages(current, current->mm,
> > > -				       (unsigned long) base, npages, 0, 0,
> > > -				       &pages[buffers], NULL);
> > > +		error = fast_gup((unsigned long)base, npages,
> > > +					0, &pages[buffers]);
> > >  
> > >  		if (unlikely(error <= 0))
> > >  			break;

Its not that clear from these two deltas that it does move to fast_gup,
yes this second one does but the first which used the old optimisation
goes straight to copy_from_user.

[...]
> > native_set_pte_present uses the below form, which does also seem to follow
> > both of these patterns sequentially, so thats ok:
> > 
> >         ptep->pte_low = 0;
> > 	smp_wmb();
> > 	ptep->pte_high = pte.pte_high;
> > 	smp_wmb();
> > 	ptep->pte_low = pte.pte_low;
> 
> That's true... I think this is just for kernel ptes though? So the
> access_ok should keep us away from any of those issues.

Yes I was more saying there is this third case, but it also seems
covered so we don't need to worry on it.

[...]
> > > +static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
> > > +		unsigned long end, int write, struct page **pages, int *nr)
> > > +{
> > > +	unsigned long mask, result;
> > > +	pte_t *ptep;
> > > +
> > > +	result = _PAGE_PRESENT|_PAGE_USER;
> > > +	if (write)
> > > +		result |= _PAGE_RW;
> > > +	mask = result | _PAGE_SPECIAL;
> > > +
> > > +	ptep = pte_offset_map(&pmd, addr);
> > > +	do {
> > > +		pte_t pte = gup_get_pte(ptep);
> > > +		struct page *page;
> > > +
> > > +		if ((pte_val(pte) & mask) != result)
> > > +			return 0;
> > > +		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
> > > +		page = pte_page(pte);
> > > +		get_page(page);
> > > +		pages[*nr] = page;
> > > +		(*nr)++;
> > > +
> > > +	} while (ptep++, addr += PAGE_SIZE, addr != end);
> > > +	pte_unmap(ptep - 1);
> > 
> > Is this pte_unmap right.  I thought you had to unmap the same address
> > that was returned from pte_offset_map, not an incremented version?
> 
> So long as it is within the same pte page, it's OK. Check some of
> the similar loops in mm/memory.c

Bah, yes I missed this in kunmap_atomic()... I hate code mixed into the
declarations:

        unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;

so yes its safe.

[...]
> > > +static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
> > > +		unsigned long end, int write, struct page **pages, int *nr)
> > > +{
> > > +	unsigned long mask;
> > > +	pte_t pte = *(pte_t *)&pmd;
> > > +	struct page *head, *page;
> > > +	int refs;
> > > +
> > > +	mask = _PAGE_PRESENT|_PAGE_USER;
> > > +	if (write)
> > > +		mask |= _PAGE_RW;
> > > +	if ((pte_val(pte) & mask) != mask)
> > > +		return 0;
> > > +	/* hugepages are never "special" */
> > > +	VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
> > 
> > As we am not expecting them to be special could we not check for that anyhow as you do in the normal case.  Safe against anyone changing hugepages.
> 
> Couldn't quite parse this ;) Do you mean to put the same VM_BUG_ON in the
> follow_hugetlb_page path? Sure we could do that, although in that case
> we have everything locked down and have looked up the vma etc. so I was
> just being paranoid here really.

I was more saying, as we know that _PAGE_SPECIAL isn't currently used and
we can only handle the !_PAGE_SPECIAL pages in these paths it might be
prudent to check for the absence of _PAGE_SPECIAL here _anyhow_ exactly
as you did for small pages.  That prevents this code false triggering
should someone later add _PAGE_SPECIAL for hugepages, as they would not
be naturally drawn here to fix it.

[...]
> > I did wonder if we could also check _PAGE_BIT_USER bit as by my reading
> > that would only ever be set on user pages, and by rejecting pages without
> > that set we could prevent any kernel pages being returned basically
> > for free.
> 
> I still do want the access_ok check to avoid any possible issues with
> kernel page table modifications... but checking for the user bit would
> be another good sanity check, good idea. 

Definatly not advocating removing any checks at all.  Just thinking the
addition is one more safety net should any one of the checks be flawed.
Security being a pig to prove at the best of times.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
