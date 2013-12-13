Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2149C6B003A
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 01:50:38 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id up15so2024044pbc.10
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 22:50:37 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id e8si774652pac.111.2013.12.12.22.50.35
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 22:50:36 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 4/6] mm/migrate: remove putback_lru_pages, fix comment on putback_movable_pages
Date: Fri, 13 Dec 2013 15:53:29 +0900
Message-Id: <1386917611-11319-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1386917611-11319-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1386917611-11319-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Some part of putback_lru_pages() and putback_movable_pages() is
duplicated, so it could confuse us what we should use.
We can remove putback_lru_pages() since it is not really needed now.
This makes us undestand and maintain the code more easily.

And comment on putback_movable_pages() is stale now, so fix it.

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index f5096b5..e4671f9 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -35,7 +35,6 @@ enum migrate_reason {
 
 #ifdef CONFIG_MIGRATION
 
-extern void putback_lru_pages(struct list_head *l);
 extern void putback_movable_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
 			struct page *, struct page *, enum migrate_mode);
@@ -58,7 +57,6 @@ extern int migrate_page_move_mapping(struct address_space *mapping,
 		struct buffer_head *head, enum migrate_mode mode);
 #else
 
-static inline void putback_lru_pages(struct list_head *l) {}
 static inline void putback_movable_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t x,
 		unsigned long private, enum migrate_mode mode, int reason)
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index b7c1716..1debdea 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1569,7 +1569,13 @@ static int __soft_offline_page(struct page *page, int flags)
 		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
 					MIGRATE_SYNC, MR_MEMORY_FAILURE);
 		if (ret) {
-			putback_lru_pages(&pagelist);
+			if (!list_empty(&pagelist)) {
+				list_del(&page->lru);
+				dec_zone_page_state(page, NR_ISOLATED_ANON +
+						page_is_file_cache(page));
+				putback_lru_page(page);
+			}
+
 			pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
 				pfn, ret, page->flags);
 			if (ret > 0)
diff --git a/mm/migrate.c b/mm/migrate.c
index b1cfd01..fa73ee3 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -71,28 +71,12 @@ int migrate_prep_local(void)
 }
 
 /*
- * Add isolated pages on the list back to the LRU under page lock
- * to avoid leaking evictable pages back onto unevictable list.
- */
-void putback_lru_pages(struct list_head *l)
-{
-	struct page *page;
-	struct page *page2;
-
-	list_for_each_entry_safe(page, page2, l, lru) {
-		list_del(&page->lru);
-		dec_zone_page_state(page, NR_ISOLATED_ANON +
-				page_is_file_cache(page));
-			putback_lru_page(page);
-	}
-}
-
-/*
  * Put previously isolated pages back onto the appropriate lists
  * from where they were once taken off for compaction/migration.
  *
- * This function shall be used instead of putback_lru_pages(),
- * whenever the isolated pageset has been built by isolate_migratepages_range()
+ * This function shall be used whenever the isolated pageset has been
+ * built from lru, balloon, hugetlbfs page. See isolate_migratepages_range()
+ * and isolate_huge_page().
  */
 void putback_movable_pages(struct list_head *l)
 {
@@ -1704,7 +1688,12 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
 	nr_remaining = migrate_pages(&migratepages, alloc_misplaced_dst_page,
 				     node, MIGRATE_ASYNC, MR_NUMA_MISPLACED);
 	if (nr_remaining) {
-		putback_lru_pages(&migratepages);
+		if (!list_empty(&migratepages)) {
+			list_del(&page->lru);
+			dec_zone_page_state(page, NR_ISOLATED_ANON +
+					page_is_file_cache(page));
+			putback_lru_page(page);
+		}
 		isolated = 0;
 	} else
 		count_vm_numa_event(NUMA_PAGE_MIGRATE);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
