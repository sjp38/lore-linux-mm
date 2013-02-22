Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id AA02A6B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 05:30:17 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH] slub: correctly bootstrap boot caches
Date: Fri, 22 Feb 2013 14:30:30 +0400
Message-Id: <1361529030-17462-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Glauber Costa <glommer@parallels.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@kernel.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

After we create a boot cache, we may allocate from it until it is bootstraped.
This will move the page from the partial list to the cpu slab list. If this
happens, the loop:

	list_for_each_entry(p, &n->partial, lru)

that we use to scan for all partial pages will yield nothing, and the pages
will keep pointing to the boot cpu cache, which is of course, invalid. To do
that, we should flush the cache to make sure that the cpu slab is back to the
partial list.

Although not verified in practice, I also point out that it is not safe to scan
the full list only when debugging is on in this case. As unlikely as it is, it
is theoretically possible for the pages to be full. If they are, they will
become unreachable. Aside from scanning the full list, we also need to make
sure that the pages indeed sit in there: the easiest way to do it is to make
sure the boot caches have the SLAB_STORE_USER debug flag set.

Signed-off-by: Glauber Costa <glommer@parallels.com>
Reported-by:  Steffen Michalke <StMichalke@web.de>
Cc: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 mm/slub.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)
---
 mm/slub.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index ba2ca53..ab372c8 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3617,6 +3617,12 @@ static struct kmem_cache * __init bootstrap(struct kmem_cache *static_cache)
 
 	memcpy(s, static_cache, kmem_cache->object_size);
 
+	/*
+	 * This runs very early, and only the boot processor is supposed to be
+	 * up.  Even if it weren't true, IRQs are not up so we couldn't fire
+	 * IPIs around.
+	 */
+	__flush_cpu_slab(s, smp_processor_id());
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 		struct page *p;
@@ -3625,12 +3631,13 @@ static struct kmem_cache * __init bootstrap(struct kmem_cache *static_cache)
 			list_for_each_entry(p, &n->partial, lru)
 				p->slab_cache = s;
 
-#ifdef CONFIG_SLUB_DEBUG
 			list_for_each_entry(p, &n->full, lru)
 				p->slab_cache = s;
-#endif
 		}
 	}
+
+	/* No longer needs to keep track of the full list */
+	s->flags &= ~SLAB_STORE_USER;
 	list_add(&s->list, &slab_caches);
 	return s;
 }
@@ -3648,8 +3655,14 @@ void __init kmem_cache_init(void)
 	kmem_cache_node = &boot_kmem_cache_node;
 	kmem_cache = &boot_kmem_cache;
 
+	/*
+	 * We want to keep early pages in the full list because of the
+	 * bootstrap process. If we don't do it, those pages become unreachable
+	 * and we can't update their page->slab_cache information.
+	 */
 	create_boot_cache(kmem_cache_node, "kmem_cache_node",
-		sizeof(struct kmem_cache_node), SLAB_HWCACHE_ALIGN);
+			sizeof(struct kmem_cache_node),
+			SLAB_HWCACHE_ALIGN | SLAB_STORE_USER);
 
 	hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK_PRI);
 
@@ -3659,7 +3672,7 @@ void __init kmem_cache_init(void)
 	create_boot_cache(kmem_cache, "kmem_cache",
 			offsetof(struct kmem_cache, node) +
 				nr_node_ids * sizeof(struct kmem_cache_node *),
-		       SLAB_HWCACHE_ALIGN);
+		       SLAB_HWCACHE_ALIGN | SLAB_STORE_USER);
 
 	kmem_cache = bootstrap(&boot_kmem_cache);
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
