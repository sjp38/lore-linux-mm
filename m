Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 32D1D6B0075
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 11:52:53 -0400 (EDT)
Received: by qcsf5 with SMTP id f5so4757050qcs.2
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 08:52:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 85si13162795qky.3.2015.06.15.08.52.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 08:52:52 -0700 (PDT)
Subject: [PATCH 6/7] slub: improve bulk alloc strategy
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 15 Jun 2015 17:52:46 +0200
Message-ID: <20150615155246.18824.3788.stgit@devil>
In-Reply-To: <20150615155053.18824.617.stgit@devil>
References: <20150615155053.18824.617.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>, Jesper Dangaard Brouer <brouer@redhat.com>

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
 mm/slub.c |   27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 26f64005a347..98d0e6f73ec1 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2776,8 +2776,23 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 	for (i = 0; i < size; i++) {
 		void *object = c->freelist;
 
-		if (!object)
-			break;
+		if (unlikely(!object)) {
+			c->tid = next_tid(c->tid);
+			local_irq_enable();
+
+			/* Invoke slow path one time, then retry fastpath
+			 * as side-effect have updated c->freelist
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
@@ -2793,14 +2808,6 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
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
