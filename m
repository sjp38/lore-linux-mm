Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D70526B02A3
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 23:03:21 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6Q33Gnn015360
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 26 Jul 2010 12:03:16 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5763045DE61
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 12:03:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 21C3445DE55
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 12:03:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EB4ED1DB8042
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 12:03:15 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A19F41DB803B
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 12:03:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/4] vmscan: convert direct reclaim tracepoint to DEFINE_TRACE
In-Reply-To: <20100726120107.2EEE.A69D9226@jp.fujitsu.com>
References: <20100726120107.2EEE.A69D9226@jp.fujitsu.com>
Message-Id: <20100726120224.2EF1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 26 Jul 2010 12:03:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Mel Gorman recently added some vmscan tracepoints. Unfortunately they are
covered only global reclaim. But we want to trace memcg reclaim too.

Thus, this patch convert them to DEFINE_TRACE macro. it help to reuse
tracepoint definition for other similar usage (i.e. memcg).
This patch have no functionally change.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 include/trace/events/vmscan.h |   19 +++++++++++++++++--
 1 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index f2da66a..a601763 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -68,7 +68,7 @@ TRACE_EVENT(mm_vmscan_wakeup_kswapd,
 		__entry->order)
 );
 
-TRACE_EVENT(mm_vmscan_direct_reclaim_begin,
+DECLARE_EVENT_CLASS(mm_vmscan_direct_reclaim_begin_template,
 
 	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags),
 
@@ -92,7 +92,15 @@ TRACE_EVENT(mm_vmscan_direct_reclaim_begin,
 		show_gfp_flags(__entry->gfp_flags))
 );
 
-TRACE_EVENT(mm_vmscan_direct_reclaim_end,
+DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_direct_reclaim_begin,
+
+	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags),
+
+	TP_ARGS(order, may_writepage, gfp_flags)
+);
+
+
+DECLARE_EVENT_CLASS(mm_vmscan_direct_reclaim_end_template,
 
 	TP_PROTO(unsigned long nr_reclaimed),
 
@@ -109,6 +117,13 @@ TRACE_EVENT(mm_vmscan_direct_reclaim_end,
 	TP_printk("nr_reclaimed=%lu", __entry->nr_reclaimed)
 );
 
+DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_direct_reclaim_end,
+
+	TP_PROTO(unsigned long nr_reclaimed),
+
+	TP_ARGS(nr_reclaimed)
+);
+
 TRACE_EVENT(mm_vmscan_lru_isolate,
 
 	TP_PROTO(int order,
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
