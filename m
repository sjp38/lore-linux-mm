Received: by ag-out-0708.google.com with SMTP id 22so4236995agd.8
        for <linux-mm@kvack.org>; Wed, 16 Jul 2008 17:48:31 -0700 (PDT)
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: [RFC PATCH 4/4] kmemtrace: SLOB hooks.
Date: Thu, 17 Jul 2008 03:46:48 +0300
Message-Id: <9e4ab51fe29754243e4577dec4649c5522ddd4f8.1216255036.git.eduard.munteanu@linux360.ro>
In-Reply-To: <017a63e6be64502c36ede4733f0cc4e5ede75db2.1216255035.git.eduard.munteanu@linux360.ro>
References: <cover.1216255034.git.eduard.munteanu@linux360.ro>
 <4472a3f883b0d9026bb2d8c490233b3eadf9b55e.1216255035.git.eduard.munteanu@linux360.ro>
 <99a4b0edd280049b57a400b5934714ad66ea5788.1216255035.git.eduard.munteanu@linux360.ro>
 <017a63e6be64502c36ede4733f0cc4e5ede75db2.1216255035.git.eduard.munteanu@linux360.ro>
In-Reply-To: <cover.1216255034.git.eduard.munteanu@linux360.ro>
References: <cover.1216255034.git.eduard.munteanu@linux360.ro>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: penberg@cs.helsinki.fi
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This adds hooks for the SLOB allocator, to allow tracing with kmemtrace.

Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
---
 mm/slob.c |   37 +++++++++++++++++++++++++++++++------
 1 files changed, 31 insertions(+), 6 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index a3ad667..0335c01 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -65,6 +65,7 @@
 #include <linux/module.h>
 #include <linux/rcupdate.h>
 #include <linux/list.h>
+#include <linux/kmemtrace.h>
 #include <asm/atomic.h>
 
 /*
@@ -463,27 +464,38 @@ void *__kmalloc_node(size_t size, gfp_t gfp, int node)
 {
 	unsigned int *m;
 	int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
+	void *ret;
 
 	if (size < PAGE_SIZE - align) {
 		if (!size)
 			return ZERO_SIZE_PTR;
 
 		m = slob_alloc(size + align, gfp, align, node);
+
 		if (!m)
 			return NULL;
 		*m = size;
-		return (void *)m + align;
+		ret = (void *)m + align;
+
+		kmemtrace_mark_alloc_node(KMEMTRACE_TYPE_KERNEL,
+					  _RET_IP_, ret,
+					  size, size + align, gfp, node);
 	} else {
-		void *ret;
+		unsigned int order = get_order(size);
 
-		ret = slob_new_page(gfp | __GFP_COMP, get_order(size), node);
+		ret = slob_new_page(gfp | __GFP_COMP, order, node);
 		if (ret) {
 			struct page *page;
 			page = virt_to_page(ret);
 			page->private = size;
 		}
-		return ret;
+
+		kmemtrace_mark_alloc_node(KMEMTRACE_TYPE_KERNEL,
+					  _RET_IP_, ret,
+					  size, PAGE_SIZE << order, gfp, node);
 	}
+
+	return ret;
 }
 EXPORT_SYMBOL(__kmalloc_node);
 
@@ -501,6 +513,8 @@ void kfree(const void *block)
 		slob_free(m, *m + align);
 	} else
 		put_page(&sp->page);
+
+	kmemtrace_mark_free(KMEMTRACE_TYPE_KERNEL, _RET_IP_, block);
 }
 EXPORT_SYMBOL(kfree);
 
@@ -569,10 +583,19 @@ void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 {
 	void *b;
 
-	if (c->size < PAGE_SIZE)
+	if (c->size < PAGE_SIZE) {
 		b = slob_alloc(c->size, flags, c->align, node);
-	else
+		kmemtrace_mark_alloc_node(KMEMTRACE_TYPE_CACHE,
+					  _RET_IP_, b, c->size,
+					  SLOB_UNITS(c->size) * SLOB_UNIT,
+					  flags, node);
+	} else {
 		b = slob_new_page(flags, get_order(c->size), node);
+		kmemtrace_mark_alloc_node(KMEMTRACE_TYPE_CACHE,
+					  _RET_IP_, b, c->size,
+					  PAGE_SIZE << get_order(c->size),
+					  flags, node);
+	}
 
 	if (c->ctor)
 		c->ctor(c, b);
@@ -608,6 +631,8 @@ void kmem_cache_free(struct kmem_cache *c, void *b)
 	} else {
 		__kmem_cache_free(b, c->size);
 	}
+
+	kmemtrace_mark_free(KMEMTRACE_TYPE_CACHE, _RET_IP_, b);
 }
 EXPORT_SYMBOL(kmem_cache_free);
 
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
