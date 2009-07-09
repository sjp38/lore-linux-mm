Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0502A6B009E
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 22:54:23 -0400 (EDT)
Date: Thu, 9 Jul 2009 11:07:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC PATCH 1/2] vmscan don't isolate too many pages in a zone
Message-ID: <20090709030731.GA17097@localhost>
References: <20090707182947.0C6D.A69D9226@jp.fujitsu.com> <20090707184034.0C70.A69D9226@jp.fujitsu.com> <4A539B11.5020803@redhat.com> <20090708031901.GA9924@localhost> <20090708215105.5016c929@bree.surriel.com> <20090709024710.GA16783@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090709024710.GA16783@localhost>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 09, 2009 at 10:47:10AM +0800, Wu Fengguang wrote:
> On Thu, Jul 09, 2009 at 09:51:05AM +0800, Rik van Riel wrote:
> > When way too many processes go into direct reclaim, it is possible
> > for all of the pages to be taken off the LRU.  One result of this
> > is that the next process in the page reclaim code thinks there are
> > no reclaimable pages left and triggers an out of memory kill.
> > 
> > One solution to this problem is to never let so many processes into
> > the page reclaim path that the entire LRU is emptied.  Limiting the
> > system to only having half of each inactive list isolated for
> > reclaim should be safe.
> > 
> > Signed-off-by: Rik van Riel <riel@redhat.com>
> > ---
> > On Wed, 8 Jul 2009 11:19:01 +0800
> > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > > > I guess I should mail out my (ugly) approach, so we can
> > > > compare the two :)
> > > 
> > > And it helps to be aware of all the alternatives, now and future :)
> > 
> > Here is the per-zone alternative to Kosaki's patch.
> > 
> > I believe Kosaki's patch will result in better performance
> > and is more elegant overall, but here it is :)
> > 
> >  mm/vmscan.c |   25 +++++++++++++++++++++++++
> >  1 file changed, 25 insertions(+)
> > 
> > Index: mmotm/mm/vmscan.c
> > ===================================================================
> > --- mmotm.orig/mm/vmscan.c	2009-07-08 21:37:01.000000000 -0400
> > +++ mmotm/mm/vmscan.c	2009-07-08 21:39:02.000000000 -0400
> > @@ -1035,6 +1035,27 @@ int isolate_lru_page(struct page *page)
> >  }
> >  
> >  /*
> > + * Are there way too many processes in the direct reclaim path already?
> > + */
> > +static int too_many_isolated(struct zone *zone, int file)
> > +{
> > +	unsigned long inactive, isolated;
> > +
> > +	if (current_is_kswapd())
> > +		return 0;
> > +
> > +	if (file) {
> > +		inactive = zone_page_state(zone, NR_INACTIVE_FILE);
> > +		isolated = zone_page_state(zone, NR_ISOLATED_FILE);
> > +	} else {
> > +		inactive = zone_page_state(zone, NR_INACTIVE_ANON);
> > +		isolated = zone_page_state(zone, NR_ISOLATED_ANON);
> > +	}
> > +
> > +	return isolated > inactive;
> > +}
> > +
> > +/*
> >   * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
> >   * of reclaimed pages
> >   */
> > @@ -1049,6 +1070,10 @@ static unsigned long shrink_inactive_lis
> >  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
> >  	int lumpy_reclaim = 0;
> >  
> > +	while (unlikely(too_many_isolated(zone, file))) {
> > +		schedule_timeout_interruptible(HZ/10);
> > +	}
> > +
> >  	/*
> >  	 * If we need a large contiguous chunk of memory, or have
> >  	 * trouble getting a small set of contiguous pages, we
> 
> It survives 5 runs. The first 4 runs are relatively smooth. The 5th run is much
> slower, and the 6th run triggered a soft-lockup warning. Anyway this record seems
> better than KOSAKI's patch, which triggered soft-lockup at the first run yesterday.
> 
>         Last login: Wed Jul  8 11:10:06 2009 from 192.168.2.1
> 1)      wfg@hp ~% /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11
>         msgctl11    0  INFO  :  Using upto 16300 pids
>         msgctl11    1  PASS  :  msgctl11 ran successfully!
> 2)      wfg@hp ~% /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11
>         msgctl11    0  INFO  :  Using upto 16300 pids
>         msgctl11    1  PASS  :  msgctl11 ran successfully!
> 3)      wfg@hp ~% /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11
>         msgctl11    0  INFO  :  Using upto 16300 pids
>         msgctl11    1  PASS  :  msgctl11 ran successfully!
> 4)      wfg@hp ~% time /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11
>         msgctl11    0  INFO  :  Using upto 16300 pids
>         msgctl11    1  PASS  :  msgctl11 ran successfully!
>         /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11  3.38s user 52.90s system 191% cpu 29.399 total
> 5)      wfg@hp ~% time /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11
>         msgctl11    0  INFO  :  Using upto 16300 pids
>         msgctl11    1  PASS  :  msgctl11 ran successfully!
>         /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11  4.54s user 488.33s system 129% cpu 6:19.14 total
> 6)      wfg@hp ~% time /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11
>         msgctl11    0  INFO  :  Using upto 16300 pids
>         msgctl11    1  PASS  :  msgctl11 ran successfully!
>         /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11  4.62s user 778.82s system 149% cpu 8:43.85 total

I tried the semaphore based concurrent direct reclaim throttling, and
get these numbers. The run time is normal 30s, but can sometimes go up
by many folds. It seems that there are more hidden problems..

Last login: Thu Jul  9 10:13:12 2009 from 192.168.2.1
wfg@hp ~% time /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11
msgctl11    0  INFO  :  Using upto 16298 pids
msgctl11    1  PASS  :  msgctl11 ran successfully!
/cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11  3.38s user 51.28s system 182% cpu 30.002 total
wfg@hp ~% time /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11
msgctl11    0  INFO  :  Using upto 16298 pids
msgctl11    1  PASS  :  msgctl11 ran successfully!
/cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11  3.78s user 52.04s system 185% cpu 30.168 total
wfg@hp ~% time /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11
msgctl11    0  INFO  :  Using upto 16298 pids
msgctl11    1  PASS  :  msgctl11 ran successfully!
/cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11  3.59s user 51.95s system 193% cpu 28.628 total
wfg@hp ~% time /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11
msgctl11    0  INFO  :  Using upto 16298 pids
msgctl11    1  PASS  :  msgctl11 ran successfully!
/cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11  3.87s user 283.66s system 167% cpu 2:51.17 total
wfg@hp ~% time /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11
msgctl11    0  INFO  :  Using upto 16297 pids
msgctl11    1  PASS  :  msgctl11 ran successfully!
/cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11  3.32s user 49.80s system 178% cpu 29.673 total
wfg@hp ~% time /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11
msgctl11    0  INFO  :  Using upto 16297 pids
msgctl11    1  PASS  :  msgctl11 ran successfully!
/cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11  3.70s user 52.56s system 190% cpu 29.601 total
wfg@hp ~% time /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11
msgctl11    0  INFO  :  Using upto 16297 pids
msgctl11    1  PASS  :  msgctl11 ran successfully!
/cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11  3.92s user 251.55s system 158% cpu 2:41.40 total
wfg@hp ~% time /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11
msgctl11    0  INFO  :  Using upto 16297 pids
(soft lockup)

--- linux.orig/mm/vmscan.c
+++ linux/mm/vmscan.c
@@ -1042,6 +1042,7 @@ static unsigned long shrink_inactive_lis
 	unsigned long nr_reclaimed = 0;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 	int lumpy_reclaim = 0;
+	static struct semaphore direct_reclaim_sem = __SEMAPHORE_INITIALIZER(direct_reclaim_sem, 32);
 
 	/*
 	 * If we need a large contiguous chunk of memory, or have
@@ -1057,6 +1058,9 @@ static unsigned long shrink_inactive_lis
 
 	pagevec_init(&pvec, 1);
 
+	if (!current_is_kswapd())
+		down(&direct_reclaim_sem);
+
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 	do {
@@ -1173,6 +1177,10 @@ static unsigned long shrink_inactive_lis
 done:
 	local_irq_enable();
 	pagevec_release(&pvec);
+
+	if (!current_is_kswapd())
+		up(&direct_reclaim_sem);
+
 	return nr_reclaimed;
 }
 
 Thanks,
 Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
