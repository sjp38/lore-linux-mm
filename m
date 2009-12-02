From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 04/24] HWPOISON: return ENXIO on invalid pfn
Date: Wed, 02 Dec 2009 11:12:35 +0800
Message-ID: <20091202043044.067424289@intel.com>
References: <20091202031231.735876003@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 10E136B0062
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 23:37:36 -0500 (EST)
Content-Disposition: inline; filename=hwpoison-action_result-valid-pfn.patch
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Return ENXIO to indicate "No such device or address".
This also avoids calling action_result() with invalid pfn.

CC: Andi Kleen <andi@firstfloor.org> 
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/memory-failure.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

--- linux-mm.orig/mm/memory-failure.c	2009-11-02 10:26:17.000000000 +0800
+++ linux-mm/mm/memory-failure.c	2009-11-02 10:26:17.000000000 +0800
@@ -598,13 +598,11 @@ static struct page_state {
 
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
 
@@ -730,8 +728,10 @@ int __memory_failure(unsigned long pfn, 
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
