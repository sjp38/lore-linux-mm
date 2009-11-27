Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 89A8E6B0062
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 19:18:45 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAR0Igdj031210
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 27 Nov 2009 09:18:42 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FFE845DE65
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 09:18:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AD6745DE61
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 09:18:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 70C5F1DB8040
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 09:18:41 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C51C38F8009
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 09:18:40 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/4] vmscan: make lru_index() helper function
In-Reply-To: <20091127091357.A7CC.A69D9226@jp.fujitsu.com>
References: <20091127091357.A7CC.A69D9226@jp.fujitsu.com>
Message-Id: <20091127091755.A7CF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 27 Nov 2009 09:18:40 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Current lru calculation (e.g. LRU_ACTIVE + file * LRU_FILE) is a bit
ugly.
To make helper function improve code readability a bit.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   25 ++++++++++++++-----------
 1 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a58ff15..7e0245d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -156,6 +156,16 @@ static unsigned long zone_nr_lru_pages(struct zone *zone,
 	return zone_page_state(zone, NR_LRU_BASE + lru);
 }
 
+static inline enum lru_list lru_index(int active, int file)
+{
+	int lru = LRU_BASE;
+	if (active)
+		lru += LRU_ACTIVE;
+	if (file)
+		lru += LRU_FILE;
+
+	return lru;
+}
 
 /*
  * Add a shrinker callback to be called from the vm
@@ -978,13 +988,8 @@ static unsigned long isolate_pages_global(unsigned long nr,
 					struct mem_cgroup *mem_cont,
 					int active, int file)
 {
-	int lru = LRU_BASE;
-	if (active)
-		lru += LRU_ACTIVE;
-	if (file)
-		lru += LRU_FILE;
-	return isolate_lru_pages(nr, &z->lru[lru].list, dst, scanned, order,
-								mode, file);
+	return isolate_lru_pages(nr, &z->lru[lru_index(active, file)].list,
+				 dst, scanned, order, mode, file);
 }
 
 /*
@@ -1373,10 +1378,8 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 
-	move_active_pages_to_lru(zone, &l_active,
-						LRU_ACTIVE + file * LRU_FILE);
-	move_active_pages_to_lru(zone, &l_inactive,
-						LRU_BASE   + file * LRU_FILE);
+	move_active_pages_to_lru(zone, &l_active, lru_index(1, file));
+	move_active_pages_to_lru(zone, &l_inactive, lru_index(0, file));
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&zone->lru_lock);
 }
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
