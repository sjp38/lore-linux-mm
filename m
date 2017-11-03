Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5493C6B0033
	for <linux-mm@kvack.org>; Sat,  4 Nov 2017 08:42:14 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id h6so5451740oia.17
        for <linux-mm@kvack.org>; Sat, 04 Nov 2017 05:42:14 -0700 (PDT)
Received: from mx02.meituan.com (mx-fe5-210.meituan.com. [103.37.138.210])
        by mx.google.com with ESMTPS id o133si4073931oib.362.2017.11.04.05.42.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 Nov 2017 05:42:12 -0700 (PDT)
From: Wang Long <wanglong19@meituan.com>
Subject: [PATCH v2] writeback: remove the unused function parameter
Date: Fri,  3 Nov 2017 01:04:45 -0400
Message-Id: <1509685485-15278-1-git-send-email-wanglong19@meituan.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jack@suse.cz, tj@kernel.org, akpm@linux-foundation.org, gregkh@linuxfoundation.org
Cc: axboe@fb.com, nborisov@suse.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The parameter `struct bdi_writeback *wb` is not been used in the function
body. so we just remove it.

Signed-off-by: Wang Long <wanglong19@meituan.com>
---
 include/linux/backing-dev.h | 2 +-
 mm/page-writeback.c         | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 1662157..186a2e7 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -95,7 +95,7 @@ static inline s64 wb_stat_sum(struct bdi_writeback *wb, enum wb_stat_item item)
 /*
  * maximal error of a stat counter.
  */
-static inline unsigned long wb_stat_error(struct bdi_writeback *wb)
+static inline unsigned long wb_stat_error(void)
 {
 #ifdef CONFIG_SMP
 	return nr_cpu_ids * WB_STAT_BATCH;
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0b9c5cb..9287466 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1543,7 +1543,7 @@ static inline void wb_dirty_limits(struct dirty_throttle_control *dtc)
 	 * actually dirty; with m+n sitting in the percpu
 	 * deltas.
 	 */
-	if (dtc->wb_thresh < 2 * wb_stat_error(wb)) {
+	if (dtc->wb_thresh < 2 * wb_stat_error()) {
 		wb_reclaimable = wb_stat_sum(wb, WB_RECLAIMABLE);
 		dtc->wb_dirty = wb_reclaimable + wb_stat_sum(wb, WB_WRITEBACK);
 	} else {
@@ -1802,7 +1802,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 * more page. However wb_dirty has accounting errors.  So use
 		 * the larger and more IO friendly wb_stat_error.
 		 */
-		if (sdtc->wb_dirty <= wb_stat_error(wb))
+		if (sdtc->wb_dirty <= wb_stat_error())
 			break;
 
 		if (fatal_signal_pending(current))
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
