Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2CE128E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 23:01:29 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id f22so5026615qkm.11
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 20:01:29 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id q45si738869qte.344.2019.01.08.20.01.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 20:01:25 -0800 (PST)
From: Rik van Riel <riel@surriel.com>
Subject: [PATCH] mm,slab,memcg: call memcg kmem put cache with same condition as get
Date: Tue,  8 Jan 2019 23:01:07 -0500
Message-Id: <20190109040107.4110-1-riel@surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Rik van Riel <riel@surriel.com>, kernel-team@fb.com, linux-mm@kvack.org, stable@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

There is an imbalance between when slab_pre_alloc_hook calls
memcg_kmem_get_cache and when slab_post_alloc_hook calls
memcg_kmem_put_cache.

This can cause a memcg kmem cache to be destroyed right as
an object from that cache is being allocated, which is probably
not good. It could lead to things like a memcg allocating new
kmalloc slabs instead of using freed space in old ones, maybe
memory leaks, and maybe oopses as a memcg kmalloc slab is getting
destroyed on one CPU while another CPU is trying to do an allocation
from that same memcg.

The obvious fix would be to use the same condition for calling
memcg_kmem_put_cache that we also use to decide whether to call
memcg_kmem_get_cache.

I am not sure how long this bug has been around, since the last
changeset to touch that code - 452647784b2f ("mm: memcontrol: cleanup
 kmem charge functions") - merely moved the bug from one location to
another. I am still tagging that changeset, because the fix should
automatically apply that far back.

Signed-off-by: Rik van Riel <riel@surriel.com>
Fixes: 452647784b2f ("mm: memcontrol: cleanup kmem charge functions")
Cc: kernel-team@fb.com
Cc: linux-mm@kvack.org
Cc: stable@vger.kernel.org
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>
---
 mm/slab.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/slab.h b/mm/slab.h
index 4190c24ef0e9..ab3d95bef8a0 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -444,7 +444,8 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
 		p[i] = kasan_slab_alloc(s, object, flags);
 	}
 
-	if (memcg_kmem_enabled())
+	if (memcg_kmem_enabled() &&
+	    ((flags & __GFP_ACCOUNT) || (s->flags & SLAB_ACCOUNT)))
 		memcg_kmem_put_cache(s);
 }
 
-- 
2.17.1
