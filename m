Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id A35DB6B0070
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 03:27:25 -0400 (EDT)
Received: by padj3 with SMTP id j3so61666419pad.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 00:27:25 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id cl12si25120823pdb.137.2015.06.02.00.27.22
        for <linux-mm@kvack.org>;
        Tue, 02 Jun 2015 00:27:24 -0700 (PDT)
From: Gioh Kim <gioh.kim@lge.com>
Subject: [RFC 3/4] mm/compaction: compaction calls generic migration
Date: Tue,  2 Jun 2015 16:27:43 +0900
Message-Id: <1433230065-3573-4-git-send-email-gioh.kim@lge.com>
In-Reply-To: <1433230065-3573-1-git-send-email-gioh.kim@lge.com>
References: <1433230065-3573-1-git-send-email-gioh.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jlayton@poochiereds.net, bfields@fieldses.org, akpm@linux-foundation.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, mst@redhat.com, kirill@shutemov.name, minchan@kernel.org, mgorman@suse.de
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, gunho.lee@lge.com, Gioh Kim <gioh.kim@lge.com>

Compaction calls interfaces of driver page migration
instead of calling balloon migration directly.

Signed-off-by: Gioh Kim <gioh.kim@lge.com>
---
 mm/compaction.c |  9 +++++----
 mm/migrate.c    | 22 +++++++++++++---------
 2 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 8c0d945..ca666e2 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -14,7 +14,7 @@
 #include <linux/backing-dev.h>
 #include <linux/sysctl.h>
 #include <linux/sysfs.h>
-#include <linux/balloon_compaction.h>
+#include <linux/compaction.h>
 #include <linux/page-isolation.h>
 #include <linux/kasan.h>
 #include "internal.h"
@@ -736,12 +736,13 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/*
 		 * Check may be lockless but that's ok as we recheck later.
-		 * It's possible to migrate LRU pages and balloon pages
+		 * It's possible to migrate LRU pages and migratable-pages
 		 * Skip any other type of page
 		 */
 		if (!PageLRU(page)) {
-			if (unlikely(balloon_page_movable(page))) {
-				if (balloon_page_isolate(page)) {
+			if (unlikely(driver_page_migratable(page))) {
+				if (page->mapping->a_ops->isolatepage(page,
+								isolate_mode)) {
 					/* Successfully isolated */
 					goto isolate_success;
 				}
diff --git a/mm/migrate.c b/mm/migrate.c
index 85e0426..649b1cd 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -35,7 +35,7 @@
 #include <linux/hugetlb.h>
 #include <linux/hugetlb_cgroup.h>
 #include <linux/gfp.h>
-#include <linux/balloon_compaction.h>
+#include <linux/compaction.h>
 #include <linux/mmu_notifier.h>
 
 #include <asm/tlbflush.h>
@@ -76,7 +76,8 @@ int migrate_prep_local(void)
  * from where they were once taken off for compaction/migration.
  *
  * This function shall be used whenever the isolated pageset has been
- * built from lru, balloon, hugetlbfs page. See isolate_migratepages_range()
+ * built from lru, migratable-page, hugetlbfs page.
+ * See isolate_migratepages_range()
  * and isolate_huge_page().
  */
 void putback_movable_pages(struct list_head *l)
@@ -92,8 +93,8 @@ void putback_movable_pages(struct list_head *l)
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		if (unlikely(isolated_balloon_page(page)))
-			balloon_page_putback(page);
+		if (unlikely(driver_page_migratable(page)))
+			page->mapping->a_ops->putbackpage(page);
 		else
 			putback_lru_page(page);
 	}
@@ -843,15 +844,18 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		}
 	}
 
-	if (unlikely(isolated_balloon_page(page))) {
+	if (unlikely(driver_page_migratable(page))) {
 		/*
-		 * A ballooned page does not need any special attention from
+		 * A migratable-page does not need any special attention from
 		 * physical to virtual reverse mapping procedures.
 		 * Skip any attempt to unmap PTEs or to remap swap cache,
 		 * in order to avoid burning cycles at rmap level, and perform
 		 * the page migration right away (proteced by page lock).
 		 */
-		rc = balloon_page_migrate(newpage, page, mode);
+		rc = page->mapping->a_ops->migratepage(page->mapping,
+						       newpage,
+						       page,
+						       mode);
 		goto out_unlock;
 	}
 
@@ -948,8 +952,8 @@ out:
 	if (rc != MIGRATEPAGE_SUCCESS && put_new_page) {
 		ClearPageSwapBacked(newpage);
 		put_new_page(newpage, private);
-	} else if (unlikely(__is_movable_balloon_page(newpage))) {
-		/* drop our reference, page already in the balloon */
+	} else if (unlikely(driver_page_migratable(newpage))) {
+		/* drop our reference */
 		put_page(newpage);
 	} else
 		putback_lru_page(newpage);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
