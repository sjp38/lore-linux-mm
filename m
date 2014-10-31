Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id AD235280028
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 03:24:12 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id y10so6741783pdj.40
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 00:24:12 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id e12si1514304pat.113.2014.10.31.00.24.09
        for <linux-mm@kvack.org>;
        Fri, 31 Oct 2014 00:24:10 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v5 4/4] mm/page_alloc: restrict max order of merging on isolated pageblock
Date: Fri, 31 Oct 2014 16:25:30 +0900
Message-Id: <1414740330-4086-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1414740330-4086-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1414740330-4086-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, stable@vger.kernel.org

Current pageblock isolation logic could isolate each pageblock
individually. This causes freepage accounting problem if freepage with
pageblock order on isolate pageblock is merged with other freepage on
normal pageblock. We can prevent merging by restricting max order of
merging to pageblock order if freepage is on isolate pageblock.

Side-effect of this change is that there could be non-merged buddy
freepage even if finishing pageblock isolation, because undoing pageblock
isolation is just to move freepage from isolate buddy list to normal buddy
list rather than to consider merging. So, the patch also makes undoing
pageblock isolation consider freepage merge. When un-isolation, freepage
with more than pageblock order and it's buddy are checked. If they are
on normal pageblock, instead of just moving, we isolate the freepage and
free it in order to get merged.

Changes from v4:
Consider merging on un-isolation process.

Cc: <stable@vger.kernel.org>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/internal.h       |   25 +++++++++++++++++++++++++
 mm/page_alloc.c     |   40 +++++++++++++---------------------------
 mm/page_isolation.c |   31 +++++++++++++++++++++++++++++++
 3 files changed, 69 insertions(+), 27 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 8293040..a4f90ba 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -108,6 +108,31 @@ extern pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address);
 /*
  * in mm/page_alloc.c
  */
+
+/*
+ * Locate the struct page for both the matching buddy in our
+ * pair (buddy1) and the combined O(n+1) page they form (page).
+ *
+ * 1) Any buddy B1 will have an order O twin B2 which satisfies
+ * the following equation:
+ *     B2 = B1 ^ (1 << O)
+ * For example, if the starting buddy (buddy2) is #8 its order
+ * 1 buddy is #10:
+ *     B2 = 8 ^ (1 << 1) = 8 ^ 2 = 10
+ *
+ * 2) Any buddy B will have an order O+1 parent P which
+ * satisfies the following equation:
+ *     P = B & ~(1 << O)
+ *
+ * Assumption: *_mem_map is contiguous at least up to MAX_ORDER
+ */
+static inline unsigned long
+__find_buddy_index(unsigned long page_idx, unsigned int order)
+{
+	return page_idx ^ (1 << order);
+}
+
+extern int __isolate_free_page(struct page *page, unsigned int order);
 extern void __free_pages_bootmem(struct page *page, unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned long order);
 #ifdef CONFIG_MEMORY_FAILURE
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2bc7768..eb60d18 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -469,29 +469,6 @@ static inline void rmv_page_order(struct page *page)
 }
 
 /*
- * Locate the struct page for both the matching buddy in our
- * pair (buddy1) and the combined O(n+1) page they form (page).
- *
- * 1) Any buddy B1 will have an order O twin B2 which satisfies
- * the following equation:
- *     B2 = B1 ^ (1 << O)
- * For example, if the starting buddy (buddy2) is #8 its order
- * 1 buddy is #10:
- *     B2 = 8 ^ (1 << 1) = 8 ^ 2 = 10
- *
- * 2) Any buddy B will have an order O+1 parent P which
- * satisfies the following equation:
- *     P = B & ~(1 << O)
- *
- * Assumption: *_mem_map is contiguous at least up to MAX_ORDER
- */
-static inline unsigned long
-__find_buddy_index(unsigned long page_idx, unsigned int order)
-{
-	return page_idx ^ (1 << order);
-}
-
-/*
  * This function checks whether a page is free && is the buddy
  * we can do coalesce a page and its buddy if
  * (a) the buddy is not in a hole &&
@@ -571,6 +548,7 @@ static inline void __free_one_page(struct page *page,
 	unsigned long combined_idx;
 	unsigned long uninitialized_var(buddy_idx);
 	struct page *buddy;
+	int max_order = MAX_ORDER;
 
 	VM_BUG_ON(!zone_is_initialized(zone));
 
@@ -579,15 +557,23 @@ static inline void __free_one_page(struct page *page,
 			return;
 
 	VM_BUG_ON(migratetype == -1);
-	if (!is_migrate_isolate(migratetype))
+	if (is_migrate_isolate(migratetype)) {
+		/*
+		 * We restrict max order of merging to prevent merge
+		 * between freepages on isolate pageblock and normal
+		 * pageblock. Without this, pageblock isolation
+		 * could cause incorrect freepage accounting.
+		 */
+		max_order = min(MAX_ORDER, pageblock_order + 1);
+	} else
 		__mod_zone_freepage_state(zone, 1 << order, migratetype);
 
-	page_idx = pfn & ((1 << MAX_ORDER) - 1);
+	page_idx = pfn & ((1 << max_order) - 1);
 
 	VM_BUG_ON_PAGE(page_idx & ((1 << order) - 1), page);
 	VM_BUG_ON_PAGE(bad_range(zone, page), page);
 
-	while (order < MAX_ORDER-1) {
+	while (order < max_order - 1) {
 		buddy_idx = __find_buddy_index(page_idx, order);
 		buddy = page + (buddy_idx - page_idx);
 		if (!page_is_buddy(page, buddy, order))
@@ -1590,7 +1576,7 @@ void split_page(struct page *page, unsigned int order)
 }
 EXPORT_SYMBOL_GPL(split_page);
 
-static int __isolate_free_page(struct page *page, unsigned int order)
+int __isolate_free_page(struct page *page, unsigned int order)
 {
 	unsigned long watermark;
 	struct zone *zone;
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 1fa4a4d..df61c93 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -76,17 +76,48 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 {
 	struct zone *zone;
 	unsigned long flags, nr_pages;
+	struct page *isolated_page = NULL;
+	unsigned int order;
+	unsigned long page_idx, buddy_idx;
+	struct page *buddy;
+	int mt;
 
 	zone = page_zone(page);
 	spin_lock_irqsave(&zone->lock, flags);
 	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
 		goto out;
+
+	/*
+	 * Because freepage with more than pageblock_order on isolated
+	 * pageblock is restricted to merge due to freepage counting problem,
+	 * it is possible that there is free buddy page.
+	 * move_freepages_block() doesn't care of merge so we need other
+	 * approach in order to merge them. Isolation and free will make
+	 * these pages to be merged.
+	 */
+	if (PageBuddy(page)) {
+		order = page_order(page);
+		if (order >= pageblock_order) {
+			page_idx = page_to_pfn(page) & ((1 << MAX_ORDER) - 1);
+			buddy_idx = __find_buddy_index(page_idx, order);
+			buddy = page + (buddy_idx - page_idx);
+			mt = get_pageblock_migratetype(buddy);
+
+			if (!is_migrate_isolate(mt)) {
+				__isolate_free_page(page, order);
+				set_page_refcounted(page);
+				isolated_page = page;
+			}
+		}
+	}
 	nr_pages = move_freepages_block(zone, page, migratetype);
 	__mod_zone_freepage_state(zone, nr_pages, migratetype);
 	set_pageblock_migratetype(page, migratetype);
 	zone->nr_isolate_pageblock--;
 out:
 	spin_unlock_irqrestore(&zone->lock, flags);
+	if (isolated_page)
+		__free_pages(isolated_page, order);
 }
 
 static inline struct page *
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
