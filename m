Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B10F46B032A
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 08:26:41 -0400 (EDT)
Received: by pwi4 with SMTP id 4so868761pwi.9
        for <linux-mm@kvack.org>; Fri, 20 Aug 2010 05:26:40 -0700 (PDT)
Date: Fri, 20 Aug 2010 20:26:27 +0800
From: Wu Fengguang <fengguang.wu@gmail.com>
Subject: Re: why are WB_SYNC_NONE COMMITs being done with FLUSH_SYNC set ?
Message-ID: <20100820122627.GA7430@localhost>
References: <20100819101525.076831ad@barsoom.rdu.redhat.com>
 <20100819143710.GA4752@infradead.org>
 <20100819235553.GB22747@localhost>
 <20100820091904.GB20138@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100820091904.GB20138@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 20, 2010 at 05:19:04AM -0400, Christoph Hellwig wrote:
> On Fri, Aug 20, 2010 at 07:55:53AM +0800, Wu Fengguang wrote:
> > Since migration and pageout still set nonblocking for ->writepage, we
> > may keep them in the near future, until VM does not start IO on itself.
> 
> Why does pageout() and memory migration need to be even more
> non-blocking than the already non-blockig WB_SYNC_NONE writeout?

Good question! So the other nonblocking checks in ->writepage are also
redundant code, let's rip them all!

Thanks,
Fengguang
---

diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 72a5d64..bd11c0e 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -45,8 +45,6 @@ struct writeback_control {
 	loff_t range_start;
 	loff_t range_end;
 
-	unsigned nonblocking:1;		/* Don't get stuck on request queues */
-	unsigned encountered_congestion:1; /* An output: a queue is full */
 	unsigned for_kupdate:1;		/* A kupdate writeback */
 	unsigned for_background:1;	/* A background writeback */
 	unsigned for_reclaim:1;		/* Invoked from the page allocator */
diff --git a/fs/buffer.c b/fs/buffer.c
index 3e7dca2..c9a7a80 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1706,7 +1706,7 @@ static int __block_write_full_page(struct inode *inode, struct page *page,
 		 * and kswapd activity, but those code paths have their own
 		 * higher-level throttling.
 		 */
-		if (wbc->sync_mode != WB_SYNC_NONE || !wbc->nonblocking) {
+		if (wbc->sync_mode != WB_SYNC_NONE) {
 			lock_buffer(bh);
 		} else if (!trylock_buffer(bh)) {
 			redirty_page_for_writepage(wbc, page);
diff --git a/fs/gfs2/meta_io.c b/fs/gfs2/meta_io.c
index f3b071f..939739c 100644
--- a/fs/gfs2/meta_io.c
+++ b/fs/gfs2/meta_io.c
@@ -55,7 +55,7 @@ static int gfs2_aspace_writepage(struct page *page, struct writeback_control *wb
 		 * activity, but those code paths have their own higher-level
 		 * throttling.
 		 */
-		if (wbc->sync_mode != WB_SYNC_NONE || !wbc->nonblocking) {
+		if (wbc->sync_mode != WB_SYNC_NONE) {
 			lock_buffer(bh);
 		} else if (!trylock_buffer(bh)) {
 			redirty_page_for_writepage(wbc, page);
diff --git a/fs/reiserfs/inode.c b/fs/reiserfs/inode.c
index caa7583..c1f9389 100644
--- a/fs/reiserfs/inode.c
+++ b/fs/reiserfs/inode.c
@@ -2438,7 +2438,7 @@ static int reiserfs_write_full_page(struct page *page,
 		/* from this point on, we know the buffer is mapped to a
 		 * real block and not a direct item
 		 */
-		if (wbc->sync_mode != WB_SYNC_NONE || !wbc->nonblocking) {
+		if (wbc->sync_mode != WB_SYNC_NONE) {
 			lock_buffer(bh);
 		} else {
 			if (!trylock_buffer(bh)) {
diff --git a/fs/xfs/linux-2.6/xfs_aops.c b/fs/xfs/linux-2.6/xfs_aops.c
index 15412fe..ec495a4 100644
--- a/fs/xfs/linux-2.6/xfs_aops.c
+++ b/fs/xfs/linux-2.6/xfs_aops.c
@@ -1139,8 +1139,7 @@ xfs_vm_writepage(
 				type = IO_DELAY;
 				flags = BMAPI_ALLOCATE;
 
-				if (wbc->sync_mode == WB_SYNC_NONE &&
-				    wbc->nonblocking)
+				if (wbc->sync_mode == WB_SYNC_NONE)
 					flags |= BMAPI_TRYLOCK;
 			}
 
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index f345f66..0bb01ab 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -96,8 +96,6 @@ DECLARE_EVENT_CLASS(wbc_class,
 		__field(long, nr_to_write)
 		__field(long, pages_skipped)
 		__field(int, sync_mode)
-		__field(int, nonblocking)
-		__field(int, encountered_congestion)
 		__field(int, for_kupdate)
 		__field(int, for_background)
 		__field(int, for_reclaim)
diff --git a/mm/migrate.c b/mm/migrate.c
index 38e7cad..1e5914a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -431,7 +431,6 @@ static int writeout(struct address_space *mapping, struct page *page)
 		.nr_to_write = 1,
 		.range_start = 0,
 		.range_end = LLONG_MAX,
-		.nonblocking = 1,
 		.for_reclaim = 1
 	};
 	int rc;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 225a759..3520523 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -376,7 +376,6 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
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
