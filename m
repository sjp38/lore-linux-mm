Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7693A6B0266
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 12:03:58 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 6so28401929pgh.0
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 09:03:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l14si1318780pga.432.2017.09.27.09.03.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 09:03:57 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 04/15] ext4: Use pagevec_lookup_range_tag()
Date: Wed, 27 Sep 2017 18:03:23 +0200
Message-Id: <20170927160334.29513-5-jack@suse.cz>
In-Reply-To: <20170927160334.29513-1-jack@suse.cz>
References: <20170927160334.29513-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org

We want only pages from given range in ext4_writepages(). Use
pagevec_lookup_range_tag() instead of pagevec_lookup_tag() and remove
unnecessary code.

CC: "Theodore Ts'o" <tytso@mit.edu>
CC: linux-ext4@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ext4/inode.c | 14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 31db875bc7a1..69f11233d0d6 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -2619,8 +2619,8 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 	mpd->map.m_len = 0;
 	mpd->next_page = index;
 	while (index <= end) {
-		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index, tag,
-			      min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1);
+		nr_pages = pagevec_lookup_range_tag(&pvec, mapping, &index, end,
+				tag, PAGEVEC_SIZE);
 		if (nr_pages == 0)
 			goto out;
 
@@ -2628,16 +2628,6 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 			struct page *page = pvec.pages[i];
 
 			/*
-			 * At this point, the page may be truncated or
-			 * invalidated (changing page->mapping to NULL), or
-			 * even swizzled back from swapper_space to tmpfs file
-			 * mapping. However, page->index will not change
-			 * because we have a reference on the page.
-			 */
-			if (page->index > end)
-				goto out;
-
-			/*
 			 * Accumulated enough dirty pages? This doesn't apply
 			 * to WB_SYNC_ALL mode. For integrity sync we have to
 			 * keep going because someone may be concurrently
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
