Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4CB586B000C
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 17:00:29 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f4-v6so11237644plr.11
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 14:00:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n15sor24744pfa.101.2018.03.19.14.00.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Mar 2018 14:00:28 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] mm, slab: memcg_link the SLAB's kmem_cache
Date: Mon, 19 Mar 2018 14:00:20 -0700
Message-Id: <20180319210020.60289-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

All the root caches are linked into slab_root_caches which was
introduced by the commit 510ded33e075 ("slab: implement slab_root_caches
list") but it missed to add the SLAB's kmem_cache.

While experimenting with opt-in/opt-out kmem accounting, I noticed
system crashes due to NULL dereference inside cache_from_memcg_idx()
while deferencing kmem_cache.memcg_params.memcg_caches. The upstream
clean kernel will not see these crashes but SLAB should be consistent
with SLUB which does linked its boot caches (kmem_cache_node and
kmem_cache) into slab_root_caches.

Fixes: 510ded33e075c ("slab: implement slab_root_caches list")
Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 mm/slab.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/slab.c b/mm/slab.c
index 324446621b3e..9095c3945425 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1283,6 +1283,7 @@ void __init kmem_cache_init(void)
 				  nr_node_ids * sizeof(struct kmem_cache_node *),
 				  SLAB_HWCACHE_ALIGN, 0, 0);
 	list_add(&kmem_cache->list, &slab_caches);
+	memcg_link_cache(kmem_cache);
 	slab_state = PARTIAL;
 
 	/*
-- 
2.16.2.804.g6dcf76e118-goog
