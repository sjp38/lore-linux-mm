Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 03DDB6B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 09:30:37 -0400 (EDT)
Received: by qgeb6 with SMTP id b6so106013560qge.3
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 06:30:36 -0700 (PDT)
Received: from m12-11.163.com (m12-11.163.com. [220.181.12.11])
        by mx.google.com with ESMTP id r19si33477292qha.4.2015.08.25.06.30.34
        for <linux-mm@kvack.org>;
        Tue, 25 Aug 2015 06:30:36 -0700 (PDT)
From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH v2] mm/page_alloc: add a helper function to check page before alloc/free
Date: Tue, 25 Aug 2015 21:26:30 +0800
Message-Id: <1440509190-3622-1-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, mhocko@kernel.org, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

The major portion of check_new_page() and free_pages_check() are same,
introduce a helper function check_one_page() for simplification.

Change in v2:
	- use bad_flags as parameter directly per Michal Hocko

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 mm/page_alloc.c | 49 ++++++++++++++++++-------------------------------
 1 file changed, 18 insertions(+), 31 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5b5240b..0a0acdb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -707,10 +707,9 @@ out:
 	zone->free_area[order].nr_free++;
 }
 
-static inline int free_pages_check(struct page *page)
+static inline int check_one_page(struct page *page, unsigned long bad_flags)
 {
 	const char *bad_reason = NULL;
-	unsigned long bad_flags = 0;
 
 	if (unlikely(page_mapcount(page)))
 		bad_reason = "nonzero mapcount";
@@ -718,9 +717,11 @@ static inline int free_pages_check(struct page *page)
 		bad_reason = "non-NULL mapping";
 	if (unlikely(atomic_read(&page->_count) != 0))
 		bad_reason = "nonzero _count";
-	if (unlikely(page->flags & PAGE_FLAGS_CHECK_AT_FREE)) {
-		bad_reason = "PAGE_FLAGS_CHECK_AT_FREE flag(s) set";
-		bad_flags = PAGE_FLAGS_CHECK_AT_FREE;
+	if (unlikely(page->flags & bad_flags)) {
+		if (bad_flags == PAGE_FLAGS_CHECK_AT_PREP)
+			bad_reason = "PAGE_FLAGS_CHECK_AT_PREP flag set";
+		else if (bad_flags == PAGE_FLAGS_CHECK_AT_FREE)
+			bad_reason = "PAGE_FLAGS_CHECK_AT_FREE flag set";
 	}
 #ifdef CONFIG_MEMCG
 	if (unlikely(page->mem_cgroup))
@@ -730,6 +731,17 @@ static inline int free_pages_check(struct page *page)
 		bad_page(page, bad_reason, bad_flags);
 		return 1;
 	}
+	return 0;
+}
+
+static inline int free_pages_check(struct page *page)
+{
+	int ret = 0;
+
+	ret = check_one_page(page, PAGE_FLAGS_CHECK_AT_FREE);
+	if (ret)
+		return ret;
+
 	page_cpupid_reset_last(page);
 	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
 		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
@@ -1287,32 +1299,7 @@ static inline void expand(struct zone *zone, struct page *page,
  */
 static inline int check_new_page(struct page *page)
 {
-	const char *bad_reason = NULL;
-	unsigned long bad_flags = 0;
-
-	if (unlikely(page_mapcount(page)))
-		bad_reason = "nonzero mapcount";
-	if (unlikely(page->mapping != NULL))
-		bad_reason = "non-NULL mapping";
-	if (unlikely(atomic_read(&page->_count) != 0))
-		bad_reason = "nonzero _count";
-	if (unlikely(page->flags & __PG_HWPOISON)) {
-		bad_reason = "HWPoisoned (hardware-corrupted)";
-		bad_flags = __PG_HWPOISON;
-	}
-	if (unlikely(page->flags & PAGE_FLAGS_CHECK_AT_PREP)) {
-		bad_reason = "PAGE_FLAGS_CHECK_AT_PREP flag set";
-		bad_flags = PAGE_FLAGS_CHECK_AT_PREP;
-	}
-#ifdef CONFIG_MEMCG
-	if (unlikely(page->mem_cgroup))
-		bad_reason = "page still charged to cgroup";
-#endif
-	if (unlikely(bad_reason)) {
-		bad_page(page, bad_reason, bad_flags);
-		return 1;
-	}
-	return 0;
+	return check_one_page(page, PAGE_FLAGS_CHECK_AT_PREP);
 }
 
 static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
-- 
1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
