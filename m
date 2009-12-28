Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C7C1160021B
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 02:48:11 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBS7m7ae023045
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 28 Dec 2009 16:48:07 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DD8645DE4C
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 16:48:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 53E8345DD6F
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 16:48:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B1881DB8038
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 16:48:07 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EACFE1DB8037
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 16:48:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/4] vmscan: get_scan_ratio cleanup
In-Reply-To: <20091228164451.A687.A69D9226@jp.fujitsu.com>
References: <20091228164451.A687.A69D9226@jp.fujitsu.com>
Message-Id: <20091228164733.A68A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 28 Dec 2009 16:48:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

The get_scan_ratio() should have all scan-ratio related calculations.
Thus, this patch move some calculation into get_scan_ratio.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2bbee91..640486b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1501,6 +1501,13 @@ static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
 	unsigned long ap, fp;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 
+	/* If we have no swap space, do not bother scanning anon pages. */
+	if (!sc->may_swap || (nr_swap_pages <= 0)) {
+		percent[0] = 0;
+		percent[1] = 100;
+		return;
+	}
+
 	anon  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_ANON) +
 		zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON);
 	file  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +
@@ -1598,22 +1605,20 @@ static void shrink_zone(int priority, struct zone *zone,
 	unsigned long nr_reclaimed = sc->nr_reclaimed;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
-	int noswap = 0;
 
-	/* If we have no swap space, do not bother scanning anon pages. */
-	if (!sc->may_swap || (nr_swap_pages <= 0)) {
-		noswap = 1;
-		percent[0] = 0;
-		percent[1] = 100;
-	} else
-		get_scan_ratio(zone, sc, percent);
+	get_scan_ratio(zone, sc, percent);
 
 	for_each_evictable_lru(l) {
 		int file = is_file_lru(l);
 		unsigned long scan;
 
+		if (percent[file] == 0) {
+			nr[l] = 0;
+			continue;
+		}
+
 		scan = zone_nr_lru_pages(zone, sc, l);
-		if (priority || noswap) {
+		if (priority) {
 			scan >>= priority;
 			scan = (scan * percent[file]) / 100;
 		}
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
