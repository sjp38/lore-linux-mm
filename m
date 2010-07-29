Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 67F316B02A4
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 01:29:25 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6T5TNFi027353
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 29 Jul 2010 14:29:23 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B1C145DE7B
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 14:29:19 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 00D3145DE4D
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 14:29:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 428851DB8046
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 14:29:16 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CAD6E38002
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 14:29:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 4/5] memcg: remove nid and zid argument from mem_cgroup_soft_limit_reclaim()
In-Reply-To: <20100729140700.4AA2.A69D9226@jp.fujitsu.com>
References: <20100729140700.4AA2.A69D9226@jp.fujitsu.com>
Message-Id: <20100729142810.4AB1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 29 Jul 2010 14:29:13 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

mem_cgroup_soft_limit_reclaim() has zone, nid and zid argument. but nid
and zid can be calculated from zone. So remove it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>

---
 include/linux/memcontrol.h |    6 +++---
 mm/memcontrol.c            |    5 ++---
 mm/vmscan.c                |    7 ++-----
 3 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 9f1afd3..fd8ddbd 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -123,8 +123,8 @@ static inline bool mem_cgroup_disabled(void)
 
 void mem_cgroup_update_file_mapped(struct page *page, int val);
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-						gfp_t gfp_mask, int nid,
-						int zid);
+					    gfp_t gfp_mask);
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 
@@ -299,7 +299,7 @@ static inline void mem_cgroup_update_file_mapped(struct page *page,
 
 static inline
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-					    gfp_t gfp_mask, int nid, int zid)
+					    gfp_t gfp_mask)
 {
 	return 0;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fee5cfa..b9ffc0c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2847,8 +2847,7 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 }
 
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-						gfp_t gfp_mask, int nid,
-						int zid)
+					    gfp_t gfp_mask)
 {
 	unsigned long nr_reclaimed = 0;
 	struct mem_cgroup_per_zone *mz, *next_mz = NULL;
@@ -2860,7 +2859,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 	if (order > 0)
 		return 0;
 
-	mctz = soft_limit_tree_node_zone(nid, zid);
+	mctz = soft_limit_tree_node_zone(zone_to_nid(zone), zone_idx(zone));
 	/*
 	 * This loop can run a while, specially if mem_cgroup's continuously
 	 * keep exceeding their soft limit and putting the system under
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5e37c84..6faae10 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2131,7 +2131,6 @@ loop_again:
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
 			int nr_slab;
-			int nid, zid;
 
 			if (!populated_zone(zone))
 				continue;
@@ -2141,14 +2140,12 @@ loop_again:
 
 			sc.nr_scanned = 0;
 
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
