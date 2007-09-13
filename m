Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8DIGeOU031700
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 14:16:40 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8DIGHr3504548
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 12:16:40 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8DI6NWj006979
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 12:06:23 -0600
Subject: Re: [Libhugetlbfs-devel] [PATCH 3/5] hugetlb: Try to grow hugetlb
	pool for MAP_PRIVATE mappings
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20070913175928.27074.14259.stgit@kernel>
References: <20070913175855.27074.27030.stgit@kernel>
	 <20070913175928.27074.14259.stgit@kernel>
Content-Type: text/plain
Date: Thu, 13 Sep 2007 11:06:21 -0700
Message-Id: <1189706781.17236.1519.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net, Dave McCracken <dave.mccracken@oracle.com>, Mel Gorman <mel@skynet.ie>, Ken Chen <kenchen@google.com>, Andy Whitcroft <apw@shadowen.org>, Bill Irwin <bill.irwin@oracle.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-09-13 at 10:59 -0700, Adam Litke wrote:
> +static int within_locked_vm_limits(long hpage_delta)
> +{
> +	unsigned long locked_pages, locked_pages_limit;
> +
> +	/* Check locked page limits */
> +	locked_pages = current->mm->locked_vm;
> +	locked_pages += hpage_delta * (HPAGE_SIZE >> PAGE_SHIFT);
> +	locked_pages_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
> +	locked_pages_limit >>= PAGE_SHIFT;
> +
> +	/* Return 0 if we would exceed locked_vm limits */
> +	if (locked_pages > locked_pages_limit)
> +		return 0;
> +
> +	/* Nice, we're within limits */
> +	return 1;
> +}
> +
> +static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
> +						unsigned long address)
> +{
> +	struct page *page;
> +
> +	/* Check we remain within limits if 1 huge page is allocated */
> +	if (!within_locked_vm_limits(1))
> +		return NULL;
> +
> +	page = alloc_pages(htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
...

Is there locking around this operation?  Or, is there a way that a
process could do this concurrently in two different threads, both appear
to be within within_locked_vm_limits(), and both succeed to allocate
when doing so actually takes them over the limit?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
