Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6BB356B0259
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 11:47:01 -0400 (EDT)
Received: by qkcf65 with SMTP id f65so4863824qkc.3
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 08:47:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o20si5223890qki.35.2015.09.29.08.46.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 08:47:00 -0700 (PDT)
Subject: [MM PATCH V4 2/6] slub: Avoid irqoff/on in bulk allocation
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 29 Sep 2015 17:47:18 +0200
Message-ID: <20150929154717.14465.67508.stgit@canyon>
In-Reply-To: <20150929154605.14465.98995.stgit@canyon>
References: <20150929154605.14465.98995.stgit@canyon>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

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
