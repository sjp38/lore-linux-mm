Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 176EC828E1
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 08:45:43 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id q62so363584439oih.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 05:45:43 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0133.outbound.protection.outlook.com. [104.47.0.133])
        by mx.google.com with ESMTPS id z65si1447744otb.242.2016.08.02.05.45.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 05:45:42 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH stable 4.6+] radix-tree: account nodes to memcg only if explicitly requested
Date: Tue, 2 Aug 2016 15:45:34 +0300
Message-ID: <1470141934-4568-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Radix trees may be used not only for storing page cache pages, so
unconditionally accounting radix tree nodes to the current memory cgroup
is bad: if a radix tree node is used for storing data shared among
different cgroups we risk pinning dead memory cgroups forever. So let's
only account radix tree nodes if it was explicitly requested by passing
__GFP_ACCOUNT to INIT_RADIX_TREE. Currently, we only want to account
page cache entries, so mark mapping->page_tree so.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: <stable@vger.kernel.org>  [4.6+]
---
 fs/inode.c       |  2 +-
 lib/radix-tree.c | 14 ++++++++++----
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 69b8b526c194..b4ff82f3a57d 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -344,7 +344,7 @@ EXPORT_SYMBOL(inc_nlink);
 void address_space_init_once(struct address_space *mapping)
 {
 	memset(mapping, 0, sizeof(*mapping));
-	INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC);
+	INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC | __GFP_ACCOUNT);
 	spin_lock_init(&mapping->tree_lock);
 	init_rwsem(&mapping->i_mmap_rwsem);
 	INIT_LIST_HEAD(&mapping->private_list);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 1624c4117961..9b9be3ffa1f6 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -228,10 +228,11 @@ radix_tree_node_alloc(struct radix_tree_root *root)
 
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
 
@@ -254,8 +255,7 @@ radix_tree_node_alloc(struct radix_tree_root *root)
 		kmemleak_update_trace(ret);
 		goto out;
 	}
-	ret = kmem_cache_alloc(radix_tree_node_cachep,
-			       gfp_mask | __GFP_ACCOUNT);
+	ret = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
 out:
 	BUG_ON(radix_tree_is_indirect_ptr(ret));
 	return ret;
@@ -302,6 +302,12 @@ static int __radix_tree_preload(gfp_t gfp_mask)
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
 	while (rtp->nr < RADIX_TREE_PRELOAD_SIZE) {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
