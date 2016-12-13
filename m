Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 85E326B025E
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 15:26:14 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id z187so2895965iod.3
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 12:26:14 -0800 (PST)
Received: from p3plsmtps2ded03.prod.phx3.secureserver.net (p3plsmtps2ded03.prod.phx3.secureserver.net. [208.109.80.60])
        by mx.google.com with ESMTPS id f142si2728149itf.36.2016.12.13.12.26.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 12:26:13 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 1/5] radix tree test suite: Cache recently freed objects
Date: Tue, 13 Dec 2016 14:21:28 -0800
Message-Id: <1481667692-14500-2-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1481667692-14500-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1481667692-14500-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Tejun Heo <tj@kernel.org>

From: Matthew Wilcox <mawilcox@microsoft.com>

The kmem_cache_alloc implementation simply allocates new memory
from malloc() and calls the ctor, which zeroes out the entire object.
This means it cannot spot bugs where the object isn't properly
reinitialised before being freed.

Add a small (11 objects) cache before freeing objects back to malloc.
This is enough to let us write a test to catch it, although the memory
allocator is now aware of the structure of the radix tree node, since it
chains free objects through ->private_data (like the percpu cache does).

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 tools/testing/radix-tree/linux.c      | 48 ++++++++++++++++++++++++++++++-----
 tools/testing/radix-tree/linux/slab.h |  5 ----
 2 files changed, 41 insertions(+), 12 deletions(-)

diff --git a/tools/testing/radix-tree/linux.c b/tools/testing/radix-tree/linux.c
index ff0452e..d31ea7c 100644
--- a/tools/testing/radix-tree/linux.c
+++ b/tools/testing/radix-tree/linux.c
@@ -1,16 +1,27 @@
 #include <stdlib.h>
 #include <string.h>
 #include <malloc.h>
+#include <pthread.h>
 #include <unistd.h>
 #include <assert.h>
 
 #include <linux/mempool.h>
+#include <linux/poison.h>
 #include <linux/slab.h>
+#include <linux/radix-tree.h>
 #include <urcu/uatomic.h>
 
 int nr_allocated;
 int preempt_count;
 
+struct kmem_cache {
+	pthread_mutex_t lock;
+	int size;
+	int nr_objs;
+	void *objs;
+	void (*ctor)(void *);
+};
+
 void *mempool_alloc(mempool_t *pool, int gfp_mask)
 {
 	return pool->alloc(gfp_mask, pool->data);
@@ -34,24 +45,44 @@ mempool_t *mempool_create(int min_nr, mempool_alloc_t *alloc_fn,
 
 void *kmem_cache_alloc(struct kmem_cache *cachep, int flags)
 {
-	void *ret;
+	struct radix_tree_node *node;
 
 	if (flags & __GFP_NOWARN)
 		return NULL;
 
-	ret = malloc(cachep->size);
-	if (cachep->ctor)
-		cachep->ctor(ret);
+	pthread_mutex_lock(&cachep->lock);
+	if (cachep->nr_objs) {
+		cachep->nr_objs--;
+		node = cachep->objs;
+		cachep->objs = node->private_data;
+		pthread_mutex_unlock(&cachep->lock);
+		node->private_data = NULL;
+	} else {
+		pthread_mutex_unlock(&cachep->lock);
+		node = malloc(cachep->size);
+		if (cachep->ctor)
+			cachep->ctor(node);
+	}
+
 	uatomic_inc(&nr_allocated);
-	return ret;
+	return node;
 }
 
 void kmem_cache_free(struct kmem_cache *cachep, void *objp)
 {
 	assert(objp);
 	uatomic_dec(&nr_allocated);
-	memset(objp, 0, cachep->size);
-	free(objp);
+	pthread_mutex_lock(&cachep->lock);
+	if (cachep->nr_objs > 10) {
+		memset(objp, POISON_FREE, cachep->size);
+		free(objp);
+	} else {
+		struct radix_tree_node *node = objp;
+		cachep->nr_objs++;
+		node->private_data = cachep->objs;
+		cachep->objs = node;
+	}
+	pthread_mutex_unlock(&cachep->lock);
 }
 
 void *kmalloc(size_t size, gfp_t gfp)
@@ -75,7 +106,10 @@ kmem_cache_create(const char *name, size_t size, size_t offset,
 {
 	struct kmem_cache *ret = malloc(sizeof(*ret));
 
+	pthread_mutex_init(&ret->lock, NULL);
 	ret->size = size;
+	ret->nr_objs = 0;
+	ret->objs = NULL;
 	ret->ctor = ctor;
 	return ret;
 }
diff --git a/tools/testing/radix-tree/linux/slab.h b/tools/testing/radix-tree/linux/slab.h
index 446639f..e40337f 100644
--- a/tools/testing/radix-tree/linux/slab.h
+++ b/tools/testing/radix-tree/linux/slab.h
@@ -10,11 +10,6 @@
 void *kmalloc(size_t size, gfp_t);
 void kfree(void *);
 
-struct kmem_cache {
-	int size;
-	void (*ctor)(void *);
-};
-
 void *kmem_cache_alloc(struct kmem_cache *cachep, int flags);
 void kmem_cache_free(struct kmem_cache *cachep, void *objp);
 
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
