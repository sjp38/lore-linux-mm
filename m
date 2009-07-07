Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F3E2B6B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 05:03:46 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n679lHe1008336
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 7 Jul 2009 18:47:17 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 825E045DE60
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 18:47:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 645D845DE4D
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 18:47:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3DCBB1DB8037
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 18:47:17 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DD53D1DB8045
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 18:47:13 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC PATCH 1/2] vmscan don't isolate too many pages
In-Reply-To: <20090707182947.0C6D.A69D9226@jp.fujitsu.com>
References: <20090707182947.0C6D.A69D9226@jp.fujitsu.com>
Message-Id: <20090707184034.0C70.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  7 Jul 2009 18:47:13 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Subject: [PATCH] vmscan don't isolate too many pages

If the system have plenty threads or processes, concurrent reclaim can
isolate very much pages.

And if other processes isolate _all_ pages on lru, the reclaimer can't find
any reclaimable page and it makes accidental OOM.

The solusion is, we should restrict maximum number of isolated pages.
(this patch use inactive_page/2)


FAQ
-------
Q: Why do you compared zone accumulate pages, not individual zone pages?
A: If we check individual zone, #-of-reclaimer is restricted by smallest zone.
   it mean decreasing the performance of the system having small dma zone.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/page_alloc.c |   27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1721,6 +1721,28 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	return alloc_flags;
 }
 
+static bool too_many_isolated(struct zonelist *zonelist,
+			      enum zone_type high_zoneidx, nodemask_t *nodemask)
+{
+	unsigned long nr_inactive = 0;
+	unsigned long nr_isolated = 0;
+	struct zoneref *z;
+	struct zone *zone;
+
+	for_each_zone_zonelist_nodemask(zone, z, zonelist,
+					high_zoneidx, nodemask) {
+		if (!populated_zone(zone))
+			continue;
+
+		nr_inactive += zone_page_state(zone, NR_INACTIVE_ANON);
+		nr_inactive += zone_page_state(zone, NR_INACTIVE_FILE);
+		nr_isolated += zone_page_state(zone, NR_ISOLATED_ANON);
+		nr_isolated += zone_page_state(zone, NR_ISOLATED_FILE);
+	}
+
+	return nr_isolated > nr_inactive;
+}
+
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
@@ -1789,6 +1811,11 @@ rebalance:
 	if (p->flags & PF_MEMALLOC)
 		goto nopage;
 
+	if (too_many_isolated(gfp_mask, zonelist, high_zoneidx, nodemask)) {
+		schedule_timeout_uninterruptible(HZ/10);
+		goto restart;
+	}
+
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order,
 					zonelist, high_zoneidx,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
