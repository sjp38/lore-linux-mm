Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3C01690010C
	for <linux-mm@kvack.org>; Tue, 10 May 2011 06:15:01 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2D0893EE0C2
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:14:59 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 118FA45DE54
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:14:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id ECC9845DE4E
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:14:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DE396E78002
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:14:58 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A481E1DB8037
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:14:58 +0900 (JST)
Date: Tue, 10 May 2011 19:08:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 4/7] memcg : test a memcg is reclaimable
Message-Id: <20110510190820.c62aca76.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>


A function for checking that a memcg has reclaimable pages. This makes
use of mem->scan_nodes when CONFIG_NUMA=y.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    1 +
 mm/memcontrol.c            |   19 +++++++++++++++++++
 2 files changed, 20 insertions(+)

Index: mmotm-May6/mm/memcontrol.c
===================================================================
--- mmotm-May6.orig/mm/memcontrol.c
+++ mmotm-May6/mm/memcontrol.c
@@ -1623,11 +1623,30 @@ int mem_cgroup_select_victim_node(struct
 	return node;
 }
 
+bool mem_cgroup_test_reclaimable(struct mem_cgroup *memcg)
+{
+	mem_cgroup_may_update_nodemask(memcg);
+	return !nodes_empty(memcg->scan_nodes);
+}
+
 #else
 int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
 {
 	return 0;
 }
+
+bool mem_cgroup_test_reclaimable(struct mem_cgroup *memcg)
+{
+	unsigned long nr;
+	int zid;
+
+	for (zid = NODE_DATA(0)->nr_zones - 1; zid >= 0; zid--)
+		if (mem_cgroup_zone_reclaimable_pages(memcg, 0, zid))
+			break;
+	if (zid < 0)
+		return false;
+	return true;
+}
 #endif
 
 /*
Index: mmotm-May6/include/linux/memcontrol.h
===================================================================
--- mmotm-May6.orig/include/linux/memcontrol.h
+++ mmotm-May6/include/linux/memcontrol.h
@@ -110,6 +110,7 @@ int mem_cgroup_inactive_anon_is_low(stru
 int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
 unsigned long
 mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg, int nid, int zid);
+bool mem_cgroup_test_reclaimable(struct mem_cgroup *memcg);
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
 unsigned int mem_cgroup_swappiness(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
