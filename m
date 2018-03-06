Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A09C26B0003
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 13:18:27 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id c37so13843769wra.5
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 10:18:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f128sor3159007wmg.32.2018.03.06.10.18.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Mar 2018 10:18:25 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2] kasan, slub: fix handling of kasan_slab_free hook
Date: Tue,  6 Mar 2018 19:18:17 +0100
Message-Id: <a62759a2545fddf69b0c034547212ca1eb1b3ce2.1520359686.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Konovalov <andreyknvl@google.com>

The kasan_slab_free hook's return value denotes whether the reuse of a
slab object must be delayed (e.g. when the object is put into memory
qurantine).

The current way SLUB handles this hook is by ignoring its return value
and hardcoding checks similar (but not exactly the same) to the ones
performed in kasan_slab_free, which is prone to making mistakes.

The main difference between the hardcoded checks and the ones in
kasan_slab_free is whether we want to perform a free in case when an
invalid-free or a double-free was detected (we don't).

This patch changes the way SLUB handles this by:
1. taking into account the return value of kasan_slab_free for each of
   the objects, that are being freed;
2. reconstructing the freelist of objects to exclude the ones, whose
   reuse must be delayed.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---

Changes in v2:
- Made slab_free_freelist_hook return bool and return true when KASAN is
  disabled. That should eliminate unnecessary branch in slab_free.

 mm/slub.c | 57 +++++++++++++++++++++++++++++++++----------------------
 1 file changed, 34 insertions(+), 23 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index e381728a3751..8442b3c54870 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1362,10 +1362,8 @@ static __always_inline void kfree_hook(void *x)
 	kasan_kfree_large(x, _RET_IP_);
 }
 
-static __always_inline void *slab_free_hook(struct kmem_cache *s, void *x)
+static __always_inline bool slab_free_hook(struct kmem_cache *s, void *x)
 {
-	void *freeptr;
-
 	kmemleak_free_recursive(x, s->flags);
 
 	/*
@@ -1385,17 +1383,12 @@ static __always_inline void *slab_free_hook(struct kmem_cache *s, void *x)
 	if (!(s->flags & SLAB_DEBUG_OBJECTS))
 		debug_check_no_obj_freed(x, s->object_size);
 
-	freeptr = get_freepointer(s, x);
-	/*
-	 * kasan_slab_free() may put x into memory quarantine, delaying its
-	 * reuse. In this case the object's freelist pointer is changed.
-	 */
-	kasan_slab_free(s, x, _RET_IP_);
-	return freeptr;
+	/* KASAN might put x into memory quarantine, delaying its reuse */
+	return kasan_slab_free(s, x, _RET_IP_);
 }
 
-static inline void slab_free_freelist_hook(struct kmem_cache *s,
-					   void *head, void *tail)
+static inline bool slab_free_freelist_hook(struct kmem_cache *s,
+					   void **head, void **tail)
 {
 /*
  * Compiler cannot detect this function can be removed if slab_free_hook()
@@ -1406,13 +1399,33 @@ static inline void slab_free_freelist_hook(struct kmem_cache *s,
 	defined(CONFIG_DEBUG_OBJECTS_FREE) ||	\
 	defined(CONFIG_KASAN)
 
-	void *object = head;
-	void *tail_obj = tail ? : head;
-	void *freeptr;
+	void *object;
+	void *next = *head;
+	void *old_tail = *tail ? *tail : *head;
+
+	/* Head and tail of the reconstructed freelist */
+	*head = NULL;
+	*tail = NULL;
 
 	do {
-		freeptr = slab_free_hook(s, object);
-	} while ((object != tail_obj) && (object = freeptr));
+		object = next;
+		next = get_freepointer(s, object);
+		/* If object's reuse doesn't have to be delayed */
+		if (!slab_free_hook(s, object)) {
+			/* Move object to the new freelist */
+			set_freepointer(s, object, *head);
+			*head = object;
+			if (!*tail)
+				*tail = object;
+		}
+	} while (object != old_tail);
+
+	if (*head == *tail)
+		*tail = NULL;
+
+	return *head != NULL;
+#else
+	return true;
 #endif
 }
 
@@ -2965,14 +2978,12 @@ static __always_inline void slab_free(struct kmem_cache *s, struct page *page,
 				      void *head, void *tail, int cnt,
 				      unsigned long addr)
 {
-	slab_free_freelist_hook(s, head, tail);
 	/*
-	 * slab_free_freelist_hook() could have put the items into quarantine.
-	 * If so, no need to free them.
+	 * With KASAN enabled slab_free_freelist_hook modifies the freelist
+	 * to remove objects, whose reuse must be delayed.
 	 */
-	if (s->flags & SLAB_KASAN && !(s->flags & SLAB_TYPESAFE_BY_RCU))
-		return;
-	do_slab_free(s, page, head, tail, cnt, addr);
+	if (slab_free_freelist_hook(s, &head, &tail))
+		do_slab_free(s, page, head, tail, cnt, addr);
 }
 
 #ifdef CONFIG_KASAN
-- 
2.16.2.395.g2e18187dfd-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
