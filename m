Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4A8849000C2
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 00:53:17 -0400 (EDT)
Date: Tue, 5 Jul 2011 21:53:01 -0700
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 03/27] xfs: use write_cache_pages for writeback
 clustering
Message-ID: <20110706045301.GA11604@localhost>
References: <20110629140109.003209430@bombadil.infradead.org>
 <20110629140336.950805096@bombadil.infradead.org>
 <20110701022248.GM561@dastard>
 <20110701041851.GN561@dastard>
 <20110701093305.GA28531@infradead.org>
 <20110701154136.GA17881@localhost>
 <20110704032534.GD1026@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110704032534.GD1026@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jul 04, 2011 at 11:25:34AM +0800, Dave Chinner wrote:
> On Fri, Jul 01, 2011 at 11:41:36PM +0800, Wu Fengguang wrote:
> > Christoph,
> > 
> > On Fri, Jul 01, 2011 at 05:33:05PM +0800, Christoph Hellwig wrote:
> > > Johannes, Mel, Wu,
> > > 
> > > Dave has been stressing some XFS patches of mine that remove the XFS
> > > internal writeback clustering in favour of using write_cache_pages.
> > > 
> > > As part of investigating the behaviour he found out that we're still
> > > doing lots of I/O from the end of the LRU in kswapd.  Not only is that
> > > pretty bad behaviour in general, but it also means we really can't
> > > just remove the writeback clustering in writepage given how much
> > > I/O is still done through that.
> > > 
> > > Any chance we could the writeback vs kswap behaviour sorted out a bit
> > > better finally?
> > 
> > I once tried this approach:
> > 
> > http://www.spinics.net/lists/linux-mm/msg09202.html
> > 
> > It used a list structure that is not linearly scalable, however that
> > part should be independently improvable when necessary.
> 
> I don't think that handing random writeback to the flusher thread is
> much better than doing random writeback directly.  Yes, you added
> some clustering, but I'm still don't think writing specific pages is
> the best solution.

I agree that the VM should avoid writing specific pages as much as
possible. Mostly often, it's indeed OK to just skip sporadically
encountered dirty page and reclaim the clean pages presumably not
far away in the LRU list. So your 2-liner patch is all good if
constraining it to low scan pressure, which will look like

        if (priority == DEF_PRIORITY)
                tag PG_reclaim on encountered dirty pages and
                skip writing it

However the VM in general does need the ability to write specific
pages, such as when reclaiming from specific zone/memcg. So I'll still
propose to do bdi_start_inode_writeback().

Below is the patch rebased to linux-next. It's good enough for testing
purpose, and I guess even with the ->nr_pages work issue, it's
complete enough to get roughly the same performance as your 2-liner
patch.

> > The real problem was, it seem to not very effective in my test runs.
> > I found many ->nr_pages works queued before the ->inode works, which
> > effectively makes the flusher working on more dispersed pages rather
> > than focusing on the dirty pages encountered in LRU reclaim.
> 
> But that's really just an implementation issue related to how you
> tried to solve the problem. That could be addressed.
> 
> However, what I'm questioning is whether we should even care what
> page memory reclaim wants to write - it seems to make fundamentally
> bad decisions from an IO persepctive.
> 
> We have to remember that memory reclaim is doing LRU reclaim and the
> flusher threads are doing "oldest first" writeback. IOWs, both are trying
> to operate in the same direction (oldest to youngest) for the same
> purpose.  The fundamental problem that occurs when memory reclaim
> starts writing pages back from the LRU is this:
> 
> 	- memory reclaim has run ahead of IO writeback -
> 
> The LRU usually looks like this:
> 
> 	oldest					youngest
> 	+---------------+---------------+--------------+
> 	clean		writeback	dirty
> 			^		^
> 			|		|
> 			|		Where flusher will next work from
> 			|		Where kswapd is working from
> 			|
> 			IO submitted by flusher, waiting on completion
> 
> 
> If memory reclaim is hitting dirty pages on the LRU, it means it has
> got ahead of writeback without being throttled - it's passed over
> all the pages currently under writeback and is trying to write back
> pages that are *newer* than what writeback is working on. IOWs, it
> starts trying to do the job of the flusher threads, and it does that
> very badly.
> 
> The $100 question is a??why is it getting ahead of writeback*?

The most important case is: faster reader + relatively slow writer.

Assume for every 10 pages read, 1 page is dirtied, and the dirty speed
is fast enough to trigger the 20% dirty ratio and hence dirty balancing.

That pattern is able to evenly distribute dirty pages all over the LRU
list and hence trigger lots of pageout()s. The "skip reclaim writes on
low pressure" approach can fix this case.

Thanks,
Fengguang
---
Subject: writeback: introduce bdi_start_inode_writeback()
Date: Thu Jul 29 14:41:19 CST 2010

This relays ASYNC file writeback IOs to the flusher threads.

pageout() will continue to serve the SYNC file page writes for necessary
throttling for preventing OOM, which may happen if the LRU list is small
and/or the storage is slow, so that the flusher cannot clean enough
pages before the LRU is full scanned.

Only ASYNC pageout() is relayed to the flusher threads, the less
frequent SYNC pageout()s will work as before as a last resort.
This helps to avoid OOM when the LRU list is small and/or the storage is
slow, and the flusher cannot clean enough pages before the LRU is
full scanned.

The flusher will piggy back more dirty pages for IO
- it's more IO efficient
- it helps clean more pages, a good number of them may sit in the same
  LRU list that is being scanned.

To avoid memory allocations at page reclaim, a mempool is created.

Background/periodic works will quit automatically (as done in another
patch), so as to clean the pages under reclaim ASAP. However for now the
sync work can still block us for long time.

Jan Kara: limit the search scope.

CC: Jan Kara <jack@suse.cz>
CC: Rik van Riel <riel@redhat.com>
CC: Mel Gorman <mel@linux.vnet.ibm.com>
CC: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c                |  156 ++++++++++++++++++++++++++++-
 include/linux/backing-dev.h      |    1 
 include/trace/events/writeback.h |   15 ++
 mm/vmscan.c                      |    8 +
 4 files changed, 174 insertions(+), 6 deletions(-)

--- linux-next.orig/mm/vmscan.c	2011-06-29 20:43:10.000000000 -0700
+++ linux-next/mm/vmscan.c	2011-07-05 18:30:19.000000000 -0700
@@ -825,6 +825,14 @@ static unsigned long shrink_page_list(st
 		if (PageDirty(page)) {
 			nr_dirty++;
 
+			if (page_is_file_cache(page) && mapping &&
+			    sc->reclaim_mode != RECLAIM_MODE_SYNC) {
+				if (flush_inode_page(page, mapping) >= 0) {
+					SetPageReclaim(page);
+					goto keep_locked;
+				}
+			}
+
 			if (references == PAGEREF_RECLAIM_CLEAN)
 				goto keep_locked;
 			if (!may_enter_fs)
--- linux-next.orig/fs/fs-writeback.c	2011-07-05 18:30:16.000000000 -0700
+++ linux-next/fs/fs-writeback.c	2011-07-05 18:30:52.000000000 -0700
@@ -30,12 +30,21 @@
 #include "internal.h"
 
 /*
+ * When flushing an inode page (for page reclaim), try to piggy back up to
+ * 4MB nearby pages for IO efficiency. These pages will have good opportunity
+ * to be in the same LRU list.
+ */
+#define WRITE_AROUND_PAGES	MIN_WRITEBACK_PAGES
+
+/*
  * Passed into wb_writeback(), essentially a subset of writeback_control
  */
 struct wb_writeback_work {
 	long nr_pages;
 	struct super_block *sb;
 	unsigned long *older_than_this;
+	struct inode *inode;
+	pgoff_t offset;
 	enum writeback_sync_modes sync_mode;
 	unsigned int tagged_writepages:1;
 	unsigned int for_kupdate:1;
@@ -59,6 +68,27 @@ struct wb_writeback_work {
  */
 int nr_pdflush_threads;
 
+static mempool_t *wb_work_mempool;
+
+static void *wb_work_alloc(gfp_t gfp_mask, void *pool_data)
+{
+	/*
+	 * bdi_start_inode_writeback() may be called on page reclaim
+	 */
+	if (current->flags & PF_MEMALLOC)
+		return NULL;
+
+	return kmalloc(sizeof(struct wb_writeback_work), gfp_mask);
+}
+
+static __init int wb_work_init(void)
+{
+	wb_work_mempool = mempool_create(1024,
+					 wb_work_alloc, mempool_kfree, NULL);
+	return wb_work_mempool ? 0 : -ENOMEM;
+}
+fs_initcall(wb_work_init);
+
 /**
  * writeback_in_progress - determine whether there is writeback in progress
  * @bdi: the device's backing_dev_info structure.
@@ -123,7 +153,7 @@ __bdi_start_writeback(struct backing_dev
 	 * This is WB_SYNC_NONE writeback, so if allocation fails just
 	 * wakeup the thread for old dirty data writeback
 	 */
-	work = kzalloc(sizeof(*work), GFP_ATOMIC);
+	work = mempool_alloc(wb_work_mempool, GFP_NOWAIT);
 	if (!work) {
 		if (bdi->wb.task) {
 			trace_writeback_nowork(bdi);
@@ -132,6 +162,7 @@ __bdi_start_writeback(struct backing_dev
 		return;
 	}
 
+	memset(work, 0, sizeof(*work));
 	work->sync_mode	= WB_SYNC_NONE;
 	work->nr_pages	= nr_pages;
 	work->range_cyclic = range_cyclic;
@@ -177,6 +208,107 @@ void bdi_start_background_writeback(stru
 	spin_unlock_bh(&bdi->wb_lock);
 }
 
+static bool extend_writeback_range(struct wb_writeback_work *work,
+				   pgoff_t offset)
+{
+	pgoff_t end = work->offset + work->nr_pages;
+
+	if (offset >= work->offset && offset < end)
+		return true;
+
+	/* the unsigned comparison helps eliminate one compare */
+	if (work->offset - offset < WRITE_AROUND_PAGES) {
+		work->nr_pages += WRITE_AROUND_PAGES;
+		work->offset -= WRITE_AROUND_PAGES;
+		return true;
+	}
+
+	if (offset - end < WRITE_AROUND_PAGES) {
+		work->nr_pages += WRITE_AROUND_PAGES;
+		return true;
+	}
+
+	return false;
+}
+
+/*
+ * schedule writeback on a range of inode pages.
+ */
+static struct wb_writeback_work *
+bdi_flush_inode_range(struct backing_dev_info *bdi,
+		      struct inode *inode,
+		      pgoff_t offset,
+		      pgoff_t len)
+{
+	struct wb_writeback_work *work;
+
+	if (!igrab(inode))
+		return ERR_PTR(-ENOENT);
+
+	work = mempool_alloc(wb_work_mempool, GFP_NOWAIT);
+	if (!work)
+		return ERR_PTR(-ENOMEM);
+
+	memset(work, 0, sizeof(*work));
+	work->sync_mode		= WB_SYNC_NONE;
+	work->inode		= inode;
+	work->offset		= offset;
+	work->nr_pages		= len;
+
+	bdi_queue_work(bdi, work);
+
+	return work;
+}
+
+/*
+ * Called by page reclaim code to flush the dirty page ASAP. Do write-around to
+ * improve IO throughput. The nearby pages will have good chance to reside in
+ * the same LRU list that vmscan is working on, and even close to each other
+ * inside the LRU list in the common case of sequential read/write.
+ *
+ * ret > 0: success, found/reused a previous writeback work
+ * ret = 0: success, allocated/queued a new writeback work
+ * ret < 0: failed
+ */
+long flush_inode_page(struct page *page, struct address_space *mapping)
+{
+	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	struct inode *inode = mapping->host;
+	pgoff_t offset = page->index;
+	pgoff_t len = 0;
+	struct wb_writeback_work *work;
+	long ret = -ENOENT;
+
+	if (unlikely(!inode))
+		goto out;
+
+	len = 1;
+	spin_lock_bh(&bdi->wb_lock);
+	list_for_each_entry_reverse(work, &bdi->work_list, list) {
+		if (work->inode != inode)
+			continue;
+		if (extend_writeback_range(work, offset)) {
+			ret = len;
+			offset = work->offset;
+			len = work->nr_pages;
+			break;
+		}
+		if (len++ > 30)	/* do limited search */
+			break;
+	}
+	spin_unlock_bh(&bdi->wb_lock);
+
+	if (ret > 0)
+		goto out;
+
+	offset = round_down(offset, WRITE_AROUND_PAGES);
+	len = WRITE_AROUND_PAGES;
+	work = bdi_flush_inode_range(bdi, inode, offset, len);
+	ret = IS_ERR(work) ? PTR_ERR(work) : 0;
+out:
+	return ret;
+}
+
 /*
  * Remove the inode from the writeback list it is on.
  */
@@ -830,6 +962,21 @@ static unsigned long get_nr_dirty_pages(
 		get_nr_dirty_inodes();
 }
 
+static long wb_flush_inode(struct bdi_writeback *wb,
+			   struct wb_writeback_work *work)
+{
+	loff_t start = work->offset;
+	loff_t end   = work->offset + work->nr_pages - 1;
+	int wrote;
+
+	wrote = __filemap_fdatawrite_range(work->inode->i_mapping,
+					   start << PAGE_CACHE_SHIFT,
+					   end   << PAGE_CACHE_SHIFT,
+					   WB_SYNC_NONE);
+	iput(work->inode);
+	return wrote;
+}
+
 static long wb_check_background_flush(struct bdi_writeback *wb)
 {
 	if (over_bground_thresh()) {
@@ -900,7 +1047,10 @@ long wb_do_writeback(struct bdi_writebac
 
 		trace_writeback_exec(bdi, work);
 
-		wrote += wb_writeback(wb, work);
+		if (work->inode)
+			wrote += wb_flush_inode(wb, work);
+		else
+			wrote += wb_writeback(wb, work);
 
 		/*
 		 * Notify the caller of completion if this is a synchronous
@@ -909,7 +1059,7 @@ long wb_do_writeback(struct bdi_writebac
 		if (work->done)
 			complete(work->done);
 		else
-			kfree(work);
+			mempool_free(work, wb_work_mempool);
 	}
 
 	/*
--- linux-next.orig/include/linux/backing-dev.h	2011-07-03 20:03:37.000000000 -0700
+++ linux-next/include/linux/backing-dev.h	2011-07-05 18:30:19.000000000 -0700
@@ -109,6 +109,7 @@ void bdi_unregister(struct backing_dev_i
 int bdi_setup_and_register(struct backing_dev_info *, char *, unsigned int);
 void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages);
 void bdi_start_background_writeback(struct backing_dev_info *bdi);
+long flush_inode_page(struct page *page, struct address_space *mapping);
 int bdi_writeback_thread(void *data);
 int bdi_has_dirty_io(struct backing_dev_info *bdi);
 void bdi_arm_supers_timer(void);
--- linux-next.orig/include/trace/events/writeback.h	2011-07-05 18:30:16.000000000 -0700
+++ linux-next/include/trace/events/writeback.h	2011-07-05 18:30:19.000000000 -0700
@@ -28,31 +28,40 @@ DECLARE_EVENT_CLASS(writeback_work_class
 	TP_ARGS(bdi, work),
 	TP_STRUCT__entry(
 		__array(char, name, 32)
+		__field(struct wb_writeback_work*, work)
 		__field(long, nr_pages)
 		__field(dev_t, sb_dev)
 		__field(int, sync_mode)
 		__field(int, for_kupdate)
 		__field(int, range_cyclic)
 		__field(int, for_background)
+		__field(unsigned long, ino)
+		__field(unsigned long, offset)
 	),
 	TP_fast_assign(
 		strncpy(__entry->name, dev_name(bdi->dev), 32);
+		__entry->work = work;
 		__entry->nr_pages = work->nr_pages;
 		__entry->sb_dev = work->sb ? work->sb->s_dev : 0;
 		__entry->sync_mode = work->sync_mode;
 		__entry->for_kupdate = work->for_kupdate;
 		__entry->range_cyclic = work->range_cyclic;
 		__entry->for_background	= work->for_background;
+		__entry->ino		= work->inode ? work->inode->i_ino : 0;
+		__entry->offset		= work->offset;
 	),
-	TP_printk("bdi %s: sb_dev %d:%d nr_pages=%ld sync_mode=%d "
-		  "kupdate=%d range_cyclic=%d background=%d",
+	TP_printk("bdi %s: sb_dev %d:%d %p nr_pages=%ld sync_mode=%d "
+		  "kupdate=%d range_cyclic=%d background=%d ino=%lu offset=%lu",
 		  __entry->name,
 		  MAJOR(__entry->sb_dev), MINOR(__entry->sb_dev),
+		  __entry->work,
 		  __entry->nr_pages,
 		  __entry->sync_mode,
 		  __entry->for_kupdate,
 		  __entry->range_cyclic,
-		  __entry->for_background
+		  __entry->for_background,
+		  __entry->ino,
+		  __entry->offset
 	)
 );
 #define DEFINE_WRITEBACK_WORK_EVENT(name) \

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
