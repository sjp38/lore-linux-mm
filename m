Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E10A66B026B
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 09:18:43 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 187so96291wmn.2
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 06:18:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s14si14595927edb.425.2017.09.14.06.18.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Sep 2017 06:18:38 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 05/15] f2fs: Use pagevec_lookup_range_tag()
Date: Thu, 14 Sep 2017 15:18:09 +0200
Message-Id: <20170914131819.26266-6-jack@suse.cz>
In-Reply-To: <20170914131819.26266-1-jack@suse.cz>
References: <20170914131819.26266-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, Jaegeuk Kim <jaegeuk@kernel.org>, ceph-devel@vger.kernel.org, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, Jan Kara <jack@suse.cz>

We want only pages from given range in f2fs_write_cache_pages(). Use
pagevec_lookup_range_tag() instead of pagevec_lookup_tag() and remove
unnecessary code.

CC: Jaegeuk Kim <jaegeuk@kernel.org>
CC: linux-f2fs-devel@lists.sourceforge.net
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/f2fs/data.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 36b535207c88..17d2c2997ddd 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -1669,8 +1669,8 @@ static int f2fs_write_cache_pages(struct address_space *mapping,
 	while (!done && (index <= end)) {
 		int i;
 
-		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index, tag,
-			      min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1);
+		nr_pages = pagevec_lookup_range_tag(&pvec, mapping, &index, end,
+				tag, PAGEVEC_SIZE);
 		if (nr_pages == 0)
 			break;
 
@@ -1678,11 +1678,6 @@ static int f2fs_write_cache_pages(struct address_space *mapping,
 			struct page *page = pvec.pages[i];
 			bool submitted = false;
 
-			if (page->index > end) {
-				done = 1;
-				break;
-			}
-
 			done_index = page->index;
 retry_write:
 			lock_page(page);
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
