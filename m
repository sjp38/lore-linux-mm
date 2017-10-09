Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 28F306B0268
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 11:15:49 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i124so4564285wmf.1
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 08:15:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t27si7711777wrb.320.2017.10.09.08.14.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Oct 2017 08:14:07 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 09/16] nilfs2: Use pagevec_lookup_range_tag()
Date: Mon,  9 Oct 2017 17:13:52 +0200
Message-Id: <20171009151359.31984-10-jack@suse.cz>
In-Reply-To: <20171009151359.31984-1-jack@suse.cz>
References: <20171009151359.31984-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Daniel Jordan <daniel.m.jordan@oracle.com>, Jan Kara <jack@suse.cz>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

We want only pages from given range in
nilfs_lookup_dirty_data_buffers(). Use pagevec_lookup_range_tag()
instead of pagevec_lookup_tag() and remove unnecessary code.

CC: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
CC: linux-nilfs@vger.kernel.org
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Acked-by: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
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
