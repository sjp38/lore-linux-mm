Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id E71406B0083
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 06:16:26 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [RFC PATCH 3/6] slab: add kmalloc_align()
Date: Tue, 20 Mar 2012 18:21:21 +0800
Message-Id: <1332238884-6237-4-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com>
References: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lai Jiangshan <laijs@cn.fujitsu.com>

ALIGN_OF_LAST_BIT(sizes[INDEX_AC].cs_size) is used instead of
ARCH_KMALLOC_MINALIGN when kmalloc kmem_caches are created.

No behavior changed except debug.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 include/linux/slab_def.h |    6 ++++++
 mm/slab.c                |    8 ++++----
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index fbd1117..fb0c8ab 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -159,6 +159,12 @@ found:
 	return __kmalloc(size, flags);
 }
 
+static __always_inline
+void *kmalloc_align(size_t size, gfp_t flags, size_t align)
+{
+	return kmalloc(ALIGN(size, align), flags);
+}
+
 #ifdef CONFIG_NUMA
 extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
 extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
diff --git a/mm/slab.c b/mm/slab.c
index f0bd785..df8edbe 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1587,7 +1587,7 @@ void __init kmem_cache_init(void)
 
 	sizes[INDEX_AC].cs_cachep = kmem_cache_create(names[INDEX_AC].name,
 					sizes[INDEX_AC].cs_size,
-					ARCH_KMALLOC_MINALIGN,
+					ALIGN_OF_LAST_BIT(sizes[INDEX_AC].cs_size),
 					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 					NULL);
 
@@ -1595,7 +1595,7 @@ void __init kmem_cache_init(void)
 		sizes[INDEX_L3].cs_cachep =
 			kmem_cache_create(names[INDEX_L3].name,
 				sizes[INDEX_L3].cs_size,
-				ARCH_KMALLOC_MINALIGN,
+				ALIGN_OF_LAST_BIT(sizes[INDEX_L3].cs_size),
 				ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 				NULL);
 	}
@@ -1613,7 +1613,7 @@ void __init kmem_cache_init(void)
 		if (!sizes->cs_cachep) {
 			sizes->cs_cachep = kmem_cache_create(names->name,
 					sizes->cs_size,
-					ARCH_KMALLOC_MINALIGN,
+					ALIGN_OF_LAST_BIT(sizes->cs_size),
 					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 					NULL);
 		}
@@ -1621,7 +1621,7 @@ void __init kmem_cache_init(void)
 		sizes->cs_dmacachep = kmem_cache_create(
 					names->name_dma,
 					sizes->cs_size,
-					ARCH_KMALLOC_MINALIGN,
+					ALIGN_OF_LAST_BIT(sizes->cs_size),
 					ARCH_KMALLOC_FLAGS|SLAB_CACHE_DMA|
 						SLAB_PANIC,
 					NULL);
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
