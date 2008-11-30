Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail2.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAUAxuLh031958
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 30 Nov 2008 19:59:56 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 95F2C45DE52
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 19:59:56 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 69F7B45DE50
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 19:59:56 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 520031DB803C
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 19:59:56 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 044CE1DB8037
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 19:59:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 05/09] make zone_nr_pages() helper function
In-Reply-To: <20081130193502.8145.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081130193502.8145.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081130195919.8154.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun, 30 Nov 2008 19:59:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

make zone_nr_pages() function.
it is used by latter patch.

this patch doesn't have any functional change.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -140,6 +140,13 @@ static struct zone_reclaim_stat *get_rec
 	return &zone->reclaim_stat;
 }
 
+static unsigned long zone_nr_pages(struct zone *zone, struct scan_control *sc,
+				   enum lru_list lru)
+{
+	return zone_page_state(zone, NR_LRU_BASE + lru);
+}
+
+
 /*
  * Add a shrinker callback to be called from the vm
  */
@@ -1435,10 +1442,10 @@ static void get_scan_ratio(struct zone *
 		return;
 	}
 
-	anon  = zone_page_state(zone, NR_ACTIVE_ANON) +
-		zone_page_state(zone, NR_INACTIVE_ANON);
-	file  = zone_page_state(zone, NR_ACTIVE_FILE) +
-		zone_page_state(zone, NR_INACTIVE_FILE);
+	anon  = zone_nr_pages(zone, sc, LRU_ACTIVE_ANON) +
+		zone_nr_pages(zone, sc, LRU_INACTIVE_ANON);
+	file  = zone_nr_pages(zone, sc, LRU_ACTIVE_FILE) +
+		zone_nr_pages(zone, sc, LRU_INACTIVE_FILE);
 	free  = zone_page_state(zone, NR_FREE_PAGES);
 
 	/* If we have very few page cache pages, force-scan anon pages. */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
