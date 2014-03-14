Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f51.google.com (mail-bk0-f51.google.com [209.85.214.51])
	by kanga.kvack.org (Postfix) with ESMTP id 03E796B0038
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 11:35:11 -0400 (EDT)
Received: by mail-bk0-f51.google.com with SMTP id 6so205195bkj.38
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 08:35:11 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ov5si2686232bkb.171.2014.03.14.08.35.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Mar 2014 08:35:10 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: vmscan: do not swap anon pages just because free+file is low
Date: Fri, 14 Mar 2014 11:35:02 -0400
Message-Id: <1394811302-30468-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Page reclaim force-scans / swaps anonymous pages when file cache drops
below the high watermark of a zone in order to prevent what little
cache remains from thrashing.

However, on bigger machines the high watermark value can be quite
large and when the workload is dominated by a static anonymous/shmem
set, the file set might just be a small window of used-once cache.  In
such situations, the VM starts swapping heavily when instead it should
be recycling the no longer used cache.

This is a longer-standing problem, but it's more likely to trigger
after 81c0a2bb515f ("mm: page_alloc: fair zone allocator policy")
because file pages can no longer accumulate in a single zone and are
dispersed into smaller fractions among the available zones.

To resolve this, do not force scan anon when file pages are low but
instead rely on the scan/rotation ratios to make the right prediction.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: <stable@kernel.org> [3.12+]
---
 mm/vmscan.c | 16 +---------------
 1 file changed, 1 insertion(+), 15 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a9c74b409681..e58e9ad5b5d1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1848,7 +1848,7 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	struct zone *zone = lruvec_zone(lruvec);
 	unsigned long anon_prio, file_prio;
 	enum scan_balance scan_balance;
-	unsigned long anon, file, free;
+	unsigned long anon, file;
 	bool force_scan = false;
 	unsigned long ap, fp;
 	enum lru_list lru;
@@ -1902,20 +1902,6 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 		get_lru_size(lruvec, LRU_INACTIVE_FILE);
 
 	/*
-	 * If it's foreseeable that reclaiming the file cache won't be
-	 * enough to get the zone back into a desirable shape, we have
-	 * to swap.  Better start now and leave the - probably heavily
-	 * thrashing - remaining file pages alone.
-	 */
-	if (global_reclaim(sc)) {
-		free = zone_page_state(zone, NR_FREE_PAGES);
-		if (unlikely(file + free <= high_wmark_pages(zone))) {
-			scan_balance = SCAN_ANON;
-			goto out;
-		}
-	}
-
-	/*
 	 * There is enough inactive page cache, do not reclaim
 	 * anything from the anonymous working set right now.
 	 */
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
