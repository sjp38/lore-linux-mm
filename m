Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 437A96B0071
	for <linux-mm@kvack.org>; Thu, 22 Oct 2009 10:22:49 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 5/5] ONLY-APPLY-IF-STILL-FAILING Revert 373c0a7e, 8aa7e847: Fix congestion_wait() sync/async vs read/write confusion
Date: Thu, 22 Oct 2009 15:22:36 +0100
Message-Id: <1256221356-26049-6-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Testing by Frans Pop indicates that in the 2.6.30..2.6.31 window at
least that the commits 373c0a7e 8aa7e847 dramatically increased the
number of GFP_ATOMIC failures that were occuring within a wireless
driver. It was never isolated which of the changes was the exact problem
and it's possible it has been fixed since. If problems are still
occuring with GFP_ATOMIC in 2.6.31-rc5, then this patch should be
applied to determine if the congestion_wait() callers are still broken.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 arch/x86/lib/usercopy_32.c  |    2 +-
 drivers/block/pktcdvd.c     |   10 ++++------
 drivers/md/dm-crypt.c       |    2 +-
 fs/fat/file.c               |    2 +-
 fs/fuse/dev.c               |    8 ++++----
 fs/nfs/write.c              |    8 +++-----
 fs/reiserfs/journal.c       |    2 +-
 fs/xfs/linux-2.6/kmem.c     |    4 ++--
 fs/xfs/linux-2.6/xfs_buf.c  |    2 +-
 include/linux/backing-dev.h |   11 +++--------
 include/linux/blkdev.h      |   13 +++++++++----
 mm/backing-dev.c            |    7 ++++---
 mm/memcontrol.c             |    2 +-
 mm/page-writeback.c         |    2 +-
 mm/page_alloc.c             |    4 ++--
 mm/vmscan.c                 |    8 ++++----
 16 files changed, 42 insertions(+), 45 deletions(-)

diff --git a/arch/x86/lib/usercopy_32.c b/arch/x86/lib/usercopy_32.c
index 1f118d4..7c8ca91 100644
--- a/arch/x86/lib/usercopy_32.c
+++ b/arch/x86/lib/usercopy_32.c
@@ -751,7 +751,7 @@ survive:
 
 			if (retval == -ENOMEM && is_global_init(current)) {
 				up_read(&current->mm->mmap_sem);
-				congestion_wait(BLK_RW_ASYNC, HZ/50);
+				congestion_wait(WRITE, HZ/50);
 				goto survive;
 			}
 
diff --git a/drivers/block/pktcdvd.c b/drivers/block/pktcdvd.c
index 2ddf03a..d69bf9c 100644
--- a/drivers/block/pktcdvd.c
+++ b/drivers/block/pktcdvd.c
@@ -1372,10 +1372,8 @@ try_next_bio:
 	wakeup = (pd->write_congestion_on > 0
 	 		&& pd->bio_queue_size <= pd->write_congestion_off);
 	spin_unlock(&pd->lock);
-	if (wakeup) {
-		clear_bdi_congested(&pd->disk->queue->backing_dev_info,
-					BLK_RW_ASYNC);
-	}
+	if (wakeup)
+		clear_bdi_congested(&pd->disk->queue->backing_dev_info, WRITE);
 
 	pkt->sleep_time = max(PACKET_WAIT_TIME, 1);
 	pkt_set_state(pkt, PACKET_WAITING_STATE);
@@ -2594,10 +2592,10 @@ static int pkt_make_request(struct request_queue *q, struct bio *bio)
 	spin_lock(&pd->lock);
 	if (pd->write_congestion_on > 0
 	    && pd->bio_queue_size >= pd->write_congestion_on) {
-		set_bdi_congested(&q->backing_dev_info, BLK_RW_ASYNC);
+		set_bdi_congested(&q->backing_dev_info, WRITE);
 		do {
 			spin_unlock(&pd->lock);
-			congestion_wait(BLK_RW_ASYNC, HZ);
+			congestion_wait(WRITE, HZ);
 			spin_lock(&pd->lock);
 		} while(pd->bio_queue_size > pd->write_congestion_off);
 	}
diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
index ed10381..c72a8dd 100644
--- a/drivers/md/dm-crypt.c
+++ b/drivers/md/dm-crypt.c
@@ -776,7 +776,7 @@ static void kcryptd_crypt_write_convert(struct dm_crypt_io *io)
 		 * But don't wait if split was due to the io size restriction
 		 */
 		if (unlikely(out_of_pages))
-			congestion_wait(BLK_RW_ASYNC, HZ/100);
+			congestion_wait(WRITE, HZ/100);
 
 		/*
 		 * With async crypto it is unsafe to share the crypto context
diff --git a/fs/fat/file.c b/fs/fat/file.c
index e8c159d..ef60a65 100644
--- a/fs/fat/file.c
+++ b/fs/fat/file.c
@@ -134,7 +134,7 @@ static int fat_file_release(struct inode *inode, struct file *filp)
 	if ((filp->f_mode & FMODE_WRITE) &&
 	     MSDOS_SB(inode->i_sb)->options.flush) {
 		fat_flush_inodes(inode->i_sb, inode, NULL);
-		congestion_wait(BLK_RW_ASYNC, HZ/10);
+		congestion_wait(WRITE, HZ/10);
 	}
 	return 0;
 }
diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index 51d9e33..b152761 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -286,8 +286,8 @@ __releases(&fc->lock)
 		}
 		if (fc->num_background == fc->congestion_threshold &&
 		    fc->connected && fc->bdi_initialized) {
-			clear_bdi_congested(&fc->bdi, BLK_RW_SYNC);
-			clear_bdi_congested(&fc->bdi, BLK_RW_ASYNC);
+			clear_bdi_congested(&fc->bdi, READ);
+			clear_bdi_congested(&fc->bdi, WRITE);
 		}
 		fc->num_background--;
 		fc->active_background--;
@@ -414,8 +414,8 @@ static void fuse_request_send_nowait_locked(struct fuse_conn *fc,
 		fc->blocked = 1;
 	if (fc->num_background == fc->congestion_threshold &&
 	    fc->bdi_initialized) {
-		set_bdi_congested(&fc->bdi, BLK_RW_SYNC);
-		set_bdi_congested(&fc->bdi, BLK_RW_ASYNC);
+		set_bdi_congested(&fc->bdi, READ);
+		set_bdi_congested(&fc->bdi, WRITE);
 	}
 	list_add_tail(&req->list, &fc->bg_queue);
 	flush_bg_queue(fc);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 53eb26c..bb9cc66 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -202,10 +202,8 @@ static int nfs_set_page_writeback(struct page *page)
 		struct nfs_server *nfss = NFS_SERVER(inode);
 
 		if (atomic_long_inc_return(&nfss->writeback) >
-				NFS_CONGESTION_ON_THRESH) {
-			set_bdi_congested(&nfss->backing_dev_info,
-						BLK_RW_ASYNC);
-		}
+				NFS_CONGESTION_ON_THRESH)
+			set_bdi_congested(&nfss->backing_dev_info, WRITE);
 	}
 	return ret;
 }
@@ -217,7 +215,7 @@ static void nfs_end_page_writeback(struct page *page)
 
 	end_page_writeback(page);
 	if (atomic_long_dec_return(&nfss->writeback) < NFS_CONGESTION_OFF_THRESH)
-		clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
+		clear_bdi_congested(&nfss->backing_dev_info, WRITE);
 }
 
 static struct nfs_page *nfs_find_and_lock_request(struct page *page)
diff --git a/fs/reiserfs/journal.c b/fs/reiserfs/journal.c
index 9062220..77f5bb7 100644
--- a/fs/reiserfs/journal.c
+++ b/fs/reiserfs/journal.c
@@ -997,7 +997,7 @@ static int reiserfs_async_progress_wait(struct super_block *s)
 	DEFINE_WAIT(wait);
 	struct reiserfs_journal *j = SB_JOURNAL(s);
 	if (atomic_read(&j->j_async_throttle))
-		congestion_wait(BLK_RW_ASYNC, HZ / 10);
+		congestion_wait(WRITE, HZ / 10);
 	return 0;
 }
 
diff --git a/fs/xfs/linux-2.6/kmem.c b/fs/xfs/linux-2.6/kmem.c
index 2d3f90a..1cd3b55 100644
--- a/fs/xfs/linux-2.6/kmem.c
+++ b/fs/xfs/linux-2.6/kmem.c
@@ -53,7 +53,7 @@ kmem_alloc(size_t size, unsigned int __nocast flags)
 			printk(KERN_ERR "XFS: possible memory allocation "
 					"deadlock in %s (mode:0x%x)\n",
 					__func__, lflags);
-		congestion_wait(BLK_RW_ASYNC, HZ/50);
+		congestion_wait(WRITE, HZ/50);
 	} while (1);
 }
 
@@ -130,7 +130,7 @@ kmem_zone_alloc(kmem_zone_t *zone, unsigned int __nocast flags)
 			printk(KERN_ERR "XFS: possible memory allocation "
 					"deadlock in %s (mode:0x%x)\n",
 					__func__, lflags);
-		congestion_wait(BLK_RW_ASYNC, HZ/50);
+		congestion_wait(WRITE, HZ/50);
 	} while (1);
 }
 
diff --git a/fs/xfs/linux-2.6/xfs_buf.c b/fs/xfs/linux-2.6/xfs_buf.c
index 965df12..178c20c 100644
--- a/fs/xfs/linux-2.6/xfs_buf.c
+++ b/fs/xfs/linux-2.6/xfs_buf.c
@@ -412,7 +412,7 @@ _xfs_buf_lookup_pages(
 
 			XFS_STATS_INC(xb_page_retries);
 			xfsbufd_wakeup(0, gfp_mask);
-			congestion_wait(BLK_RW_ASYNC, HZ/50);
+			congestion_wait(WRITE, HZ/50);
 			goto retry;
 		}
 
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index b449e73..58f5d0c 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -273,14 +273,9 @@ static inline int bdi_rw_congested(struct backing_dev_info *bdi)
 				  (1 << BDI_async_congested));
 }
 
-enum {
-	BLK_RW_ASYNC	= 0,
-	BLK_RW_SYNC	= 1,
-};
-
-void clear_bdi_congested(struct backing_dev_info *bdi, int sync);
-void set_bdi_congested(struct backing_dev_info *bdi, int sync);
-long congestion_wait(int sync, long timeout);
+void clear_bdi_congested(struct backing_dev_info *bdi, int rw);
+void set_bdi_congested(struct backing_dev_info *bdi, int rw);
+long congestion_wait(int rw, long timeout);
 
 
 static inline bool bdi_cap_writeback_dirty(struct backing_dev_info *bdi)
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 221cecd..51a6320 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -70,6 +70,11 @@ enum rq_cmd_type_bits {
 	REQ_TYPE_ATA_PC,
 };
 
+enum {
+	BLK_RW_ASYNC	= 0,
+	BLK_RW_SYNC	= 1,
+};
+
 /*
  * For request of type REQ_TYPE_LINUX_BLOCK, rq->cmd[0] is the opcode being
  * sent down (similar to how REQ_TYPE_BLOCK_PC means that ->cmd[] holds a
@@ -784,18 +789,18 @@ extern int sg_scsi_ioctl(struct request_queue *, struct gendisk *, fmode_t,
  * congested queues, and wake up anyone who was waiting for requests to be
  * put back.
  */
-static inline void blk_clear_queue_congested(struct request_queue *q, int sync)
+static inline void blk_clear_queue_congested(struct request_queue *q, int rw)
 {
-	clear_bdi_congested(&q->backing_dev_info, sync);
+	clear_bdi_congested(&q->backing_dev_info, rw);
 }
 
 /*
  * A queue has just entered congestion.  Flag that in the queue's VM-visible
  * state flags and increment the global gounter of congested queues.
  */
-static inline void blk_set_queue_congested(struct request_queue *q, int sync)
+static inline void blk_set_queue_congested(struct request_queue *q, int rw)
 {
-	set_bdi_congested(&q->backing_dev_info, sync);
+	set_bdi_congested(&q->backing_dev_info, rw);
 }
 
 extern void blk_start_queue(struct request_queue *q);
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 5a37e20..d68d6e4 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -696,6 +696,7 @@ static wait_queue_head_t congestion_wqh[2] = {
 		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[1])
 	};
 
+
 void clear_bdi_congested(struct backing_dev_info *bdi, int sync)
 {
 	enum bdi_state bit;
@@ -720,18 +721,18 @@ EXPORT_SYMBOL(set_bdi_congested);
 
 /**
  * congestion_wait - wait for a backing_dev to become uncongested
- * @sync: SYNC or ASYNC IO
+ * @rw: READ or WRITE
  * @timeout: timeout in jiffies
  *
  * Waits for up to @timeout jiffies for a backing_dev (any backing_dev) to exit
  * write congestion.  If no backing_devs are congested then just wait for the
  * next write to be completed.
  */
-long congestion_wait(int sync, long timeout)
+long congestion_wait(int rw, long timeout)
 {
 	long ret;
 	DEFINE_WAIT(wait);
-	wait_queue_head_t *wqh = &congestion_wqh[sync];
+	wait_queue_head_t *wqh = &congestion_wqh[rw];
 
 	prepare_to_wait(wqh, &wait, TASK_UNINTERRUPTIBLE);
 	ret = io_schedule_timeout(timeout);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f99f599..f92ee06 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2430,7 +2430,7 @@ try_to_free:
 		if (!progress) {
 			nr_retries--;
 			/* maybe some writeback is necessary */
-			congestion_wait(BLK_RW_ASYNC, HZ/10);
+			congestion_wait(WRITE, HZ/10);
 		}
 
 	}
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 2c5d792..b300954 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -671,7 +671,7 @@ void throttle_vm_writeout(gfp_t gfp_mask)
                 if (global_page_state(NR_UNSTABLE_NFS) +
 			global_page_state(NR_WRITEBACK) <= dirty_thresh)
                         	break;
-                congestion_wait(BLK_RW_ASYNC, HZ/10);
+                congestion_wait(WRITE, HZ/10);
 
 		/*
 		 * The caller might hold locks which can prevent IO completion
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 851df40..2cd0fbb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1738,7 +1738,7 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 			preferred_zone, migratetype);
 
 		if (!page && gfp_mask & __GFP_NOFAIL)
-			congestion_wait(BLK_RW_ASYNC, HZ/50);
+			congestion_wait(WRITE, HZ/50);
 	} while (!page && (gfp_mask & __GFP_NOFAIL));
 
 	/*
@@ -1909,7 +1909,7 @@ rebalance:
 	pages_reclaimed += did_some_progress;
 	if (should_alloc_retry(gfp_mask, order, pages_reclaimed)) {
 		/* Wait for some write requests to complete then retry */
-		congestion_wait(BLK_RW_ASYNC, HZ/50);
+		congestion_wait(WRITE, HZ/50);
 		goto rebalance;
 	}
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index cd68109..3805e59 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1174,7 +1174,7 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 		 */
 		if (nr_freed < nr_taken && !current_is_kswapd() &&
 		    lumpy_reclaim) {
-			congestion_wait(BLK_RW_ASYNC, HZ/10);
+			congestion_wait(WRITE, HZ/10);
 
 			/*
 			 * The attempt at page out may have made some
@@ -1783,7 +1783,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 
 		/* Take a nap, wait for some writeback to complete */
 		if (sc->nr_scanned && priority < DEF_PRIORITY - 2)
-			congestion_wait(BLK_RW_ASYNC, HZ/10);
+			congestion_wait(WRITE, HZ/10);
 	}
 	/* top priority shrink_zones still had more to do? don't OOM, then */
 	if (!sc->all_unreclaimable && scanning_global_lru(sc))
@@ -2074,7 +2074,7 @@ loop_again:
 		 * another pass across the zones.
 		 */
 		if (total_scanned && priority < DEF_PRIORITY - 2)
-			congestion_wait(BLK_RW_ASYNC, HZ/10);
+			congestion_wait(WRITE, HZ/10);
 
 		/*
 		 * We do this so kswapd doesn't build up large priorities for
@@ -2378,7 +2378,7 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
 				goto out;
 
 			if (sc.nr_scanned && prio < DEF_PRIORITY - 2)
-				congestion_wait(BLK_RW_ASYNC, HZ / 10);
+				congestion_wait(WRITE, HZ / 10);
 		}
 	}
 
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
