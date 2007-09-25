Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8PFUrHX010179
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 11:30:53 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8PFUrNm178106
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 09:30:53 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8PFUqHt023492
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 09:30:52 -0600
Subject: Re: [PATCH 0/4] [hugetlb] Dynamic huge page pool resizing
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <46F8EF7F.80804@linux.vnet.ibm.com>
References: <20070924154638.7565.86666.stgit@kernel>
	 <46F8EF7F.80804@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Tue, 25 Sep 2007 10:30:49 -0500
Message-Id: <1190734249.14295.34.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Ken Chen <kenchen@google.com>, Dave McCracken <dave.mccracken@oracle.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-09-25 at 16:52 +0530, Balbir Singh wrote:
> Adam Litke wrote:
> > How it works
> > ============
> > 
> > Upon depletion of the hugetlb pool, rather than reporting an error immediately,
> > first try and allocate the needed huge pages directly from the buddy allocator.
> > Care must be taken to avoid unbounded growth of the hugetlb pool, so the
> > hugetlb filesystem quota is used to limit overall pool size.
> > 
> 
> If I understand hugetlb correctly, there is no accounting of hugepages
> to the RSS of any process. Since the pool will no longer be static,
> should we also consider changes to the accounting of hugepages?

You're right: there is no accounting of huge pages against a process.
This is also the case for the statically allocated pool so this
particular issue exists unconditionally.  There are several things
missing: RSS accounting, counting huge pages towards locked_vm limits,
etc...  The plan is to address these separately and to fix them all at
once.

In the absence of traditional per-process huge page accounting, the
kernel has provided an alternate means for restricting a process' access
to the global hugetlb pool: filesystem permissions and quotas.  It's not
ideal, but with this patch series, the filesystem permissions and quotas
remain the effective mechanism for restricting pool growth and
consumption by processes.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
