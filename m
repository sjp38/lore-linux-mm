Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EE79E6B0023
	for <linux-mm@kvack.org>; Thu, 19 May 2011 23:48:58 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 589733EE0BB
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:48:56 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4088845DE80
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:48:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 21DDE45DE88
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:48:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BB0E1DB8040
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:48:56 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C4B5D1DB8037
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:48:55 +0900 (JST)
Date: Fri, 20 May 2011 12:42:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/8] memcg: easy check routine for reclaimable
Message-Id: <20110520124212.facdc595.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, hannes@cmpxchg.org, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>


A function for checking that a memcg has reclaimable pages. This makes
use of mem->scan_nodes when CONFIG_NUMA=y.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    1 +
 mm/memcontrol.c            |   19 +++++++++++++++++++
 2 files changed, 20 insertions(+)

Index: mmotm-May11/mm/memcontrol.c
===================================================================
--- mmotm-May11.orig/mm/memcontrol.c
+++ mmotm-May11/mm/memcontrol.c
@@ -1587,11 +1587,30 @@ int mem_cgroup_select_victim_node(struct
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
Index: mmotm-May11/include/linux/memcontrol.h
===================================================================
--- mmotm-May11.orig/include/linux/memcontrol.h
+++ mmotm-May11/include/linux/memcontrol.h
@@ -110,6 +110,7 @@ int mem_cgroup_inactive_anon_is_low(stru
 int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
 unsigned long
 mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg, int nid, int zid);
+bool mem_cgroup_test_reclaimable(struct mem_cgroup *memcg);
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
 				       struct zone *zone,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
