Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D13216B01AD
	for <linux-mm@kvack.org>; Tue, 25 May 2010 14:17:15 -0400 (EDT)
Date: Tue, 25 May 2010 14:17:11 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH] xfs: skip writeback from reclaim context
Message-ID: <20100525181711.GA4119@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: xfs@oss.sgi.com
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Allowing writeback from reclaim context causes massive problems with stack
overflows as we can call into the writeback code which tends to be a heavy
stack user both in the generic code and XFS from random contexts that
perform memory allocations.

Follow the example of btrfs (and in slightly different form ext4) and refuse
to write out data from reclaim context.  This issue should really be handled
by the VM so that we can tune better for this case, but until we get it
sorted out there we have to hack around this in each filesystem with a
complex writeback path.

Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: xfs/fs/xfs/linux-2.6/xfs_aops.c
===================================================================
--- xfs.orig/fs/xfs/linux-2.6/xfs_aops.c	2010-05-25 11:40:59.068253457 +0200
+++ xfs/fs/xfs/linux-2.6/xfs_aops.c	2010-05-25 18:25:39.575011803 +0200
@@ -1326,6 +1326,21 @@ xfs_vm_writepage(
 	trace_xfs_writepage(inode, page, 0);
 
 	/*
+	 * Refuse to write the page out if we are called from reclaim context.
+	 *
+	 * This is primarily to avoid stack overflows when called from deep
+	 * used stacks in random callers for direct reclaim, but disabling
+	 * reclaim for kswap is a nice side-effect as kswapd causes rather
+	 * suboptimal I/O patters, too.
+	 *
+	 * This should really be done by the core VM, but until that happens
+	 * filesystems like XFS, btrfs and ext4 have to take care of this
+	 * by themselves.
+	 */
+	if (current->flags & PF_MEMALLOC)
+		goto out_fail;
+
+	/*
 	 * We need a transaction if:
 	 *  1. There are delalloc buffers on the page
 	 *  2. The page is uptodate and we have unmapped buffers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
