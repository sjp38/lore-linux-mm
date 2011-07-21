Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 41CAF6B0092
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 08:53:45 -0400 (EDT)
Received: by mail-ew0-f41.google.com with SMTP id 9so1637748ewy.14
        for <linux-mm@kvack.org>; Thu, 21 Jul 2011 05:53:40 -0700 (PDT)
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [RFC v3 2/5] slab: implement slab object boundaries assertion
Date: Thu, 21 Jul 2011 16:53:35 +0400
Message-Id: <1311252815-6733-1-git-send-email-segoon@openwall.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Greg Kroah-Hartman <gregkh@suse.de>, Al Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>

Implement slab_access_ok() which checks whether a supplied buffer fully
fits in a slab page and whether it overflows a slab object.  It uses
cache specific information to learn object's boundaries.  It doesn't
check whether the object is actually allocated.  The latter would
significantly slowdown the check and it is related to object pointer
miscalculation rather than length parameter overflow, but
RUNTIME_USER_COPY_CHECK checks length overflows only.

If object's size is aligned, the check interprets padding bytes as if
they are object bytes.  It doesn't relax the check too much though: if
the checked action is write, overwriting pad bytes doesn't make sense;
if it is read, slab caches with constant object size don't suffer as
these padding bytes are not used too.  The check is weak for dynamically
sized objects only (kmalloc caches).

As it doesn't check whether the copied object is actually allocated, an
infoleak of a freed object is still possible.

The check is missing in SLOB case as objects boundaries are not easy to
check.  The walking through all objects from the first one on the page
to the touched object is needed for a strict check.  It also needs
holding a lock during the walking, which would significantly slowdown
the usercopy check.

v3 - Define slab_access_ok() only if DEBUG_RUNTIME_USER_COPY_CHECKS=y.
   - Removed redundant NULL initializers.
   - Removed (char *) casts.
   - Moved "len == 0" check to kernel_access_ok().

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
---
 include/linux/slab.h |    4 ++++
 mm/slab.c            |   33 +++++++++++++++++++++++++++++++++
 mm/slob.c            |   12 ++++++++++++
 mm/slub.c            |   28 ++++++++++++++++++++++++++++
 4 files changed, 77 insertions(+), 0 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index ad4dd1c..cdcee83 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -333,4 +333,8 @@ static inline void *kzalloc_node(size_t size, gfp_t flags, int node)
 
 void __init kmem_cache_init_late(void);
 
+#ifdef CONFIG_DEBUG_RUNTIME_USER_COPY_CHECKS
+extern bool slab_access_ok(const void *ptr, unsigned long len);
+#endif
+
 #endif	/* _LINUX_SLAB_H */
diff --git a/mm/slab.c b/mm/slab.c
index d96e223..95cda2e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3843,6 +3843,39 @@ unsigned int kmem_cache_size(struct kmem_cache *cachep)
 }
 EXPORT_SYMBOL(kmem_cache_size);
 
+#ifdef CONFIG_DEBUG_RUNTIME_USER_COPY_CHECKS
+/*
+ * Returns false if and only if [ptr; ptr+len) touches the slab,
+ * but breaks objects boundaries.  It doesn't check whether the
+ * accessed object is actually allocated.
+ */
+bool slab_access_ok(const void *ptr, unsigned long len)
+{
+	struct page *page;
+	struct kmem_cache *cachep;
+	struct slab *slabp;
+	unsigned int objnr;
+	unsigned long offset;
+
+	if (!virt_addr_valid(ptr))
+		return true;
+	page = virt_to_head_page(ptr);
+	if (!PageSlab(page))
+		return true;
+
+	cachep = page_get_cache(page);
+	slabp = page_get_slab(page);
+	objnr = obj_to_index(cachep, slabp, (void *)ptr);
+	BUG_ON(objnr >= cachep->num);
+	offset = ptr - index_to_obj(cachep, slabp, objnr) - obj_offset(cachep);
+	if (offset < obj_size(cachep) && len <= obj_size(cachep) - offset)
+		return true;
+
+	return false;
+}
+EXPORT_SYMBOL(slab_access_ok);
+#endif /* CONFIG_DEBUG_RUNTIME_USER_COPY_CHECKS */
+
 /*
  * This initializes kmem_list3 or resizes various caches for all nodes.
  */
diff --git a/mm/slob.c b/mm/slob.c
index 46e0aee..8333db6 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -666,6 +666,18 @@ unsigned int kmem_cache_size(struct kmem_cache *c)
 }
 EXPORT_SYMBOL(kmem_cache_size);
 
+#ifdef CONFIG_DEBUG_RUNTIME_USER_COPY_CHECKS
+bool slab_access_ok(const void *ptr, unsigned long len)
+{
+	/*
+	 * TODO: is it worth checking?  We have to gain a lock and
+	 * walk through all chunks.
+	 */
+	return true;
+}
+EXPORT_SYMBOL(slab_access_ok);
+#endif /* CONFIG_DEBUG_RUNTIME_USER_COPY_CHECKS */
+
 int kmem_cache_shrink(struct kmem_cache *d)
 {
 	return 0;
diff --git a/mm/slub.c b/mm/slub.c
index 35f351f..37e7467 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2623,6 +2623,34 @@ unsigned int kmem_cache_size(struct kmem_cache *s)
 }
 EXPORT_SYMBOL(kmem_cache_size);
 
+#ifdef CONFIG_DEBUG_RUNTIME_USER_COPY_CHECKS
+/*
+ * Returns false if and only if [ptr; ptr+len) touches the slab,
+ * but breaks objects boundaries.  It doesn't check whether the
+ * accessed object is actually allocated.
+ */
+bool slab_access_ok(const void *ptr, unsigned long len)
+{
+	struct page *page;
+	struct kmem_cache *s = NULL;
+	unsigned long offset;
+
+	if (!virt_addr_valid(ptr))
+		return true;
+	page = virt_to_head_page(ptr);
+	if (!PageSlab(page))
+		return true;
+
+	s = page->slab;
+	offset = (ptr - page_address(page)) % s->size;
+	if (offset <= s->objsize && len <= s->objsize - offset)
+		return true;
+
+	return false;
+}
+EXPORT_SYMBOL(slab_access_ok);
+#endif /* CONFIG_DEBUG_RUNTIME_USER_COPY_CHECKS */
+
 static void list_slab_objects(struct kmem_cache *s, struct page *page,
 							const char *text)
 {
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
