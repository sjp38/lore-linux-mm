Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 987836B00C7
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 03:43:42 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n297hdxX012960
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 9 Mar 2009 16:43:39 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CB2945DE53
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:43:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C5A1F45DE50
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:43:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id AFCE1E38002
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:43:37 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 41CACE18007
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:43:37 +0900 (JST)
Date: Mon, 9 Mar 2009 16:42:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 3/4] memcg: softlimit caller via kswapd
Message-Id: <20090309164218.b64251b7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090309163745.5e3805ba.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090309163745.5e3805ba.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch adds hooks for memcg's softlimit to kswapd().

Softlimit handler is called...
  - before generic shrink_zone() is called.
  - # of pages to be scanned depends on priority.
  - If not enough progress, selected memcg will be moved to UNUSED queue.
  - at each call for balance_pgdat(), softlimit queue is rebalanced.

Changelog: v1->v2
  - check "enough progress" or not.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/vmscan.c |   42 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)

Index: develop/mm/vmscan.c
===================================================================
--- develop.orig/mm/vmscan.c
+++ develop/mm/vmscan.c
@@ -1733,6 +1733,43 @@ unsigned long try_to_free_mem_cgroup_pag
 }
 #endif
 
+static void shrink_zone_softlimit(struct scan_control *sc, struct zone *zone,
+			   int order, int priority, int target, int end_zone)
+{
+	int scan = SWAP_CLUSTER_MAX;
+	int nid = zone->zone_pgdat->node_id;
+	int zid = zone_idx(zone);
+	int before;
+	struct mem_cgroup *mem;
+
+	scan <<= (DEF_PRIORITY - priority);
+	if (scan > (target * 2))
+		scan = target * 2;
+
+	while (scan > 0) {
+		if (zone_watermark_ok(zone, order, target, end_zone, 0))
+			break;
+		mem = mem_cgroup_schedule(nid, zid);
+		if (!mem)
+			return;
+		sc->nr_scanned = 0;
+		sc->mem_cgroup = mem;
+		before = sc->nr_reclaimed;
+		sc->isolate_pages = mem_cgroup_isolate_pages;
+
+		shrink_zone(priority, zone, sc);
+
+		if (sc->nr_reclaimed - before > scan/2)
+			mem_cgroup_schedule_end(nid, zid, mem, true);
+		else
+			mem_cgroup_schedule_end(nid, zid, mem, false);
+
+		sc->mem_cgroup = NULL;
+		sc->isolate_pages = isolate_pages_global;
+		scan -= sc->nr_scanned;
+	}
+	return;
+}
 /*
  * For kswapd, balance_pgdat() will work across all this node's zones until
  * they are all at pages_high.
@@ -1776,6 +1813,8 @@ static unsigned long balance_pgdat(pg_da
 	 */
 	int temp_priority[MAX_NR_ZONES];
 
+	/* Refill softlimit queue */
+	mem_cgroup_reschedule(pgdat->node_id);
 loop_again:
 	total_scanned = 0;
 	sc.nr_reclaimed = 0;
@@ -1856,6 +1895,9 @@ loop_again:
 					       end_zone, 0))
 				all_zones_ok = 0;
 			temp_priority[i] = priority;
+			/* Try soft limit at first */
+			shrink_zone_softlimit(&sc, zone, order, priority,
+					       8 * zone->pages_high, end_zone);
 			sc.nr_scanned = 0;
 			note_zone_scanning_priority(zone, priority);
 			/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
