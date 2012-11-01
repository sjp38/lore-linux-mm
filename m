Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 46A036B0070
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 08:09:11 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v6 16/29] slab: annotate on-slab caches nodelist locks
Date: Thu,  1 Nov 2012 16:07:32 +0400
Message-Id: <1351771665-11076-17-git-send-email-glommer@parallels.com>
In-Reply-To: <1351771665-11076-1-git-send-email-glommer@parallels.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>, JoonSoo Kim <js1304@gmail.com>

We currently provide lockdep annotation for kmalloc caches, and also
caches that have SLAB_DEBUG_OBJECTS enabled. The reason for this is that
we can quite frequently nest in the l3->list_lock lock, which is not
something trivial to avoid.

My proposal with this patch, is to extend this to caches whose slab
management object lives within the slab as well ("on_slab"). The need
for this arose in the context of testing kmemcg-slab patches. With such
patchset, we can have per-memcg kmalloc caches. So the same path that
led to nesting between kmalloc caches will could then lead to in-memcg
nesting. Because they are not annotated, lockdep will trigger.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: David Rientjes <rientjes@google.com>
CC: JoonSoo Kim <js1304@gmail.com>
---
 mm/slab.c | 34 +++++++++++++++++++++++++++++++++-
 1 file changed, 33 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 98b3460..dcc05f5 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -653,6 +653,26 @@ static void init_node_lock_keys(int q)
 	}
 }
 
+static void on_slab_lock_classes_node(struct kmem_cache *cachep, int q)
+{
+	struct kmem_list3 *l3;
+	l3 = cachep->nodelists[q];
+	if (!l3)
+		return;
+
+	slab_set_lock_classes(cachep, &on_slab_l3_key,
+			&on_slab_alc_key, q);
+}
+
+static inline void on_slab_lock_classes(struct kmem_cache *cachep)
+{
+	int node;
+
+	VM_BUG_ON(OFF_SLAB(cachep));
+	for_each_node(node)
+		on_slab_lock_classes_node(cachep, node);
+}
+
 static inline void init_lock_keys(void)
 {
 	int node;
@@ -669,6 +689,14 @@ static inline void init_lock_keys(void)
 {
 }
 
+static inline void on_slab_lock_classes(struct kmem_cache *cachep)
+{
+}
+
+static inline void on_slab_lock_classes_node(struct kmem_cache *cachep, int node)
+{
+}
+
 static void slab_set_debugobj_lock_classes_node(struct kmem_cache *cachep, int node)
 {
 }
@@ -1396,6 +1424,9 @@ static int __cpuinit cpuup_prepare(long cpu)
 		free_alien_cache(alien);
 		if (cachep->flags & SLAB_DEBUG_OBJECTS)
 			slab_set_debugobj_lock_classes_node(cachep, node);
+		else if (!OFF_SLAB(cachep) &&
+			 !(cachep->flags & SLAB_DESTROY_BY_RCU))
+			on_slab_lock_classes_node(cachep, node);
 	}
 	init_node_lock_keys(node);
 
@@ -2550,7 +2581,8 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 		WARN_ON_ONCE(flags & SLAB_DESTROY_BY_RCU);
 
 		slab_set_debugobj_lock_classes(cachep);
-	}
+	} else if (!OFF_SLAB(cachep) && !(flags & SLAB_DESTROY_BY_RCU))
+		on_slab_lock_classes(cachep);
 
 	return 0;
 }
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
