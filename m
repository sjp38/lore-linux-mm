Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A85786B00BC
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 01:28:21 -0400 (EDT)
Date: Mon, 25 Oct 2010 13:28:18 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] memory-hotplug: only drain LRU when failed to offline
 pages
Message-ID: <20101025052818.GA23237@localhost>
References: <20101025051202.GA22412@localhost>
 <20101025141519.7fd32b1c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101025141519.7fd32b1c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 25, 2010 at 01:15:19PM +0800, KAMEZAWA Hiroyuki wrote:
> On Mon, 25 Oct 2010 13:12:02 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > do_migrate_range() offlines 1MB pages at one time and hence might be
> > called up to 16000 times when trying to offline 16GB memory. 
> 
> But size of memory section is not such big.

It's NR_OFFLINE_AT_ONCE_PAGES=256 (1MB).

> > It makes sense to avoid sending the costly IPIs to drain pages on all LRU for
> > the 99% cases that do_migrate_range() succeeds offlining some pages.
> > 
> 
> did you test ? I think this patch should be tested by IBM guys.

Only compile tested..

> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> 
> Sorry, this will HUNK. Could you wait until the end of merge window ?

OK, I'll resend.

> 
> > ---
> >  mm/memory_hotplug.c |   24 ++++++++++--------------
> >  1 file changed, 10 insertions(+), 14 deletions(-)
> > 
> > --- linux-next.orig/mm/memory_hotplug.c	2010-10-25 11:20:47.000000000 +0800
> > +++ linux-next/mm/memory_hotplug.c	2010-10-25 13:07:10.000000000 +0800
> > @@ -788,7 +788,7 @@ static int offline_pages(unsigned long s
> >  {
> >  	unsigned long pfn, nr_pages, expire;
> >  	long offlined_pages;
> > -	int ret, drain, retry_max, node;
> > +	int ret, retry_max, node;
> >  	struct zone *zone;
> >  	struct memory_notify arg;
> >  
> > @@ -827,7 +827,6 @@ static int offline_pages(unsigned long s
> >  
> >  	pfn = start_pfn;
> >  	expire = jiffies + timeout;
> > -	drain = 0;
> >  	retry_max = 5;
> >  repeat:
> >  	/* start memory hot removal */
> > @@ -838,34 +837,31 @@ repeat:
> >  	if (signal_pending(current))
> >  		goto failed_removal;
> >  	ret = 0;
> > -	if (drain) {
> > -		lru_add_drain_all();
> > -		flush_scheduled_work();
> 
> this flush_scheduled_work() is removed in recent work of Tejun Heo.

Ah yes.

> > -		cond_resched();
> > -		drain_all_pages();
> > -	}
> > -
> >  	pfn = scan_lru_pages(start_pfn, end_pfn);
> >  	if (pfn) { /* We have page on LRU */
> >  		ret = do_migrate_range(pfn, end_pfn);
> >  		if (!ret) {
> > -			drain = 1;
> >  			goto repeat;
> >  		} else {
> >  			if (ret < 0)
> >  				if (--retry_max == 0)
> >  					goto failed_removal;
> >  			yield();
> > -			drain = 1;
> > +			lru_add_drain_all();
> > +			flush_scheduled_work();
> This flush is unnecessary.

OK. 

> > +			cond_resched();
> > +			drain_all_pages();
> 
> I think followin is  better order.
> 
> drain_all_pages();      # SEND IPI and asynchronous.
> lru_add_drain_pages();  # call schedule_work ony by one and it's synchronous.
> cond_resched();	# may not be unnecessary (lru_add_drain_pages() will sleep.)

That looks better. I'll remove cond_resched() too.

> >  			goto repeat;
> >  		}
> >  	}
> > -	/* drain all zone's lru pagevec, this is asyncronous... */
> > +
> > +	/* drain all zone's lru pagevec, this is asynchronous... */
> >  	lru_add_drain_all();
> >  	flush_scheduled_work();
> This flush() is dropped by recent works of Tejun Heo's workqueue updates.

OK.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
