Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4816B007E
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 13:04:31 -0500 (EST)
Date: Mon, 1 Mar 2010 18:04:12 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] mm: adjust kswapd nice level for high priority page
	allocators
Message-ID: <20100301180412.GF3852@csn.ul.ie>
References: <alpine.DEB.2.00.1003010213480.26824@chino.kir.corp.google.com> <20100301135242.GE3852@csn.ul.ie> <alpine.DEB.2.00.1003010941020.26562@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003010941020.26562@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Con Kolivas <kernel@kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 01, 2010 at 09:56:02AM -0800, David Rientjes wrote:
> On Mon, 1 Mar 2010, Mel Gorman wrote:
> 
> > > When kswapd is awoken due to reclaim by a running task, set the priority
> > > of kswapd to that of the task allocating pages thus making memory reclaim
> > > cpu activity affected by nice level.
> > > 
> > 
> > Why?
> > 
> > When a process kicks kswapd, the watermark at which a process enters
> > direct reclaim has not been reached yet. In other words, there is no
> > guarantee that a process will stall due to memory pressure.
> > 
> > The exception would be if there are many high-priority processes allocating
> > pages at a steady rate that are starving kswapd of CPU time and
> > consequently entering direct reclaim.
> 
> They don't necessarily need to be allocating pages, they may simply be 
> starving kswapd of cputime which increases the liklihood of subsequently 
> entering direct reclaim because of a low watermark on a later allocation.  

True.

> Without this patch, it's trivial especially on smaller desktop machines or 
> servers using cpusets to preempt kswapd from running by setting nice 
> levels for processes from userspace to have high priority.
> 

Can that be included with the changelog then please?

Can figures also be shown then as part of the patch? It would appear that
one possibility would be to boot a machine with 1G and simply measure the
time taken to complete 7 simultaneous kernel compiles (so that kswapd is
active) and measure the number of pages direct reclaimed and reclaimed by
kswapd. Rerun the test except that all the kernel builds are at a higher
priority than kswapd.

When all the priorities are the same, the reclaim figures should match
with or without the patch. With the priorities higher, then the direct
reclaims should be higher without this patch reflecting the fact that
kswapd was starved of CPU.

> If we're going to be doing background reclaim, it should not be done 
> slower than one or more processes allocating pages; otherwise, we bias 
> high priority tasks trying to allocate pages and favor lower priority.
> 
> > My main concern is that in the case there are a mix of high and low processes
> > with kswapd towards the higher priority as a result of this patch, kswapd
> > could be keeping CPU time from low-priority processes that are well behaved
> > that would would make less forward progress as a result of this patch.
> > 
> 
> That would only be the case if we constantly follow the slowpath in the 
> page allocator, in which case we want kswapd to run and reclaim memory so 
> that all processes can use the fastpath.
> 

Not necessarily. The CPU time used by the low-priority processes is not
necessarily allocator related. It could just be doing normal work, but
less of it because kswapd is getting more CPU time. Maybe it wouldn't
matter in practice because the lower CPU time is offset by the avoidance
of direct reclaims at some future point.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
