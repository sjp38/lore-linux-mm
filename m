Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id B0D536B0256
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 15:44:21 -0400 (EDT)
Received: by igui7 with SMTP id i7so23472194igu.1
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 12:44:21 -0700 (PDT)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id 28si5872228ioi.3.2015.08.28.12.44.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 28 Aug 2015 12:44:21 -0700 (PDT)
Date: Fri, 28 Aug 2015 14:44:20 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH] slub: Avoid irqoff/on in bulk allocation
Message-ID: <alpine.DEB.2.11.1508281443290.11894@east.gentwo.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org

Use the new function that can do allocation while
interrupts are disabled.  Avoids irq on/off sequences.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2015-08-28 14:34:59.377234626 -0500
+++ linux/mm/slub.c	2015-08-28 14:34:59.377234626 -0500
@@ -2823,30 +2823,23 @@ bool kmem_cache_alloc_bulk(struct kmem_c
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
@@ -2866,6 +2859,11 @@ bool kmem_cache_alloc_bulk(struct kmem_c
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
