Date: Sat, 31 May 2008 14:06:03 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] huge page private reservation review cleanups
Message-ID: <20080531130603.GD423@csn.ul.ie>
References: <exportbomb.1212166524@pinky> <1212166704.0@pinky> <20080530132903.5d6717b0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080530132903.5d6717b0.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, agl@us.ibm.com, wli@holomorphy.com, kenchen@google.com, dwg@au1.ibm.com, andi@firstfloor.org, dean@arctic.org, abh@cray.com
List-ID: <linux-mm.kvack.org>

On (30/05/08 13:29), Andrew Morton didst pronounce:
> On Fri, 30 May 2008 17:58:24 +0100
> Andy Whitcroft <apw@shadowen.org> wrote:
> 
> > 
> > Create some new accessors for vma private data to cut down on and contain
> > the casts.  Encapsulates the huge and small page offset calculations.  Also
> > adds a couple of VM_BUG_ONs for consistency.
> > 
> 
> I'll stage this after Mel's
> hugetlb-guarantee-that-cow-faults-for-a-process-that-called-mmapmap_private-on-hugetlbfs-will-succeed.patch
> 

Sounds good, thanks.

> > ---
> >  mm/hugetlb.c |   56 +++++++++++++++++++++++++++++++++++++++++++-------------
> >  1 files changed, 43 insertions(+), 13 deletions(-)
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 729a830..7a5ac81 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -40,6 +40,26 @@ static int hugetlb_next_nid;
> >   */
> >  static DEFINE_SPINLOCK(hugetlb_lock);
> >  
> > +/*
> > + * Convert the address within this vma to the page offset within
> > + * the mapping, in base page units.
> > + */
> > +pgoff_t vma_page_offset(struct vm_area_struct *vma, unsigned long address)
> > +{
> > +	return ((address - vma->vm_start) >> PAGE_SHIFT) +
> > +					(vma->vm_pgoff >> PAGE_SHIFT);
> > +}
> > +
> > +/*
> > + * Convert the address within this vma to the page offset within
> > + * the mapping, in pagecache page units; huge pages here.
> > + */
> > +pgoff_t vma_pagecache_offset(struct vm_area_struct *vma, unsigned long address)
> > +{
> > +	return ((address - vma->vm_start) >> HPAGE_SHIFT) +
> > +			(vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
> > +}
> 
> I'll make these static.
> 
> >  #define HPAGE_RESV_OWNER    (1UL << (BITS_PER_LONG - 1))
> >  #define HPAGE_RESV_UNMAPPED (1UL << (BITS_PER_LONG - 2))
> >  #define HPAGE_RESV_MASK (HPAGE_RESV_OWNER | HPAGE_RESV_UNMAPPED)
> > @@ -53,36 +73,48 @@ static DEFINE_SPINLOCK(hugetlb_lock);
> >   * to reset the VMA at fork() time as it is not in use yet and there is no
> >   * chance of the global counters getting corrupted as a result of the values.
> >   */
> > +static unsigned long get_vma_private_data(struct vm_area_struct *vma)
> > +{
> > +	return (unsigned long)vma->vm_private_data;
> > +}
> > +
> > +static void set_vma_private_data(struct vm_area_struct *vma,
> > +							unsigned long value)
> > +{
> > +	vma->vm_private_data = (void *)value;
> > +}
> 
> Better.
> 
> >  static unsigned long vma_resv_huge_pages(struct vm_area_struct *vma)
> >  {
> >  	VM_BUG_ON(!is_vm_hugetlb_page(vma));
> >  	if (!(vma->vm_flags & VM_SHARED))
> > -		return (unsigned long)vma->vm_private_data & ~HPAGE_RESV_MASK;
> > +		return get_vma_private_data(vma) & ~HPAGE_RESV_MASK;
> >  	return 0;
> >  }
> 
> But I wonder if helpers which manipulate a vma's HPAGE_RESV_MASK
> flag(s) rather than the whole vm_provate_data would have been better.
> 

There are helpers that do that below. It was suggested that I define a
struct with bit-fields instead but I didn't feel it was much easier to
understand than masks which are already pretty common.

> >  static void set_vma_resv_huge_pages(struct vm_area_struct *vma,
> >  							unsigned long reserve)
> >  {
> > -	unsigned long flags;
> >  	VM_BUG_ON(!is_vm_hugetlb_page(vma));
> >  	VM_BUG_ON(vma->vm_flags & VM_SHARED);
> >  
> > -	flags = (unsigned long)vma->vm_private_data & HPAGE_RESV_MASK;
> > -	vma->vm_private_data = (void *)(reserve | flags);
> > +	set_vma_private_data(vma,
> > +		(get_vma_private_data(vma) & HPAGE_RESV_MASK) | reserve);
> >  }
> >  
> >  static void set_vma_resv_flags(struct vm_area_struct *vma, unsigned long flags)
> >  {
> > -	unsigned long reserveflags = (unsigned long)vma->vm_private_data;
> >  	VM_BUG_ON(!is_vm_hugetlb_page(vma));
> > -	vma->vm_private_data = (void *)(reserveflags | flags);
> > +	VM_BUG_ON(vma->vm_flags & VM_SHARED);
> > +
> > +	set_vma_private_data(vma, get_vma_private_data(vma) | flags);
> >  }
> >  
> >  static int is_vma_resv_set(struct vm_area_struct *vma, unsigned long flag)
> >  {
> >  	VM_BUG_ON(!is_vm_hugetlb_page(vma));
> > -	return ((unsigned long)vma->vm_private_data & flag) != 0;
> > +
> > +	return (get_vma_private_data(vma) & flag) != 0;
> >  }
> 
> Oh.  We already kinda have it.  Perhaps vma_resv_huge_pages() should
> have called set_vma_resv_flags().  I guess the assertions would have
> busted that.
> 

The assertions as-is would have made that hard all right, but the checks
(particularly the SHARED ones) that are there are really defensive in nature
rather than set in stone.  A VM_SHARED mapping could use the flags as well
if there was a good reason for it but I didn't want the helpers to be used
by accident.

> Oh well, whatever.
> 

I am currently under the belief that the helpers as-is are
fairly easy to understand, should not interfere badly with the
1GB-and-multi-large-page-support being worked on and are reasonably difficult
to use incorrectly but I'm open to being corrected on it.

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
