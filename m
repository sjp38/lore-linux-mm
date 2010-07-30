Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F3CCE6B02A4
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 00:03:11 -0400 (EDT)
Date: Fri, 30 Jul 2010 12:03:06 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: stop periodic/background work on seeing
 sync works
Message-ID: <20100730040306.GA5694@localhost>
References: <20100729115142.102255590@intel.com>
 <20100729121423.332557547@intel.com>
 <20100729162027.GF12690@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100729162027.GF12690@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 30, 2010 at 12:20:27AM +0800, Jan Kara wrote:
> On Thu 29-07-10 19:51:44, Wu Fengguang wrote:
> > The periodic/background writeback can run forever. So when any
> > sync work is enqueued, increase bdi->sync_works to notify the
> > active non-sync works to exit. Non-sync works queued after sync
> > works won't be affected.
>   Hmm, wouldn't it be simpler logic to just make for_kupdate and
> for_background work always yield when there's some other work to do (as
> they are livelockable from the definition of the target they have) and
> make sure any other work isn't livelockable?

Good idea!

> The only downside is that
> non-livelockable work cannot be "fair" in the sense that we cannot switch
> inodes after writing MAX_WRITEBACK_PAGES.

Cannot switch indoes _before_ finish with the current
MAX_WRITEBACK_PAGES batch? 

>   I even had a patch for this but it's already outdated by now. But I
> can refresh it if we decide this is the way to go.

I'm very interested in your old patch, would you post it? Let's see
which one is easier to work with :)

Thanks,
Fengguang

> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  fs/fs-writeback.c           |   13 +++++++++++++
> >  include/linux/backing-dev.h |    6 ++++++
> >  mm/backing-dev.c            |    1 +
> >  3 files changed, 20 insertions(+)
> > 
> > --- linux-next.orig/fs/fs-writeback.c	2010-07-29 17:13:23.000000000 +0800
> > +++ linux-next/fs/fs-writeback.c	2010-07-29 17:13:49.000000000 +0800
> > @@ -80,6 +80,8 @@ static void bdi_queue_work(struct backin
> >  
> >  	spin_lock(&bdi->wb_lock);
> >  	list_add_tail(&work->list, &bdi->work_list);
> > +	if (work->for_sync)
> > +		atomic_inc(&bdi->wb.sync_works);
> >  	spin_unlock(&bdi->wb_lock);
> >  
> >  	/*
> > @@ -633,6 +635,14 @@ static long wb_writeback(struct bdi_writ
> >  			break;
> >  
> >  		/*
> > +		 * background/periodic works can run forever, need to abort
> > +		 * on seeing any pending sync work, to prevent livelock it.
> > +		 */
> > +		if (atomic_read(&wb->sync_works) &&
> > +		    (work->for_background || work->for_kupdate))
> > +			break;
> > +
> > +		/*
> >  		 * For background writeout, stop when we are below the
> >  		 * background dirty threshold
> >  		 */
> > @@ -765,6 +775,9 @@ long wb_do_writeback(struct bdi_writebac
> >  
> >  		wrote += wb_writeback(wb, work);
> >  
> > +		if (work->for_sync)
> > +			atomic_dec(&wb->sync_works);
> > +
> >  		/*
> >  		 * Notify the caller of completion if this is a synchronous
> >  		 * work item, otherwise just free it.
> > --- linux-next.orig/include/linux/backing-dev.h	2010-07-29 17:13:23.000000000 +0800
> > +++ linux-next/include/linux/backing-dev.h	2010-07-29 17:13:31.000000000 +0800
> > @@ -50,6 +50,12 @@ struct bdi_writeback {
> >  
> >  	unsigned long last_old_flush;		/* last old data flush */
> >  
> > +	/*
> > +	 * sync works queued, background works shall abort on seeing this,
> > +	 * to prevent livelocking the sync works
> > +	 */
> > +	atomic_t sync_works;
> > +
> >  	struct task_struct	*task;		/* writeback task */
> >  	struct list_head	b_dirty;	/* dirty inodes */
> >  	struct list_head	b_io;		/* parked for writeback */
> > --- linux-next.orig/mm/backing-dev.c	2010-07-29 17:13:23.000000000 +0800
> > +++ linux-next/mm/backing-dev.c	2010-07-29 17:13:31.000000000 +0800
> > @@ -257,6 +257,7 @@ static void bdi_wb_init(struct bdi_write
> >  
> >  	wb->bdi = bdi;
> >  	wb->last_old_flush = jiffies;
> > +	atomic_set(&wb->sync_works, 0);
> >  	INIT_LIST_HEAD(&wb->b_dirty);
> >  	INIT_LIST_HEAD(&wb->b_io);
> >  	INIT_LIST_HEAD(&wb->b_more_io);
> > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> -- 
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
