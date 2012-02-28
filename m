Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 856936B00E7
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:56:26 -0500 (EST)
Message-Id: <20120228144747.198713792@intel.com>
Date: Tue, 28 Feb 2012 22:00:27 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH 5/9] writeback: introduce the pageout work
References: <20120228140022.614718843@intel.com>
Content-Disposition: inline; filename=writeback-bdi_start_inode_writeback.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This relays file pageout IOs to the flusher threads.

It's much more important now that page reclaim generally does not
writeout filesystem-backed pages.

The ultimate target is to gracefully handle the LRU lists pressured by
dirty/writeback pages. In particular, problems (1-2) are addressed here.

1) I/O efficiency

The flusher will piggy back the nearby ~10ms worth of dirty pages for I/O.

This takes advantage of the time/spacial locality in most workloads: the
nearby pages of one file are typically populated into the LRU at the same
time, hence will likely be close to each other in the LRU list. Writing
them in one shot helps clean more pages effectively for page reclaim.

For the common dd style sequential writes that have excellent locality,
up to ~80ms data will be wrote around by the pageout work, which helps
make I/O performance very close to that of the background writeback.

2) writeback work coordinations

To avoid memory allocations at page reclaim, a mempool for struct
wb_writeback_work is created.

wakeup_flusher_threads() is removed because it can easily delay the
more oriented pageout works and even exhaust the mempool reservations.
It's also found to not I/O efficient by frequently submitting writeback
works with small ->nr_pages.

Background/periodic works will quit automatically, so as to clean the
pages under reclaim ASAP. However for now the sync work can still block
us for long time.

Jan Kara: limit the search scope; remove works and unpin inodes on umount.

TODO: the pageout works may be starved by the sync work and maybe others.
Need a proper way to guarantee fairness.

CC: Jan Kara <jack@suse.cz>
CC: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
CC: Greg Thelen <gthelen@google.com>
CC: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 fs/fs-writeback.c                |  230 +++++++++++++++++++++++++++--
 fs/super.c                       |    1 
 include/linux/backing-dev.h      |    2 
 include/linux/writeback.h        |   16 +-
 include/trace/events/writeback.h |   12 +
 mm/vmscan.c                      |   36 ++--
 6 files changed, 268 insertions(+), 29 deletions(-)

--- linux.orig/fs/fs-writeback.c	2012-02-28 19:07:06.109064465 +0800
+++ linux/fs/fs-writeback.c	2012-02-28 19:07:07.277064493 +0800
@@ -41,6 +41,8 @@ struct wb_writeback_work {
 	long nr_pages;
 	struct super_block *sb;
 	unsigned long *older_than_this;
+	struct inode *inode;
+	pgoff_t offset;
 	enum writeback_sync_modes sync_mode;
 	unsigned int tagged_writepages:1;
 	unsigned int for_kupdate:1;
@@ -57,6 +59,27 @@ struct wb_writeback_work {
  */
 int nr_pdflush_threads;
 
+static mempool_t *wb_work_mempool;
+
+static void *wb_work_alloc(gfp_t gfp_mask, void *pool_data)
+{
+	/*
+	 * alloc_queue_pageout_work() will be called on page reclaim
+	 */
+	if (current->flags & PF_MEMALLOC)
+		return NULL;
+
+	return kmalloc(sizeof(struct wb_writeback_work), gfp_mask);
+}
+
+static __init int wb_work_init(void)
+{
+	wb_work_mempool = mempool_create(WB_WORK_MEMPOOL_SIZE,
+					 wb_work_alloc, mempool_kfree, NULL);
+	return wb_work_mempool ? 0 : -ENOMEM;
+}
+fs_initcall(wb_work_init);
+
 /**
  * writeback_in_progress - determine whether there is writeback in progress
  * @bdi: the device's backing_dev_info structure.
@@ -129,7 +152,7 @@ __bdi_start_writeback(struct backing_dev
 	 * This is WB_SYNC_NONE writeback, so if allocation fails just
 	 * wakeup the thread for old dirty data writeback
 	 */
-	work = kzalloc(sizeof(*work), GFP_ATOMIC);
+	work = mempool_alloc(wb_work_mempool, GFP_NOWAIT);
 	if (!work) {
 		if (bdi->wb.task) {
 			trace_writeback_nowork(bdi);
@@ -138,6 +161,7 @@ __bdi_start_writeback(struct backing_dev
 		return;
 	}
 
+	memset(work, 0, sizeof(*work));
 	work->sync_mode	= WB_SYNC_NONE;
 	work->nr_pages	= nr_pages;
 	work->range_cyclic = range_cyclic;
@@ -187,6 +211,181 @@ void bdi_start_background_writeback(stru
 }
 
 /*
+ * Check if @work already covers @offset, or try to extend it to cover @offset.
+ * Returns true if the wb_writeback_work now encompasses the requested offset.
+ */
+static bool extend_writeback_range(struct wb_writeback_work *work,
+				   pgoff_t offset,
+				   unsigned long unit)
+{
+	pgoff_t end = work->offset + work->nr_pages;
+
+	if (offset >= work->offset && offset < end)
+		return true;
+
+	/*
+	 * for sequential workloads with good locality, include up to 8 times
+	 * more data in one chunk
+	 */
+	if (work->nr_pages >= 8 * unit)
+		return false;
+
+	/* the unsigned comparison helps eliminate one compare */
+	if (work->offset - offset < unit) {
+		work->nr_pages += unit;
+		work->offset -= unit;
+		return true;
+	}
+
+	if (offset - end < unit) {
+		work->nr_pages += unit;
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
+alloc_queue_pageout_work(struct backing_dev_info *bdi,
+			 struct inode *inode,
+			 pgoff_t offset,
+			 pgoff_t len)
+{
+	struct wb_writeback_work *work;
+
+	/*
+	 * Grab the inode until the work is executed. We are calling this from
+	 * page reclaim context and the only thing pinning the address_space
+	 * for the moment is the page lock.
+	 */
+	if (!igrab(inode))
+		return ERR_PTR(-ENOENT);
+
+	work = mempool_alloc(wb_work_mempool, GFP_NOWAIT);
+	if (!work) {
+		trace_printk("wb_work_mempool alloc fail\n");
+		return ERR_PTR(-ENOMEM);
+	}
+
+	memset(work, 0, sizeof(*work));
+	work->sync_mode		= WB_SYNC_NONE;
+	work->inode		= inode;
+	work->offset		= offset;
+	work->nr_pages		= len;
+	work->reason		= WB_REASON_PAGEOUT;
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
+ * ret > 0: success, allocated/queued a new pageout work;
+ *	    there are at least @ret writeback works queued now
+ * ret = 0: success, reused/extended a previous pageout work
+ * ret < 0: failed
+ */
+int queue_pageout_work(struct address_space *mapping, struct page *page)
+{
+	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	struct inode *inode = mapping->host;
+	struct wb_writeback_work *work;
+	unsigned long write_around_pages;
+	pgoff_t offset = page->index;
+	int i = 0;
+	int ret = -ENOENT;
+
+	if (unlikely(!inode))
+		return ret;
+
+	/*
+	 * piggy back 8-15ms worth of data
+	 */
+	write_around_pages = bdi->avg_write_bandwidth + MIN_WRITEBACK_PAGES;
+	write_around_pages = rounddown_pow_of_two(write_around_pages) >> 6;
+
+	i = 1;
+	spin_lock_bh(&bdi->wb_lock);
+	list_for_each_entry_reverse(work, &bdi->work_list, list) {
+		if (work->inode != inode)
+			continue;
+		if (extend_writeback_range(work, offset, write_around_pages)) {
+			ret = 0;
+			break;
+		}
+		/*
+		 * vmscan will slow down page reclaim when there are more than
+		 * LOTS_OF_WRITEBACK_WORKS queued. Limit search depth to two
+		 * times larger.
+		 */
+		if (i++ > 2 * LOTS_OF_WRITEBACK_WORKS)
+			break;
+	}
+	spin_unlock_bh(&bdi->wb_lock);
+
+	if (ret) {
+		ret = i;
+		offset = round_down(offset, write_around_pages);
+		work = alloc_queue_pageout_work(bdi, inode,
+						offset, write_around_pages);
+		if (IS_ERR(work))
+			ret = PTR_ERR(work);
+	}
+	return ret;
+}
+
+static void wb_free_work(struct wb_writeback_work *work)
+{
+	if (work->inode)
+		iput(work->inode);
+	/*
+	 * Notify the caller of completion if this is a synchronous
+	 * work item, otherwise just free it.
+	 */
+	if (work->done)
+		complete(work->done);
+	else
+		mempool_free(work, wb_work_mempool);
+}
+
+/*
+ * Remove works for @sb; or if (@sb == NULL), remove all works on @bdi.
+ */
+void bdi_remove_writeback_works(struct backing_dev_info *bdi,
+				struct super_block *sb)
+{
+	struct wb_writeback_work *work, *tmp;
+	LIST_HEAD(dispose);
+
+	spin_lock_bh(&bdi->wb_lock);
+	list_for_each_entry_safe(work, tmp, &bdi->work_list, list) {
+		if (sb) {
+			if (work->sb && work->sb != sb)
+				continue;
+			if (work->inode && work->inode->i_sb != sb)
+				continue;
+		}
+		list_move(&work->list, &dispose);
+	}
+	spin_unlock_bh(&bdi->wb_lock);
+
+	while (!list_empty(&dispose)) {
+		work = list_entry(dispose.next,
+				  struct wb_writeback_work, list);
+		list_del_init(&work->list);
+		wb_free_work(work);
+	}
+}
+
+/*
  * Remove the inode from the writeback list it is on.
  */
 void inode_wb_list_del(struct inode *inode)
@@ -833,6 +1032,21 @@ static unsigned long get_nr_dirty_pages(
 		get_nr_dirty_inodes();
 }
 
+static long wb_pageout(struct bdi_writeback *wb, struct wb_writeback_work *work)
+{
+	struct writeback_control wbc = {
+		.sync_mode = WB_SYNC_NONE,
+		.nr_to_write = LONG_MAX,
+		.range_start = work->offset << PAGE_CACHE_SHIFT,
+		.range_end = (work->offset + work->nr_pages - 1)
+						<< PAGE_CACHE_SHIFT,
+	};
+
+	do_writepages(work->inode->i_mapping, &wbc);
+
+	return LONG_MAX - wbc.nr_to_write;
+}
+
 static long wb_check_background_flush(struct bdi_writeback *wb)
 {
 	if (over_bground_thresh(wb->bdi)) {
@@ -905,16 +1119,12 @@ long wb_do_writeback(struct bdi_writebac
 
 		trace_writeback_exec(bdi, work);
 
-		wrote += wb_writeback(wb, work);
-
-		/*
-		 * Notify the caller of completion if this is a synchronous
-		 * work item, otherwise just free it.
-		 */
-		if (work->done)
-			complete(work->done);
+		if (!work->inode)
+			wrote += wb_writeback(wb, work);
 		else
-			kfree(work);
+			wrote += wb_pageout(wb, work);
+
+		wb_free_work(work);
 	}
 
 	/*
--- linux.orig/include/trace/events/writeback.h	2012-02-28 19:07:06.077064464 +0800
+++ linux/include/trace/events/writeback.h	2012-02-28 20:25:46.415730762 +0800
@@ -23,7 +23,7 @@
 
 #define WB_WORK_REASON							\
 		{WB_REASON_BACKGROUND,		"background"},		\
-		{WB_REASON_TRY_TO_FREE_PAGES,	"try_to_free_pages"},	\
+		{WB_REASON_PAGEOUT,		"pageout"},		\
 		{WB_REASON_SYNC,		"sync"},		\
 		{WB_REASON_PERIODIC,		"periodic"},		\
 		{WB_REASON_LAPTOP_TIMER,	"laptop_timer"},	\
@@ -45,6 +45,8 @@ DECLARE_EVENT_CLASS(writeback_work_class
 		__field(int, range_cyclic)
 		__field(int, for_background)
 		__field(int, reason)
+		__field(unsigned long, ino)
+		__field(unsigned long, offset)
 	),
 	TP_fast_assign(
 		struct device *dev = bdi->dev;
@@ -58,9 +60,11 @@ DECLARE_EVENT_CLASS(writeback_work_class
 		__entry->range_cyclic = work->range_cyclic;
 		__entry->for_background	= work->for_background;
 		__entry->reason = work->reason;
+		__entry->ino = work->inode ? work->inode->i_ino : 0;
+		__entry->offset = work->offset;
 	),
 	TP_printk("bdi %s: sb_dev %d:%d nr_pages=%ld sync_mode=%d "
-		  "kupdate=%d range_cyclic=%d background=%d reason=%s",
+		  "kupdate=%d range_cyclic=%d background=%d reason=%s ino=%lu offset=%lu",
 		  __entry->name,
 		  MAJOR(__entry->sb_dev), MINOR(__entry->sb_dev),
 		  __entry->nr_pages,
@@ -68,7 +72,9 @@ DECLARE_EVENT_CLASS(writeback_work_class
 		  __entry->for_kupdate,
 		  __entry->range_cyclic,
 		  __entry->for_background,
-		  __print_symbolic(__entry->reason, WB_WORK_REASON)
+		  __print_symbolic(__entry->reason, WB_WORK_REASON),
+		  __entry->ino,
+		  __entry->offset
 	)
 );
 #define DEFINE_WRITEBACK_WORK_EVENT(name) \
--- linux.orig/include/linux/writeback.h	2012-02-28 19:07:06.093064464 +0800
+++ linux/include/linux/writeback.h	2012-02-28 20:25:47.323730784 +0800
@@ -40,7 +40,7 @@ enum writeback_sync_modes {
  */
 enum wb_reason {
 	WB_REASON_BACKGROUND,
-	WB_REASON_TRY_TO_FREE_PAGES,
+	WB_REASON_PAGEOUT,
 	WB_REASON_SYNC,
 	WB_REASON_PERIODIC,
 	WB_REASON_LAPTOP_TIMER,
@@ -94,6 +94,20 @@ long writeback_inodes_wb(struct bdi_writ
 				enum wb_reason reason);
 long wb_do_writeback(struct bdi_writeback *wb, int force_wait);
 void wakeup_flusher_threads(long nr_pages, enum wb_reason reason);
+int queue_pageout_work(struct address_space *mapping, struct page *page);
+
+/*
+ * Tailored for vmscan which may submit lots of pageout works. The page reclaim
+ * will try to slow down the pageout work submission rate when the queue size
+ * grows to LOTS_OF_WRITEBACK_WORKS. queue_pageout_work() will accordingly limit
+ * its search depth to (2 * LOTS_OF_WRITEBACK_WORKS).
+ *
+ * Note that the limited search and work pool is not a big problem: 1024 IOs
+ * under flight are typically more than enough to saturate the disk. And the
+ * overheads of searching in the work list didn't even show up in perf report.
+ */
+#define WB_WORK_MEMPOOL_SIZE		1024
+#define LOTS_OF_WRITEBACK_WORKS		(WB_WORK_MEMPOOL_SIZE / 8)
 
 /* writeback.h requires fs.h; it, too, is not included from here. */
 static inline void wait_on_inode(struct inode *inode)
--- linux.orig/fs/super.c	2012-02-28 19:07:06.101064465 +0800
+++ linux/fs/super.c	2012-02-28 19:07:07.277064493 +0800
@@ -389,6 +389,7 @@ void generic_shutdown_super(struct super
 
 		fsnotify_unmount_inodes(&sb->s_inodes);
 
+		bdi_remove_writeback_works(sb->s_bdi, sb);
 		evict_inodes(sb);
 
 		if (sop->put_super)
--- linux.orig/include/linux/backing-dev.h	2012-02-28 19:07:06.081064464 +0800
+++ linux/include/linux/backing-dev.h	2012-02-28 19:07:07.281064493 +0800
@@ -126,6 +126,8 @@ int bdi_has_dirty_io(struct backing_dev_
 void bdi_arm_supers_timer(void);
 void bdi_wakeup_thread_delayed(struct backing_dev_info *bdi);
 void bdi_lock_two(struct bdi_writeback *wb1, struct bdi_writeback *wb2);
+void bdi_remove_writeback_works(struct backing_dev_info *bdi,
+				struct super_block *sb);
 
 extern spinlock_t bdi_lock;
 extern struct list_head bdi_list;
--- linux.orig/mm/vmscan.c	2012-02-28 19:07:06.065064464 +0800
+++ linux/mm/vmscan.c	2012-02-28 20:26:15.559731455 +0800
@@ -874,12 +874,22 @@ static unsigned long shrink_page_list(st
 			nr_dirty++;
 
 			/*
-			 * Only kswapd can writeback filesystem pages to
-			 * avoid risk of stack overflow but do not writeback
-			 * unless under significant pressure.
+			 * Pages may be dirtied anywhere inside the LRU. This
+			 * ensures they undergo a full period of LRU iteration
+			 * before considering pageout. The intention is to
+			 * delay writeout to the flusher thread, unless when
+			 * run into a long segment of dirty pages.
+			 */
+			if (references == PAGEREF_RECLAIM_CLEAN &&
+			    priority == DEF_PRIORITY)
+				goto keep_locked;
+
+			/*
+			 * Try relaying the pageout I/O to the flusher threads
+			 * for better I/O efficiency and avoid stack overflow.
 			 */
-			if (page_is_file_cache(page) &&
-					(!current_is_kswapd() || priority >= DEF_PRIORITY - 2)) {
+			if (page_is_file_cache(page) && mapping &&
+			    queue_pageout_work(mapping, page) >= 0) {
 				/*
 				 * Immediately reclaim when written back.
 				 * Similar in principal to deactivate_page()
@@ -892,8 +902,13 @@ static unsigned long shrink_page_list(st
 				goto keep_locked;
 			}
 
-			if (references == PAGEREF_RECLAIM_CLEAN)
+			/*
+			 * Only kswapd can writeback filesystem pages to
+			 * avoid risk of stack overflow.
+			 */
+			if (page_is_file_cache(page) && !current_is_kswapd())
 				goto keep_locked;
+
 			if (!may_enter_fs)
 				goto keep_locked;
 			if (!sc->may_writepage)
@@ -2373,17 +2388,8 @@ static unsigned long do_try_to_free_page
 		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
 			goto out;
 
-		/*
-		 * Try to write back as many pages as we just scanned.  This
-		 * tends to cause slow streaming writers to write data to the
-		 * disk smoothly, at the dirtying rate, which is nice.   But
-		 * that's undesirable in laptop mode, where we *want* lumpy
-		 * writeout.  So in laptop mode, write out the whole world.
-		 */
 		writeback_threshold = sc->nr_to_reclaim + sc->nr_to_reclaim / 2;
 		if (total_scanned > writeback_threshold) {
-			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned,
-						WB_REASON_TRY_TO_FREE_PAGES);
 			sc->may_writepage = 1;
 		}
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
