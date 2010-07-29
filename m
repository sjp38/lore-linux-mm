Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 28E306B02A9
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 01:29:55 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6T5TpqV027396
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 29 Jul 2010 14:29:52 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 93AAC45DE50
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 14:29:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A3A845DE4E
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 14:29:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 50CAB1DB8041
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 14:29:51 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0385A1DB803E
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 14:29:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 5/5] memcg: convert to use zone_to_nid() from bare zone->zone_pgdat->node_id
In-Reply-To: <20100729140700.4AA2.A69D9226@jp.fujitsu.com>
References: <20100729140700.4AA2.A69D9226@jp.fujitsu.com>
Message-Id: <20100729142914.4AB4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 29 Jul 2010 14:29:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


We have zone_to_nid(). this patch convert all existing users of
zone->zone_pgdat->node_id.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---
 mm/memcontrol.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b9ffc0c..b7bb7d9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -919,7 +919,7 @@ unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
 				       struct zone *zone,
 				       enum lru_list lru)
 {
-	int nid = zone->zone_pgdat->node_id;
+	int nid = zone_to_nid(zone);
 	int zid = zone_idx(zone);
 	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
 
@@ -929,7 +929,7 @@ unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
 struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
 						      struct zone *zone)
 {
-	int nid = zone->zone_pgdat->node_id;
+	int nid = zone_to_nid(zone);
 	int zid = zone_idx(zone);
 	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
 
@@ -974,7 +974,7 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 	LIST_HEAD(pc_list);
 	struct list_head *src;
 	struct page_cgroup *pc, *tmp;
-	int nid = z->zone_pgdat->node_id;
+	int nid = zone_to_nid(z);
 	int zid = zone_idx(z);
 	struct mem_cgroup_per_zone *mz;
 	int lru = LRU_FILE * file + active;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
