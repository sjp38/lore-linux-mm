Return-Path: <owner-linux-mm@kvack.org>
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 3/3] mm: migrate pinned page
Date: Tue, 13 Aug 2013 16:05:02 +0900
Message-Id: <1376377502-28207-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1376377502-28207-1-git-send-email-minchan@kernel.org>
References: <1376377502-28207-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, k.kozlowski@samsung.com, Seth Jennings <sjenning@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, guz.fnst@cn.fujitsu.com, Benjamin LaHaise <bcrl@kvack.org>, Dave Hansen <dave.hansen@intel.com>, lliubbo@gmail.com, aquini@redhat.com, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/compaction.c |   26 +++++++++++++++++++++++--
 mm/migrate.c    |   58 ++++++++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 75 insertions(+), 9 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 05ccb4c..16b80e6 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -396,8 +396,10 @@ static void acct_isolated(struct zone *zone, bool locked, struct compact_control
 	struct page *page;
 	unsigned int count[2] = { 0, };
 
-	list_for_each_entry(page, &cc->migratepages, lru)
-		count[!!page_is_file_cache(page)]++;
+	list_for_each_entry(page, &cc->migratepages, lru) {
+		if (!PagePin(page))
+			count[!!page_is_file_cache(page)]++;
+	}
 
 	/* If locked we can use the interrupt unsafe versions */
 	if (locked) {
@@ -535,6 +537,25 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		}
 
 		/*
+		 * Pinned kernel page(ex, zswap) could be isolated.
+		 */
+		if (PagePin(page)) {
+			if (!get_page_unless_zero(page))
+				continue;
+			/*
+			 * Subsystem want to use pinpage should not
+			 * use page->lru feild.
+			 */
+			VM_BUG_ON(!list_empty(&page->lru));
+			if (!trylock_page(page)) {
+				put_page(page);
+				continue;
+			}
+
+			goto isolated;
+		}
+
+		/*
 		 * Check may be lockless but that's ok as we recheck later.
 		 * It's possible to migrate LRU pages and balloon pages
 		 * Skip any other type of page
@@ -601,6 +622,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		/* Successfully isolated */
 		cc->finished_update_migrate = true;
 		del_page_from_lru_list(page, lruvec, page_lru(page));
+isolated:
 		list_add(&page->lru, migratelist);
 		cc->nr_migratepages++;
 		nr_isolated++;
diff --git a/mm/migrate.c b/mm/migrate.c
index 6f0c244..4d28049 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -36,6 +36,7 @@
 #include <linux/hugetlb_cgroup.h>
 #include <linux/gfp.h>
 #include <linux/balloon_compaction.h>
+#include <linux/pinpage.h>
 
 #include <asm/tlbflush.h>
 
@@ -101,12 +102,17 @@ void putback_movable_pages(struct list_head *l)
 
 	list_for_each_entry_safe(page, page2, l, lru) {
 		list_del(&page->lru);
-		dec_zone_page_state(page, NR_ISOLATED_ANON +
-				page_is_file_cache(page));
-		if (unlikely(balloon_page_movable(page)))
-			balloon_page_putback(page);
-		else
-			putback_lru_page(page);
+		if (!PagePin(page)) {
+			dec_zone_page_state(page, NR_ISOLATED_ANON +
+					page_is_file_cache(page));
+			if (unlikely(balloon_page_movable(page)))
+				balloon_page_putback(page);
+			else
+				putback_lru_page(page);
+		} else {
+			unlock_page(page);
+			put_page(page);
+		}
 	}
 }
 
@@ -855,6 +861,39 @@ out:
 	return rc;
 }
 
+static int unmap_and_move_pinpage(new_page_t get_new_page,
+			unsigned long private, struct page *page, int force,
+			enum migrate_mode mode)
+{
+	int *result = NULL;
+	int rc = 0;
+	struct page *newpage = get_new_page(page, private, &result);
+	if (!newpage)
+		return -ENOMEM;
+
+	VM_BUG_ON(!PageLocked(page));
+	if (page_count(page) == 1) {
+		/* page was freed from under us. So we are done. */
+		goto out;
+	}
+
+	rc = migrate_pinpage(page, newpage);
+out:
+	if (rc != -EAGAIN) {
+		list_del(&page->lru);
+		unlock_page(page);
+		put_page(page);
+	}
+
+	if (result) {
+		if (rc)
+			*result = rc;
+		else
+			*result = page_to_nid(newpage);
+	}
+	return rc;
+
+}
 /*
  * Obtain the lock on page, remove all ptes and migrate the page
  * to the newly allocated page in newpage.
@@ -1025,8 +1064,13 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 		list_for_each_entry_safe(page, page2, from, lru) {
 			cond_resched();
 
-			rc = unmap_and_move(get_new_page, private,
+			if (PagePin(page)) {
+				rc = unmap_and_move_pinpage(get_new_page, private,
 						page, pass > 2, mode);
+			} else {
+				rc = unmap_and_move(get_new_page, private,
+					page, pass > 2, mode);
+			}
 
 			switch(rc) {
 			case -ENOMEM:
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
