Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB1CGp63011462
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 1 Dec 2008 21:16:51 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 784D545DD7A
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 21:16:50 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D1E3345DE4F
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 21:16:49 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AA0D21DB803E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 21:16:49 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 47DB0E08001
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 21:16:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 07/11] memcg: make mem_cgroup_zone_nr_pages()
In-Reply-To: <20081201205810.1CCA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081201205810.1CCA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081201211545.1CDF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  1 Dec 2008 21:16:48 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

introduce mem_cgroup_zone_nr_pages().
it is called by zone_nr_pages() helper function.


this patch doesn't have any behavior change.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/memcontrol.h |   11 +++++++++++
 mm/memcontrol.c            |   12 +++++++++++-
 mm/vmscan.c                |    3 +++
 3 files changed, 25 insertions(+), 1 deletion(-)

Index: b/include/linux/memcontrol.h
===================================================================
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -92,6 +92,9 @@ extern long mem_cgroup_calc_reclaim(stru
 					int priority, enum lru_list lru);
 int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg,
 				    struct zone *zone);
+unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
+				       struct zone *zone,
+				       enum lru_list lru);
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
@@ -250,6 +253,14 @@ mem_cgroup_inactive_anon_is_low(struct m
 	return 1;
 }
 
+static inline unsigned long
+mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg, struct zone *zone,
+			 enum lru_list lru)
+{
+	return 0;
+}
+
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
Index: b/mm/memcontrol.c
===================================================================
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -186,7 +186,6 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
 	0, /* FORCE */
 };
 
-
 /* for encoding cft->private value on file */
 #define _MEM			(0)
 #define _MEMSWAP		(1)
@@ -448,6 +447,17 @@ int mem_cgroup_inactive_anon_is_low(stru
 	return 0;
 }
 
+unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
+				       struct zone *zone,
+				       enum lru_list lru)
+{
+	int nid = zone->zone_pgdat->node_id;
+	int zid = zone_idx(zone);
+	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
+
+	return MEM_CGROUP_ZSTAT(mz, lru);
+}
+
 unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -140,6 +140,9 @@ static struct zone_reclaim_stat *get_rec
 static unsigned long zone_nr_pages(struct zone *zone, struct scan_control *sc,
 				   enum lru_list lru)
 {
+	if (!scan_global_lru(sc))
+		return mem_cgroup_zone_nr_pages(sc->mem_cgroup, zone, lru);
+
 	return zone_page_state(zone, NR_LRU_BASE + lru);
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
