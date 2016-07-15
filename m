Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id EB5FC6B0262
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 09:09:32 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id f199so7773874lfg.2
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 06:09:32 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id 5si669626wjs.273.2016.07.15.06.09.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Jul 2016 06:09:27 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id DD0C799305
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 13:09:26 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 3/5] mm, pagevec: Release/reacquire lru_lock on pgdat change
Date: Fri, 15 Jul 2016 14:09:23 +0100
Message-Id: <1468588165-12461-4-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1468588165-12461-1-git-send-email-mgorman@techsingularity.net>
References: <1468588165-12461-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

With node-lru, the locking is based on the pgdat. Previously it was
required that a pagevec drain released one zone lru_lock and acquired
another zone lru_lock on every zone change. Now, it's only necessary if
the node changes. The end-result is fewer lock release/acquires if the
pages are all on the same node but in different zones.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/swap.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 77af473635fe..75c63bb2a1da 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -179,26 +179,26 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
 	void *arg)
 {
 	int i;
-	struct zone *zone = NULL;
+	struct pglist_data *pgdat = NULL;
 	struct lruvec *lruvec;
 	unsigned long flags = 0;
 
 	for (i = 0; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
-		struct zone *pagezone = page_zone(page);
+		struct pglist_data *pagepgdat = page_pgdat(page);
 
-		if (pagezone != zone) {
-			if (zone)
-				spin_unlock_irqrestore(zone_lru_lock(zone), flags);
-			zone = pagezone;
-			spin_lock_irqsave(zone_lru_lock(zone), flags);
+		if (pagepgdat != pgdat) {
+			if (pgdat)
+				spin_unlock_irqrestore(&pgdat->lru_lock, flags);
+			pgdat = pagepgdat;
+			spin_lock_irqsave(&pgdat->lru_lock, flags);
 		}
 
-		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
+		lruvec = mem_cgroup_page_lruvec(page, pgdat);
 		(*move_fn)(page, lruvec, arg);
 	}
-	if (zone)
-		spin_unlock_irqrestore(zone_lru_lock(zone), flags);
+	if (pgdat)
+		spin_unlock_irqrestore(&pgdat->lru_lock, flags);
 	release_pages(pvec->pages, pvec->nr, pvec->cold);
 	pagevec_reinit(pvec);
 }
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
