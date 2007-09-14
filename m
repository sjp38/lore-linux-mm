Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8EDXZRr005006
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 09:33:35 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8EDXZJo503082
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 07:33:35 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8EDXY9k023351
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 07:33:35 -0600
Subject: Re: [Libhugetlbfs-devel] [PATCH 3/5] hugetlb: Try to grow
	hugetlb	pool for MAP_PRIVATE mappings
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20070914054615.GL481@localhost.localdomain>
References: <20070913175855.27074.27030.stgit@kernel>
	 <20070913175928.27074.14259.stgit@kernel>
	 <1189706781.17236.1519.camel@localhost>
	 <1189714890.15024.39.camel@localhost.localdomain>
	 <20070914054615.GL481@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 14 Sep 2007 08:33:33 -0500
Message-Id: <1189776813.15024.45.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Gibson <dwg@au1.ibm.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, libhugetlbfs-devel@lists.sourceforge.net, Dave McCracken <dave.mccracken@oracle.com>, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, Ken Chen <kenchen@google.com>, Andy Whitcroft <apw@shadowen.org>, Bill Irwin <bill.irwin@oracle.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-09-14 at 15:46 +1000, David Gibson wrote:
> On Thu, Sep 13, 2007 at 03:21:30PM -0500, Adam Litke wrote:
> > On Thu, 2007-09-13 at 11:06 -0700, Dave Hansen wrote:
> > > On Thu, 2007-09-13 at 10:59 -0700, Adam Litke wrote:
> > > > +static int within_locked_vm_limits(long hpage_delta)
> > > > +{
> > > > +	unsigned long locked_pages, locked_pages_limit;
> > > > +
> > > > +	/* Check locked page limits */
> > > > +	locked_pages = current->mm->locked_vm;
> > > > +	locked_pages += hpage_delta * (HPAGE_SIZE >> PAGE_SHIFT);
> > > > +	locked_pages_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
> > > > +	locked_pages_limit >>= PAGE_SHIFT;
> > > > +
> > > > +	/* Return 0 if we would exceed locked_vm limits */
> > > > +	if (locked_pages > locked_pages_limit)
> > > > +		return 0;
> > > > +
> > > > +	/* Nice, we're within limits */
> > > > +	return 1;
> > > > +}
> > > > +
> > > > +static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
> > > > +						unsigned long address)
> > > > +{
> > > > +	struct page *page;
> > > > +
> > > > +	/* Check we remain within limits if 1 huge page is allocated */
> > > > +	if (!within_locked_vm_limits(1))
> > > > +		return NULL;
> > > > +
> > > > +	page = alloc_pages(htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
> > > ...
> > > 
> > > Is there locking around this operation?  Or, is there a way that a
> > > process could do this concurrently in two different threads, both appear
> > > to be within within_locked_vm_limits(), and both succeed to allocate
> > > when doing so actually takes them over the limit?
> > 
> > This case is prevented by hugetlb_instantiation_mutex.  I'll include a
> > comment to make that clearer.
> 
> Hrm... a number of people are trying to get rid of, or at least reduce
> the scope of the instatiation mutex, since it can be significant
> bottlenect when clearing large numbers of hugepages on big SMP
> systems.

Yes, and with the exception of this bit, this patch series furthers that
goal substantially.  With a dynamic hugetlb pool, the
alloc-instantiation race can be handled by stretching the pool during
the race window to accommodate the temporary overage.

As for the safety of within_locked_vm_limits() depending on
hugetlb_instantiation_mutex, perhaps this is another reason to not use
the locked ulimit as a way to manage hugetlb pool growth (since we do
have the fs quota method). 

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
