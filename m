Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 330B1600815
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 10:38:24 -0400 (EDT)
Date: Tue, 27 Jul 2010 15:38:05 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 8/8] vmscan: Kick flusher threads to clean pages when
	reclaim is encountering dirty pages
Message-ID: <20100727143805.GB5300@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie> <1279545090-19169-9-git-send-email-mel@csn.ul.ie> <20100726072832.GB13076@localhost> <20100726092616.GG5300@csn.ul.ie> <20100726112709.GB6284@localhost> <20100726125717.GS5300@csn.ul.ie> <20100726131008.GE11947@localhost> <20100727133513.GZ5300@csn.ul.ie> <20100727142412.GA4771@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100727142412.GA4771@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 27, 2010 at 10:24:13PM +0800, Wu Fengguang wrote:
> On Tue, Jul 27, 2010 at 09:35:13PM +0800, Mel Gorman wrote:
> > On Mon, Jul 26, 2010 at 09:10:08PM +0800, Wu Fengguang wrote:
> > > On Mon, Jul 26, 2010 at 08:57:17PM +0800, Mel Gorman wrote:
> > > > On Mon, Jul 26, 2010 at 07:27:09PM +0800, Wu Fengguang wrote:
> > > > > > > > @@ -933,13 +934,16 @@ keep_dirty:
> > > > > > > >  		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
> > > > > > > >  	}
> > > > > > > >  
> > > > > > > > +	/*
> > > > > > > > +	 * If reclaim is encountering dirty pages, it may be because
> > > > > > > > +	 * dirty pages are reaching the end of the LRU even though
> > > > > > > > +	 * the dirty_ratio may be satisified. In this case, wake
> > > > > > > > +	 * flusher threads to pro-actively clean some pages
> > > > > > > > +	 */
> > > > > > > > +	wakeup_flusher_threads(laptop_mode ? 0 : nr_dirty + nr_dirty / 2);
> > > > > > > 
> > > > > > > Ah it's very possible that nr_dirty==0 here! Then you are hitting the
> > > > > > > number of dirty pages down to 0 whether or not pageout() is called.
> > > > > > > 
> > > > > > 
> > > > > > True, this has been fixed to only wakeup flusher threads when this is
> > > > > > the file LRU, dirty pages have been encountered and the caller has
> > > > > > sc->may_writepage.
> > > > > 
> > > > > OK.
> > > > > 
> > > > > > > Another minor issue is, the passed (nr_dirty + nr_dirty / 2) is
> > > > > > > normally a small number, much smaller than MAX_WRITEBACK_PAGES.
> > > > > > > The flusher will sync at least MAX_WRITEBACK_PAGES pages, this is good
> > > > > > > for efficiency.
> > > > > > > And it seems good to let the flusher write much more
> > > > > > > than nr_dirty pages to safeguard a reasonable large
> > > > > > > vmscan-head-to-first-dirty-LRU-page margin. So it would be enough to
> > > > > > > update the comments.
> > > > > > > 
> > > > > > 
> > > > > > Ok, the reasoning had been to flush a number of pages that was related
> > > > > > to the scanning rate but if that is inefficient for the flusher, I'll
> > > > > > use MAX_WRITEBACK_PAGES.
> > > > > 
> > > > > It would be better to pass something like (nr_dirty * N).
> > > > > MAX_WRITEBACK_PAGES may be increased to 128MB in the future, which is
> > > > > obviously too large as a parameter. When the batch size is increased
> > > > > to 128MB, the writeback code may be improved somehow to not exceed the
> > > > > nr_pages limit too much.
> > > > > 
> > > > 
> > > > What might be a useful value for N? 1.5 appears to work reasonably well
> > > > to create a window of writeback ahead of the scanner but it's a bit
> > > > arbitrary.
> > > 
> > > I'd recommend N to be a large value. It's no longer relevant now since
> > > we'll call the flusher to sync some range containing the target page.
> > > The flusher will then choose an N large enough (eg. 4MB) for efficient
> > > IO. It needs to be a large value, otherwise the vmscan code will
> > > quickly run into dirty pages again..
> > > 
> > 
> > Ok, I took the 4MB at face value to be a "reasonable amount that should
> > not cause congestion".
> 
> Under memory pressure, the disk should be busy/congested anyway.

Not necessarily. It could be streaming reads where pages are being added
to the LRU quickly but not necessarily dominated by dirty pages. Due to the
scanning rate, a dirty page may be encountered but it could be rare.

> The big 4MB adds much work, however many of the pages may need to be
> synced in the near future anyway. It also requires more time to do
> the bigger IO, hence adding some latency, however the latency should
> be a small factor comparing to the IO queue time (which will be long
> for a busy disk).
> 
> Overall expectation is, the more efficient IO, the more progress :)
> 

Ok.

> > The end result is
> > 
> > #define MAX_WRITEBACK (4194304UL >> PAGE_SHIFT)
> > #define WRITEBACK_FACTOR (MAX_WRITEBACK / SWAP_CLUSTER_MAX)
> > static inline long nr_writeback_pages(unsigned long nr_dirty)
> > {
> >         return laptop_mode ? 0 :
> >                         min(MAX_WRITEBACK, (nr_dirty * WRITEBACK_FACTOR));
> > }
> > 
> > nr_writeback_pages(nr_dirty) is what gets passed to
> > wakeup_flusher_threads(). Does that seem sensible?
> 
> If you plan to keep wakeup_flusher_threads(), a simpler form may be
> sufficient, eg.
> 
>         laptop_mode ? 0 : (nr_dirty * 16)
> 

I plan to keep wakeup_flusher_threads() for now. I didn't go with 16 because
while nr_dirty will usually be < SWAP_CLUSTER_MAX, it might not be due to lumpy
reclaim. I wanted to firmly bound how much writeback was being requested -
hence the mild complexity.

> On top of this, we may write another patch to convert the
> wakeup_flusher_threads(bdi, nr_pages) call to some
> bdi_start_inode_writeback(inode, offset) call, to start more oriented
> writeback.
> 

I did a first pass at optimising based on prioritising inodes related to
dirty pages. It's incredibly primitive and I have to sit down and see
how the entire of writeback is put together to improve on it. Maybe
you'll spot something simple or see if it's the totally wrong direction.
Patch is below.

> When talking the 4MB optimization, I was referring to the internal
> implementation of bdi_start_inode_writeback(). Sorry for the missing
> context in the previous email.
> 

No worries, I was assuming it was something in mainline I didn't know
yet :)

> It may need a big patch to implement bdi_start_inode_writeback().
> Would you like to try it, or leave the task to me?
> 

If you send me a patch, I can try it out but it's not my highest
priority right now. I'm still looking to get writeback-from-reclaim down
to a reasonable level without causing a large amount of churn.

Here is the first pass anyway at kicking wakeup_flusher_threads() for
inodes belonging to a list of pages. You'll note that I do nothing with
page offset because I didn't spot a simple way of taking that
information into account. It's also horrible from a locking perspective.
So far, it's testing has been "it didn't crash".

==== CUT HERE ====
writeback: Prioritise dirty inodes encountered by reclaim for background flushing

It is preferable that as few dirty pages as possible are dispatched for
cleaning from the page reclaim path. When dirty pages are encountered by
page reclaim, this patch marks the inodes that they should be dispatched
immediately. When the background flusher runs, it moves such inodes immediately
to the dispatch queue regardless of inode age.

This is an early prototype. It could be optimised to not regularly take
the inode lock repeatedly and ideally the page offset would also be
taken into account.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 fs/fs-writeback.c         |   52 ++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/fs.h        |    5 ++-
 include/linux/writeback.h |    1 +
 mm/vmscan.c               |    6 +++-
 4 files changed, 59 insertions(+), 5 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 5a3c764..27a8b75 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -221,7 +221,7 @@ static void move_expired_inodes(struct list_head *delaying_queue,
 	LIST_HEAD(tmp);
 	struct list_head *pos, *node;
 	struct super_block *sb = NULL;
-	struct inode *inode;
+	struct inode *inode, *tinode;
 	int do_sb_sort = 0;
 
 	if (wbc->for_kupdate || wbc->for_background) {
@@ -229,6 +229,14 @@ static void move_expired_inodes(struct list_head *delaying_queue,
 		older_than_this = jiffies - expire_interval;
 	}
 
+	/* Move inodes reclaim found at end of LRU to dispatch queue */
+	list_for_each_entry_safe(inode, tinode, delaying_queue, i_list) {
+		if (inode->i_state & I_DIRTY_RECLAIM) {
+			inode->i_state &= ~I_DIRTY_RECLAIM;
+			list_move(&inode->i_list, &tmp);
+		}
+	}
+
 	while (!list_empty(delaying_queue)) {
 		inode = list_entry(delaying_queue->prev, struct inode, i_list);
 		if (expire_interval &&
@@ -906,6 +914,48 @@ void wakeup_flusher_threads(long nr_pages)
 	rcu_read_unlock();
 }
 
+/*
+ * Similar to wakeup_flusher_threads except prioritise inodes contained
+ * in the page_list regardless of age
+ */
+void wakeup_flusher_threads_pages(long nr_pages, struct list_head *page_list)
+{
+	struct page *page;
+	struct address_space *mapping;
+	struct inode *inode;
+
+	list_for_each_entry(page, page_list, lru) {
+		if (!PageDirty(page))
+			continue;
+
+		lock_page(page);
+		mapping = page_mapping(page);
+		if (!mapping || mapping == &swapper_space)
+			goto unlock;
+
+		/*
+		 * Test outside the lock to see as if it is already set, taking
+		 * the inode lock is a waste and the inode should be pinned by
+		 * the lock_page
+		 */
+		inode = page->mapping->host;
+		if (inode->i_state & I_DIRTY_RECLAIM)
+			goto unlock;
+
+		/*
+		 * XXX: Yuck, has to be a way of batching this by not requiring
+		 * 	the page lock to pin the inode
+		 */
+		spin_lock(&inode_lock);
+		inode->i_state |= I_DIRTY_RECLAIM;
+		spin_unlock(&inode_lock);
+unlock:
+		unlock_page(page);
+	}
+
+	wakeup_flusher_threads(nr_pages);
+}
+
 static noinline void block_dump___mark_inode_dirty(struct inode *inode)
 {
 	if (inode->i_ino || strcmp(inode->i_sb->s_id, "bdev")) {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index e29f0ed..8836698 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1585,8 +1585,8 @@ struct super_operations {
 /*
  * Inode state bits.  Protected by inode_lock.
  *
- * Three bits determine the dirty state of the inode, I_DIRTY_SYNC,
- * I_DIRTY_DATASYNC and I_DIRTY_PAGES.
+ * Four bits determine the dirty state of the inode, I_DIRTY_SYNC,
+ * I_DIRTY_DATASYNC, I_DIRTY_PAGES and I_DIRTY_RECLAIM.
  *
  * Four bits define the lifetime of an inode.  Initially, inodes are I_NEW,
  * until that flag is cleared.  I_WILL_FREE, I_FREEING and I_CLEAR are set at
@@ -1633,6 +1633,7 @@ struct super_operations {
 #define I_DIRTY_SYNC		1
 #define I_DIRTY_DATASYNC	2
 #define I_DIRTY_PAGES		4
+#define I_DIRTY_RECLAIM		256
 #define __I_NEW			3
 #define I_NEW			(1 << __I_NEW)
 #define I_WILL_FREE		16
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 494edd6..73a4df2 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -64,6 +64,7 @@ void writeback_inodes_wb(struct bdi_writeback *wb,
 		struct writeback_control *wbc);
 long wb_do_writeback(struct bdi_writeback *wb, int force_wait);
 void wakeup_flusher_threads(long nr_pages);
+void wakeup_flusher_threads_pages(long nr_pages, struct list_head *page_list);
 
 /* writeback.h requires fs.h; it, too, is not included from here. */
 static inline void wait_on_inode(struct inode *inode)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b66d1f5..bad1abf 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -901,7 +901,8 @@ keep:
 	 * laptop mode avoiding disk spin-ups
 	 */
 	if (file && nr_dirty_seen && sc->may_writepage)
-		wakeup_flusher_threads(nr_writeback_pages(nr_dirty));
+		wakeup_flusher_threads_pages(nr_writeback_pages(nr_dirty),
+					page_list);
 
 	*nr_still_dirty = nr_dirty;
 	count_vm_events(PGACTIVATE, pgactivate);
@@ -1368,7 +1369,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 				list_add(&page->lru, &putback_list);
 			}
 
-			wakeup_flusher_threads(laptop_mode ? 0 : nr_dirty);
+			wakeup_flusher_threads_pages(laptop_mode ? 0 : nr_dirty,
+								&page_list);
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 			/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
