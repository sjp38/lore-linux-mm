Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4229B6B00E9
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 12:29:09 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/8] ext4: Warn if direct reclaim tries to writeback pages
Date: Thu, 21 Jul 2011 17:28:45 +0100
Message-Id: <1311265730-5324-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1311265730-5324-1-git-send-email-mgorman@suse.de>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>

Direct reclaim should never writeback pages. Warn if an attempt
is made.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/ext4/inode.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index e3126c0..95bb179 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -2663,8 +2663,12 @@ static int ext4_writepage(struct page *page,
 		 * We don't want to do block allocation, so redirty
 		 * the page and return.  We may reach here when we do
 		 * a journal commit via journal_submit_inode_data_buffers.
-		 * We can also reach here via shrink_page_list
+		 * We can also reach here via shrink_page_list but it
+		 * should never be for direct reclaim so warn if that
+		 * happens
 		 */
+		WARN_ON_ONCE((current->flags & (PF_MEMALLOC|PF_KSWAPD)) ==
+								PF_MEMALLOC);
 		goto redirty_page;
 	}
 	if (commit_write)
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
