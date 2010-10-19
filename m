Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5033E5F0047
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 05:06:25 -0400 (EDT)
Date: Tue, 19 Oct 2010 10:06:06 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [experimental][PATCH] mm,vmstat: per cpu stat flush too when
	per cpu page cache flushed
Message-ID: <20101019090606.GE30667@csn.ul.ie>
References: <20101014114541.8B89.A69D9226@jp.fujitsu.com> <20101018110829.GZ30667@csn.ul.ie> <20101019102428.A1BF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101019102428.A1BF.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 19, 2010 at 10:34:13AM +0900, KOSAKI Motohiro wrote:
> > > Initial variable ZVC commit (df9ecaba3f1) says 
> > > 
> > > >     [PATCH] ZVC: Scale thresholds depending on the size of the system
> > > > 
> > > >     The ZVC counter update threshold is currently set to a fixed value of 32.
> > > >     This patch sets up the threshold depending on the number of processors and
> > > >     the sizes of the zones in the system.
> > > > 
> > > >     With the current threshold of 32, I was able to observe slight contention
> > > >     when more than 130-140 processors concurrently updated the counters.  The
> > > >     contention vanished when I either increased the threshold to 64 or used
> > > >     Andrew's idea of overstepping the interval (see ZVC overstep patch).
> > > > 
> > > >     However, we saw contention again at 220-230 processors.  So we need higher
> > > >     values for larger systems.
> > > 
> > > So, I'm worry about your patch reintroduce old cache contention issue that Christoph
> > > observed when run 128-256cpus system.  May I ask how do you think this issue?
> > 
> > It only reintroduces the overhead while kswapd is awake and the system is in danger
> > of accidentally allocating all of its pages. Yes, it's slower but it's
> > less risky.
> 
> When we have rich storage and running IO intensive workload, kswapd are almost 
> always awake ;)

That's an interesting assertion because it's not just the storage and IO
that is a factor but the number of pages it requires. For example, lets
assume a workload is write-intensive but it is using the same 30% of memory
for I/O.  That workload should not keep kswapd awake and if it is, it should
be investigated. Are you aware of a situation like this?

An I/O intensive workload that kswapd is constantly awake for must be
continually requiring new data meaning it is either streaming writes or its
working set size exceeds physical memory. In the former case, there is no
much we can do because the workload is going to be blocked on I/O anyway to
write the pages. In the latter case, the machine could do with more memory
or the application could do with some tuning to reduce its footprint. In
either case, the workload is going to be more concerned with being blocked
on I/O than the increased cost of counters.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
