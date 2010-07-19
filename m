Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 251576007F3
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 09:11:40 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 5/8] fs,btrfs: Allow kswapd to writeback pages
Date: Mon, 19 Jul 2010 14:11:27 +0100
Message-Id: <1279545090-19169-6-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

As only kswapd and memcg are writing back pages, there should be no
danger of overflowing the stack. Allow the writing back of dirty pages
in btrfs from the VM.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 fs/btrfs/disk-io.c |   21 +--------------------
 fs/btrfs/inode.c   |    6 ------
 2 files changed, 1 insertions(+), 26 deletions(-)

diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 34f7c37..e4aa547 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -696,26 +696,7 @@ static int btree_writepage(struct page *page, struct writeback_control *wbc)
 	int was_dirty;
 
 	tree = &BTRFS_I(page->mapping->host)->io_tree;
-	if (!(current->flags & PF_MEMALLOC)) {
-		return extent_write_full_page(tree, page,
-					      btree_get_extent, wbc);
-	}
-
-	redirty_page_for_writepage(wbc, page);
-	eb = btrfs_find_tree_block(root, page_offset(page),
-				      PAGE_CACHE_SIZE);
-	WARN_ON(!eb);
-
-	was_dirty = test_and_set_bit(EXTENT_BUFFER_DIRTY, &eb->bflags);
-	if (!was_dirty) {
-		spin_lock(&root->fs_info->delalloc_lock);
-		root->fs_info->dirty_metadata_bytes += PAGE_CACHE_SIZE;
-		spin_unlock(&root->fs_info->delalloc_lock);
-	}
-	free_extent_buffer(eb);
-
-	unlock_page(page);
-	return 0;
+	return extent_write_full_page(tree, page, btree_get_extent, wbc);
 }
 
 static int btree_writepages(struct address_space *mapping,
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 1bff92a..5c0e604 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -5859,12 +5859,6 @@ static int btrfs_writepage(struct page *page, struct writeback_control *wbc)
 {
 	struct extent_io_tree *tree;
 
-
-	if (current->flags & PF_MEMALLOC) {
-		redirty_page_for_writepage(wbc, page);
-		unlock_page(page);
-		return 0;
-	}
 	tree = &BTRFS_I(page->mapping->host)->io_tree;
 	return extent_write_full_page(tree, page, btrfs_get_extent, wbc);
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
