Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id AD5C1828E1
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 01:01:53 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id ho8so46719615pac.2
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:01:53 -0800 (PST)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id zq10si17588343pab.11.2016.02.25.22.01.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 22:01:52 -0800 (PST)
Received: by mail-pf0-x22d.google.com with SMTP id c10so47844972pfc.2
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:01:52 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v2 06/17] mm/slab: clean up DEBUG_PAGEALLOC processing code
Date: Fri, 26 Feb 2016 15:01:13 +0900
Message-Id: <1456466484-3442-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, open code for checking DEBUG_PAGEALLOC cache is spread to some
sites.  It makes code unreadable and hard to change.  This patch clean-up
these code.  Following patch will change the criteria for DEBUG_PAGEALLOC
cache so this clean-up will help it, too.

v2: fix build with CONFIG_DEBUG_PAGEALLOC=n by Andrew

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/mm.h | 12 ++++---
 mm/slab.c          | 97 +++++++++++++++++++++++++++---------------------------
 2 files changed, 57 insertions(+), 52 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 516e149..7c6d47d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2194,14 +2194,18 @@ kernel_map_pages(struct page *page, int numpages, int enable)
 }
 #ifdef CONFIG_HIBERNATION
 extern bool kernel_page_present(struct page *page);
-#endif /* CONFIG_HIBERNATION */
-#else
+#endif	/* CONFIG_HIBERNATION */
+#else	/* CONFIG_DEBUG_PAGEALLOC */
 static inline void
 kernel_map_pages(struct page *page, int numpages, int enable) {}
 #ifdef CONFIG_HIBERNATION
 static inline bool kernel_page_present(struct page *page) { return true; }
-#endif /* CONFIG_HIBERNATION */
-#endif
+#endif	/* CONFIG_HIBERNATION */
+static inline bool debug_pagealloc_enabled(void)
+{
+	return false;
+}
+#endif	/* CONFIG_DEBUG_PAGEALLOC */
 
 #ifdef __HAVE_ARCH_GATE_AREA
 extern struct vm_area_struct *get_gate_vma(struct mm_struct *mm);
diff --git a/mm/slab.c b/mm/slab.c
index 8bca9be..3142ec3 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1661,6 +1661,14 @@ static void kmem_rcu_free(struct rcu_head *head)
 }
 
 #if DEBUG
+static bool is_debug_pagealloc_cache(struct kmem_cache *cachep)
+{
+	if (debug_pagealloc_enabled() && OFF_SLAB(cachep) &&
+		(cachep->size % PAGE_SIZE) == 0)
+		return true;
+
+	return false;
+}
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
 static void store_stackinfo(struct kmem_cache *cachep, unsigned long *addr,
@@ -1694,6 +1702,23 @@ static void store_stackinfo(struct kmem_cache *cachep, unsigned long *addr,
 	}
 	*addr++ = 0x87654321;
 }
+
+static void slab_kernel_map(struct kmem_cache *cachep, void *objp,
+				int map, unsigned long caller)
+{
+	if (!is_debug_pagealloc_cache(cachep))
+		return;
+
+	if (caller)
+		store_stackinfo(cachep, objp, caller);
+
+	kernel_map_pages(virt_to_page(objp), cachep->size / PAGE_SIZE, map);
+}
+
+#else
+static inline void slab_kernel_map(struct kmem_cache *cachep, void *objp,
+				int map, unsigned long caller) {}
+
 #endif
 
 static void poison_obj(struct kmem_cache *cachep, void *addr, unsigned char val)
@@ -1772,6 +1797,9 @@ static void check_poison_obj(struct kmem_cache *cachep, void *objp)
 	int size, i;
 	int lines = 0;
 
+	if (is_debug_pagealloc_cache(cachep))
+		return;
+
 	realobj = (char *)objp + obj_offset(cachep);
 	size = cachep->object_size;
 
@@ -1837,17 +1865,8 @@ static void slab_destroy_debugcheck(struct kmem_cache *cachep,
 		void *objp = index_to_obj(cachep, page, i);
 
 		if (cachep->flags & SLAB_POISON) {
-#ifdef CONFIG_DEBUG_PAGEALLOC
-			if (debug_pagealloc_enabled() &&
-				cachep->size % PAGE_SIZE == 0 &&
-					OFF_SLAB(cachep))
-				kernel_map_pages(virt_to_page(objp),
-					cachep->size / PAGE_SIZE, 1);
-			else
-				check_poison_obj(cachep, objp);
-#else
 			check_poison_obj(cachep, objp);
-#endif
+			slab_kernel_map(cachep, objp, 1, 0);
 		}
 		if (cachep->flags & SLAB_RED_ZONE) {
 			if (*dbg_redzone1(cachep, objp) != RED_INACTIVE)
@@ -2226,16 +2245,6 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	if (flags & CFLGS_OFF_SLAB) {
 		/* really off slab. No need for manual alignment */
 		freelist_size = calculate_freelist_size(cachep->num, 0);
-
-#ifdef CONFIG_PAGE_POISONING
-		/* If we're going to use the generic kernel_map_pages()
-		 * poisoning, then it's going to smash the contents of
-		 * the redzone and userword anyhow, so switch them off.
-		 */
-		if (debug_pagealloc_enabled() &&
-			size % PAGE_SIZE == 0 && flags & SLAB_POISON)
-			flags &= ~(SLAB_RED_ZONE | SLAB_STORE_USER);
-#endif
 	}
 
 	cachep->colour_off = cache_line_size();
@@ -2251,7 +2260,19 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	cachep->size = size;
 	cachep->reciprocal_buffer_size = reciprocal_value(size);
 
-	if (flags & CFLGS_OFF_SLAB) {
+#if DEBUG
+	/*
+	 * If we're going to use the generic kernel_map_pages()
+	 * poisoning, then it's going to smash the contents of
+	 * the redzone and userword anyhow, so switch them off.
+	 */
+	if (IS_ENABLED(CONFIG_PAGE_POISONING) &&
+		(cachep->flags & SLAB_POISON) &&
+		is_debug_pagealloc_cache(cachep))
+		cachep->flags &= ~(SLAB_RED_ZONE | SLAB_STORE_USER);
+#endif
+
+	if (OFF_SLAB(cachep)) {
 		cachep->freelist_cache = kmalloc_slab(freelist_size, 0u);
 		/*
 		 * This is a possibility for one of the kmalloc_{dma,}_caches.
@@ -2475,9 +2496,6 @@ static void cache_init_objs(struct kmem_cache *cachep,
 	for (i = 0; i < cachep->num; i++) {
 		void *objp = index_to_obj(cachep, page, i);
 #if DEBUG
-		/* need to poison the objs? */
-		if (cachep->flags & SLAB_POISON)
-			poison_obj(cachep, objp, POISON_FREE);
 		if (cachep->flags & SLAB_STORE_USER)
 			*dbg_userword(cachep, objp) = NULL;
 
@@ -2501,10 +2519,11 @@ static void cache_init_objs(struct kmem_cache *cachep,
 				slab_error(cachep, "constructor overwrote the"
 					   " start of an object");
 		}
-		if ((cachep->size % PAGE_SIZE) == 0 &&
-			    OFF_SLAB(cachep) && cachep->flags & SLAB_POISON)
-			kernel_map_pages(virt_to_page(objp),
-					 cachep->size / PAGE_SIZE, 0);
+		/* need to poison the objs? */
+		if (cachep->flags & SLAB_POISON) {
+			poison_obj(cachep, objp, POISON_FREE);
+			slab_kernel_map(cachep, objp, 0, 0);
+		}
 #else
 		if (cachep->ctor)
 			cachep->ctor(objp);
@@ -2716,18 +2735,8 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
 
 	set_obj_status(page, objnr, OBJECT_FREE);
 	if (cachep->flags & SLAB_POISON) {
-#ifdef CONFIG_DEBUG_PAGEALLOC
-		if (debug_pagealloc_enabled() &&
-			(cachep->size % PAGE_SIZE) == 0 && OFF_SLAB(cachep)) {
-			store_stackinfo(cachep, objp, caller);
-			kernel_map_pages(virt_to_page(objp),
-					 cachep->size / PAGE_SIZE, 0);
-		} else {
-			poison_obj(cachep, objp, POISON_FREE);
-		}
-#else
 		poison_obj(cachep, objp, POISON_FREE);
-#endif
+		slab_kernel_map(cachep, objp, 0, caller);
 	}
 	return objp;
 }
@@ -2862,16 +2871,8 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 	if (!objp)
 		return objp;
 	if (cachep->flags & SLAB_POISON) {
-#ifdef CONFIG_DEBUG_PAGEALLOC
-		if (debug_pagealloc_enabled() &&
-			(cachep->size % PAGE_SIZE) == 0 && OFF_SLAB(cachep))
-			kernel_map_pages(virt_to_page(objp),
-					 cachep->size / PAGE_SIZE, 1);
-		else
-			check_poison_obj(cachep, objp);
-#else
 		check_poison_obj(cachep, objp);
-#endif
+		slab_kernel_map(cachep, objp, 1, 0);
 		poison_obj(cachep, objp, POISON_INUSE);
 	}
 	if (cachep->flags & SLAB_STORE_USER)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
