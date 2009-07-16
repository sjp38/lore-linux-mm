Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 719056B005D
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 20:53:41 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6G0riBb016482
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Jul 2009 09:53:45 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C98D145DE4C
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 09:53:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 97E4145DE55
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 09:53:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6353E1DB8040
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 09:53:44 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F3CFC1DB8042
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 09:53:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/3] mm: shrink_inactive_lis() nr_scan accounting fix fix
In-Reply-To: <20090716094619.9D07.A69D9226@jp.fujitsu.com>
References: <20090716094619.9D07.A69D9226@jp.fujitsu.com>
Message-Id: <20090716095241.9D0D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Jul 2009 09:53:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Subject: [PATCH] mm: shrink_inactive_lis() nr_scan accounting fix fix

If sc->isolate_pages() return 0, we don't need to call shrink_page_list().
In past days, shrink_inactive_list() handled it properly.

But commit fb8d14e1 (three years ago commit!) breaked it. current shrink_inactive_list()
always call shrink_page_list() although isolate_pages() return 0.

This patch restore proper return value check.


Requirements:
  o "nr_taken == 0" condition should stay before calling shrink_page_list().
  o "nr_taken == 0" condition should stay after nr_scan related statistics
     modification.


Cc: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   30 ++++++++++++++++++------------
 1 file changed, 18 insertions(+), 12 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1071,6 +1071,20 @@ static unsigned long shrink_inactive_lis
 		nr_taken = sc->isolate_pages(sc->swap_cluster_max,
 			     &page_list, &nr_scan, sc->order, mode,
 				zone, sc->mem_cgroup, 0, file);
+
+		if (scanning_global_lru(sc)) {
+			zone->pages_scanned += nr_scan;
+			if (current_is_kswapd())
+				__count_zone_vm_events(PGSCAN_KSWAPD, zone,
+						       nr_scan);
+			else
+				__count_zone_vm_events(PGSCAN_DIRECT, zone,
+						       nr_scan);
+		}
+
+		if (nr_taken == 0)
+			goto done;
+
 		nr_active = clear_active_flags(&page_list, count);
 		__count_vm_events(PGDEACTIVATE, nr_active);
 
@@ -1083,8 +1097,6 @@ static unsigned long shrink_inactive_lis
 		__mod_zone_page_state(zone, NR_INACTIVE_ANON,
 						-count[LRU_INACTIVE_ANON]);
 
-		if (scanning_global_lru(sc))
-			zone->pages_scanned += nr_scan;
 
 		reclaim_stat->recent_scanned[0] += count[LRU_INACTIVE_ANON];
 		reclaim_stat->recent_scanned[0] += count[LRU_ACTIVE_ANON];
@@ -1118,18 +1130,12 @@ static unsigned long shrink_inactive_lis
 		}
 
 		nr_reclaimed += nr_freed;
+
 		local_irq_disable();
-		if (current_is_kswapd()) {
-			__count_zone_vm_events(PGSCAN_KSWAPD, zone, nr_scan);
+		if (current_is_kswapd())
 			__count_vm_events(KSWAPD_STEAL, nr_freed);
-		} else if (scanning_global_lru(sc))
-			__count_zone_vm_events(PGSCAN_DIRECT, zone, nr_scan);
-
 		__count_zone_vm_events(PGSTEAL, zone, nr_freed);
 
-		if (nr_taken == 0)
-			goto done;
-
 		spin_lock(&zone->lru_lock);
 		/*
 		 * Put back any unfreeable pages.
@@ -1159,9 +1165,9 @@ static unsigned long shrink_inactive_lis
 			}
 		}
   	} while (nr_scanned < max_scan);
-	spin_unlock(&zone->lru_lock);
+
 done:
-	local_irq_enable();
+	spin_unlock_irq(&zone->lru_lock);
 	pagevec_release(&pvec);
 	return nr_reclaimed;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
