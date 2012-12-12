Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 007AD6B0074
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 16:44:43 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 5/8] mm: vmscan: improve comment on low-page cache handling
Date: Wed, 12 Dec 2012 16:43:37 -0500
Message-Id: <1355348620-9382-6-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Fix comment style and elaborate on why anonymous memory is
force-scanned when file cache runs low.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5e1beed..05475e1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1697,13 +1697,15 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	file  = get_lru_size(lruvec, LRU_ACTIVE_FILE) +
 		get_lru_size(lruvec, LRU_INACTIVE_FILE);
 
+	/*
+	 * If it's foreseeable that reclaiming the file cache won't be
+	 * enough to get the zone back into a desirable shape, we have
+	 * to swap.  Better start now and leave the - probably heavily
+	 * thrashing - remaining file pages alone.
+	 */
 	if (global_reclaim(sc)) {
-		free  = zone_page_state(zone, NR_FREE_PAGES);
+		free = zone_page_state(zone, NR_FREE_PAGES);
 		if (unlikely(file + free <= high_wmark_pages(zone))) {
-			/*
-			 * If we have very few page cache pages, force-scan
-			 * anon pages.
-			 */
 			fraction[0] = 1;
 			fraction[1] = 0;
 			denominator = 1;
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
