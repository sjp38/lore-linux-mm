Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 111816B025E
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 14:20:24 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u63so218522wmu.0
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 11:20:24 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u70si3267948wmf.106.2017.02.02.11.20.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Feb 2017 11:20:22 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/7] mm: vmscan: kick flushers when we encounter dirty pages on the LRU
Date: Thu,  2 Feb 2017 14:19:52 -0500
Message-Id: <20170202191957.22872-3-hannes@cmpxchg.org>
In-Reply-To: <20170202191957.22872-1-hannes@cmpxchg.org>
References: <20170202191957.22872-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Memory pressure can put dirty pages at the end of the LRU without anybody
running into dirty limits.  Don't start writing individual pages from
kswapd while the flushers might be asleep.

Unlike the old direct reclaim flusher wakeup (removed in the next
patch) that flushes the number of pages just scanned, this patch wakes
the flushers for all outstanding dirty pages. That seemed to perform
better in a synthetic test that pushes dirty pages to the end of the
LRU and into reclaim, because we know LRU aging outstrips writeback
already, and this way we give younger dirty pages a headstart rather
than wait until reclaim runs into them as well. It also means less
plugging and risk of exhausting the struct request pool from reclaim.

There is a concern that this will cause temporary files that used to
get dirtied and truncated before writeback to now get written to disk
under memory pressure. If this turns out to be a real problem, we'll
have to revisit this and tame the reclaim flusher wakeups.

Link: http://lkml.kernel.org/r/20170123181641.23938-3-hannes@cmpxchg.org
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Minchan Kim <minchan@kernel.org>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/writeback.h        |  2 +-
 include/trace/events/writeback.h |  2 +-
 mm/vmscan.c                      | 18 +++++++++++++-----
 3 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 5527d910ba3d..a3c0cbd7c888 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -46,7 +46,7 @@ enum writeback_sync_modes {
  */
 enum wb_reason {
 	WB_REASON_BACKGROUND,
-	WB_REASON_TRY_TO_FREE_PAGES,
+	WB_REASON_VMSCAN,
 	WB_REASON_SYNC,
 	WB_REASON_PERIODIC,
 	WB_REASON_LAPTOP_TIMER,
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 2ccd9ccbf9ef..7bd8783a590f 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -31,7 +31,7 @@
 
 #define WB_WORK_REASON							\
 	EM( WB_REASON_BACKGROUND,		"background")		\
-	EM( WB_REASON_TRY_TO_FREE_PAGES,	"try_to_free_pages")	\
+	EM( WB_REASON_VMSCAN,			"vmscan")		\
 	EM( WB_REASON_SYNC,			"sync")			\
 	EM( WB_REASON_PERIODIC,			"periodic")		\
 	EM( WB_REASON_LAPTOP_TIMER,		"laptop_timer")		\
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0d05f7f3b532..56ea8d24041f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1798,12 +1798,20 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 		/*
 		 * If dirty pages are scanned that are not queued for IO, it
-		 * implies that flushers are not keeping up. In this case, flag
-		 * the pgdat PGDAT_DIRTY and kswapd will start writing pages from
-		 * reclaim context.
+		 * implies that flushers are not doing their job. This can
+		 * happen when memory pressure pushes dirty pages to the end
+		 * of the LRU without the dirty limits being breached. It can
+		 * also happen when the proportion of dirty pages grows not
+		 * through writes but through memory pressure reclaiming all
+		 * the clean cache. And in some cases, the flushers simply
+		 * cannot keep up with the allocation rate. Nudge the flusher
+		 * threads in case they are asleep, but also allow kswapd to
+		 * start writing pages during reclaim.
 		 */
-		if (stat.nr_unqueued_dirty == nr_taken)
+		if (stat.nr_unqueued_dirty == nr_taken) {
+			wakeup_flusher_threads(0, WB_REASON_VMSCAN);
 			set_bit(PGDAT_DIRTY, &pgdat->flags);
+		}
 
 		/*
 		 * If kswapd scans pages marked marked for immediate
@@ -2787,7 +2795,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		writeback_threshold = sc->nr_to_reclaim + sc->nr_to_reclaim / 2;
 		if (total_scanned > writeback_threshold) {
 			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned,
-						WB_REASON_TRY_TO_FREE_PAGES);
+						WB_REASON_VMSCAN);
 			sc->may_writepage = 1;
 		}
 	} while (--sc->priority >= 0);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
