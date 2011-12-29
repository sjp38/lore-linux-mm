Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id A76866B0099
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 07:39:17 -0500 (EST)
Received: from euspt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LWY007JHTTFCG@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 29 Dec 2011 12:39:15 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LWY00863TTFYC@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 29 Dec 2011 12:39:15 +0000 (GMT)
Date: Thu, 29 Dec 2011 13:39:02 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 01/11] mm: page_alloc: set_migratetype_isolate: drain PCP prior
 to isolating
In-reply-to: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1325162352-24709-2-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

From: Michal Nazarewicz <mina86@mina86.com>

When set_migratetype_isolate() sets pageblock's migrate type, it does
not change each page_private data.  This makes sense, as the function
has no way of knowing what kind of information page_private stores.

Unfortunately, if a page is on PCP list, it's page_private indicates
its migrate type.  This means, that if a page on PCP list gets
isolated, a call to free_pcppages_bulk() will assume it has the old
migrate type rather than MIGRATE_ISOLATE.  This means, that a page
which should be isolated, will end up on a free list of it's old
migrate type.

Coincidentally, at the very end, set_migratetype_isolate() calls
drain_all_pages() which leads to calling free_pcppages_bulk(), which
does the wrong thing.

To avoid this situation, this commit moves the draining prior to
setting pageblock's migratetype and moving pages from old free list to
MIGRATETYPE_ISOLATE's free list.

Because of spin locks this is a non-trivial change however as both
set_migratetype_isolate() and free_pcppages_bulk() grab zone->lock.
To solve this problem, this commit renames free_pcppages_bulk() to
__free_pcppages_bulk() and changes it so that it no longer grabs
zone->lock instead requiring caller to hold it.  This commit later
adds a __zone_drain_all_pages() function which works just like
drain_all_pages() expects that it drains only pages from a single zone
and assumes that caller holds zone->lock.

A side effect is that instead of draining pages from all zones,
set_migratetype_isolate() now drain only pages from zone pageblock it
operates on is in.

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 mm/page_alloc.c |   56 ++++++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 43 insertions(+), 13 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2b8ba3a..f88b320 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -590,15 +590,16 @@ static inline int free_pages_check(struct page *page)
  *
  * And clear the zone's pages_scanned counter, to hold off the "all pages are
  * pinned" detection logic.
+ *
+ * Caller must hold zone->lock.
  */
-static void free_pcppages_bulk(struct zone *zone, int count,
+static void __free_pcppages_bulk(struct zone *zone, int count,
 					struct per_cpu_pages *pcp)
 {
 	int migratetype = 0;
 	int batch_free = 0;
 	int to_free = count;
 
-	spin_lock(&zone->lock);
 	zone->all_unreclaimable = 0;
 	zone->pages_scanned = 0;
 
@@ -628,13 +629,13 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			page = list_entry(list->prev, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
+
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
 			__free_one_page(page, zone, 0, page_private(page));
 			trace_mm_page_pcpu_drain(page, 0, page_private(page));
 		} while (--to_free && --batch_free && !list_empty(list));
 	}
 	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
-	spin_unlock(&zone->lock);
 }
 
 static void free_one_page(struct zone *zone, struct page *page, int order,
@@ -1067,14 +1068,14 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 	unsigned long flags;
 	int to_drain;
 
-	local_irq_save(flags);
+	spin_lock_irqsave(&zone->lock, flags);
 	if (pcp->count >= pcp->batch)
 		to_drain = pcp->batch;
 	else
 		to_drain = pcp->count;
-	free_pcppages_bulk(zone, to_drain, pcp);
+	__free_pcppages_bulk(zone, to_drain, pcp);
 	pcp->count -= to_drain;
-	local_irq_restore(flags);
+	spin_unlock_irqrestore(&zone->lock, flags);
 }
 #endif
 
@@ -1099,7 +1100,9 @@ static void drain_pages(unsigned int cpu)
 
 		pcp = &pset->pcp;
 		if (pcp->count) {
-			free_pcppages_bulk(zone, pcp->count, pcp);
+			spin_lock(&zone->lock);
+			__free_pcppages_bulk(zone, pcp->count, pcp);
+			spin_unlock(&zone->lock);
 			pcp->count = 0;
 		}
 		local_irq_restore(flags);
@@ -1122,6 +1125,32 @@ void drain_all_pages(void)
 	on_each_cpu(drain_local_pages, NULL, 1);
 }
 
+/* Caller must hold zone->lock. */
+static void __zone_drain_local_pages(void *arg)
+{
+	struct per_cpu_pages *pcp;
+	struct zone *zone = arg;
+	unsigned long flags;
+
+	local_irq_save(flags);
+	pcp = &per_cpu_ptr(zone->pageset, smp_processor_id())->pcp;
+	if (pcp->count) {
+		/* Caller holds zone->lock, no need to grab it. */
+		__free_pcppages_bulk(zone, pcp->count, pcp);
+		pcp->count = 0;
+	}
+	local_irq_restore(flags);
+}
+
+/*
+ * Like drain_all_pages() but operates on a single zone.  Caller must
+ * hold zone->lock.
+ */
+static void __zone_drain_all_pages(struct zone *zone)
+{
+	on_each_cpu(__zone_drain_local_pages, zone, 1);
+}
+
 #ifdef CONFIG_HIBERNATION
 
 void mark_free_pages(struct zone *zone)
@@ -1202,7 +1231,9 @@ void free_hot_cold_page(struct page *page, int cold)
 		list_add(&page->lru, &pcp->lists[migratetype]);
 	pcp->count++;
 	if (pcp->count >= pcp->high) {
-		free_pcppages_bulk(zone, pcp->batch, pcp);
+		spin_lock(&zone->lock);
+		__free_pcppages_bulk(zone, pcp->batch, pcp);
+		spin_unlock(&zone->lock);
 		pcp->count -= pcp->batch;
 	}
 
@@ -3684,10 +3715,10 @@ static int __zone_pcp_update(void *data)
 		pset = per_cpu_ptr(zone->pageset, cpu);
 		pcp = &pset->pcp;
 
-		local_irq_save(flags);
-		free_pcppages_bulk(zone, pcp->count, pcp);
+		spin_lock_irqsave(&zone->lock, flags);
+		__free_pcppages_bulk(zone, pcp->count, pcp);
 		setup_pageset(pset, batch);
-		local_irq_restore(flags);
+		spin_unlock_irqrestore(&zone->lock, flags);
 	}
 	return 0;
 }
@@ -5657,13 +5688,12 @@ int set_migratetype_isolate(struct page *page)
 
 out:
 	if (!ret) {
+		__zone_drain_all_pages(zone);
 		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
 		move_freepages_block(zone, page, MIGRATE_ISOLATE);
 	}
 
 	spin_unlock_irqrestore(&zone->lock, flags);
-	if (!ret)
-		drain_all_pages();
 	return ret;
 }
 
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
