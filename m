Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9A16B004A
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 04:29:08 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 728D33EE0C0
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 17:29:05 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5766045DE7E
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 17:29:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3591245DEAD
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 17:29:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 06E381DB803B
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 17:29:05 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B04D21DB8041
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 17:29:04 +0900 (JST)
Date: Fri, 22 Jul 2011 17:21:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] memcg: fix vmscan count in small memcgs
Message-Id: <20110722172155.d6834641.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Michal Hocko <mhocko@suse.cz>

commit 246e87a(memcg: fix get_scan_count() for small targets) fixes
the memcg/kswapd behavior against small targets and prevent vmscan
priority too high.

But implementation is too naive and adds another problem to small memcg.
It always force scan to 32 pages of file/anon and doesn't handle
swappiness and other rotate_info. It makes vmscan to scan anon LRU
regardless of swappiness and make reclaim bad.
This patch fixes it by adjusting scanning count with regard to
swappiness at el.

At a test "cat 1G file under 300M limit." (swappiness=20)
 before patch
        scanned_pages_by_limit 360919
        scanned_anon_pages_by_limit 180469
        scanned_file_pages_by_limit 180450
        rotated_pages_by_limit 31
        rotated_anon_pages_by_limit 25
        rotated_file_pages_by_limit 6
        freed_pages_by_limit 180458
        freed_anon_pages_by_limit 19
        freed_file_pages_by_limit 180439
        elapsed_ns_by_limit 429758872
 after patch
        scanned_pages_by_limit 180674
        scanned_anon_pages_by_limit 24
        scanned_file_pages_by_limit 180650
        rotated_pages_by_limit 35
        rotated_anon_pages_by_limit 24
        rotated_file_pages_by_limit 11
        freed_pages_by_limit 180634
        freed_anon_pages_by_limit 0
        freed_file_pages_by_limit 180634
        elapsed_ns_by_limit 367119089
        scanned_pages_by_system 0

the numbers of scanning anon are decreased(as expected), and elapsed time
reduced. By this patch, small memcgs will work better.
(*) Because the amount of file-cache is much bigger than anon,
    recalaim_stat's rotate-scan counter make scanning files more.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/vmscan.c |   18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

Index: mmotm-0710/mm/vmscan.c
===================================================================
--- mmotm-0710.orig/mm/vmscan.c
+++ mmotm-0710/mm/vmscan.c
@@ -1768,6 +1768,7 @@ static void get_scan_count(struct zone *
 	enum lru_list l;
 	int noswap = 0;
 	int force_scan = 0;
+	unsigned long nr_force_scan[2];
 
 
 	anon  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_ANON) +
@@ -1790,6 +1791,8 @@ static void get_scan_count(struct zone *
 		fraction[0] = 0;
 		fraction[1] = 1;
 		denominator = 1;
+		nr_force_scan[0] = 0;
+		nr_force_scan[1] = SWAP_CLUSTER_MAX;
 		goto out;
 	}
 
@@ -1801,6 +1804,8 @@ static void get_scan_count(struct zone *
 			fraction[0] = 1;
 			fraction[1] = 0;
 			denominator = 1;
+			nr_force_scan[0] = SWAP_CLUSTER_MAX;
+			nr_force_scan[1] = 0;
 			goto out;
 		}
 	}
@@ -1849,6 +1854,11 @@ static void get_scan_count(struct zone *
 	fraction[0] = ap;
 	fraction[1] = fp;
 	denominator = ap + fp + 1;
+	if (force_scan) {
+		unsigned long scan = SWAP_CLUSTER_MAX;
+		nr_force_scan[0] = div64_u64(scan * ap, denominator);
+		nr_force_scan[1] = div64_u64(scan * fp, denominator);
+	}
 out:
 	for_each_evictable_lru(l) {
 		int file = is_file_lru(l);
@@ -1869,12 +1879,8 @@ out:
 		 * memcg, priority drop can cause big latency. So, it's better
 		 * to scan small amount. See may_noscan above.
 		 */
-		if (!scan && force_scan) {
-			if (file)
-				scan = SWAP_CLUSTER_MAX;
-			else if (!noswap)
-				scan = SWAP_CLUSTER_MAX;
-		}
+		if (!scan && force_scan)
+			scan = nr_force_scan[file];
 		nr[l] = scan;
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
