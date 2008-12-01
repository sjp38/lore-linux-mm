Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB1CDiTc026517
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 1 Dec 2008 21:13:44 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 483D245DE5D
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 21:13:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0808445DE61
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 21:13:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BE9761DB804A
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 21:13:43 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 60FC41DB8046
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 21:13:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 03/11] make zone_nr_pages() helper function
In-Reply-To: <20081201205810.1CCA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081201205810.1CCA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081201211256.1CD3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  1 Dec 2008 21:13:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

make zone_nr_pages() helper function.

it is used by latter patch.
this patch doesn't have any functional change.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -137,6 +137,13 @@ static struct zone_reclaim_stat *get_rec
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
@@ -1424,10 +1431,10 @@ static void get_scan_ratio(struct zone *
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
