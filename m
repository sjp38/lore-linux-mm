Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0D01F6B025F
	for <linux-mm@kvack.org>; Wed, 25 May 2016 22:38:10 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c84so18156276pfc.3
        for <linux-mm@kvack.org>; Wed, 25 May 2016 19:38:10 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id g10si3004121pfa.159.2016.05.25.19.38.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 19:38:09 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id f144so447078pfa.2
        for <linux-mm@kvack.org>; Wed, 25 May 2016 19:38:09 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 4/7] mm/page_owner: introduce split_page_owner and replace manual handling
Date: Thu, 26 May 2016 11:37:52 +0900
Message-Id: <1464230275-25791-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

split_page() calls set_page_owner() to set up page_owner to each pages.
But, it has a drawback that head page and the others have different
stacktrace because callsite of set_page_owner() is slightly differnt.
To avoid this problem, this patch copies head page's page_owner to
the others. It needs to introduce new function, split_page_owner() but
it also remove the other function, get_page_owner_gfp() so looks good
to do.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
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
index 1b1ca57..616ada9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2459,7 +2459,6 @@ void free_hot_cold_page_list(struct list_head *list, bool cold)
 void split_page(struct page *page, unsigned int order)
 {
 	int i;
-	gfp_t gfp_mask;
 
 	VM_BUG_ON_PAGE(PageCompound(page), page);
 	VM_BUG_ON_PAGE(!page_count(page), page);
@@ -2473,12 +2472,9 @@ void split_page(struct page *page, unsigned int order)
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
