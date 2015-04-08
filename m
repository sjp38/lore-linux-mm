Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 79AF46B0032
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 14:13:32 -0400 (EDT)
Received: by qgfi89 with SMTP id i89so32569833qgf.1
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 11:13:32 -0700 (PDT)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id g80si11665353qge.102.2015.04.08.11.13.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 08 Apr 2015 11:13:30 -0700 (PDT)
Date: Wed, 8 Apr 2015 13:13:29 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: slub bulk alloc: Extract objects from the per cpu slab
Message-ID: <alpine.DEB.2.11.1504081311070.20469@gentwo.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: brouer@redhat.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

First piece: accelleration of retrieval of per cpu objects


If we are allocating lots of objects then it is advantageous to
disable interrupts and avoid the this_cpu_cmpxchg() operation to
get these objects faster. Note that we cannot do the fast operation
if debugging is enabled. Note also that the requirement of having
interrupts disabled avoids having to do processor flag operations.

Allocate as many objects as possible in the fast way and then fall
back to the generic implementation for the rest of the objects.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -2761,7 +2761,32 @@ EXPORT_SYMBOL(kmem_cache_free_bulk);
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
