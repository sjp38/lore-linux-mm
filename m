Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4SIG7vS020857
	for <linux-mm@kvack.org>; Wed, 28 May 2008 14:16:07 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4SIG7VS137236
	for <linux-mm@kvack.org>; Wed, 28 May 2008 14:16:07 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4SIG5nX023762
	for <linux-mm@kvack.org>; Wed, 28 May 2008 14:16:06 -0400
Subject: Re: [PATCH 3/3] Guarantee that COW faults for a process that
	called mmap(MAP_PRIVATE) on hugetlbfs will succeed
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080527185128.16194.87380.sendpatchset@skynet.skynet.ie>
References: <20080527185028.16194.57978.sendpatchset@skynet.skynet.ie>
	 <20080527185128.16194.87380.sendpatchset@skynet.skynet.ie>
Content-Type: text/plain
Date: Wed, 28 May 2008 13:16:07 -0500
Message-Id: <1211998567.12036.65.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, dean@arctic.org, linux-kernel@vger.kernel.org, wli@holomorphy.com, dwg@au1.ibm.com, apw@shadowen.org, linux-mm@kvack.org, andi@firstfloor.org, kenchen@google.com, abh@cray.com
List-ID: <linux-mm.kvack.org>

On Tue, 2008-05-27 at 19:51 +0100, Mel Gorman wrote:
> After patch 2 in this series, a process that successfully calls mmap()
> for a MAP_PRIVATE mapping will be guaranteed to successfully fault until a
> process calls fork().  At that point, the next write fault from the parent
> could fail due to COW if the child still has a reference.
> 
> We only reserve pages for the parent but a copy must be made to avoid leaking
> data from the parent to the child after fork(). Reserves could be taken for
> both parent and child at fork time to guarantee faults but if the mapping
> is large it is highly likely we will not have sufficient pages for the
> reservation, and it is common to fork only to exec() immediatly after. A
> failure here would be very undesirable.
> 
> Note that the current behaviour of mainline with MAP_PRIVATE pages is
> pretty bad.  The following situation is allowed to occur today.
> 
> 1. Process calls mmap(MAP_PRIVATE)
> 2. Process calls mlock() to fault all pages and makes sure it succeeds
> 3. Process forks()
> 4. Process writes to MAP_PRIVATE mapping while child still exists
> 5. If the COW fails at this point, the process gets SIGKILLed even though it
>    had taken care to ensure the pages existed
> 
> This patch improves the situation by guaranteeing the reliability of the
> process that successfully calls mmap(). When the parent performs COW, it
> will try to satisfy the allocation without using reserves. If that fails the
> parent will steal the page leaving any children without a page. Faults from
> the child after that point will result in failure. If the child COW happens
> first, an attempt will be made to allocate the page without reserves and
> the child will get SIGKILLed on failure.
> 
> To summarise the new behaviour:
> 
> 1. If the original mapper performs COW on a private mapping with multiple
>    references, it will attempt to allocate a hugepage from the pool or
>    the buddy allocator without using the existing reserves. On fail, VMAs
>    mapping the same area are traversed and the page being COW'd is unmapped
>    where found. It will then steal the original page as the last mapper in
>    the normal way.
> 
> 2. The VMAs the pages were unmapped from are flagged to note that pages
>    with data no longer exist. Future no-page faults on those VMAs will
>    terminate the process as otherwise it would appear that data was corrupted.
>    A warning is printed to the console that this situation occured.
> 
> 2. If the child performs COW first, it will attempt to satisfy the COW
>    from the pool if there are enough pages or via the buddy allocator if
>    overcommit is allowed and the buddy allocator can satisfy the request. If
>    it fails, the child will be killed.
> 
> If the pool is large enough, existing applications will not notice that the
> reserves were a factor. Existing applications depending on the no-reserves
> been set are unlikely to exist as for much of the history of hugetlbfs,
> pages were prefaulted at mmap(), allocating the pages at that point or failing
> the mmap().
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Acked-by: Adam Litke <agl@us.ibm.com>

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
