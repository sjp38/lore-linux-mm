Date: Tue, 11 Mar 2008 21:33:18 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: grow_dev_page's __GFP_MOVABLE
Message-ID: <Pine.LNX.4.64.0803112116380.18085@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Mel,

I'm (slightly) worried by your __GFP_MOVABLE in grow_dev_page:
is it valid, given that we come here for filesystem metadata pages
- don't we?  If it is valid, then wouldn't adding __GFP_HIGHMEM
be valid there also?  It'd be very nice to have __GFP_MOVABLE and
__GFP_HIGHMEM on all blockdev pages, but we've concluded in the
past that __GFP_HIGHMEM cannot be allowed without large kmapping
mods throughout the filesystems.  Go back to GFP_NOFS there?

Hugh

--- 2.6.25-rc5/fs/buffer.c	2008-03-05 10:47:40.000000000 +0000
+++ linux/fs/buffer.c	2008-03-11 21:21:10.000000000 +0000
@@ -1029,8 +1029,7 @@ grow_dev_page(struct block_device *bdev,
 	struct page *page;
 	struct buffer_head *bh;
 
-	page = find_or_create_page(inode->i_mapping, index,
-		(mapping_gfp_mask(inode->i_mapping) & ~__GFP_FS)|__GFP_MOVABLE);
+	page = find_or_create_page(inode->i_mapping, index, GFP_NOFS);
 	if (!page)
 		return NULL;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
