Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id A93816B0255
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 08:56:21 -0500 (EST)
Received: by mail-io0-f173.google.com with SMTP id 9so17905449iom.1
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 05:56:21 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id qd10si23150964igb.33.2016.02.09.05.56.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 05:56:21 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH v2 4/6] radix-tree: account radix_tree_node to memory cgroup
Date: Tue, 9 Feb 2016 16:55:52 +0300
Message-ID: <1da590d4d48461d85a5d64d91d58b8927c188c96.1455025246.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1455025246.git.vdavydov@virtuozzo.com>
References: <cover.1455025246.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Allocation of radix_tree_node objects can be easily triggered from
userspace, so we should account them to memory cgroup. Besides, we need
them accounted for making shadow node shrinker per memcg (see
mm/workingset.c).

A tricky thing about accounting radix_tree_node objects is that they are
mostly allocated through radix_tree_preload(), so we can't just set
SLAB_ACCOUNT for radix_tree_node_cachep - that would likely result in a
lot of unrelated cgroups using objects from each other's caches.

One way to overcome this would be making radix tree preloads per memcg,
but that would probably look cumbersome and overcomplicated.

Instead, we make radix_tree_node_alloc() first try to allocate from the
cache with __GFP_ACCOUNT, no matter if the caller has preloaded or not,
and only if it fails fall back on using per cpu preloads. This should
make most allocations accounted.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 lib/radix-tree.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index e2511b8e2300..1624c4117961 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -227,6 +227,15 @@ radix_tree_node_alloc(struct radix_tree_root *root)
 		struct radix_tree_preload *rtp;
 
 		/*
+		 * Even if the caller has preloaded, try to allocate from the
+		 * cache first for the new node to get accounted.
+		 */
+		ret = kmem_cache_alloc(radix_tree_node_cachep,
+				       gfp_mask | __GFP_ACCOUNT | __GFP_NOWARN);
+		if (ret)
+			goto out;
+
+		/*
 		 * Provided the caller has preloaded here, we will always
 		 * succeed in getting a node here (and never reach
 		 * kmem_cache_alloc)
@@ -243,10 +252,11 @@ radix_tree_node_alloc(struct radix_tree_root *root)
 		 * for debugging.
 		 */
 		kmemleak_update_trace(ret);
+		goto out;
 	}
-	if (ret == NULL)
-		ret = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
-
+	ret = kmem_cache_alloc(radix_tree_node_cachep,
+			       gfp_mask | __GFP_ACCOUNT);
+out:
 	BUG_ON(radix_tree_is_indirect_ptr(ret));
 	return ret;
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
