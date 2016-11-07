Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 359D16B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 16:19:22 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id i88so55915828pfk.3
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 13:19:22 -0800 (PST)
Received: from mail-pg0-x233.google.com (mail-pg0-x233.google.com. [2607:f8b0:400e:c05::233])
        by mx.google.com with ESMTPS id 62si32917988pfg.244.2016.11.07.13.11.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 13:11:49 -0800 (PST)
Received: by mail-pg0-x233.google.com with SMTP id x23so5552727pgx.1
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 13:11:49 -0800 (PST)
From: Thomas Garnier <thgarnie@google.com>
Subject: [PATCH v3 1/2] memcg: Prevent memcg caches to be both OFF_SLAB & OBJFREELIST_SLAB
Date: Mon,  7 Nov 2016 13:11:14 -0800
Message-Id: <1478553075-120242-1-git-send-email-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, gthelen@google.com, vdavydov.dev@gmail.com, mhocko@kernel.org

From: Greg Thelen <gthelen@google.com>

While testing OBJFREELIST_SLAB integration with pagealloc, we found a
bug where kmem_cache(sys) would be created with both CFLGS_OFF_SLAB &
CFLGS_OBJFREELIST_SLAB.

The original kmem_cache is created early making OFF_SLAB not possible.
When kmem_cache(sys) is created, OFF_SLAB is possible and if pagealloc
is enabled it will try to enable it first under certain conditions.
Given kmem_cache(sys) reuses the original flag, you can have both flags
at the same time resulting in allocation failures and odd behaviors.

This fix discards allocator specific flags from memcg before calling
create_cache.

Fixes: b03a017bebc4 ("mm/slab: introduce new slab management type, OBJFREELIST_SLAB")
Signed-off-by: Greg Thelen <gthelen@google.com>
Tested-by: Thomas Garnier <thgarnie@google.com>
---
Based on next-20161027
---
 mm/slab_common.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 71f0b28..329b038 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -533,8 +533,8 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 
 	s = create_cache(cache_name, root_cache->object_size,
 			 root_cache->size, root_cache->align,
-			 root_cache->flags, root_cache->ctor,
-			 memcg, root_cache);
+			 root_cache->flags & CACHE_CREATE_MASK,
+			 root_cache->ctor, memcg, root_cache);
 	/*
 	 * If we could not create a memcg cache, do not complain, because
 	 * that's not critical at all as we can always proceed with the root
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
