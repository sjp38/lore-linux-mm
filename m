Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 10E406B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 13:50:40 -0400 (EDT)
Received: by pvc30 with SMTP id 30so909649pvc.14
        for <linux-mm@kvack.org>; Thu, 26 Aug 2010 10:50:39 -0700 (PDT)
Date: Fri, 27 Aug 2010 02:50:30 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RFC PATCH 0/3] Do not wait the full timeout on
 congestion_wait when there is no congestion
Message-ID: <20100826175030.GE6873@barrios-desktop>
References: <1282835656-5638-1-git-send-email-mel@csn.ul.ie>
 <20100826172038.GA6873@barrios-desktop>
 <20100826173147.GH20944@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100826173147.GH20944@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 26, 2010 at 06:31:47PM +0100, Mel Gorman wrote:
> On Fri, Aug 27, 2010 at 02:20:38AM +0900, Minchan Kim wrote:
> > On Thu, Aug 26, 2010 at 04:14:13PM +0100, Mel Gorman wrote:
> > > congestion_wait() is a bit stupid in that it goes to sleep even when there
> > > is no congestion. This causes stalls in a number of situations and may be
> > > partially responsible for bug reports about desktop interactivity.
> > > 
> > > This patch series aims to account for these unnecessary congestion_waits()
> > > and to avoid going to sleep when there is no congestion available. Patches
> > > 1 and 2 add instrumentation related to congestion which should be reuable
> > > by alternative solutions to congestion_wait. Patch 3 calls cond_resched()
> > > instead of going to sleep if there is no congestion.
> > > 
> > > Once again, I shoved this through performance test. Unlike previous tests,
> > > I ran this on a ported version of my usual test-suite that should be suitable
> > > for release soon. It's not quite as good as my old set but it's sufficient
> > > for this and related series. The tests I ran were kernbench vmr-stream
> > > iozone hackbench-sockets hackbench-pipes netperf-udp netperf-tcp sysbench
> > > stress-highalloc. Sysbench was a read/write tests and stress-highalloc is
> > > the usual stress the number of high order allocations that can be made while
> > > the system is under severe stress. The suite contains the necessary analysis
> > > scripts as well and I'd release it now except the documentation blows.
> > > 
> > > x86:    Intel Pentium D 3GHz with 3G RAM (no-brand machine)
> > > x86-64:	AMD Phenom 9950 1.3GHz with 3G RAM (no-brand machine)
> > > ppc64:	PPC970MP 2.5GHz with 3GB RAM (it's a terrasoft powerstation)
> > > 
> > > The disks on all of them were single disks and not particularly fast.
> > > 
> > > Comparison was between a 2.6.36-rc1 with patches 1 and 2 applied for
> > > instrumentation and a second test with patch 3 applied.
> > > 
> > > In all cases, kernbench, hackbench, STREAM and iozone did not show any
> > > performance difference because none of them were pressuring the system
> > > enough to be calling congestion_wait() so I won't post the results.
> > > About all worth noting for them is that nothing horrible appeared to break.
> > > 
> > > In the analysis scripts, I record unnecessary sleeps to be a sleep that
> > > had no congestion. The post-processing scripts for cond_resched() will only
> > > count an uncongested call to congestion_wait() as unnecessary if the process
> > > actually gets scheduled. Ordinarily, we'd expect it to continue uninterrupted.
> > > 
> > > One vague concern I have is when too many pages are isolated, we call
> > > congestion_wait(). This could now actively spin in the loop for its quanta
> > > before calling cond_resched(). If it's calling with no congestion, it's
> > > hard to know what the proper thing to do there is.
> > 
> > Suddenly, many processes could enter into the direct reclaim path by another
> > reason(ex, fork bomb) regradless of congestion. backing dev congestion is 
> > just one of them. 
> > 
> 
> This situation applys with or without this series, right?

I think the situation applys with this series. That's because old behavior was calling
schedule regardless of I/O congested as seeing io_schedule_timeout.
But you are changing it now as calling it conditionally.

> 
> > I think if congestion_wait returns without calling io_schedule_timeout 
> > by your patch, too_many_isolated can schedule_timeout to wait for the system's 
> > calm to preventing OOM killing.
> > 
> 
> More likely, to stop a loop in too_many_isolated() consuming CPU time it
> can do nothing with.
> 
> > How about this?
> > 
> > If you don't mind, I will send the patch based on this patch series 
> > after your patch settle down or Could you add this to your patch series?
> > But I admit this doesn't almost affect your experiment. 
> > 
> 
> I think it's a related topic so could belong with the series.
> 
> > From 70d6584e125c3954d74a69bfcb72de17244635d2 Mon Sep 17 00:00:00 2001
> > From: Minchan Kim <minchan.kim@gmail.com>
> > Date: Fri, 27 Aug 2010 02:06:45 +0900
> > Subject: [PATCH] Wait regardless of congestion if too many pages are isolated
> > 
> > Suddenly, many processes could enter into the direct reclaim path
> > regradless of congestion. backing dev congestion is just one of them.
> > But current implementation calls congestion_wait if too many pages are isolated.
> > 
> > if congestion_wait returns without calling io_schedule_timeout,
> > too_many_isolated can schedule_timeout to wait for the system's calm
> > to preventing OOM killing.
> > 
> 
> I think the reasoning here might be a little off. How about;
> 
> If many processes enter direct reclaim or memory compaction, too many pages
> can get isolated. In this situation, too_many_isolated() can call
> congestion_wait() but if there is no congestion, it fails to go to sleep
> and instead spins until it's quota expires.
> 
> This patch checks if congestion_wait() returned without sleeping. If it
> did because there was no congestion, it unconditionally goes to sleep
> instead of hogging the CPU.

That's good to me. :)

> 
> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> > ---
> >  mm/backing-dev.c |    5 ++---
> >  mm/compaction.c  |    6 +++++-
> >  mm/vmscan.c      |    6 +++++-
> >  3 files changed, 12 insertions(+), 5 deletions(-)
> > 
> > diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> > index 6abe860..9431bca 100644
> > --- a/mm/backing-dev.c
> > +++ b/mm/backing-dev.c
> > @@ -756,8 +756,7 @@ EXPORT_SYMBOL(set_bdi_congested);
> >   * @timeout: timeout in jiffies
> >   *
> >   * Waits for up to @timeout jiffies for a backing_dev (any backing_dev) to exit
> > - * write congestion.  If no backing_devs are congested then just wait for the
> > - * next write to be completed.
> > + * write congestion.  If no backing_devs are congested then just returns.
> >   */  
> >  long congestion_wait(int sync, long timeout)
> >  {
> > @@ -776,7 +775,7 @@ long congestion_wait(int sync, long timeout)
> >         if (atomic_read(&nr_bdi_congested[sync]) == 0) {
> >                 unnecessary = true;
> >                 cond_resched();
> > -               ret = 0;
> > +               ret = timeout;
> >         } else {
> >                 prepare_to_wait(wqh, &wait, TASK_UNINTERRUPTIBLE);
> >                 ret = io_schedule_timeout(timeout);
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 94cce51..7370683 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -253,7 +253,11 @@ static unsigned long isolate_migratepages(struct zone *zone,
> >          * delay for some time until fewer pages are isolated
> >          */  
> >         while (unlikely(too_many_isolated(zone))) {
> > -               congestion_wait(BLK_RW_ASYNC, HZ/10);
> > +               long timeout = HZ/10;
> > +               if (timeout == congestion_wait(BLK_RW_ASYNC, timeout)) {
> > +                       set_current_state(TASK_INTERRUPTIBLE);
> > +                       schedule_timeout(timeout);
> > +               }
> > 
> 
> We don't really need the timeout variable here but I see what you are
> at. It's unfortunate to just go to sleep for HZ/10 but if it's not
> congestion, we do not have any other event to wake up on at the moment.
> We'd have to introduce a too_many_isolated waitqueue that is kicked if
> pages are put back on the LRU.

I thought it firstly but first of all, let's make sure how often this situation happens 
and it's really serious problem. I means it's rather overkill. 
> 
> This is better than spinning though.
> 
> >                 if (fatal_signal_pending(current))
> >                         return 0;
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 3109ff7..f5e3e28 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1337,7 +1337,11 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
> >         unsigned long nr_dirty;
> >         while (unlikely(too_many_isolated(zone, file, sc))) {
> > -               congestion_wait(BLK_RW_ASYNC, HZ/10);
> > +               long timeout = HZ/10;
> > +               if (timeout == congestion_wait(BLK_RW_ASYNC, timeout)) {
> > +                       set_current_state(TASK_INTERRUPTIBLE);
> > +                       schedule_timeout(timeout);
> > +               }
> > 
> >                 /* We are about to die and free our memory. Return now. */
> >                 if (fatal_signal_pending(current))
> 
> This seems very reasonable. I'll review it more carefully tomorrow and if I
> spot nothing horrible, I'll add it onto the series. I'm not sure I'm hitting
> the too_many_isolated() case but I cannot think of a better alternative
> without adding more waitqueues.

Thanks. Mel. 

> 
> -- 
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
