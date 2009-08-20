Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id F23526B004F
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 23:17:25 -0400 (EDT)
Date: Thu, 20 Aug 2009 11:17:23 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH] mm: remove unnecessary loop inside
	shrink_inactive_list()
Message-ID: <20090820031723.GA25673@localhost>
References: <20090820024929.GA19793@localhost> <20090820025209.GA24387@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090820025209.GA24387@localhost>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

shrink_inactive_list() won't be called to scan too much pages
(unless in hibernation code which is fine) or too few pages (ie.
batching is taken care of by the callers).  So we can just remove the
big loop and isolate the exact number of pages requested.

Just a RFC, and a scratch patch to show the basic idea.
Please kindly NAK quick if you don't like it ;)

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmscan.c |   32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

--- linux.orig/mm/vmscan.c	2009-08-20 10:16:18.000000000 +0800
+++ linux/mm/vmscan.c	2009-08-20 10:24:34.000000000 +0800
@@ -1032,16 +1032,22 @@ int isolate_lru_page(struct page *page)
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
  */
-static unsigned long shrink_inactive_list(unsigned long max_scan,
+static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
 			struct zone *zone, struct scan_control *sc,
 			int priority, int file)
 {
 	LIST_HEAD(page_list);
 	struct pagevec pvec;
-	unsigned long nr_scanned = 0;
-	unsigned long nr_reclaimed = 0;
+	unsigned long nr_reclaimed;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
-	int lumpy_reclaim = 0;
+	int lumpy_reclaim;
+	struct page *page;
+	unsigned long nr_taken;
+	unsigned long nr_scan;
+	unsigned long nr_freed;
+	unsigned long nr_active;
+	unsigned int count[NR_LRU_LISTS] = { 0, };
+	int mode;
 
 	/*
 	 * If we need a large contiguous chunk of memory, or have
@@ -1054,21 +1060,17 @@ static unsigned long shrink_inactive_lis
 		lumpy_reclaim = 1;
 	else if (sc->order && priority < DEF_PRIORITY - 2)
 		lumpy_reclaim = 1;
+	else
+		lumpy_reclaim = 0;
+
+	mode = lumpy_reclaim ? ISOLATE_BOTH : ISOLATE_INACTIVE;
 
 	pagevec_init(&pvec, 1);
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
-	do {
-		struct page *page;
-		unsigned long nr_taken;
-		unsigned long nr_scan;
-		unsigned long nr_freed;
-		unsigned long nr_active;
-		unsigned int count[NR_LRU_LISTS] = { 0, };
-		int mode = lumpy_reclaim ? ISOLATE_BOTH : ISOLATE_INACTIVE;
 
-		nr_taken = sc->isolate_pages(sc->swap_cluster_max,
+		nr_taken = sc->isolate_pages(nr_to_scan,
 			     &page_list, &nr_scan, sc->order, mode,
 				zone, sc->mem_cgroup, 0, file);
 		nr_active = clear_active_flags(&page_list, count);
@@ -1093,7 +1095,6 @@ static unsigned long shrink_inactive_lis
 
 		spin_unlock_irq(&zone->lru_lock);
 
-		nr_scanned += nr_scan;
 		nr_freed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
 
 		/*
@@ -1117,7 +1118,7 @@ static unsigned long shrink_inactive_lis
 							PAGEOUT_IO_SYNC);
 		}
 
-		nr_reclaimed += nr_freed;
+		nr_reclaimed = nr_freed;
 		local_irq_disable();
 		if (current_is_kswapd()) {
 			__count_zone_vm_events(PGSCAN_KSWAPD, zone, nr_scan);
@@ -1158,7 +1159,6 @@ static unsigned long shrink_inactive_lis
 				spin_lock_irq(&zone->lru_lock);
 			}
 		}
-  	} while (nr_scanned < max_scan);
 	spin_unlock(&zone->lru_lock);
 done:
 	local_irq_enable();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
