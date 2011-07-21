Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2A3C56B00E7
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 12:29:05 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/8] xfs: Warn if direct reclaim tries to writeback pages
Date: Thu, 21 Jul 2011 17:28:44 +0100
Message-Id: <1311265730-5324-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1311265730-5324-1-git-send-email-mgorman@suse.de>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>

Direct reclaim should never writeback pages. For now, handle the
situation and warn about it. Ultimately, this will be a BUG_ON.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/xfs/linux-2.6/xfs_aops.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/xfs/linux-2.6/xfs_aops.c b/fs/xfs/linux-2.6/xfs_aops.c
index 79ce38b..c33a439 100644
--- a/fs/xfs/linux-2.6/xfs_aops.c
+++ b/fs/xfs/linux-2.6/xfs_aops.c
@@ -930,12 +930,13 @@ xfs_vm_writepage(
 	 * random callers for direct reclaim or memcg reclaim.  We explicitly
 	 * allow reclaim from kswapd as the stack usage there is relatively low.
 	 *
-	 * This should really be done by the core VM, but until that happens
-	 * filesystems like XFS, btrfs and ext4 have to take care of this
-	 * by themselves.
+	 * This should never happen except in the case of a VM regression so
+	 * warn about it.
 	 */
-	if ((current->flags & (PF_MEMALLOC|PF_KSWAPD)) == PF_MEMALLOC)
+	if ((current->flags & (PF_MEMALLOC|PF_KSWAPD)) == PF_MEMALLOC) {
+		WARN_ON_ONCE(1);
 		goto redirty;
+	}
 
 	/*
 	 * We need a transaction if there are delalloc or unwritten buffers
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
