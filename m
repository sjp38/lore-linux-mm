Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 014DC6B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 10:06:33 -0400 (EDT)
Date: Fri, 13 Mar 2009 23:06:27 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: [BUGFIX][PATCH] vmscan: pgmoved should be cleared after updating
 recent_rotated
Message-Id: <20090313230627.3fa31cef.d-nishimura@mtf.biglobe.ne.jp>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, d-nishimura@mtf.biglobe.ne.jp
List-ID: <linux-mm.kvack.org>

From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

pgmoved should be cleared after updating recent_rotated.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/vmscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e895171..56ddf41 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1262,7 +1262,6 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	 * Move the pages to the [file or anon] inactive list.
 	 */
 	pagevec_init(&pvec, 1);
-	pgmoved = 0;
 	lru = LRU_BASE + file * LRU_FILE;
 
 	spin_lock_irq(&zone->lru_lock);
@@ -1274,6 +1273,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	 */
 	reclaim_stat->recent_rotated[!!file] += pgmoved;
 
+	pgmoved = 0;
 	while (!list_empty(&l_inactive)) {
 		page = lru_to_page(&l_inactive);
 		prefetchw_prev_lru_page(page, &l_inactive, flags);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
