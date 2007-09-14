Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8E5ko4B027940
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 15:46:50 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8E5oMna285950
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 15:50:22 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8E5kWAQ018871
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 15:46:32 +1000
Date: Fri, 14 Sep 2007 15:46:15 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [Libhugetlbfs-devel] [PATCH 3/5] hugetlb: Try to grow hugetlb	pool for MAP_PRIVATE mappings
Message-ID: <20070914054615.GL481@localhost.localdomain>
References: <20070913175855.27074.27030.stgit@kernel> <20070913175928.27074.14259.stgit@kernel> <1189706781.17236.1519.camel@localhost> <1189714890.15024.39.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1189714890.15024.39.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, libhugetlbfs-devel@lists.sourceforge.net, Dave McCracken <dave.mccracken@oracle.com>, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, Ken Chen <kenchen@google.com>, Andy Whitcroft <apw@shadowen.org>, Bill Irwin <bill.irwin@oracle.com>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 13, 2007 at 03:21:30PM -0500, Adam Litke wrote:
> On Thu, 2007-09-13 at 11:06 -0700, Dave Hansen wrote:
> > On Thu, 2007-09-13 at 10:59 -0700, Adam Litke wrote:
> > > +static int within_locked_vm_limits(long hpage_delta)
> > > +{
> > > +	unsigned long locked_pages, locked_pages_limit;
> > > +
> > > +	/* Check locked page limits */
> > > +	locked_pages = current->mm->locked_vm;
> > > +	locked_pages += hpage_delta * (HPAGE_SIZE >> PAGE_SHIFT);
> > > +	locked_pages_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
> > > +	locked_pages_limit >>= PAGE_SHIFT;
> > > +
> > > +	/* Return 0 if we would exceed locked_vm limits */
> > > +	if (locked_pages > locked_pages_limit)
> > > +		return 0;
> > > +
> > > +	/* Nice, we're within limits */
> > > +	return 1;
> > > +}
> > > +
> > > +static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
> > > +						unsigned long address)
> > > +{
> > > +	struct page *page;
> > > +
> > > +	/* Check we remain within limits if 1 huge page is allocated */
> > > +	if (!within_locked_vm_limits(1))
> > > +		return NULL;
> > > +
> > > +	page = alloc_pages(htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
> > ...
> > 
> > Is there locking around this operation?  Or, is there a way that a
> > process could do this concurrently in two different threads, both appear
> > to be within within_locked_vm_limits(), and both succeed to allocate
> > when doing so actually takes them over the limit?
> 
> This case is prevented by hugetlb_instantiation_mutex.  I'll include a
> comment to make that clearer.

Hrm... a number of people are trying to get rid of, or at least reduce
the scope of the instatiation mutex, since it can be significant
bottlenect when clearing large numbers of hugepages on big SMP
systems.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
