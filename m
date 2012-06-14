Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 532846B0070
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 12:16:26 -0400 (EDT)
Received: by ggm4 with SMTP id 4so1943590ggm.14
        for <linux-mm@kvack.org>; Thu, 14 Jun 2012 09:16:25 -0700 (PDT)
From: kosaki.motohiro@gmail.com
Subject: [PATCH] mm: clear pages_scanned only if draining a pcp adds pages to the buddy allocator again
Date: Thu, 14 Jun 2012 12:16:10 -0400
Message-Id: <1339690570-7471-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

commit 2ff754fa8f (mm: clear pages_scanned only if draining a pcp adds pages
to the buddy allocator again) fixed one free_pcppages_bulk() misuse. But two
another miuse still exist.

This patch fixes it.

Cc: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/page_alloc.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5716b00..4e7059d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1157,8 +1157,10 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 		to_drain = pcp->batch;
 	else
 		to_drain = pcp->count;
-	free_pcppages_bulk(zone, to_drain, pcp);
-	pcp->count -= to_drain;
+	if (to_drain > 0) {
+		free_pcppages_bulk(zone, to_drain, pcp);
+		pcp->count -= to_drain;
+	}
 	local_irq_restore(flags);
 }
 #endif
@@ -3914,7 +3916,8 @@ static int __zone_pcp_update(void *data)
 		pcp = &pset->pcp;
 
 		local_irq_save(flags);
-		free_pcppages_bulk(zone, pcp->count, pcp);
+		if (pcp->count > 0)
+			free_pcppages_bulk(zone, pcp->count, pcp);
 		setup_pageset(pset, batch);
 		local_irq_restore(flags);
 	}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
