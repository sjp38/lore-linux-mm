Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 64AAE8D0030
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 09:15:56 -0400 (EDT)
Date: Mon, 1 Nov 2010 20:35:36 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/4] writeback: introduce bdi_start_inode_writeback()
Message-ID: <20101101123536.GA11208@localhost>
References: <20100913123110.372291929@intel.com>
 <20100913130150.138758012@intel.com>
 <20100914133652.GC4874@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100914133652.GC4874@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 14, 2010 at 09:36:52PM +0800, Jan Kara wrote:
> On Mon 13-09-10 20:31:13, Wu Fengguang wrote:
> > This is to transfer dirty pages encountered in page reclaim to the
> > flusher threads for writeback.
> > 
> > The flusher will piggy back more dirty pages for IO
> > - it's more IO efficient
> > - it helps clean more pages, a good number of them may sit in the same
> >   LRU list that is being scanned.
> > 
> > To avoid memory allocations at page reclaim, a mempool is created.
> > 
> > Background/periodic works will quit automatically, so as to clean the
> > pages under reclaim ASAP. However the sync work can still block us for
> > long time.
> > 
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  fs/fs-writeback.c           |  103 +++++++++++++++++++++++++++++++++-
> >  include/linux/backing-dev.h |    2 
> >  2 files changed, 102 insertions(+), 3 deletions(-)
> > 
> ...
> > +int bdi_start_inode_writeback(struct backing_dev_info *bdi,
> > +			      struct inode *inode, pgoff_t offset)
> > +{
> > +	struct wb_writeback_work *work;
> > +
> > +	spin_lock_bh(&bdi->wb_lock);
> > +	list_for_each_entry_reverse(work, &bdi->work_list, list) {
> > +		unsigned long end;
> > +		if (work->inode != inode)
> > +			continue;
>   Hmm, this looks rather inefficient. I can imagine the list of work items
> can grow rather large on memory stressed machine and the linear scan does
> not play well with that (and contention on wb_lock would make it even
> worse). I'm not sure how to best handle your set of intervals... RB tree
> attached to an inode is an obvious choice but it seems too expensive
> (memory spent for every inode) for such a rare use. Maybe you could have
> a per-bdi mapping (hash table) from ino to it's tree of intervals for
> reclaim... But before going for this, probably measuring how many intervals
> are we going to have under memory pressure would be good.

Good point. For now I'll just limit the search to 100 recent works.
Could be further improved later.

> > +		end = work->offset + work->nr_pages;
> > +		if (work->offset - offset < WRITE_AROUND_PAGES) {
>        It's slightly unclear what's intended here when offset >
> work->offset. Could you make that explicit?

It implicitly takes advantage of the "unsigned" compare.  When offset
 > work->offset, "work->offset - offset" will normally be a
huge _positive_ value.  I added a comment for it in the following
updated version. Is this still way too hacky?

Thanks,
Fengguang
---
Subject: vmscan: transfer async file writeback to the flusher

This is to transfer dirty pages encountered in page reclaim to the
flusher threads for writeback.

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

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c           |  118 +++++++++++++++++++++++++++++++++-
 include/linux/backing-dev.h |    2 
 2 files changed, 117 insertions(+), 3 deletions(-)

--- linux-next.orig/mm/vmscan.c	2010-11-01 04:10:37.000000000 +0800
+++ linux-next/mm/vmscan.c	2010-11-01 04:49:47.000000000 +0800
@@ -752,6 +754,16 @@ static unsigned long shrink_page_list(st
 				}
 			}
 
+			if (page_is_file_cache(page) && mapping &&
+			    sync_writeback == PAGEOUT_IO_ASYNC) {
+				if (!bdi_start_inode_writeback(
+					mapping->backing_dev_info,
+					mapping->host, page_index(page))) {
+					SetPageReclaim(page);
+					goto keep_locked;
+				}
+			}
+
 			if (references == PAGEREF_RECLAIM_CLEAN)
 				goto keep_locked;
 			if (!may_enter_fs)
--- linux-next.orig/fs/fs-writeback.c	2010-10-31 19:31:32.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-11-01 04:32:17.000000000 +0800
@@ -30,11 +30,20 @@
 #include "internal.h"
 
 /*
+ * When flushing an inode page (for page reclaim), try to piggy back more
+ * nearby pages for IO efficiency. These pages will have good opportunity
+ * to be in the same LRU list.
+ */
+#define WRITE_AROUND_PAGES	(1UL << (20 - PAGE_CACHE_SHIFT))
+
+/*
  * Passed into wb_writeback(), essentially a subset of writeback_control
  */
 struct wb_writeback_work {
 	long nr_pages;
 	struct super_block *sb;
+	struct inode *inode;
+	pgoff_t offset;
 	enum writeback_sync_modes sync_mode;
 	unsigned int for_kupdate:1;
 	unsigned int range_cyclic:1;
@@ -57,6 +66,27 @@ struct wb_writeback_work {
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
@@ -116,7 +146,7 @@ __bdi_start_writeback(struct backing_dev
 	 * This is WB_SYNC_NONE writeback, so if allocation fails just
 	 * wakeup the thread for old dirty data writeback
 	 */
-	work = kzalloc(sizeof(*work), GFP_ATOMIC);
+	work = mempool_alloc(wb_work_mempool, GFP_NOWAIT);
 	if (!work) {
 		if (bdi->wb.task) {
 			trace_writeback_nowork(bdi);
@@ -125,6 +155,7 @@ __bdi_start_writeback(struct backing_dev
 		return;
 	}
 
+	memset(work, 0, sizeof(*work));
 	work->sync_mode	= WB_SYNC_NONE;
 	work->nr_pages	= nr_pages;
 	work->range_cyclic = range_cyclic;
@@ -169,6 +200,70 @@ void bdi_start_background_writeback(stru
 	spin_unlock_bh(&bdi->wb_lock);
 }
 
+static bool try_extend_writeback_range(struct wb_writeback_work *work,
+				       pgoff_t offset)
+{
+	pgoff_t end = work->offset + work->nr_pages;
+
+	if (offset > work->offset && offset < end)
+		return true;
+
+	/* the unsigned comparison helps eliminate one compare */
+	if (work->offset - offset < WRITE_AROUND_PAGES) {
+		work->nr_pages += work->offset - offset;
+		work->offset = offset;
+		return true;
+	}
+
+	if (offset - end < WRITE_AROUND_PAGES) {
+		work->nr_pages += offset - end;
+		return true;
+	}
+
+	return false;
+}
+
+int bdi_start_inode_writeback(struct backing_dev_info *bdi,
+			      struct inode *inode, pgoff_t offset)
+{
+	struct wb_writeback_work *work;
+	int i = 0;
+
+	spin_lock_bh(&bdi->wb_lock);
+	list_for_each_entry_reverse(work, &bdi->work_list, list) {
+		unsigned long end;
+		if (work->inode != inode)
+			continue;
+		if (try_extend_writeback_range(work, offset)) {
+			inode = NULL;
+			break;
+		}
+		if (i++ > 100)	/* do limited search */
+			break;
+	}
+	spin_unlock_bh(&bdi->wb_lock);
+
+	if (!inode)
+		return 0;
+
+	if (!igrab(inode))
+		return -ENOENT;
+
+	work = mempool_alloc(wb_work_mempool, GFP_NOWAIT);
+	if (!work)
+		return -ENOMEM;
+
+	memset(work, 0, sizeof(*work));
+	work->sync_mode		= WB_SYNC_NONE;
+	work->inode		= inode;
+	work->offset		= offset;
+	work->nr_pages		= 1;
+
+	bdi_queue_work(inode->i_sb->s_bdi, work);
+
+	return 0;
+}
+
 /*
  * Redirty an inode: set its when-it-was dirtied timestamp and move it to the
  * furthest end of its superblock's dirty-inode list.
@@ -745,6 +840,20 @@ get_next_work_item(struct backing_dev_in
 	return work;
 }
 
+static long wb_flush_inode(struct bdi_writeback *wb,
+			   struct wb_writeback_work *work)
+{
+	pgoff_t start = round_down(work->offset, WRITE_AROUND_PAGES);
+	pgoff_t end = round_up(work->offset + work->nr_pages,
+			       WRITE_AROUND_PAGES);
+	int wrote;
+
+	wrote = __filemap_fdatawrite_range(work->inode->i_mapping,
+					   start, end, WB_SYNC_NONE);
+	iput(work->inode);
+	return wrote;
+}
+
 static long wb_check_background_flush(struct bdi_writeback *wb)
 {
 	if (over_bground_thresh()) {
@@ -817,7 +926,10 @@ long wb_do_writeback(struct bdi_writebac
 
 		trace_writeback_exec(bdi, work);
 
-		wrote += wb_writeback(wb, work);
+		if (work->inode)
+			wrote += wb_flush_inode(wb, work);
+		else
+			wrote += wb_writeback(wb, work);
 
 		/*
 		 * Notify the caller of completion if this is a synchronous
@@ -826,7 +938,7 @@ long wb_do_writeback(struct bdi_writebac
 		if (work->done)
 			complete(work->done);
 		else
-			kfree(work);
+			mempool_free(work, wb_work_mempool);
 	}
 
 	/*
--- linux-next.orig/include/linux/backing-dev.h	2010-10-26 11:21:17.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2010-10-31 19:32:00.000000000 +0800
@@ -107,6 +107,8 @@ void bdi_unregister(struct backing_dev_i
 int bdi_setup_and_register(struct backing_dev_info *, char *, unsigned int);
 void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages);
 void bdi_start_background_writeback(struct backing_dev_info *bdi);
+int bdi_start_inode_writeback(struct backing_dev_info *bdi,
+			      struct inode *inode, pgoff_t offset);
 int bdi_writeback_thread(void *data);
 int bdi_has_dirty_io(struct backing_dev_info *bdi);
 void bdi_arm_supers_timer(void);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
