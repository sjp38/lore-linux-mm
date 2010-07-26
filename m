Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B24E66B02A3
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 23:06:09 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6Q367EE020982
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 26 Jul 2010 12:06:07 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 65FF045DE51
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 12:06:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2536F45DE4F
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 12:06:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E7E41DB8050
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 12:06:07 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B37211DB8042
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 12:06:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 4/4] memcg: add mm_vmscan_memcg_isolate tracepoint
In-Reply-To: <20100726120107.2EEE.A69D9226@jp.fujitsu.com>
References: <20100726120107.2EEE.A69D9226@jp.fujitsu.com>
Message-Id: <20100726120519.2EFA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 26 Jul 2010 12:06:05 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Memcg also need to trace page isolation information as global reclaim.
This patch does it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/trace/events/vmscan.h |   15 +++++++++++++++
 mm/memcontrol.c               |    6 ++++++
 2 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index b97a3db..776f92b 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -213,6 +213,21 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_lru_isolate,
 
 );
 
+DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_memcg_isolate,
+
+	TP_PROTO(int order,
+		unsigned long nr_requested,
+		unsigned long nr_scanned,
+		unsigned long nr_taken,
+		unsigned long nr_lumpy_taken,
+		unsigned long nr_lumpy_dirty,
+		unsigned long nr_lumpy_failed,
+		int isolate_mode),
+
+	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode)
+
+);
+
 TRACE_EVENT(mm_vmscan_writepage,
 
 	TP_PROTO(struct page *page,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2b648ce..2600776 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -52,6 +52,8 @@
 
 #include <asm/uaccess.h>
 
+#include <trace/events/vmscan.h>
+
 struct cgroup_subsys mem_cgroup_subsys __read_mostly;
 #define MEM_CGROUP_RECLAIM_RETRIES	5
 struct mem_cgroup *root_mem_cgroup __read_mostly;
@@ -1011,6 +1013,10 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 	}
 
 	*scanned = scan;
+
+	trace_mm_vmscan_memcg_isolate(0, nr_to_scan, scan, nr_taken,
+				      0, 0, 0, mode);
+
 	return nr_taken;
 }
 
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
