Date: Sat, 24 May 2008 01:44:32 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/2] mm: lockless get_user_pages
Message-ID: <20080523234432.GD3144@wotan.suse.de>
References: <20080521115929.GB9030@wotan.suse.de> <20080521121114.GC9030@wotan.suse.de> <20080522102753.GA25370@shadowen.org> <20080523022732.GC30209@wotan.suse.de> <20080523123112.GA9357@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080523123112.GA9357@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: apw@shadowen.org
Cc: Andrew Morton <akpm@linux-foundation.org>, shaggy@austin.ibm.com, axboe@oracle.com, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, May 23, 2008 at 01:31:12PM +0100, apw@shadowen.org wrote:
> On Fri, May 23, 2008 at 04:27:33AM +0200, Nick Piggin wrote:
> [...]
> > > Why is this optimisation taken out as part of this patch.  From what I
> > > an see the caller below does not move to fast_gup so it appears
> > > (naively) that this would still be applicable, though the locking may be
> > > hard.
> > 
> > The get_iovec_page_array caller AFAIKS does move to fast_gup.
> > 
> > That funny optimisation is an attempt to avoid taking and dropping the
> > mmap_sem for each page if we can perform the copy without taking a
> > fault. If the same conditions exist for fast_gup, then it can perform
> > the get_user_pages operation without taking mmap_sem at all.
> 
> Yep see below though, the call site for this optimisation seems to go
> to copy_from_user ...
> 
> > > > -/*
> > > >   * Map an iov into an array of pages and offset/length tupples. With the
> > > >   * partial_page structure, we can map several non-contiguous ranges into
> > > >   * our ones pages[] map instead of splitting that operation into pieces.
> > > > @@ -1189,8 +1159,6 @@ static int get_iovec_page_array(const st
> > > >  {
> > > >  	int buffers = 0, error = 0;
> > > >  
> > > > -	down_read(&current->mm->mmap_sem);
> > > > -
> > > >  	while (nr_vecs) {
> > > >  		unsigned long off, npages;
> > > >  		struct iovec entry;
> > > > @@ -1199,7 +1167,7 @@ static int get_iovec_page_array(const st
> > > >  		int i;
> > > >  
> > > >  		error = -EFAULT;
> > > > -		if (copy_from_user_mmap_sem(&entry, iov, sizeof(entry)))
> > > > +		if (copy_from_user(&entry, iov, sizeof(entry)))
> > > >  			break;
> > > >  
> > > >  		base = entry.iov_base;
> > > > @@ -1233,9 +1201,8 @@ static int get_iovec_page_array(const st
> > > >  		if (npages > PIPE_BUFFERS - buffers)
> > > >  			npages = PIPE_BUFFERS - buffers;
> > > >  
> > > > -		error = get_user_pages(current, current->mm,
> > > > -				       (unsigned long) base, npages, 0, 0,
> > > > -				       &pages[buffers], NULL);
> > > > +		error = fast_gup((unsigned long)base, npages,
> > > > +					0, &pages[buffers]);
> > > >  
> > > >  		if (unlikely(error <= 0))
> > > >  			break;
> 
> Its not that clear from these two deltas that it does move to fast_gup,
> yes this second one does but the first which used the old optimisation
> goes straight to copy_from_user.

Oh, the copy_from_user is OK, it is just copying the iovec out from
userspace.

 
> > > > +	pte_unmap(ptep - 1);
> > > 
> > > Is this pte_unmap right.  I thought you had to unmap the same address
> > > that was returned from pte_offset_map, not an incremented version?
> > 
> > So long as it is within the same pte page, it's OK. Check some of
> > the similar loops in mm/memory.c
> 
> Bah, yes I missed this in kunmap_atomic()... I hate code mixed into the
> declarations:
> 
>         unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
> 
> so yes its safe.

Yeah, the convention is a bit ugly, but that's what we've got :P

 
> [...]
> > > > +static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
> > > > +		unsigned long end, int write, struct page **pages, int *nr)
> > > > +{
> > > > +	unsigned long mask;
> > > > +	pte_t pte = *(pte_t *)&pmd;
> > > > +	struct page *head, *page;
> > > > +	int refs;
> > > > +
> > > > +	mask = _PAGE_PRESENT|_PAGE_USER;
> > > > +	if (write)
> > > > +		mask |= _PAGE_RW;
> > > > +	if ((pte_val(pte) & mask) != mask)
> > > > +		return 0;
> > > > +	/* hugepages are never "special" */
> > > > +	VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
> > > 
> > > As we am not expecting them to be special could we not check for that anyhow as you do in the normal case.  Safe against anyone changing hugepages.
> > 
> > Couldn't quite parse this ;) Do you mean to put the same VM_BUG_ON in the
> > follow_hugetlb_page path? Sure we could do that, although in that case
> > we have everything locked down and have looked up the vma etc. so I was
> > just being paranoid here really.
> 
> I was more saying, as we know that _PAGE_SPECIAL isn't currently used and
> we can only handle the !_PAGE_SPECIAL pages in these paths it might be
> prudent to check for the absence of _PAGE_SPECIAL here _anyhow_ exactly
> as you did for small pages.  That prevents this code false triggering
> should someone later add _PAGE_SPECIAL for hugepages, as they would not
> be naturally drawn here to fix it.

I see. Yes that might be a good idea.

 
> [...]
> > > I did wonder if we could also check _PAGE_BIT_USER bit as by my reading
> > > that would only ever be set on user pages, and by rejecting pages without
> > > that set we could prevent any kernel pages being returned basically
> > > for free.
> > 
> > I still do want the access_ok check to avoid any possible issues with
> > kernel page table modifications... but checking for the user bit would
> > be another good sanity check, good idea. 
> 
> Definatly not advocating removing any checks at all.  Just thinking the
> addition is one more safety net should any one of the checks be flawed.
> Security being a pig to prove at the best of times.

It isn't a bad idea at all. I'll see what I can do.

Thanks
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
