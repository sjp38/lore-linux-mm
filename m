Date: Wed, 30 Jan 2008 17:57:54 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 05/19] split LRU lists into anon & file sets
In-Reply-To: <20080130121152.1AF1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080108210002.638347207@redhat.com> <20080130121152.1AF1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080130175439.1AFD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Rik, Lee

I found number of scan pages calculation bug.

1. wrong calculation order

	ap *= rotate_sum / (zone->recent_rotated_anon + 1);

   when recent_rotated_anon = 100 and recent_rotated_file = 0,
   
     rotate_sum / (zone->recent_rotated_anon + 1)
   = 100 / 101
   = 0

   at that time, ap become 0.

2. wrong fraction omission

	nr[l] = zone->nr_scan[l] * percent[file] / 100;

	when percent is very small,
	nr[l] become 0.

Test Result:
(1) $ ./hackbench 150 process 1000
(2) # sync; echo 3 > /proc/sys/vm/drop_caches
    $ dd if=tmp10G of=/dev/null
    $ ./hackbench 150 process 1000

rvr-split-lru + revert patch of previous mail
 	(1) 83.014
	(2) 717.009

rvr-split-lru + revert patch of previous mail + below patch
	(1) 61.965
	(2) 85.444 !!


Now, We got 1000% performance improvement against 2.6.24-rc8-mm1 :)



- kosaki


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/vmscan.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c	2008-01-30 15:22:10.000000000 +0900
+++ b/mm/vmscan.c	2008-01-30 16:03:28.000000000 +0900
@@ -1355,7 +1355,7 @@ static void get_scan_ratio(struct zone *
 	 *               anon + file       rotate_sum
 	 */
 	ap = (anon_prio * anon) / (anon + file + 1);
-	ap *= rotate_sum / (zone->recent_rotated_anon + 1);
+	ap = (ap * rotate_sum) / (zone->recent_rotated_anon + 1);
 	if (ap == 0)
 		ap = 1;
 	else if (ap > 100)
@@ -1363,7 +1363,7 @@ static void get_scan_ratio(struct zone *
 	percent[0] = ap;
 
 	fp = (file_prio * file) / (anon + file + 1);
-	fp *= rotate_sum / (zone->recent_rotated_file + 1);
+	fp = (fp * rotate_sum) / (zone->recent_rotated_file + 1);
 	if (fp == 0)
 		fp = 1;
 	else if (fp > 100)
@@ -1402,6 +1402,7 @@ static unsigned long shrink_zone(int pri
 
 	for_each_reclaimable_lru(l) {
 		if (scan_global_lru(sc)) {
+			unsigned long nr_max_scan;
 			int file = is_file_lru(l);
 			/*
 			 * Add one to nr_to_scan just to make sure that the
@@ -1409,7 +1410,11 @@ static unsigned long shrink_zone(int pri
 			 */
 			zone->nr_scan[l] += (zone_page_state(zone,
 				NR_INACTIVE_ANON + l) >> priority) + 1;
-			nr[l] = zone->nr_scan[l] * percent[file] / 100;
+			nr[l] = (zone->nr_scan[l] * percent[file] / 100) + 1;
+			nr_max_scan = zone_page_state(zone, NR_INACTIVE_ANON+l);
+			if (nr[l] > nr_max_scan)
+				nr[l] = nr_max_scan;
+
 			if (nr[l] >= sc->swap_cluster_max)
 				zone->nr_scan[l] = 0;
 			else



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
