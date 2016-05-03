Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A3F706B0260
	for <linux-mm@kvack.org>; Tue,  3 May 2016 01:23:18 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b203so18991949pfb.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 22:23:18 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id sj6si2342462pac.205.2016.05.02.22.23.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 22:23:17 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id c189so5320338pfb.3
        for <linux-mm@kvack.org>; Mon, 02 May 2016 22:23:17 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 4/6] mm/page_owner: introduce split_page_owner and replace manual handling
Date: Tue,  3 May 2016 14:23:02 +0900
Message-Id: <1462252984-8524-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

split_page() calls set_page_owner() to set up page_owner to each pages.
But, it has a drawback that head page and the others have different
stacktrace because callsite of set_page_owner() is slightly differnt.
To avoid this problem, this patch copies head page's page_owner to
the others. It needs to introduce new function, split_page_owner() but
it also remove the other function, get_page_owner_gfp() so looks good
to do.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/page_owner.h | 12 +++++-------
 mm/page_alloc.c            |  8 ++------
 mm/page_owner.c            |  7 +++++--
 3 files changed, 12 insertions(+), 15 deletions(-)

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
index 5b632be..7cefc90 100644
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
index 6693959..7b5a834 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -86,11 +86,14 @@ void __set_page_owner_migrate_reason(struct page *page, int reason)
 	page_ext->last_migrate_reason = reason;
 }
 
-gfp_t __get_page_owner_gfp(struct page *page)
+void __split_page_owner(struct page *page, unsigned int order)
 {
 	struct page_ext *page_ext = lookup_page_ext(page);
+	int i;
 
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
