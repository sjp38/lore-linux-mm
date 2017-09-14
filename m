Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 04CAD6B025E
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 09:18:39 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r74so82157wme.5
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 06:18:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t47si12236251eda.89.2017.09.14.06.18.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Sep 2017 06:18:37 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 04/15] ext4: Use pagevec_lookup_range_tag()
Date: Thu, 14 Sep 2017 15:18:08 +0200
Message-Id: <20170914131819.26266-5-jack@suse.cz>
In-Reply-To: <20170914131819.26266-1-jack@suse.cz>
References: <20170914131819.26266-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, Jaegeuk Kim <jaegeuk@kernel.org>, ceph-devel@vger.kernel.org, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, Jan Kara <jack@suse.cz>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org

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
