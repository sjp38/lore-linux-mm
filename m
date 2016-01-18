Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD896B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 02:18:28 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id ik10so50075839igb.1
        for <linux-mm@kvack.org>; Sun, 17 Jan 2016 23:18:28 -0800 (PST)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id e34si23906453iod.55.2016.01.17.23.18.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 17 Jan 2016 23:18:27 -0800 (PST)
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0O15031SO0APPX00@mailout2.samsung.com> for linux-mm@kvack.org;
 Mon, 18 Jan 2016 16:18:25 +0900 (KST)
From: Maninder Singh <maninder1.s@samsung.com>
Subject: [PATCH 1/1] mmzone: code cleanup for LRU stats.
Date: Mon, 18 Jan 2016 12:48:12 +0530
Message-id: <1453101492-37125-1-git-send-email-maninder1.s@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov@virtuozzo.com, akpm@linux-foundation.org, mgorman@techsingularity.net, vbabka@suse.cz, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, tj@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org
Cc: ajeet.y@samsung.com, pankaj.m@samsung.com, Maninder Singh <maninder1.s@samsung.com>, Vaneet Narang <v.narang@samsung.com>

Replacing hardcoded values with enum lru_stats for LRU stats.

Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
Signed-off-by: Vaneet Narang <v.narang@samsung.com>
---
 include/linux/mmzone.h |   12 ++++++++----
 mm/memcontrol.c        |   20 ++++++++++----------
 mm/vmscan.c            |   20 ++++++++++----------
 3 files changed, 28 insertions(+), 24 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 68cc063..fd993e4 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -198,17 +198,21 @@ static inline int is_active_lru(enum lru_list lru)
 	return (lru == LRU_ACTIVE_ANON || lru == LRU_ACTIVE_FILE);
 }
 
+enum lru_stats {
+	LRU_ANON_STAT, /* anon LRU stats */
+	LRU_FILE_STAT, /* file LRU stats */
+	LRU_MAX_STAT
+};
+
 struct zone_reclaim_stat {
 	/*
 	 * The pageout code in vmscan.c keeps track of how many of the
 	 * mem/swap backed and file backed pages are referenced.
 	 * The higher the rotated/scanned ratio, the more valuable
 	 * that cache is.
-	 *
-	 * The anon LRU stats live in [0], file LRU stats in [1]
 	 */
-	unsigned long		recent_rotated[2];
-	unsigned long		recent_scanned[2];
+	unsigned long		recent_rotated[LRU_MAX_STAT];
+	unsigned long		recent_scanned[LRU_MAX_STAT];
 };
 
 struct lruvec {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 11e97e0..49c8e4d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3373,23 +3373,23 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 		int nid, zid;
 		struct mem_cgroup_per_zone *mz;
 		struct zone_reclaim_stat *rstat;
-		unsigned long recent_rotated[2] = {0, 0};
-		unsigned long recent_scanned[2] = {0, 0};
+		unsigned long recent_rotated[LRU_MAX_STAT] = {0, 0};
+		unsigned long recent_scanned[LRU_MAX_STAT] = {0, 0};
 
 		for_each_online_node(nid)
 			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
 				mz = &memcg->nodeinfo[nid]->zoneinfo[zid];
 				rstat = &mz->lruvec.reclaim_stat;
 
-				recent_rotated[0] += rstat->recent_rotated[0];
-				recent_rotated[1] += rstat->recent_rotated[1];
-				recent_scanned[0] += rstat->recent_scanned[0];
-				recent_scanned[1] += rstat->recent_scanned[1];
+				recent_rotated[LRU_ANON_STAT] += rstat->recent_rotated[LRU_ANON_STAT];
+				recent_rotated[LRU_FILE_STAT] += rstat->recent_rotated[LRU_FILE_STAT];
+				recent_scanned[LRU_ANON_STAT] += rstat->recent_scanned[LRU_ANON_STAT];
+				recent_scanned[LRU_FILE_STAT] += rstat->recent_scanned[LRU_FILE_STAT];
 			}
-		seq_printf(m, "recent_rotated_anon %lu\n", recent_rotated[0]);
-		seq_printf(m, "recent_rotated_file %lu\n", recent_rotated[1]);
-		seq_printf(m, "recent_scanned_anon %lu\n", recent_scanned[0]);
-		seq_printf(m, "recent_scanned_file %lu\n", recent_scanned[1]);
+		seq_printf(m, "recent_rotated_anon %lu\n", recent_rotated[LRU_ANON_STAT]);
+		seq_printf(m, "recent_rotated_file %lu\n", recent_rotated[LRU_FILE_STAT]);
+		seq_printf(m, "recent_scanned_anon %lu\n", recent_scanned[LRU_ANON_STAT]);
+		seq_printf(m, "recent_scanned_file %lu\n", recent_scanned[LRU_FILE_STAT]);
 	}
 #endif
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ee3bbd5..7a66554 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2176,14 +2176,14 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 		get_lru_size(lruvec, LRU_INACTIVE_FILE);
 
 	spin_lock_irq(&zone->lru_lock);
-	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
-		reclaim_stat->recent_scanned[0] /= 2;
-		reclaim_stat->recent_rotated[0] /= 2;
+	if (unlikely(reclaim_stat->recent_scanned[LRU_ANON_STAT] > anon / 4)) {
+		reclaim_stat->recent_scanned[LRU_ANON_STAT] /= 2;
+		reclaim_stat->recent_rotated[LRU_ANON_STAT] /= 2;
 	}
 
-	if (unlikely(reclaim_stat->recent_scanned[1] > file / 4)) {
-		reclaim_stat->recent_scanned[1] /= 2;
-		reclaim_stat->recent_rotated[1] /= 2;
+	if (unlikely(reclaim_stat->recent_scanned[LRU_FILE_STAT] > file / 4)) {
+		reclaim_stat->recent_scanned[LRU_FILE_STAT] /= 2;
+		reclaim_stat->recent_rotated[LRU_FILE_STAT] /= 2;
 	}
 
 	/*
@@ -2191,11 +2191,11 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * proportional to the fraction of recently scanned pages on
 	 * each list that were recently referenced and in active use.
 	 */
-	ap = anon_prio * (reclaim_stat->recent_scanned[0] + 1);
-	ap /= reclaim_stat->recent_rotated[0] + 1;
+	ap = anon_prio * (reclaim_stat->recent_scanned[LRU_ANON_STAT] + 1);
+	ap /= reclaim_stat->recent_rotated[LRU_ANON_STAT] + 1;
 
-	fp = file_prio * (reclaim_stat->recent_scanned[1] + 1);
-	fp /= reclaim_stat->recent_rotated[1] + 1;
+	fp = file_prio * (reclaim_stat->recent_scanned[LRU_FILE_STAT] + 1);
+	fp /= reclaim_stat->recent_rotated[LRU_FILE_STAT] + 1;
 	spin_unlock_irq(&zone->lru_lock);
 
 	fraction[0] = ap;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
