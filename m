Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4SDqlom004200
	for <linux-mm@kvack.org>; Wed, 28 May 2008 09:52:47 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4SDqinb143126
	for <linux-mm@kvack.org>; Wed, 28 May 2008 09:52:44 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4SDqgMG005515
	for <linux-mm@kvack.org>; Wed, 28 May 2008 09:52:44 -0400
Subject: Re: [PATCH 2/3] Reserve huge pages for reliable MAP_PRIVATE
	hugetlbfs mappings until fork()
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080527185108.16194.87892.sendpatchset@skynet.skynet.ie>
References: <20080527185028.16194.57978.sendpatchset@skynet.skynet.ie>
	 <20080527185108.16194.87892.sendpatchset@skynet.skynet.ie>
Content-Type: text/plain
Date: Wed, 28 May 2008 08:52:44 -0500
Message-Id: <1211982764.12036.58.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, abh@cray.com, dean@arctic.org, linux-kernel@vger.kernel.org, wli@holomorphy.com, dwg@au1.ibm.com, linux-mm@kvack.org, andi@firstfloor.org, kenchen@google.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-05-27 at 19:51 +0100, Mel Gorman wrote:
> This patch reserves huge pages at mmap() time for MAP_PRIVATE mappings in a
> similar manner to the reservations taken for MAP_SHARED mappings. The reserve count is
> accounted both globally and on a per-VMA basis for private mappings. This
> guarantees that a process that successfully calls mmap() will successfully
> fault all pages in the future unless fork() is called.
> 
> The characteristics of private mappings of hugetlbfs files behaviour after
> this patch are;
> 
> 1. The process calling mmap() is guaranteed to succeed all future faults until
>    it forks().
> 2. On fork(), the parent may die due to SIGKILL on writes to the private
>    mapping if enough pages are not available for the COW. For reasonably
>    reliable behaviour in the face of a small huge page pool, children of
>    hugepage-aware processes should not reference the mappings; such as
>    might occur when fork()ing to exec().
> 3. On fork(), the child VMAs inherit no reserves. Reads on pages already
>    faulted by the parent will succeed. Successful writes will depend on enough
>    huge pages being free in the pool.
> 4. Quotas of the hugetlbfs mount are checked at reserve time for the mapper
>    and at fault time otherwise.
> 
> Before this patch, all reads or writes in the child potentially needs page
> allocations that can later lead to the death of the parent. This applies
> to reads and writes of uninstantiated pages as well as COW. After the
> patch it is only a write to an instantiated page that causes problems.
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
