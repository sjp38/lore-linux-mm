Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2DD616B026A
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 11:14:11 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p186so2902303wmd.11
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 08:14:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q1si8196021wrc.474.2017.10.09.08.14.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Oct 2017 08:14:07 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 10/16] mm: Use pagevec_lookup_range_tag() in __filemap_fdatawait_range()
Date: Mon,  9 Oct 2017 17:13:53 +0200
Message-Id: <20171009151359.31984-11-jack@suse.cz>
In-Reply-To: <20171009151359.31984-1-jack@suse.cz>
References: <20171009151359.31984-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Daniel Jordan <daniel.m.jordan@oracle.com>, Jan Kara <jack@suse.cz>

Use pagevec_lookup_range_tag() in __filemap_fdatawait_range() as it is
interested only in pages from given range. Remove unnecessary code
resulting from this.

Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/filemap.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index cf74d0dacc6a..229481d258bc 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -420,19 +420,17 @@ static void __filemap_fdatawait_range(struct address_space *mapping,
 		return;
 
 	pagevec_init(&pvec, 0);
-	while ((index <= end) &&
-			(nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
-			PAGECACHE_TAG_WRITEBACK,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1)) != 0) {
+	while (index <= end) {
 		unsigned i;
 
+		nr_pages = pagevec_lookup_range_tag(&pvec, mapping, &index,
+				end, PAGECACHE_TAG_WRITEBACK, PAGEVEC_SIZE);
+		if (!nr_pages)
+			break;
+
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
 
-			/* until radix tree lookup accepts end_index */
-			if (page->index > end)
-				continue;
-
 			wait_on_page_writeback(page);
 			ClearPageError(page);
 		}
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
