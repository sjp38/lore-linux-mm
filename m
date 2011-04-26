Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B685A900110
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:26:15 -0400 (EDT)
Received: by mail-iy0-f169.google.com with SMTP id 42so951630iyh.14
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:26:14 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [RFC 7/8] migration: make in-order-putback aware
Date: Wed, 27 Apr 2011 01:25:24 +0900
Message-Id: <1f162d17040ab50ffea1ef53d4cd16348d3e7c2d.1303833418.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1303833415.git.minchan.kim@gmail.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1303833415.git.minchan.kim@gmail.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

This patch makes migrate_pages is aware of in-order putback
This patch should be not changed old behavior.
It's used by next patch.

Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/migrate.h |    4 +-
 mm/compaction.c         |    2 +-
 mm/memory-failure.c     |    2 +-
 mm/memory_hotplug.c     |    2 +-
 mm/mempolicy.c          |    4 +-
 mm/migrate.c            |   95 +++++++++++++++++++++++++++++++++++------------
 6 files changed, 78 insertions(+), 31 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 3aa5ab6..f842fc8 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -15,7 +15,7 @@ extern int migrate_page(struct address_space *,
 			struct page *, struct page *);
 extern int migrate_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
-			bool sync);
+			bool sync, bool keep_lru);
 extern int migrate_huge_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
 			bool sync);
@@ -38,7 +38,7 @@ static inline void putback_pages_lru(struct list_head *l) {}
 static inline void putback_lru_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t x,
 		unsigned long private, bool offlining,
-		bool sync) { return -ENOSYS; }
+		bool sync, bool keep_lru) { return -ENOSYS; }
 static inline int migrate_huge_pages(struct list_head *l, new_page_t x,
 		unsigned long private, bool offlining,
 		bool sync) { return -ENOSYS; }
diff --git a/mm/compaction.c b/mm/compaction.c
index c453000..a2f6e96 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -529,7 +529,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		nr_migrate = cc->nr_migratepages;
 		err = migrate_pages(&cc->migratepages, compaction_alloc,
 				(unsigned long)cc, false,
-				cc->sync);
+				cc->sync, false);
 		update_nr_listpages(cc);
 		nr_remaining = cc->nr_migratepages;
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 2b9a5ee..395a99e 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1466,7 +1466,7 @@ int soft_offline_page(struct page *page, int flags)
 
 		list_add(&page->lru, &pagelist);
 		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
-								0, true);
+								0, true, false);
 		if (ret) {
 			putback_lru_pages(&pagelist);
 			pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 59ac18f..75dd241 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -741,7 +741,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 		}
 		/* this function returns # of failed pages */
 		ret = migrate_pages(&source, hotremove_migrate_alloc, 0,
-								true, true);
+								true, true, false);
 		if (ret)
 			putback_lru_pages(&source);
 	}
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 8e57a72..9fe702a 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -938,7 +938,7 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
 
 	if (!list_empty(&pagelist)) {
 		err = migrate_pages(&pagelist, new_node_page, dest,
-								false, true);
+						false, true, false);
 		if (err)
 			putback_lru_pages(&pagelist);
 	}
@@ -1159,7 +1159,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 		if (!list_empty(&pagelist)) {
 			nr_failed = migrate_pages(&pagelist, new_vma_page,
 						(unsigned long)vma,
-						false, true);
+						false, true, false);
 			if (nr_failed)
 				putback_lru_pages(&pagelist);
 		}
diff --git a/mm/migrate.c b/mm/migrate.c
index 9cfb63b..871e6ee 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -662,7 +662,8 @@ static int move_to_new_page(struct page *newpage, struct page *page,
  * to the newly allocated page in newpage.
  */
 static int unmap_and_move(new_page_t get_new_page, unsigned long private,
-			struct page *page, int force, bool offlining, bool sync)
+			struct page *page, int force, bool offlining,
+			bool sync, struct pages_lru *pages_lru)
 {
 	int rc = 0;
 	int *result = NULL;
@@ -671,6 +672,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 	int charge = 0;
 	struct mem_cgroup *mem;
 	struct anon_vma *anon_vma = NULL;
+	bool del_pages_lru = false;
 
 	if (!newpage)
 		return -ENOMEM;
@@ -834,7 +836,13 @@ move_newpage:
  		 * migrated will have kepts its references and be
  		 * restored.
  		 */
- 		list_del(&page->lru);
+		if (pages_lru) {
+			list_del(&pages_lru->lru);
+			del_pages_lru = true;
+		}
+		else
+			list_del(&page->lru);
+
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
 		putback_lru_page(page);
@@ -844,7 +852,21 @@ move_newpage:
 	 * Move the new page to the LRU. If migration was not successful
 	 * then this will free the page.
 	 */
-	putback_lru_page(newpage);
+	if (pages_lru) {
+		struct zone *zone = page_zone(page);
+		spin_lock_irq(&zone->lru_lock);
+		if (keep_lru_order(pages_lru)) {
+			putback_page_to_lru(newpage, &pages_lru->prev_page->lru);
+			spin_unlock_irq(&zone->lru_lock);
+		}
+		else {
+			spin_unlock_irq(&zone->lru_lock);
+			putback_lru_page(newpage);
+		}
+
+		if (del_pages_lru)
+			kfree(pages_lru);
+	}
 
 	if (result) {
 		if (rc)
@@ -947,13 +969,13 @@ out:
  */
 int migrate_pages(struct list_head *from,
 		new_page_t get_new_page, unsigned long private, bool offlining,
-		bool sync)
+		bool sync, bool keep_lru)
 {
 	int retry = 1;
 	int nr_failed = 0;
 	int pass = 0;
-	struct page *page;
-	struct page *page2;
+	struct page *page, *page2;
+	struct pages_lru *pages_lru, *pages_lru2;
 	int swapwrite = current->flags & PF_SWAPWRITE;
 	int rc;
 
@@ -962,26 +984,51 @@ int migrate_pages(struct list_head *from,
 
 	for(pass = 0; pass < 10 && retry; pass++) {
 		retry = 0;
+		if (!keep_lru) {
+			list_for_each_entry_safe(page, page2, from, lru) {
+				cond_resched();
 
-		list_for_each_entry_safe(page, page2, from, lru) {
-			cond_resched();
-
-			rc = unmap_and_move(get_new_page, private,
+				rc = unmap_and_move(get_new_page, private,
 						page, pass > 2, offlining,
-						sync);
-
-			switch(rc) {
-			case -ENOMEM:
-				goto out;
-			case -EAGAIN:
-				retry++;
-				break;
-			case 0:
-				break;
-			default:
-				/* Permanent failure */
-				nr_failed++;
-				break;
+						sync, NULL);
+
+				switch(rc) {
+					case -ENOMEM:
+						goto out;
+					case -EAGAIN:
+						retry++;
+						break;
+					case 0:
+						break;
+					default:
+						/* Permanent failure */
+						nr_failed++;
+						break;
+				}
+			}
+		}
+		else {
+
+			list_for_each_entry_safe(pages_lru, pages_lru2, from, lru) {
+				cond_resched();
+
+				rc = unmap_and_move(get_new_page, private,
+						pages_lru->page, pass > 2, offlining,
+						sync, pages_lru);
+
+				switch(rc) {
+					case -ENOMEM:
+						goto out;
+					case -EAGAIN:
+						retry++;
+						break;
+					case 0:
+						break;
+					default:
+						/* Permanent failure */
+						nr_failed++;
+						break;
+				}
 			}
 		}
 	}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
