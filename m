Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 600CB6B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 23:49:39 -0500 (EST)
Received: by iouu10 with SMTP id u10so43457690iou.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 20:49:39 -0800 (PST)
Received: from cmccmta1.chinamobile.com (cmccmta1.chinamobile.com. [221.176.66.79])
        by mx.google.com with ESMTP id 19si18565839iol.108.2015.11.24.20.49.37
        for <linux-mm@kvack.org>;
        Tue, 24 Nov 2015 20:49:38 -0800 (PST)
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: [PATCH] mm: vmscan: Obey indeed proportional scanning for kswapd and memcg
Date: Wed, 25 Nov 2015 12:48:20 +0800
Message-Id: <1448426900-2907-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, riel@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, jslaby@suse.cz, Valdis.Kletnieks@vt.edu, zcalusic@bitsync.net, vbabka@suse.cz, vdavydov@parallels.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit e82e0561dae9f3ae5 ("mm: vmscan: obey proportional scanning
requirements for kswapd") intended to preserve the proportional scanning
and reclaim what was requested by get_scan_count() for kswapd and memcg
by stopping reclaiming one type(anon or file) LRU and reducing the other's
amount of scanning proportional to the original scan target.

So the way to determine which LRU should be stopped reclaiming should be
comparing scanned/unscanned percentages to the original scan target of two
lru types instead of absolute values what implemented currently, because
larger absolute value doesn't mean larger percentage, there shall be
chance that larger absolute value with smaller percentage, for instance:

	target_file = 1000
	target_anon = 500
	nr_file = 500
	nr_anon = 400

in this case, because nr_file > nr_anon, according to current implement,
we will stop scanning anon lru and shrink file lru. This breaks
proportional scanning intent and makes more unproportional.

This patch changes to compare percentage to the original scan target to
determine which lru should be shrunk.

Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
---
 mm/vmscan.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2aec424..09a37436 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2216,6 +2216,7 @@ static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
 		unsigned long nr_anon, nr_file, percentage;
+		unsigned long percentage_anon, percentage_file;
 		unsigned long nr_scanned;
 
 		for_each_evictable_lru(lru) {
@@ -2250,16 +2251,17 @@ static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
 		if (!nr_file || !nr_anon)
 			break;
 
-		if (nr_file > nr_anon) {
-			unsigned long scan_target = targets[LRU_INACTIVE_ANON] +
-						targets[LRU_ACTIVE_ANON] + 1;
+		percentage_anon = nr_anon * 100 / (targets[LRU_INACTIVE_ANON] +
+						targets[LRU_ACTIVE_ANON] + 1);
+		percentage_file = nr_file * 100 / (targets[LRU_INACTIVE_FILE] +
+						targets[LRU_ACTIVE_FILE] + 1);
+
+		if (percentage_file > percentage_anon) {
 			lru = LRU_BASE;
-			percentage = nr_anon * 100 / scan_target;
+			percentage = percentage_anon;
 		} else {
-			unsigned long scan_target = targets[LRU_INACTIVE_FILE] +
-						targets[LRU_ACTIVE_FILE] + 1;
 			lru = LRU_FILE;
-			percentage = nr_file * 100 / scan_target;
+			percentage = percentage_file;
 		}
 
 		/* Stop scanning the smaller of the LRU */
-- 
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
