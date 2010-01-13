Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D32776B0078
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 03:22:41 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0D8MdC6017175
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 13 Jan 2010 17:22:39 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3882045DE50
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 17:22:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 07C0445DE4F
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 17:22:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E47641DB8041
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 17:22:38 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 905F71DB803F
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 17:22:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 3/3] [v2] memcg: add anon_scan_ratio to memory.stat file
In-Reply-To: <20100113171734.B3E2.A69D9226@jp.fujitsu.com>
References: <20100113171734.B3E2.A69D9226@jp.fujitsu.com>
Message-Id: <20100113172143.B3E8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 13 Jan 2010 17:22:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Changelog
  since v1: cancel to remove "recent_xxx" debug statistics as bilbir's
  mention

===========================================

anon_scan_ratio feature doesn't only useful for global VM pressure
analysis, but it also useful for memcg memroy pressure analysis.

Then, this patch add anon_scan_ratio field to memory.stat file too.

Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/memcontrol.c |   65 +++++++++++++++++++++++++++++++++++-------------------
 1 files changed, 42 insertions(+), 23 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 325df12..7348edc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2950,6 +2950,11 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 {
 	struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cont);
 	struct mcs_total_stat mystat;
+	struct zone *zone;
+	unsigned long total_anon = 0;
+	unsigned long total_scan_anon = 0;
+	unsigned long recent_rotated[2] = {0};
+	unsigned long recent_scanned[2] = {0};
 	int i;
 
 	memset(&mystat, 0, sizeof(mystat));
@@ -2978,33 +2983,47 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 		cb->fill(cb, memcg_stat_strings[i].total_name, mystat.stat[i]);
 	}
 
-#ifdef CONFIG_DEBUG_VM
 	cb->fill(cb, "inactive_ratio", calc_inactive_ratio(mem_cont, NULL));
 
-	{
-		int nid, zid;
+	for_each_populated_zone(zone) {
+		int nid = zone->zone_pgdat->node_id;
+		int zid = zone_idx(zone);
 		struct mem_cgroup_per_zone *mz;
-		unsigned long recent_rotated[2] = {0, 0};
-		unsigned long recent_scanned[2] = {0, 0};
-
-		for_each_online_node(nid)
-			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
-				mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
-
-				recent_rotated[0] +=
-					mz->reclaim_stat.recent_rotated[0];
-				recent_rotated[1] +=
-					mz->reclaim_stat.recent_rotated[1];
-				recent_scanned[0] +=
-					mz->reclaim_stat.recent_scanned[0];
-				recent_scanned[1] +=
-					mz->reclaim_stat.recent_scanned[1];
-			}
-		cb->fill(cb, "recent_rotated_anon", recent_rotated[0]);
-		cb->fill(cb, "recent_rotated_file", recent_rotated[1]);
-		cb->fill(cb, "recent_scanned_anon", recent_scanned[0]);
-		cb->fill(cb, "recent_scanned_file", recent_scanned[1]);
+		unsigned long anon;
+		unsigned long ratio;
+
+		mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
+
+		anon = MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_ANON);
+		anon += MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_ANON);
+
+		ratio = get_anon_scan_ratio(zone, mem_cont, mem_cont->swappiness);
+
+		/*
+		 * We have per-zone anon-scan-ratio. but we don't hope display such
+		 * value directly. Instead, we display following fomula.
+		 *
+		 *   sum(anon * ratio/100)
+		 *   --------------------- * 100
+		 *        sum(anon)
+		 */
+		total_anon += anon;
+		total_scan_anon += anon * ratio;
+
+#ifdef CONFIG_DEBUG_VM
+		recent_rotated[0] += mz->reclaim_stat.recent_rotated[0];
+		recent_rotated[1] += mz->reclaim_stat.recent_rotated[1];
+		recent_scanned[0] += mz->reclaim_stat.recent_scanned[0];
+		recent_scanned[1] += mz->reclaim_stat.recent_scanned[1];
+#endif
 	}
+	cb->fill(cb, "anon_scan_ratio", total_scan_anon / total_anon);
+
+#ifdef CONFIG_DEBUG_VM
+	cb->fill(cb, "recent_rotated_anon", recent_rotated[0]);
+	cb->fill(cb, "recent_rotated_file", recent_rotated[1]);
+	cb->fill(cb, "recent_scanned_anon", recent_scanned[0]);
+	cb->fill(cb, "recent_scanned_file", recent_scanned[1]);
 #endif
 
 	return 0;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
