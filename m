Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5426B0261
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 08:12:08 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g62so92511277pfb.3
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 05:12:08 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id m28si3879287pfj.13.2016.07.08.05.12.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 05:12:07 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id dx3so6196090pab.2
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 05:12:07 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH v2 1/3] mm/page_owner: rename page_owner functions
Date: Fri,  8 Jul 2016 21:11:30 +0900
Message-Id: <20160708121132.8253-2-sergey.senozhatsky@gmail.com>
In-Reply-To: <20160708121132.8253-1-sergey.senozhatsky@gmail.com>
References: <20160708121132.8253-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

A cosmetic change:

rename set_page_owner() and reset_page_owner() functions to
page_owner_alloc_pages()/page_owner_free_pages(). This is
sort of a preparation step for PAGE_OWNER_TRACK_FREE patch.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 include/linux/page_owner.h | 16 ++++++++--------
 mm/page_alloc.c            |  4 ++--
 mm/page_owner.c            |  6 +++---
 3 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/linux/page_owner.h b/include/linux/page_owner.h
index 30583ab..7b25953 100644
--- a/include/linux/page_owner.h
+++ b/include/linux/page_owner.h
@@ -7,25 +7,25 @@
 extern struct static_key_false page_owner_inited;
 extern struct page_ext_operations page_owner_ops;
 
-extern void __reset_page_owner(struct page *page, unsigned int order);
-extern void __set_page_owner(struct page *page,
+extern void __page_owner_free_pages(struct page *page, unsigned int order);
+extern void __page_owner_alloc_pages(struct page *page,
 			unsigned int order, gfp_t gfp_mask);
 extern void __split_page_owner(struct page *page, unsigned int order);
 extern void __copy_page_owner(struct page *oldpage, struct page *newpage);
 extern void __set_page_owner_migrate_reason(struct page *page, int reason);
 extern void __dump_page_owner(struct page *page);
 
-static inline void reset_page_owner(struct page *page, unsigned int order)
+static inline void page_owner_free_pages(struct page *page, unsigned int order)
 {
 	if (static_branch_unlikely(&page_owner_inited))
-		__reset_page_owner(page, order);
+		__page_owner_free_pages(page, order);
 }
 
-static inline void set_page_owner(struct page *page,
+static inline void page_owner_alloc_pages(struct page *page,
 			unsigned int order, gfp_t gfp_mask)
 {
 	if (static_branch_unlikely(&page_owner_inited))
-		__set_page_owner(page, order, gfp_mask);
+		__page_owner_alloc_pages(page, order, gfp_mask);
 }
 
 static inline void split_page_owner(struct page *page, unsigned int order)
@@ -49,10 +49,10 @@ static inline void dump_page_owner(struct page *page)
 		__dump_page_owner(page);
 }
 #else
-static inline void reset_page_owner(struct page *page, unsigned int order)
+static inline void page_owner_free_pages(struct page *page, unsigned int order)
 {
 }
-static inline void set_page_owner(struct page *page,
+static inline void page_owner_alloc_pages(struct page *page,
 			unsigned int order, gfp_t gfp_mask)
 {
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 63801c7..5e3cba4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1031,7 +1031,7 @@ static __always_inline bool free_pages_prepare(struct page *page,
 
 	page_cpupid_reset_last(page);
 	page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
-	reset_page_owner(page, order);
+	page_owner_free_pages(page, order);
 
 	if (!PageHighMem(page)) {
 		debug_check_no_locks_freed(page_address(page),
@@ -1770,7 +1770,7 @@ void post_alloc_hook(struct page *page, unsigned int order, gfp_t gfp_flags)
 	kernel_map_pages(page, 1 << order, 1);
 	kernel_poison_pages(page, 1 << order, 1);
 	kasan_alloc_pages(page, order);
-	set_page_owner(page, order, gfp_flags);
+	page_owner_alloc_pages(page, order, gfp_flags);
 }
 
 static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
diff --git a/mm/page_owner.c b/mm/page_owner.c
index 8fa5083..fde443a 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -85,7 +85,7 @@ struct page_ext_operations page_owner_ops = {
 	.init = init_page_owner,
 };
 
-void __reset_page_owner(struct page *page, unsigned int order)
+void __page_owner_free_pages(struct page *page, unsigned int order)
 {
 	int i;
 	struct page_ext *page_ext;
@@ -147,7 +147,7 @@ static noinline depot_stack_handle_t save_stack(gfp_t flags)
 	return handle;
 }
 
-noinline void __set_page_owner(struct page *page, unsigned int order,
+noinline void __page_owner_alloc_pages(struct page *page, unsigned int order,
 					gfp_t gfp_mask)
 {
 	struct page_ext *page_ext = lookup_page_ext(page);
@@ -452,7 +452,7 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
 				continue;
 
 			/* Found early allocated page */
-			set_page_owner(page, 0, 0);
+			__page_owner_alloc_pages(page, 0, 0);
 			count++;
 		}
 	}
-- 
2.9.0.37.g6d523a3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
