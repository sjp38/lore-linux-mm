Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 659C76B0377
	for <linux-mm@kvack.org>; Sat, 21 Aug 2010 02:28:45 -0400 (EDT)
Date: Sat, 21 Aug 2010 14:28:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] writeback: remove nonblocking/encountered_congestion
 references
Message-ID: <20100821062831.GA19911@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Jens Axboe <axboe@kernel.dk>, David Howells <dhowells@redhat.com>, Sage Weil <sage@newdream.net>, Steve French <sfrench@samba.org>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

This removes more dead code that was somehow missed by commit 0d99519efef
(writeback: remove unused nonblocking and congestion checks). There are no
behavior change except for the removal of two entries from one of the ext4
tracing interface.

The nonblocking checks in ->writepages are no longer used because the
flusher now prefer to block on get_request_wait() than to skip inodes on
IO congestion. The latter will lead to more seeky IO.

The nonblocking checks in ->writepage are no longer used because it's
redundant with the WB_SYNC_NONE check.

We no long set ->nonblocking in VM page out and page migration, because
a) it's effectively redundant with WB_SYNC_NONE in current code
b) it's old semantic of "Don't get stuck on request queues" is mis-behavior:
   that would skip some dirty inodes on congestion and page out others, which
   is unfair in terms of LRU age.

Inspired by Christoph Hellwig. Thanks!

CC: Theodore Ts'o <tytso@mit.edu>
CC: David Howells <dhowells@redhat.com>
CC: Sage Weil <sage@newdream.net>
CC: Steve French <sfrench@samba.org>
CC: Chris Mason <chris.mason@oracle.com>
CC: Jens Axboe <axboe@kernel.dk>
CC: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---

Andrew: this passed allmodconfig and allyesconfig compile tests.

This effectively removes all references to wbc->nonblocking and
wbc->encountered_congestion. The NFS git tree has a standalone patch
to remove one wbc->nonblocking reference. To avoid merge conflicts,
the removal of nonblocking/encountered_congestion definitions need to
be delayed for one more kernel release.

 fs/afs/write.c                   |   19 +------------------
 fs/buffer.c                      |    2 +-
 fs/ceph/addr.c                   |    9 ---------
 fs/cifs/file.c                   |   11 -----------
 fs/gfs2/meta_io.c                |    2 +-
 fs/nfs/write.c                   |    6 ++----
 fs/reiserfs/inode.c              |    2 +-
 fs/xfs/linux-2.6/xfs_aops.c      |    3 +--
 include/trace/events/ext4.h      |    8 +++++---
 include/trace/events/writeback.h |    2 --
 mm/migrate.c                     |    1 -
 mm/vmscan.c                      |    1 -
 12 files changed, 12 insertions(+), 54 deletions(-)

Index: mmotm/fs/afs/write.c
===================================================================
--- mmotm.orig/fs/afs/write.c
+++ mmotm/fs/afs/write.c
@@ -438,7 +438,6 @@ no_more:
  */
 int afs_writepage(struct page *page, struct writeback_control *wbc)
 {
-	struct backing_dev_info *bdi = page->mapping->backing_dev_info;
 	struct afs_writeback *wb;
 	int ret;
 
@@ -455,8 +454,6 @@ int afs_writepage(struct page *page, str
 	}
 
 	wbc->nr_to_write -= ret;
-	if (wbc->nonblocking && bdi_write_congested(bdi))
-		wbc->encountered_congestion = 1;
 
 	_leave(" = 0");
 	return 0;
@@ -469,7 +466,6 @@ static int afs_writepages_region(struct 
 				 struct writeback_control *wbc,
 				 pgoff_t index, pgoff_t end, pgoff_t *_next)
 {
-	struct backing_dev_info *bdi = mapping->backing_dev_info;
 	struct afs_writeback *wb;
 	struct page *page;
 	int ret, n;
@@ -529,11 +525,6 @@ static int afs_writepages_region(struct 
 
 		wbc->nr_to_write -= ret;
 
-		if (wbc->nonblocking && bdi_write_congested(bdi)) {
-			wbc->encountered_congestion = 1;
-			break;
-		}
-
 		cond_resched();
 	} while (index < end && wbc->nr_to_write > 0);
 
@@ -548,24 +539,16 @@ static int afs_writepages_region(struct 
 int afs_writepages(struct address_space *mapping,
 		   struct writeback_control *wbc)
 {
-	struct backing_dev_info *bdi = mapping->backing_dev_info;
 	pgoff_t start, end, next;
 	int ret;
 
 	_enter("");
 
-	if (wbc->nonblocking && bdi_write_congested(bdi)) {
-		wbc->encountered_congestion = 1;
-		_leave(" = 0 [congest]");
-		return 0;
-	}
-
 	if (wbc->range_cyclic) {
 		start = mapping->writeback_index;
 		end = -1;
 		ret = afs_writepages_region(mapping, wbc, start, end, &next);
-		if (start > 0 && wbc->nr_to_write > 0 && ret == 0 &&
-		    !(wbc->nonblocking && wbc->encountered_congestion))
+		if (start > 0 && wbc->nr_to_write > 0 && ret == 0)
 			ret = afs_writepages_region(mapping, wbc, 0, start,
 						    &next);
 		mapping->writeback_index = next;
Index: mmotm/fs/buffer.c
===================================================================
--- mmotm.orig/fs/buffer.c
+++ mmotm/fs/buffer.c
@@ -1682,7 +1682,7 @@ static int __block_write_full_page(struc
 		 * and kswapd activity, but those code paths have their own
 		 * higher-level throttling.
 		 */
-		if (wbc->sync_mode != WB_SYNC_NONE || !wbc->nonblocking) {
+		if (wbc->sync_mode != WB_SYNC_NONE) {
 			lock_buffer(bh);
 		} else if (!trylock_buffer(bh)) {
 			redirty_page_for_writepage(wbc, page);
Index: mmotm/fs/ceph/addr.c
===================================================================
--- mmotm.orig/fs/ceph/addr.c
+++ mmotm/fs/ceph/addr.c
@@ -594,7 +594,6 @@ static int ceph_writepages_start(struct 
 				 struct writeback_control *wbc)
 {
 	struct inode *inode = mapping->host;
-	struct backing_dev_info *bdi = mapping->backing_dev_info;
 	struct ceph_inode_info *ci = ceph_inode(inode);
 	struct ceph_client *client;
 	pgoff_t index, start, end;
@@ -636,13 +635,6 @@ static int ceph_writepages_start(struct 
 
 	pagevec_init(&pvec, 0);
 
-	/* ?? */
-	if (wbc->nonblocking && bdi_write_congested(bdi)) {
-		dout(" writepages congested\n");
-		wbc->encountered_congestion = 1;
-		goto out_final;
-	}
-
 	/* where to start/end? */
 	if (wbc->range_cyclic) {
 		start = mapping->writeback_index; /* Start from prev offset */
@@ -887,7 +879,6 @@ out:
 		rc = 0;  /* vfs expects us to return 0 */
 	ceph_put_snap_context(snapc);
 	dout("writepages done, rc = %d\n", rc);
-out_final:
 	return rc;
 }
 
Index: mmotm/fs/cifs/file.c
===================================================================
--- mmotm.orig/fs/cifs/file.c
+++ mmotm/fs/cifs/file.c
@@ -1338,7 +1338,6 @@ static int cifs_partialpagewrite(struct 
 static int cifs_writepages(struct address_space *mapping,
 			   struct writeback_control *wbc)
 {
-	struct backing_dev_info *bdi = mapping->backing_dev_info;
 	unsigned int bytes_to_write;
 	unsigned int bytes_written;
 	struct cifs_sb_info *cifs_sb;
@@ -1380,16 +1379,6 @@ static int cifs_writepages(struct addres
 		return generic_writepages(mapping, wbc);
 
 
-	/*
-	 * BB: Is this meaningful for a non-block-device file system?
-	 * If it is, we should test it again after we do I/O
-	 */
-	if (wbc->nonblocking && bdi_write_congested(bdi)) {
-		wbc->encountered_congestion = 1;
-		kfree(iov);
-		return 0;
-	}
-
 	xid = GetXid();
 
 	pagevec_init(&pvec, 0);
Index: mmotm/fs/gfs2/meta_io.c
===================================================================
--- mmotm.orig/fs/gfs2/meta_io.c
+++ mmotm/fs/gfs2/meta_io.c
@@ -55,7 +55,7 @@ static int gfs2_aspace_writepage(struct 
 		 * activity, but those code paths have their own higher-level
 		 * throttling.
 		 */
-		if (wbc->sync_mode != WB_SYNC_NONE || !wbc->nonblocking) {
+		if (wbc->sync_mode != WB_SYNC_NONE) {
 			lock_buffer(bh);
 		} else if (!trylock_buffer(bh)) {
 			redirty_page_for_writepage(wbc, page);
Index: mmotm/fs/nfs/write.c
===================================================================
--- mmotm.orig/fs/nfs/write.c
+++ mmotm/fs/nfs/write.c
@@ -292,9 +292,7 @@ static int nfs_do_writepage(struct page 
 	nfs_add_stats(inode, NFSIOS_WRITEPAGES, 1);
 
 	nfs_pageio_cond_complete(pgio, page->index);
-	ret = nfs_page_async_flush(pgio, page,
-			wbc->sync_mode == WB_SYNC_NONE ||
-			wbc->nonblocking != 0);
+	ret = nfs_page_async_flush(pgio, page, wbc->sync_mode == WB_SYNC_NONE);
 	if (ret == -EAGAIN) {
 		redirty_page_for_writepage(wbc, page);
 		ret = 0;
Index: mmotm/fs/reiserfs/inode.c
===================================================================
--- mmotm.orig/fs/reiserfs/inode.c
+++ mmotm/fs/reiserfs/inode.c
@@ -2437,7 +2437,7 @@ static int reiserfs_write_full_page(stru
 		/* from this point on, we know the buffer is mapped to a
 		 * real block and not a direct item
 		 */
-		if (wbc->sync_mode != WB_SYNC_NONE || !wbc->nonblocking) {
+		if (wbc->sync_mode != WB_SYNC_NONE) {
 			lock_buffer(bh);
 		} else {
 			if (!trylock_buffer(bh)) {
Index: mmotm/fs/xfs/linux-2.6/xfs_aops.c
===================================================================
--- mmotm.orig/fs/xfs/linux-2.6/xfs_aops.c
+++ mmotm/fs/xfs/linux-2.6/xfs_aops.c
@@ -1139,8 +1139,7 @@ xfs_vm_writepage(
 				type = IO_DELAY;
 				flags = BMAPI_ALLOCATE;
 
-				if (wbc->sync_mode == WB_SYNC_NONE &&
-				    wbc->nonblocking)
+				if (wbc->sync_mode == WB_SYNC_NONE)
 					flags |= BMAPI_TRYLOCK;
 			}
 
Index: mmotm/include/trace/events/ext4.h
===================================================================
--- mmotm.orig/include/trace/events/ext4.h
+++ mmotm/include/trace/events/ext4.h
@@ -242,18 +242,20 @@ TRACE_EVENT(ext4_da_writepages,
 		__entry->pages_skipped	= wbc->pages_skipped;
 		__entry->range_start	= wbc->range_start;
 		__entry->range_end	= wbc->range_end;
-		__entry->nonblocking	= wbc->nonblocking;
 		__entry->for_kupdate	= wbc->for_kupdate;
 		__entry->for_reclaim	= wbc->for_reclaim;
 		__entry->range_cyclic	= wbc->range_cyclic;
 		__entry->writeback_index = inode->i_mapping->writeback_index;
 	),
 
-	TP_printk("dev %s ino %lu nr_to_write %ld pages_skipped %ld range_start %llu range_end %llu nonblocking %d for_kupdate %d for_reclaim %d range_cyclic %d writeback_index %lu",
+	TP_printk("dev %s ino %lu nr_to_write %ld pages_skipped %ld "
+		  "range_start %llu range_end %llu "
+		  "for_kupdate %d for_reclaim %d "
+		  "range_cyclic %d writeback_index %lu",
 		  jbd2_dev_to_name(__entry->dev),
 		  (unsigned long) __entry->ino, __entry->nr_to_write,
 		  __entry->pages_skipped, __entry->range_start,
-		  __entry->range_end, __entry->nonblocking,
+		  __entry->range_end,
 		  __entry->for_kupdate, __entry->for_reclaim,
 		  __entry->range_cyclic,
 		  (unsigned long) __entry->writeback_index)
Index: mmotm/include/trace/events/writeback.h
===================================================================
--- mmotm.orig/include/trace/events/writeback.h
+++ mmotm/include/trace/events/writeback.h
@@ -96,8 +96,6 @@ DECLARE_EVENT_CLASS(wbc_class,
 		__field(long, nr_to_write)
 		__field(long, pages_skipped)
 		__field(int, sync_mode)
-		__field(int, nonblocking)
-		__field(int, encountered_congestion)
 		__field(int, for_kupdate)
 		__field(int, for_background)
 		__field(int, for_reclaim)
Index: mmotm/mm/migrate.c
===================================================================
--- mmotm.orig/mm/migrate.c
+++ mmotm/mm/migrate.c
@@ -431,7 +431,6 @@ static int writeout(struct address_space
 		.nr_to_write = 1,
 		.range_start = 0,
 		.range_end = LLONG_MAX,
-		.nonblocking = 1,
 		.for_reclaim = 1
 	};
 	int rc;
Index: mmotm/mm/vmscan.c
===================================================================
--- mmotm.orig/mm/vmscan.c
+++ mmotm/mm/vmscan.c
@@ -391,7 +391,6 @@ static pageout_t pageout(struct page *pa
 			.nr_to_write = SWAP_CLUSTER_MAX,
 			.range_start = 0,
 			.range_end = LLONG_MAX,
-			.nonblocking = 1,
 			.for_reclaim = 1,
 		};
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
