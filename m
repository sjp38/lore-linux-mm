Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F08B89000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:06:07 -0400 (EDT)
Date: Tue, 26 Apr 2011 22:05:36 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/6] writeback: sync expired inodes first in background
 writeback
Message-ID: <20110426140536.GA12554@localhost>
References: <20110420080336.441157866@intel.com>
 <20110420080918.383880412@intel.com>
 <20110420164005.e3925965.akpm@linux-foundation.org>
 <20110424031531.GA11220@localhost>
 <20110426121751.GB5114@quack.suse.cz>
 <20110426135130.GA5719@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110426135130.GA5719@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

> I scratched a patch (totally untested) which will guarantee any kind
> of starvation inside an inode. Will this be too overweight?
> 
> Thanks,
> Fengguang
> ---
> Subject: writeback: livelock prevention inside actively dirtied files
> Date: Tue Apr 26 21:35:47 CST 2011
> 
> - refresh dirtied_when on every full writeback_index cycle
>   (pages may be skipped on SYNC_NONE, but as long as they are retried in
>   next cycle..)
> 
> - do tagged sync when writeback_index not cycled for too long time
>   (the arbitrarily 60s may lead to more page tagging overheads in
>   "large dirty threshold but slow storage" system..)
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/fs-writeback.c       |    1 +
>  include/linux/fs.h      |    1 +
>  include/linux/pagemap.h |   16 ++++++++++++++++
>  mm/page-writeback.c     |   24 ++++++++++++++++++------
>  4 files changed, 36 insertions(+), 6 deletions(-)

FYI to make it easier, the above patch is actually based upon this one.
---
Subject: writeback: quit on wrap for .range_cyclic
Date: Mon Apr 25 14:58:19 CST 2011

Convert wbc.range_cyclic to new behavior: when past EOF, abort the
writeback of the current inode, which will instruct
writeback_single_inode() to redirty_tail() it.

This is the right behavior for
- sync writeback (is already so with range_whole)
  we have scanned the inode address space, and don't care any more newly
  dirtied pages. So shall update its i_dirtied_when and exclude it from
  the todo list.
- periodic writeback
  any more newly dirtied pages should be associated with a new expire
  time. This also prevents pointless IO for busy overwriters.
- background writeback
  irrelevant because it generally don't care the dirty timestamp.

That should get rid of one inefficient IO pattern of .range_cyclic when
writeback_index wraps, in which the submitted pages may be consisted of
two distant ranges: submit [10000-10100], (wrap), submit [0-100].

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 drivers/staging/pohmelfs/inode.c |   25 ++++++++-----------------
 fs/afs/write.c                   |    7 +++----
 fs/btrfs/extent_io.c             |   21 ++++++---------------
 fs/cifs/file.c                   |   15 +++------------
 fs/ext4/inode.c                  |   18 ++++--------------
 fs/gfs2/aops.c                   |   16 ++--------------
 mm/page-writeback.c              |   27 +++++----------------------
 7 files changed, 31 insertions(+), 98 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-04-25 14:56:33.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-04-25 14:57:09.000000000 +0800
@@ -868,35 +868,27 @@ int write_cache_pages(struct address_spa
 	int done = 0;
 	struct pagevec pvec;
 	int nr_pages;
-	pgoff_t uninitialized_var(writeback_index);
 	pgoff_t index;
 	pgoff_t end;		/* Inclusive */
 	pgoff_t done_index;
-	int cycled;
 	int range_whole = 0;
 	int tag;
 
 	pagevec_init(&pvec, 0);
 	if (wbc->range_cyclic) {
-		writeback_index = mapping->writeback_index; /* prev offset */
-		index = writeback_index;
-		if (index == 0)
-			cycled = 1;
-		else
-			cycled = 0;
+		index = mapping->writeback_index; /* prev offset */
 		end = -1;
 	} else {
 		index = wbc->range_start >> PAGE_CACHE_SHIFT;
 		end = wbc->range_end >> PAGE_CACHE_SHIFT;
 		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
 			range_whole = 1;
-		cycled = 1; /* ignore range_cyclic tests */
 	}
 	if (wbc->sync_mode == WB_SYNC_ALL)
 		tag = PAGECACHE_TAG_TOWRITE;
 	else
 		tag = PAGECACHE_TAG_DIRTY;
-retry:
+
 	if (wbc->sync_mode == WB_SYNC_ALL)
 		tag_pages_for_writeback(mapping, index, end);
 	done_index = index;
@@ -905,8 +897,10 @@ retry:
 
 		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index, tag,
 			      min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1);
-		if (nr_pages == 0)
+		if (nr_pages == 0) {
+			done_index = 0;
 			break;
+		}
 
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
@@ -998,17 +992,6 @@ continue_unlock:
 		pagevec_release(&pvec);
 		cond_resched();
 	}
-	if (!cycled && !done) {
-		/*
-		 * range_cyclic:
-		 * We hit the last page and there is more work to be done: wrap
-		 * back to the start of the file
-		 */
-		cycled = 1;
-		index = 0;
-		end = writeback_index - 1;
-		goto retry;
-	}
 	if (wbc->range_cyclic || (range_whole && wbc->nr_to_write > 0))
 		mapping->writeback_index = done_index;
 
--- linux-next.orig/drivers/staging/pohmelfs/inode.c	2011-03-31 13:53:02.000000000 +0800
+++ linux-next/drivers/staging/pohmelfs/inode.c	2011-04-25 14:57:03.000000000 +0800
@@ -148,7 +148,6 @@ static int pohmelfs_writepages(struct ad
 	int nr_pages;
 	pgoff_t index;
 	pgoff_t end;		/* Inclusive */
-	int scanned = 0;
 	int range_whole = 0;
 
 	if (wbc->range_cyclic) {
@@ -159,17 +158,18 @@ static int pohmelfs_writepages(struct ad
 		end = wbc->range_end >> PAGE_CACHE_SHIFT;
 		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
 			range_whole = 1;
-		scanned = 1;
 	}
-retry:
+
 	while (!done && (index <= end)) {
 		unsigned int i = min(end - index, (pgoff_t)psb->trans_max_pages);
 		int path_len;
 		struct netfs_trans *trans;
 
 		err = pohmelfs_inode_has_dirty_pages(mapping, index);
-		if (!err)
+		if (!err) {
+			index = 0;
 			break;
+		}
 
 		err = pohmelfs_path_length(pi);
 		if (err < 0)
@@ -196,15 +196,16 @@ retry:
 		dprintk("%s: t: %p, nr_pages: %u, end: %lu, index: %lu, max: %u.\n",
 				__func__, trans, nr_pages, end, index, trans->page_num);
 
-		if (!nr_pages)
+		if (!nr_pages) {
+			index = 0;
 			goto err_out_reset;
+		}
 
 		err = pohmelfs_write_inode_create(inode, trans);
 		if (err)
 			goto err_out_reset;
 
 		err = 0;
-		scanned = 1;
 
 		for (i = 0; i < trans->page_num; i++) {
 			struct page *page = trans->pages[i];
@@ -214,7 +215,7 @@ retry:
 			if (unlikely(page->mapping != mapping))
 				goto out_continue;
 
-			if (!wbc->range_cyclic && page->index > end) {
+			if (page->index > end) {
 				done = 1;
 				goto out_continue;
 			}
@@ -262,16 +263,6 @@ err_out_reset:
 		break;
 	}
 
-	if (!scanned && !done) {
-		/*
-		 * We hit the last page and there is more work to be done: wrap
-		 * back to the start of the file
-		 */
-		scanned = 1;
-		index = 0;
-		goto retry;
-	}
-
 	if (wbc->range_cyclic || (range_whole && wbc->nr_to_write > 0))
 		mapping->writeback_index = index;
 
--- linux-next.orig/fs/btrfs/extent_io.c	2011-04-20 17:08:47.000000000 +0800
+++ linux-next/fs/btrfs/extent_io.c	2011-04-25 14:57:50.000000000 +0800
@@ -2464,10 +2464,9 @@ static int extent_write_cache_pages(stru
 	int done = 0;
 	int nr_to_write_done = 0;
 	struct pagevec pvec;
-	int nr_pages;
+	int nr_pages = 1;
 	pgoff_t index;
 	pgoff_t end;		/* Inclusive */
-	int scanned = 0;
 
 	pagevec_init(&pvec, 0);
 	if (wbc->range_cyclic) {
@@ -2476,16 +2475,14 @@ static int extent_write_cache_pages(stru
 	} else {
 		index = wbc->range_start >> PAGE_CACHE_SHIFT;
 		end = wbc->range_end >> PAGE_CACHE_SHIFT;
-		scanned = 1;
 	}
-retry:
+
 	while (!done && !nr_to_write_done && (index <= end) &&
 	       (nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
 			      PAGECACHE_TAG_DIRTY, min(end - index,
 				  (pgoff_t)PAGEVEC_SIZE-1) + 1))) {
 		unsigned i;
 
-		scanned = 1;
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
 
@@ -2506,7 +2503,7 @@ retry:
 				continue;
 			}
 
-			if (!wbc->range_cyclic && page->index > end) {
+			if (page->index > end) {
 				done = 1;
 				unlock_page(page);
 				continue;
@@ -2543,15 +2540,9 @@ retry:
 		pagevec_release(&pvec);
 		cond_resched();
 	}
-	if (!scanned && !done) {
-		/*
-		 * We hit the last page and there is more work to be done: wrap
-		 * back to the start of the file
-		 */
-		scanned = 1;
-		index = 0;
-		goto retry;
-	}
+	if (!nr_pages)
+		mapping->writeback_index = 0;
+
 	return ret;
 }
 
--- linux-next.orig/fs/cifs/file.c	2011-04-20 17:08:47.000000000 +0800
+++ linux-next/fs/cifs/file.c	2011-04-25 14:58:00.000000000 +0800
@@ -1200,7 +1200,6 @@ static int cifs_writepages(struct addres
 	struct page *page;
 	struct pagevec pvec;
 	int rc = 0;
-	int scanned = 0;
 	int xid;
 
 	cifs_sb = CIFS_SB(mapping->host->i_sb);
@@ -1241,9 +1240,8 @@ static int cifs_writepages(struct addres
 		end = wbc->range_end >> PAGE_CACHE_SHIFT;
 		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
 			range_whole = 1;
-		scanned = 1;
 	}
-retry:
+
 	while (!done && (index <= end) &&
 	       (nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
 			PAGECACHE_TAG_DIRTY,
@@ -1276,7 +1274,7 @@ retry:
 				break;
 			}
 
-			if (!wbc->range_cyclic && page->index > end) {
+			if (page->index > end) {
 				done = 1;
 				unlock_page(page);
 				break;
@@ -1403,15 +1401,8 @@ retry_write:
 
 		pagevec_release(&pvec);
 	}
-	if (!scanned && !done) {
-		/*
-		 * We hit the last page and there is more work to be done: wrap
-		 * back to the start of the file
-		 */
-		scanned = 1;
+	if (!nr_pages)
 		index = 0;
-		goto retry;
-	}
 	if (wbc->range_cyclic || (range_whole && wbc->nr_to_write > 0))
 		mapping->writeback_index = index;
 
--- linux-next.orig/fs/ext4/inode.c	2011-04-12 11:13:27.000000000 +0800
+++ linux-next/fs/ext4/inode.c	2011-04-25 15:01:30.000000000 +0800
@@ -2893,7 +2893,7 @@ static int ext4_da_writepages(struct add
 	struct inode *inode = mapping->host;
 	int pages_written = 0;
 	unsigned int max_pages;
-	int range_cyclic, cycled = 1, io_done = 0;
+	int range_cyclic, io_done = 0;
 	int needed_blocks, ret = 0;
 	long desired_nr_to_write, nr_to_writebump = 0;
 	loff_t range_start = wbc->range_start;
@@ -2930,8 +2930,6 @@ static int ext4_da_writepages(struct add
 	range_cyclic = wbc->range_cyclic;
 	if (wbc->range_cyclic) {
 		index = mapping->writeback_index;
-		if (index)
-			cycled = 0;
 		wbc->range_start = index << PAGE_CACHE_SHIFT;
 		wbc->range_end  = LLONG_MAX;
 		wbc->range_cyclic = 0;
@@ -2974,7 +2972,6 @@ static int ext4_da_writepages(struct add
 		wbc->nr_to_write = desired_nr_to_write;
 	}
 
-retry:
 	if (wbc->sync_mode == WB_SYNC_ALL)
 		tag_pages_for_writeback(mapping, index, end);
 
@@ -3034,20 +3031,13 @@ retry:
 			pages_written += mpd.pages_written;
 			ret = 0;
 			io_done = 1;
-		} else if (wbc->nr_to_write)
+		} else if (wbc->nr_to_write > 0) {
 			/*
 			 * There is no more writeout needed
-			 * or we requested for a noblocking writeout
-			 * and we found the device congested
 			 */
+			index = 0;
 			break;
-	}
-	if (!io_done && !cycled) {
-		cycled = 1;
-		index = 0;
-		wbc->range_start = index << PAGE_CACHE_SHIFT;
-		wbc->range_end  = mapping->writeback_index - 1;
-		goto retry;
+		}
 	}
 
 	/* Update index */
--- linux-next.orig/fs/gfs2/aops.c	2011-03-31 13:53:21.000000000 +0800
+++ linux-next/fs/gfs2/aops.c	2011-04-25 14:57:03.000000000 +0800
@@ -283,7 +283,7 @@ static int gfs2_write_jdata_pagevec(stru
 			continue;
 		}
 
-		if (!wbc->range_cyclic && page->index > end) {
+		if (page->index > end) {
 			ret = 1;
 			unlock_page(page);
 			continue;
@@ -335,7 +335,6 @@ static int gfs2_write_cache_jdata(struct
 	int nr_pages;
 	pgoff_t index;
 	pgoff_t end;
-	int scanned = 0;
 	int range_whole = 0;
 
 	pagevec_init(&pvec, 0);
@@ -347,15 +346,12 @@ static int gfs2_write_cache_jdata(struct
 		end = wbc->range_end >> PAGE_CACHE_SHIFT;
 		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
 			range_whole = 1;
-		scanned = 1;
 	}
 
-retry:
 	 while (!done && (index <= end) &&
 		(nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
 					       PAGECACHE_TAG_DIRTY,
 					       min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1))) {
-		scanned = 1;
 		ret = gfs2_write_jdata_pagevec(mapping, wbc, &pvec, nr_pages, end);
 		if (ret)
 			done = 1;
@@ -366,16 +362,8 @@ retry:
 		cond_resched();
 	}
 
-	if (!scanned && !done) {
-		/*
-		 * We hit the last page and there is more work to be done: wrap
-		 * back to the start of the file
-		 */
-		scanned = 1;
+	if (!nr_pages)
 		index = 0;
-		goto retry;
-	}
-
 	if (wbc->range_cyclic || (range_whole && wbc->nr_to_write > 0))
 		mapping->writeback_index = index;
 	return ret;
--- linux-next.orig/fs/afs/write.c	2011-03-02 17:41:41.000000000 +0800
+++ linux-next/fs/afs/write.c	2011-04-25 14:57:03.000000000 +0800
@@ -476,8 +476,10 @@ static int afs_writepages_region(struct 
 	do {
 		n = find_get_pages_tag(mapping, &index, PAGECACHE_TAG_DIRTY,
 				       1, &page);
-		if (!n)
+		if (!n) {
+			index = 0;
 			break;
+		}
 
 		_debug("wback %lx", page->index);
 
@@ -549,9 +551,6 @@ int afs_writepages(struct address_space 
 		start = mapping->writeback_index;
 		end = -1;
 		ret = afs_writepages_region(mapping, wbc, start, end, &next);
-		if (start > 0 && wbc->nr_to_write > 0 && ret == 0)
-			ret = afs_writepages_region(mapping, wbc, 0, start,
-						    &next);
 		mapping->writeback_index = next;
 	} else if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX) {
 		end = (pgoff_t)(LLONG_MAX >> PAGE_CACHE_SHIFT);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
