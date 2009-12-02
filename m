From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 11/24] HWPOISON: detect free buddy pages explicitly
Date: Wed, 02 Dec 2009 11:12:42 +0800
Message-ID: <20091202043045.016245713@intel.com>
References: <20091202031231.735876003@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 62B3B6007AF
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 23:37:38 -0500 (EST)
Content-Disposition: inline; filename=hwpoison-is-free-page.patch
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Most free pages in the buddy system have no PG_buddy set.
Introduce is_free_buddy_page() for detecting them reliably.

CC: Andi Kleen <andi@firstfloor.org>
CC: Nick Piggin <npiggin@suse.de> 
CC: Mel Gorman <mel@linux.vnet.ibm.com> 
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/internal.h       |    3 +++
 mm/memory-failure.c |    9 +++++++--
 mm/page_alloc.c     |   21 +++++++++++++++++++++
 3 files changed, 31 insertions(+), 2 deletions(-)

--- linux-mm.orig/mm/memory-failure.c	2009-11-30 20:04:51.000000000 +0800
+++ linux-mm/mm/memory-failure.c	2009-11-30 20:06:00.000000000 +0800
@@ -783,8 +783,13 @@ int __memory_failure(unsigned long pfn, 
 	 * that may make page_freeze_refs()/page_unfreeze_refs() mismatch.
 	 */
 	if (!ref && !get_page_unless_zero(compound_head(p))) {
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
--- linux-mm.orig/mm/internal.h	2009-11-30 11:08:34.000000000 +0800
+++ linux-mm/mm/internal.h	2009-11-30 20:06:01.000000000 +0800
@@ -50,6 +50,9 @@ extern void putback_lru_page(struct page
  */
 extern void __free_pages_bootmem(struct page *page, unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned long order);
+#ifdef CONFIG_MEMORY_FAILURE
+extern bool is_free_buddy_page(struct page *page);
+#endif
 
 
 /*
--- linux-mm.orig/mm/page_alloc.c	2009-11-30 11:08:34.000000000 +0800
+++ linux-mm/mm/page_alloc.c	2009-11-30 20:06:01.000000000 +0800
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
