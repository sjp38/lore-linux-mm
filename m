Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 00DA84403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 10:15:51 -0500 (EST)
Received: by mail-qg0-f51.google.com with SMTP id b35so300615566qge.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 07:15:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q7si103196433qhb.86.2016.01.12.07.15.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 07:15:50 -0800 (PST)
Subject: [PATCH V2 09/11] slab: implement bulk free in SLAB allocator
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 12 Jan 2016 16:15:47 +0100
Message-ID: <20160112151536.31725.28835.stgit@firesoul>
In-Reply-To: <20160112151257.31725.71327.stgit@firesoul>
References: <20160112151257.31725.71327.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>

This patch implements the free side of bulk API for the SLAB
allocator kmem_cache_free_bulk(), and concludes the
implementation of optimized bulk API for SLAB allocator.

Benchmarked[1] cost of alloc+free (obj size 256 bytes) on CPU
i7-4790K @ 4.00GHz, with no debug options, no PREEMPT and
CONFIG_MEMCG_KMEM=y but no active user of kmemcg.

SLAB single alloc+free cost: 87 cycles(tsc) 21.814 ns with this
optimized config.

bulk- Current fallback          - optimized SLAB bulk
  1 - 102 cycles(tsc) 25.747 ns - 41 cycles(tsc) 10.490 ns - improved 59.8%
  2 -  94 cycles(tsc) 23.546 ns - 26 cycles(tsc)  6.567 ns - improved 72.3%
  3 -  92 cycles(tsc) 23.127 ns - 20 cycles(tsc)  5.244 ns - improved 78.3%
  4 -  90 cycles(tsc) 22.663 ns - 18 cycles(tsc)  4.588 ns - improved 80.0%
  8 -  88 cycles(tsc) 22.242 ns - 14 cycles(tsc)  3.656 ns - improved 84.1%
 16 -  88 cycles(tsc) 22.010 ns - 13 cycles(tsc)  3.480 ns - improved 85.2%
 30 -  89 cycles(tsc) 22.305 ns - 13 cycles(tsc)  3.303 ns - improved 85.4%
 32 -  89 cycles(tsc) 22.277 ns - 13 cycles(tsc)  3.309 ns - improved 85.4%
 34 -  88 cycles(tsc) 22.246 ns - 13 cycles(tsc)  3.294 ns - improved 85.2%
 48 -  88 cycles(tsc) 22.121 ns - 13 cycles(tsc)  3.492 ns - improved 85.2%
 64 -  88 cycles(tsc) 22.052 ns - 13 cycles(tsc)  3.411 ns - improved 85.2%
128 -  89 cycles(tsc) 22.452 ns - 15 cycles(tsc)  3.841 ns - improved 83.1%
158 -  89 cycles(tsc) 22.403 ns - 14 cycles(tsc)  3.746 ns - improved 84.3%
250 -  91 cycles(tsc) 22.775 ns - 16 cycles(tsc)  4.111 ns - improved 82.4%

Notice it is not recommended to do very large bulk operation with
this bulk API, because local IRQs are disabled in this period.

[1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_bulk_test01.c

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slab.c |   29 +++++++++++++++++++++++------
 1 file changed, 23 insertions(+), 6 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 3f391e200ea2..6cc5f99fe2ea 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3385,12 +3385,6 @@ void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 }
 EXPORT_SYMBOL(kmem_cache_alloc);
 
-void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
-{
-	__kmem_cache_free_bulk(s, size, p);
-}
-EXPORT_SYMBOL(kmem_cache_free_bulk);
-
 static __always_inline void
 cache_alloc_debugcheck_after_bulk(struct kmem_cache *s, gfp_t flags,
 				  size_t size, void **p, unsigned long caller)
@@ -3584,6 +3578,29 @@ void kmem_cache_free(struct kmem_cache *cachep, void *objp)
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
+	/* FIXME: add tracing */
+}
+EXPORT_SYMBOL(kmem_cache_free_bulk);
+
 /**
  * kfree - free previously allocated memory
  * @objp: pointer returned by kmalloc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
