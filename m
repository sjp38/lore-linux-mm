Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8EFD728029C
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 12:22:40 -0400 (EDT)
Received: by qgef3 with SMTP id f3so20517917qge.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 09:22:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g193si5951140qhc.81.2015.07.15.09.22.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 09:22:39 -0700 (PDT)
Subject: [PATCH 1/3] slub: extend slowpath __slab_free() to handle bulk free
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 15 Jul 2015 18:01:34 +0200
Message-ID: <20150715160119.17525.53567.stgit@devil>
In-Reply-To: <20150715155934.17525.2835.stgit@devil>
References: <20150715155934.17525.2835.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Alexander Duyck <alexander.duyck@gmail.com>, Hannes Frederic Sowa <hannes@stressinduktion.org>, Jesper Dangaard Brouer <brouer@redhat.com>

Make it possible to free a freelist with several objects by extending
__slab_free() with two arguments: a freelist_head pointer and objects
counter (cnt).  If freelist_head pointer is set, then the object must
be the freelist tail pointer.

This allows a list of object to be free'ed using a single locked
cmpxchg_double.

Micro benchmarking showed no performance reduction due to this change.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slub.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index c9305f525004..d0841a4c61ea 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2573,9 +2573,13 @@ EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
  * So we still attempt to reduce cache line usage. Just take the slab
  * lock and free the item. If there is no additional partial page
  * handling required then we can return immediately.
+ *
+ * Bulk free of a freelist with several objects possible by specifying
+ * freelist_head ptr and object as tail ptr, plus objects count (cnt).
  */
 static void __slab_free(struct kmem_cache *s, struct page *page,
-			void *x, unsigned long addr)
+			void *x, unsigned long addr,
+			void *freelist_head, int cnt)
 {
 	void *prior;
 	void **object = (void *)x;
@@ -2584,6 +2588,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 	unsigned long counters;
 	struct kmem_cache_node *n = NULL;
 	unsigned long uninitialized_var(flags);
+	void *new_freelist = (!freelist_head) ? object : freelist_head;
 
 	stat(s, FREE_SLOWPATH);
 
@@ -2601,7 +2606,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 		set_freepointer(s, object, prior);
 		new.counters = counters;
 		was_frozen = new.frozen;
-		new.inuse--;
+		new.inuse -= cnt;
 		if ((!new.inuse || !prior) && !was_frozen) {
 
 			if (kmem_cache_has_cpu_partial(s) && !prior) {
@@ -2632,7 +2637,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 
 	} while (!cmpxchg_double_slab(s, page,
 		prior, counters,
-		object, new.counters,
+		new_freelist, new.counters,
 		"__slab_free"));
 
 	if (likely(!n)) {
@@ -2736,7 +2741,7 @@ redo:
 		}
 		stat(s, FREE_FASTPATH);
 	} else
-		__slab_free(s, page, x, addr);
+		__slab_free(s, page, x, addr, NULL, 1);
 
 }
 
@@ -2780,7 +2785,7 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 			c->tid = next_tid(c->tid);
 			local_irq_enable();
 			/* Slowpath: overhead locked cmpxchg_double_slab */
-			__slab_free(s, page, object, _RET_IP_);
+			__slab_free(s, page, object, _RET_IP_, NULL, 1);
 			local_irq_disable();
 			c = this_cpu_ptr(s->cpu_slab);
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
