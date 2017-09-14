Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D29716B0281
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 09:20:29 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id d6so3354399wrd.7
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 06:20:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j3si1745612edd.462.2017.09.14.06.18.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Sep 2017 06:18:38 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 09/15] nilfs2: Use pagevec_lookup_range_tag()
Date: Thu, 14 Sep 2017 15:18:13 +0200
Message-Id: <20170914131819.26266-10-jack@suse.cz>
In-Reply-To: <20170914131819.26266-1-jack@suse.cz>
References: <20170914131819.26266-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, Jaegeuk Kim <jaegeuk@kernel.org>, ceph-devel@vger.kernel.org, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, Jan Kara <jack@suse.cz>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

We want only pages from given range in
nilfs_lookup_dirty_data_buffers(). Use pagevec_lookup_range_tag()
instead of pagevec_lookup_tag() and remove unnecessary code.

CC: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
CC: linux-nilfs@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/nilfs2/segment.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
index 70ded52dc1dd..68e5769cef3b 100644
--- a/fs/nilfs2/segment.c
+++ b/fs/nilfs2/segment.c
@@ -711,18 +711,14 @@ static size_t nilfs_lookup_dirty_data_buffers(struct inode *inode,
 	pagevec_init(&pvec, 0);
  repeat:
 	if (unlikely(index > last) ||
-	    !pagevec_lookup_tag(&pvec, mapping, &index, PAGECACHE_TAG_DIRTY,
-				min_t(pgoff_t, last - index,
-				      PAGEVEC_SIZE - 1) + 1))
+	    !pagevec_lookup_range_tag(&pvec, mapping, &index, last,
+				PAGECACHE_TAG_DIRTY, PAGEVEC_SIZE))
 		return ndirties;
 
 	for (i = 0; i < pagevec_count(&pvec); i++) {
 		struct buffer_head *bh, *head;
 		struct page *page = pvec.pages[i];
 
-		if (unlikely(page->index > last))
-			break;
-
 		lock_page(page);
 		if (!page_has_buffers(page))
 			create_empty_buffers(page, i_blocksize(inode), 0);
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
