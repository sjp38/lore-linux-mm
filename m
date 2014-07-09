Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id A67606B0068
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 07:36:44 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so8915511pde.10
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 04:36:44 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id ej14si7240532pdb.261.2014.07.09.04.36.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 09 Jul 2014 04:36:39 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8G00HYV08YG350@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 09 Jul 2014 12:36:34 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [RFC/PATCH RESEND -next 13/21] mm: slub: add allocation size field to
 struct kmem_cache
Date: Wed, 09 Jul 2014 15:30:07 +0400
Message-id: <1404905415-9046-14-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org, Andrey Ryabinin <a.ryabinin@samsung.com>

When caller creates new kmem_cache, requested size of kmem_cache
will be stored in alloc_size. Later alloc_size will be used by
kerenel address sanitizer to mark alloc_size of slab object as
accessible and the rest of its size as redzone.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 include/linux/slub_def.h |  5 +++++
 mm/slab.h                | 10 ++++++++++
 mm/slab_common.c         |  2 ++
 mm/slub.c                |  1 +
 4 files changed, 18 insertions(+)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index d82abd4..b8b8154 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -68,6 +68,11 @@ struct kmem_cache {
 	int object_size;	/* The size of an object without meta data */
 	int offset;		/* Free pointer offset. */
 	int cpu_partial;	/* Number of per cpu partial objects to keep around */
+
+#ifdef CONFIG_KASAN
+	int alloc_size;		/* actual allocation size kmem_cache_create */
+#endif
+
 	struct kmem_cache_order_objects oo;
 
 	/* Allocation and freeing of slabs */
diff --git a/mm/slab.h b/mm/slab.h
index 912af7f..cb2e776 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -260,6 +260,16 @@ static inline void memcg_uncharge_slab(struct kmem_cache *s, int order)
 }
 #endif
 
+#ifdef CONFIG_KASAN
+static inline void kasan_set_alloc_size(struct kmem_cache *s, size_t size)
+{
+	s->alloc_size = size;
+}
+#else
+static inline void kasan_set_alloc_size(struct kmem_cache *s, size_t size) { }
+#endif
+
+
 static inline struct kmem_cache *virt_to_cache(const void *obj)
 {
 	struct page *page = virt_to_head_page(obj);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 8df59b09..f5b52f0 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -147,6 +147,7 @@ do_kmem_cache_create(char *name, size_t object_size, size_t size, size_t align,
 	s->name = name;
 	s->object_size = object_size;
 	s->size = size;
+	kasan_set_alloc_size(s, object_size);
 	s->align = align;
 	s->ctor = ctor;
 
@@ -409,6 +410,7 @@ void __init create_boot_cache(struct kmem_cache *s, const char *name, size_t siz
 
 	s->name = name;
 	s->size = s->object_size = size;
+	kasan_set_alloc_size(s, size);
 	s->align = calculate_alignment(flags, ARCH_KMALLOC_MINALIGN, size);
 	err = __kmem_cache_create(s, flags);
 
diff --git a/mm/slub.c b/mm/slub.c
index 3bdd9ac..6ddedf9 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3724,6 +3724,7 @@ __kmem_cache_alias(const char *name, size_t size, size_t align,
 		 * the complete object on kzalloc.
 		 */
 		s->object_size = max(s->object_size, (int)size);
+		kasan_set_alloc_size(s, max(s->alloc_size, (int)size));
 		s->inuse = max_t(int, s->inuse, ALIGN(size, sizeof(void *)));
 
 		for_each_memcg_cache_index(i) {
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
