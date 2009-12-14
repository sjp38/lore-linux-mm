Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8AF4A6B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 07:23:53 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBECNocp007279
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 14 Dec 2009 21:23:50 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EB4345DE4F
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:23:50 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CB1F45DE38
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:23:50 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 517371DB803C
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:23:50 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EA1271DB8038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:23:46 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [cleanup][PATCH 1/8] vmscan: Make shrink_zone_begin/end helper function
In-Reply-To: <20091214210823.BBAE.A69D9226@jp.fujitsu.com>
References: <20091211164651.036f5340@annuminas.surriel.com> <20091214210823.BBAE.A69D9226@jp.fujitsu.com>
Message-Id: <20091214212308.BBB1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 14 Dec 2009 21:23:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

concurrent_reclaimers limitation related code made mess to shrink_zone.
To introduce helper function increase readability.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   58 +++++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 35 insertions(+), 23 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index ecfe28c..74c36fe 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1597,25 +1597,11 @@ static unsigned long nr_scan_try_batch(unsigned long nr_to_scan,
 	return nr;
 }
 
-/*
- * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
- */
-static void shrink_zone(int priority, struct zone *zone,
-				struct scan_control *sc)
+static int shrink_zone_begin(struct zone *zone, struct scan_control *sc)
 {
-	unsigned long nr[NR_LRU_LISTS];
-	unsigned long nr_to_scan;
-	unsigned long percent[2];	/* anon @ 0; file @ 1 */
-	enum lru_list l;
-	unsigned long nr_reclaimed = sc->nr_reclaimed;
-	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
-	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
-	int noswap = 0;
-
-	if (!current_is_kswapd() && atomic_read(&zone->concurrent_reclaimers) >
-				max_zone_concurrent_reclaimers &&
-				(sc->gfp_mask & (__GFP_IO|__GFP_FS)) ==
-				(__GFP_IO|__GFP_FS)) {
+	if (!current_is_kswapd() &&
+	    atomic_read(&zone->concurrent_reclaimers) > max_zone_concurrent_reclaimers &&
+	    (sc->gfp_mask & (__GFP_IO|__GFP_FS)) == (__GFP_IO|__GFP_FS)) {
 		/*
 		 * Do not add to the lock contention if this zone has
 		 * enough processes doing page reclaim already, since
@@ -1630,12 +1616,40 @@ static void shrink_zone(int priority, struct zone *zone,
 		if (zone_watermark_ok(zone, sc->order, low_wmark_pages(zone),
 					0, 0)) {
 			wake_up(&zone->reclaim_wait);
-			sc->nr_reclaimed += nr_to_reclaim;
-			return;
+			sc->nr_reclaimed += sc->nr_to_reclaim;
+			return -ERESTARTSYS;
 		}
 	}
 
 	atomic_inc(&zone->concurrent_reclaimers);
+	return 0;
+}
+
+static void shrink_zone_end(struct zone *zone, struct scan_control *sc)
+{
+	atomic_dec(&zone->concurrent_reclaimers);
+	wake_up(&zone->reclaim_wait);
+}
+
+/*
+ * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
+ */
+static void shrink_zone(int priority, struct zone *zone,
+			struct scan_control *sc)
+{
+	unsigned long nr[NR_LRU_LISTS];
+	unsigned long nr_to_scan;
+	unsigned long percent[2];	/* anon @ 0; file @ 1 */
+	enum lru_list l;
+	unsigned long nr_reclaimed = sc->nr_reclaimed;
+	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
+	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
+	int noswap = 0;
+	int ret;
+
+	ret = shrink_zone_begin(zone, sc);
+	if (ret)
+		return;
 
 	/* If we have no swap space, do not bother scanning anon pages. */
 	if (!sc->may_swap || (nr_swap_pages <= 0)) {
@@ -1692,9 +1706,7 @@ static void shrink_zone(int priority, struct zone *zone,
 		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
 
 	throttle_vm_writeout(sc->gfp_mask);
-
-	atomic_dec(&zone->concurrent_reclaimers);
-	wake_up(&zone->reclaim_wait);
+	shrink_zone_end(zone, sc);
 }
 
 /*
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
