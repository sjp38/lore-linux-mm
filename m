Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 78A946B0007
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 22:41:01 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id cy9so27687526pac.0
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 19:41:01 -0800 (PST)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id di6si844486pad.172.2015.12.21.19.40.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 19:40:59 -0800 (PST)
Received: by mail-pf0-x232.google.com with SMTP id n128so82303419pfn.0
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 19:40:59 -0800 (PST)
From: Laura Abbott <laura@labbott.name>
Subject: [RFC][PATCH 2/7] slub: Add support for sanitization
Date: Mon, 21 Dec 2015 19:40:36 -0800
Message-Id: <1450755641-7856-3-git-send-email-laura@labbott.name>
In-Reply-To: <1450755641-7856-1-git-send-email-laura@labbott.name>
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <laura@labbott.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, kernel-hardening@lists.openwall.com


Clearing of objects on free only happens when SLUB_DEBUG and poisoning
is enabled for caches. This is a potential source of security leaks;
sensitive information may remain around well after its normal life
time. Add support for sanitizing objects independent of debug features.
Sanitization can be configured on only the slow path or all paths.

All credit for the original work should be given to Brad Spengler and
the PaX Team.

Signed-off-by: Laura Abbott <laura@labbott.name>
---
 mm/slub.c | 90 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 89 insertions(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 4699751..a02e1e7 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -220,6 +220,15 @@ static inline void stat(const struct kmem_cache *s, enum stat_item si)
 #endif
 }
 
+static inline bool should_sanitize_slab(const struct kmem_cache *s)
+{
+#ifdef CONFIG_SLAB_MEMORY_SANITIZE
+		return !(s->flags & SLAB_NO_SANITIZE);
+#else
+		return false;
+#endif
+}
+
 /********************************************************************
  * 			Core slab cache functions
  *******************************************************************/
@@ -286,6 +295,9 @@ static inline int slab_index(void *p, struct kmem_cache *s, void *addr)
 
 static inline size_t slab_ksize(const struct kmem_cache *s)
 {
+	if (should_sanitize_slab(s))
+		return s->object_size;
+
 #ifdef CONFIG_SLUB_DEBUG
 	/*
 	 * Debugging requires use of the padding between object
@@ -1263,6 +1275,66 @@ static inline void dec_slabs_node(struct kmem_cache *s, int node,
 
 #endif /* CONFIG_SLUB_DEBUG */
 
+#ifdef CONFIG_SLAB_MEMORY_SANITIZE
+static void __sanitize_object(struct kmem_cache *s, void *p)
+{
+	memset(p, SLAB_MEMORY_SANITIZE_VALUE, s->object_size);
+	if (s->ctor)
+		s->ctor(p);
+}
+
+static void sanitize_objects(struct kmem_cache *s, void *head, void *tail,
+				int cnt)
+{
+	int i = 1;
+	void *p = head;
+
+	do {
+		if (i > cnt)
+			BUG();
+
+		__sanitize_object(s, p);
+		i++;
+	} while (p != tail && (p = get_freepointer(s, p)));
+}
+
+
+static void sanitize_slow_path(struct kmem_cache *s, void *head, void *tail,
+				int cnt)
+{
+	if (sanitize_slab != SLAB_SANITIZE_PARTIAL_SLOWPATH)
+		return;
+
+	if (!should_sanitize_slab(s))
+		return;
+
+	sanitize_objects(s, head, tail, cnt);
+}
+
+static void sanitize_object(struct kmem_cache *s, void *p)
+{
+	if (sanitize_slab != SLAB_SANITIZE_FULL &&
+	    sanitize_slab != SLAB_SANITIZE_PARTIAL)
+		return;
+
+	if (!should_sanitize_slab(s))
+		return;
+
+	__sanitize_object(s, p);
+}
+#else
+static void sanitize_slow_path(struct kmem_cache *s, void *head, void *tail,
+				int cnt)
+{
+	return;
+}
+
+static void sanitize_object(struct kmem_cache *s, void *p)
+{
+	return;
+}
+#endif
+
 /*
  * Hooks for other subsystems that check memory allocations. In a typical
  * production configuration these hooks all should produce no code at all.
@@ -1311,6 +1383,7 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
 
 static inline void slab_free_hook(struct kmem_cache *s, void *x)
 {
+	sanitize_object(s, x);
 	kmemleak_free_recursive(x, s->flags);
 
 	/*
@@ -1345,7 +1418,8 @@ static inline void slab_free_freelist_hook(struct kmem_cache *s,
 	defined(CONFIG_LOCKDEP)	||		\
 	defined(CONFIG_DEBUG_KMEMLEAK) ||	\
 	defined(CONFIG_DEBUG_OBJECTS_FREE) ||	\
-	defined(CONFIG_KASAN)
+	defined(CONFIG_KASAN) || \
+	defined(CONFIG_SLAB_MEMORY_SANITIZE)
 
 	void *object = head;
 	void *tail_obj = tail ? : head;
@@ -2645,6 +2719,8 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 
 	stat(s, FREE_SLOWPATH);
 
+	sanitize_slow_path(s, head, tail, cnt);
+
 	if (kmem_cache_debug(s) &&
 	    !(n = free_debug_processing(s, page, head, tail, cnt,
 					addr, &flags)))
@@ -3262,6 +3338,7 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 	s->inuse = size;
 
 	if (((flags & (SLAB_DESTROY_BY_RCU | SLAB_POISON)) ||
+		should_sanitize_slab(s) ||
 		s->ctor)) {
 		/*
 		 * Relocate free pointer after the object if it is not
@@ -4787,6 +4864,14 @@ static ssize_t cache_dma_show(struct kmem_cache *s, char *buf)
 SLAB_ATTR_RO(cache_dma);
 #endif
 
+#ifdef CONFIG_SLAB_MEMORY_SANITIZE
+static ssize_t sanitize_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", should_sanitize_slab(s));
+}
+SLAB_ATTR_RO(sanitize);
+#endif
+
 static ssize_t destroy_by_rcu_show(struct kmem_cache *s, char *buf)
 {
 	return sprintf(buf, "%d\n", !!(s->flags & SLAB_DESTROY_BY_RCU));
@@ -5129,6 +5214,9 @@ static struct attribute *slab_attrs[] = {
 #ifdef CONFIG_ZONE_DMA
 	&cache_dma_attr.attr,
 #endif
+#ifdef CONFIG_SLAB_MEMORY_SANITIZE
+	&sanitize_attr.attr,
+#endif
 #ifdef CONFIG_NUMA
 	&remote_node_defrag_ratio_attr.attr,
 #endif
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
