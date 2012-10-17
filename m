Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 3D8496B005A
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 08:03:20 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [PATCH v2 1/5] memory-hotplug: skip HWPoisoned page when offlining pages
Date: Wed, 17 Oct 2012 20:08:51 +0800
Message-Id: <1350475735-26136-2-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1350475735-26136-1-git-send-email-wency@cn.fujitsu.com>
References: <1350475735-26136-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>, Christoph Lameter <cl@linux.com>

From: Wen Congyang <wency@cn.fujitsu.com>

hwpoisoned may be set when we offline a page by the sysfs interface
/sys/devices/system/memory/soft_offline_page or
/sys/devices/system/memory/hard_offline_page. If we don't clear
this flag when onlining pages, this page can't be freed, and will
not in free list. So we can't offline these pages again. So we
should skip such page when offlining pages.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 include/linux/page-isolation.h |   10 ++++++----
 mm/memory-failure.c            |    2 +-
 mm/memory_hotplug.c            |    4 ++--
 mm/page_alloc.c                |   27 +++++++++++++++++++++++----
 mm/page_isolation.c            |   27 ++++++++++++++++++++-------
 5 files changed, 52 insertions(+), 18 deletions(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 76a9539..a92061e 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -2,7 +2,8 @@
 #define __LINUX_PAGEISOLATION_H
 
 
-bool has_unmovable_pages(struct zone *zone, struct page *page, int count);
+bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
+			 bool skip_hwpoisoned_pages);
 void set_pageblock_migratetype(struct page *page, int migratetype);
 int move_freepages_block(struct zone *zone, struct page *page,
 				int migratetype);
@@ -21,7 +22,7 @@ int move_freepages(struct zone *zone,
  */
 int
 start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
-			 unsigned migratetype);
+			 unsigned migratetype, bool skip_hwpoisoned_pages);
 
 /*
  * Changes MIGRATE_ISOLATE to MIGRATE_MOVABLE.
@@ -34,12 +35,13 @@ undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 /*
  * Test all pages in [start_pfn, end_pfn) are isolated or not.
  */
-int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn);
+int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
+			bool skip_hwpoisoned_pages);
 
 /*
  * Internal functions. Changes pageblock's migrate type.
  */
-int set_migratetype_isolate(struct page *page);
+int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages);
 void unset_migratetype_isolate(struct page *page, unsigned migratetype);
 struct page *alloc_migrate_target(struct page *page, unsigned long private,
 				int **resultp);
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 6c5899b..1abffee 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1385,7 +1385,7 @@ static int get_any_page(struct page *p, unsigned long pfn, int flags)
 	 * Isolate the page, so that it doesn't get reallocated if it
 	 * was free.
 	 */
-	set_migratetype_isolate(p);
+	set_migratetype_isolate(p, true);
 	/*
 	 * When the target page is a free hugepage, just remove it
 	 * from free hugepage list.
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 56b758a..ec899a2 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -854,7 +854,7 @@ check_pages_isolated_cb(unsigned long start_pfn, unsigned long nr_pages,
 {
 	int ret;
 	long offlined = *(long *)data;
-	ret = test_pages_isolated(start_pfn, start_pfn + nr_pages);
+	ret = test_pages_isolated(start_pfn, start_pfn + nr_pages, true);
 	offlined = nr_pages;
 	if (!ret)
 		*(long *)data += offlined;
@@ -901,7 +901,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	nr_pages = end_pfn - start_pfn;
 
 	/* set above range as isolated */
-	ret = start_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
+	ret = start_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE, true);
 	if (ret)
 		goto out;
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bb90971..e33d0fb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5575,7 +5575,8 @@ void set_pageblock_flags_group(struct page *page, unsigned long flags,
  * MIGRATE_MOVABLE block might include unmovable pages. It means you can't
  * expect this function should be exact.
  */
-bool has_unmovable_pages(struct zone *zone, struct page *page, int count)
+bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
+			 bool skip_hwpoisoned_pages)
 {
 	unsigned long pfn, iter, found;
 	int mt;
@@ -5610,6 +5611,13 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count)
 			continue;
 		}
 
+		/*
+		 * The HWPoisoned page may be not in buddy system, and
+		 * page_count() is not 0.
+		 */
+		if (skip_hwpoisoned_pages && PageHWPoison(page))
+			continue;
+
 		if (!PageLRU(page))
 			found++;
 		/*
@@ -5652,7 +5660,7 @@ bool is_pageblock_removable_nolock(struct page *page)
 			zone->zone_start_pfn + zone->spanned_pages <= pfn)
 		return false;
 
-	return !has_unmovable_pages(zone, page, 0);
+	return !has_unmovable_pages(zone, page, 0, true);
 }
 
 #ifdef CONFIG_CMA
@@ -5823,7 +5831,8 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	 */
 
 	ret = start_isolate_page_range(pfn_max_align_down(start),
-				       pfn_max_align_up(end), migratetype);
+				       pfn_max_align_up(end), migratetype,
+				       false);
 	if (ret)
 		goto done;
 
@@ -5862,7 +5871,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	}
 
 	/* Make sure the range is really isolated. */
-	if (test_pages_isolated(outer_start, end)) {
+	if (test_pages_isolated(outer_start, end, false)) {
 		pr_warn("alloc_contig_range test_pages_isolated(%lx, %lx) failed\n",
 		       outer_start, end);
 		ret = -EBUSY;
@@ -5977,6 +5986,16 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 			continue;
 		}
 		page = pfn_to_page(pfn);
+		/*
+		 * The HWPoisoned page may be not in buddy system, and
+		 * page_count() is not 0.
+		 */
+		if (unlikely(!PageBuddy(page) && PageHWPoison(page))) {
+			pfn++;
+			SetPageReserved(page);
+			continue;
+		}
+
 		BUG_ON(page_count(page));
 		BUG_ON(!PageBuddy(page));
 		order = page_order(page);
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index f2f5b48..9d2264e 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -30,7 +30,7 @@ static void restore_pageblock_isolate(struct page *page, int migratetype)
 	zone->nr_pageblock_isolate--;
 }
 
-int set_migratetype_isolate(struct page *page)
+int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
 {
 	struct zone *zone;
 	unsigned long flags, pfn;
@@ -66,7 +66,8 @@ int set_migratetype_isolate(struct page *page)
 	 * FIXME: Now, memory hotplug doesn't call shrink_slab() by itself.
 	 * We just check MOVABLE pages.
 	 */
-	if (!has_unmovable_pages(zone, page, arg.pages_found))
+	if (!has_unmovable_pages(zone, page, arg.pages_found,
+				 skip_hwpoisoned_pages))
 		ret = 0;
 
 	/*
@@ -134,7 +135,7 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
  * Returns 0 on success and -EBUSY if any part of range cannot be isolated.
  */
 int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
-			     unsigned migratetype)
+			     unsigned migratetype, bool skip_hwpoisoned_pages)
 {
 	unsigned long pfn;
 	unsigned long undo_pfn;
@@ -147,7 +148,8 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 	     pfn < end_pfn;
 	     pfn += pageblock_nr_pages) {
 		page = __first_valid_page(pfn, pageblock_nr_pages);
-		if (page && set_migratetype_isolate(page)) {
+		if (page &&
+		    set_migratetype_isolate(page, skip_hwpoisoned_pages)) {
 			undo_pfn = pfn;
 			goto undo;
 		}
@@ -190,7 +192,8 @@ int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
  * Returns 1 if all pages in the range are isolated.
  */
 static int
-__test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn)
+__test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
+				  bool skip_hwpoisoned_pages)
 {
 	struct page *page;
 
@@ -220,6 +223,14 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn)
 		else if (page_count(page) == 0 &&
 			get_freepage_migratetype(page) == MIGRATE_ISOLATE)
 			pfn += 1;
+		else if (skip_hwpoisoned_pages && PageHWPoison(page)) {
+			/*
+			 * The HWPoisoned page may be not in buddy
+			 * system, and page_count() is not 0.
+			 */
+			pfn++;
+			continue;
+		}
 		else
 			break;
 	}
@@ -228,7 +239,8 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn)
 	return 1;
 }
 
-int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
+int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
+			bool skip_hwpoisoned_pages)
 {
 	unsigned long pfn, flags;
 	struct page *page;
@@ -251,7 +263,8 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
 	/* Check all pages are free or Marked as ISOLATED */
 	zone = page_zone(page);
 	spin_lock_irqsave(&zone->lock, flags);
-	ret = __test_page_isolated_in_pageblock(start_pfn, end_pfn);
+	ret = __test_page_isolated_in_pageblock(start_pfn, end_pfn,
+						skip_hwpoisoned_pages);
 	spin_unlock_irqrestore(&zone->lock, flags);
 	return ret ? 0 : -EBUSY;
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
