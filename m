Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2659C6B025F
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:13:55 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id n3so93364013wmn.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 01:13:55 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id 124si17103661wmt.3.2016.04.11.01.13.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 01:13:54 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id BF8A398B8F
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:13:53 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 01/22] mm, page_alloc: Only check PageCompound for high-order pages
Date: Mon, 11 Apr 2016 09:13:24 +0100
Message-Id: <1460362424-26369-2-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
References: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

order-0 pages by definition cannot be compound so avoid the check in the
fast path for those pages.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 25 +++++++++++++++++--------
 1 file changed, 17 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 59de90d5d3a3..5d205bcfe10d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1024,24 +1024,33 @@ void __meminit reserve_bootmem_region(unsigned long start, unsigned long end)
 
 static bool free_pages_prepare(struct page *page, unsigned int order)
 {
-	bool compound = PageCompound(page);
-	int i, bad = 0;
+	int bad = 0;
 
 	VM_BUG_ON_PAGE(PageTail(page), page);
-	VM_BUG_ON_PAGE(compound && compound_order(page) != order, page);
 
 	trace_mm_page_free(page, order);
 	kmemcheck_free_shadow(page, order);
 	kasan_free_pages(page, order);
 
+	/*
+	 * Check tail pages before head page information is cleared to
+	 * avoid checking PageCompound for order-0 pages.
+	 */
+	if (order) {
+		bool compound = PageCompound(page);
+		int i;
+
+		VM_BUG_ON_PAGE(compound && compound_order(page) != order, page);
+
+		for (i = 1; i < (1 << order); i++) {
+			if (compound)
+				bad += free_tail_pages_check(page, page + i);
+			bad += free_pages_check(page + i);
+		}
+	}
 	if (PageAnon(page))
 		page->mapping = NULL;
 	bad += free_pages_check(page);
-	for (i = 1; i < (1 << order); i++) {
-		if (compound)
-			bad += free_tail_pages_check(page, page + i);
-		bad += free_pages_check(page + i);
-	}
 	if (bad)
 		return false;
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
