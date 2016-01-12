Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1AF424403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 10:15:34 -0500 (EST)
Received: by mail-qg0-f47.google.com with SMTP id b35so300607838qge.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 07:15:34 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f30si40081444qga.65.2016.01.12.07.15.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 07:15:33 -0800 (PST)
Subject: [PATCH V2 08/11] slab: avoid running debug SLAB code with IRQs
 disabled for alloc_bulk
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 12 Jan 2016 16:15:31 +0100
Message-ID: <20160112151517.31725.85846.stgit@firesoul>
In-Reply-To: <20160112151257.31725.71327.stgit@firesoul>
References: <20160112151257.31725.71327.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Move the call to cache_alloc_debugcheck_after() outside the IRQ
disabled section in kmem_cache_alloc_bulk().

When CONFIG_DEBUG_SLAB is disabled the compiler should remove
this code.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slab.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 17931ea961d1..3f391e200ea2 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3391,6 +3391,16 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 }
 EXPORT_SYMBOL(kmem_cache_free_bulk);
 
+static __always_inline void
+cache_alloc_debugcheck_after_bulk(struct kmem_cache *s, gfp_t flags,
+				  size_t size, void **p, unsigned long caller)
+{
+	size_t i;
+
+	for (i = 0; i < size; i++)
+		p[i] = cache_alloc_debugcheck_after(s, flags, p[i], caller);
+}
+
 int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 			  void **p)
 {
@@ -3406,15 +3416,14 @@ int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 	for (i = 0; i < size; i++) {
 		void *objp = __do_cache_alloc(s, flags);
 
-		/* this call could be done outside IRQ disabled section */
-		objp = cache_alloc_debugcheck_after(s, flags, objp, _RET_IP_);
-
 		if (unlikely(!objp))
 			goto error;
 		p[i] = objp;
 	}
 	local_irq_enable();
 
+	cache_alloc_debugcheck_after_bulk(s, flags, size, p, _RET_IP_);
+
 	/* Clear memory outside IRQ disabled section */
 	if (unlikely(flags & __GFP_ZERO))
 		for (i = 0; i < size; i++)
@@ -3425,6 +3434,7 @@ int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 	return size;
 error:
 	local_irq_enable();
+	cache_alloc_debugcheck_after_bulk(s, flags, i, p, _RET_IP_);
 	slab_post_alloc_hook(s, flags, i, p);
 	__kmem_cache_free_bulk(s, i, p);
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
