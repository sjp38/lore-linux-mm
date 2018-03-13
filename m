Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9F0F46B0010
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 12:54:58 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p128so89272pga.19
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 09:54:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p13sor164022pgc.251.2018.03.13.09.54.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Mar 2018 09:54:57 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] slab, slub: remove size disparity on debug kernel
Date: Tue, 13 Mar 2018 09:54:28 -0700
Message-Id: <20180313165428.58699-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

I have noticed on debug kernel with SLAB, the size of some non-root
slabs were larger than their corresponding root slabs.

e.g. for radix_tree_node:
$cat /proc/slabinfo | grep radix
name     <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> ...
radix_tree_node 15052    15075      4096         1             1 ...

$cat /cgroup/memory/temp/memory.kmem.slabinfo | grep radix
name     <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> ...
radix_tree_node 1581      158       4120         1             2 ...

However for SLUB in debug kernel, the sizes were same. On further
inspection it is found that SLUB always use kmem_cache.object_size to
measure the kmem_cache.size while SLAB use the given kmem_cache.size. In
the debug kernel the slab's size can be larger than its object_size.
Thus in the creation of non-root slab, the SLAB uses the root's size as
base to calculate the non-root slab's size and thus non-root slab's size
can be larger than the root slab's size. For SLUB, the non-root slab's
size is measured based on the root's object_size and thus the size will
remain same for root and non-root slab.

This patch makes slab's object_size the default base to measure the
slab's size.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 mm/slab_common.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index e41cbc18c57d..61ab2ca8bea7 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -379,7 +379,7 @@ struct kmem_cache *find_mergeable(unsigned int size, unsigned int align,
 }
 
 static struct kmem_cache *create_cache(const char *name,
-		unsigned int object_size, unsigned int size, unsigned int align,
+		unsigned int object_size, unsigned int align,
 		slab_flags_t flags, unsigned int useroffset,
 		unsigned int usersize, void (*ctor)(void *),
 		struct mem_cgroup *memcg, struct kmem_cache *root_cache)
@@ -396,8 +396,7 @@ static struct kmem_cache *create_cache(const char *name,
 		goto out;
 
 	s->name = name;
-	s->object_size = object_size;
-	s->size = size;
+	s->size = s->object_size = object_size;
 	s->align = align;
 	s->ctor = ctor;
 	s->useroffset = useroffset;
@@ -503,7 +502,7 @@ kmem_cache_create_usercopy(const char *name,
 		goto out_unlock;
 	}
 
-	s = create_cache(cache_name, size, size,
+	s = create_cache(cache_name, size,
 			 calculate_alignment(flags, align, size),
 			 flags, useroffset, usersize, ctor, NULL, NULL);
 	if (IS_ERR(s)) {
@@ -650,7 +649,7 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 		goto out_unlock;
 
 	s = create_cache(cache_name, root_cache->object_size,
-			 root_cache->size, root_cache->align,
+			 root_cache->align,
 			 root_cache->flags & CACHE_CREATE_MASK,
 			 root_cache->useroffset, root_cache->usersize,
 			 root_cache->ctor, memcg, root_cache);
-- 
2.16.2.660.g709887971b-goog
