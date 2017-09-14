Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 439D16B0274
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 09:18:50 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f4so73140wmh.7
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 06:18:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 64si1036618edo.435.2017.09.14.06.18.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Sep 2017 06:18:38 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 08/15] gfs2: Use pagevec_lookup_range_tag()
Date: Thu, 14 Sep 2017 15:18:12 +0200
Message-Id: <20170914131819.26266-9-jack@suse.cz>
In-Reply-To: <20170914131819.26266-1-jack@suse.cz>
References: <20170914131819.26266-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, Jaegeuk Kim <jaegeuk@kernel.org>, ceph-devel@vger.kernel.org, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, Jan Kara <jack@suse.cz>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

We want only pages from given range in gfs2_write_cache_jdata(). Use
pagevec_lookup_range_tag() instead of pagevec_lookup_tag() and remove
unnecessary code.

CC: Bob Peterson <rpeterso@redhat.com>
CC: cluster-devel@redhat.com
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/gfs2/aops.c | 20 ++------------------
 1 file changed, 2 insertions(+), 18 deletions(-)

diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
index 68ed06962537..d0848d9623fb 100644
--- a/fs/gfs2/aops.c
+++ b/fs/gfs2/aops.c
@@ -280,22 +280,6 @@ static int gfs2_write_jdata_pagevec(struct address_space *mapping,
 	for(i = 0; i < nr_pages; i++) {
 		struct page *page = pvec->pages[i];
 
-		/*
-		 * At this point, the page may be truncated or
-		 * invalidated (changing page->mapping to NULL), or
-		 * even swizzled back from swapper_space to tmpfs file
-		 * mapping. However, page->index will not change
-		 * because we have a reference on the page.
-		 */
-		if (page->index > end) {
-			/*
-			 * can't be range_cyclic (1st pass) because
-			 * end == -1 in that case.
-			 */
-			ret = 1;
-			break;
-		}
-
 		*done_index = page->index;
 
 		lock_page(page);
@@ -413,8 +397,8 @@ static int gfs2_write_cache_jdata(struct address_space *mapping,
 		tag_pages_for_writeback(mapping, index, end);
 	done_index = index;
 	while (!done && (index <= end)) {
-		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index, tag,
-			      min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1);
+		nr_pages = pagevec_lookup_range_tag(&pvec, mapping, &index, end,
+				tag, PAGEVEC_SIZE);
 		if (nr_pages == 0)
 			break;
 
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
