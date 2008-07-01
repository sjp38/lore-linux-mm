From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 3/4] buddy: explicitly identify buddy field use in struct page
Date: Tue,  1 Jul 2008 18:58:41 +0100
Message-Id: <1214935122-20828-4-git-send-email-apw@shadowen.org>
In-Reply-To: <1214935122-20828-1-git-send-email-apw@shadowen.org>
References: <1214935122-20828-1-git-send-email-apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
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
index 02a27ae..45eb71f 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -69,6 +69,9 @@ struct page {
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
index 0034e94..ac0f600 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -44,7 +44,7 @@ extern void __free_pages_bootmem(struct page *page, unsigned int order);
 static inline unsigned long page_order(struct page *page)
 {
 	VM_BUG_ON(!PageBuddy(page));
-	return page_private(page);
+	return page->buddy_order;
 }
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4d9c4e8..d73e1e1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -316,14 +316,14 @@ static inline void prep_zero_page(struct page *page, int order, gfp_t gfp_flags)
 
 static inline void set_page_order(struct page *page, int order)
 {
-	set_page_private(page, order);
+	page->buddy_order = order;
 	__SetPageBuddy(page);
 }
 
 static inline void rmv_page_order(struct page *page)
 {
 	__ClearPageBuddy(page);
-	set_page_private(page, 0);
+	page->buddy_order = 0;
 }
 
 /*
-- 
1.5.6.1.201.g3e7d3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
