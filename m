Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2574E6B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 17:02:20 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 1/2] SLAB: Add function to get slab cache for a page
Date: Wed,  6 Oct 2010 23:02:09 +0200
Message-Id: <1286398930-11956-2-git-send-email-andi@firstfloor.org>
In-Reply-To: <1286398930-11956-1-git-send-email-andi@firstfloor.org>
References: <1286398930-11956-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: penberg@cs.helsinki.fi, cl@linux-foundation.org, mpm@selenic.com, Andi Kleen <ak@linux.intel.com>
List-ID: <linux-mm.kvack.org>

From: Andi Kleen <ak@linux.intel.com>

Add a generic function to get the slab cache for a page pointer.
The slabs already know this information internally, so just
export it.

Needed for a followup hwpoison patch which uses this to shrink
slab caches more efficiently.

Be careful to never BUG_ON in this path to make hwpoison
more robust.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 include/linux/slab.h |    1 +
 mm/slab.c            |   17 +++++++++++++++++
 mm/slob.c            |    5 +++++
 mm/slub.c            |   11 +++++++++++
 4 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 59260e2..9639e28 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -108,6 +108,7 @@ unsigned int kmem_cache_size(struct kmem_cache *);
 const char *kmem_cache_name(struct kmem_cache *);
 int kern_ptr_validate(const void *ptr, unsigned long size);
 int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
+struct kmem_cache *kmem_page_cache(struct page *p);
 
 /*
  * Please use this macro to create slab caches. Simply specify the
diff --git a/mm/slab.c b/mm/slab.c
index fcae981..20e6a24 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -498,6 +498,12 @@ static inline struct kmem_cache *page_get_cache(struct page *page)
 	return (struct kmem_cache *)page->lru.next;
 }
 
+static inline struct kmem_cache *__page_get_cache(struct page *page)
+{
+	page = compound_head(page);
+	return (struct kmem_cache *)page->lru.next;
+}
+
 static inline void page_set_slab(struct page *page, struct slab *slab)
 {
 	page->lru.prev = (struct list_head *)slab;
@@ -4587,3 +4593,14 @@ size_t ksize(const void *objp)
 	return obj_size(virt_to_cache(objp));
 }
 EXPORT_SYMBOL(ksize);
+
+/**
+ * kmem_page_cache - report kmem cache for page or NULL.
+ * @p: page
+ */
+struct kmem_cache *kmem_page_cache(struct page *p)
+{
+	if (!PageSlab(p))
+		return NULL;
+	return __page_get_cache(p);
+}
diff --git a/mm/slob.c b/mm/slob.c
index d582171..dd024a4 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -697,3 +697,8 @@ void __init kmem_cache_init_late(void)
 {
 	/* Nothing to do */
 }
+
+struct kmem_cache *kmem_page_cache(struct page *p)
+{
+	return NULL;
+}
diff --git a/mm/slub.c b/mm/slub.c
index 13fffe1..df7b998 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4678,3 +4678,14 @@ static int __init slab_proc_init(void)
 }
 module_init(slab_proc_init);
 #endif /* CONFIG_SLABINFO */
+
+/**
+ * kmem_page_cache - report kmem cache for page or NULL.
+ * @p: page
+ */
+struct kmem_cache *kmem_page_cache(struct page *p)
+{
+	if (!PageSlab(p))
+		return NULL;
+	return compound_head(p)->slab;
+}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
