Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 489456B0260
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 09:13:16 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id d65so9918937ith.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 06:13:16 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10137.outbound.protection.outlook.com. [40.107.1.137])
        by mx.google.com with ESMTPS id i21si19345928otb.126.2016.08.01.06.13.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 06:13:15 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] radix-tree: account nodes to memcg only if explicitly requested
Date: Mon, 1 Aug 2016 16:13:08 +0300
Message-ID: <1470057188-7864-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Radix trees may be used not only for storing page cache pages, so
unconditionally accounting radix tree nodes to the current memory cgroup
is bad: if a radix tree node is used for storing data shared among
different cgroups we risk pinning dead memory cgroups forever. So let's
only account radix tree nodes if it was explicitly requested by passing
__GFP_ACCOUNT to INIT_RADIX_TREE. Currently, we only want to account
page cache entries, so mark mapping->page_tree so.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 fs/inode.c       |  2 +-
 lib/radix-tree.c | 14 ++++++++++----
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 559a9da25237..1d04dab5211c 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -345,7 +345,7 @@ EXPORT_SYMBOL(inc_nlink);
 void address_space_init_once(struct address_space *mapping)
 {
 	memset(mapping, 0, sizeof(*mapping));
-	INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC);
+	INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC | __GFP_ACCOUNT);
 	spin_lock_init(&mapping->tree_lock);
 	init_rwsem(&mapping->i_mmap_rwsem);
 	INIT_LIST_HEAD(&mapping->private_list);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 61b8fb529cef..1b7bf7314141 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -277,10 +277,11 @@ radix_tree_node_alloc(struct radix_tree_root *root)
 
 		/*
 		 * Even if the caller has preloaded, try to allocate from the
-		 * cache first for the new node to get accounted.
+		 * cache first for the new node to get accounted to the memory
+		 * cgroup.
 		 */
 		ret = kmem_cache_alloc(radix_tree_node_cachep,
-				       gfp_mask | __GFP_ACCOUNT | __GFP_NOWARN);
+				       gfp_mask | __GFP_NOWARN);
 		if (ret)
 			goto out;
 
@@ -303,8 +304,7 @@ radix_tree_node_alloc(struct radix_tree_root *root)
 		kmemleak_update_trace(ret);
 		goto out;
 	}
-	ret = kmem_cache_alloc(radix_tree_node_cachep,
-			       gfp_mask | __GFP_ACCOUNT);
+	ret = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
 out:
 	BUG_ON(radix_tree_is_internal_node(ret));
 	return ret;
@@ -351,6 +351,12 @@ static int __radix_tree_preload(gfp_t gfp_mask, int nr)
 	struct radix_tree_node *node;
 	int ret = -ENOMEM;
 
+	/*
+	 * Nodes preloaded by one cgroup can be be used by another cgroup, so
+	 * they should never be accounted to any particular memory cgroup.
+	 */
+	gfp_mask &= ~__GFP_ACCOUNT;
+
 	preempt_disable();
 	rtp = this_cpu_ptr(&radix_tree_preloads);
 	while (rtp->nr < nr) {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
