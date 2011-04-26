Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 294E99000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 05:24:07 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 909C23EE0C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 18:24:03 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7900045DEA3
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 18:24:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 55EEE45DE87
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 18:24:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 49F941DB803C
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 18:24:03 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 04B7E1DB802C
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 18:24:03 +0900 (JST)
Date: Tue, 26 Apr 2011 18:17:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] fix get_scan_count for working well with small targets
Message-Id: <20110426181724.f8cdad57.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, Ying Han <yinghan@google.com>

At memory reclaim, we determine the number of pages to be scanned
per zone as
	(anon + file) >> priority.
Assume 
	scan = (anon + file) >> priority.

If scan < SWAP_CLUSTER_MAX, shlink_list will be skipped for this
priority and results no-sacn.  This has some problems.

  1. This increases priority as 1 without any scan.
     To do scan in DEF_PRIORITY always, amount of pages should be larger than
     512M. If pages>>priority < SWAP_CLUSTER_MAX, it's recorded and scan will be
     batched, later. (But we lose 1 priority.)
     But if the amount of pages is smaller than 16M, no scan at priority==0
     forever.

  2. If zone->all_unreclaimabe==true, it's scanned only when priority==0.
     So, x86's ZONE_DMA will never be recoverred until the user of pages
     frees memory by itself.

  3. With memcg, the limit of memory can be small. When using small memcg,
     it gets priority < DEF_PRIORITY-2 very easily and need to call
     wait_iff_congested().
     For doing scan before priorty=9, 64MB of memory should be used.

This patch tries to scan SWAP_CLUSTER_MAX of pages in force...when

  1. the target is enough small.
  2. it's kswapd or memcg reclaim.

Then we can avoid rapid priority drop and may be able to recover
all_unreclaimable in a small zones.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/vmscan.c |   31 ++++++++++++++++++++++++++-----
 1 file changed, 26 insertions(+), 5 deletions(-)

Index: memcg/mm/vmscan.c
===================================================================
--- memcg.orig/mm/vmscan.c
+++ memcg/mm/vmscan.c
@@ -1737,6 +1737,16 @@ static void get_scan_count(struct zone *
 	u64 fraction[2], denominator;
 	enum lru_list l;
 	int noswap = 0;
+	int may_noscan = 0;
+
+
+	anon  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_ANON) +
+		zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON);
+	file  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +
+		zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
+
+	if (((anon + file) >> priority) < SWAP_CLUSTER_MAX)
+		may_noscan = 1;
 
 	/* If we have no swap space, do not bother scanning anon pages. */
 	if (!sc->may_swap || (nr_swap_pages <= 0)) {
@@ -1747,11 +1757,6 @@ static void get_scan_count(struct zone *
 		goto out;
 	}
 
-	anon  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_ANON) +
-		zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON);
-	file  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +
-		zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
-
 	if (scanning_global_lru(sc)) {
 		free  = zone_page_state(zone, NR_FREE_PAGES);
 		/* If we have very few page cache pages,
@@ -1814,10 +1819,26 @@ out:
 		unsigned long scan;
 
 		scan = zone_nr_lru_pages(zone, sc, l);
+
 		if (priority || noswap) {
 			scan >>= priority;
 			scan = div64_u64(scan * fraction[file], denominator);
 		}
+
+		if (!scan &&
+		    may_noscan &&
+		    (current_is_kswapd() || !scanning_global_lru(sc))) {
+			/*
+ 			 * if we do target scan, the whole amount of memory
+ 			 * can be too small to scan with low priority value.
+ 			 * This raise up priority rapidly without any scan.
+ 			 * Avoid that and give some scan.
+ 			 */
+			if (file)
+				scan = SWAP_CLUSTER_MAX;
+			else if (!noswap && (fraction[anon] > fraction[file]*16))
+				scan = SWAP_CLUSTER_MAX;
+		}
 		nr[l] = nr_scan_try_batch(scan,
 					  &reclaim_stat->nr_saved_scan[l]);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
