Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6D1386B039F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:47:28 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e204so7224260wma.2
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 04:47:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v189si4028793wme.98.2017.07.26.04.47.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 04:47:27 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 08/10] fs: Use pagevec_lookup_range() in page_cache_seek_hole_data()
Date: Wed, 26 Jul 2017 13:47:02 +0200
Message-Id: <20170726114704.7626-9-jack@suse.cz>
In-Reply-To: <20170726114704.7626-1-jack@suse.cz>
References: <20170726114704.7626-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org

We want only pages from given range in page_cache_seek_hole_data(). Use
pagevec_lookup_range() instead of pagevec_lookup() and remove
unnecessary code. Note that the check for getting less pages than
desired can be removed because index gets updated by
pagevec_lookup_range().

CC: linux-fsdevel@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/buffer.c | 16 +++-------------
 1 file changed, 3 insertions(+), 13 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 7e531bb356bd..8770b58ca569 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -3549,11 +3549,10 @@ page_cache_seek_hole_data(struct inode *inode, loff_t offset, loff_t length,
 	pagevec_init(&pvec, 0);
 
 	do {
-		unsigned want, nr_pages, i;
+		unsigned nr_pages, i;
 
-		want = min_t(unsigned, end - index, PAGEVEC_SIZE);
-		nr_pages = pagevec_lookup(&pvec, inode->i_mapping, &index,
-					  want);
+		nr_pages = pagevec_lookup_range(&pvec, inode->i_mapping, &index,
+						end - 1, PAGEVEC_SIZE);
 		if (nr_pages == 0)
 			break;
 
@@ -3574,10 +3573,6 @@ page_cache_seek_hole_data(struct inode *inode, loff_t offset, loff_t length,
 			    lastoff < page_offset(page))
 				goto check_range;
 
-			/* Searching done if the page index is out of range. */
-			if (page->index >= end)
-				goto not_found;
-
 			lock_page(page);
 			if (likely(page->mapping == inode->i_mapping) &&
 			    page_has_buffers(page)) {
@@ -3590,11 +3585,6 @@ page_cache_seek_hole_data(struct inode *inode, loff_t offset, loff_t length,
 			unlock_page(page);
 			lastoff = page_offset(page) + PAGE_SIZE;
 		}
-
-		/* Searching done if fewer pages returned than wanted. */
-		if (nr_pages < want)
-			break;
-
 		pagevec_release(&pvec);
 	} while (index < end);
 
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
