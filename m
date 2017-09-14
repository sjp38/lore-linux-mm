Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5A16B026B
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 09:18:44 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w12so3372428wrc.2
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 06:18:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s5si6200462edd.251.2017.09.14.06.18.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Sep 2017 06:18:38 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 07/15] f2fs: Use find_get_pages_tag() for looking up single page
Date: Thu, 14 Sep 2017 15:18:11 +0200
Message-Id: <20170914131819.26266-8-jack@suse.cz>
In-Reply-To: <20170914131819.26266-1-jack@suse.cz>
References: <20170914131819.26266-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, Jaegeuk Kim <jaegeuk@kernel.org>, ceph-devel@vger.kernel.org, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, Jan Kara <jack@suse.cz>

__get_first_dirty_index() wants to lookup only the first dirty page
after given index. There's no point in using pagevec_lookup_tag() for
that. Just use find_get_pages_tag() directly.

CC: Jaegeuk Kim <jaegeuk@kernel.org>
CC: linux-f2fs-devel@lists.sourceforge.net
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
