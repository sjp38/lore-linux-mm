Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 208036B025E
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 13:17:07 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id jz4so28133718wjb.5
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 10:17:07 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e56si19678610wre.332.2017.01.23.10.17.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 10:17:06 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 3/5] mm: vmscan: remove old flusher wakeup from direct reclaim path
Date: Mon, 23 Jan 2017 13:16:39 -0500
Message-Id: <20170123181641.23938-4-hannes@cmpxchg.org>
In-Reply-To: <20170123181641.23938-1-hannes@cmpxchg.org>
References: <20170123181641.23938-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Direct reclaim has been replaced by kswapd reclaim in pretty much all
common memory pressure situations, so this code most likely doesn't
accomplish the described effect anymore. The previous patch wakes up
flushers for all reclaimers when we encounter dirty pages at the tail
end of the LRU. Remove the crufty old direct reclaim invocation.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 17 -----------------
 1 file changed, 17 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 56ea8d24041f..915fc658de41 100644
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
