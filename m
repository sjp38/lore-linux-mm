From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 3/4] buddy: explicitly identify buddy field use in struct page
Date: Wed,  3 Sep 2008 19:44:11 +0100
Message-Id: <1220467452-15794-4-git-send-email-apw@shadowen.org>
In-Reply-To: <1220467452-15794-1-git-send-email-apw@shadowen.org>
References: <1220467452-15794-1-git-send-email-apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Explicitly define the struct page fields which buddy uses when it owns
pages.  Defines a new anonymous struct to allow additional fields to
be defined in a later patch.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 include/linux/mm_types.h |    3 +++
 mm/internal.h            |    2 +-
 mm/page_alloc.c          |    4 ++--
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 995c588..906d8e0 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -70,6 +70,9 @@ struct page {
 #endif
 	    struct kmem_cache *slab;	/* SLUB: Pointer to slab */
 	    struct page *first_page;	/* Compound tail pages */
+	    struct {
+		unsigned long buddy_order;     /* buddy: free page order */
+	    };
 	};
 	union {
 		pgoff_t index;		/* Our offset within mapping. */
diff --git a/mm/internal.h b/mm/internal.h
index c0e4859..fcedcd0 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -58,7 +58,7 @@ extern void __free_pages_bootmem(struct page *page, unsigned int order);
 static inline unsigned long page_order(struct page *page)
 {
 	VM_BUG_ON(!PageBuddy(page));
-	return page_private(page);
+	return page->buddy_order;
 }
 
 extern int mlock_vma_pages_range(struct vm_area_struct *vma,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2c3874e..db0dbd6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -331,7 +331,7 @@ static inline void prep_zero_page(struct page *page, int order, gfp_t gfp_flags)
 
 static inline void set_page_order(struct page *page, int order)
 {
-	set_page_private(page, order);
+	page->buddy_order = order;
 	__SetPageBuddy(page);
 #ifdef CONFIG_PAGE_OWNER
 		page->order = -1;
@@ -341,7 +341,7 @@ static inline void set_page_order(struct page *page, int order)
 static inline void rmv_page_order(struct page *page)
 {
 	__ClearPageBuddy(page);
-	set_page_private(page, 0);
+	page->buddy_order = 0;
 }
 
 /*
-- 
1.6.0.rc1.258.g80295

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
