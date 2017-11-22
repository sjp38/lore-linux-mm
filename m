Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C18326B0274
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:08:19 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 199so11235910pgg.20
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:08:19 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e39si7302529plg.511.2017.11.22.13.08.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:18 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 33/62] page cache: Convert page_cache_next_hole to XArray
Date: Wed, 22 Nov 2017 13:07:10 -0800
Message-Id: <20171122210739.29916-34-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Use xas_find_any() to scan the entries instead of doing a lookup from
the top of the tree each time.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/filemap.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 1c03b0ea105e..accc350f9544 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1349,20 +1349,15 @@ int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 pgoff_t page_cache_next_hole(struct address_space *mapping,
 			     pgoff_t index, unsigned long max_scan)
 {
-	unsigned long i;
-
-	for (i = 0; i < max_scan; i++) {
-		struct page *page;
+	XA_STATE(xas, index);
 
-		page = radix_tree_lookup(&mapping->pages, index);
-		if (!page || xa_is_value(page))
-			break;
-		index++;
-		if (index == 0)
+	while (max_scan--) {
+		void *entry = xas_find_any(&mapping->pages, &xas);
+		if (!entry || xa_is_value(entry))
 			break;
 	}
 
-	return index;
+	return xas.xa_index;
 }
 EXPORT_SYMBOL(page_cache_next_hole);
 
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
