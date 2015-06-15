Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id F18216B0071
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 11:52:22 -0400 (EDT)
Received: by qcbfz6 with SMTP id fz6so5976097qcb.0
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 08:52:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 134si10143425qhs.73.2015.06.15.08.52.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 08:52:22 -0700 (PDT)
Subject: [PATCH 3/7] slub: reduce indention level in kmem_cache_alloc_bulk()
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 15 Jun 2015 17:52:17 +0200
Message-ID: <20150615155216.18824.26550.stgit@devil>
In-Reply-To: <20150615155053.18824.617.stgit@devil>
References: <20150615155053.18824.617.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Use kernel early return style to reduce indention level,
by testing for kmem_cache_debug() and fallback to
none-optimized bulking via __kmem_cache_alloc_bulk().

This also make it easier to fix a bug in the current
implementation, in the next patch.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slub.c |   37 +++++++++++++++++++------------------
 1 file changed, 19 insertions(+), 18 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index d18f8e195ac4..753f88bd8b40 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2757,32 +2757,33 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 EXPORT_SYMBOL(kmem_cache_free_bulk);
 
 bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
-								void **p)
+			   void **p)
 {
-	if (!kmem_cache_debug(s)) {
-		struct kmem_cache_cpu *c;
+	struct kmem_cache_cpu *c;
 
-		/* Drain objects in the per cpu slab */
-		local_irq_disable();
-		c = this_cpu_ptr(s->cpu_slab);
+	/* Debugging fallback to generic bulk */
+	if (kmem_cache_debug(s))
+		return __kmem_cache_alloc_bulk(s, flags, size, p);
 
-		while (size) {
-			void *object = c->freelist;
+	/* Drain objects in the per cpu slab */
+	local_irq_disable();
+	c = this_cpu_ptr(s->cpu_slab);
 
-			if (!object)
-				break;
+	while (size) {
+		void *object = c->freelist;
 
-			c->freelist = get_freepointer(s, object);
-			*p++ = object;
-			size--;
+		if (!object)
+			break;
 
-			if (unlikely(flags & __GFP_ZERO))
-				memset(object, 0, s->object_size);
-		}
-		c->tid = next_tid(c->tid);
+		c->freelist = get_freepointer(s, object);
+		*p++ = object;
+		size--;
 
-		local_irq_enable();
+		if (unlikely(flags & __GFP_ZERO))
+			memset(object, 0, s->object_size);
 	}
+	c->tid = next_tid(c->tid);
+	local_irq_enable();
 
 	return __kmem_cache_alloc_bulk(s, flags, size, p);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
