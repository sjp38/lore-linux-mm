Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2976A6B016C
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 12:27:28 -0400 (EDT)
Received: by gxk23 with SMTP id 23so4939921gxk.14
        for <linux-mm@kvack.org>; Mon, 22 Aug 2011 09:27:23 -0700 (PDT)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 2/4] debug-pagealloc: add support for highmem pages
Date: Tue, 23 Aug 2011 01:29:06 +0900
Message-Id: <1314030548-21082-3-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1314030548-21082-1-git-send-email-akinobu.mita@gmail.com>
References: <1314030548-21082-1-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>

This adds support for highmem pages poisoning and verification to the
debug-pagealloc feature for no-architecture support.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
---
 mm/debug-pagealloc.c |   61 ++++++++++++++++++++++++-------------------------
 1 files changed, 30 insertions(+), 31 deletions(-)

diff --git a/mm/debug-pagealloc.c b/mm/debug-pagealloc.c
index a4b6d70..5afe80c 100644
--- a/mm/debug-pagealloc.c
+++ b/mm/debug-pagealloc.c
@@ -1,5 +1,6 @@
 #include <linux/kernel.h>
 #include <linux/mm.h>
+#include <linux/highmem.h>
 #include <linux/page-debug-flags.h>
 #include <linux/poison.h>
 #include <linux/ratelimit.h>
@@ -19,28 +20,25 @@ static inline bool page_poison(struct page *page)
 	return test_bit(PAGE_DEBUG_FLAG_POISON, &page->debug_flags);
 }
 
-static void poison_highpage(struct page *page)
-{
-	/*
-	 * Page poisoning for highmem pages is not implemented.
-	 *
-	 * This can be called from interrupt contexts.
-	 * So we need to create a new kmap_atomic slot for this
-	 * application and it will need interrupt protection.
-	 */
-}
-
 static void poison_page(struct page *page)
 {
 	void *addr;
-
-	if (PageHighMem(page)) {
-		poison_highpage(page);
-		return;
+	unsigned long flags;
+	bool highmem = PageHighMem(page);
+
+	if (highmem) {
+		local_irq_save(flags);
+		addr = kmap_atomic(page);
+	} else {
+		addr = page_address(page);
 	}
 	set_page_poison(page);
-	addr = page_address(page);
 	memset(addr, PAGE_POISON, PAGE_SIZE);
+
+	if (highmem) {
+		kunmap_atomic(addr);
+		local_irq_restore(flags);
+	}
 }
 
 static void poison_pages(struct page *page, int n)
@@ -88,26 +86,27 @@ static void check_poison_mem(unsigned char *mem, size_t bytes)
 	dump_stack();
 }
 
-static void unpoison_highpage(struct page *page)
-{
-	/*
-	 * See comment in poison_highpage().
-	 * Highmem pages should not be poisoned for now
-	 */
-	BUG_ON(page_poison(page));
-}
-
 static void unpoison_page(struct page *page)
 {
-	if (PageHighMem(page)) {
-		unpoison_highpage(page);
+	void *addr;
+	unsigned long flags;
+	bool highmem = PageHighMem(page);
+
+	if (!page_poison(page))
 		return;
+
+	if (highmem) {
+		local_irq_save(flags);
+		addr = kmap_atomic(page);
+	} else {
+		addr = page_address(page);
 	}
-	if (page_poison(page)) {
-		void *addr = page_address(page);
+	check_poison_mem(addr, PAGE_SIZE);
+	clear_page_poison(page);
 
-		check_poison_mem(addr, PAGE_SIZE);
-		clear_page_poison(page);
+	if (highmem) {
+		kunmap_atomic(addr);
+		local_irq_restore(flags);
 	}
 }
 
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
