Date: Fri, 16 May 2008 13:15:10 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] Guarantee that COW faults for a process that called mmap(MAP_PRIVATE) on hugetlbfs will succeed
Message-ID: <20080516121510.GC2637@csn.ul.ie>
References: <20080507193826.5765.49292.sendpatchset@skynet.skynet.ie> <20080507193926.5765.78883.sendpatchset@skynet.skynet.ie> <1210798525.19507.55.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1210798525.19507.55.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, dean@arctic.org, linux-kernel@vger.kernel.org, wli@holomorphy.com, dwg@au1.ibm.com, andi@firstfloor.org, kenchen@google.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On (14/05/08 15:55), Adam Litke didst pronounce:
> On Wed, 2008-05-07 at 20:39 +0100, Mel Gorman wrote:
> 
> > diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-0020-map_private_reserve/mm/hugetlb.c linux-2.6.25-mm1-0030-reliable_parent_faults/mm/hugetlb.c
> > --- linux-2.6.25-mm1-0020-map_private_reserve/mm/hugetlb.c	2008-05-07 18:39:34.000000000 +0100
> > +++ linux-2.6.25-mm1-0030-reliable_parent_faults/mm/hugetlb.c	2008-05-07 20:05:18.000000000 +0100
> > @@ -40,6 +40,9 @@ static int hugetlb_next_nid;
> >   */
> >  static DEFINE_SPINLOCK(hugetlb_lock);
> > 
> > +#define HPAGE_RESV_OWNER    (1UL << (BITS_PER_LONG - 1))
> > +#define HPAGE_RESV_UNMAPPED (1UL << (BITS_PER_LONG - 2))
> > +#define HPAGE_RESV_MASK (HPAGE_RESV_OWNER | HPAGE_RESV_UNMAPPED)
> >  /*
> >   * These three helpers are used to track how many pages are reserved for
> >   * faults in a MAP_PRIVATE mapping. Only the process that called mmap()
> > @@ -49,20 +52,23 @@ static unsigned long vma_resv_huge_pages
> >  {
> >  	VM_BUG_ON(!is_vm_hugetlb_page(vma));
> >  	if (!(vma->vm_flags & VM_SHARED))
> > -		return (unsigned long)vma->vm_private_data;
> > +		return (unsigned long)vma->vm_private_data & ~HPAGE_RESV_MASK;
> >  	return 0;
> >  }
> 
> Ick.  Though I don't really have a suggestion on how to improve it
> unless a half-word is enough room to contain the reservation.  In that
> case we could create a structure which would make this much clearer.
> 
> struct hugetlb_vma_reservation {
> 	unsigned int flags;
> 	unsigned int resv;
> };
> 

That won't fit into a void * on 32 bit. The use of a pointer to store
values like this is a little ugly but it's confined to the helpers whose
naming makes it obvious what is going on.

It would be done with bit-fields and the like but I don't think it helps
the readability a whole lot.

> >  static void adjust_vma_resv_huge_pages(struct vm_area_struct *vma, int delta)
> >  {
> >  	unsigned long reserve;
> > +	unsigned long flags;
> >  	VM_BUG_ON(vma->vm_flags & VM_SHARED);
> >  	VM_BUG_ON(!is_vm_hugetlb_page(vma));
> > 
> >  	reserve = (unsigned long)vma->vm_private_data + delta;
> > -	vma->vm_private_data = (void *)reserve;
> > +	flags = (unsigned long)vma->vm_private_data & HPAGE_RESV_MASK;
> > +	vma->vm_private_data = (void *)(reserve | flags);
> >  }
> > 
> > +/* Reset counters to 0 and clear all HPAGE_RESV_* flags */
> >  void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
> >  {
> >  	VM_BUG_ON(!is_vm_hugetlb_page(vma));
> > @@ -73,10 +79,27 @@ void reset_vma_resv_huge_pages(struct vm
> >  static void set_vma_resv_huge_pages(struct vm_area_struct *vma,
> >  							unsigned long reserve)
> >  {
> > +	unsigned long flags;
> > +
> >  	VM_BUG_ON(!is_vm_hugetlb_page(vma));
> >  	VM_BUG_ON(vma->vm_flags & VM_SHARED);
> > 
> > -	vma->vm_private_data = (void *)reserve;
> > +	flags = (unsigned long)vma->vm_private_data & HPAGE_RESV_MASK;
> > +	vma->vm_private_data = (void *)(reserve | flags);
> > +}
> > +
> > +static void set_vma_resv_flags(struct vm_area_struct *vma, unsigned long flags)
> > +{
> > +	unsigned long reserveflags = (unsigned long)vma->vm_private_data;
> > +	VM_BUG_ON(!is_vm_hugetlb_page(vma));
> > +	reserveflags |= flags;
> > +	vma->vm_private_data = (void *)reserveflags;
> > +}
> > +
> > +static int is_vma_resv_set(struct vm_area_struct *vma, unsigned long flag)
> > +{
> > +	VM_BUG_ON(!is_vm_hugetlb_page(vma));
> > +	return ((unsigned long)vma->vm_private_data & flag) != 0;
> >  }
> > 
> >  static void clear_huge_page(struct page *page, unsigned long addr)
> > @@ -139,7 +162,7 @@ static void decrement_hugepage_resv_vma(
> >  		 * Only the process that called mmap() has reserves for
> >  		 * private mappings.
> >  		 */
> > -		if (vma_resv_huge_pages(vma)) {
> > +		if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
> >  			resv_huge_pages--;
> >  			adjust_vma_resv_huge_pages(vma, -1);
> >  		}
> 
> -- 
> Adam Litke - (agl at us.ibm.com)
> IBM Linux Technology Center
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
