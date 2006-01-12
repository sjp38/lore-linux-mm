Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0CHQ7DP004517
	for <linux-mm@kvack.org>; Thu, 12 Jan 2006 12:26:07 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0CHQ7BB071866
	for <linux-mm@kvack.org>; Thu, 12 Jan 2006 12:26:07 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k0CHQ6KS019407
	for <linux-mm@kvack.org>; Thu, 12 Jan 2006 12:26:07 -0500
Subject: Re: [PATCH 2/2] hugetlb: synchronize alloc with page cache insert
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20060112010502.GG9091@holomorphy.com>
References: <1137018263.9672.10.camel@localhost.localdomain>
	 <200601120040.k0C0ebg02818@unix-os.sc.intel.com>
	 <20060112010502.GG9091@holomorphy.com>
Content-Type: text/plain
Date: Thu, 12 Jan 2006 11:26:05 -0600
Message-Id: <1137086766.9672.40.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2006-01-11 at 17:05 -0800, William Lee Irwin III wrote:
> On Wed, Jan 11, 2006 at 04:40:37PM -0800, Chen, Kenneth W wrote:
> > What if two processes fault on the same page and races with find_lock_page(),
> > both find page not in the page cache.  The process won the race proceed to
> > allocate last hugetlb page.  While the other will exit with SIGBUS.
> > In theory, both processes should be OK.
> 
> This is supposed to fix the incarnation of that as a preexisting
> problem, but you're right, there is no fallback or retry for the case
> of hugepage queue exhaustion. For some reason I saw a phantom page
> allocator fallback in the hugepage allocator changes.
> 
> Looks like back to the drawing board for this pair of patches, though
> I'd be more than happy to get a solution to this.

I still think patch 1 (delayed zeroing) is a good thing to have.  It
will definitely improve performance for multi-threaded hugetlb
applications by avoiding unnecessary hugetlb page zeroing.  It also
shrinks the race window we have been talking about to a tiny fraction of
what it was.  This should ease the problem while we figure out a way to
handle the "last free page" case.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
