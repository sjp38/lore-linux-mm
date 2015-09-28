Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 704776B0257
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 08:26:17 -0400 (EDT)
Received: by qgez77 with SMTP id z77so118867787qge.1
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 05:26:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 141si15199463qhx.1.2015.09.28.05.26.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Sep 2015 05:26:16 -0700 (PDT)
Subject: [PATCH 2/7] slub: Avoid irqoff/on in bulk allocation
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 28 Sep 2015 14:26:14 +0200
Message-ID: <20150928122614.15409.89190.stgit@canyon>
In-Reply-To: <20150928122444.15409.10498.stgit@canyon>
References: <20150928122444.15409.10498.stgit@canyon>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Christoph Lameter <cl@linux.com>

NOTICE: Accepted by AKPM
 http://ozlabs.org/~akpm/mmots/broken-out/slub-avoid-irqoff-on-in-bulk-allocation.patch

Use the new function that can do allocation while
interrupts are disabled.  Avoids irq on/off sequences.

Signed-off-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slub.c |   24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 02cfb3a5983e..024eed32da2c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2821,30 +2821,23 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 		void *object = c->freelist;
 
 		if (unlikely(!object)) {
-			local_irq_enable();
 			/*
 			 * Invoking slow path likely have side-effect
 			 * of re-populating per CPU c->freelist
 			 */
-			p[i] = __slab_alloc(s, flags, NUMA_NO_NODE,
+			p[i] = ___slab_alloc(s, flags, NUMA_NO_NODE,
 					    _RET_IP_, c);
-			if (unlikely(!p[i])) {
-				__kmem_cache_free_bulk(s, i, p);
-				return false;
-			}
-			local_irq_disable();
+			if (unlikely(!p[i]))
+				goto error;
+
 			c = this_cpu_ptr(s->cpu_slab);
 			continue; /* goto for-loop */
 		}
 
 		/* kmem_cache debug support */
 		s = slab_pre_alloc_hook(s, flags);
-		if (unlikely(!s)) {
-			__kmem_cache_free_bulk(s, i, p);
-			c->tid = next_tid(c->tid);
-			local_irq_enable();
-			return false;
-		}
+		if (unlikely(!s))
+			goto error;
 
 		c->freelist = get_freepointer(s, object);
 		p[i] = object;
@@ -2864,6 +2857,11 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 	}
 
 	return true;
+
+error:
+	__kmem_cache_free_bulk(s, i, p);
+	local_irq_enable();
+	return false;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_bulk);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
