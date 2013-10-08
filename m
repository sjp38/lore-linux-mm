Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f207.google.com (mail-ob0-f207.google.com [209.85.214.207])
	by kanga.kvack.org (Postfix) with ESMTP id 515BD6B004D
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 12:48:42 -0400 (EDT)
Received: by mail-ob0-f207.google.com with SMTP id wo20so16958obc.2
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 09:48:42 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/2] fs: buffer: move allocation failure loop into the allocator
Date: Tue,  8 Oct 2013 16:58:10 -0400
Message-Id: <1381265890-11333-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1381265890-11333-1-git-send-email-hannes@cmpxchg.org>
References: <1381265890-11333-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Buffer allocation has a very crude indefinite loop around waking the
flusher threads and performing global NOFS direct reclaim because it
can not handle allocation failures.

The most immediate problem with this is that the allocation may fail
due to a memory cgroup limit, where flushers + direct reclaim might
not make any progress towards resolving the situation at all.  Because
unlike the global case, a memory cgroup may not have any cache at all,
only anonymous pages but no swap.  This situation will lead to a
reclaim livelock with insane IO from waking the flushers and thrashing
unrelated filesystem cache in a tight loop.

Use __GFP_NOFAIL allocations for buffers for now.  This makes sure
that any looping happens in the page allocator, which knows how to
orchestrate kswapd, direct reclaim, and the flushers sensibly.  It
also allows memory cgroups to detect allocations that can't handle
failure and will allow them to ultimately bypass the limit if reclaim
can not make progress.

Reported-by: azurIt <azurit@pobox.sk>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: stable@kernel.org
---
 fs/buffer.c     | 14 ++++++++++++--
 mm/memcontrol.c |  2 ++
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 4d74335..6024877 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1005,9 +1005,19 @@ grow_dev_page(struct block_device *bdev, sector_t block,
 	struct buffer_head *bh;
 	sector_t end_block;
 	int ret = 0;		/* Will call free_more_memory() */
+	gfp_t gfp_mask;
 
-	page = find_or_create_page(inode->i_mapping, index,
-		(mapping_gfp_mask(inode->i_mapping) & ~__GFP_FS)|__GFP_MOVABLE);
+	gfp_mask = mapping_gfp_mask(inode->i_mapping) & ~__GFP_FS;
+	gfp_mask |= __GFP_MOVABLE;
+	/*
+	 * XXX: __getblk_slow() can not really deal with failure and
+	 * will endlessly loop on improvised global reclaim.  Prefer
+	 * looping in the allocator rather than here, at least that
+	 * code knows what it's doing.
+	 */
+	gfp_mask |= __GFP_NOFAIL;
+
+	page = find_or_create_page(inode->i_mapping, index, gfp_mask);
 	if (!page)
 		return ret;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b39dfac..e233aa1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2764,6 +2764,8 @@ done:
 	return 0;
 nomem:
 	*ptr = NULL;
+	if (gfp_mask & __GFP_NOFAIL)
+		return 0;
 	return -ENOMEM;
 bypass:
 	*ptr = root_mem_cgroup;
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
