Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 196906B0093
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 16:37:08 -0400 (EDT)
Date: Tue, 2 Nov 2010 04:37:02 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/2] writeback: integrated background writeback work
Message-ID: <20101101203702.GA7309@localhost>
References: <20100913123110.372291929@intel.com>
 <20100913130149.994322762@intel.com>
 <20100914124033.GA4874@quack.suse.cz>
 <20101101121408.GB9006@localhost>
 <20101101152149.GA12741@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101101152149.GA12741@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 01, 2010 at 11:21:50PM +0800, Christoph Hellwig wrote:
> > +static void _bdi_wakeup_flusher(struct backing_dev_info *bdi)
> 
> Remove the leading underscore, please.

OK, makes sense. The updated patch will follow.

> >  void bdi_start_background_writeback(struct backing_dev_info *bdi)
> >  {
> > -	__bdi_start_writeback(bdi, LONG_MAX, true, true);
> > +	/*
> > +	 * We just wake up the flusher thread. It will perform background
> > +	 * writeback as soon as there is no other work to do.
> > +	 */
> > +	spin_lock_bh(&bdi->wb_lock);
> > +	_bdi_wakeup_flusher(bdi);
> > +	spin_unlock_bh(&bdi->wb_lock);
> 
> We probably want a trace point here, too.
> 
> Otherwise the patch looks good to me.  Thanks for bringing it up again.

Thanks. It's trivial to add the trace point, here is the incremental
patch.

Thanks,
Fengguang

---
writeback: trace wakeup event for background writeback

This tracks when balance_dirty_pages() tries to wakeup the flusher
thread for background writeback (if it was not started already).

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c                |    1 +
 include/trace/events/writeback.h |    1 +
 2 files changed, 2 insertions(+)

--- linux-next.orig/include/trace/events/writeback.h	2010-11-02 04:17:26.000000000 +0800
+++ linux-next/include/trace/events/writeback.h	2010-11-02 04:21:02.000000000 +0800
@@ -81,6 +81,7 @@ DEFINE_EVENT(writeback_class, name, \
 	TP_ARGS(bdi))
 
 DEFINE_WRITEBACK_EVENT(writeback_nowork);
+DEFINE_WRITEBACK_EVENT(writeback_wake_background);
 DEFINE_WRITEBACK_EVENT(writeback_wake_thread);
 DEFINE_WRITEBACK_EVENT(writeback_wake_forker_thread);
 DEFINE_WRITEBACK_EVENT(writeback_bdi_register);
--- linux-next.orig/fs/fs-writeback.c	2010-11-02 04:22:17.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-11-02 04:22:33.000000000 +0800
@@ -164,6 +164,7 @@ void bdi_start_background_writeback(stru
 	 * We just wake up the flusher thread. It will perform background
 	 * writeback as soon as there is no other work to do.
 	 */
+	trace_writeback_wake_background(bdi);
 	spin_lock_bh(&bdi->wb_lock);
 	bdi_wakeup_flusher(bdi);
 	spin_unlock_bh(&bdi->wb_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
