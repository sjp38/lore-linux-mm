Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id E5C1E6B0070
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 01:21:20 -0500 (EST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/2] mm: forcely swapout when we are out of page cache
Date: Wed,  9 Jan 2013 15:21:14 +0900
Message-Id: <1357712474-27595-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1357712474-27595-1-git-send-email-minchan@kernel.org>
References: <1357712474-27595-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Sonny Rao <sonnyrao@google.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>

If laptop_mode is enable, VM try to avoid I/O for saving the power.
But if there isn't reclaimable memory without I/O, we should do I/O
for preventing unnecessary OOM kill although we sacrifices power.

One of example is that we are out of page cache. Remained one is
only anonymous pages, for swapping out, we needs may_writepage = 1.

Reported-by: Luigi Semenzato <semenzato@google.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 439cc47..624c816 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1728,6 +1728,12 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 		free = zone_page_state(zone, NR_FREE_PAGES);
 		if (unlikely(file + free <= high_wmark_pages(zone))) {
 			scan_balance = SCAN_ANON;
+			/*
+			 * From now on, we have to swap out
+			 * for peventing OOM kill although
+			 * we sacrifice power consumption.
+			 */
+			sc->may_writepage = 1;
 			goto out;
 		}
 	}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
