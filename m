Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CCB366B026D
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 12:03:59 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y77so23988672pfd.2
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 09:03:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t85si7616770pfg.23.2017.09.27.09.03.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 09:03:58 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 02/15] btrfs: Use pagevec_lookup_range_tag()
Date: Wed, 27 Sep 2017 18:03:21 +0200
Message-Id: <20170927160334.29513-3-jack@suse.cz>
In-Reply-To: <20170927160334.29513-1-jack@suse.cz>
References: <20170927160334.29513-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>

We want only pages from given range in btree_write_cache_pages() and
extent_write_cache_pages(). Use pagevec_lookup_range_tag() instead of
pagevec_lookup_tag() and remove unnecessary code.

CC: linux-btrfs@vger.kernel.org
CC: David Sterba <dsterba@suse.com>
Reviewed-by: David Sterba <dsterba@suse.com>
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
