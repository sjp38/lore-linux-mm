Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 361E36B024D
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 23:04:18 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6Q34FQA009020
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 26 Jul 2010 12:04:15 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D54645DE55
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 12:04:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D341045DE51
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 12:04:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9ABC41DB8054
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 12:04:14 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A5161DB8050
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 12:04:14 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/4] memcg, vmscan: add memcg reclaim tracepoint
In-Reply-To: <20100726120107.2EEE.A69D9226@jp.fujitsu.com>
References: <20100726120107.2EEE.A69D9226@jp.fujitsu.com>
Message-Id: <20100726120325.2EF4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 26 Jul 2010 12:04:13 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Memcg also need to trace reclaim progress as direct reclaim. This patch
add it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---
 include/trace/events/vmscan.h |   28 ++++++++++++++++++++++++++++
 mm/vmscan.c                   |   20 +++++++++++++++++++-
 2 files changed, 47 insertions(+), 1 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index a601763..c35e905 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -99,6 +99,19 @@ DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_direct_reclaim_b
 	TP_ARGS(order, may_writepage, gfp_flags)
 );
 
+DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_reclaim_begin,
+
+	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags),
+
+	TP_ARGS(order, may_writepage, gfp_flags)
+);
+
+DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_softlimit_reclaim_begin,
+
+	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags),
+
+	TP_ARGS(order, may_writepage, gfp_flags)
+);
 
 DECLARE_EVENT_CLASS(mm_vmscan_direct_reclaim_end_template,
 
@@ -124,6 +137,21 @@ DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_direct_reclaim_end
 	TP_ARGS(nr_reclaimed)
 );
 
+DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_memcg_reclaim_end,
+
+	TP_PROTO(unsigned long nr_reclaimed),
+
+	TP_ARGS(nr_reclaimed)
+);
+
+DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_memcg_softlimit_reclaim_end,
+
+	TP_PROTO(unsigned long nr_reclaimed),
+
+	TP_ARGS(nr_reclaimed)
+);
+
+
 TRACE_EVENT(mm_vmscan_lru_isolate,
 
 	TP_PROTO(int order,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 97170eb..c691967 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1949,6 +1949,11 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 	sc.nodemask = &nm;
 	sc.nr_reclaimed = 0;
 	sc.nr_scanned = 0;
+
+	trace_mm_vmscan_memcg_softlimit_reclaim_begin(0,
+						      sc.may_writepage,
+						      sc.gfp_mask);
+
 	/*
 	 * NOTE: Although we can get the priority field, using it
 	 * here is not a good idea, since it limits the pages we can scan.
@@ -1957,6 +1962,9 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 	 * the priority and make it zero.
 	 */
 	shrink_zone(0, zone, &sc);
+
+	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
+
 	return sc.nr_reclaimed;
 }
 
@@ -1966,6 +1974,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 					   unsigned int swappiness)
 {
 	struct zonelist *zonelist;
+	unsigned long nr_reclaimed;
 	struct scan_control sc = {
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
@@ -1980,7 +1989,16 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
 	zonelist = NODE_DATA(numa_node_id())->node_zonelists;
-	return do_try_to_free_pages(zonelist, &sc);
+
+	trace_mm_vmscan_memcg_reclaim_begin(0,
+					    sc.may_writepage,
+					    sc.gfp_mask);
+
+	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
+
+	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
+
+	return nr_reclaimed;
 }
 #endif
 
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
