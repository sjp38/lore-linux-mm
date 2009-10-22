Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5B05C6B0062
	for <linux-mm@kvack.org>; Thu, 22 Oct 2009 10:25:12 -0400 (EDT)
Date: Thu, 22 Oct 2009 15:25:12 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Against 2.6.31.4 [PATCH 5/5] Revert 373c0a7e, 8aa7e847: Fix
	congestion_wait() sync/async vs read/write confusion
Message-ID: <20091022142512.GP11778@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <1256221356-26049-6-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1256221356-26049-6-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a clean revert against 2.6.31.4

==== CUT HERE ====
Revert 373c0a7e, 8aa7e847: Fix congestion_wait() sync/async vs read/write confusion

Testing by Frans Pop indicates that in the 2.6.30..2.6.31 window at least
that the commits 373c0a7e 8aa7e847 dramatically increased the number of
GFP_ATOMIC failures that were occuring within a wireless driver. It was
never isolated which of the changes was the exact problem and it's possible
it has been fixed since.

However the fixes, if they exist in mainline, have not been back-ported to
-stable so for the -stable series, it might be best just to revert.

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
 mm/page-writeback.c         |    8 ++++----
 mm/page_alloc.c             |    4 ++--
 mm/vmscan.c                 |    8 ++++----
 16 files changed, 45 insertions(+), 48 deletions(-)

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
index 99a506f..83650e0 100644
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
index f042b96..b28ea64 100644
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
index 6484eb7..f58ecbc 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -286,8 +286,8 @@ __releases(&fc->lock)
 		}
 		if (fc->num_background == FUSE_CONGESTION_THRESHOLD &&
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
 	if (fc->num_background == FUSE_CONGESTION_THRESHOLD &&
 	    fc->bdi_initialized) {
-		set_bdi_congested(&fc->bdi, BLK_RW_SYNC);
-		set_bdi_congested(&fc->bdi, BLK_RW_ASYNC);
+		set_bdi_congested(&fc->bdi, READ);
+		set_bdi_congested(&fc->bdi, WRITE);
 	}
 	list_add_tail(&req->list, &fc->bg_queue);
 	flush_bg_queue(fc);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index a34fae2..5693fcd 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -200,10 +200,8 @@ static int nfs_set_page_writeback(struct page *page)
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
@@ -215,7 +213,7 @@ static void nfs_end_page_writeback(struct page *page)
 
 	end_page_writeback(page);
 	if (atomic_long_dec_return(&nfss->writeback) < NFS_CONGESTION_OFF_THRESH)
-		clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
+		clear_bdi_congested(&nfss->backing_dev_info, WRITE);
 }
 
 /*
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
index 1d52425..0ec2c59 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -229,14 +229,9 @@ static inline int bdi_rw_congested(struct backing_dev_info *bdi)
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
index 69103e0..998c8e0 100644
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
@@ -775,18 +780,18 @@ extern int sg_scsi_ioctl(struct request_queue *, struct gendisk *, fmode_t,
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
index c86edd2..493b468 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -283,6 +283,7 @@ static wait_queue_head_t congestion_wqh[2] = {
 		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[1])
 	};
 
+
 void clear_bdi_congested(struct backing_dev_info *bdi, int sync)
 {
 	enum bdi_state bit;
@@ -307,18 +308,18 @@ EXPORT_SYMBOL(set_bdi_congested);
 
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
index fd4529d..834509f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1990,7 +1990,7 @@ try_to_free:
 		if (!progress) {
 			nr_retries--;
 			/* maybe some writeback is necessary */
-			congestion_wait(BLK_RW_ASYNC, HZ/10);
+			congestion_wait(WRITE, HZ/10);
 		}
 
 	}
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 81627eb..7687879 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -575,7 +575,7 @@ static void balance_dirty_pages(struct address_space *mapping)
 		if (pages_written >= write_chunk)
 			break;		/* We've done our duty */
 
-		congestion_wait(BLK_RW_ASYNC, HZ/10);
+		congestion_wait(WRITE, HZ/10);
 	}
 
 	if (bdi_nr_reclaimable + bdi_nr_writeback < bdi_thresh &&
@@ -669,7 +669,7 @@ void throttle_vm_writeout(gfp_t gfp_mask)
                 if (global_page_state(NR_UNSTABLE_NFS) +
 			global_page_state(NR_WRITEBACK) <= dirty_thresh)
                         	break;
-                congestion_wait(BLK_RW_ASYNC, HZ/10);
+                congestion_wait(WRITE, HZ/10);
 
 		/*
 		 * The caller might hold locks which can prevent IO completion
@@ -715,7 +715,7 @@ static void background_writeout(unsigned long _min_pages)
 		if (wbc.nr_to_write > 0 || wbc.pages_skipped > 0) {
 			/* Wrote less than expected */
 			if (wbc.encountered_congestion || wbc.more_io)
-				congestion_wait(BLK_RW_ASYNC, HZ/10);
+				congestion_wait(WRITE, HZ/10);
 			else
 				break;
 		}
@@ -787,7 +787,7 @@ static void wb_kupdate(unsigned long arg)
 		writeback_inodes(&wbc);
 		if (wbc.nr_to_write > 0) {
 			if (wbc.encountered_congestion || wbc.more_io)
-				congestion_wait(BLK_RW_ASYNC, HZ/10);
+				congestion_wait(WRITE, HZ/10);
 			else
 				break;	/* All the old data is written */
 		}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f7e52af..68f75da 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1684,7 +1684,7 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 			preferred_zone, migratetype);
 
 		if (!page && gfp_mask & __GFP_NOFAIL)
-			congestion_wait(BLK_RW_ASYNC, HZ/50);
+			congestion_wait(WRITE, HZ/50);
 	} while (!page && (gfp_mask & __GFP_NOFAIL));
 
 	/*
@@ -1855,7 +1855,7 @@ rebalance:
 	pages_reclaimed += did_some_progress;
 	if (should_alloc_retry(gfp_mask, order, pages_reclaimed)) {
 		/* Wait for some write requests to complete then retry */
-		congestion_wait(BLK_RW_ASYNC, HZ/50);
+		congestion_wait(WRITE, HZ/50);
 		goto rebalance;
 	}
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a7eafdb..0e66a6b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1109,7 +1109,7 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 		 */
 		if (nr_freed < nr_taken && !current_is_kswapd() &&
 		    lumpy_reclaim) {
-			congestion_wait(BLK_RW_ASYNC, HZ/10);
+			congestion_wait(WRITE, HZ/10);
 
 			/*
 			 * The attempt at page out may have made some
@@ -1726,7 +1726,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 
 		/* Take a nap, wait for some writeback to complete */
 		if (sc->nr_scanned && priority < DEF_PRIORITY - 2)
-			congestion_wait(BLK_RW_ASYNC, HZ/10);
+			congestion_wait(WRITE, HZ/10);
 	}
 	/* top priority shrink_zones still had more to do? don't OOM, then */
 	if (!sc->all_unreclaimable && scanning_global_lru(sc))
@@ -1974,7 +1974,7 @@ loop_again:
 		 * another pass across the zones.
 		 */
 		if (total_scanned && priority < DEF_PRIORITY - 2)
-			congestion_wait(BLK_RW_ASYNC, HZ/10);
+			congestion_wait(WRITE, HZ/10);
 
 		/*
 		 * We do this so kswapd doesn't build up large priorities for
@@ -2247,7 +2247,7 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
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
