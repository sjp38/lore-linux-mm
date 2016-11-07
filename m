Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB716B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 17:47:54 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y68so57617931pfb.6
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 14:47:54 -0800 (PST)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id n7si27758715pag.191.2016.11.07.14.47.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 14:47:53 -0800 (PST)
Received: by mail-pf0-x232.google.com with SMTP id d2so96959653pfd.0
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 14:47:53 -0800 (PST)
From: Thomas Garnier <thgarnie@google.com>
Subject: [PATCH v4 1/2] memcg: Prevent memcg caches to be both OFF_SLAB & OBJFREELIST_SLAB
Date: Mon,  7 Nov 2016 14:47:20 -0800
Message-Id: <1478558841-23005-1-git-send-email-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, gthelen@google.com, vdavydov.dev@gmail.com, mhocko@kernel.org, Thomas Garnier <thgarnie@google.com>

From: Greg Thelen <gthelen@google.com>

While testing OBJFREELIST_SLAB integration with pagealloc, we found a
bug where kmem_cache(sys) would be created with both CFLGS_OFF_SLAB &
CFLGS_OBJFREELIST_SLAB. When it happened, critical allocations needed
for loading drivers or creating new caches will fail.

The original kmem_cache is created early making OFF_SLAB not possible.
When kmem_cache(sys) is created, OFF_SLAB is possible and if pagealloc
is enabled it will try to enable it first under certain conditions.
Given kmem_cache(sys) reuses the original flag, you can have both flags
at the same time.

This fix discards allocator specific flags from memcg before calling
create_cache.

The bug exists since 4.6-rc1 and affects testing debug pagealloc
configurations.

Fixes: b03a017bebc4 ("mm/slab: introduce new slab management type, OBJFREELIST_SLAB")
Signed-off-by: Greg Thelen <gthelen@google.com>
Signed-off-by: Thomas Garnier <thgarnie@google.com>
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
