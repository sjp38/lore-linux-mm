Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD27B6B0038
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 08:45:24 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id t193so119713922ywc.0
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 05:45:24 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id e185si13081352ywb.151.2016.10.20.05.45.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Oct 2016 05:45:22 -0700 (PDT)
From: <zhouxianrong@huawei.com>
Subject: [PATCH] bdi flusher should not be throttled here when it fall into buddy slow path
Date: Thu, 20 Oct 2016 20:38:05 +0800
Message-ID: <1476967085-89647-1-git-send-email-zhouxianrong@huawei.com>
In-Reply-To: <1476774765-21130-1-git-send-email-zhouxianrong@huawei.com>
References: <1476774765-21130-1-git-send-email-zhouxianrong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, mingo@redhat.com, peterz@infradead.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, mhocko@suse.com, vdavydov.dev@gmail.com, minchan@kernel.org, riel@redhat.com, zhouxianrong@huawei.com, zhouxiyu@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com, tuxiaobing@huawei.com

From: z00281421 <z00281421@notesmail.huawei.com>

The bdi flusher should be throttled only depends on 
own bdi and is decoupled with others.

separate PGDAT_WRITEBACK into PGDAT_ANON_WRITEBACK and
PGDAT_FILE_WRITEBACK avoid scanning anon lru and it is ok 
then throttled on file WRITEBACK.

i think above may be not right.

Signed-off-by: z00281421 <z00281421@notesmail.huawei.com>
---
 fs/fs-writeback.c      |    8 ++++++--
 include/linux/mmzone.h |    7 +++++--
 mm/vmscan.c            |   20 ++++++++++++--------
 3 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 05713a5..ddcc70f 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1905,10 +1905,13 @@ void wb_workfn(struct work_struct *work)
 {
 	struct bdi_writeback *wb = container_of(to_delayed_work(work),
 						struct bdi_writeback, dwork);
+	struct backing_dev_info *bdi = container_of(to_delayed_work(work),
+						struct backing_dev_info, wb.dwork);
 	long pages_written;
 
 	set_worker_desc("flush-%s", dev_name(wb->bdi->dev));
-	current->flags |= PF_SWAPWRITE;
+	current->flags |= (PF_SWAPWRITE | PF_LESS_THROTTLE);
+	current->bdi = bdi;
 
 	if (likely(!current_is_workqueue_rescuer() ||
 		   !test_bit(WB_registered, &wb->state))) {
@@ -1938,7 +1941,8 @@ void wb_workfn(struct work_struct *work)
 	else if (wb_has_dirty_io(wb) && dirty_writeback_interval)
 		wb_wakeup_delayed(wb);
 
-	current->flags &= ~PF_SWAPWRITE;
+	current->bdi = NULL;
+	current->flags &= ~(PF_SWAPWRITE | PF_LESS_THROTTLE);
 }
 
 /*
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 7f2ae99..fa602e9 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -528,8 +528,11 @@ enum pgdat_flags {
 					 * many dirty file pages at the tail
 					 * of the LRU.
 					 */
-	PGDAT_WRITEBACK,		/* reclaim scanning has recently found
-					 * many pages under writeback
+	PGDAT_ANON_WRITEBACK,		/* reclaim scanning has recently found
+					 * many anonymous pages under writeback
+					 */
+	PGDAT_FILE_WRITEBACK,		/* reclaim scanning has recently found
+					 * many file pages under writeback
 					 */
 	PGDAT_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
 };
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0fe8b71..3f08ba3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -917,6 +917,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_writeback = 0;
 	unsigned long nr_immediate = 0;
+	int file;
 
 	cond_resched();
 
@@ -954,6 +955,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
 			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
 
+		file = page_is_file_cache(page)
+
 		/*
 		 * The number of dirty pages determines if a zone is marked
 		 * reclaim_congested which affects wait_iff_congested. kswapd
@@ -1016,7 +1019,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			/* Case 1 above */
 			if (current_is_kswapd() &&
 			    PageReclaim(page) &&
-			    test_bit(PGDAT_WRITEBACK, &pgdat->flags)) {
+			    test_bit(PGDAT_ANON_WRITEBACK + file, &pgdat->flags)) {
 				nr_immediate++;
 				goto keep_locked;
 
@@ -1643,13 +1646,14 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
  * If a kernel thread (such as nfsd for loop-back mounts) services
  * a backing device by writing to the page cache it sets PF_LESS_THROTTLE.
  * In that case we should only throttle if the backing device it is
- * writing to is congested.  In other cases it is safe to throttle.
+ * writing to is congested. The bdi flusher should be throttled only depends
+ * on own bdi and is decoupled with others. In other cases it is safe to throttle.
  */
-static int current_may_throttle(void)
+static int current_may_throttle(int file)
 {
 	return !(current->flags & PF_LESS_THROTTLE) ||
-		current->backing_dev_info == NULL ||
-		bdi_write_congested(current->backing_dev_info);
+		(file && (current->backing_dev_info == NULL ||
+		bdi_write_congested(current->backing_dev_info)));
 }
 
 static bool inactive_reclaimable_pages(struct lruvec *lruvec,
@@ -1774,7 +1778,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	 * are encountered in the nr_immediate check below.
 	 */
 	if (nr_writeback && nr_writeback == nr_taken)
-		set_bit(PGDAT_WRITEBACK, &pgdat->flags);
+		set_bit(PGDAT_ANON_WRITEBACK + file, &pgdat->flags);
 
 	/*
 	 * Legacy memcg will stall in page writeback so avoid forcibly
@@ -1803,7 +1807,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		 * that pages are cycling through the LRU faster than
 		 * they are written so also forcibly stall.
 		 */
-		if (nr_immediate && current_may_throttle())
+		if (nr_immediate && current_may_throttle(file))
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 	}
 
@@ -1813,7 +1817,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	 * unqueued dirty pages or cycling through the LRU too quickly.
 	 */
 	if (!sc->hibernation_mode && !current_is_kswapd() &&
-	    current_may_throttle())
+	    current_may_throttle(file))
 		wait_iff_congested(pgdat, BLK_RW_ASYNC, HZ/10);
 
 	trace_mm_vmscan_lru_shrink_inactive(pgdat->node_id,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
