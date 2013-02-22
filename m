Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id BD54A6B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 11:19:35 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2] slub: correctly bootstrap boot caches
Date: Fri, 22 Feb 2013 20:20:00 +0400
Message-Id: <1361550000-14173-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Glauber Costa <glommer@parallels.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@kernel.org>

After we create a boot cache, we may allocate from it until it is bootstraped.
This will move the page from the partial list to the cpu slab list. If this
happens, the loop:

	list_for_each_entry(p, &n->partial, lru)

that we use to scan for all partial pages will yield nothing, and the pages
will keep pointing to the boot cpu cache, which is of course, invalid. To do
that, we should flush the cache to make sure that the cpu slab is back to the
partial list.

Signed-off-by: Glauber Costa <glommer@parallels.com>
Reported-by:  Steffen Michalke <StMichalke@web.de>
Tested-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Pekka Enberg <penberg@kernel.org>

 mm/slub.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)
---
 mm/slub.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index ba2ca53..31a494c 100644
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
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
