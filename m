Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1335C6B0038
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 02:37:32 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ma3so2215015pbc.27
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 23:37:31 -0700 (PDT)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id zm8si3013387pac.317.2014.03.13.23.37.30
        for <linux-mm@kvack.org>;
        Thu, 13 Mar 2014 23:37:31 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 5/6] mm: reclaim lazyfree pages in swapless system
Date: Fri, 14 Mar 2014 15:37:49 +0900
Message-Id: <1394779070-8545-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1394779070-8545-1-git-send-email-minchan@kernel.org>
References: <1394779070-8545-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.org>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

If there are lazyfree pages in system, shrink inactive anonymous
LRU to discard lazyfree pages regardless of existing avaialable
swap.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 98a1c3ffcaab..ad73e053c581 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1889,8 +1889,13 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	if (!global_reclaim(sc))
 		force_scan = true;
 
-	/* If we have no swap space, do not bother scanning anon pages. */
-	if (!sc->may_swap || (get_nr_swap_pages() <= 0)) {
+	/*
+	 * If we have no swap space and lazyfree pages,
+	 * do not bother scanning anon pages.
+	 */
+	if (!sc->may_swap ||
+		(get_nr_swap_pages() <= 0 &&
+			zone_page_state(zone, NR_LAZYFREE_PAGES) <= 0)) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
