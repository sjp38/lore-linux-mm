Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id B09786B0036
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 11:22:19 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so8399430pde.17
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 08:22:19 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id hk10si23527225pac.55.2014.06.30.08.22.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 08:22:18 -0700 (PDT)
Received: by mail-pd0-f174.google.com with SMTP id y10so8386716pdj.19
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 08:22:18 -0700 (PDT)
From: Chen Yucong <slaoub@gmail.com>
Subject: [PATCH] mm: vmscan: proportional scanning cleanup
Date: Mon, 30 Jun 2014 23:22:07 +0800
Message-Id: <1404141727-31601-1-git-send-email-slaoub@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Yucong <slaoub@gmail.com>

This patch aims for clean up, not changing behavior. It records the file_targets
and anon_target in advance, removing the need for the targets[] array and adjusts
the inactive/active lists by the scanning targets.

This patch also adds some comments, making it more readable and clarify. To be
clear: most of those comments stem from https://lkml.org/lkml/2014/6/17/17 and
https://lkml.org/lkml/2014/6/19/723.

Check the file/anon rate of scanning by invoking trace-vmscan-postprocess.pl during
the execution of mmtests(config-global-dhp__pagereclaim-performance).

FTrace Reclaim Statistics: vmscan

The first round of the test:
					without-patch  with-patch
Direct reclaims:     			4502		4629
Direct reclaim pages scanned:		584978		586063
Direct reclaim file pages scanned:	556080		565488
Direct reclaim anon pages scanned:	28898		20575
Direct reclaim file/anon ratio:		19.242		27.484
Direct reclaim pages reclaimed:		226069		234171
Direct reclaim write file sync I/O:	0		0
Direct reclaim write anon sync I/O:	0		0
Direct reclaim write file async I/O:	0		0
Direct reclaim write anon async I/O:	12		9
Wake kswapd requests:			17676		18974
Time stalled direct reclaim(seconds): 	3.40		3.77

Kswapd wakeups:				3369		3566
Kswapd pages scanned:			21777692	21657203
Kswapd file pages scanned:		21312208	21189120
Kswapd anon pages scanned:		465484		468083
Kswapd file/anon ratio:			45.785		45.267
Kswapd pages reclaimed:			15289358	15239544
Kswapd reclaim write file sync I/O:	0		0
Kswapd reclaim write anon sync I/O:	0		0
Kswapd reclaim write file async I/O:	0		0
Kswapd reclaim write anon async I/O:	1064		1077
Time kswapd awake(seconds):		1410.73		1460.54

The second round of the test:
					without-patch  with-patch
Direct reclaims:     			5455		4034
Direct reclaim pages scanned:		686646		557039
Direct reclaim file pages scanned:	633144		527209
Direct reclaim anon pages scanned:	53502		29830
Direct reclaim file/anon ratio:		11.834		17.673
Direct reclaim pages reclaimed:		272571		202050
Direct reclaim write file sync I/O:	0		0
Direct reclaim write anon sync I/O:	0		0
Direct reclaim write file async I/O:	0		0
Direct reclaim write anon async I/O:	7		5
Wake kswapd requests:			19404		18786
Time stalled direct reclaim(seconds): 	3.89		4.52

Kswapd wakeups:				3109		3583
Kswapd pages scanned:			22006470	21619496
Kswapd file pages scanned:		21568763	21165916
Kswapd anon pages scanned:		437707		453580
Kswapd file/anon ratio:			49.276		46.664
Kswapd pages reclaimed:			15363377	15237407
Kswapd reclaim write file sync I/O:	0		0
Kswapd reclaim write anon sync I/O:	0		0
Kswapd reclaim write file async I/O:	0		0
Kswapd reclaim write anon async I/O:	1104		1101
Time kswapd awake(seconds):		1318.28		1486.85

Signed-off-by: Chen Yucong <slaoub@gmail.com>
---
 mm/vmscan.c |   84 ++++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 57 insertions(+), 27 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a8ffe4e..ad46a7b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2057,8 +2057,7 @@ out:
 static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 {
 	unsigned long nr[NR_LRU_LISTS];
-	unsigned long targets[NR_LRU_LISTS];
-	unsigned long nr_to_scan;
+	unsigned long file_target, anon_target;
 	enum lru_list lru;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
@@ -2067,8 +2066,12 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 
 	get_scan_count(lruvec, sc, nr);
 
-	/* Record the original scan target for proportional adjustments later */
-	memcpy(targets, nr, sizeof(nr));
+	/*
+	 * Record the original scan target of file and anon for proportional
+	 * adjustments later
+	 */
+	file_target = nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE];
+	anon_target = nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON];
 
 	/*
 	 * Global reclaiming within direct reclaim at DEF_PRIORITY is a normal
@@ -2084,11 +2087,18 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 	scan_adjusted = (global_reclaim(sc) && !current_is_kswapd() &&
 			 sc->priority == DEF_PRIORITY);
 
+	/*
+	 * we scanned the LRUs in batches of SWAP_CLUSTER_MAX until the
+	 * requested number of pages were reclaimed. Assuming the scan
+	 * counts do not reach zero prematurely, the ratio between nr_file
+	 * and nr_anon should remain constant.
+	 */
 	blk_start_plug(&plug);
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
-		unsigned long nr_anon, nr_file, percentage;
-		unsigned long nr_scanned;
+		unsigned long nr_to_scan, nr_scanned;
+		unsigned long nr_anon, nr_file;
+		unsigned percentage;
 
 		for_each_evictable_lru(lru) {
 			if (nr[lru]) {
@@ -2104,11 +2114,14 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 			continue;
 
 		/*
-		 * For kswapd and memcg, reclaim at least the number of pages
-		 * requested. Ensure that the anon and file LRUs are scanned
-		 * proportionally what was requested by get_scan_count(). We
-		 * stop reclaiming one LRU and reduce the amount scanning
-		 * proportional to the original scan target.
+		 * In the normal case, file/anon LRUs are scanned at a rate
+		 * proportional to the value of vm.swappiness. get_scan_count()
+		 * calculates the number of pages to scan from each LRU taking
+		 * into account additional factors such as the availability of
+		 * swap. When the requested number of pages have been reclaimed
+		 * we adjust to scan targets to minimize the number of pages
+		 * scanned while maintaining the ratio of file/anon pages that
+		 * are scanned.
 		 */
 		nr_file = nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE];
 		nr_anon = nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON];
@@ -2122,35 +2135,52 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 		if (!nr_file || !nr_anon)
 			break;
 
+		/*
+		 * Scan the bigger of the LRU more while stop scanning the
+		 * smaller of the LRU to keep aging balance between LRUs
+		 */
 		if (nr_file > nr_anon) {
-			unsigned long scan_target = targets[LRU_INACTIVE_ANON] +
-						targets[LRU_ACTIVE_ANON] + 1;
+			/*
+			 * In order to maintain the original proportion, we
+			 * need to calculate the percentage of anonymous LRUs
+			 * that has already been scanned. In other words, we
+			 * still need to scan file LRUs until they achieve the
+			 * same *percentage*.
+			 */
+			percentage = nr_anon * 100 / anon_target;
+			nr_scanned = file_target - nr_file;
+			nr_to_scan = file_target * (100 - percentage) / 100;
 			lru = LRU_BASE;
-			percentage = nr_anon * 100 / scan_target;
+
+			/*
+			 * Here, Recalculating the percentage is just used to
+			 * divide nr_so_scan pages appropriately between active
+			 * and inactive lists.
+			 */
+			percentage = nr[LRU_FILE] * 100 / nr_file;
 		} else {
-			unsigned long scan_target = targets[LRU_INACTIVE_FILE] +
-						targets[LRU_ACTIVE_FILE] + 1;
+			percentage = nr_file * 100 / file_target;
+			nr_scanned = anon_target - nr_anon;
+			nr_to_scan = anon_target * (100 - percentage) / 100;
 			lru = LRU_FILE;
-			percentage = nr_file * 100 / scan_target;
+			percentage = nr[LRU_BASE] * 100 / nr_anon;
 		}
+
+		if (nr_to_scan <= nr_scanned)
+			break;
+		nr_to_scan -= nr_scanned;
 
 		/* Stop scanning the smaller of the LRU */
 		nr[lru] = 0;
 		nr[lru + LRU_ACTIVE] = 0;
 
 		/*
-		 * Recalculate the other LRU scan count based on its original
-		 * scan target and the percentage scanning already complete
+		 * Distribute nr_so_scan pages proportionally between active and
+		 * inactive LRU lists.
 		 */
 		lru = (lru == LRU_FILE) ? LRU_BASE : LRU_FILE;
-		nr_scanned = targets[lru] - nr[lru];
-		nr[lru] = targets[lru] * (100 - percentage) / 100;
-		nr[lru] -= min(nr[lru], nr_scanned);
-
-		lru += LRU_ACTIVE;
-		nr_scanned = targets[lru] - nr[lru];
-		nr[lru] = targets[lru] * (100 - percentage) / 100;
-		nr[lru] -= min(nr[lru], nr_scanned);
+		nr[lru] = nr_to_scan * percentage / 100;
+		nr[lru + LRU_ACTIVE] = nr_to_scan - nr[lru];
 
 		scan_adjusted = true;
 	}
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
