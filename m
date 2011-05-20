Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7C45A6B0023
	for <linux-mm@kvack.org>; Thu, 19 May 2011 23:47:59 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A46733EE0BC
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:47:56 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AD5B45DE78
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:47:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E21D45DE93
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:47:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4ED4AE18004
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:47:56 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FFC21DB8037
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:47:56 +0900 (JST)
Date: Fri, 20 May 2011 12:41:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/8] memcg: export zone reclaimable pages
Message-Id: <20110520124108.c65e03e3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, hannes@cmpxchg.org, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

From: Ying Han <yinghan@google.com>

The number of reclaimable pages per zone is an useful information for
controling memory reclaim schedule. This patch exports it.

Signed-off-by: Ying Han <yinghan@google.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    2 ++
 mm/memcontrol.c            |   14 ++++++++++++++
 2 files changed, 16 insertions(+)

Index: mmotm-May11/mm/memcontrol.c
===================================================================
--- mmotm-May11.orig/mm/memcontrol.c
+++ mmotm-May11/mm/memcontrol.c
@@ -1162,6 +1162,20 @@ unsigned long mem_cgroup_zone_nr_pages(s
 	return MEM_CGROUP_ZSTAT(mz, lru);
 }
 
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
Index: mmotm-May11/include/linux/memcontrol.h
===================================================================
--- mmotm-May11.orig/include/linux/memcontrol.h
+++ mmotm-May11/include/linux/memcontrol.h
@@ -108,6 +108,8 @@ extern void mem_cgroup_end_migration(str
  */
 int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
 int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
+unsigned long
+mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg, int nid, int zid);
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
 				       struct zone *zone,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
