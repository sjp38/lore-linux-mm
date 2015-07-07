Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id B499A9003C7
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 00:34:57 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so106349148pac.2
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 21:34:57 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id zq10si32481150pac.96.2015.07.06.21.34.55
        for <linux-mm@kvack.org>;
        Mon, 06 Jul 2015 21:34:56 -0700 (PDT)
From: Gioh Kim <gioh.kim@lge.com>
Subject: [RFCv3 4/5] mm: call generic migration callbacks
Date: Tue,  7 Jul 2015 13:36:24 +0900
Message-Id: <1436243785-24105-5-git-send-email-gioh.kim@lge.com>
In-Reply-To: <1436243785-24105-1-git-send-email-gioh.kim@lge.com>
References: <1436243785-24105-1-git-send-email-gioh.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jlayton@poochiereds.net, bfields@fieldses.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, viro@zeniv.linux.org.uk, mst@redhat.com, koct9i@gmail.com, minchan@kernel.org, aquini@redhat.com, linux-fsdevel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: gunho.lee@lge.com, akpm@linux-foundation.org, Gioh Kim <gurugio@hanmail.net>, Gioh Kim <gioh.kim@lge.com>

From: Gioh Kim <gurugio@hanmail.net>

Compaction calls interfaces of mobile page migration
instead of calling balloon migration directly.

Signed-off-by: Gioh Kim <gioh.kim@lge.com>
---
 mm/compaction.c |  8 ++++----
 mm/migrate.c    | 19 ++++++++++---------
 2 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 81bafaf..60e4cbb 100644
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
@@ -714,12 +714,12 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/*
 		 * Check may be lockless but that's ok as we recheck later.
-		 * It's possible to migrate LRU pages and balloon pages
+		 * It's possible to migrate LRU pages and mobile pages
 		 * Skip any other type of page
 		 */
 		if (!PageLRU(page)) {
-			if (unlikely(balloon_page_movable(page))) {
-				if (balloon_page_isolate(page, isolate_mode)) {
+			if (unlikely(mobile_page(page))) {
+				if (isolate_mobilepage(page, isolate_mode)) {
 					/* Successfully isolated */
 					goto isolate_success;
 				}
diff --git a/mm/migrate.c b/mm/migrate.c
index c94038e..e22be67 100644
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
@@ -76,7 +76,7 @@ int migrate_prep_local(void)
  * from where they were once taken off for compaction/migration.
  *
  * This function shall be used whenever the isolated pageset has been
- * built from lru, balloon, hugetlbfs page. See isolate_migratepages_range()
+ * built from lru, mobile, hugetlbfs page. See isolate_migratepages_range()
  * and isolate_huge_page().
  */
 void putback_movable_pages(struct list_head *l)
@@ -92,8 +92,8 @@ void putback_movable_pages(struct list_head *l)
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		if (unlikely(isolated_balloon_page(page)))
-			balloon_page_putback(page);
+		if (unlikely(mobile_page(page)))
+			putback_mobilepage(page);
 		else
 			putback_lru_page(page);
 	}
@@ -844,15 +844,16 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		}
 	}
 
-	if (unlikely(isolated_balloon_page(page))) {
+	if (unlikely(mobile_page(page))) {
 		/*
-		 * A ballooned page does not need any special attention from
+		 * A mobile page does not need any special attention from
 		 * physical to virtual reverse mapping procedures.
 		 * Skip any attempt to unmap PTEs or to remap swap cache,
 		 * in order to avoid burning cycles at rmap level, and perform
 		 * the page migration right away (proteced by page lock).
 		 */
-		rc = balloon_page_migrate(page->mapping, newpage, page, mode);
+		rc = page->mapping->a_ops->migratepage(page->mapping,
+						       newpage, page, mode);
 		goto out_unlock;
 	}
 
@@ -960,8 +961,8 @@ out:
 	if (rc != MIGRATEPAGE_SUCCESS && put_new_page) {
 		ClearPageSwapBacked(newpage);
 		put_new_page(newpage, private);
-	} else if (unlikely(__is_movable_balloon_page(newpage))) {
-		/* drop our reference, page already in the balloon */
+	} else if (unlikely(mobile_page(newpage))) {
+		/* drop our reference */
 		put_page(newpage);
 	} else
 		putback_lru_page(newpage);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
