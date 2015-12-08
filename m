Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id E88C66B025D
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 11:19:27 -0500 (EST)
Received: by qgeb1 with SMTP id b1so23393895qge.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 08:19:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a59si4069225qgf.42.2015.12.08.08.18.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 08:18:55 -0800 (PST)
Subject: [RFC PATCH V2 6/9] slab: implement bulk alloc in SLAB allocator
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 08 Dec 2015 17:18:52 +0100
Message-ID: <20151208161852.21945.85266.stgit@firesoul>
In-Reply-To: <20151208161751.21945.53936.stgit@firesoul>
References: <20151208161751.21945.53936.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slab.c |   37 +++++++++++++++++++++++++++++++++++--
 1 file changed, 35 insertions(+), 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 47e7bcab8c3b..70be9235e083 100644
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
