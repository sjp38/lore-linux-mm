Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id A94446B0068
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 17:03:00 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 3/4] slab: move FULL state transition to an initcall
Date: Thu, 21 Jun 2012 00:59:18 +0400
Message-Id: <1340225959-1966-4-git-send-email-glommer@parallels.com>
In-Reply-To: <1340225959-1966-1-git-send-email-glommer@parallels.com>
References: <1340225959-1966-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, Cristoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>

During kmem_cache_init_late(), we transition to the LATE state,
and after some more work, to the FULL state, its last state

This is quite different from slub, that will only transition to
its last state (previously SYSFS), in a (late)initcall, after a lot
more of the kernel is ready.

This means that in slab, we have no way to taking actions dependent
on the initialization of other pieces of the kernel that are supposed
to start way after kmem_init_late(), such as cgroups initialization.

To achieve more consistency in this behavior, that patch only
transitions to the UP state in kmem_init_late. In my analysis,
setup_cpu_cache() should be happy to test for >= UP, instead of
== FULL. It also has passed some tests I've made.

We then only mark FULL state after the reap timers are in place,
meaning that no further setup is expected.

Signed-off-by: Glauber Costa <glommer@parallels.com>
Acked-by: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: David Rientjes <rientjes@google.com>
---
 mm/slab.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 0d1bd09..cb6da05 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1668,9 +1668,6 @@ void __init kmem_cache_init_late(void)
 			BUG();
 	mutex_unlock(&cache_chain_mutex);
 
-	/* Done! */
-	g_cpucache_up = FULL;
-
 	/*
 	 * Register a cpu startup notifier callback that initializes
 	 * cpu_cache_get for all new cpus
@@ -1700,6 +1697,9 @@ static int __init cpucache_init(void)
 	 */
 	for_each_online_cpu(cpu)
 		start_cpu_timer(cpu);
+
+	/* Done! */
+	g_cpucache_up = FULL;
 	return 0;
 }
 __initcall(cpucache_init);
@@ -2167,7 +2167,7 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
 
 static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
 {
-	if (g_cpucache_up == FULL)
+	if (g_cpucache_up >= LATE)
 		return enable_cpucache(cachep, gfp);
 
 	if (g_cpucache_up == NONE) {
-- 
1.7.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
