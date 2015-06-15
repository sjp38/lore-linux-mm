Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1B2DF6B0070
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 03:51:12 -0400 (EDT)
Received: by lblr1 with SMTP id r1so21690698lbl.0
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 00:51:11 -0700 (PDT)
Received: from mail-lb0-x229.google.com (mail-lb0-x229.google.com. [2a00:1450:4010:c04::229])
        by mx.google.com with ESMTPS id ql5si9821017lbb.165.2015.06.15.00.51.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 00:51:10 -0700 (PDT)
Received: by lbbti3 with SMTP id ti3so10736691lbb.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 00:51:09 -0700 (PDT)
Subject: [PATCH RFC v0 3/6] mm/cma: repalce reclaim_clean_pages_from_list
 with try_to_reclaim_page
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Mon, 15 Jun 2015 10:51:05 +0300
Message-ID: <20150615075105.18112.90811.stgit@zurg>
In-Reply-To: <20150615073926.18112.59207.stgit@zurg>
References: <20150615073926.18112.59207.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

This gives almost the same behavior but makes code much less ugly.
Reclaimer works only with isolated pages, try_to_reclaim_page doesn't
require that. Of course it fails if page is currently isolated by
somebody else because in this case page has elevated refcount.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 include/linux/mm.h |    1 +
 mm/filemap.c       |   20 ++++++++++++++++++++
 mm/internal.h      |    2 --
 mm/page_alloc.c    |   13 +++++++++----
 mm/vmscan.c        |   42 +++++-------------------------------------
 5 files changed, 35 insertions(+), 43 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0755b9f..ed1e76bb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1204,6 +1204,7 @@ int get_kernel_page(unsigned long start, int write, struct page **pages);
 struct page *get_dump_page(unsigned long addr);
 
 extern int try_to_release_page(struct page * page, gfp_t gfp_mask);
+extern int try_to_reclaim_page(struct page *page);
 extern void do_invalidatepage(struct page *page, unsigned int offset,
 			      unsigned int length);
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 6bf5e42..a06324d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2663,3 +2663,23 @@ int try_to_release_page(struct page *page, gfp_t gfp_mask)
 }
 
 EXPORT_SYMBOL(try_to_release_page);
+
+/**
+ * try_to_reclaim_page() - unmap and invalidate clean page cache page
+ *
+ * @page: the page which the kernel is trying to free
+ */
+int try_to_reclaim_page(struct page *page)
+{
+	int ret;
+
+	if (PageDirty(page) || PageWriteback(page))
+		return 0;
+	if (!trylock_page(page))
+		return 0;
+	if (page_mapped(page))
+		try_to_unmap(page, TTU_UNMAP | TTU_IGNORE_ACCESS);
+	ret = invalidate_inode_page(page);
+	unlock_page(page);
+	return ret;
+}
diff --git a/mm/internal.h b/mm/internal.h
index a25e359..1cf2eb9 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -416,8 +416,6 @@ extern unsigned long vm_mmap_pgoff(struct file *, unsigned long,
         unsigned long, unsigned long);
 
 extern void set_pageblock_order(void);
-unsigned long reclaim_clean_pages_from_list(struct zone *zone,
-					    struct list_head *page_list);
 /* The ALLOC_WMARK bits are used as an index to zone->watermark */
 #define ALLOC_WMARK_MIN		WMARK_MIN
 #define ALLOC_WMARK_LOW		WMARK_LOW
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ebffa0e..9adf4d07 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6341,9 +6341,9 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 					unsigned long start, unsigned long end)
 {
 	/* This function is based on compact_zone() from compaction.c. */
-	unsigned long nr_reclaimed;
 	unsigned long pfn = start;
 	unsigned int tries = 0;
+	struct page *page;
 	int ret = 0;
 
 	migrate_prep();
@@ -6367,9 +6367,14 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 			break;
 		}
 
-		nr_reclaimed = reclaim_clean_pages_from_list(cc->zone,
-							&cc->migratepages);
-		cc->nr_migratepages -= nr_reclaimed;
+		/*
+		 * Try to reclaim clean page cache pages.
+		 * Migration simply skips pages where page_count == 1.
+		 */
+		list_for_each_entry(page, &cc->migratepages, lru) {
+			if (!PageAnon(page))
+				try_to_reclaim_page(page);
+		}
 
 		ret = migrate_pages(&cc->migratepages, alloc_migrate_target,
 				    NULL, 0, cc->mode, MR_CMA);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5e8eadd..ae2d50d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -843,13 +843,11 @@ static void page_check_dirty_writeback(struct page *page,
 static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct zone *zone,
 				      struct scan_control *sc,
-				      enum ttu_flags ttu_flags,
 				      unsigned long *ret_nr_dirty,
 				      unsigned long *ret_nr_unqueued_dirty,
 				      unsigned long *ret_nr_congested,
 				      unsigned long *ret_nr_writeback,
-				      unsigned long *ret_nr_immediate,
-				      bool force_reclaim)
+				      unsigned long *ret_nr_immediate)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
@@ -991,8 +989,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		if (!force_reclaim)
-			references = page_check_references(page, sc);
+		references = page_check_references(page, sc);
 
 		switch (references) {
 		case PAGEREF_ACTIVATE:
@@ -1024,7 +1021,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * processes. Try to unmap it here.
 		 */
 		if (page_mapped(page) && mapping) {
-			switch (try_to_unmap(page, ttu_flags)) {
+			switch (try_to_unmap(page, TTU_UNMAP)) {
 			case SWAP_FAIL:
 				goto activate_locked;
 			case SWAP_AGAIN:
@@ -1188,34 +1185,6 @@ keep:
 	return nr_reclaimed;
 }
 
-unsigned long reclaim_clean_pages_from_list(struct zone *zone,
-					    struct list_head *page_list)
-{
-	struct scan_control sc = {
-		.gfp_mask = GFP_KERNEL,
-		.priority = DEF_PRIORITY,
-		.may_unmap = 1,
-	};
-	unsigned long ret, dummy1, dummy2, dummy3, dummy4, dummy5;
-	struct page *page, *next;
-	LIST_HEAD(clean_pages);
-
-	list_for_each_entry_safe(page, next, page_list, lru) {
-		if (page_is_file_cache(page) && !PageDirty(page) &&
-		    !isolated_balloon_page(page)) {
-			ClearPageActive(page);
-			list_move(&page->lru, &clean_pages);
-		}
-	}
-
-	ret = shrink_page_list(&clean_pages, zone, &sc,
-			TTU_UNMAP|TTU_IGNORE_ACCESS,
-			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5, true);
-	list_splice(&clean_pages, page_list);
-	mod_zone_page_state(zone, NR_ISOLATED_FILE, -ret);
-	return ret;
-}
-
 /*
  * Attempt to remove the specified page from its LRU.  Only take this page
  * if it is of the appropriate PageActive status.  Pages which are being
@@ -1563,10 +1532,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	if (nr_taken == 0)
 		return 0;
 
-	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
+	nr_reclaimed = shrink_page_list(&page_list, zone, sc,
 				&nr_dirty, &nr_unqueued_dirty, &nr_congested,
-				&nr_writeback, &nr_immediate,
-				false);
+				&nr_writeback, &nr_immediate);
 
 	spin_lock_irq(&zone->lru_lock);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
