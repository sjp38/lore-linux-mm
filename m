Date: Fri, 25 Apr 2008 16:19:00 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC] Reserve huge pages for reliable MAP_PRIVATE hugetlbfs mappings
Message-ID: <20080425151859.GA2094@csn.ul.ie>
References: <20080421183621.GA13100@csn.ul.ie> <20080425142813.GA27530@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080425142813.GA27530@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: wli@holomorphy.com, agl@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (25/04/08 15:28), Andy Whitcroft didst pronounce:
> > <SNIP>
> > 
> > Opinions?
> 
> [This is one of those patches which is best read applied, diff has not
> been friendly to the reviewer.]
> 

Yeah, I noticed that all right. Will see can it be fixed up in a future
revision.

> Overall I think we should be sanitising these semantics.  So I would
> like to see this stack progressed.
> 

Right.

> > <SNIP>
> > +
> > +static void hugetlb_vm_open(struct vm_area_struct *vma)
> > +{
> > +	if (!(vma->vm_flags & VM_MAYSHARE))
> > +		set_vma_resv_huge_pages(vma, 0);
> > +}
> 
> Ok, you zap out the reservation when the VMA is opened.  How does that
> tie in with the VMA modifications which occur when we mprotect a page in
> the middle of a map?
> 

Umm.... Badly.

> From my reading of vma_adjust and vma_split, I am not convinced you
> would maintain the reservation correctly. I suspect that the original
> VMA will retain the whole reservation which it will then not be able to
> use. 

You're right. The only raw of light here is that the reservation should
not leak. On exit, the VMA will be closed and the reserve given back on the
assumption it was pages reserved but not faulted. Not a great consolation,
this is still wrong.

> The new VMAs would not have any reservation and might then fail on
> fault dispite the total reservation being sufficient.
> 

Correct. It would get nailed by this check.

        /*
         * A child process with MAP_PRIVATE mappings created by their parent
         * have no page reserves. This check ensures that reservations are
         * not "stolen". The child may still get SIGKILLed
         */
        if (!(vma->vm_flags & VM_MAYSHARE) &&
                        !vma_resv_huge_pages(vma) &&
                        free_huge_pages - resv_huge_pages == 0)
                return NULL;

I will try altering dup_mmap() to reset the reserves during fork() instead
of vm_ops->open(). The vm_ops->close() should still be ok.

> > +
> > +static void hugetlb_vm_close(struct vm_area_struct *vma)
> > +{
> > +	unsigned long reserve = vma_resv_huge_pages(vma);
> > +	if (reserve)
> > +		hugetlb_acct_memory(-reserve);
> > +}
> > +
> >  struct vm_operations_struct hugetlb_vm_ops = {
> >  	.fault = hugetlb_vm_op_fault,
> > +	.close = hugetlb_vm_close,
> > +	.open = hugetlb_vm_open,
> >  };
> >  
> >  static pte_t make_huge_pte(struct vm_area_struct *vma, struct page *page,
> > @@ -1223,52 +1305,30 @@ static long region_truncate(struct list_
> >  	return chg;
> >  }
> >  
> > -static int hugetlb_acct_memory(long delta)
> > +int hugetlb_reserve_pages(struct inode *inode,
> > +					long from, long to,
> > +					struct vm_area_struct *vma)
> >  {
> > -	int ret = -ENOMEM;
> > +	long ret, chg;
> >  
> > -	spin_lock(&hugetlb_lock);
> >  	/*
> > -	 * When cpuset is configured, it breaks the strict hugetlb page
> > -	 * reservation as the accounting is done on a global variable. Such
> > -	 * reservation is completely rubbish in the presence of cpuset because
> > -	 * the reservation is not checked against page availability for the
> > -	 * current cpuset. Application can still potentially OOM'ed by kernel
> > -	 * with lack of free htlb page in cpuset that the task is in.
> > -	 * Attempt to enforce strict accounting with cpuset is almost
> > -	 * impossible (or too ugly) because cpuset is too fluid that
> > -	 * task or memory node can be dynamically moved between cpusets.
> > -	 *
> > -	 * The change of semantics for shared hugetlb mapping with cpuset is
> > -	 * undesirable. However, in order to preserve some of the semantics,
> > -	 * we fall back to check against current free page availability as
> > -	 * a best attempt and hopefully to minimize the impact of changing
> > -	 * semantics that cpuset has.
> > +	 * Shared mappings and read-only mappings should based their reservation
> > +	 * on the number of pages that are already allocated on behalf of the
> > +	 * file. Private mappings that are writable need to reserve the full
> > +	 * area. Note that a read-only private mapping that subsequently calls
> > +	 * mprotect() to make it read-write may not work reliably
> >  	 */
> > -	if (delta > 0) {
> > -		if (gather_surplus_pages(delta) < 0)
> > -			goto out;
> > -
> > -		if (delta > cpuset_mems_nr(free_huge_pages_node)) {
> > -			return_unused_surplus_pages(delta);
> > -			goto out;
> > -		}
> > +	if (vma->vm_flags & VM_SHARED)
> > +		chg = region_chg(&inode->i_mapping->private_list, from, to);
> > +	else {
> > +		if (vma->vm_flags & VM_MAYWRITE)
> > +			chg = to - from;
> > +		else
> > +			chg = region_chg(&inode->i_mapping->private_list,
> > +								from, to);
> 
> In the read-only case you only create a reservation for the first mmap
> of a particular offset in the file.  I do not think this will work as
> intended. 

You're right.

> If we consider a process which forks, and each process then
> mmaps the same offset.  The first will get a reservation for its mmap,
> the second will not.  This seems to violate the "mapper is guarenteed
> to get sufficient pages" guarentee for the second mapper.  As the
> pages are missing and read-only we know that we actually could share the
> pages so in some sense this might make sense _if_ we could find and
> share the pages at fault time.  Currently we do not have the information
> required to find these pages so we would have to allocate pages for each
> mmap.
> 
> As things stand I think that we should be using 'chg = to - from' for
> all private mappings.  As each mapping is effectivly independant.
> 
> > +		set_vma_resv_huge_pages(vma, chg);
> 

Agreed. It's also a case that mprotect() to PROT_WRITE is not handled by this
patch at all. chg = to - from; appears to be the way to go for a multitute
of reasons.

> Whats not clear from the diff is that this change leaves us with two
> cases where we apply region_chg() and one where we do not, but we then
> always apply region_add().  Now when writing that region code I intended
> the region_chg/region_add as prepare/commit pair with the former
> performing any memory allocation we might require.  It is not safe to
> call region_add without first calling region_chg.  Yes the names are not
> helpful.  That region_add probabally should be:
> 
>         if (vma->vm_flags & VM_SHARED || !(vma->vm_flags & VM_MAYWRITE))
> 		region_add(&inode->i_mapping->private_list, from, to);
> 

Big oops on my part. You're right again.

> 
> >  	}
> > -
> > -	ret = 0;
> > -	if (delta < 0)
> > -		return_unused_surplus_pages((unsigned long) -delta);
> > -
> > -out:
> > -	spin_unlock(&hugetlb_lock);
> > -	return ret;
> > -}
> > -
> > -int hugetlb_reserve_pages(struct inode *inode, long from, long to)
> > -{
> > -	long ret, chg;
> > -
> > -	chg = region_chg(&inode->i_mapping->private_list, from, to);
> > +
> >  	if (chg < 0)
> >  		return chg;
> 

Thanks Andy.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
