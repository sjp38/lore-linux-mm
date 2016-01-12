Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8BF444403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 10:14:33 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id o11so430545191qge.2
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 07:14:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f11si48300586qga.87.2016.01.12.07.14.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 07:14:32 -0800 (PST)
Subject: [PATCH V2 04/11] slab: use slab_pre_alloc_hook in SLAB allocator
 shared with SLUB
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 12 Jan 2016 16:14:30 +0100
Message-ID: <20160112151418.31725.60306.stgit@firesoul>
In-Reply-To: <20160112151257.31725.71327.stgit@firesoul>
References: <20160112151257.31725.71327.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Dedublicate code in SLAB allocator functions slab_alloc() and
slab_alloc_node() by using the slab_pre_alloc_hook() call, which
is now shared between SLUB and SLAB.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
V2: added unlikely() per request of Kim

 mm/slab.c |   18 ++++--------------
 1 file changed, 4 insertions(+), 14 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index d5b29e7bee81..30365be73547 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3140,15 +3140,10 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 	void *ptr;
 	int slab_node = numa_mem_id();
 
-	flags &= gfp_allowed_mask;
-
-	lockdep_trace_alloc(flags);
-
-	if (should_failslab(cachep, flags))
+	cachep = slab_pre_alloc_hook(cachep, flags);
+	if (unlikely(!cachep))
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
-	if (should_failslab(cachep, flags))
+	cachep = slab_pre_alloc_hook(cachep, flags);
+	if (unlikely(!cachep))
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
