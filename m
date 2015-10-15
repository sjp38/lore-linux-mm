Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 963E46B0254
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 05:09:29 -0400 (EDT)
Received: by padcn9 with SMTP id cn9so640714pad.3
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 02:09:29 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id fm3si20089075pab.106.2015.10.15.02.09.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 15 Oct 2015 02:09:28 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [RFC v2 1/3] migrate: new struct migration and add it to struct page
Date: Thu, 15 Oct 2015 17:09:00 +0800
Message-ID: <1444900142-1996-2-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1444900142-1996-1-git-send-email-zhuhui@xiaomi.com>
References: <1444900142-1996-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey
 Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Dave Hansen <dave.hansen@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal
 Hocko <mhocko@suse.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jennifer Herbert <jennifer.herbert@citrix.com>, Hugh Dickins <hughd@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil
 Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, "Steven Rostedt (Red Hat)" <rostedt@goodmis.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <wanpeng.li@hotmail.com>, Geert Uytterhoeven <geert+renesas@glider.be>, Greg
 Thelen <gthelen@google.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

I got that add function interfaces is really not a good idea.
So I add a new struct migration to put all migration interfaces and add
this struct to struct page as union of "mapping".
Then the function doesn't need increase the size of struct page.

Also I change the flags from "PG_movable" to "PageMigration" according
to the review.

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 include/linux/migrate.h  | 30 ++++++++++++++++++++++++++++++
 include/linux/mm_types.h |  3 +++
 mm/compaction.c          |  8 ++++++++
 mm/migrate.c             | 17 +++++++++++++----
 mm/vmscan.c              |  2 +-
 5 files changed, 55 insertions(+), 5 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index cac1c09..8b8caba 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -27,6 +27,31 @@ enum migrate_reason {
 };
 
 #ifdef CONFIG_MIGRATION
+struct migration {
+	int (*isolate)(struct page *page);
+	void (*put)(struct page *page);
+	int (*move)(struct page *page, struct page *newpage, int force,
+		       enum migrate_mode mode);
+};
+
+#define PAGE_MIGRATION_MAPCOUNT_VALUE (-512)
+
+static inline int PageMigration(struct page *page)
+{
+	return atomic_read(&page->_mapcount) == PAGE_MIGRATION_MAPCOUNT_VALUE;
+}
+
+static inline void __SetPageMigration(struct page *page)
+{
+	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
+	atomic_set(&page->_mapcount, PAGE_MIGRATION_MAPCOUNT_VALUE);
+}
+
+static inline void __ClearPageMigration(struct page *page)
+{
+	VM_BUG_ON_PAGE(!PageMigration(page), page);
+	atomic_set(&page->_mapcount, -1);
+}
 
 extern void putback_movable_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
@@ -45,6 +70,11 @@ extern int migrate_page_move_mapping(struct address_space *mapping,
 		int extra_count);
 #else
 
+static inline int PageMigration(struct page *page)
+{
+	return false;
+}
+
 static inline void putback_movable_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t new,
 		free_page_t free, unsigned long private, enum migrate_mode mode,
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3d6baa7..61d5da4 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -56,6 +56,9 @@ struct page {
 						 * see PAGE_MAPPING_ANON below.
 						 */
 		void *s_mem;			/* slab first object */
+#ifdef CONFIG_MIGRATION
+		struct migration *migration;
+#endif
 	};
 
 	/* Second double word */
diff --git a/mm/compaction.c b/mm/compaction.c
index c5c627a..d05822e 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -752,6 +752,14 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 */
 		is_lru = PageLRU(page);
 		if (!is_lru) {
+#ifdef CONFIG_MIGRATION
+			if (PageMigration(page)) {
+				if (page->migration->isolate(page) == 0)
+					goto isolate_success;
+
+				continue;
+			}
+#endif
 			if (unlikely(balloon_page_movable(page))) {
 				if (balloon_page_isolate(page)) {
 					/* Successfully isolated */
diff --git a/mm/migrate.c b/mm/migrate.c
index 842ecd7..2e20d4e 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -93,7 +93,9 @@ void putback_movable_pages(struct list_head *l)
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		if (unlikely(isolated_balloon_page(page)))
+		if (PageMigration(page))
+			page->migration->put(page);
+		else if (unlikely(isolated_balloon_page(page)))
 			balloon_page_putback(page);
 		else
 			putback_lru_page(page);
@@ -953,7 +955,10 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		if (unlikely(split_huge_page(page)))
 			goto out;
 
-	rc = __unmap_and_move(page, newpage, force, mode);
+	if (PageMigration(page))
+		rc = page->migration->move(page, newpage, force, mode);
+	else
+		rc = __unmap_and_move(page, newpage, force, mode);
 
 out:
 	if (rc != -EAGAIN) {
@@ -967,7 +972,9 @@ out:
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
 		/* Soft-offlined page shouldn't go through lru cache list */
-		if (reason == MR_MEMORY_FAILURE) {
+		if (PageMigration(page))
+			page->migration->put(page);
+		else if (reason == MR_MEMORY_FAILURE) {
 			put_page(page);
 			if (!test_set_page_hwpoison(page))
 				num_poisoned_pages_inc();
@@ -983,7 +990,9 @@ out:
 	if (rc != MIGRATEPAGE_SUCCESS && put_new_page) {
 		ClearPageSwapBacked(newpage);
 		put_new_page(newpage, private);
-	} else if (unlikely(__is_movable_balloon_page(newpage))) {
+	} else if (PageMigration(newpage))
+		put_page(newpage);
+	else if (unlikely(__is_movable_balloon_page(newpage))) {
 		/* drop our reference, page already in the balloon */
 		put_page(newpage);
 	} else
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7f63a93..87d6934 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1245,7 +1245,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 
 	list_for_each_entry_safe(page, next, page_list, lru) {
 		if (page_is_file_cache(page) && !PageDirty(page) &&
-		    !isolated_balloon_page(page)) {
+		    !isolated_balloon_page(page) && !PageMigration(page)) {
 			ClearPageActive(page);
 			list_move(&page->lru, &clean_pages);
 		}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
