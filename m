Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BA7CB6006F7
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 07:43:41 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 14/14] fs,xfs: Allow kswapd to writeback pages
Date: Tue, 29 Jun 2010 12:34:48 +0100
Message-Id: <1277811288-5195-15-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
References: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

As only kswapd and memcg are writing back pages, there should be no
danger of overflowing the stack. Allow the writing back of dirty pages
in xfs from the VM.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 fs/xfs/linux-2.6/xfs_aops.c |   15 ---------------
 1 files changed, 0 insertions(+), 15 deletions(-)

diff --git a/fs/xfs/linux-2.6/xfs_aops.c b/fs/xfs/linux-2.6/xfs_aops.c
index 34640d6..4c89db3 100644
--- a/fs/xfs/linux-2.6/xfs_aops.c
+++ b/fs/xfs/linux-2.6/xfs_aops.c
@@ -1333,21 +1333,6 @@ xfs_vm_writepage(
 	trace_xfs_writepage(inode, page, 0);
 
 	/*
-	 * Refuse to write the page out if we are called from reclaim context.
-	 *
-	 * This is primarily to avoid stack overflows when called from deep
-	 * used stacks in random callers for direct reclaim, but disabling
-	 * reclaim for kswap is a nice side-effect as kswapd causes rather
-	 * suboptimal I/O patters, too.
-	 *
-	 * This should really be done by the core VM, but until that happens
-	 * filesystems like XFS, btrfs and ext4 have to take care of this
-	 * by themselves.
-	 */
-	if (current->flags & PF_MEMALLOC)
-		goto out_fail;
-
-	/*
 	 * We need a transaction if:
 	 *  1. There are delalloc buffers on the page
 	 *  2. The page is uptodate and we have unmapped buffers
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
