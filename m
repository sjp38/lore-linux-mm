Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id CB5426B0072
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 11:52:32 -0400 (EDT)
Received: by qkhq76 with SMTP id q76so55913961qkh.2
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 08:52:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e145si13119689qhc.95.2015.06.15.08.52.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 08:52:32 -0700 (PDT)
Subject: [PATCH 4/7] slub: fix error path bug in kmem_cache_alloc_bulk
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 15 Jun 2015 17:52:26 +0200
Message-ID: <20150615155226.18824.99.stgit@devil>
In-Reply-To: <20150615155053.18824.617.stgit@devil>
References: <20150615155053.18824.617.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>, Jesper Dangaard Brouer <brouer@redhat.com>

The current kmem_cache/SLAB bulking API need to release all objects
in case the layer cannot satisfy the full request.

If __kmem_cache_alloc_bulk() fails, all allocated objects in array
should be freed, but, __kmem_cache_alloc_bulk() can't know
about objects allocated by this slub specific kmem_cache_alloc_bulk()
function.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slub.c |   21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 753f88bd8b40..d10de5a33c03 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2760,24 +2760,27 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 			   void **p)
 {
 	struct kmem_cache_cpu *c;
+	int i;
 
 	/* Debugging fallback to generic bulk */
 	if (kmem_cache_debug(s))
 		return __kmem_cache_alloc_bulk(s, flags, size, p);
 
-	/* Drain objects in the per cpu slab */
+	/* Drain objects in the per cpu slab, while disabling local
+	 * IRQs, which protects against PREEMPT and interrupts
+	 * handlers invoking normal fastpath.
+	 */
 	local_irq_disable();
 	c = this_cpu_ptr(s->cpu_slab);
 
-	while (size) {
+	for (i = 0; i < size; i++) {
 		void *object = c->freelist;
 
 		if (!object)
 			break;
 
 		c->freelist = get_freepointer(s, object);
-		*p++ = object;
-		size--;
+		p[i] = object;
 
 		if (unlikely(flags & __GFP_ZERO))
 			memset(object, 0, s->object_size);
@@ -2785,7 +2788,15 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 	c->tid = next_tid(c->tid);
 	local_irq_enable();
 
-	return __kmem_cache_alloc_bulk(s, flags, size, p);
+	/* Fallback to single elem alloc */
+	for (; i < size; i++) {
+		void *x = p[i] = kmem_cache_alloc(s, flags);
+		if (unlikely(!x)) {
+			__kmem_cache_free_bulk(s, i, p);
+			return false;
+		}
+	}
+	return true;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_bulk);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
