Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9B15F6B009D
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 11:43:14 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LV800EGO6FY4J70@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 25 Nov 2011 16:43:10 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LV800AY96FXUT@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 25 Nov 2011 16:43:10 +0000 (GMT)
Date: Fri, 25 Nov 2011 17:43:07 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH] mm: cma: hack/workaround for some allocation issues
In-reply-to: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1322239387-31394-1-git-send-email-m.szyprowski@samsung.com>
References: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

This is a quick and dirty patch and hack to solve some memory allocation
issues that appeared at CMA v17 after switching migration code from
hotplug to memory compaction. Especially the issue with watermark
adjustment need a real fix instead of disabling the code.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---

Hello,

This patch fixes the issues that have been reported recently. It should
be considered only as a temporary solution until a new version of CMA
patches is ready.

Best regards
--
Marek Szyprowski
Samsung Poland R&D Center

---
 mm/compaction.c |    5 ++++-
 mm/page_alloc.c |   12 +++++++++---
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 3e07341..41976f8 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -79,8 +79,9 @@ isolate_freepages_range(struct zone *zone,
 skip:
 			if (freelist)
 				goto next;
+failed:
 			for (; start < pfn; ++start)
-				__free_page(pfn_to_page(pfn));
+				__free_page(pfn_to_page(start));
 			return 0;
 		}
 
@@ -91,6 +92,8 @@ skip:
 			struct page *p = page;
 			for (i = isolated; i; --i, ++p)
 				list_add(&p->lru, freelist);
+		} else if (!isolated) {
+			goto failed;
 		}
 
 next:
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 714b1c1..b4a46c7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1303,12 +1303,12 @@ int split_free_page(struct page *page)
 
 	zone = page_zone(page);
 	order = page_order(page);
-
+#if 0
 	/* Obey watermarks as if the page was being allocated */
 	watermark = low_wmark_pages(zone) + (1 << order);
 	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
 		return 0;
-
+#endif
 	/* Remove page from free list */
 	list_del(&page->lru);
 	zone->free_area[order].nr_free--;
@@ -5734,6 +5734,12 @@ static unsigned long pfn_align_to_maxpage_up(unsigned long pfn)
 	return ALIGN(pfn, MAX_ORDER_NR_PAGES);
 }
 
+static struct page *
+cma_migrate_alloc(struct page *page, unsigned long private, int **x)
+{
+	return alloc_page(GFP_HIGHUSER_MOVABLE);
+}
+
 static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
 {
 	/* This function is based on compact_zone() from compaction.c. */
@@ -5801,7 +5807,7 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
 		}
 
 		/* Try to migrate. */
-		ret = migrate_pages(&cc.migratepages, compaction_alloc,
+		ret = migrate_pages(&cc.migratepages, cma_migrate_alloc,
 				    (unsigned long)&cc, false, cc.sync);
 
 		/* Migrated all of them? Great! */
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
