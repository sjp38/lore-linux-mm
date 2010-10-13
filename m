Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D61D26B00DF
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 23:21:12 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9D3L9j8024901
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 13 Oct 2010 12:21:09 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C92645DE4F
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 12:21:09 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FABA45DD71
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 12:21:09 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 04AB61DB8012
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 12:21:09 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C5FDE38003
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 12:21:08 +0900 (JST)
Date: Wed, 13 Oct 2010 12:15:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 1/3] contigous big page allocator
Message-Id: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>


No big change since the previous version but divided into 3 patches.
This patch is based onto mmotm-1008 and just works, IOW, mot tested in
very-bad-situation.

What this wants to do: 
  allocates a contiguous chunk of pages larger than MAX_ORDER.
  for device drivers (camera? etc..)
  My intention is not for allocating HUGEPAGE(> MAX_ORDER).
  
What this does:
  allocates a contiguous chunk of page with page migration,
  based on memory hotplug codes. (memory unplug is for isolating
  a chunk of page from buddy allocator.)

Consideration:
  Maybe more codes can be shared with other functions
  (memory hotplug, compaction..)

Status:
  Maybe still needs more updates, works on small test.
  [1/3] ... move some codes from memory hotplug. (no functional changes)
  [2/3] ... a code for searching contiguous pages.
  [3/3] ... a code for allocating contig memory.

Thanks,
-Kame
==

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Memory hotplug is a logic for making pages unused in the specified range
of pfn. So, some of core logics can be used for other purpose as
allocating a very large contigous memory block.

This patch moves some functions from mm/memory_hotplug.c to
mm/page_isolation.c. This helps adding a function for large-alloc in
page_isolation.c with memory-unplug technique.


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/page-isolation.h |    7 ++
 mm/memory_hotplug.c            |  109 ---------------------------------------
 mm/page_isolation.c            |  114 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 121 insertions(+), 109 deletions(-)

Index: mmotm-1008/include/linux/page-isolation.h
===================================================================
--- mmotm-1008.orig/include/linux/page-isolation.h
+++ mmotm-1008/include/linux/page-isolation.h
@@ -33,5 +33,12 @@ test_pages_isolated(unsigned long start_
 extern int set_migratetype_isolate(struct page *page);
 extern void unset_migratetype_isolate(struct page *page);
 
+/*
+ * For migration.
+ */
+
+int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn);
+int scan_lru_pages(unsigned long start, unsigned long end);
+int do_migrate_range(unsigned long start_pfn, unsigned long end_pfn);
 
 #endif
Index: mmotm-1008/mm/memory_hotplug.c
===================================================================
--- mmotm-1008.orig/mm/memory_hotplug.c
+++ mmotm-1008/mm/memory_hotplug.c
@@ -617,115 +617,6 @@ int is_mem_section_removable(unsigned lo
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
-int scan_lru_pages(unsigned long start, unsigned long end)
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
-			/* Becasue we don't have big zone->lock. we should
-			   check this again here. */
-			if (page_count(page))
-				not_managed++;
-#ifdef CONFIG_DEBUG_VM
-			printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
-			       pfn);
-			dump_page(page);
-#endif
-		}
-	}
-	ret = -EBUSY;
-	if (not_managed) {
-		if (!list_empty(&source))
-			putback_lru_pages(&source);
-		goto out;
-	}
-	ret = 0;
-	if (list_empty(&source))
-		goto out;
-	/* this function returns # of failed pages */
-	ret = migrate_pages(&source, hotremove_migrate_alloc, 0, 1);
-	if (ret)
-		putback_lru_pages(&source);
-
-out:
-	return ret;
-}
-
-/*
  * remove from free_area[] and mark all as Reserved.
  */
 static int
Index: mmotm-1008/mm/page_isolation.c
===================================================================
--- mmotm-1008.orig/mm/page_isolation.c
+++ mmotm-1008/mm/page_isolation.c
@@ -1,10 +1,15 @@
 /*
  * linux/mm/page_isolation.c
+ * Contains a function for page migration based on page isolation by
+ * mirate-flag. Used in memory hotplug.
  */
 
 #include <linux/mm.h>
 #include <linux/page-isolation.h>
 #include <linux/pageblock-flags.h>
+#include <linux/memcontrol.h>
+#include <linux/migrate.h>
+#include <linux/mm_inline.h>
 #include "internal.h"
 
 static inline struct page *
@@ -140,3 +145,112 @@ int test_pages_isolated(unsigned long st
 	spin_unlock_irqrestore(&zone->lock, flags);
 	return ret ? 0 : -EBUSY;
 }
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
+int scan_lru_pages(unsigned long start, unsigned long end)
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
+static struct page *
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
+			/* Becasue we don't have big zone->lock. we should
+			   check this again here. */
+			if (page_count(page))
+				not_managed++;
+#ifdef CONFIG_DEBUG_VM
+			printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
+			       pfn);
+			dump_page(page);
+#endif
+		}
+	}
+	ret = -EBUSY;
+	if (not_managed) {
+		if (!list_empty(&source))
+			putback_lru_pages(&source);
+		goto out;
+	}
+	ret = 0;
+	if (list_empty(&source))
+		goto out;
+	/* this function returns # of failed pages */
+	ret = migrate_pages(&source, hotremove_migrate_alloc, 0, 1);
+	if (ret)
+		putback_lru_pages(&source);
+
+out:
+	return ret;
+}
+




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
