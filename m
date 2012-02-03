Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id A7A466B13FA
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 07:19:12 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LYT0046CGVRV450@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 03 Feb 2012 12:19:03 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LYT00F04GVRIL@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 03 Feb 2012 12:19:03 +0000 (GMT)
Date: Fri, 03 Feb 2012 13:18:54 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 11/15] mm: trigger page reclaim in alloc_contig_range() to
 stabilize watermarks
In-reply-to: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1328271538-14502-12-git-send-email-m.szyprowski@samsung.com>
References: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
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
 mm/page_alloc.c |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 983ccba..371a79f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5632,6 +5632,46 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
 	return ret > 0 ? 0 : ret;
 }
 
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
+	 * to stabilize at new watermark level.
+	 */
+	min_free_kbytes += count * PAGE_SIZE / 1024;
+	setup_per_zone_wmarks();
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
+	min_free_kbytes -= count * PAGE_SIZE / 1024;
+	setup_per_zone_wmarks();
+
+	return count;
+}
+
 /**
  * alloc_contig_range() -- tries to allocate given range of pages
  * @start:	start PFN to allocate
@@ -5730,6 +5770,13 @@ int alloc_contig_range(unsigned long start, unsigned long end,
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
