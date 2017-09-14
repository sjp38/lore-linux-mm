Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 018336B0268
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 09:18:40 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r74so82202wme.5
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 06:18:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o88si4142044edd.190.2017.09.14.06.18.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Sep 2017 06:18:37 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 02/15] btrfs: Use pagevec_lookup_range_tag()
Date: Thu, 14 Sep 2017 15:18:06 +0200
Message-Id: <20170914131819.26266-3-jack@suse.cz>
In-Reply-To: <20170914131819.26266-1-jack@suse.cz>
References: <20170914131819.26266-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, Jaegeuk Kim <jaegeuk@kernel.org>, ceph-devel@vger.kernel.org, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, Jan Kara <jack@suse.cz>, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>

We want only pages from given range in btree_write_cache_pages() and
extent_write_cache_pages(). Use pagevec_lookup_range_tag() instead of
pagevec_lookup_tag() and remove unnecessary code.

CC: linux-btrfs@vger.kernel.org
CC: David Sterba <dsterba@suse.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/btrfs/extent_io.c | 19 ++++---------------
 1 file changed, 4 insertions(+), 15 deletions(-)

diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 0f077c5db58e..9b7936ea3a88 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -3819,8 +3819,8 @@ int btree_write_cache_pages(struct address_space *mapping,
 	if (wbc->sync_mode == WB_SYNC_ALL)
 		tag_pages_for_writeback(mapping, index, end);
 	while (!done && !nr_to_write_done && (index <= end) &&
-	       (nr_pages = pagevec_lookup_tag(&pvec, mapping, &index, tag,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1))) {
+	       (nr_pages = pagevec_lookup_range_tag(&pvec, mapping, &index, end,
+			tag, PAGEVEC_SIZE))) {
 		unsigned i;
 
 		scanned = 1;
@@ -3830,11 +3830,6 @@ int btree_write_cache_pages(struct address_space *mapping,
 			if (!PagePrivate(page))
 				continue;
 
-			if (!wbc->range_cyclic && page->index > end) {
-				done = 1;
-				break;
-			}
-
 			spin_lock(&mapping->private_lock);
 			if (!PagePrivate(page)) {
 				spin_unlock(&mapping->private_lock);
@@ -3966,8 +3961,8 @@ static int extent_write_cache_pages(struct address_space *mapping,
 		tag_pages_for_writeback(mapping, index, end);
 	done_index = index;
 	while (!done && !nr_to_write_done && (index <= end) &&
-	       (nr_pages = pagevec_lookup_tag(&pvec, mapping, &index, tag,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1))) {
+	       (nr_pages = pagevec_lookup_range_tag(&pvec, mapping, &index, end,
+			tag, PAGEVEC_SIZE))) {
 		unsigned i;
 
 		scanned = 1;
@@ -3992,12 +3987,6 @@ static int extent_write_cache_pages(struct address_space *mapping,
 				continue;
 			}
 
-			if (!wbc->range_cyclic && page->index > end) {
-				done = 1;
-				unlock_page(page);
-				continue;
-			}
-
 			if (wbc->sync_mode != WB_SYNC_NONE) {
 				if (PageWriteback(page))
 					flush_fn(data);
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
