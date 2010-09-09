Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 31CE56B004A
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 07:11:49 -0400 (EDT)
Date: Thu, 9 Sep 2010 12:11:32 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: [RFC PATCH] fs,xfs: Use __GFP_MOVABLE for XFS buffers
Message-ID: <20100909111131.GO29263@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: xfs@oss.sgi.com
Cc: Alex Elder <aelder@sgi.com>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Fragmentation avoidance in the kernel depends on reclaimable and movable
allocations being marked-up at page allocation time. Reclaimable allocations
refer to slab caches such as inode caches which can be reclaimed although
not necessarily in a targetted fashion. Movable pages are those pages that
can be moved to backing storage (during page reclaim) or migrated.

When testing against XFS, it was noticed that large page allocation rates
against XFS were far lower than expected in comparison to ext3. Investigation
showed that buffer pages allocated by XFS are placed on the LRU but not
marked __GFP_MOVABLE at allocation time.

This patch updates xb_to_gfp() to specify __GFP_MOVABLE and is correct iff
all pages allocated from a mask derived from xb_to_gfp() are guaranteed to
be movable be it via page reclaim or page migration. It needs an XFS expert
to make that determination but when applied, huge page allocation success
rates are similar to those seen on tests backed by ext3.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 fs/xfs/linux-2.6/xfs_buf.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/xfs/linux-2.6/xfs_buf.c b/fs/xfs/linux-2.6/xfs_buf.c
index ea79072..93f3fb0 100644
--- a/fs/xfs/linux-2.6/xfs_buf.c
+++ b/fs/xfs/linux-2.6/xfs_buf.c
@@ -67,7 +67,7 @@ struct workqueue_struct *xfsconvertd_workqueue;
 
 #define xb_to_gfp(flags) \
 	((((flags) & XBF_READ_AHEAD) ? __GFP_NORETRY : \
-	  ((flags) & XBF_DONT_BLOCK) ? GFP_NOFS : GFP_KERNEL) | __GFP_NOWARN)
+	  ((flags) & XBF_DONT_BLOCK) ? GFP_NOFS : GFP_KERNEL) | __GFP_NOWARN | __GFP_MOVABLE)
 
 #define xb_to_km(flags) \
 	 (((flags) & XBF_DONT_BLOCK) ? KM_NOFS : KM_SLEEP)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
