Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0E6596B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 21:01:32 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C11V8Q006114
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 12 Mar 2009 10:01:31 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E179F45DE51
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 10:01:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A8F8D45DE50
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 10:01:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 83D031DB803B
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 10:01:30 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 199CD1DB803C
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 10:01:30 +0900 (JST)
Date: Thu, 12 Mar 2009 10:00:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 5/5] memcg softlimit hooks to kswapd
Message-Id: <20090312100008.aa8379d7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This patch needs MORE investigation...

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch adds hooks for memcg's softlimit to kswapd().

Softlimit handler is called...
  - before generic shrink_zone() is called.
  - # of pages to be scanned depends on priority.
  - If not enough progress, selected memcg will be moved to UNUSED queue.
  - at each call for balance_pgdat(), softlimit queue is rebalanced.

Changelog: v3 -> v4
 - move "sc" as local variable

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/vmscan.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 52 insertions(+)

Index: mmotm-2.6.29-Mar10/mm/vmscan.c
===================================================================
--- mmotm-2.6.29-Mar10.orig/mm/vmscan.c
+++ mmotm-2.6.29-Mar10/mm/vmscan.c
@@ -1733,6 +1733,49 @@ unsigned long try_to_free_mem_cgroup_pag
 }
 #endif
 
+static void shrink_zone_softlimit(struct zone *zone, int order, int priority,
+			   int target, int end_zone)
+{
+	int scan = SWAP_CLUSTER_MAX;
+	int nid = zone->zone_pgdat->node_id;
+	int zid = zone_idx(zone);
+	struct mem_cgroup *mem;
+	struct scan_control sc =  {
+		.gfp_mask = GFP_KERNEL,
+		.may_writepage = !laptop_mode,
+		.swap_cluster_max = SWAP_CLUSTER_MAX,
+		.may_unmap = 1,
+		.swappiness = vm_swappiness,
+		.order = order,
+		.mem_cgroup = NULL,
+		.isolate_pages = mem_cgroup_isolate_pages,
+	};
+
+	scan = target * 2;
+
+	sc.nr_scanned = 0;
+	sc.nr_reclaimed = 0;
+	while (scan > 0) {
+		if (zone_watermark_ok(zone, order, target, end_zone, 0))
+			break;
+		mem = mem_cgroup_schedule(nid, zid);
+		if (!mem)
+			return;
+		sc.mem_cgroup = mem;
+
+		sc.nr_reclaimed = 0;
+		shrink_zone(priority, zone, &sc);
+
+		if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX/2)
+			mem_cgroup_schedule_end(nid, zid, mem, true);
+		else
+			mem_cgroup_schedule_end(nid, zid, mem, false);
+
+		scan -= sc.nr_scanned;
+	}
+
+	return;
+}
 /*
  * For kswapd, balance_pgdat() will work across all this node's zones until
  * they are all at pages_high.
@@ -1776,6 +1819,8 @@ static unsigned long balance_pgdat(pg_da
 	 */
 	int temp_priority[MAX_NR_ZONES];
 
+	/* Refill softlimit queue */
+	mem_cgroup_reschedule_all(pgdat->node_id);
 loop_again:
 	total_scanned = 0;
 	sc.nr_reclaimed = 0;
@@ -1856,6 +1901,13 @@ loop_again:
 					       end_zone, 0))
 				all_zones_ok = 0;
 			temp_priority[i] = priority;
+
+			/*
+			 * Try soft limit at first.  This reclaims page
+			 * with regard to user's hint.
+			 */
+			shrink_zone_softlimit(zone, order, priority,
+					       8 * zone->pages_high, end_zone);
 			sc.nr_scanned = 0;
 			note_zone_scanning_priority(zone, priority);
 			/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
