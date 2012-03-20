Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id B7E086B00E8
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 06:16:27 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [RFC PATCH 5/6] slob: add kmalloc_align()
Date: Tue, 20 Mar 2012 18:21:23 +0800
Message-Id: <1332238884-6237-6-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com>
References: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lai Jiangshan <laijs@cn.fujitsu.com>

Add a __kmalloc_node_align() for kmalloc_align().

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 include/linux/slob_def.h |   14 +++++++++++++-
 mm/slob.c                |    8 ++++----
 2 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/include/linux/slob_def.h b/include/linux/slob_def.h
index 0ec00b3..f2b0fe3 100644
--- a/include/linux/slob_def.h
+++ b/include/linux/slob_def.h
@@ -9,7 +9,13 @@ static __always_inline void *kmem_cache_alloc(struct kmem_cache *cachep,
 	return kmem_cache_alloc_node(cachep, flags, -1);
 }
 
-void *__kmalloc_node(size_t size, gfp_t flags, int node);
+void *__kmalloc_node_align(size_t size, gfp_t gfp, int align, int node);
+
+static __always_inline
+void *__kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	return __kmalloc_node_align(size, flags, 0, -1);
+}
 
 static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
@@ -34,4 +40,10 @@ static __always_inline void *__kmalloc(size_t size, gfp_t flags)
 	return kmalloc(size, flags);
 }
 
+static __always_inline
+void *kmalloc_align(size_t size, gfp_t flags, size_t align)
+{
+	return __kmalloc_node_align(ALIGN(size, align), flags, align, -1);
+}
+
 #endif /* __LINUX_SLOB_DEF_H */
diff --git a/mm/slob.c b/mm/slob.c
index 266e518..d46b986 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -478,15 +478,15 @@ out:
  * End of slob allocator proper. Begin kmem_cache_alloc and kmalloc frontend.
  */
 
-void *__kmalloc_node(size_t size, gfp_t gfp, int node)
+void *__kmalloc_node_align(size_t size, gfp_t gfp, int align, int node)
 {
 	unsigned int *m;
 	int hsize = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
-	int align;
 	void *ret;
 
 	gfp &= gfp_allowed_mask;
-	align = hsize;
+	if (align < hsize)
+		align = hsize;
 
 	lockdep_trace_alloc(gfp);
 
@@ -522,7 +522,7 @@ void *__kmalloc_node(size_t size, gfp_t gfp, int node)
 	kmemleak_alloc(ret, size, 1, gfp);
 	return ret;
 }
-EXPORT_SYMBOL(__kmalloc_node);
+EXPORT_SYMBOL(__kmalloc_node_align);
 
 void kfree(const void *block)
 {
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
