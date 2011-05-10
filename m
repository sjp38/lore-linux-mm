Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 17BD3900001
	for <linux-mm@kvack.org>; Tue, 10 May 2011 06:12:28 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6048B3EE0BC
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:12:24 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3562545DE58
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:12:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 124A245DE4E
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:12:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F13E9E78007
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:12:23 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B675AE78004
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:12:23 +0900 (JST)
Date: Tue, 10 May 2011 19:05:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/7] memcg: count reclaimable pages per zone
Message-Id: <20110510190545.1a290638.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

From: Ying Han <yinghan@google.com>

The number of reclaimable pages per zone is an useful information for
controling memory reclaim schedule. This patch exports it.

Signed-off-by: Ying Han <yinghan@google.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    2 ++
 mm/memcontrol.c            |   14 ++++++++++++++
 2 files changed, 16 insertions(+)

Index: mmotm-May6/mm/memcontrol.c
===================================================================
--- mmotm-May6.orig/mm/memcontrol.c
+++ mmotm-May6/mm/memcontrol.c
@@ -1198,6 +1198,20 @@ unsigned long mem_cgroup_zone_nr_pages(s
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
Index: mmotm-May6/include/linux/memcontrol.h
===================================================================
--- mmotm-May6.orig/include/linux/memcontrol.h
+++ mmotm-May6/include/linux/memcontrol.h
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
