Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j2AIHCl1000422
	for <linux-mm@kvack.org>; Thu, 10 Mar 2005 13:17:12 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j2AIHClE216996
	for <linux-mm@kvack.org>; Thu, 10 Mar 2005 13:17:12 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j2AIHBpM004320
	for <linux-mm@kvack.org>; Thu, 10 Mar 2005 13:17:12 -0500
Subject: Re: [PATCH] 0/2 Buddy allocator with placement policy (Version 9)
	+ prezeroing (Version 4)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050310092201.37bae9ba.pj@engr.sgi.com>
References: <20050307193938.0935EE594@skynet.csn.ul.ie>
	 <1110239966.6446.66.camel@localhost>
	 <Pine.LNX.4.58.0503101421260.2105@skynet>
	 <20050310092201.37bae9ba.pj@engr.sgi.com>
Content-Type: text/plain
Date: Thu, 10 Mar 2005 10:16:53 -0800
Message-Id: <1110478613.16432.36.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@engr.sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-03-10 at 09:22 -0800, Paul Jackson wrote:
> In particular, I am working on preparing a patch proposal for a policy
> that would kill a task rather than invoke the swapper.  In
> mm/page_alloc.c __alloc_pages(), if one gets down to the point of being
> about to kick the swapper, if this policy is enabled (and you're not
> in_interrupt() and don't have flag PF_MEMALLOC set), then ask
> oom_kill_task() to shoot us instead.  For some big HPC jobs that are
> carefully sized to fit on the allowed memory nodes, swapping is a fate
> worse than death.
>
> The natural place (for me, anyway) to hang such policies is off the
> cpuset.
> 
> I am hopeful that cpusets will soon hit Linus's tree.
> 
> Would it make sense to specify these buddy allocator fallback policies
> per cpuset as well?

That seems reasonable, but I don't think there necessarily be enough
cpuset users to make this reasonable as the only interface.

Seems like something VMA-based along the lines of madvise() or the NUMA
binding API would be more appropriate.  Perhaps default policies
inherited from a cpuset, but overridden by other APIs would be a good
compromise.

I have the feeling that applications will want to give the same kind of
notifications for swapping as they would for memory hotplug operations
as well.  In decreasing order of pickiness:

1. Don't touch me at all
2. It's OK to migrate these pages elsewhere on this node
3. It's OK to migrate these pages anywhere
4. It's OK to swap these pages out

Although the node part, at least, can almost certainly be done in
combination with the NUMA api.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
