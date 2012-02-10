Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id F39796B13FD
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 12:32:46 -0500 (EST)
Received: from euspt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LZ600GQXU2B42@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 10 Feb 2012 17:32:36 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LZ6006CGU2BXO@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 10 Feb 2012 17:32:35 +0000 (GMT)
Date: Fri, 10 Feb 2012 18:32:27 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv21 12/16] mm: trigger page reclaim in alloc_contig_range() to
 stabilise watermarks
In-reply-to: <1328895151-5196-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1328895151-5196-13-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1328895151-5196-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Rob Clark <rob.clark@linaro.org>, Ohad Ben-Cohen <ohad@wizery.com>

alloc_contig_range() performs memory allocation so it also should keep
track on keeping the correct level of memory watermarks. This commit adds
a call to *_slowpath style reclaim to grab enough pages to make sure that
the final collection of contiguous pages from freelists will not starve
the system.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
CC: Michal Nazarewicz <mina86@mina86.com>
Tested-by: Rob Clark <rob.clark@linaro.org>
Tested-by: Ohad Ben-Cohen <ohad@wizery.com>
Tested-by: Benjamin Gaignard <benjamin.gaignard@linaro.org>
---
 include/linux/mmzone.h |    9 +++++++
 mm/page_alloc.c        |   62 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 71 insertions(+), 0 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 82f4fa5..6a6c2cc 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -63,8 +63,10 @@ enum {
 
 #ifdef CONFIG_CMA
 #  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
+#  define cma_wmark_pages(zone)	zone->min_cma_pages
 #else
 #  define is_migrate_cma(migratetype) false
+#  define cma_wmark_pages(zone) 0
 #endif
 
 #define for_each_migratetype_order(order, type) \
@@ -371,6 +373,13 @@ struct zone {
 	/* see spanned/present_pages for more description */
 	seqlock_t		span_seqlock;
 #endif
+#ifdef CONFIG_CMA
+	/*
+	 * CMA needs to increase watermark levels during the allocation
+	 * process to make sure that the system is not starved.
+	 */
+	unsigned long		min_cma_pages;
+#endif
 	struct free_area	free_area[MAX_ORDER];
 
 #ifndef CONFIG_SPARSEMEM
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 793c4e4..2fedd36 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5035,6 +5035,11 @@ static void __setup_per_zone_wmarks(void)
 
 		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + (tmp >> 2);
 		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + (tmp >> 1);
+
+		zone->watermark[WMARK_MIN] += cma_wmark_pages(zone);
+		zone->watermark[WMARK_LOW] += cma_wmark_pages(zone);
+		zone->watermark[WMARK_HIGH] += cma_wmark_pages(zone);
+
 		setup_zone_migrate_reserve(zone);
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
@@ -5637,6 +5642,56 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
 	return ret > 0 ? 0 : ret;
 }
 
+/*
+ * Update zone's cma pages counter used for watermark level calculation.
+ */
+static inline void __update_cma_wmark_pages(struct zone *zone, int count)
+{
+	unsigned long flags;
+	spin_lock_irqsave(&zone->lock, flags);
+	zone->min_cma_pages += count;
+	spin_unlock_irqrestore(&zone->lock, flags);
+	setup_per_zone_wmarks();
+}
+
+/*
+ * Trigger memory pressure bump to reclaim some pages in order to be able to
+ * allocate 'count' pages in single page units. Does similar work as
+ *__alloc_pages_slowpath() function.
+ */
+static int __reclaim_pages(struct zone *zone, gfp_t gfp_mask, int count)
+{
+	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
+	struct zonelist *zonelist = node_zonelist(0, gfp_mask);
+	int did_some_progress = 0;
+	int order = 1;
+	unsigned long watermark;
+
+	/*
+	 * Increase level of watermarks to force kswapd do his job
+	 * to stabilise at new watermark level.
+	 */
+	__modify_min_cma_pages(zone, count);
+
+	/* Obey watermarks as if the page was being allocated */
+	watermark = low_wmark_pages(zone) + count;
+	while (!zone_watermark_ok(zone, 0, watermark, 0, 0)) {
+		wake_all_kswapd(order, zonelist, high_zoneidx, zone_idx(zone));
+
+		did_some_progress = __perform_reclaim(gfp_mask, order, zonelist,
+						      NULL);
+		if (!did_some_progress) {
+			/* Exhausted what can be done so it's blamo time */
+			out_of_memory(zonelist, gfp_mask, order, NULL);
+		}
+	}
+
+	/* Restore original watermark levels. */
+	__modify_min_cma_pages(zone, -count);
+
+	return count;
+}
+
 /**
  * alloc_contig_range() -- tries to allocate given range of pages
  * @start:	start PFN to allocate
@@ -5735,6 +5790,13 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 		goto done;
 	}
 
+	/*
+	 * Reclaim enough pages to make sure that contiguous allocation
+	 * will not starve the system.
+	 */
+	__reclaim_pages(zone, GFP_HIGHUSER_MOVABLE, end-start);
+
+	/* Grab isolated pages from freelists. */
 	outer_end = isolate_freepages_range(outer_start, end);
 	if (!outer_end) {
 		ret = -EBUSY;
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
