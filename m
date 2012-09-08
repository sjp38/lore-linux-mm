Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id C60C26B00A6
	for <linux-mm@kvack.org>; Sat,  8 Sep 2012 16:50:18 -0400 (EDT)
Received: by mail-gh0-f169.google.com with SMTP id r18so248154ghr.14
        for <linux-mm@kvack.org>; Sat, 08 Sep 2012 13:50:18 -0700 (PDT)
From: Ezequiel Garcia <elezegarcia@gmail.com>
Subject: [PATCH 08/10] mm, slab: Rename __cache_alloc() -> slab_alloc()
Date: Sat,  8 Sep 2012 17:47:57 -0300
Message-Id: <1347137279-17568-8-git-send-email-elezegarcia@gmail.com>
In-Reply-To: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com>
References: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

This patch does not fix anything and its only goal is to
produce common code between SLAB and SLUB.

Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
---
 mm/slab.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 47cb03c..57094ee 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3560,7 +3560,7 @@ done:
  * Fallback to other node is possible if __GFP_THISNODE is not set.
  */
 static __always_inline void *
-__cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
+slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 		   unsigned long caller)
 {
 	unsigned long save_flags;
@@ -3647,7 +3647,7 @@ __do_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 #endif /* CONFIG_NUMA */
 
 static __always_inline void *
-__cache_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
+slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 {
 	unsigned long save_flags;
 	void *objp;
@@ -3823,7 +3823,7 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
  */
 void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 {
-	void *ret = __cache_alloc(cachep, flags, _RET_IP_);
+	void *ret = slab_alloc(cachep, flags, _RET_IP_);
 
 	trace_kmem_cache_alloc(_RET_IP_, ret,
 			       cachep->object_size, cachep->size, flags);
@@ -3838,7 +3838,7 @@ kmem_cache_alloc_trace(struct kmem_cache *cachep, gfp_t flags, size_t size)
 {
 	void *ret;
 
-	ret = __cache_alloc(cachep, flags, _RET_IP_);
+	ret = slab_alloc(cachep, flags, _RET_IP_);
 
 	trace_kmalloc(_RET_IP_, ret,
 		      size, cachep->size, flags);
@@ -3850,7 +3850,7 @@ EXPORT_SYMBOL(kmem_cache_alloc_trace);
 #ifdef CONFIG_NUMA
 void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 {
-	void *ret = __cache_alloc_node(cachep, flags, nodeid, _RET_IP_);
+	void *ret = slab_alloc_node(cachep, flags, nodeid, _RET_IP_);
 
 	trace_kmem_cache_alloc_node(_RET_IP_, ret,
 				    cachep->object_size, cachep->size,
@@ -3868,7 +3868,7 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *cachep,
 {
 	void *ret;
 
-	ret = __cache_alloc_node(cachep, flags, nodeid, _RET_IP);
+	ret = slab_alloc_node(cachep, flags, nodeid, _RET_IP);
 
 	trace_kmalloc_node(_RET_IP_, ret,
 			   size, cachep->size,
@@ -3931,7 +3931,7 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 	cachep = __find_general_cachep(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
-	ret = __cache_alloc(cachep, flags, caller);
+	ret = slab_alloc(cachep, flags, caller);
 
 	trace_kmalloc(caller, ret,
 		      size, cachep->size, flags);
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
