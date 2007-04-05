Message-Id: <20070405174320.649550491@programming.kicks-ass.net>
References: <20070405174209.498059336@programming.kicks-ass.net>
Date: Thu, 05 Apr 2007 19:42:21 +0200
From: root@programming.kicks-ass.net
Subject: [PATCH 12/12] mm: per BDI congestion feedback
Content-Disposition: inline; filename=bdi_congestion.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com
List-ID: <linux-mm.kvack.org>

Now that we have per BDI dirty throttling is makes sense to also have oer BDI
congestion feedback; why wait on another device if the current one is not
congested.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 drivers/block/pktcdvd.c     |    2 -
 drivers/md/dm-crypt.c       |    7 +++--
 fs/cifs/file.c              |    2 -
 fs/ext4/writeback.c         |    2 -
 fs/fat/file.c               |    4 ++
 fs/fs-writeback.c           |    2 -
 fs/nfs/write.c              |    2 -
 fs/reiser4/vfs_ops.c        |    2 -
 fs/reiserfs/journal.c       |    7 +++--
 fs/xfs/linux-2.6/xfs_aops.c |    2 -
 include/linux/backing-dev.h |    7 +++--
 include/linux/writeback.h   |    3 +-
 mm/backing-dev.c            |   61 ++++++++++++++++++++++++++++----------------
 mm/page-writeback.c         |   19 +++++++------
 mm/vmscan.c                 |   19 +++++++------
 15 files changed, 88 insertions(+), 53 deletions(-)

Index: linux-2.6-mm/include/linux/backing-dev.h
===================================================================
--- linux-2.6-mm.orig/include/linux/backing-dev.h	2007-04-05 18:24:34.000000000 +0200
+++ linux-2.6-mm/include/linux/backing-dev.h	2007-04-05 19:26:24.000000000 +0200
@@ -10,6 +10,7 @@
 
 #include <linux/cpumask.h>
 #include <linux/spinlock.h>
+#include <linux/wait.h>
 #include <asm/atomic.h>
 
 struct page;
@@ -52,6 +53,8 @@ struct backing_dev_info {
 	void (*unplug_io_fn)(struct backing_dev_info *, struct page *);
 	void *unplug_io_data;
 
+	wait_queue_head_t congestion_wqh[2];
+
 	/*
 	 * data used for scaling the writeback cache
 	 */
@@ -214,8 +217,8 @@ static inline int bdi_rw_congested(struc
 
 void clear_bdi_congested(struct backing_dev_info *bdi, int rw);
 void set_bdi_congested(struct backing_dev_info *bdi, int rw);
-long congestion_wait(int rw, long timeout);
-long congestion_wait_interruptible(int rw, long timeout);
+long congestion_wait(struct backing_dev_info *bdi, int rw, long timeout);
+long congestion_wait_interruptible(struct backing_dev_info *bdi, int rw, long timeout);
 
 #define bdi_cap_writeback_dirty(bdi) \
 	(!((bdi)->capabilities & BDI_CAP_NO_WRITEBACK))
Index: linux-2.6-mm/mm/backing-dev.c
===================================================================
--- linux-2.6-mm.orig/mm/backing-dev.c	2007-04-05 18:24:34.000000000 +0200
+++ linux-2.6-mm/mm/backing-dev.c	2007-04-05 18:26:00.000000000 +0200
@@ -5,16 +5,10 @@
 #include <linux/sched.h>
 #include <linux/module.h>
 
-static wait_queue_head_t congestion_wqh[2] = {
-		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[0]),
-		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[1])
-	};
-
-
 void clear_bdi_congested(struct backing_dev_info *bdi, int rw)
 {
 	enum bdi_state bit;
-	wait_queue_head_t *wqh = &congestion_wqh[rw];
+	wait_queue_head_t *wqh = &bdi->congestion_wqh[rw];
 
 	bit = (rw == WRITE) ? BDI_write_congested : BDI_read_congested;
 	clear_bit(bit, &bdi->state);
@@ -42,31 +36,48 @@ EXPORT_SYMBOL(set_bdi_congested);
  * write congestion.  If no backing_devs are congested then just wait for the
  * next write to be completed.
  */
-long congestion_wait(int rw, long timeout)
+long congestion_wait(struct backing_dev_info *bdi, int rw, long timeout)
 {
-	long ret;
+	long ret = 0;
 	DEFINE_WAIT(wait);
-	wait_queue_head_t *wqh = &congestion_wqh[rw];
+	wait_queue_head_t *wqh = &bdi->congestion_wqh[rw];
 
-	prepare_to_wait(wqh, &wait, TASK_UNINTERRUPTIBLE);
-	ret = io_schedule_timeout(timeout);
-	finish_wait(wqh, &wait);
+	if (bdi_congested(bdi, rw)) {
+		for (;;) {
+			prepare_to_wait(wqh, &wait, TASK_UNINTERRUPTIBLE);
+			if (!bdi_congested(bdi, rw))
+				break;
+			ret = io_schedule_timeout(timeout);
+			if (!ret)
+				break;
+		}
+		finish_wait(wqh, &wait);
+	}
 	return ret;
 }
 EXPORT_SYMBOL(congestion_wait);
 
-long congestion_wait_interruptible(int rw, long timeout)
+long congestion_wait_interruptible(struct backing_dev_info *bdi,
+		int rw, long timeout)
 {
-	long ret;
+	long ret = 0;
 	DEFINE_WAIT(wait);
-	wait_queue_head_t *wqh = &congestion_wqh[rw];
+	wait_queue_head_t *wqh = &bdi->congestion_wqh[rw];
 
-	prepare_to_wait(wqh, &wait, TASK_INTERRUPTIBLE);
-	if (signal_pending(current))
-		ret = -ERESTARTSYS;
-	else
-		ret = io_schedule_timeout(timeout);
-	finish_wait(wqh, &wait);
+	if (bdi_congested(bdi, rw)) {
+		for (;;) {
+			prepare_to_wait(wqh, &wait, TASK_INTERRUPTIBLE);
+			if (!bdi_congested(bdi, rw))
+				break;
+			if (signal_pending(current))
+				ret = -ERESTARTSYS;
+			else
+				ret = io_schedule_timeout(timeout);
+			if (!ret)
+				break;
+		}
+		finish_wait(wqh, &wait);
+	}
 	return ret;
 }
 EXPORT_SYMBOL(congestion_wait_interruptible);
@@ -78,6 +89,10 @@ void bdi_init(struct backing_dev_info *b
 {
 	int i;
 
+	for (i = 0; i < ARRAY_SIZE(bdi->congestion_wqh); i++)
+		bdi->congestion_wqh[i] = (wait_queue_head_t)
+			__WAIT_QUEUE_HEAD_INITIALIZER(bdi->congestion_wqh[i]);
+
 	spin_lock_init(&bdi->lock);
 	bdi->cycles = 0;
 
@@ -195,3 +210,5 @@ void dec_bdi_stat(struct backing_dev_inf
 }
 EXPORT_SYMBOL(dec_bdi_stat);
 #endif
+
+
Index: linux-2.6-mm/mm/page-writeback.c
===================================================================
--- linux-2.6-mm.orig/mm/page-writeback.c	2007-04-05 18:24:34.000000000 +0200
+++ linux-2.6-mm/mm/page-writeback.c	2007-04-05 18:24:34.000000000 +0200
@@ -366,7 +366,7 @@ static void balance_dirty_pages(struct a
 			if (pages_written >= write_chunk)
 				break;		/* We've done our duty */
 		}
-		congestion_wait(WRITE, HZ/10);
+		congestion_wait(bdi, WRITE, HZ/10);
 	}
 
 	if (writeback_in_progress(bdi))
@@ -462,15 +462,17 @@ static void background_writeout(unsigned
 			global_page_state(NR_UNSTABLE_NFS) < background_thresh
 				&& min_pages <= 0)
 			break;
-		wbc.encountered_congestion = 0;
+		wbc.encountered_congestion = NULL;
 		wbc.nr_to_write = MAX_WRITEBACK_PAGES;
 		wbc.pages_skipped = 0;
 		writeback_inodes(&wbc);
 		min_pages -= MAX_WRITEBACK_PAGES - wbc.nr_to_write;
 		if (wbc.nr_to_write > 0 || wbc.pages_skipped > 0) {
 			/* Wrote less than expected */
-			congestion_wait(WRITE, HZ/10);
-			if (!wbc.encountered_congestion)
+			if (wbc.encountered_congestion)
+				congestion_wait(wbc.encountered_congestion,
+						WRITE, HZ/10);
+			else
 				break;
 		}
 	}
@@ -535,12 +537,13 @@ static void wb_kupdate(unsigned long arg
 			global_page_state(NR_UNSTABLE_NFS) +
 			(inodes_stat.nr_inodes - inodes_stat.nr_unused);
 	while (nr_to_write > 0) {
-		wbc.encountered_congestion = 0;
+		wbc.encountered_congestion = NULL;
 		wbc.nr_to_write = MAX_WRITEBACK_PAGES;
 		writeback_inodes(&wbc);
 		if (wbc.nr_to_write > 0) {
 			if (wbc.encountered_congestion)
-				congestion_wait(WRITE, HZ/10);
+				congestion_wait(wbc.encountered_congestion,
+					       	WRITE, HZ/10);
 			else
 				break;	/* All the old data is written */
 		}
@@ -698,7 +701,7 @@ int write_cache_pages(struct address_spa
 	int range_whole = 0;
 
 	if (wbc->nonblocking && bdi_write_congested(bdi)) {
-		wbc->encountered_congestion = 1;
+		wbc->encountered_congestion = bdi;
 		return 0;
 	}
 
@@ -760,7 +763,7 @@ retry:
 			if (ret || (--(wbc->nr_to_write) <= 0))
 				done = 1;
 			if (wbc->nonblocking && bdi_write_congested(bdi)) {
-				wbc->encountered_congestion = 1;
+				wbc->encountered_congestion = bdi;
 				done = 1;
 			}
 		}
Index: linux-2.6-mm/drivers/block/pktcdvd.c
===================================================================
--- linux-2.6-mm.orig/drivers/block/pktcdvd.c	2007-04-05 18:24:29.000000000 +0200
+++ linux-2.6-mm/drivers/block/pktcdvd.c	2007-04-05 18:24:34.000000000 +0200
@@ -2589,7 +2589,7 @@ static int pkt_make_request(request_queu
 		set_bdi_congested(&q->backing_dev_info, WRITE);
 		do {
 			spin_unlock(&pd->lock);
-			congestion_wait(WRITE, HZ);
+			congestion_wait(&q->backing_dev_info, WRITE, HZ);
 			spin_lock(&pd->lock);
 		} while(pd->bio_queue_size > pd->write_congestion_off);
 	}
Index: linux-2.6-mm/drivers/md/dm-crypt.c
===================================================================
--- linux-2.6-mm.orig/drivers/md/dm-crypt.c	2007-04-05 18:24:29.000000000 +0200
+++ linux-2.6-mm/drivers/md/dm-crypt.c	2007-04-05 18:24:34.000000000 +0200
@@ -640,8 +640,11 @@ static void process_write(struct crypt_i
 		 * may be gone already. */
 
 		/* out of memory -> run queues */
-		if (remaining)
-			congestion_wait(WRITE, HZ/100);
+		if (remaining) {
+			struct backing_dev_info *bdi =
+				&io->target->table->md->queue->backing_dev_info;
+			congestion_wait(bdi, WRITE, HZ/100);
+		}
 	}
 }
 
Index: linux-2.6-mm/fs/fat/file.c
===================================================================
--- linux-2.6-mm.orig/fs/fat/file.c	2007-04-05 18:24:28.000000000 +0200
+++ linux-2.6-mm/fs/fat/file.c	2007-04-05 18:24:34.000000000 +0200
@@ -118,8 +118,10 @@ static int fat_file_release(struct inode
 {
 	if ((filp->f_mode & FMODE_WRITE) &&
 	     MSDOS_SB(inode->i_sb)->options.flush) {
+		struct backing_dev_info *bdi =
+			inode->i_mapping->backing_dev_info;
 		fat_flush_inodes(inode->i_sb, inode, NULL);
-		congestion_wait(WRITE, HZ/10);
+		congestion_wait(bdi, WRITE, HZ/10);
 	}
 	return 0;
 }
Index: linux-2.6-mm/fs/reiserfs/journal.c
===================================================================
--- linux-2.6-mm.orig/fs/reiserfs/journal.c	2007-04-05 18:24:28.000000000 +0200
+++ linux-2.6-mm/fs/reiserfs/journal.c	2007-04-05 18:25:00.000000000 +0200
@@ -970,8 +970,11 @@ int reiserfs_async_progress_wait(struct 
 {
 	DEFINE_WAIT(wait);
 	struct reiserfs_journal *j = SB_JOURNAL(s);
-	if (atomic_read(&j->j_async_throttle))
-		congestion_wait(WRITE, HZ / 10);
+	if (atomic_read(&j->j_async_throttle)) {
+		struct backing_dev_info *bdi =
+			blk_get_backing_dev_info(j->j_dev_bd);
+		congestion_wait(bdi, WRITE, HZ / 10);
+	}
 	return 0;
 }
 
Index: linux-2.6-mm/include/linux/writeback.h
===================================================================
--- linux-2.6-mm.orig/include/linux/writeback.h	2007-04-05 18:24:34.000000000 +0200
+++ linux-2.6-mm/include/linux/writeback.h	2007-04-05 18:24:34.000000000 +0200
@@ -54,11 +54,12 @@ struct writeback_control {
 	loff_t range_end;
 
 	unsigned nonblocking:1;		/* Don't get stuck on request queues */
-	unsigned encountered_congestion:1; /* An output: a queue is full */
 	unsigned for_kupdate:1;		/* A kupdate writeback */
 	unsigned for_reclaim:1;		/* Invoked from the page allocator */
 	unsigned for_writepages:1;	/* This is a writepages() call */
 	unsigned range_cyclic:1;	/* range_start is cyclic */
+
+	struct backing_dev_info *encountered_congestion; /* An output: a queue is full */
 };
 
 /*
Index: linux-2.6-mm/fs/cifs/file.c
===================================================================
--- linux-2.6-mm.orig/fs/cifs/file.c	2007-04-05 18:24:28.000000000 +0200
+++ linux-2.6-mm/fs/cifs/file.c	2007-04-05 18:24:34.000000000 +0200
@@ -1143,7 +1143,7 @@ static int cifs_writepages(struct addres
 	 * If it is, we should test it again after we do I/O
 	 */
 	if (wbc->nonblocking && bdi_write_congested(bdi)) {
-		wbc->encountered_congestion = 1;
+		wbc->encountered_congestion = bdi;
 		kfree(iov);
 		return 0;
 	}
Index: linux-2.6-mm/fs/ext4/writeback.c
===================================================================
--- linux-2.6-mm.orig/fs/ext4/writeback.c	2007-04-05 18:24:28.000000000 +0200
+++ linux-2.6-mm/fs/ext4/writeback.c	2007-04-05 18:24:34.000000000 +0200
@@ -782,7 +782,7 @@ int ext4_wb_writepages(struct address_sp
 #ifdef EXT4_WB_STATS
 				atomic_inc(&EXT4_SB(inode->i_sb)->s_wb_congested);
 #endif
-				wbc->encountered_congestion = 1;
+				wbc->encountered_congestion = bdi;
 				done = 1;
 			}
 		}
Index: linux-2.6-mm/fs/fs-writeback.c
===================================================================
--- linux-2.6-mm.orig/fs/fs-writeback.c	2007-04-05 18:24:29.000000000 +0200
+++ linux-2.6-mm/fs/fs-writeback.c	2007-04-05 18:24:34.000000000 +0200
@@ -349,7 +349,7 @@ int generic_sync_sb_inodes(struct super_
 		}
 
 		if (wbc->nonblocking && bdi_write_congested(bdi)) {
-			wbc->encountered_congestion = 1;
+			wbc->encountered_congestion = bdi;
 			if (!sb_is_blkdev_sb(sb))
 				break;		/* Skip a congested fs */
 			list_move(&inode->i_list, &sb->s_dirty);
Index: linux-2.6-mm/fs/reiser4/vfs_ops.c
===================================================================
--- linux-2.6-mm.orig/fs/reiser4/vfs_ops.c	2007-04-05 18:24:29.000000000 +0200
+++ linux-2.6-mm/fs/reiser4/vfs_ops.c	2007-04-05 18:24:34.000000000 +0200
@@ -169,7 +169,7 @@ void reiser4_writeout(struct super_block
 		if (wbc->nonblocking &&
 		    bdi_write_congested(mapping->backing_dev_info)) {
 			blk_run_address_space(mapping);
-			wbc->encountered_congestion = 1;
+			wbc->encountered_congestion = mapping->backing_dev_info;
 			break;
 		}
 		repeats++;
Index: linux-2.6-mm/fs/xfs/linux-2.6/xfs_aops.c
===================================================================
--- linux-2.6-mm.orig/fs/xfs/linux-2.6/xfs_aops.c	2007-04-05 18:24:28.000000000 +0200
+++ linux-2.6-mm/fs/xfs/linux-2.6/xfs_aops.c	2007-04-05 18:24:34.000000000 +0200
@@ -777,7 +777,7 @@ xfs_convert_page(
 			bdi = inode->i_mapping->backing_dev_info;
 			wbc->nr_to_write--;
 			if (bdi_write_congested(bdi)) {
-				wbc->encountered_congestion = 1;
+				wbc->encountered_congestion = bdi;
 				done = 1;
 			} else if (wbc->nr_to_write <= 0) {
 				done = 1;
Index: linux-2.6-mm/mm/vmscan.c
===================================================================
--- linux-2.6-mm.orig/mm/vmscan.c	2007-04-05 18:24:34.000000000 +0200
+++ linux-2.6-mm/mm/vmscan.c	2007-04-05 18:24:34.000000000 +0200
@@ -71,7 +71,7 @@ struct scan_control {
 
 	int order;
 
-	int encountered_congestion;
+	struct backing_dev_info *encountered_congestion;
 };
 
 /*
@@ -376,7 +376,7 @@ static pageout_t pageout(struct page *pa
 			bdi = mapping->backing_dev_info;
 
 		if (bdi_congested(bdi, WRITE))
-			sc->encountered_congestion = 1;
+			sc->encountered_congestion = bdi;
 
 		SetPageReclaim(page);
 		res = mapping->a_ops->writepage(page, &wbc);
@@ -1153,7 +1153,7 @@ unsigned long try_to_free_pages(struct z
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		sc.nr_scanned = 0;
-		sc.encountered_congestion = 0;
+		sc.encountered_congestion = NULL;
 		if (!priority)
 			disable_swap_token();
 		nr_reclaimed += shrink_zones(priority, zones, &sc);
@@ -1183,7 +1183,8 @@ unsigned long try_to_free_pages(struct z
 
 		/* Take a nap, wait for some writeback to complete */
 		if (sc.encountered_congestion)
-			congestion_wait(WRITE, HZ/10);
+			congestion_wait(sc.encountered_congestion,
+					WRITE, HZ/10);
 	}
 	/* top priority shrink_caches still had more to do? don't OOM, then */
 	if (!sc.all_unreclaimable)
@@ -1263,7 +1264,7 @@ loop_again:
 		int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 		unsigned long lru_pages = 0;
 
-		sc.encountered_congestion = 0;
+		sc.encountered_congestion = NULL;
 		/* The swap token gets in the way of swapout... */
 		if (!priority)
 			disable_swap_token();
@@ -1352,7 +1353,8 @@ loop_again:
 		 * another pass across the zones.
 		 */
 		if (sc.encountered_congestion)
-			congestion_wait(WRITE, HZ/10);
+			congestion_wait(sc.encountered_congestion,
+					WRITE, HZ/10);
 
 		/*
 		 * We do this so kswapd doesn't build up large priorities for
@@ -1594,7 +1596,7 @@ unsigned long shrink_all_memory(unsigned
 			unsigned long nr_to_scan = nr_pages - ret;
 
 			sc.nr_scanned = 0;
-			sc.encountered_congestion = 0;
+			sc.encountered_congestion = NULL;
 			ret += shrink_all_zones(nr_to_scan, prio, pass, &sc);
 			if (ret >= nr_pages)
 				goto out;
@@ -1607,7 +1609,8 @@ unsigned long shrink_all_memory(unsigned
 				goto out;
 
 			if (sc.encountered_congestion)
-				congestion_wait(WRITE, HZ / 10);
+				congestion_wait(sc.encountered_congestion,
+						WRITE, HZ / 10);
 		}
 	}
 
Index: linux-2.6-mm/fs/nfs/write.c
===================================================================
--- linux-2.6-mm.orig/fs/nfs/write.c	2007-04-05 18:24:33.000000000 +0200
+++ linux-2.6-mm/fs/nfs/write.c	2007-04-05 18:24:34.000000000 +0200
@@ -567,7 +567,7 @@ static int nfs_wait_on_write_congestion(
 		sigset_t oldset;
 
 		rpc_clnt_sigmask(clnt, &oldset);
-		ret = congestion_wait_interruptible(WRITE, HZ/10);
+		ret = congestion_wait_interruptible(bdi, WRITE, HZ/10);
 		rpc_clnt_sigunmask(clnt, &oldset);
 		if (ret == -ERESTARTSYS)
 			break;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
