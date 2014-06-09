Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1E50A6B0087
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 09:29:02 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id ma3so4900166pbc.37
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 06:29:01 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id nd4si30833995pbc.20.2014.06.09.06.29.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Jun 2014 06:29:01 -0700 (PDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so741952pad.21
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 06:29:00 -0700 (PDT)
From: Chen Yucong <slaoub@gmail.com>
Subject: [PATCH] mm/vmscan.c: avoid recording the original scan targets in shrink_lruvec()
Date: Mon,  9 Jun 2014 21:27:16 +0800
Message-Id: <1402320436-22270-1-git-send-email-slaoub@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: mhocko@suse.cz, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Yucong <slaoub@gmail.com>

Via https://lkml.org/lkml/2013/4/10/334 , we can find that recording the
original scan targets introduces extra 40 bytes on the stack. This patch
is able to avoid this situation and the call to memcpy(). At the same time,
it does not change the relative design idea.

ratio = original_nr_file / original_nr_anon;

If (nr_file > nr_anon), then ratio = (nr_file - x) / nr_anon.
 x = nr_file - ratio * nr_anon;

if (nr_file <= nr_anon), then ratio = nr_file / (nr_anon - x).
 x = nr_anon - nr_file / ratio;

Signed-off-by: Chen Yucong <slaoub@gmail.com>
---
 mm/vmscan.c |   28 +++++++++-------------------
 1 file changed, 9 insertions(+), 19 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a8ffe4e..daaf89c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2057,8 +2057,7 @@ out:
 static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 {
 	unsigned long nr[NR_LRU_LISTS];
-	unsigned long targets[NR_LRU_LISTS];
-	unsigned long nr_to_scan;
+	unsigned long nr_to_scan, ratio;
 	enum lru_list lru;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
@@ -2067,8 +2066,8 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 
 	get_scan_count(lruvec, sc, nr);
 
-	/* Record the original scan target for proportional adjustments later */
-	memcpy(targets, nr, sizeof(nr));
+	ratio = (nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE] + 1) /
+			(nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON] + 1);
 
 	/*
 	 * Global reclaiming within direct reclaim at DEF_PRIORITY is a normal
@@ -2088,7 +2087,6 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
 		unsigned long nr_anon, nr_file, percentage;
-		unsigned long nr_scanned;
 
 		for_each_evictable_lru(lru) {
 			if (nr[lru]) {
@@ -2123,15 +2121,13 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 			break;
 
 		if (nr_file > nr_anon) {
-			unsigned long scan_target = targets[LRU_INACTIVE_ANON] +
-						targets[LRU_ACTIVE_ANON] + 1;
+			nr_to_scan = nr_file - ratio * nr_anon;
+			percentage = nr[LRU_FILE] * 100 / nr_file;
 			lru = LRU_BASE;
-			percentage = nr_anon * 100 / scan_target;
 		} else {
-			unsigned long scan_target = targets[LRU_INACTIVE_FILE] +
-						targets[LRU_ACTIVE_FILE] + 1;
+			nr_to_scan = nr_anon - nr_file / ratio;
+			percentage = nr[LRU_BASE] * 100 / nr_anon;
 			lru = LRU_FILE;
-			percentage = nr_file * 100 / scan_target;
 		}
 
 		/* Stop scanning the smaller of the LRU */
@@ -2143,14 +2139,8 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 		 * scan target and the percentage scanning already complete
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
