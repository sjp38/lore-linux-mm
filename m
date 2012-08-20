Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 0CA0A6B006C
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 16:50:37 -0400 (EDT)
Message-Id: <0000013945cd23c0-fb48fffb-7f4d-4ade-9ad7-9f30d2cbf62c-000000@email.amazonses.com>
Date: Mon, 20 Aug 2012 20:50:35 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C12 [02/19] slub: Use kmem_cache for the kmem_cache structure
References: <20120820204021.494276880@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org

Do not use kmalloc() but kmem_cache_alloc() for the allocation
of the kmem_cache structures in slub.

Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slub.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 00f8557..e0b9403 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -213,7 +213,7 @@ static inline int sysfs_slab_alias(struct kmem_cache *s, const char *p)
 static inline void sysfs_slab_remove(struct kmem_cache *s)
 {
 	kfree(s->name);
-	kfree(s);
+	kmem_cache_free(kmem_cache, s);
 }
 
 #endif
@@ -3969,7 +3969,7 @@ struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
 	if (!n)
 		return NULL;
 
-	s = kmalloc(kmem_size, GFP_KERNEL);
+	s = kmem_cache_alloc(kmem_cache, GFP_KERNEL);
 	if (s) {
 		if (kmem_cache_open(s, n,
 				size, align, flags, ctor)) {
@@ -3986,7 +3986,7 @@ struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
 			list_del(&s->list);
 			kmem_cache_close(s);
 		}
-		kfree(s);
+		kmem_cache_free(kmem_cache, s);
 	}
 	kfree(n);
 	return NULL;
@@ -5224,7 +5224,7 @@ static void kmem_cache_release(struct kobject *kobj)
 	struct kmem_cache *s = to_slab(kobj);
 
 	kfree(s->name);
-	kfree(s);
+	kmem_cache_free(kmem_cache, s);
 }
 
 static const struct sysfs_ops slab_sysfs_ops = {
-- 
1.7.9.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
