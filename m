Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CBD116B03BD
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:47:35 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u89so31541358wrc.1
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 04:47:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q21si13387412wra.478.2017.07.26.04.47.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 04:47:27 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 09/10] mm: Use find_get_pages_range() in filemap_range_has_page()
Date: Wed, 26 Jul 2017 13:47:03 +0200
Message-Id: <20170726114704.7626-10-jack@suse.cz>
In-Reply-To: <20170726114704.7626-1-jack@suse.cz>
References: <20170726114704.7626-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>

We want only pages from given range in filemap_range_has_page(),
furthermore we want at most a single page. So use find_get_pages_range()
instead of pagevec_lookup() and remove unnecessary code.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/filemap.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index b02be926a115..871c974f0bb3 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -402,8 +402,7 @@ bool filemap_range_has_page(struct address_space *mapping,
 {
 	pgoff_t index = start_byte >> PAGE_SHIFT;
 	pgoff_t end = end_byte >> PAGE_SHIFT;
-	struct pagevec pvec;
-	bool ret;
+	struct page *page;
 
 	if (end_byte < start_byte)
 		return false;
@@ -411,12 +410,10 @@ bool filemap_range_has_page(struct address_space *mapping,
 	if (mapping->nrpages == 0)
 		return false;
 
-	pagevec_init(&pvec, 0);
-	if (!pagevec_lookup(&pvec, mapping, &index, 1))
+	if (!find_get_pages_range(mapping, &index, end, 1, &page))
 		return false;
-	ret = (pvec.pages[0]->index <= end);
-	pagevec_release(&pvec);
-	return ret;
+	put_page(page);
+	return true;
 }
 EXPORT_SYMBOL(filemap_range_has_page);
 
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
