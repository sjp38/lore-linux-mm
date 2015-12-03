Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0C5E46B0256
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 10:57:44 -0500 (EST)
Received: by qkda6 with SMTP id a6so31636999qkd.3
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 07:57:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g205si1556667qkb.9.2015.12.03.07.57.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 07:57:43 -0800 (PST)
Subject: [RFC PATCH 2/2] slab: implement bulk free in SLAB allocator
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 03 Dec 2015 16:57:41 +0100
Message-ID: <20151203155736.3589.67424.stgit@firesoul>
In-Reply-To: <20151203155600.3589.86568.stgit@firesoul>
References: <20151203155600.3589.86568.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

(will add more desc after RFC)

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slab.c |   31 +++++++++++++++++++++++++------
 1 file changed, 25 insertions(+), 6 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 3354489547ec..b676ac1dad34 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3413,12 +3413,6 @@ void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 }
 EXPORT_SYMBOL(kmem_cache_alloc);
 
-void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
-{
-	__kmem_cache_free_bulk(s, size, p);
-}
-EXPORT_SYMBOL(kmem_cache_free_bulk);
-
 int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 			  void **p)
 {
@@ -3619,6 +3613,31 @@ void kmem_cache_free(struct kmem_cache *cachep, void *objp)
 }
 EXPORT_SYMBOL(kmem_cache_free);
 
+void kmem_cache_free_bulk(struct kmem_cache *orig_s, size_t size, void **p)
+{
+	struct kmem_cache *s;
+	size_t i;
+
+	local_irq_disable();
+	for (i = 0; i < size; i++) {
+		void *objp = p[i];
+
+		s = cache_from_obj(orig_s, objp);
+
+		debug_check_no_locks_freed(objp, s->object_size);
+		if (!(s->flags & SLAB_DEBUG_OBJECTS))
+			debug_check_no_obj_freed(objp, s->object_size);
+
+		__cache_free(s, objp, _RET_IP_);
+	}
+	local_irq_enable();
+
+	// FIXME: tracing
+	// trace_kmem_cache_free(_RET_IP_, objp);
+}
+EXPORT_SYMBOL(kmem_cache_free_bulk);
+
+
 /**
  * kfree - free previously allocated memory
  * @objp: pointer returned by kmalloc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
