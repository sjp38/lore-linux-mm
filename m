Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 64D4E6B0075
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 10:29:54 -0400 (EDT)
Received: by qkfe185 with SMTP id e185so27033763qkf.3
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 07:29:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f34si4512024qki.17.2015.06.17.07.29.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 07:29:53 -0700 (PDT)
Subject: [PATCH V2 4/6] slub: improve bulk alloc strategy
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 17 Jun 2015 16:28:51 +0200
Message-ID: <20150617142836.11791.27417.stgit@devil>
In-Reply-To: <20150617142613.11791.76008.stgit@devil>
References: <20150617142613.11791.76008.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Call slowpath __slab_alloc() from within the bulk loop, as the
side-effect of this call likely repopulates c->freelist.

Choose to reenable local IRQs while calling slowpath.

Saving some optimizations for later.  E.g. it is possible to
extract parts of __slab_alloc() and avoid the unnecessary and
expensive (37 cycles) local_irq_{save,restore}.  For now, be
happy calling __slab_alloc() this lower icache impact of this
func and I don't have to worry about correctness.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
V2:
 - remove update of "tid" before call to __slab_alloc()
   not necessary as code-path does not modify per cpu information

Measurements on CPU CPU i7-4790K @ 4.00GHz
Baseline normal fastpath (alloc+free cost): 42 cycles(tsc) 10.601 ns

Bulk- fallback                   - this-patch
  1 -  58 cycles(tsc) 14.516 ns  -  49 cycles(tsc) 12.459 ns  improved 15.5%
  2 -  51 cycles(tsc) 12.930 ns  -  38 cycles(tsc)  9.605 ns  improved 25.5%
  3 -  49 cycles(tsc) 12.274 ns  -  34 cycles(tsc)  8.525 ns  improved 30.6%
  4 -  48 cycles(tsc) 12.058 ns  -  32 cycles(tsc)  8.036 ns  improved 33.3%
  8 -  46 cycles(tsc) 11.609 ns  -  31 cycles(tsc)  7.756 ns  improved 32.6%
 16 -  45 cycles(tsc) 11.451 ns  -  32 cycles(tsc)  8.148 ns  improved 28.9%
 30 -  79 cycles(tsc) 19.865 ns  -  68 cycles(tsc) 17.164 ns  improved 13.9%
 32 -  76 cycles(tsc) 19.212 ns  -  66 cycles(tsc) 16.584 ns  improved 13.2%
 34 -  74 cycles(tsc) 18.600 ns  -  63 cycles(tsc) 15.954 ns  improved 14.9%
 48 -  88 cycles(tsc) 22.092 ns  -  77 cycles(tsc) 19.373 ns  improved 12.5%
 64 -  80 cycles(tsc) 20.043 ns  -  68 cycles(tsc) 17.188 ns  improved 15.0%
128 -  99 cycles(tsc) 24.818 ns  -  89 cycles(tsc) 22.404 ns  improved 10.1%
158 -  99 cycles(tsc) 24.977 ns  -  92 cycles(tsc) 23.089 ns  improved  7.1%
250 - 106 cycles(tsc) 26.552 ns  -  99 cycles(tsc) 24.785 ns  improved  6.6%

 mm/slub.c |   26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index a92fdec57237..02c33bacd3a6 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2779,8 +2779,22 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 	for (i = 0; i < size; i++) {
 		void *object = c->freelist;
 
-		if (!object)
-			break;
+		if (unlikely(!object)) {
+			local_irq_enable();
+			/*
+			 * Invoking slow path likely have side-effect
+			 * of re-populating per CPU c->freelist
+			 */
+			p[i] = __slab_alloc(s, flags, NUMA_NO_NODE,
+					    _RET_IP_, c);
+			if (unlikely(!p[i])) {
+				__kmem_cache_free_bulk(s, i, p);
+				return false;
+			}
+			local_irq_disable();
+			c = this_cpu_ptr(s->cpu_slab);
+			continue; /* goto for-loop */
+		}
 
 		c->freelist = get_freepointer(s, object);
 		p[i] = object;
@@ -2796,14 +2810,6 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 			memset(p[j], 0, s->object_size);
 	}
 
-	/* Fallback to single elem alloc */
-	for (; i < size; i++) {
-		void *x = p[i] = kmem_cache_alloc(s, flags);
-		if (unlikely(!x)) {
-			__kmem_cache_free_bulk(s, i, p);
-			return false;
-		}
-	}
 	return true;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_bulk);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
