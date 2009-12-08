Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CEFE5600762
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:16:40 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [13/31] HWPOISON: detect free buddy pages explicitly
Message-Id: <20091208211629.660E2B151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:29 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, npiggin@suse.de, mel@linux.vnet.ibm.comfengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


From: Wu Fengguang <fengguang.wu@intel.com>

Most free pages in the buddy system have no PG_buddy set.
Introduce is_free_buddy_page() for detecting them reliably.

CC: Nick Piggin <npiggin@suse.de> 
CC: Mel Gorman <mel@linux.vnet.ibm.com> 
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/internal.h       |    3 +++
 mm/memory-failure.c |    9 +++++++--
 mm/page_alloc.c     |   21 +++++++++++++++++++++
 3 files changed, 31 insertions(+), 2 deletions(-)

Index: linux/mm/memory-failure.c
===================================================================
--- linux.orig/mm/memory-failure.c
+++ linux/mm/memory-failure.c
@@ -809,8 +809,13 @@ int __memory_failure(unsigned long pfn,
 	 */
 	if (!(flags & MF_COUNT_INCREASED) &&
 		!get_page_unless_zero(compound_head(p))) {
-		action_result(pfn, "free or high order kernel", IGNORED);
-		return PageBuddy(compound_head(p)) ? 0 : -EBUSY;
+		if (is_free_buddy_page(p)) {
+			action_result(pfn, "free buddy", DELAYED);
+			return 0;
+		} else {
+			action_result(pfn, "high order kernel", IGNORED);
+			return -EBUSY;
+		}
 	}
 
 	/*
Index: linux/mm/internal.h
===================================================================
--- linux.orig/mm/internal.h
+++ linux/mm/internal.h
@@ -50,6 +50,9 @@ extern void putback_lru_page(struct page
  */
 extern void __free_pages_bootmem(struct page *page, unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned long order);
+#ifdef CONFIG_MEMORY_FAILURE
+extern bool is_free_buddy_page(struct page *page);
+#endif
 
 
 /*
Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c
+++ linux/mm/page_alloc.c
@@ -5085,3 +5085,24 @@ __offline_isolated_pages(unsigned long s
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
 #endif
+
+#ifdef CONFIG_MEMORY_FAILURE
+bool is_free_buddy_page(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long pfn = page_to_pfn(page);
+	unsigned long flags;
+	int order;
+
+	spin_lock_irqsave(&zone->lock, flags);
+	for (order = 0; order < MAX_ORDER; order++) {
+		struct page *page_head = page - (pfn & ((1 << order) - 1));
+
+		if (PageBuddy(page_head) && page_order(page_head) >= order)
+			break;
+	}
+	spin_unlock_irqrestore(&zone->lock, flags);
+
+	return order < MAX_ORDER;
+}
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
