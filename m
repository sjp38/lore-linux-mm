Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8BF094403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 10:15:15 -0500 (EST)
Received: by mail-qg0-f51.google.com with SMTP id o11so430563587qge.2
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 07:15:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k65si85103172qgf.53.2016.01.12.07.15.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 07:15:14 -0800 (PST)
Subject: [PATCH V2 07/11] slab: implement bulk alloc in SLAB allocator
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 12 Jan 2016 16:15:12 +0100
Message-ID: <20160112151501.31725.91231.stgit@firesoul>
In-Reply-To: <20160112151257.31725.71327.stgit@firesoul>
References: <20160112151257.31725.71327.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>

This patch implements the alloc side of bulk API for the SLAB
allocator.

Further optimization are still possible by changing the call to
__do_cache_alloc() into something that can return multiple
objects.  This optimization is left for later, given end results
already show in the area of 80% speedup.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slab.c |   37 +++++++++++++++++++++++++++++++++++--
 1 file changed, 35 insertions(+), 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index a05f716031de..17931ea961d1 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3392,9 +3392,42 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 EXPORT_SYMBOL(kmem_cache_free_bulk);
 
 int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
-								void **p)
+			  void **p)
 {
-	return __kmem_cache_alloc_bulk(s, flags, size, p);
+	size_t i;
+
+	s = slab_pre_alloc_hook(s, flags);
+	if (!s)
+		return 0;
+
+	cache_alloc_debugcheck_before(s, flags);
+
+	local_irq_disable();
+	for (i = 0; i < size; i++) {
+		void *objp = __do_cache_alloc(s, flags);
+
+		/* this call could be done outside IRQ disabled section */
+		objp = cache_alloc_debugcheck_after(s, flags, objp, _RET_IP_);
+
+		if (unlikely(!objp))
+			goto error;
+		p[i] = objp;
+	}
+	local_irq_enable();
+
+	/* Clear memory outside IRQ disabled section */
+	if (unlikely(flags & __GFP_ZERO))
+		for (i = 0; i < size; i++)
+			memset(p[i], 0, s->object_size);
+
+	slab_post_alloc_hook(s, flags, size, p);
+	/* FIXME: Trace call missing. Christoph would like a bulk variant */
+	return size;
+error:
+	local_irq_enable();
+	slab_post_alloc_hook(s, flags, i, p);
+	__kmem_cache_free_bulk(s, i, p);
+	return 0;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_bulk);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
