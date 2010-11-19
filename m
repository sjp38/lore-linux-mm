Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1A06A6B0092
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:58:31 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LC500JD931DUQ20@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 19 Nov 2010 15:58:26 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LC50012Y31C14@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 19 Nov 2010 15:58:25 +0000 (GMT)
Date: Fri, 19 Nov 2010 16:58:06 +0100
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [RFCv6 08/13] mm: move some functions to page_isolation.c
In-reply-to: <cover.1290172312.git.m.nazarewicz@samsung.com>
Message-id: 
 <1460279e4d5bc268225a9970402fe248baa0227c.1290172312.git.m.nazarewicz@samsung.com>
References: <cover.1290172312.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: mina86@mina86.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Bryan Huntsman <bryanh@codeaurora.org>, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Johan Mossberg <johan.xx.mossberg@stericsson.com>, Jonathan Corbet <corbet@lwn.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Marcus LORENTZON <marcus.xm.lorentzon@stericsson.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>, Russell King <linux@arm.linux.org.uk>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, dipankar@in.ibm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Memory hotplug is a logic for making pages unused in the specified range
of pfn. So, some of core logics can be used for other purpose as
allocating a very large contigous memory block.

This patch moves some functions from mm/memory_hotplug.c to
mm/page_isolation.c. This helps adding a function for large-alloc in
page_isolation.c with memory-unplug technique.

Changelog: 2010/10/26
 - adjusted to mmotm-1024 + Bob's 3 clean ups.
Changelog: 2010/10/21
 - adjusted to mmotm-1020

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 include/linux/page-isolation.h |    7 +++
 mm/memory_hotplug.c            |  108 --------------------------------------
 mm/page_isolation.c            |  111 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 118 insertions(+), 108 deletions(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 051c1b1..58cdbac 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -33,5 +33,12 @@ test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn);
 extern int set_migratetype_isolate(struct page *page);
 extern void unset_migratetype_isolate(struct page *page);
 
+/*
+ * For migration.
+ */
+
+int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn);
+unsigned long scan_lru_pages(unsigned long start, unsigned long end);
+int do_migrate_range(unsigned long start_pfn, unsigned long end_pfn);
 
 #endif
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9260314..23f4e36 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -617,114 +617,6 @@ int is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 }
 
 /*
- * Confirm all pages in a range [start, end) is belongs to the same zone.
- */
-static int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
-{
-	unsigned long pfn;
-	struct zone *zone = NULL;
-	struct page *page;
-	int i;
-	for (pfn = start_pfn;
-	     pfn < end_pfn;
-	     pfn += MAX_ORDER_NR_PAGES) {
-		i = 0;
-		/* This is just a CONFIG_HOLES_IN_ZONE check.*/
-		while ((i < MAX_ORDER_NR_PAGES) && !pfn_valid_within(pfn + i))
-			i++;
-		if (i == MAX_ORDER_NR_PAGES)
-			continue;
-		page = pfn_to_page(pfn + i);
-		if (zone && page_zone(page) != zone)
-			return 0;
-		zone = page_zone(page);
-	}
-	return 1;
-}
-
-/*
- * Scanning pfn is much easier than scanning lru list.
- * Scan pfn from start to end and Find LRU page.
- */
-static unsigned long scan_lru_pages(unsigned long start, unsigned long end)
-{
-	unsigned long pfn;
-	struct page *page;
-	for (pfn = start; pfn < end; pfn++) {
-		if (pfn_valid(pfn)) {
-			page = pfn_to_page(pfn);
-			if (PageLRU(page))
-				return pfn;
-		}
-	}
-	return 0;
-}
-
-static struct page *
-hotremove_migrate_alloc(struct page *page, unsigned long private, int **x)
-{
-	/* This should be improooooved!! */
-	return alloc_page(GFP_HIGHUSER_MOVABLE);
-}
-
-#define NR_OFFLINE_AT_ONCE_PAGES	(256)
-static int
-do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
-{
-	unsigned long pfn;
-	struct page *page;
-	int move_pages = NR_OFFLINE_AT_ONCE_PAGES;
-	int not_managed = 0;
-	int ret = 0;
-	LIST_HEAD(source);
-
-	for (pfn = start_pfn; pfn < end_pfn && move_pages > 0; pfn++) {
-		if (!pfn_valid(pfn))
-			continue;
-		page = pfn_to_page(pfn);
-		if (!page_count(page))
-			continue;
-		/*
-		 * We can skip free pages. And we can only deal with pages on
-		 * LRU.
-		 */
-		ret = isolate_lru_page(page);
-		if (!ret) { /* Success */
-			list_add_tail(&page->lru, &source);
-			move_pages--;
-			inc_zone_page_state(page, NR_ISOLATED_ANON +
-					    page_is_file_cache(page));
-
-		} else {
-#ifdef CONFIG_DEBUG_VM
-			printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
-			       pfn);
-			dump_page(page);
-#endif
-			/* Becasue we don't have big zone->lock. we should
-			   check this again here. */
-			if (page_count(page)) {
-				not_managed++;
-				ret = -EBUSY;
-				break;
-			}
-		}
-	}
-	if (!list_empty(&source)) {
-		if (not_managed) {
-			putback_lru_pages(&source);
-			goto out;
-		}
-		/* this function returns # of failed pages */
-		ret = migrate_pages(&source, hotremove_migrate_alloc, 0, 1);
-		if (ret)
-			putback_lru_pages(&source);
-	}
-out:
-	return ret;
-}
-
-/*
  * remove from free_area[] and mark all as Reserved.
  */
 static int
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 4ae42bb..077cf19 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -5,6 +5,9 @@
 #include <linux/mm.h>
 #include <linux/page-isolation.h>
 #include <linux/pageblock-flags.h>
+#include <linux/memcontrol.h>
+#include <linux/migrate.h>
+#include <linux/mm_inline.h>
 #include "internal.h"
 
 static inline struct page *
@@ -139,3 +142,111 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
 	spin_unlock_irqrestore(&zone->lock, flags);
 	return ret ? 0 : -EBUSY;
 }
+
+
+/*
+ * Confirm all pages in a range [start, end) is belongs to the same zone.
+ */
+int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
+{
+	unsigned long pfn;
+	struct zone *zone = NULL;
+	struct page *page;
+	int i;
+	for (pfn = start_pfn;
+	     pfn < end_pfn;
+	     pfn += MAX_ORDER_NR_PAGES) {
+		i = 0;
+		/* This is just a CONFIG_HOLES_IN_ZONE check.*/
+		while ((i < MAX_ORDER_NR_PAGES) && !pfn_valid_within(pfn + i))
+			i++;
+		if (i == MAX_ORDER_NR_PAGES)
+			continue;
+		page = pfn_to_page(pfn + i);
+		if (zone && page_zone(page) != zone)
+			return 0;
+		zone = page_zone(page);
+	}
+	return 1;
+}
+
+/*
+ * Scanning pfn is much easier than scanning lru list.
+ * Scan pfn from start to end and Find LRU page.
+ */
+unsigned long scan_lru_pages(unsigned long start, unsigned long end)
+{
+	unsigned long pfn;
+	struct page *page;
+	for (pfn = start; pfn < end; pfn++) {
+		if (pfn_valid(pfn)) {
+			page = pfn_to_page(pfn);
+			if (PageLRU(page))
+				return pfn;
+		}
+	}
+	return 0;
+}
+
+struct page *
+hotremove_migrate_alloc(struct page *page, unsigned long private, int **x)
+{
+	/* This should be improooooved!! */
+	return alloc_page(GFP_HIGHUSER_MOVABLE);
+}
+
+#define NR_OFFLINE_AT_ONCE_PAGES	(256)
+int do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
+{
+	unsigned long pfn;
+	struct page *page;
+	int move_pages = NR_OFFLINE_AT_ONCE_PAGES;
+	int not_managed = 0;
+	int ret = 0;
+	LIST_HEAD(source);
+
+	for (pfn = start_pfn; pfn < end_pfn && move_pages > 0; pfn++) {
+		if (!pfn_valid(pfn))
+			continue;
+		page = pfn_to_page(pfn);
+		if (!page_count(page))
+			continue;
+		/*
+		 * We can skip free pages. And we can only deal with pages on
+		 * LRU.
+		 */
+		ret = isolate_lru_page(page);
+		if (!ret) { /* Success */
+			list_add_tail(&page->lru, &source);
+			move_pages--;
+			inc_zone_page_state(page, NR_ISOLATED_ANON +
+					    page_is_file_cache(page));
+
+		} else {
+#ifdef CONFIG_DEBUG_VM
+			printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
+			       pfn);
+			dump_page(page);
+#endif
+			/* Because we don't have big zone->lock. we should
+			   check this again here. */
+			if (page_count(page)) {
+				not_managed++;
+				ret = -EBUSY;
+				break;
+			}
+		}
+	}
+	if (!list_empty(&source)) {
+		if (not_managed) {
+			putback_lru_pages(&source);
+			goto out;
+		}
+		/* this function returns # of failed pages */
+		ret = migrate_pages(&source, hotremove_migrate_alloc, 0, 1);
+		if (ret)
+			putback_lru_pages(&source);
+	}
+out:
+	return ret;
+}
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
