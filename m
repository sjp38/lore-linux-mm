Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D4DF76007B9
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:16:51 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [12/31] HWPOISON: remove the free buddy page handler
Message-Id: <20091208211628.63512B151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:28 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.comfengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


From: Wu Fengguang <fengguang.wu@intel.com>

The buddy page has already be handled in the very beginning.
So remove redundant code.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/memory-failure.c |   14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

Index: linux/mm/memory-failure.c
===================================================================
--- linux.orig/mm/memory-failure.c
+++ linux/mm/memory-failure.c
@@ -401,14 +401,6 @@ static int me_unknown(struct page *p, un
 }
 
 /*
- * Free memory
- */
-static int me_free(struct page *p, unsigned long pfn)
-{
-	return DELAYED;
-}
-
-/*
  * Clean (or cleaned) page cache page.
  */
 static int me_pagecache_clean(struct page *p, unsigned long pfn)
@@ -604,7 +596,6 @@ static int me_huge_page(struct page *p,
 #define tail		(1UL << PG_tail)
 #define compound	(1UL << PG_compound)
 #define slab		(1UL << PG_slab)
-#define buddy		(1UL << PG_buddy)
 #define reserved	(1UL << PG_reserved)
 
 static struct page_state {
@@ -614,7 +605,10 @@ static struct page_state {
 	int (*action)(struct page *p, unsigned long pfn);
 } error_states[] = {
 	{ reserved,	reserved,	"reserved kernel",	me_ignore },
-	{ buddy,	buddy,		"free kernel",	me_free },
+	/*
+	 * free pages are specially detected outside this table:
+	 * PG_buddy pages only make a small fraction of all free pages.
+	 */
 
 	/*
 	 * Could in theory check if slab page is free or if we can drop

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
