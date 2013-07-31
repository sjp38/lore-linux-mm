Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id A98046B0037
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 13:22:50 -0400 (EDT)
Message-ID: <0000014035c0e66a-8d14330a-608d-4fa6-87b7-4b3822fda7d0-000000@email.amazonses.com>
Date: Wed, 31 Jul 2013 17:22:49 +0000
From: Christoph Lameter <cl@linux.com>
Subject: [3.12 4/5] slub: remove verify_mem_not_deleted()
References: <20130731171257.629155011@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

I do not see any user for this code in the tree.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slub_def.h
===================================================================
--- linux.orig/include/linux/slub_def.h	2013-07-19 09:08:35.184029519 -0500
+++ linux/include/linux/slub_def.h	2013-07-19 09:08:35.180029449 -0500
@@ -98,17 +98,4 @@ struct kmem_cache {
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
-/**
- * Calling this on allocated memory will check that the memory
- * is expected to be in use, and print warnings if not.
- */
-#ifdef CONFIG_SLUB_DEBUG
-extern bool verify_mem_not_deleted(const void *x);
-#else
-static inline bool verify_mem_not_deleted(const void *x)
-{
-	return true;
-}
-#endif
-
 #endif /* _LINUX_SLUB_DEF_H */
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2013-07-19 09:06:36.000000000 -0500
+++ linux/mm/slub.c	2013-07-19 09:09:02.492486583 -0500
@@ -3319,42 +3319,6 @@ size_t ksize(const void *object)
 }
 EXPORT_SYMBOL(ksize);
 
-#ifdef CONFIG_SLUB_DEBUG
-bool verify_mem_not_deleted(const void *x)
-{
-	struct page *page;
-	void *object = (void *)x;
-	unsigned long flags;
-	bool rv;
-
-	if (unlikely(ZERO_OR_NULL_PTR(x)))
-		return false;
-
-	local_irq_save(flags);
-
-	page = virt_to_head_page(x);
-	if (unlikely(!PageSlab(page))) {
-		/* maybe it was from stack? */
-		rv = true;
-		goto out_unlock;
-	}
-
-	slab_lock(page);
-	if (on_freelist(page->slab_cache, page, object)) {
-		object_err(page->slab_cache, page, object, "Object is on free-list");
-		rv = false;
-	} else {
-		rv = true;
-	}
-	slab_unlock(page);
-
-out_unlock:
-	local_irq_restore(flags);
-	return rv;
-}
-EXPORT_SYMBOL(verify_mem_not_deleted);
-#endif
-
 void kfree(const void *x)
 {
 	struct page *page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
