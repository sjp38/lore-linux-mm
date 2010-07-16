Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1C83C6B02A6
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 06:15:12 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6GAF8aR007966
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 16 Jul 2010 19:15:09 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C50C645DE51
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 19:15:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 80E3A45DE4E
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 19:15:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D5EA71DB8042
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 19:15:06 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B97F1DB803E
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 19:15:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 3/7] memcg: nid and zid can be calculated from zone
In-Reply-To: <20100716191006.7369.A69D9226@jp.fujitsu.com>
References: <20100716191006.7369.A69D9226@jp.fujitsu.com>
Message-Id: <20100716191418.7372.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 16 Jul 2010 19:15:05 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


mem_cgroup_soft_limit_reclaim() has zone, nid and zid argument. but nid
and zid can be calculated from zone. So remove it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    6 +++---
 include/linux/mmzone.h     |    5 +++++
 mm/memcontrol.c            |    5 ++---
 mm/vmscan.c                |    7 ++-----
 4 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 9411d32..9dec218 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -128,8 +128,8 @@ static inline bool mem_cgroup_disabled(void)
 
 void mem_cgroup_update_file_mapped(struct page *page, int val);
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-						gfp_t gfp_mask, int nid,
-						int zid);
+					    gfp_t gfp_mask);
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 
@@ -304,7 +304,7 @@ static inline void mem_cgroup_update_file_mapped(struct page *page,
 
 static inline
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-					    gfp_t gfp_mask, int nid, int zid)
+					    gfp_t gfp_mask)
 {
 	return 0;
 }
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 9ed9c45..34ac27a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -684,6 +684,11 @@ unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
  */
 #define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
 
+static inline int zone_nid(struct zone *zone)
+{
+	return zone->zone_pgdat->node_id;
+}
+
 static inline int populated_zone(struct zone *zone)
 {
 	return (!!zone->present_pages);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 01f38ff..81bc9bf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2833,8 +2833,7 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 }
 
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-						gfp_t gfp_mask, int nid,
-						int zid)
+					    gfp_t gfp_mask)
 {
 	unsigned long nr_reclaimed = 0;
 	struct mem_cgroup_per_zone *mz, *next_mz = NULL;
@@ -2846,7 +2845,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 	if (order > 0)
 		return 0;
 
-	mctz = soft_limit_tree_node_zone(nid, zid);
+	mctz = soft_limit_tree_node_zone(zone_nid(zone), zone_idx(zone));
 	/*
 	 * This loop can run a while, specially if mem_cgroup's continuously
 	 * keep exceeding their soft limit and putting the system under
diff --git a/mm/vmscan.c b/mm/vmscan.c
index be860a0..89b4287 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2121,7 +2121,6 @@ loop_again:
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
 			int nr_slab;
-			int nid, zid;
 
 			if (!populated_zone(zone))
 				continue;
@@ -2133,14 +2132,12 @@ loop_again:
 			sc.nr_scanned = 0;
 			note_zone_scanning_priority(zone, priority);
 
-			nid = pgdat->node_id;
-			zid = zone_idx(zone);
 			/*
 			 * Call soft limit reclaim before calling shrink_zone.
 			 * For now we ignore the return value
 			 */
-			mem_cgroup_soft_limit_reclaim(zone, order, sc.gfp_mask,
-							nid, zid);
+			mem_cgroup_soft_limit_reclaim(zone, order, sc.gfp_mask);
+
 			/*
 			 * We put equal pressure on every zone, unless one
 			 * zone has way too many pages free already.
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
