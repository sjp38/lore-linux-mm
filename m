Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id E770D6B0254
	for <linux-mm@kvack.org>; Sat, 22 Aug 2015 04:11:17 -0400 (EDT)
Received: by qkbm65 with SMTP id m65so42665766qkb.2
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 01:11:17 -0700 (PDT)
Received: from m12-11.163.com (m12-11.163.com. [220.181.12.11])
        by mx.google.com with ESMTP id v92si1759195qgd.85.2015.08.22.01.11.16
        for <linux-mm@kvack.org>;
        Sat, 22 Aug 2015 01:11:17 -0700 (PDT)
From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH 2/3] mm/page_alloc: add a helper function to check page before alloc/free
Date: Sat, 22 Aug 2015 15:40:11 +0800
Message-Id: <1440229212-8737-2-git-send-email-bywxiaobai@163.com>
In-Reply-To: <1440229212-8737-1-git-send-email-bywxiaobai@163.com>
References: <1440229212-8737-1-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, mhocko@suse.com, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

The major portion of check_new_page() and free_pages_check() are same,
introduce a helper function check_one_page() for readablity.

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 mm/page_alloc.c | 54 +++++++++++++++++++++++-------------------------------
 1 file changed, 23 insertions(+), 31 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c22b133..a0839de 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -707,7 +707,7 @@ out:
 	zone->free_area[order].nr_free++;
 }
 
-static inline int free_pages_check(struct page *page)
+static inline int check_one_page(struct page *page, bool free)
 {
 	const char *bad_reason = NULL;
 	unsigned long bad_flags = 0;
@@ -718,10 +718,16 @@ static inline int free_pages_check(struct page *page)
 		bad_reason = "non-NULL mapping";
 	if (unlikely(atomic_read(&page->_count) != 0))
 		bad_reason = "nonzero _count";
-	if (unlikely(page->flags & PAGE_FLAGS_CHECK_AT_FREE)) {
-		bad_reason = "PAGE_FLAGS_CHECK_AT_FREE flag(s) set";
-		bad_flags = PAGE_FLAGS_CHECK_AT_FREE;
-	}
+	if (free)
+		if (unlikely(page->flags & PAGE_FLAGS_CHECK_AT_FREE)) {
+			bad_reason = "PAGE_FLAGS_CHECK_AT_FREE flag(s) set";
+			bad_flags = PAGE_FLAGS_CHECK_AT_FREE;
+		}
+	else
+		if (unlikely(page->flags & PAGE_FLAGS_CHECK_AT_PREP)) {
+			bad_reason = "PAGE_FLAGS_CHECK_AT_PREP flag set";
+			bad_flags = PAGE_FLAGS_CHECK_AT_PREP;
+		}
 #ifdef CONFIG_MEMCG
 	if (unlikely(page->mem_cgroup))
 		bad_reason = "page still charged to cgroup";
@@ -730,6 +736,17 @@ static inline int free_pages_check(struct page *page)
 		bad_page(page, bad_reason, bad_flags);
 		return 1;
 	}
+	return 0;
+}
+
+static inline int free_pages_check(struct page *page)
+{
+	int ret=0;
+
+	ret=check_one_page(page, true);
+	if (ret)
+		return ret;
+
 	page_cpupid_reset_last(page);
 	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
 		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
@@ -1287,32 +1304,7 @@ static inline void expand(struct zone *zone, struct page *page,
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
+	return check_one_page(page, false);
 }
 
 static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
-- 
1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
