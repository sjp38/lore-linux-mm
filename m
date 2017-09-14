Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1FCE56B026F
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 09:18:44 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id d6so3349477wrd.7
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 06:18:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k44si20332072edd.267.2017.09.14.06.18.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Sep 2017 06:18:38 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 10/15] mm: Use pagevec_lookup_range_tag() in __filemap_fdatawait_range()
Date: Thu, 14 Sep 2017 15:18:14 +0200
Message-Id: <20170914131819.26266-11-jack@suse.cz>
In-Reply-To: <20170914131819.26266-1-jack@suse.cz>
References: <20170914131819.26266-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, Jaegeuk Kim <jaegeuk@kernel.org>, ceph-devel@vger.kernel.org, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, Jan Kara <jack@suse.cz>

Use pagevec_lookup_range_tag() in __filemap_fdatawait_range() as it is
interested only in pages from given range. Remove unnecessary code
resulting from this.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/filemap.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index fe20329c83cd..479fc54b7cd1 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -421,18 +421,13 @@ static void __filemap_fdatawait_range(struct address_space *mapping,
 
 	pagevec_init(&pvec, 0);
 	while ((index <= end) &&
-			(nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
-			PAGECACHE_TAG_WRITEBACK,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1)) != 0) {
+			(nr_pages = pagevec_lookup_range_tag(&pvec, mapping,
+			&index, end, PAGECACHE_TAG_WRITEBACK, PAGEVEC_SIZE))) {
 		unsigned i;
 
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
