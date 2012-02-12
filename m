Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 5CCAD6B13F0
	for <linux-mm@kvack.org>; Sat, 11 Feb 2012 22:20:38 -0500 (EST)
Date: Sun, 12 Feb 2012 11:10:29 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: reclaim the LRU lists full of dirty/writeback pages
Message-ID: <20120212031029.GA17435@localhost>
References: <CAHH2K0b-+T4dspJPKq5TH25aH58TEr+7yvq0-HMkbFi0ghqAfA@mail.gmail.com>
 <20120208093120.GA18993@localhost>
 <CAHH2K0bmURXpk6-4D9q7ErppVyMJjKMsn37MenwqcP_nnT66Mw@mail.gmail.com>
 <20120210114706.GA4704@localhost>
 <20120211124445.GA10826@localhost>
 <4F36816A.6030609@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F36816A.6030609@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

On Sat, Feb 11, 2012 at 09:55:38AM -0500, Rik van Riel wrote:
> On 02/11/2012 07:44 AM, Wu Fengguang wrote:
> 
> >Note that it's data for XFS. ext4 seems to have some problem with the
> >workload: the majority pages are found to be writeback pages, and the
> >flusher ends up blocking on the unconditional wait_on_page_writeback()
> >in write_cache_pages_da() from time to time...

Sorry I overlooked the WB_SYNC_NONE test before the wait_on_page_writeback()
call! And the issue can no longer be reproduce anyway. ext4 performs pretty
good now, here is the result for one single memcg dd:

        dd if=/dev/zero of=/fs/f$i bs=4k count=1M

        4294967296 bytes (4.3 GB) copied, 44.5759 s, 96.4 MB/s

iostat -kx 3

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.25    0.00   11.03   28.54    0.00   60.19
           0.25    0.00   13.71   16.65    0.00   69.39
           0.17    0.00    8.41   24.81    0.00   66.61
           0.25    0.00   15.00   19.63    0.00   65.12

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00    17.00    0.00  178.33     0.00 90694.67  1017.14   111.34  520.88   5.45  97.23
sda               0.00     0.00    0.00  193.67     0.00 98816.00  1020.48    86.22  496.81   4.81  93.07
sda               0.00     3.33    0.00  182.33     0.00 92345.33  1012.93   101.14  623.98   5.49 100.03
sda               0.00     3.00    0.00  187.00     0.00 95586.67  1022.32    89.36  441.70   4.96  92.70

> >XXX: commit NFS unstable pages via write_inode()
> >XXX: the added congestion_wait() may be undesirable in some situations
> 
> Even with these caveats, this seems to be the right way forward.

> Acked-by: Rik van Riel <riel@redhat.com>

Thank you!
 
Here is the updated patch.
- ~10ms write around chunk size, adaptive to the bdi bandwith 
- cleanup flush_inode_page()

Thanks,
Fengguang
---
Subject: writeback: introduce the pageout work
Date: Thu Jul 29 14:41:19 CST 2010

This relays file pageout IOs to the flusher threads.

The ultimate target is to gracefully handle the LRU lists full of
dirty/writeback pages.

1) I/O efficiency

The flusher will piggy back the nearby ~10ms worth of dirty pages for I/O.

This takes advantage of the time/spacial locality in most workloads: the
nearby pages of one file are typically populated into the LRU at the same
time, hence will likely be close to each other in the LRU list. Writing
them in one shot helps clean more pages effectively for page reclaim.

2) OOM avoidance and scan rate control

Typically we do LRU scan w/o rate control and quickly get enough clean
pages for the LRU lists not full of dirty pages.

Or we can still get a number of freshly cleaned pages (moved to LRU tail
by end_page_writeback()) when the queued pageout I/O is completed within
tens of milli-seconds.

However if the LRU list is small and full of dirty pages, it can be
quickly fully scanned and go OOM before the flusher manages to clean
enough pages.

A simple yet reliable scheme is employed to avoid OOM and keep scan rate
in sync with the I/O rate:

	if (PageReclaim(page))
		congestion_wait(HZ/10);

PG_reclaim plays the key role. When dirty pages are encountered, we
queue I/O for it, set PG_reclaim and put it back to the LRU head.
So if PG_reclaim pages are encountered again, it means the dirty page
has not yet been cleaned by the flusher after a full zone scan. It
indicates we are scanning more fast than I/O and shall take a snap.

The runtime behavior on a fully dirtied small LRU list would be:
It will start with a quick scan of the list, queuing all pages for I/O.
Then the scan will be slowed down by the PG_reclaim pages *adaptively*
to match the I/O bandwidth.

3) writeback work coordinations

To avoid memory allocations at page reclaim, a mempool for struct
wb_writeback_work is created.

wakeup_flusher_threads() is removed because it can easily delay the
more oriented pageout works and even exhaust the mempool reservations.
It's also found to not I/O efficient by frequently submitting writeback
works with small ->nr_pages.

Background/periodic works will quit automatically, so as to clean the
pages under reclaim ASAP. However for now the sync work can still block
us for long time.

Jan Kara: limit the search scope. Note that the limited search and work
pool is not a big problem: 1000 IOs under flight are typically more than
enough to saturate the disk. And the overheads of searching in the work
list didn't even show up in the perf report.

4) test case

Run 2 dd tasks in a 100MB memcg (a very handy test case from Greg Thelen):

	mkdir /cgroup/x
	echo 100M > /cgroup/x/memory.limit_in_bytes
	echo $$ > /cgroup/x/tasks

	for i in `seq 2`
	do
		dd if=/dev/zero of=/fs/f$i bs=1k count=1M &
	done

Before patch, the dd tasks are quickly OOM killed.
After patch, they run well with reasonably good performance and overheads:

1073741824 bytes (1.1 GB) copied, 22.2196 s, 48.3 MB/s
1073741824 bytes (1.1 GB) copied, 22.4675 s, 47.8 MB/s

iostat -kx 1

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00     0.00    0.00  178.00     0.00 89568.00  1006.38    74.35  417.71   4.80  85.40
sda               0.00     2.00    0.00  191.00     0.00 94428.00   988.77    53.34  219.03   4.34  82.90
sda               0.00    20.00    0.00  196.00     0.00 97712.00   997.06    71.11  337.45   4.77  93.50
sda               0.00     5.00    0.00  175.00     0.00 84648.00   967.41    54.03  316.44   5.06  88.60
sda               0.00     0.00    0.00  186.00     0.00 92432.00   993.89    56.22  267.54   5.38 100.00
sda               0.00     1.00    0.00  183.00     0.00 90156.00   985.31    37.99  325.55   4.33  79.20
sda               0.00     0.00    0.00  175.00     0.00 88692.00  1013.62    48.70  218.43   4.69  82.10
sda               0.00     0.00    0.00  196.00     0.00 97528.00   995.18    43.38  236.87   5.10 100.00
sda               0.00     0.00    0.00  179.00     0.00 88648.00   990.48    45.83  285.43   5.59 100.00
sda               0.00     0.00    0.00  178.00     0.00 88500.00   994.38    28.28  158.89   4.99  88.80
sda               0.00     0.00    0.00  194.00     0.00 95852.00   988.16    32.58  167.39   5.15 100.00
sda               0.00     2.00    0.00  215.00     0.00 105996.00   986.01    41.72  201.43   4.65 100.00
sda               0.00     4.00    0.00  173.00     0.00 84332.00   974.94    50.48  260.23   5.76  99.60
sda               0.00     0.00    0.00  182.00     0.00 90312.00   992.44    36.83  212.07   5.49 100.00
sda               0.00     8.00    0.00  195.00     0.00 95940.50   984.01    50.18  221.06   5.13 100.00
sda               0.00     1.00    0.00  220.00     0.00 108852.00   989.56    40.99  202.68   4.55 100.00
sda               0.00     2.00    0.00  161.00     0.00 80384.00   998.56    37.19  268.49   6.21 100.00
sda               0.00     4.00    0.00  182.00     0.00 90830.00   998.13    50.58  239.77   5.49 100.00
sda               0.00     0.00    0.00  197.00     0.00 94877.00   963.22    36.68  196.79   5.08 100.00

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.25    0.00   15.08   33.92    0.00   50.75
           0.25    0.00   14.54   35.09    0.00   50.13
           0.50    0.00   13.57   32.41    0.00   53.52
           0.50    0.00   11.28   36.84    0.00   51.38
           0.50    0.00   15.75   32.00    0.00   51.75
           0.50    0.00   10.50   34.00    0.00   55.00
           0.50    0.00   17.63   27.46    0.00   54.41
           0.50    0.00   15.08   30.90    0.00   53.52
           0.50    0.00   11.28   32.83    0.00   55.39
           0.75    0.00   16.79   26.82    0.00   55.64
           0.50    0.00   16.08   29.15    0.00   54.27
           0.50    0.00   13.50   30.50    0.00   55.50
           0.50    0.00   14.32   35.18    0.00   50.00
           0.50    0.00   12.06   33.92    0.00   53.52
           0.50    0.00   17.29   30.58    0.00   51.63
           0.50    0.00   15.08   29.65    0.00   54.77
           0.50    0.00   12.53   29.32    0.00   57.64
           0.50    0.00   15.29   31.83    0.00   52.38

The global dd numbers for comparison:

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00     0.00    0.00  189.00     0.00 95752.00  1013.25   143.09  684.48   5.29 100.00
sda               0.00     0.00    0.00  208.00     0.00 105480.00  1014.23   143.06  733.29   4.81 100.00
sda               0.00     0.00    0.00  161.00     0.00 81924.00  1017.69   141.71  757.79   6.21 100.00
sda               0.00     0.00    0.00  217.00     0.00 109580.00  1009.95   143.09  749.55   4.61 100.10
sda               0.00     0.00    0.00  187.00     0.00 94728.00  1013.13   144.31  773.67   5.35 100.00
sda               0.00     0.00    0.00  189.00     0.00 95752.00  1013.25   144.14  742.00   5.29 100.00
sda               0.00     0.00    0.00  177.00     0.00 90032.00  1017.31   143.32  656.59   5.65 100.00
sda               0.00     0.00    0.00  215.00     0.00 108640.00  1010.60   142.90  817.54   4.65 100.00
sda               0.00     2.00    0.00  166.00     0.00 83858.00  1010.34   143.64  808.61   6.02 100.00
sda               0.00     0.00    0.00  186.00     0.00 92813.00   997.99   141.18  736.95   5.38 100.00
sda               0.00     0.00    0.00  206.00     0.00 104456.00  1014.14   146.27  729.33   4.85 100.00
sda               0.00     0.00    0.00  213.00     0.00 107024.00  1004.92   143.25  705.70   4.69 100.00
sda               0.00     0.00    0.00  188.00     0.00 95748.00  1018.60   141.82  764.78   5.32 100.00

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.51    0.00   11.22   52.30    0.00   35.97
           0.25    0.00   10.15   52.54    0.00   37.06
           0.25    0.00    5.01   56.64    0.00   38.10
           0.51    0.00   15.15   43.94    0.00   40.40
           0.25    0.00   12.12   48.23    0.00   39.39
           0.51    0.00   11.20   53.94    0.00   34.35
           0.26    0.00    9.72   51.41    0.00   38.62
           0.76    0.00    9.62   50.63    0.00   38.99
           0.51    0.00   10.46   53.32    0.00   35.71
           0.51    0.00    9.41   51.91    0.00   38.17
           0.25    0.00   10.69   49.62    0.00   39.44
           0.51    0.00   12.21   52.67    0.00   34.61
           0.51    0.00   11.45   53.18    0.00   34.86

XXX: commit NFS unstable pages via write_inode()
XXX: the added congestion_wait() may be undesirable in some situations

CC: Jan Kara <jack@suse.cz>
CC: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
CC: Greg Thelen <gthelen@google.com>
CC: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c                |  167 ++++++++++++++++++++++++++++-
 include/linux/writeback.h        |    4 
 include/trace/events/writeback.h |   12 +-
 mm/vmscan.c                      |   17 +-
 4 files changed, 186 insertions(+), 14 deletions(-)

--- linux.orig/mm/vmscan.c	2012-02-11 19:59:40.000000000 +0800
+++ linux/mm/vmscan.c	2012-02-11 20:07:48.000000000 +0800
@@ -813,6 +813,8 @@ static unsigned long shrink_page_list(st
 
 		if (PageWriteback(page)) {
 			nr_writeback++;
+			if (PageReclaim(page))
+				congestion_wait(BLK_RW_ASYNC, HZ/10);
 			/*
 			 * Synchronous reclaim cannot queue pages for
 			 * writeback due to the possibility of stack overflow
@@ -874,12 +876,15 @@ static unsigned long shrink_page_list(st
 			nr_dirty++;
 
 			/*
-			 * Only kswapd can writeback filesystem pages to
-			 * avoid risk of stack overflow but do not writeback
-			 * unless under significant pressure.
+			 * run into the visited page again: we are scanning
+			 * faster than the flusher can writeout dirty pages
 			 */
-			if (page_is_file_cache(page) &&
-					(!current_is_kswapd() || priority >= DEF_PRIORITY - 2)) {
+			if (page_is_file_cache(page) && PageReclaim(page)) {
+				congestion_wait(BLK_RW_ASYNC, HZ/10);
+				goto keep_locked;
+			}
+			if (page_is_file_cache(page) && mapping &&
+			    flush_inode_page(mapping, page, true) >= 0) {
 				/*
 				 * Immediately reclaim when written back.
 				 * Similar in principal to deactivate_page()
@@ -2382,8 +2387,6 @@ static unsigned long do_try_to_free_page
 		 */
 		writeback_threshold = sc->nr_to_reclaim + sc->nr_to_reclaim / 2;
 		if (total_scanned > writeback_threshold) {
-			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned,
-						WB_REASON_TRY_TO_FREE_PAGES);
 			sc->may_writepage = 1;
 		}
 
--- linux.orig/fs/fs-writeback.c	2012-02-11 19:59:40.000000000 +0800
+++ linux/fs/fs-writeback.c	2012-02-12 10:54:05.000000000 +0800
@@ -41,6 +41,8 @@ struct wb_writeback_work {
 	long nr_pages;
 	struct super_block *sb;
 	unsigned long *older_than_this;
+	struct inode *inode;
+	pgoff_t offset;
 	enum writeback_sync_modes sync_mode;
 	unsigned int tagged_writepages:1;
 	unsigned int for_kupdate:1;
@@ -65,6 +67,27 @@ struct wb_writeback_work {
  */
 int nr_pdflush_threads;
 
+static mempool_t *wb_work_mempool;
+
+static void *wb_work_alloc(gfp_t gfp_mask, void *pool_data)
+{
+	/*
+	 * bdi_flush_inode_range() may be called on page reclaim
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
@@ -186,6 +210,123 @@ void bdi_start_background_writeback(stru
 	spin_unlock_bh(&bdi->wb_lock);
 }
 
+static bool extend_writeback_range(struct wb_writeback_work *work,
+				   pgoff_t offset,
+				   unsigned long write_around_pages)
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
+	if (work->nr_pages >= 8 * write_around_pages)
+		return false;
+
+	/* the unsigned comparison helps eliminate one compare */
+	if (work->offset - offset < write_around_pages) {
+		work->nr_pages += write_around_pages;
+		work->offset -= write_around_pages;
+		return true;
+	}
+
+	if (offset - end < write_around_pages) {
+		work->nr_pages += write_around_pages;
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
+		      pgoff_t len,
+		      bool wait)
+{
+	struct wb_writeback_work *work;
+
+	if (!igrab(inode))
+		return ERR_PTR(-ENOENT);
+
+	work = mempool_alloc(wb_work_mempool, wait ? GFP_NOIO : GFP_NOWAIT);
+	if (!work)
+		return ERR_PTR(-ENOMEM);
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
+ * ret > 0: success, found/reused a previous writeback work
+ * ret = 0: success, allocated/queued a new writeback work
+ * ret < 0: failed
+ */
+long flush_inode_page(struct address_space *mapping,
+		      struct page *page,
+		      bool wait)
+{
+	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	struct inode *inode = mapping->host;
+	struct wb_writeback_work *work;
+	unsigned long write_around_pages;
+	pgoff_t offset = page->index;
+	int i;
+	long ret = 0;
+
+	if (unlikely(!inode))
+		return -ENOENT;
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
+			ret = i;
+			break;
+		}
+		if (i++ > 100)	/* limit search depth */
+			break;
+	}
+	spin_unlock_bh(&bdi->wb_lock);
+
+	if (!ret) {
+		offset = round_down(offset, write_around_pages);
+		work = bdi_flush_inode_range(bdi, inode,
+					     offset, write_around_pages, wait);
+		if (IS_ERR(work))
+			ret = PTR_ERR(work);
+	}
+	return ret;
+}
+
 /*
  * Remove the inode from the writeback list it is on.
  */
@@ -833,6 +974,23 @@ static unsigned long get_nr_dirty_pages(
 		get_nr_dirty_inodes();
 }
 
+static long wb_flush_inode(struct bdi_writeback *wb,
+			   struct wb_writeback_work *work)
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
+	iput(work->inode);
+
+	return LONG_MAX - wbc.nr_to_write;
+}
+
 static long wb_check_background_flush(struct bdi_writeback *wb)
 {
 	if (over_bground_thresh(wb->bdi)) {
@@ -905,7 +1063,10 @@ long wb_do_writeback(struct bdi_writebac
 
 		trace_writeback_exec(bdi, work);
 
-		wrote += wb_writeback(wb, work);
+		if (work->inode)
+			wrote += wb_flush_inode(wb, work);
+		else
+			wrote += wb_writeback(wb, work);
 
 		/*
 		 * Notify the caller of completion if this is a synchronous
@@ -914,7 +1075,7 @@ long wb_do_writeback(struct bdi_writebac
 		if (work->done)
 			complete(work->done);
 		else
-			kfree(work);
+			mempool_free(work, wb_work_mempool);
 	}
 
 	/*
--- linux.orig/include/trace/events/writeback.h	2012-02-11 19:59:40.000000000 +0800
+++ linux/include/trace/events/writeback.h	2012-02-11 20:07:48.000000000 +0800
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
 		strncpy(__entry->name, dev_name(bdi->dev), 32);
@@ -55,9 +57,11 @@ DECLARE_EVENT_CLASS(writeback_work_class
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
@@ -65,7 +69,9 @@ DECLARE_EVENT_CLASS(writeback_work_class
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
--- linux.orig/include/linux/writeback.h	2012-02-11 19:59:40.000000000 +0800
+++ linux/include/linux/writeback.h	2012-02-11 20:07:48.000000000 +0800
@@ -40,7 +40,7 @@ enum writeback_sync_modes {
  */
 enum wb_reason {
 	WB_REASON_BACKGROUND,
-	WB_REASON_TRY_TO_FREE_PAGES,
+	WB_REASON_PAGEOUT,
 	WB_REASON_SYNC,
 	WB_REASON_PERIODIC,
 	WB_REASON_LAPTOP_TIMER,
@@ -94,6 +94,8 @@ long writeback_inodes_wb(struct bdi_writ
 				enum wb_reason reason);
 long wb_do_writeback(struct bdi_writeback *wb, int force_wait);
 void wakeup_flusher_threads(long nr_pages, enum wb_reason reason);
+long flush_inode_page(struct address_space *mapping, struct page *page,
+		      bool wait);
 
 /* writeback.h requires fs.h; it, too, is not included from here. */
 static inline void wait_on_inode(struct inode *inode)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
