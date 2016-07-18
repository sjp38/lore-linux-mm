Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 76AFE6B025F
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 10:50:30 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id r97so10708036lfi.2
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 07:50:30 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id n24si9041101wmi.20.2016.07.18.07.50.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Jul 2016 07:50:27 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 46D2598EF8
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 14:50:27 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 2/3] mm, vmscan: Release/reacquire lru_lock on pgdat change
Date: Mon, 18 Jul 2016 15:50:25 +0100
Message-Id: <1468853426-12858-3-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1468853426-12858-1-git-send-email-mgorman@techsingularity.net>
References: <1468853426-12858-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

With node-lru, the locking is based on the pgdat. As Minchan pointed
out, there is an opportunity to reduce LRU lock release/acquire in
check_move_unevictable_pages by only changing lock on a pgdat change.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 45344acf52ba..a6f31617a08c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3775,24 +3775,24 @@ int page_evictable(struct page *page)
 void check_move_unevictable_pages(struct page **pages, int nr_pages)
 {
 	struct lruvec *lruvec;
-	struct zone *zone = NULL;
+	struct pglist_data *pgdat = NULL;
 	int pgscanned = 0;
 	int pgrescued = 0;
 	int i;
 
 	for (i = 0; i < nr_pages; i++) {
 		struct page *page = pages[i];
-		struct zone *pagezone;
+		struct pglist_data *pagepgdat = page_pgdat(page);
 
 		pgscanned++;
-		pagezone = page_zone(page);
-		if (pagezone != zone) {
-			if (zone)
-				spin_unlock_irq(zone_lru_lock(zone));
-			zone = pagezone;
-			spin_lock_irq(zone_lru_lock(zone));
+		pagepgdat = page_pgdat(page);
+		if (pagepgdat != pgdat) {
+			if (pgdat)
+				spin_unlock_irq(&pgdat->lru_lock);
+			pgdat = pagepgdat;
+			spin_lock_irq(&pgdat->lru_lock);
 		}
-		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
+		lruvec = mem_cgroup_page_lruvec(page, pgdat);
 
 		if (!PageLRU(page) || !PageUnevictable(page))
 			continue;
@@ -3808,10 +3808,10 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 		}
 	}
 
-	if (zone) {
+	if (pgdat) {
 		__count_vm_events(UNEVICTABLE_PGRESCUED, pgrescued);
 		__count_vm_events(UNEVICTABLE_PGSCANNED, pgscanned);
-		spin_unlock_irq(zone_lru_lock(zone));
+		spin_unlock_irq(&pgdat->lru_lock);
 	}
 }
 #endif /* CONFIG_SHMEM */
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
