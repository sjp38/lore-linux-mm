Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 237EF600762
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:16:25 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [5/31] HWPOISON: return ENXIO on invalid page number
Message-Id: <20091208211621.50759B151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:21 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.comfengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


From: Wu Fengguang <fengguang.wu@intel.com>

Use a different errno than the usual EIO for invalid page numbers. 
This is mainly for better reporting for the injector.

This also avoids calling action_result() with invalid pfn.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/memory-failure.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

Index: linux/mm/memory-failure.c
===================================================================
--- linux.orig/mm/memory-failure.c
+++ linux/mm/memory-failure.c
@@ -620,13 +620,11 @@ static struct page_state {
 
 static void action_result(unsigned long pfn, char *msg, int result)
 {
-	struct page *page = NULL;
-	if (pfn_valid(pfn))
-		page = pfn_to_page(pfn);
+	struct page *page = pfn_to_page(pfn);
 
 	printk(KERN_ERR "MCE %#lx: %s%s page recovery: %s\n",
 		pfn,
-		page && PageDirty(page) ? "dirty " : "",
+		PageDirty(page) ? "dirty " : "",
 		msg, action_name[result]);
 }
 
@@ -752,8 +750,10 @@ int __memory_failure(unsigned long pfn,
 		panic("Memory failure from trap %d on page %lx", trapno, pfn);
 
 	if (!pfn_valid(pfn)) {
-		action_result(pfn, "memory outside kernel control", IGNORED);
-		return -EIO;
+		printk(KERN_ERR
+		       "MCE %#lx: memory outside kernel control\n",
+		       pfn);
+		return -ENXIO;
 	}
 
 	p = pfn_to_page(pfn);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
