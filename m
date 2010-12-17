Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4D4106B009C
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 22:11:10 -0500 (EST)
Date: Fri, 17 Dec 2010 11:11:04 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 22/35] writeback: trace global dirty page states
Message-ID: <20101217031104.GA18860@localhost>
References: <20101213144646.341970461@intel.com>
 <20101213150329.002158963@intel.com>
 <20101217021934.GA9525@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101217021934.GA9525@localhost>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 17, 2010 at 10:19:34AM +0800, Wu Fengguang wrote:
> On Mon, Dec 13, 2010 at 10:47:08PM +0800, Wu, Fengguang wrote:
> 
> > +	TP_fast_assign(
> > +		strlcpy(__entry->bdi,
> > +			dev_name(mapping->backing_dev_info->dev), 32);
> > +		__entry->ino			= mapping->host->i_ino;
> 
> I got an oops against the above line on shmem. Can be fixed by the
> below patch, but still not 100% confident..

btw, here is a cleanup of the tracepoint.

Thanks,
Fengguang
---
Subject: writeback: simplify and rename tracepoint balance_dirty_state to global_dirty_state
Date: Fri Dec 17 10:37:35 CST 2010

Make it a more clean interface, and also track the background flusher
when it calls over_bground_thresh() to check the global limits.

The removed information could go into tracepoint balance_dirty_pages.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/trace/events/writeback.h |   37 +++++++----------------------
 mm/page-writeback.c              |   16 +++---------
 2 files changed, 13 insertions(+), 40 deletions(-)

--- linux-next.orig/include/trace/events/writeback.h	2010-12-17 11:05:08.000000000 +0800
+++ linux-next/include/trace/events/writeback.h	2010-12-17 11:06:20.000000000 +0800
@@ -149,60 +149,41 @@ DEFINE_WBC_EVENT(wbc_writeback_written);
 DEFINE_WBC_EVENT(wbc_writeback_wait);
 DEFINE_WBC_EVENT(wbc_writepage);
 
-TRACE_EVENT(balance_dirty_state,
+TRACE_EVENT(global_dirty_state,
 
-	TP_PROTO(struct address_space *mapping,
-		 unsigned long nr_dirty,
-		 unsigned long nr_writeback,
-		 unsigned long nr_unstable,
-		 unsigned long background_thresh,
+	TP_PROTO(unsigned long background_thresh,
 		 unsigned long dirty_thresh
 	),
 
-	TP_ARGS(mapping,
-		nr_dirty,
-		nr_writeback,
-		nr_unstable,
-		background_thresh,
+	TP_ARGS(background_thresh,
 		dirty_thresh
 	),
 
 	TP_STRUCT__entry(
-		__array(char,		bdi, 32)
-		__field(unsigned long,	ino)
 		__field(unsigned long,	nr_dirty)
 		__field(unsigned long,	nr_writeback)
 		__field(unsigned long,	nr_unstable)
 		__field(unsigned long,	background_thresh)
 		__field(unsigned long,	dirty_thresh)
-		__field(unsigned long,	task_dirtied_pause)
 	),
 
 	TP_fast_assign(
-		strlcpy(__entry->bdi,
-			dev_name(mapping->backing_dev_info->dev), 32);
-		__entry->ino			= mapping->host->i_ino;
-		__entry->nr_dirty		= nr_dirty;
-		__entry->nr_writeback		= nr_writeback;
-		__entry->nr_unstable		= nr_unstable;
+		__entry->nr_dirty	= global_page_state(NR_FILE_DIRTY);
+		__entry->nr_writeback	= global_page_state(NR_WRITEBACK);
+		__entry->nr_unstable	= global_page_state(NR_UNSTABLE_NFS);
 		__entry->background_thresh	= background_thresh;
 		__entry->dirty_thresh		= dirty_thresh;
-		__entry->task_dirtied_pause	= current->nr_dirtied_pause;
 	),
 
-	TP_printk("bdi %s: dirty=%lu wb=%lu unstable=%lu "
-		  "bg_thresh=%lu thresh=%lu gap=%ld "
-		  "poll_thresh=%lu ino=%lu",
-		  __entry->bdi,
+	TP_printk("dirty=%lu writeback=%lu unstable=%lu "
+		  "bg_thresh=%lu thresh=%lu gap=%ld",
 		  __entry->nr_dirty,
 		  __entry->nr_writeback,
 		  __entry->nr_unstable,
 		  __entry->background_thresh,
 		  __entry->dirty_thresh,
 		  __entry->dirty_thresh - __entry->nr_dirty -
-		  __entry->nr_writeback - __entry->nr_unstable,
-		  __entry->task_dirtied_pause,
-		  __entry->ino
+		  __entry->nr_writeback - __entry->nr_unstable
 	)
 );
 
--- linux-next.orig/mm/page-writeback.c	2010-12-17 11:05:08.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-17 11:05:09.000000000 +0800
@@ -418,6 +418,7 @@ void global_dirty_limits(unsigned long *
 	}
 	*pbackground = background;
 	*pdirty = dirty;
+	trace_global_dirty_state(background, dirty);
 }
 
 /**
@@ -712,21 +713,12 @@ static void balance_dirty_pages(struct a
 		 * written to the server's write cache, but has not yet
 		 * been flushed to permanent storage.
 		 */
-		nr_reclaimable = global_page_state(NR_FILE_DIRTY);
-		bdi_dirty = global_page_state(NR_UNSTABLE_NFS);
-		nr_dirty = global_page_state(NR_WRITEBACK);
+		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
+					global_page_state(NR_UNSTABLE_NFS);
+		nr_dirty = nr_reclaimable + global_page_state(NR_WRITEBACK);
 
 		global_dirty_limits(&background_thresh, &dirty_thresh);
 
-		trace_balance_dirty_state(mapping,
-					  nr_reclaimable,
-					  nr_dirty,
-					  bdi_dirty,
-					  background_thresh,
-					  dirty_thresh);
-		nr_reclaimable += bdi_dirty;
-		nr_dirty += nr_reclaimable;
-
 		/*
 		 * Throttle it only when the background writeback cannot
 		 * catch-up. This avoids (excessively) small writeouts

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
