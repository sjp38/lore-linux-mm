Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9C66B00EA
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 12:29:14 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/8] btrfs: Warn if direct reclaim tries to writeback pages
Date: Thu, 21 Jul 2011 17:28:46 +0100
Message-Id: <1311265730-5324-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1311265730-5324-1-git-send-email-mgorman@suse.de>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>

Direct reclaim should never writeback pages. Warn if an attempt is
made. By rights, btrfs should be allowing writepage from kswapd if
it is failing to reclaim pages by any other means but it's outside
the scope of this patch.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/btrfs/disk-io.c |    2 ++
 fs/btrfs/inode.c   |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 1ac8db5d..cc9c9cf 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -829,6 +829,8 @@ static int btree_writepage(struct page *page, struct writeback_control *wbc)
 
 	tree = &BTRFS_I(page->mapping->host)->io_tree;
 	if (!(current->flags & PF_MEMALLOC)) {
+		WARN_ON_ONCE((current->flags & (PF_MEMALLOC|PF_KSWAPD)) ==
+								PF_MEMALLOC);
 		return extent_write_full_page(tree, page,
 					      btree_get_extent, wbc);
 	}
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 3601f0a..07d6c27 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -6259,6 +6259,8 @@ static int btrfs_writepage(struct page *page, struct writeback_control *wbc)
 
 
 	if (current->flags & PF_MEMALLOC) {
+		WARN_ON_ONCE((current->flags & (PF_MEMALLOC|PF_KSWAPD)) ==
+								PF_MEMALLOC);
 		redirty_page_for_writepage(wbc, page);
 		unlock_page(page);
 		return 0;
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
