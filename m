Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8DKLWqX027165
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 16:21:32 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8DKLWdX410510
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 14:21:32 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8DKLVdV015914
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 14:21:32 -0600
Subject: Re: [Libhugetlbfs-devel] [PATCH 3/5] hugetlb: Try to grow hugetlb
	pool for MAP_PRIVATE mappings
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1189706781.17236.1519.camel@localhost>
References: <20070913175855.27074.27030.stgit@kernel>
	 <20070913175928.27074.14259.stgit@kernel>
	 <1189706781.17236.1519.camel@localhost>
Content-Type: text/plain
Date: Thu, 13 Sep 2007 15:21:30 -0500
Message-Id: <1189714890.15024.39.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net, Dave McCracken <dave.mccracken@oracle.com>, Mel Gorman <mel@skynet.ie>, Ken Chen <kenchen@google.com>, Andy Whitcroft <apw@shadowen.org>, Bill Irwin <bill.irwin@oracle.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-09-13 at 11:06 -0700, Dave Hansen wrote:
> On Thu, 2007-09-13 at 10:59 -0700, Adam Litke wrote:
> > +static int within_locked_vm_limits(long hpage_delta)
> > +{
> > +	unsigned long locked_pages, locked_pages_limit;
> > +
> > +	/* Check locked page limits */
> > +	locked_pages = current->mm->locked_vm;
> > +	locked_pages += hpage_delta * (HPAGE_SIZE >> PAGE_SHIFT);
> > +	locked_pages_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
> > +	locked_pages_limit >>= PAGE_SHIFT;
> > +
> > +	/* Return 0 if we would exceed locked_vm limits */
> > +	if (locked_pages > locked_pages_limit)
> > +		return 0;
> > +
> > +	/* Nice, we're within limits */
> > +	return 1;
> > +}
> > +
> > +static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
> > +						unsigned long address)
> > +{
> > +	struct page *page;
> > +
> > +	/* Check we remain within limits if 1 huge page is allocated */
> > +	if (!within_locked_vm_limits(1))
> > +		return NULL;
> > +
> > +	page = alloc_pages(htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
> ...
> 
> Is there locking around this operation?  Or, is there a way that a
> process could do this concurrently in two different threads, both appear
> to be within within_locked_vm_limits(), and both succeed to allocate
> when doing so actually takes them over the limit?

This case is prevented by hugetlb_instantiation_mutex.  I'll include a
comment to make that clearer.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
