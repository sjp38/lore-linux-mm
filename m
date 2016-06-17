Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 65B776B0262
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 03:57:58 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a69so147575228pfa.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:57:58 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id n1si9601564pax.163.2016.06.17.00.57.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 00:57:57 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id ts6so5349256pac.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:57:57 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v3 4/9] mm/page_owner: introduce split_page_owner and replace manual handling
Date: Fri, 17 Jun 2016 16:57:34 +0900
Message-Id: <1466150259-27727-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1466150259-27727-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1466150259-27727-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

split_page() calls set_page_owner() to set up page_owner to each pages.
But, it has a drawback that head page and the others have different
stacktrace because callsite of set_page_owner() is slightly differnt.  To
avoid this problem, this patch copies head page's page_owner to the
others.  It needs to introduce new function, split_page_owner() but it
also remove the other function, get_page_owner_gfp() so looks good to do.

Link: http://lkml.kernel.org/r/1464230275-25791-4-git-send-email-iamjoonsoo.kim@lge.com
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Alexander Potapenko <glider@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@kernel.org>
---
 include/linux/page_owner.h | 12 +++++-------
 mm/page_alloc.c            |  8 ++------
 mm/page_owner.c            | 14 +++++++-------
 3 files changed, 14 insertions(+), 20 deletions(-)

diff --git a/include/linux/page_owner.h b/include/linux/page_owner.h
index 46f1b93..30583ab 100644
--- a/include/linux/page_owner.h
+++ b/include/linux/page_owner.h
@@ -10,7 +10,7 @@ extern struct page_ext_operations page_owner_ops;
 extern void __reset_page_owner(struct page *page, unsigned int order);
 extern void __set_page_owner(struct page *page,
 			unsigned int order, gfp_t gfp_mask);
-extern gfp_t __get_page_owner_gfp(struct page *page);
+extern void __split_page_owner(struct page *page, unsigned int order);
 extern void __copy_page_owner(struct page *oldpage, struct page *newpage);
 extern void __set_page_owner_migrate_reason(struct page *page, int reason);
 extern void __dump_page_owner(struct page *page);
@@ -28,12 +28,10 @@ static inline void set_page_owner(struct page *page,
 		__set_page_owner(page, order, gfp_mask);
 }
 
-static inline gfp_t get_page_owner_gfp(struct page *page)
+static inline void split_page_owner(struct page *page, unsigned int order)
 {
 	if (static_branch_unlikely(&page_owner_inited))
-		return __get_page_owner_gfp(page);
-	else
-		return 0;
+		__split_page_owner(page, order);
 }
 static inline void copy_page_owner(struct page *oldpage, struct page *newpage)
 {
@@ -58,9 +56,9 @@ static inline void set_page_owner(struct page *page,
 			unsigned int order, gfp_t gfp_mask)
 {
 }
-static inline gfp_t get_page_owner_gfp(struct page *page)
+static inline void split_page_owner(struct page *page,
+			unsigned int order)
 {
-	return 0;
 }
 static inline void copy_page_owner(struct page *oldpage, struct page *newpage)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 127128a..e3085eb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2466,7 +2466,6 @@ void free_hot_cold_page_list(struct list_head *list, bool cold)
 void split_page(struct page *page, unsigned int order)
 {
 	int i;
-	gfp_t gfp_mask;
 
 	VM_BUG_ON_PAGE(PageCompound(page), page);
 	VM_BUG_ON_PAGE(!page_count(page), page);
@@ -2480,12 +2479,9 @@ void split_page(struct page *page, unsigned int order)
 		split_page(virt_to_page(page[0].shadow), order);
 #endif
 
-	gfp_mask = get_page_owner_gfp(page);
-	set_page_owner(page, 0, gfp_mask);
-	for (i = 1; i < (1 << order); i++) {
+	for (i = 1; i < (1 << order); i++)
 		set_page_refcounted(page + i);
-		set_page_owner(page + i, 0, gfp_mask);
-	}
+	split_page_owner(page, order);
 }
 EXPORT_SYMBOL_GPL(split_page);
 
diff --git a/mm/page_owner.c b/mm/page_owner.c
index 73e202f..499ad26 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -94,17 +94,17 @@ void __set_page_owner_migrate_reason(struct page *page, int reason)
 	page_ext->last_migrate_reason = reason;
 }
 
-gfp_t __get_page_owner_gfp(struct page *page)
+void __split_page_owner(struct page *page, unsigned int order)
 {
+	int i;
 	struct page_ext *page_ext = lookup_page_ext(page);
+
 	if (unlikely(!page_ext))
-		/*
-		 * The caller just returns 0 if no valid gfp
-		 * So return 0 here too.
-		 */
-		return 0;
+		return;
 
-	return page_ext->gfp_mask;
+	page_ext->order = 0;
+	for (i = 1; i < (1 << order); i++)
+		__copy_page_owner(page, page + i);
 }
 
 void __copy_page_owner(struct page *oldpage, struct page *newpage)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
