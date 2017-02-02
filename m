Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2833F6B0261
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 14:20:28 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u63so218819wmu.0
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 11:20:28 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w18si15589568wra.157.2017.02.02.11.20.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Feb 2017 11:20:26 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 4/7] mm: vmscan: remove old flusher wakeup from direct reclaim path
Date: Thu,  2 Feb 2017 14:19:54 -0500
Message-Id: <20170202191957.22872-5-hannes@cmpxchg.org>
In-Reply-To: <20170202191957.22872-1-hannes@cmpxchg.org>
References: <20170202191957.22872-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Direct reclaim has been replaced by kswapd reclaim in pretty much all
common memory pressure situations, so this code most likely doesn't
accomplish the described effect anymore.  The previous patch wakes up
flushers for all reclaimers when we encounter dirty pages at the tail end
of the LRU.  Remove the crufty old direct reclaim invocation.

Link: http://lkml.kernel.org/r/20170123181641.23938-4-hannes@cmpxchg.org
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Minchan Kim <minchan@kernel.org>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/vmscan.c | 17 -----------------
 1 file changed, 17 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 83c92b866afe..ce2ee8331414 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2757,8 +2757,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 					  struct scan_control *sc)
 {
 	int initial_priority = sc->priority;
-	unsigned long total_scanned = 0;
-	unsigned long writeback_threshold;
 retry:
 	delayacct_freepages_start();
 
@@ -2771,7 +2769,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		sc->nr_scanned = 0;
 		shrink_zones(zonelist, sc);
 
-		total_scanned += sc->nr_scanned;
 		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
 			break;
 
@@ -2784,20 +2781,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		 */
 		if (sc->priority < DEF_PRIORITY - 2)
 			sc->may_writepage = 1;
-
-		/*
-		 * Try to write back as many pages as we just scanned.  This
-		 * tends to cause slow streaming writers to write data to the
-		 * disk smoothly, at the dirtying rate, which is nice.   But
-		 * that's undesirable in laptop mode, where we *want* lumpy
-		 * writeout.  So in laptop mode, write out the whole world.
-		 */
-		writeback_threshold = sc->nr_to_reclaim + sc->nr_to_reclaim / 2;
-		if (total_scanned > writeback_threshold) {
-			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned,
-						WB_REASON_VMSCAN);
-			sc->may_writepage = 1;
-		}
 	} while (--sc->priority >= 0);
 
 	delayacct_freepages_end();
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
