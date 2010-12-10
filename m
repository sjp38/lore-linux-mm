Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DCD3E6B0093
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:46:30 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 5/6] mm: kswapd: Treat zone->all_unreclaimable in sleeping_prematurely similar to balance_pgdat()
Date: Fri, 10 Dec 2010 15:46:24 +0000
Message-Id: <1291995985-5913-6-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1291995985-5913-1-git-send-email-mel@csn.ul.ie>
References: <1291995985-5913-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

After DEF_PRIORITY, balance_pgdat() considers all_unreclaimable zones to
be balanced but sleeping_prematurely does not. This can force kswapd to
stay awake longer than it should. This patch fixes it.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e1be4e8..5995121 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2237,8 +2237,16 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
 		if (!populated_zone(zone))
 			continue;
 
-		if (zone->all_unreclaimable)
+		/*
+		 * balance_pgdat() skips over all_unreclaimable after
+		 * DEF_PRIORITY. Effectively, it considers them balanced so
+		 * they must be considered balanced here as well if kswapd
+		 * is to sleep
+		 */
+		if (zone->all_unreclaimable) {
+			balanced += zone->present_pages;
 			continue;
+		}
 
 		if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone),
 								0, 0))
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
