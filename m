Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C9BB6B029C
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 14:46:26 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id 62so6695533ply.4
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 11:46:26 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a9-v6si3838138pln.89.2018.02.19.11.46.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Feb 2018 11:46:25 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v7 40/61] mm: Convert huge_memory to XArray
Date: Mon, 19 Feb 2018 11:45:35 -0800
Message-Id: <20180219194556.6575-41-willy@infradead.org>
In-Reply-To: <20180219194556.6575-1-willy@infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Quite a straightforward conversion.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/huge_memory.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4b60f55f1f8b..e0a073f0a794 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2371,7 +2371,7 @@ static void __split_huge_page_tail(struct page *head, int tail,
 	if (PageAnon(head) && !PageSwapCache(head)) {
 		page_ref_inc(page_tail);
 	} else {
-		/* Additional pin to radix tree */
+		/* Additional pin to page cache */
 		page_ref_add(page_tail, 2);
 	}
 
@@ -2442,13 +2442,13 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 	ClearPageCompound(head);
 	/* See comment in __split_huge_page_tail() */
 	if (PageAnon(head)) {
-		/* Additional pin to radix tree of swap cache */
+		/* Additional pin to swap cache */
 		if (PageSwapCache(head))
 			page_ref_add(head, 2);
 		else
 			page_ref_inc(head);
 	} else {
-		/* Additional pin to radix tree */
+		/* Additional pin to page cache */
 		page_ref_add(head, 2);
 		xa_unlock(&head->mapping->pages);
 	}
@@ -2560,7 +2560,7 @@ bool can_split_huge_page(struct page *page, int *pextra_pins)
 {
 	int extra_pins;
 
-	/* Additional pins from radix tree */
+	/* Additional pins from page cache */
 	if (PageAnon(page))
 		extra_pins = PageSwapCache(page) ? HPAGE_PMD_NR : 0;
 	else
@@ -2656,17 +2656,14 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	spin_lock_irqsave(zone_lru_lock(page_zone(head)), flags);
 
 	if (mapping) {
-		void **pslot;
+		XA_STATE(xas, &mapping->pages, page_index(head));
 
-		xa_lock(&mapping->pages);
-		pslot = radix_tree_lookup_slot(&mapping->pages,
-				page_index(head));
 		/*
-		 * Check if the head page is present in radix tree.
+		 * Check if the head page is present in page cache.
 		 * We assume all tail are present too, if head is there.
 		 */
-		if (radix_tree_deref_slot_protected(pslot,
-					&mapping->pages.xa_lock) != head)
+		xa_lock(&mapping->pages);
+		if (xas_load(&xas) != head)
 			goto fail;
 	}
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
