Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DA86E6B00B1
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 07:08:44 -0400 (EDT)
Date: Mon, 18 Oct 2010 12:08:29 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [experimental][PATCH] mm,vmstat: per cpu stat flush too when
	per cpu page cache flushed
Message-ID: <20101018110829.GZ30667@csn.ul.ie>
References: <20101013160640.ADC9.A69D9226@jp.fujitsu.com> <20101013132246.GO30667@csn.ul.ie> <20101014114541.8B89.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101014114541.8B89.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 14, 2010 at 11:50:28AM +0900, KOSAKI Motohiro wrote:
> > On Wed, Oct 13, 2010 at 04:10:43PM +0900, KOSAKI Motohiro wrote:
> > > When memory shortage, we are using drain_pages() for flushing per cpu
> > > page cache. In this case, per cpu stat should be flushed too. because
> > > now we are under memory shortage and we need to know exact free pages.
> > > 
> > > Otherwise get_page_from_freelist() may fail even though pcp was flushed.
> > > 
> > 
> > With my patch adjusting the threshold to a small value while kswapd is awake,
> > it seems less necessary. 
> 
> I agree this.
> 
> > It's also very hard to predict the performance of
> > this. We are certainly going to take a hit to do the flush but we *might*
> > gain slightly if an allocation succeeds because a watermark check passed
> > when the counters were updated. It's a definite hit for a possible gain
> > though which is not a great trade-off. Would need some performance testing.
> > 
> > I still think my patch on adjusting thresholds is our best proposal so
> > far on how to reduce Shaohua's performance problems while still being
> > safer from livelocks due to memory exhaustion.
> 
> OK, I will try to explain a detai of my worry.
> 
> Initial variable ZVC commit (df9ecaba3f1) says 
> 
> >     [PATCH] ZVC: Scale thresholds depending on the size of the system
> > 
> >     The ZVC counter update threshold is currently set to a fixed value of 32.
> >     This patch sets up the threshold depending on the number of processors and
> >     the sizes of the zones in the system.
> > 
> >     With the current threshold of 32, I was able to observe slight contention
> >     when more than 130-140 processors concurrently updated the counters.  The
> >     contention vanished when I either increased the threshold to 64 or used
> >     Andrew's idea of overstepping the interval (see ZVC overstep patch).
> > 
> >     However, we saw contention again at 220-230 processors.  So we need higher
> >     values for larger systems.
> 
> So, I'm worry about your patch reintroduce old cache contention issue that Christoph
> observed when run 128-256cpus system.  May I ask how do you think this issue?
> 

It only reintroduces the overhead while kswapd is awake and the system is in danger
of accidentally allocating all of its pages. Yes, it's slower but it's
less risky.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
