Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2899D8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 15:02:31 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id v12so710786plp.16
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 12:02:31 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d4si65261819pfa.150.2019.01.07.12.02.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 07 Jan 2019 12:02:29 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH] mm: Remove redundant test from find_get_pages_contig
Date: Mon,  7 Jan 2019 12:02:24 -0800
Message-Id: <20190107200224.13260-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>

After we establish a reference on the page, we check the pointer continues
to be in the correct position in i_pages.  There's no need to check the
page->mapping or page->index afterwards; if those can change after we've
got the reference, they can change after we return the page to the caller.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 mm/filemap.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 9f5e323e883e6..935fbc29aeb13 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1837,16 +1837,6 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
 		if (unlikely(page != xas_reload(&xas)))
 			goto put_page;
 
-		/*
-		 * must check mapping and index after taking the ref.
-		 * otherwise we can get both false positives and false
-		 * negatives, which is just confusing to the caller.
-		 */
-		if (!page->mapping || page_to_pgoff(page) != xas.xa_index) {
-			put_page(page);
-			break;
-		}
-
 		pages[ret] = page;
 		if (++ret == nr_pages)
 			break;
-- 
2.20.1
