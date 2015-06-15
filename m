Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4AA546B0070
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 11:52:13 -0400 (EDT)
Received: by qcwx2 with SMTP id x2so4040200qcw.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 08:52:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j2si10995179qgj.3.2015.06.15.08.52.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 08:52:12 -0700 (PDT)
Subject: [PATCH 2/7] slub bulk alloc: extract objects from the per cpu slab
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 15 Jun 2015 17:52:07 +0200
Message-ID: <20150615155207.18824.8674.stgit@devil>
In-Reply-To: <20150615155053.18824.617.stgit@devil>
References: <20150615155053.18824.617.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>, Jesper Dangaard Brouer <brouer@redhat.com>

From: Christoph Lameter <cl@linux.com>

[NOTICE: Already in AKPM's quilt-queue]

First piece: acceleration of retrieval of per cpu objects

If we are allocating lots of objects then it is advantageous to disable
interrupts and avoid the this_cpu_cmpxchg() operation to get these objects
faster.

Note that we cannot do the fast operation if debugging is enabled, because
we would have to add extra code to do all the debugging checks.  And it
would not be fast anyway.

Note also that the requirement of having interrupts disabled
avoids having to do processor flag operations.

Allocate as many objects as possible in the fast way and then fall back to
the generic implementation for the rest of the objects.

Signed-off-by: Christoph Lameter <cl@linux.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slub.c |   27 ++++++++++++++++++++++++++-
 1 file changed, 26 insertions(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 80f17403e503..d18f8e195ac4 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2759,7 +2759,32 @@ EXPORT_SYMBOL(kmem_cache_free_bulk);
 bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 								void **p)
 {
-	return kmem_cache_alloc_bulk(s, flags, size, p);
+	if (!kmem_cache_debug(s)) {
+		struct kmem_cache_cpu *c;
+
+		/* Drain objects in the per cpu slab */
+		local_irq_disable();
+		c = this_cpu_ptr(s->cpu_slab);
+
+		while (size) {
+			void *object = c->freelist;
+
+			if (!object)
+				break;
+
+			c->freelist = get_freepointer(s, object);
+			*p++ = object;
+			size--;
+
+			if (unlikely(flags & __GFP_ZERO))
+				memset(object, 0, s->object_size);
+		}
+		c->tid = next_tid(c->tid);
+
+		local_irq_enable();
+	}
+
+	return __kmem_cache_alloc_bulk(s, flags, size, p);
 }
 EXPORT_SYMBOL(kmem_cache_alloc_bulk);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
