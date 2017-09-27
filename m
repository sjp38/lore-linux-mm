Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9166B026B
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 12:03:58 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id p5so28343033pgn.7
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 09:03:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k6si7922682pgn.129.2017.09.27.09.03.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 09:03:57 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 11/15] mm: Use pagevec_lookup_range_tag() in write_cache_pages()
Date: Wed, 27 Sep 2017 18:03:30 +0200
Message-Id: <20170927160334.29513-12-jack@suse.cz>
In-Reply-To: <20170927160334.29513-1-jack@suse.cz>
References: <20170927160334.29513-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>

Use pagevec_lookup_range_tag() in write_cache_pages() as it is
interested only in pages from given range. Remove unnecessary code
resulting from this.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/page-writeback.c | 20 ++------------------
 1 file changed, 2 insertions(+), 18 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0b9c5cbe8eba..43b18e185fbd 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2194,30 +2194,14 @@ int write_cache_pages(struct address_space *mapping,
 	while (!done && (index <= end)) {
 		int i;
 
-		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index, tag,
-			      min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1);
+		nr_pages = pagevec_lookup_range_tag(&pvec, mapping, &index, end,
+				tag, PAGEVEC_SIZE);
 		if (nr_pages == 0)
 			break;
 
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
 
-			/*
-			 * At this point, the page may be truncated or
-			 * invalidated (changing page->mapping to NULL), or
-			 * even swizzled back from swapper_space to tmpfs file
-			 * mapping. However, page->index will not change
-			 * because we have a reference on the page.
-			 */
-			if (page->index > end) {
-				/*
-				 * can't be range_cyclic (1st pass) because
-				 * end == -1 in that case.
-				 */
-				done = 1;
-				break;
-			}
-
 			done_index = page->index;
 
 			lock_page(page);
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
