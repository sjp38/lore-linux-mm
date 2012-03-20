Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id A1A636B004D
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 06:16:23 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [RFC PATCH 2/6] slub: add kmalloc_align()
Date: Tue, 20 Mar 2012 18:21:20 +0800
Message-Id: <1332238884-6237-3-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com>
References: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lai Jiangshan <laijs@cn.fujitsu.com>

ALIGN_OF_LAST_BIT(size) is used instead of
ARCH_KMALLOC_MINALIGN when kmalloc kmem_caches are created.

No behavior changed except debug.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 include/linux/slub_def.h |    6 ++++++
 mm/slub.c                |    2 +-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index a32bcfd..67ac6b4 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -280,6 +280,12 @@ static __always_inline void *kmalloc(size_t size, gfp_t flags)
 	return __kmalloc(size, flags);
 }
 
+static __always_inline
+void *kmalloc_align(size_t size, gfp_t flags, size_t align)
+{
+	return kmalloc(ALIGN(size, align), flags);
+}
+
 #ifdef CONFIG_NUMA
 void *__kmalloc_node(size_t size, gfp_t flags, int node);
 void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
diff --git a/mm/slub.c b/mm/slub.c
index 4907563..01cf99d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3238,7 +3238,7 @@ static struct kmem_cache *__init create_kmalloc_cache(const char *name,
 	 * This function is called with IRQs disabled during early-boot on
 	 * single CPU so there's no need to take slub_lock here.
 	 */
-	if (!kmem_cache_open(s, name, size, ARCH_KMALLOC_MINALIGN,
+	if (!kmem_cache_open(s, name, size, ALIGN_OF_LAST_BIT(size),
 								flags, NULL))
 		goto panic;
 
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
