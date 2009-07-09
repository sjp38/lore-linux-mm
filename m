Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8113F6B005A
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 04:27:27 -0400 (EDT)
Date: Thu, 9 Jul 2009 16:42:22 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC PATCH 1/2] vmscan don't isolate too many pages in a zone
Message-ID: <20090709084222.GA10400@localhost>
References: <20090709024710.GA16783@localhost> <20090709030731.GA17097@localhost> <20090709121647.2395.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090709121647.2395.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 09, 2009 at 03:01:26PM +0800, KOSAKI Motohiro wrote:
> Hi
> 
> > I tried the semaphore based concurrent direct reclaim throttling, and
> > get these numbers. The run time is normal 30s, but can sometimes go up
> > by many folds. It seems that there are more hidden problems..
> 
> Hmm....
> I think I and you have different priority list. May I explain why Rik
> and decide to use half of LRU pages?
> 
> the system have 4GB (=1M pages) memory. my patch allow 1M/2/32=16384
> threads. I agree this is very large and inefficient. However IOW 
> this is very conservative.
> I believe it don't makes too strong restriction problem.
 
Sorry if I made confusions. I agree on the NR_ISOLATED based throttling.
It risks much less than to limit the concurrency of direct reclaim.
Isolating half LRU pages normally costs nothing.

> In the other hand, your patch's concurrent restriction is small constant
> value (=32).
> it can be more efficient and it also can makes regression. IOW it is more
> aggressive approach.
> 
> e.g.
> if the system have >100 CPU, my patch can get enough much reclaimer but
> your patch makes tons idle cpus.

That's a quick (and clueless) hack to check if the (very unstable)
reclaim behavior can be improved by limiting the concurrency. I didn't
mean to push it further more :)

> And, To recall original issue tearch us this is rarely and a bit insane
> workload issue.
> Then, I priotize to
> 
> 1. prevent unnecessary OOM
> 2. no regression to typical workload
> 3. msgctl11 performance

I totally agree on the above priorities.

> 
> IOW, I don't think msgctl11 performance is so important.
> May I ask why do you think msgctl11 performance is so important?

Now that we have addressed (1)/(2) with your patch, naturally the
msgctl11 performance problem catches my eyes. Strictly speaking
I'm not particularly interested in the performance itself, but
the obviously high _fluctuations_ of performance. Something bad
is happening there which deserves some attention.

> 
> >
> > --- linux.orig/mm/vmscan.c
> > +++ linux/mm/vmscan.c
> > @@ -1042,6 +1042,7 @@ static unsigned long shrink_inactive_lis
> >  	unsigned long nr_reclaimed = 0;
> >  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
> >  	int lumpy_reclaim = 0;
> > +	static struct semaphore direct_reclaim_sem = __SEMAPHORE_INITIALIZER(direct_reclaim_sem, 32);
> >  
> >  	/*
> >  	 * If we need a large contiguous chunk of memory, or have
> > @@ -1057,6 +1058,9 @@ static unsigned long shrink_inactive_lis
> >  
> >  	pagevec_init(&pvec, 1);
> >  
> > +	if (!current_is_kswapd())
> > +		down(&direct_reclaim_sem);
> > +
> >  	lru_add_drain();
> >  	spin_lock_irq(&zone->lru_lock);
> >  	do {
> > @@ -1173,6 +1177,10 @@ static unsigned long shrink_inactive_lis
> >  done:
> >  	local_irq_enable();
> >  	pagevec_release(&pvec);
> > +
> > +	if (!current_is_kswapd())
> > +		up(&direct_reclaim_sem);
> > +
> >  	return nr_reclaimed;
> >  }
> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
