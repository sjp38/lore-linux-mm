Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6B80E6B0047
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 12:56:14 -0500 (EST)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o21HuAOj013890
	for <linux-mm@kvack.org>; Mon, 1 Mar 2010 09:56:10 -0800
Received: from pwi8 (pwi8.prod.google.com [10.241.219.8])
	by kpbe14.cbf.corp.google.com with ESMTP id o21Hu8Ih008690
	for <linux-mm@kvack.org>; Mon, 1 Mar 2010 09:56:09 -0800
Received: by pwi8 with SMTP id 8so1744140pwi.23
        for <linux-mm@kvack.org>; Mon, 01 Mar 2010 09:56:08 -0800 (PST)
Date: Mon, 1 Mar 2010 09:56:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: adjust kswapd nice level for high priority page
 allocators
In-Reply-To: <20100301135242.GE3852@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1003010941020.26562@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003010213480.26824@chino.kir.corp.google.com> <20100301135242.GE3852@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Con Kolivas <kernel@kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Mar 2010, Mel Gorman wrote:

> > When kswapd is awoken due to reclaim by a running task, set the priority
> > of kswapd to that of the task allocating pages thus making memory reclaim
> > cpu activity affected by nice level.
> > 
> 
> Why?
> 
> When a process kicks kswapd, the watermark at which a process enters
> direct reclaim has not been reached yet. In other words, there is no
> guarantee that a process will stall due to memory pressure.
> 
> The exception would be if there are many high-priority processes allocating
> pages at a steady rate that are starving kswapd of CPU time and
> consequently entering direct reclaim.

They don't necessarily need to be allocating pages, they may simply be 
starving kswapd of cputime which increases the liklihood of subsequently 
entering direct reclaim because of a low watermark on a later allocation.  
Without this patch, it's trivial especially on smaller desktop machines or 
servers using cpusets to preempt kswapd from running by setting nice 
levels for processes from userspace to have high priority.

If we're going to be doing background reclaim, it should not be done 
slower than one or more processes allocating pages; otherwise, we bias 
high priority tasks trying to allocate pages and favor lower priority.

> My main concern is that in the case there are a mix of high and low processes
> with kswapd towards the higher priority as a result of this patch, kswapd
> could be keeping CPU time from low-priority processes that are well behaved
> that would would make less forward progress as a result of this patch.
> 

That would only be the case if we constantly follow the slowpath in the 
page allocator, in which case we want kswapd to run and reclaim memory so 
that all processes can use the fastpath.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
