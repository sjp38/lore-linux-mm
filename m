Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 928206B028B
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:49:31 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 199so25191016pgg.20
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:49:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h65sor5776916pgc.262.2017.11.27.23.49.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 23:49:30 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH 03/18] vchecker: mark/unmark the shadow of the allocated objects
Date: Tue, 28 Nov 2017 16:48:38 +0900
Message-Id: <1511855333-3570-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Mark/unmark the shadow of the objects that is allocated before the
vchecker is enabled/disabled. It is necessary to fully debug the system.
Since there is no synchronization way to prevent slab object free,
we cannot synchronously mark/unmark the shadow of the allocated object.
Therefore, with this patch, it would be possible to overwrite
KASAN_KMALLOC_FREE shadow value to KASAN_VCHECKER_GRAYZONE/0 and
UAF check in KASAN would be missed. However, it is okay since
it happens rarely and we would decide to use this feature
as a last resort.

We can solve this race problem if another shadow memory is introduced.
It will be considered after the usefulness of the feature is justified.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/slab.h |  6 ++++++
 mm/kasan/vchecker.c  | 27 +++++++++++++++++++++++++++
 mm/kasan/vchecker.h  |  7 +++++++
 mm/slab.c            | 31 +++++++++++++++++++++++++++++++
 mm/slab.h            |  4 ++--
 mm/slub.c            | 36 ++++++++++++++++++++++++++++++++++--
 6 files changed, 107 insertions(+), 4 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 47e70e6..f6efbbe 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -108,6 +108,12 @@
 #define SLAB_KASAN		0
 #endif
 
+#ifdef CONFIG_VCHECKER
+#define SLAB_VCHECKER		0x10000000UL
+#else
+#define SLAB_VCHECKER		0x00000000UL
+#endif
+
 /* The following flags affect the page allocator grouping pages by mobility */
 /* Objects are reclaimable */
 #define SLAB_RECLAIM_ACCOUNT	((slab_flags_t __force)0x00020000U)
diff --git a/mm/kasan/vchecker.c b/mm/kasan/vchecker.c
index 0ac031c..0b8a1e7 100644
--- a/mm/kasan/vchecker.c
+++ b/mm/kasan/vchecker.c
@@ -109,6 +109,12 @@ static int remove_cbs(struct kmem_cache *s, struct vchecker_type *t)
 	return 0;
 }
 
+void vchecker_cache_create(struct kmem_cache *s,
+			size_t *size, slab_flags_t *flags)
+{
+	*flags |= SLAB_VCHECKER;
+}
+
 void vchecker_kmalloc(struct kmem_cache *s, const void *object, size_t size)
 {
 	struct vchecker *checker;
@@ -130,6 +136,26 @@ void vchecker_kmalloc(struct kmem_cache *s, const void *object, size_t size)
 	rcu_read_unlock();
 }
 
+void vchecker_enable_obj(struct kmem_cache *s, const void *object,
+			size_t size, bool enable)
+{
+	struct vchecker *checker;
+	struct vchecker_cb *cb;
+	s8 shadow_val = READ_ONCE(*(s8 *)kasan_mem_to_shadow(object));
+	s8 mark = enable ? KASAN_VCHECKER_GRAYZONE : 0;
+
+	/* It would be freed object. We don't need to mark it */
+	if (shadow_val < 0 && (u8)shadow_val != KASAN_VCHECKER_GRAYZONE)
+		return;
+
+	checker = s->vchecker_cache.checker;
+	list_for_each_entry(cb, &checker->cb_list, list) {
+		kasan_poison_shadow(object + cb->begin,
+				round_up(cb->end - cb->begin,
+				     KASAN_SHADOW_SCALE_SIZE), mark);
+	}
+}
+
 static void vchecker_report(unsigned long addr, size_t size, bool write,
 			unsigned long ret_ip, struct kmem_cache *s,
 			struct vchecker_cb *cb, void *object)
@@ -380,6 +406,7 @@ static ssize_t enable_write(struct file *filp, const char __user *ubuf,
 	 * left that accesses checker's cb list if vchecker is disabled.
 	 */
 	synchronize_sched();
+	vchecker_enable_cache(s, enable);
 	mutex_unlock(&vchecker_meta);
 
 	return cnt;
diff --git a/mm/kasan/vchecker.h b/mm/kasan/vchecker.h
index 77ba07d..aa22e8d 100644
--- a/mm/kasan/vchecker.h
+++ b/mm/kasan/vchecker.h
@@ -16,6 +16,11 @@ bool vchecker_check(unsigned long addr, size_t size,
 			bool write, unsigned long ret_ip);
 int init_vchecker(struct kmem_cache *s);
 void fini_vchecker(struct kmem_cache *s);
+void vchecker_cache_create(struct kmem_cache *s, size_t *size,
+			slab_flags_t *flags);
+void vchecker_enable_cache(struct kmem_cache *s, bool enable);
+void vchecker_enable_obj(struct kmem_cache *s, const void *object,
+			size_t size, bool enable);
 
 #else
 static inline void vchecker_kmalloc(struct kmem_cache *s,
@@ -24,6 +29,8 @@ static inline bool vchecker_check(unsigned long addr, size_t size,
 			bool write, unsigned long ret_ip) { return false; }
 static inline int init_vchecker(struct kmem_cache *s) { return 0; }
 static inline void fini_vchecker(struct kmem_cache *s) { }
+static inline void vchecker_cache_create(struct kmem_cache *s,
+			size_t *size, slab_flags_t *flags) {}
 
 #endif
 
diff --git a/mm/slab.c b/mm/slab.c
index 78ea436..ba45c15 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2551,6 +2551,37 @@ static inline bool shuffle_freelist(struct kmem_cache *cachep,
 }
 #endif /* CONFIG_SLAB_FREELIST_RANDOM */
 
+#ifdef CONFIG_VCHECKER
+static void __vchecker_enable_cache(struct kmem_cache *s,
+				struct page *page, bool enable)
+{
+	int i;
+	void *p;
+
+	for (i = 0; i < s->num; i++) {
+		p = index_to_obj(s, page, i);
+		vchecker_enable_obj(s, p, s->object_size, enable);
+	}
+}
+
+void vchecker_enable_cache(struct kmem_cache *s, bool enable)
+{
+	int node;
+	struct kmem_cache_node *n;
+	struct page *page;
+	unsigned long flags;
+
+	for_each_kmem_cache_node(s, node, n) {
+		spin_lock_irqsave(&n->list_lock, flags);
+		list_for_each_entry(page, &n->slabs_partial, lru)
+			__vchecker_enable_cache(s, page, enable);
+		list_for_each_entry(page, &n->slabs_full, lru)
+			__vchecker_enable_cache(s, page, enable);
+		spin_unlock_irqrestore(&n->list_lock, flags);
+	}
+}
+#endif
+
 static void cache_init_objs(struct kmem_cache *cachep,
 			    struct page *page)
 {
diff --git a/mm/slab.h b/mm/slab.h
index d054da8..c1cf486 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -136,10 +136,10 @@ static inline slab_flags_t kmem_cache_flags(unsigned long object_size,
 			 SLAB_TYPESAFE_BY_RCU | SLAB_DEBUG_OBJECTS )
 
 #if defined(CONFIG_DEBUG_SLAB)
-#define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER)
+#define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | SLAB_VCHECKER)
 #elif defined(CONFIG_SLUB_DEBUG)
 #define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
-			  SLAB_TRACE | SLAB_CONSISTENCY_CHECKS)
+			  SLAB_TRACE | SLAB_CONSISTENCY_CHECKS | SLAB_VCHECKER)
 #else
 #define SLAB_DEBUG_FLAGS (0)
 #endif
diff --git a/mm/slub.c b/mm/slub.c
index bb8c949..67364cb 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1026,7 +1026,7 @@ static void trace(struct kmem_cache *s, struct page *page, void *object,
 static void add_full(struct kmem_cache *s,
 	struct kmem_cache_node *n, struct page *page)
 {
-	if (!(s->flags & SLAB_STORE_USER))
+	if (!(s->flags & (SLAB_STORE_USER | SLAB_VCHECKER)))
 		return;
 
 	lockdep_assert_held(&n->list_lock);
@@ -1035,7 +1035,7 @@ static void add_full(struct kmem_cache *s,
 
 static void remove_full(struct kmem_cache *s, struct kmem_cache_node *n, struct page *page)
 {
-	if (!(s->flags & SLAB_STORE_USER))
+	if (!(s->flags & (SLAB_STORE_USER | SLAB_VCHECKER)))
 		return;
 
 	lockdep_assert_held(&n->list_lock);
@@ -1555,6 +1555,38 @@ static inline bool shuffle_freelist(struct kmem_cache *s, struct page *page)
 }
 #endif /* CONFIG_SLAB_FREELIST_RANDOM */
 
+#ifdef CONFIG_VCHECKER
+static void __vchecker_enable_cache(struct kmem_cache *s,
+				struct page *page, bool enable)
+{
+	void *p;
+	void *addr = page_address(page);
+
+	if (!page->inuse)
+		return;
+
+	for_each_object(p, s, addr, page->objects)
+		vchecker_enable_obj(s, p, s->object_size, enable);
+}
+
+void vchecker_enable_cache(struct kmem_cache *s, bool enable)
+{
+	int node;
+	struct kmem_cache_node *n;
+	struct page *page;
+	unsigned long flags;
+
+	for_each_kmem_cache_node(s, node, n) {
+		spin_lock_irqsave(&n->list_lock, flags);
+		list_for_each_entry(page, &n->partial, lru)
+			__vchecker_enable_cache(s, page, enable);
+		list_for_each_entry(page, &n->full, lru)
+			__vchecker_enable_cache(s, page, enable);
+		spin_unlock_irqrestore(&n->list_lock, flags);
+	}
+}
+#endif
+
 static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 {
 	struct page *page;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
