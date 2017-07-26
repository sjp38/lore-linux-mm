Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id BAD356B03B5
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:47:35 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 92so31557811wra.11
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 04:47:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9si8449918wrp.425.2017.07.26.04.47.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 04:47:27 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 06/10] ext4: Use pagevec_lookup_range() in writeback code
Date: Wed, 26 Jul 2017 13:47:00 +0200
Message-Id: <20170726114704.7626-7-jack@suse.cz>
In-Reply-To: <20170726114704.7626-1-jack@suse.cz>
References: <20170726114704.7626-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org

Both occurences of pagevec_lookup() actually want only pages from a
given range. Use pagevec_lookup_range() for the lookup.

CC: "Theodore Ts'o" <tytso@mit.edu>
CC: linux-ext4@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ext4/inode.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 68d0166d5ebc..eb86c1baf40c 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1676,13 +1676,13 @@ static void mpage_release_unused_pages(struct mpage_da_data *mpd,
 
 	pagevec_init(&pvec, 0);
 	while (index <= end) {
-		nr_pages = pagevec_lookup(&pvec, mapping, &index, PAGEVEC_SIZE);
+		nr_pages = pagevec_lookup_range(&pvec, mapping, &index, end,
+						PAGEVEC_SIZE);
 		if (nr_pages == 0)
 			break;
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
-			if (page->index > end)
-				break;
+
 			BUG_ON(!PageLocked(page));
 			BUG_ON(PageWriteback(page));
 			if (invalidate) {
@@ -2303,15 +2303,13 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
 
 	pagevec_init(&pvec, 0);
 	while (start <= end) {
-		nr_pages = pagevec_lookup(&pvec, inode->i_mapping, &start,
-					  PAGEVEC_SIZE);
+		nr_pages = pagevec_lookup_range(&pvec, inode->i_mapping,
+						&start, end, PAGEVEC_SIZE);
 		if (nr_pages == 0)
 			break;
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
 
-			if (page->index > end)
-				break;
 			bh = head = page_buffers(page);
 			do {
 				if (lblk < mpd->map.m_lblk)
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
