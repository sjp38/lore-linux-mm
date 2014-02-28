Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 78E136B0078
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 09:15:36 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id f8so644565wiw.9
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 06:15:35 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j7si1787707wjy.45.2014.02.28.06.15.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 06:15:33 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 3/6] mm: add is_migrate_isolate_page_nolock() for cases where locking is undesirable
Date: Fri, 28 Feb 2014 15:15:01 +0100
Message-Id: <1393596904-16537-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1393596904-16537-1-git-send-email-vbabka@suse.cz>
References: <1393596904-16537-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

This patch complements the addition of get_pageblock_migratetype_nolock() for
the case where is_migrate_isolate_page() cannot be called with zone->lock held.
A race with set_pageblock_migratetype() may be detected, in which case a caller
supplied argument is returned.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/page-isolation.h | 24 ++++++++++++++++++++++++
 mm/hugetlb.c                   |  2 +-
 2 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 3fff8e7..f7bd491 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -2,10 +2,30 @@
 #define __LINUX_PAGEISOLATION_H
 
 #ifdef CONFIG_MEMORY_ISOLATION
+/*
+ * Should be called only with zone->lock held. In cases where locking overhead
+ * is undesirable, consider the _nolock version.
+ */
 static inline bool is_migrate_isolate_page(struct page *page)
 {
 	return get_pageblock_migratetype(page) == MIGRATE_ISOLATE;
 }
+/*
+ * When called without zone->lock held, a race with set_pageblock_migratetype
+ * may result in bogus values. The race may be detected, in which case the
+ * value of race_fallback argument is returned. For details, see
+ * get_pageblock_migratetype_nolock().
+ */
+static inline bool is_migrate_isolate_page_nolock(struct page *page,
+		bool race_fallback)
+{
+	int migratetype = get_pageblock_migratetype_nolock(page, MIGRATE_TYPES);
+
+	if (unlikely(migratetype == MIGRATE_TYPES))
+		return race_fallback;
+
+	return migratetype == MIGRATE_ISOLATE;
+}
 static inline bool is_migrate_isolate(int migratetype)
 {
 	return migratetype == MIGRATE_ISOLATE;
@@ -15,6 +35,10 @@ static inline bool is_migrate_isolate_page(struct page *page)
 {
 	return false;
 }
+static inline bool is_migrate_isolate_page_nolock(struct page *page)
+{
+	return false;
+}
 static inline bool is_migrate_isolate(int migratetype)
 {
 	return false;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 2252cac..fac4003 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -525,7 +525,7 @@ static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
 	struct page *page;
 
 	list_for_each_entry(page, &h->hugepage_freelists[nid], lru)
-		if (!is_migrate_isolate_page(page))
+		if (!is_migrate_isolate_page_nolock(page, true))
 			break;
 	/*
 	 * if 'non-isolated free hugepage' not found on the list,
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
