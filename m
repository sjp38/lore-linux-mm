Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BD2DB6B026A
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 12:03:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y29so23943221pff.6
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 09:03:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v3si7782850plb.576.2017.09.27.09.03.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 09:03:58 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 07/15] f2fs: Use find_get_pages_tag() for looking up single page
Date: Wed, 27 Sep 2017 18:03:26 +0200
Message-Id: <20170927160334.29513-8-jack@suse.cz>
In-Reply-To: <20170927160334.29513-1-jack@suse.cz>
References: <20170927160334.29513-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net

__get_first_dirty_index() wants to lookup only the first dirty page
after given index. There's no point in using pagevec_lookup_tag() for
that. Just use find_get_pages_tag() directly.

CC: Jaegeuk Kim <jaegeuk@kernel.org>
CC: linux-f2fs-devel@lists.sourceforge.net
Reviewed-by: Chao Yu <yuchao0@huawei.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/f2fs/file.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 517e112c8a9a..f78b76ec4707 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -313,18 +313,19 @@ int f2fs_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
 static pgoff_t __get_first_dirty_index(struct address_space *mapping,
 						pgoff_t pgofs, int whence)
 {
-	struct pagevec pvec;
+	struct page *page;
 	int nr_pages;
 
 	if (whence != SEEK_DATA)
 		return 0;
 
 	/* find first dirty page index */
-	pagevec_init(&pvec, 0);
-	nr_pages = pagevec_lookup_tag(&pvec, mapping, &pgofs,
-					PAGECACHE_TAG_DIRTY, 1);
-	pgofs = nr_pages ? pvec.pages[0]->index : ULONG_MAX;
-	pagevec_release(&pvec);
+	nr_pages = find_get_pages_tag(mapping, &pgofs, PAGECACHE_TAG_DIRTY,
+				      1, &page);
+	if (!nr_pages)
+		return ULONG_MAX;
+	pgofs = page->index;
+	put_page(page);
 	return pgofs;
 }
 
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
