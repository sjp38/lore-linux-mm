From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH] mm/readahead.c, mm/vmscan.c: use lru_to_page instead of list_to_page
Date: Tue,  8 Dec 2015 22:40:01 +0800
Message-ID: <35cab720b3e69d47f03c9ce36d680db336bb5683.1449585319.git.geliangtang@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jens Axboe <axboe@fb.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: Geliang Tang <geliangtang@163.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

list_to_page() in readahead.c is the same as lru_to_page() in vmscan.c.
So I move lru_to_page to internal.h and drop list_to_page().

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 mm/internal.h  | 2 ++
 mm/readahead.c | 8 +++-----
 mm/vmscan.c    | 2 --
 3 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 4ae7b7c..d01a41c 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -80,6 +80,8 @@ extern int isolate_lru_page(struct page *page);
 extern void putback_lru_page(struct page *page);
 extern bool zone_reclaimable(struct zone *zone);
 
+#define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
+
 /*
  * in mm/rmap.c:
  */
diff --git a/mm/readahead.c b/mm/readahead.c
index ba22d7f..0aff760 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -32,8 +32,6 @@ file_ra_state_init(struct file_ra_state *ra, struct address_space *mapping)
 }
 EXPORT_SYMBOL_GPL(file_ra_state_init);
 
-#define list_to_page(head) (list_entry((head)->prev, struct page, lru))
-
 /*
  * see if a page needs releasing upon read_cache_pages() failure
  * - the caller of read_cache_pages() may have set PG_private or PG_fscache
@@ -64,7 +62,7 @@ static void read_cache_pages_invalidate_pages(struct address_space *mapping,
 	struct page *victim;
 
 	while (!list_empty(pages)) {
-		victim = list_to_page(pages);
+		victim = lru_to_page(pages);
 		list_del(&victim->lru);
 		read_cache_pages_invalidate_page(mapping, victim);
 	}
@@ -87,7 +85,7 @@ int read_cache_pages(struct address_space *mapping, struct list_head *pages,
 	int ret = 0;
 
 	while (!list_empty(pages)) {
-		page = list_to_page(pages);
+		page = lru_to_page(pages);
 		list_del(&page->lru);
 		if (add_to_page_cache_lru(page, mapping, page->index,
 				mapping_gfp_constraint(mapping, GFP_KERNEL))) {
@@ -125,7 +123,7 @@ static int read_pages(struct address_space *mapping, struct file *filp,
 	}
 
 	for (page_idx = 0; page_idx < nr_pages; page_idx++) {
-		struct page *page = list_to_page(pages);
+		struct page *page = lru_to_page(pages);
 		list_del(&page->lru);
 		if (!add_to_page_cache_lru(page, mapping, page->index,
 				mapping_gfp_constraint(mapping, GFP_KERNEL))) {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c2f6944..f284401 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -106,8 +106,6 @@ struct scan_control {
 	unsigned long nr_reclaimed;
 };
 
-#define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
-
 #ifdef ARCH_HAS_PREFETCH
 #define prefetch_prev_lru_page(_page, _base, _field)			\
 	do {								\
-- 
2.5.0
