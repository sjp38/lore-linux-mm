Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2A13F600762
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:16:43 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [15/31] HWPOISON: make semantics of IGNORED/DELAYED clear
Message-Id: <20091208211631.6B8A1B151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:31 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.comfengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


From: Wu Fengguang <fengguang.wu@intel.com>

Change semantics for
- IGNORED: not handled; it may well be _unsafe_
- DELAYED: to be handled later; it is _safe_

With this change,
- IGNORED/FAILED mean (maybe) Error
- DELAYED/RECOVERED mean Success

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/memory-failure.c |   22 +++++++---------------
 1 file changed, 7 insertions(+), 15 deletions(-)

Index: linux/mm/memory-failure.c
===================================================================
--- linux.orig/mm/memory-failure.c
+++ linux/mm/memory-failure.c
@@ -336,16 +336,16 @@ static void collect_procs(struct page *p
  */
 
 enum outcome {
-	FAILED,		/* Error handling failed */
+	IGNORED,	/* Error: cannot be handled */
+	FAILED,		/* Error: handling failed */
 	DELAYED,	/* Will be handled later */
-	IGNORED,	/* Error safely ignored */
 	RECOVERED,	/* Successfully recovered */
 };
 
 static const char *action_name[] = {
+	[IGNORED] = "Ignored",
 	[FAILED] = "Failed",
 	[DELAYED] = "Delayed",
-	[IGNORED] = "Ignored",
 	[RECOVERED] = "Recovered",
 };
 
@@ -380,14 +380,6 @@ static int delete_from_lru_cache(struct
  */
 static int me_kernel(struct page *p, unsigned long pfn)
 {
-	return DELAYED;
-}
-
-/*
- * Already poisoned page.
- */
-static int me_ignore(struct page *p, unsigned long pfn)
-{
 	return IGNORED;
 }
 
@@ -604,7 +596,7 @@ static struct page_state {
 	char *msg;
 	int (*action)(struct page *p, unsigned long pfn);
 } error_states[] = {
-	{ reserved,	reserved,	"reserved kernel",	me_ignore },
+	{ reserved,	reserved,	"reserved kernel",	me_kernel },
 	/*
 	 * free pages are specially detected outside this table:
 	 * PG_buddy pages only make a small fraction of all free pages.
@@ -790,7 +782,7 @@ int __memory_failure(unsigned long pfn,
 
 	p = pfn_to_page(pfn);
 	if (TestSetPageHWPoison(p)) {
-		action_result(pfn, "already hardware poisoned", IGNORED);
+		printk(KERN_ERR "MCE %#lx: already hardware poisoned\n", pfn);
 		return 0;
 	}
 
@@ -845,7 +837,7 @@ int __memory_failure(unsigned long pfn,
 	 * unpoison always clear PG_hwpoison inside page lock
 	 */
 	if (!PageHWPoison(p)) {
-		action_result(pfn, "unpoisoned", IGNORED);
+		printk(KERN_ERR "MCE %#lx: just unpoisoned\n", pfn);
 		res = 0;
 		goto out;
 	}
@@ -867,7 +859,7 @@ int __memory_failure(unsigned long pfn,
 	 */
 	if (PageLRU(p) && !PageSwapCache(p) && p->mapping == NULL) {
 		action_result(pfn, "already truncated LRU", IGNORED);
-		res = 0;
+		res = -EBUSY;
 		goto out;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
