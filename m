Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 09EF96B0023
	for <linux-mm@kvack.org>; Thu, 26 May 2011 01:26:00 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6455D3EE0AE
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:25:58 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BFDF45DE9C
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:25:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 286E845DEC5
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:25:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 195071DB803B
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:25:58 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D64231DB803E
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:25:57 +0900 (JST)
Date: Thu, 26 May 2011 14:19:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH v3 3/10] memcg: a test whether zone is reclaimable or
 not
Message-Id: <20110526141909.ec42113e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

From: Ying Han <yinghan@google.com>

The number of reclaimable pages per zone is an useful information for
controling memory reclaim schedule. This patch exports it.

Changelog v2->v3:
  - added comments.

Signed-off-by: Ying Han <yinghan@google.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    2 ++
 mm/memcontrol.c            |   24 ++++++++++++++++++++++++
 2 files changed, 26 insertions(+)

Index: memcg_async/mm/memcontrol.c
===================================================================
--- memcg_async.orig/mm/memcontrol.c
+++ memcg_async/mm/memcontrol.c
@@ -1240,6 +1240,30 @@ static unsigned long mem_cgroup_nr_lru_p
 }
 #endif /* CONFIG_NUMA */
 
+/**
+ * mem_cgroup_zone_reclaimable_pages
+ * @memcg: the memcg
+ * @nid  : node index to be checked.
+ * @zid  : zone index to be checked.
+ *
+ * This function returns the number reclaimable pages on a zone for given memcg.
+ * Reclaimable page includes file caches and anonymous pages if swap is
+ * avaliable and never includes unevictable pages.
+ */
+unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg,
+						int nid, int zid)
+{
+	unsigned long nr;
+	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
+
+	nr = MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE) +
+		MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE);
+	if (nr_swap_pages > 0)
+		nr += MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_ANON) +
+			MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_ANON);
+	return nr;
+}
+
 struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
 						      struct zone *zone)
 {
Index: memcg_async/include/linux/memcontrol.h
===================================================================
--- memcg_async.orig/include/linux/memcontrol.h
+++ memcg_async/include/linux/memcontrol.h
@@ -109,6 +109,8 @@ extern void mem_cgroup_end_migration(str
  */
 int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
 int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
+unsigned long
+mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg, int nid, int zid);
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
 						struct zone *zone,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
