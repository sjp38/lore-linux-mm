From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 19/22] HWPOISON: detect free buddy pages explicitly
Date: Mon, 15 Jun 2009 10:45:39 +0800
Message-ID: <20090615031255.006086951@intel.com>
References: <20090615024520.786814520@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A1A7E6B008C
	for <linux-mm@kvack.org>; Sun, 14 Jun 2009 23:14:39 -0400 (EDT)
Content-Disposition: inline; filename=hwpoison-is-free-page.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

The free pages in the buddy system may well have no PG_buddy set.
Introduce is_free_buddy_page() for detecting them reliably.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/internal.h       |    3 +++
 mm/memory-failure.c |   24 +++++++++---------------
 mm/page_alloc.c     |   16 ++++++++++++++++
 3 files changed, 28 insertions(+), 15 deletions(-)

--- sound-2.6.orig/mm/memory-failure.c
+++ sound-2.6/mm/memory-failure.c
@@ -324,15 +324,15 @@ struct hwpoison_control {
  * Do nothing, try to be lucky and not touch this instead. For a few cases we
  * could be more sophisticated.
  */
-static int me_kernel(struct hwpoison_control *hpc)
+static int me_slab(struct hwpoison_control *hpc)
 {
 	return DELAYED;
 }
 
 /*
- * Already poisoned page.
+ * Reserved kernel page.
  */
-static int me_ignore(struct hwpoison_control *hpc)
+static int me_reserved(struct hwpoison_control *hpc)
 {
 	return IGNORED;
 }
@@ -347,14 +347,6 @@ static int me_unknown(struct hwpoison_co
 }
 
 /*
- * Free memory
- */
-static int me_free(struct hwpoison_control *hpc)
-{
-	return DELAYED;
-}
-
-/*
  * Clean (or cleaned) page cache page.
  */
 static int me_pagecache_clean(struct hwpoison_control *hpc)
@@ -539,15 +531,14 @@ static struct page_state {
 	char *msg;
 	int (*action)(struct hwpoison_control *hpc);
 } error_states[] = {
-	{ reserved,	reserved,	"reserved kernel",	me_ignore },
-	{ buddy,	buddy,		"free kernel",	me_free },
+	{ reserved,	reserved,	"reserved kernel", me_reserved },
 
 	/*
 	 * Could in theory check if slab page is free or if we can drop
 	 * currently unused objects without touching them. But just
 	 * treat it as standard kernel for now.
 	 */
-	{ slab,		slab,		"kernel slab",	me_kernel },
+	{ slab,		slab,		"kernel slab",	me_slab },
 
 #ifdef CONFIG_PAGEFLAGS_EXTENDED
 	{ head,		head,		"huge",		me_huge_page },
@@ -756,7 +747,10 @@ void memory_failure(unsigned long pfn, i
 	 * that may make page_freeze_refs()/page_unfreeze_refs() mismatch.
 	 */
 	if (!get_page_unless_zero(p)) {
-		action_result(&hpc, "free or high order kernel", IGNORED);
+		if (is_free_buddy_page(p))
+			action_result(&hpc, "free buddy", DELAYED);
+		else
+			action_result(&hpc, "high order kernel", IGNORED);
 		return;
 	}
 
--- sound-2.6.orig/mm/internal.h
+++ sound-2.6/mm/internal.h
@@ -49,6 +49,9 @@ extern void putback_lru_page(struct page
 extern unsigned long highest_memmap_pfn;
 extern void __free_pages_bootmem(struct page *page, unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned long order);
+#ifdef CONFIG_MEMORY_FAILURE
+extern bool is_free_buddy_page(struct page *page);
+#endif
 
 
 /*
--- sound-2.6.orig/mm/page_alloc.c
+++ sound-2.6/mm/page_alloc.c
@@ -4966,3 +4966,19 @@ __offline_isolated_pages(unsigned long s
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
 #endif
+
+#ifdef CONFIG_MEMORY_FAILURE
+bool is_free_buddy_page(struct page *page)
+{
+	int pfn = page_to_pfn(page);
+	int order;
+
+	for (order = 0; order < MAX_ORDER; order++) {
+		struct page *page_head = page - (pfn & ((1 << order) - 1));
+
+		if (PageBuddy(page_head) && page_order(page_head) >= order)
+			return true;
+	}
+	return false;
+}
+#endif

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
