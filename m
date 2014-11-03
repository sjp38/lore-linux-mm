Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 770DE6B00F9
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 16:00:25 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so12899734pab.4
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 13:00:25 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id x3si16139668pdr.187.2014.11.03.13.00.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Nov 2014 13:00:23 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 7/8] slab: introduce slab_free helper
Date: Mon, 3 Nov 2014 23:59:45 +0300
Message-ID: <439ae0a228e18af4ba909dce471a7e3d21005ef6.1415046910.git.vdavydov@parallels.com>
In-Reply-To: <cover.1415046910.git.vdavydov@parallels.com>
References: <cover.1415046910.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slab.c |   30 ++++++++++++++----------------
 1 file changed, 14 insertions(+), 16 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index a9eb49f40c0a..178a3b733a50 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3521,6 +3521,18 @@ void *__kmalloc_track_caller(size_t size, gfp_t flags, unsigned long caller)
 }
 EXPORT_SYMBOL(__kmalloc_track_caller);
 
+static __always_inline void slab_free(struct kmem_cache *cachep, void *objp)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	debug_check_no_locks_freed(objp, cachep->object_size);
+	if (!(cachep->flags & SLAB_DEBUG_OBJECTS))
+		debug_check_no_obj_freed(objp, cachep->object_size);
+	__cache_free(cachep, objp, _RET_IP_);
+	local_irq_restore(flags);
+}
+
 /**
  * kmem_cache_free - Deallocate an object
  * @cachep: The cache the allocation was from.
@@ -3531,18 +3543,10 @@ EXPORT_SYMBOL(__kmalloc_track_caller);
  */
 void kmem_cache_free(struct kmem_cache *cachep, void *objp)
 {
-	unsigned long flags;
 	cachep = cache_from_obj(cachep, objp);
 	if (!cachep)
 		return;
-
-	local_irq_save(flags);
-	debug_check_no_locks_freed(objp, cachep->object_size);
-	if (!(cachep->flags & SLAB_DEBUG_OBJECTS))
-		debug_check_no_obj_freed(objp, cachep->object_size);
-	__cache_free(cachep, objp, _RET_IP_);
-	local_irq_restore(flags);
-
+	slab_free(cachep, objp);
 	trace_kmem_cache_free(_RET_IP_, objp);
 }
 EXPORT_SYMBOL(kmem_cache_free);
@@ -3559,20 +3563,14 @@ EXPORT_SYMBOL(kmem_cache_free);
 void kfree(const void *objp)
 {
 	struct kmem_cache *c;
-	unsigned long flags;
 
 	trace_kfree(_RET_IP_, objp);
 
 	if (unlikely(ZERO_OR_NULL_PTR(objp)))
 		return;
-	local_irq_save(flags);
 	kfree_debugcheck(objp);
 	c = virt_to_cache(objp);
-	debug_check_no_locks_freed(objp, c->object_size);
-
-	debug_check_no_obj_freed(objp, c->object_size);
-	__cache_free(c, (void *)objp, _RET_IP_);
-	local_irq_restore(flags);
+	slab_free(c, (void *)objp);
 }
 EXPORT_SYMBOL(kfree);
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
