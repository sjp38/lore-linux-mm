Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 05BB96B025A
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 11:19:10 -0500 (EST)
Received: by qgea14 with SMTP id a14so23342888qge.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 08:19:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e67si4045119qkb.67.2015.12.08.08.18.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 08:18:39 -0800 (PST)
Subject: [RFC PATCH V2 3/9] slab: use slab_pre_alloc_hook in SLAB allocator
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 08 Dec 2015 17:18:37 +0100
Message-ID: <20151208161837.21945.45442.stgit@firesoul>
In-Reply-To: <20151208161751.21945.53936.stgit@firesoul>
References: <20151208161751.21945.53936.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

Dedublicate code in slab_alloc() and slab_alloc_node() by using
the slab_pre_alloc_hook() call.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slab.c |   18 ++++--------------
 1 file changed, 4 insertions(+), 14 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 4684c2496982..17fd6268ad41 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3140,15 +3140,10 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 	void *ptr;
 	int slab_node = numa_mem_id();
 
-	flags &= gfp_allowed_mask;
-
-	lockdep_trace_alloc(flags);
-
-	if (slab_should_failslab(cachep, flags))
+	cachep = slab_pre_alloc_hook(cachep, flags);
+	if (!cachep)
 		return NULL;
 
-	cachep = memcg_kmem_get_cache(cachep, flags);
-
 	cache_alloc_debugcheck_before(cachep, flags);
 	local_irq_save(save_flags);
 
@@ -3228,15 +3223,10 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 	unsigned long save_flags;
 	void *objp;
 
-	flags &= gfp_allowed_mask;
-
-	lockdep_trace_alloc(flags);
-
-	if (slab_should_failslab(cachep, flags))
+	cachep = slab_pre_alloc_hook(cachep, flags);
+	if (!cachep)
 		return NULL;
 
-	cachep = memcg_kmem_get_cache(cachep, flags);
-
 	cache_alloc_debugcheck_before(cachep, flags);
 	local_irq_save(save_flags);
 	objp = __do_cache_alloc(cachep, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
