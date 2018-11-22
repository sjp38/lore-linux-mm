Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B48E36B2D69
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 16:32:36 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id o17so3159730pgi.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 13:32:36 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e8si8528398pfc.248.2018.11.22.13.32.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Nov 2018 13:32:35 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 1/2] mm: Remove redundant test from find_get_pages_contig
Date: Thu, 22 Nov 2018 13:32:23 -0800
Message-Id: <20181122213224.12793-2-willy@infradead.org>
In-Reply-To: <20181122213224.12793-1-willy@infradead.org>
References: <20181122213224.12793-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>

After we establish a reference on the page, we check the pointer continues
to be in the correct position in i_pages.  There's no need to check the
page->mapping or page->index afterwards; if those can change after we've
got the reference, they can change after we return the page to the caller.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 mm/filemap.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 81adec8ee02cc..538531590ef2d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1776,16 +1776,6 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
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
2.19.1
