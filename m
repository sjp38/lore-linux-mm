Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0352E8D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 07:20:48 -0400 (EDT)
Date: Tue, 19 Apr 2011 15:20:40 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/6] writeback: the kupdate expire timestamp should be
 a moving target
Message-ID: <20110419072040.GA6404@localhost>
References: <20110419030003.108796967@intel.com>
 <20110419030532.392203618@intel.com>
 <20110419070247.GE23985@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110419070247.GE23985@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Trond Myklebust <Trond.Myklebust@netapp.com>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Tue, Apr 19, 2011 at 03:02:47PM +0800, Dave Chinner wrote:
> On Tue, Apr 19, 2011 at 11:00:05AM +0800, Wu Fengguang wrote:
> > Dynamically compute the dirty expire timestamp at queue_io() time.
> > 
> > writeback_control.older_than_this used to be determined at entrance to
> > the kupdate writeback work. This _static_ timestamp may go stale if the
> > kupdate work runs on and on. The flusher may then stuck with some old
> > busy inodes, never considering newly expired inodes thereafter.
> > 
> > This has two possible problems:
> > 
> > - It is unfair for a large dirty inode to delay (for a long time) the
> >   writeback of small dirty inodes.
> > 
> > - As time goes by, the large and busy dirty inode may contain only
> >   _freshly_ dirtied pages. Ignoring newly expired dirty inodes risks
> >   delaying the expired dirty pages to the end of LRU lists, triggering
> >   the evil pageout(). Nevertheless this patch merely addresses part
> >   of the problem.
> 
> When wb_writeback() is called with for_kupdate set, it initialises
> wbc->older_than_this appropriately outside the writeback loop.
> queue_io() is called once per writeback_inodes_wb() call, which is
> once per loop in wb_writeback. All your change does is re-initialise
> older_than_this once per loop in wb_writeback, jus tin a different
> and very non-obvious place.
> 
> So why didn't you just re-initialise it inside the loop in
> wb_writeback() and leave all the other code alone?

It helps both readability and efficiency to make it a local var.

I have another patch to kill the wbc->older_than_this (and one more
for wbc->more_io). They are delayed to avoid possible merge conflicts
with the IO-less patchset.

But yeah, it seems reasonable to move the first chunk of the below
patch to this one.

Thanks,
Fengguang
---
Subject: writeback: the kupdate expire timestamp should be a moving target
Date: Wed Jul 21 20:32:30 CST 2010

Remove writeback_control.older_than_this which is no longer used.

[kitayama@cl.bb4u.ne.jp] fix btrfs and ext4 references

Acked-by: Jan Kara <jack@suse.cz>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Itaru Kitayama <kitayama@cl.bb4u.ne.jp>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/btrfs/extent_io.c             |    2 --
 fs/fs-writeback.c                |   13 -------------
 include/linux/writeback.h        |    2 --
 include/trace/events/writeback.h |    6 +-----
 mm/backing-dev.c                 |    1 -
 5 files changed, 1 insertion(+), 23 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2011-04-18 08:37:01.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2011-04-18 08:38:16.000000000 +0800
@@ -681,30 +681,20 @@ static unsigned long writeback_chunk_siz
  * Try to run once per dirty_writeback_interval.  But if a writeback event
  * takes longer than a dirty_writeback_interval interval, then leave a
  * one-second gap.
- *
- * older_than_this takes precedence over nr_to_write.  So we'll only write back
- * all dirty pages if they are all attached to "old" mappings.
  */
 static long wb_writeback(struct bdi_writeback *wb,
 			 struct wb_writeback_work *work)
 {
 	struct writeback_control wbc = {
 		.sync_mode		= work->sync_mode,
-		.older_than_this	= NULL,
 		.for_kupdate		= work->for_kupdate,
 		.for_background		= work->for_background,
 		.range_cyclic		= work->range_cyclic,
 	};
-	unsigned long oldest_jif;
 	long wrote = 0;
 	long write_chunk;
 	struct inode *inode;
 
-	if (wbc.for_kupdate) {
-		wbc.older_than_this = &oldest_jif;
-		oldest_jif = jiffies -
-				msecs_to_jiffies(dirty_expire_interval * 10);
-	}
 	if (!wbc.range_cyclic) {
 		wbc.range_start = 0;
 		wbc.range_end = LLONG_MAX;
@@ -1139,9 +1129,6 @@ EXPORT_SYMBOL(__mark_inode_dirty);
  * Write out a superblock's list of dirty inodes.  A wait will be performed
  * upon no inodes, all inodes or the final one, depending upon sync_mode.
  *
- * If older_than_this is non-NULL, then only write out inodes which
- * had their first dirtying at a time earlier than *older_than_this.
- *
  * If `bdi' is non-zero then we're being asked to writeback a specific queue.
  * This function assumes that the blockdev superblock's inodes are backed by
  * a variety of queues, so all inodes are searched.  For other superblocks,
--- linux-next.orig/include/linux/writeback.h	2011-04-18 08:36:59.000000000 +0800
+++ linux-next/include/linux/writeback.h	2011-04-18 08:38:16.000000000 +0800
@@ -66,8 +66,6 @@ enum writeback_sync_modes {
  */
 struct writeback_control {
 	enum writeback_sync_modes sync_mode;
-	unsigned long *older_than_this;	/* If !NULL, only write back inodes
-					   older than this */
 	unsigned long wb_start;         /* Time writeback_inodes_wb was
 					   called. This is needed to avoid
 					   extra jobs and livelock */
--- linux-next.orig/include/trace/events/writeback.h	2011-04-18 08:36:59.000000000 +0800
+++ linux-next/include/trace/events/writeback.h	2011-04-18 08:38:16.000000000 +0800
@@ -115,7 +115,6 @@ DECLARE_EVENT_CLASS(wbc_class,
 		__field(int, for_reclaim)
 		__field(int, range_cyclic)
 		__field(int, more_io)
-		__field(unsigned long, older_than_this)
 		__field(long, range_start)
 		__field(long, range_end)
 	),
@@ -130,14 +129,12 @@ DECLARE_EVENT_CLASS(wbc_class,
 		__entry->for_reclaim	= wbc->for_reclaim;
 		__entry->range_cyclic	= wbc->range_cyclic;
 		__entry->more_io	= wbc->more_io;
-		__entry->older_than_this = wbc->older_than_this ?
-						*wbc->older_than_this : 0;
 		__entry->range_start	= (long)wbc->range_start;
 		__entry->range_end	= (long)wbc->range_end;
 	),
 
 	TP_printk("bdi %s: towrt=%ld skip=%ld mode=%d kupd=%d "
-		"bgrd=%d reclm=%d cyclic=%d more=%d older=0x%lx "
+		"bgrd=%d reclm=%d cyclic=%d more=%d "
 		"start=0x%lx end=0x%lx",
 		__entry->name,
 		__entry->nr_to_write,
@@ -148,7 +145,6 @@ DECLARE_EVENT_CLASS(wbc_class,
 		__entry->for_reclaim,
 		__entry->range_cyclic,
 		__entry->more_io,
-		__entry->older_than_this,
 		__entry->range_start,
 		__entry->range_end)
 )
--- linux-next.orig/mm/backing-dev.c	2011-04-18 08:36:59.000000000 +0800
+++ linux-next/mm/backing-dev.c	2011-04-18 08:38:16.000000000 +0800
@@ -263,7 +263,6 @@ static void bdi_flush_io(struct backing_
 {
 	struct writeback_control wbc = {
 		.sync_mode		= WB_SYNC_NONE,
-		.older_than_this	= NULL,
 		.range_cyclic		= 1,
 		.nr_to_write		= 1024,
 	};
--- linux-next.orig/fs/btrfs/extent_io.c	2011-04-18 08:36:59.000000000 +0800
+++ linux-next/fs/btrfs/extent_io.c	2011-04-18 08:38:16.000000000 +0800
@@ -2556,7 +2556,6 @@ int extent_write_full_page(struct extent
 	};
 	struct writeback_control wbc_writepages = {
 		.sync_mode	= wbc->sync_mode,
-		.older_than_this = NULL,
 		.nr_to_write	= 64,
 		.range_start	= page_offset(page) + PAGE_CACHE_SIZE,
 		.range_end	= (loff_t)-1,
@@ -2589,7 +2588,6 @@ int extent_write_locked_range(struct ext
 	};
 	struct writeback_control wbc_writepages = {
 		.sync_mode	= mode,
-		.older_than_this = NULL,
 		.nr_to_write	= nr_pages * 2,
 		.range_start	= start,
 		.range_end	= end + 1,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
