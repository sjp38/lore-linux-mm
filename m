Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id A13AF8309E
	for <linux-mm@kvack.org>; Sun,  7 Feb 2016 12:28:00 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id yy13so61229935pab.3
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 09:28:00 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id bc9si40154680pad.140.2016.02.07.09.27.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Feb 2016 09:28:00 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 4/5] radix-tree: account radix_tree_node to memory cgroup
Date: Sun, 7 Feb 2016 20:27:34 +0300
Message-ID: <886d4b42a50c77c45ece9c0e685fc25f8f7643c9.1454864628.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1454864628.git.vdavydov@virtuozzo.com>
References: <cover.1454864628.git.vdavydov@virtuozzo.com>
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
