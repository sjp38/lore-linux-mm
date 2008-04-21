Date: Mon, 21 Apr 2008 20:19:25 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC] Reserve huge pages for reliable MAP_PRIVATE hugetlbfs mappings
Message-ID: <20080421191925.GB13100@csn.ul.ie>
References: <20080421183621.GA13100@csn.ul.ie> <1208804726.17385.109.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1208804726.17385.109.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: wli@holomorphy.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (21/04/08 14:05), Adam Litke didst pronounce:
> On Mon, 2008-04-21 at 19:36 +0100, Mel Gorman wrote:
> > MAP_SHARED mappings on hugetlbfs reserve huge pages at mmap() time. This is
> > so that all future faults will be guaranteed to succeed. Applications are not
> > expected to use mlock() as this can result in poor NUMA placement.
> > 
> > MAP_PRIVATE mappings do not reserve pages. This can result in an application
> > being SIGKILLed later if a large page is not available at fault time. This
> > makes huge pages usage very ill-advised in some cases as the unexpected
> > application failure is intolerable. Forcing potential poor placement with
> > mlock() is not a great solution either.
> > 
> > This patch reserves huge pages at mmap() time for MAP_PRIVATE mappings similar
> > to what happens for MAP_SHARED mappings. Once mmap() succeeds, the application
> > developer knows that future faults will also succeed. However, there is no
> > guarantee that children of the process will be able to write-fault the same
> > mapping. The assumption is being made that the majority of applications that
> > fork() either use MAP_SHARED as an IPC mechanism or are calling exec().
> > 
> > Opinions?
> 
> Very sound idea in my opinion and definitely a step in the right
> direction toward even more reliable huge pages.  With this patch (my
> comments included), the only remaining cause of unexpected SIGKILLs
> would be copy-on-write.
> 

Correct. I have a test case which trivially triggers that parent/child problem
but the parent is able to complete properly which was the important thing. If
the pool is empty and dynamic resizing is disabled, then the test case exits
at mmap() time which is what I figured was better behaviour.

> > @@ -40,6 +40,34 @@ static int hugetlb_next_nid;
> >   */
> >  static DEFINE_SPINLOCK(hugetlb_lock);
> > 
> > +/* Helpers to track the number of pages reserved for a MAP_PRIVATE vma */
> > +static unsigned long vma_resv_huge_pages(struct vm_area_struct *vma)
> > +{
> > +	if (!(vma->vm_flags & VM_MAYSHARE))
> > +		return (unsigned long)vma->vm_private_data;
> > +	return 0;
> > +}
> > +
> > +static void adjust_vma_resv_huge_pages(struct vm_area_struct *vma,
> > +						int delta)
> > +{
> > +	BUG_ON((unsigned long)vma->vm_private_data > 100);
> > +	WARN_ON_ONCE(vma->vm_flags & VM_MAYSHARE);
> > +	if (!(vma->vm_flags & VM_MAYSHARE)) {
> > +		unsigned long reserve;
> > +		reserve = (unsigned long)vma->vm_private_data + delta;
> > +		vma->vm_private_data = (void *)reserve;
> > +	}
> > +}
> > +static void set_vma_resv_huge_pages(struct vm_area_struct *vma,
> > +						unsigned long reserve)
> > +{
> > +	BUG_ON((unsigned long)vma->vm_private_data > 100);
> 
> I assume you're just playing it safe for this RFC, but surely a 100 page
> max reservation is not sufficient (especially since we have a whole
> unsigned long to work with).  Also, I am not sure a BUG_ON would be an
> appropriate response to exceeding the maximum.
> 

That BUG_ON is a mistake. I was tracking down a reservation-related bug and
I introduced this temporarily and then forgot about it. Sorry about that.

> <snip>
> 
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
> > +		set_vma_resv_huge_pages(vma, chg);
> 
> To promote reliability, might it be advisable to just reserve the pages
> regardless of VM_MAYWRITE?  Otherwise we might want to consider
> reserving the pages in hugetlb_change_protection().
> 

It will mean excessive reservations for read-only mappings but I imagine
that is a fairly rare case anyway so I'll do that. The patch as-is is
vunerable to mprotect() making a read-only mapping read-write and the
application later dying. Reserving everything up-front might be
excessive but it's also a bit more robust.

Thanks Adam.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
