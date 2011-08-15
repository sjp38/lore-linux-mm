Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A68E66B00EE
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 10:21:49 -0400 (EDT)
Date: Mon, 15 Aug 2011 22:21:41 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/5] writeback: per task dirty rate limit
Message-ID: <20110815142141.GC23601@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094527.002914580@intel.com>
 <1312811234.10488.34.camel@twins>
 <20110808142318.GC22080@localhost>
 <20110813162826.GA1646@thinkpad>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="KsGdsel6WgEHnImy"
Content-Disposition: inline
In-Reply-To: <20110813162826.GA1646@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Andrea,

> > @@ -1158,6 +1160,15 @@ void balance_dirty_pages_ratelimited_nr(
> >  	if (bdi->dirty_exceeded)
> >  		ratelimit = 8;
> >  
> > +	preempt_disable();
> > +	p = &__get_cpu_var(dirty_leaks);
> > +	if (*p > 0 && current->nr_dirtied < ratelimit) {
> > +		nr_pages_dirtied = min(*p, ratelimit - current->nr_dirtied);
> > +		*p -= nr_pages_dirtied;
> > +		current->nr_dirtied += nr_pages_dirtied;
> > +	}
> > +	preempt_enable();
> > +
> 
> I think we are still leaking some dirty pages, when the condition is
> false nr_pages_dirtied is just ignored.
> 
> Why not doing something like this?
> 
> 	current->nr_dirtied += nr_pages_dirtied;

You must mean the above line. Sorry I failed to provide another patch
before this one (attached this time). With that preparation patch, it
effectively become equal to the logic below :)

> 	if (current->nr_dirtied < ratelimit) {
> 		p = &get_cpu_var(dirty_leaks);
> 		if (*p > 0) {
> 			nr_pages_dirtied = min(*p, ratelimit -
> 							current->nr_dirtied);
> 			*p -= nr_pages_dirtied;
> 		} else
> 			nr_pages_dirtied = 0;
> 		put_cpu_var(dirty_leaks);
> 
> 		current->nr_dirtied += nr_pages_dirtied;
> 	}

Thanks,
Fengguang

> >  	if (unlikely(current->nr_dirtied >= ratelimit))
> >  		balance_dirty_pages(mapping, current->nr_dirtied);
> >  }
> > --- linux-next.orig/kernel/exit.c	2011-08-08 21:43:37.000000000 +0800
> > +++ linux-next/kernel/exit.c	2011-08-08 21:45:58.000000000 +0800
> > @@ -1039,6 +1039,8 @@ NORET_TYPE void do_exit(long code)
> >  	validate_creds_for_do_exit(tsk);
> >  
> >  	preempt_disable();
> > +	if (tsk->nr_dirtied)
> > +		__this_cpu_add(dirty_leaks, tsk->nr_dirtied);
> >  	exit_rcu();
> >  	/* causes final put_task_struct in finish_task_switch(). */
> >  	tsk->state = TASK_DEAD;

--KsGdsel6WgEHnImy
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="writeback-accurate-task-dirtied.patch"

Subject: writeback: fix dirtied pages accounting on sub-page writes
Date: Thu Apr 14 07:52:37 CST 2011

When dd in 512bytes, generic_perform_write() calls
balance_dirty_pages_ratelimited() 8 times for the same page, but
obviously the page is only dirtied once.

Fix it by accounting nr_dirtied at page dirty time.

This will allow further simplification of the
balance_dirty_pages_ratelimited_nr() calls.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-08-15 22:12:14.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-15 22:12:27.000000000 +0800
@@ -1211,8 +1211,6 @@ void balance_dirty_pages_ratelimited_nr(
 	else
 		ratelimit = min(ratelimit, 32 >> (PAGE_SHIFT - 10));
 
-	current->nr_dirtied += nr_pages_dirtied;
-
 	preempt_disable();
 	/*
 	 * This prevents one CPU to accumulate too many dirtied pages without
@@ -1711,6 +1709,7 @@ void account_page_dirtied(struct page *p
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_DIRTIED);
 		task_dirty_inc(current);
 		task_io_account_write(PAGE_CACHE_SIZE);
+		current->nr_dirtied++;
 	}
 }
 EXPORT_SYMBOL(account_page_dirtied);

--KsGdsel6WgEHnImy--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
