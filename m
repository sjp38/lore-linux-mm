Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CD0A76B028D
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:49:34 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x202so31249996pgx.1
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:49:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y4sor4727416pgy.54.2017.11.27.23.49.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 23:49:33 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH 04/18] vchecker: prepare per object memory for vchecker
Date: Tue, 28 Nov 2017 16:48:39 +0900
Message-Id: <1511855333-3570-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

To prepare per object memory for vchecker, we need to change the layout
of the object when kmem_cache initialization. Add such code on
vchecker_cache_create() which is called when kmem_cache initialization.

And, this memory should be initialized when object is populated. Do it
with another hook.

This memory will be used in the following patch.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/kasan/vchecker.c | 15 +++++++++++++++
 mm/kasan/vchecker.h |  4 ++++
 mm/slab.c           |  2 ++
 mm/slub.c           |  2 ++
 4 files changed, 23 insertions(+)

diff --git a/mm/kasan/vchecker.c b/mm/kasan/vchecker.c
index 0b8a1e7..be0f0cd 100644
--- a/mm/kasan/vchecker.c
+++ b/mm/kasan/vchecker.c
@@ -31,6 +31,10 @@ enum vchecker_type_num {
 	VCHECKER_TYPE_MAX,
 };
 
+struct vchecker_data {
+	void *dummy;
+};
+
 struct vchecker_type {
 	char *name;
 	const struct file_operations *fops;
@@ -109,10 +113,21 @@ static int remove_cbs(struct kmem_cache *s, struct vchecker_type *t)
 	return 0;
 }
 
+void vchecker_init_slab_obj(struct kmem_cache *s, const void *object)
+{
+	struct vchecker_data *data;
+
+	data = (void *)object + s->vchecker_cache.data_offset;
+	__memset(data, 0, sizeof(*data));
+}
+
 void vchecker_cache_create(struct kmem_cache *s,
 			size_t *size, slab_flags_t *flags)
 {
 	*flags |= SLAB_VCHECKER;
+
+	s->vchecker_cache.data_offset = *size;
+	*size += sizeof(struct vchecker_data);
 }
 
 void vchecker_kmalloc(struct kmem_cache *s, const void *object, size_t size)
diff --git a/mm/kasan/vchecker.h b/mm/kasan/vchecker.h
index aa22e8d..efebc63 100644
--- a/mm/kasan/vchecker.h
+++ b/mm/kasan/vchecker.h
@@ -7,6 +7,7 @@ struct vchecker_cb;
 struct vchecker_cache {
 	struct vchecker *checker;
 	struct dentry *dir;
+	int data_offset;
 };
 
 
@@ -18,6 +19,7 @@ int init_vchecker(struct kmem_cache *s);
 void fini_vchecker(struct kmem_cache *s);
 void vchecker_cache_create(struct kmem_cache *s, size_t *size,
 			slab_flags_t *flags);
+void vchecker_init_slab_obj(struct kmem_cache *s, const void *object);
 void vchecker_enable_cache(struct kmem_cache *s, bool enable);
 void vchecker_enable_obj(struct kmem_cache *s, const void *object,
 			size_t size, bool enable);
@@ -31,6 +33,8 @@ static inline int init_vchecker(struct kmem_cache *s) { return 0; }
 static inline void fini_vchecker(struct kmem_cache *s) { }
 static inline void vchecker_cache_create(struct kmem_cache *s,
 			size_t *size, slab_flags_t *flags) {}
+static inline void vchecker_init_slab_obj(struct kmem_cache *s,
+	const void *object) {}
 
 #endif
 
diff --git a/mm/slab.c b/mm/slab.c
index ba45c15..64d768b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2076,6 +2076,7 @@ int __kmem_cache_create(struct kmem_cache *cachep, slab_flags_t flags)
 	}
 #endif
 
+	vchecker_cache_create(cachep, &size, &flags);
 	kasan_cache_create(cachep, &size, &flags);
 
 	size = ALIGN(size, cachep->align);
@@ -2601,6 +2602,7 @@ static void cache_init_objs(struct kmem_cache *cachep,
 
 	for (i = 0; i < cachep->num; i++) {
 		objp = index_to_obj(cachep, page, i);
+		vchecker_init_slab_obj(cachep, objp);
 		kasan_init_slab_obj(cachep, objp);
 
 		/* constructor could break poison info */
diff --git a/mm/slub.c b/mm/slub.c
index 67364cb..c099b33 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1418,6 +1418,7 @@ static void setup_object(struct kmem_cache *s, struct page *page,
 				void *object)
 {
 	setup_object_debug(s, page, object);
+	vchecker_init_slab_obj(s, object);
 	kasan_init_slab_obj(s, object);
 	if (unlikely(s->ctor)) {
 		kasan_unpoison_object_data(s, object);
@@ -3550,6 +3551,7 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 		size += 2 * sizeof(struct track);
 #endif
 
+	vchecker_cache_create(s, &size, &s->flags);
 	kasan_cache_create(s, &size, &s->flags);
 #ifdef CONFIG_SLUB_DEBUG
 	if (flags & SLAB_RED_ZONE) {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
