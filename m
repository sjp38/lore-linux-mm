Received: by ti-out-0910.google.com with SMTP id j3so27673tid.8
        for <linux-mm@kvack.org>; Tue, 19 Aug 2008 10:46:58 -0700 (PDT)
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: [PATCH 3/5] SLUB: Replace __builtin_return_address(0) with _RET_IP_.
Date: Tue, 19 Aug 2008 20:43:25 +0300
Message-Id: <1219167807-5407-3-git-send-email-eduard.munteanu@linux360.ro>
In-Reply-To: <1219167807-5407-2-git-send-email-eduard.munteanu@linux360.ro>
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro>
 <1219167807-5407-2-git-send-email-eduard.munteanu@linux360.ro>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: penberg@cs.helsinki.fi
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, cl@linux-foundation.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

This patch replaces __builtin_return_address(0) with _RET_IP_, since a
previous patch moved _RET_IP_ and _THIS_IP_ to include/linux/kernel.h and
they're widely available now. This makes for shorter and easier to read
code.

Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
---
 mm/slub.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 4f5b961..8f66782 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1612,14 +1612,14 @@ static __always_inline void *slab_alloc(struct kmem_cache *s,
 
 void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
 {
-	return slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
+	return slab_alloc(s, gfpflags, -1, (void *) _RET_IP_);
 }
 EXPORT_SYMBOL(kmem_cache_alloc);
 
 #ifdef CONFIG_NUMA
 void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node)
 {
-	return slab_alloc(s, gfpflags, node, __builtin_return_address(0));
+	return slab_alloc(s, gfpflags, node, (void *) _RET_IP_);
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 #endif
@@ -1730,7 +1730,7 @@ void kmem_cache_free(struct kmem_cache *s, void *x)
 
 	page = virt_to_head_page(x);
 
-	slab_free(s, page, x, __builtin_return_address(0));
+	slab_free(s, page, x, (void *) _RET_IP_);
 }
 EXPORT_SYMBOL(kmem_cache_free);
 
@@ -2657,7 +2657,7 @@ void *__kmalloc(size_t size, gfp_t flags)
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	return slab_alloc(s, flags, -1, __builtin_return_address(0));
+	return slab_alloc(s, flags, -1, (void *) _RET_IP_);
 }
 EXPORT_SYMBOL(__kmalloc);
 
@@ -2685,7 +2685,7 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	return slab_alloc(s, flags, node, __builtin_return_address(0));
+	return slab_alloc(s, flags, node, (void *) _RET_IP_);
 }
 EXPORT_SYMBOL(__kmalloc_node);
 #endif
@@ -2742,7 +2742,7 @@ void kfree(const void *x)
 		put_page(page);
 		return;
 	}
-	slab_free(page->slab, page, object, __builtin_return_address(0));
+	slab_free(page->slab, page, object, (void *) _RET_IP_);
 }
 EXPORT_SYMBOL(kfree);
 
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
