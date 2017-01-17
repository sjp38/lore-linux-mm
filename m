Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 541C76B026A
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 18:54:27 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d185so22090020pgc.2
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 15:54:27 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id w9si11435084pgo.148.2017.01.17.15.54.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 15:54:26 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id t6so5033525pgt.1
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 15:54:26 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 08/10] slab: remove synchronous synchronize_sched() from memcg cache deactivation path
Date: Tue, 17 Jan 2017 15:54:09 -0800
Message-Id: <20170117235411.9408-9-tj@kernel.org>
In-Reply-To: <20170117235411.9408-1-tj@kernel.org>
References: <20170117235411.9408-1-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com, Tejun Heo <tj@kernel.org>

With kmem cgroup support enabled, kmem_caches can be created and
destroyed frequently and a great number of near empty kmem_caches can
accumulate if there are a lot of transient cgroups and the system is
not under memory pressure.  When memory reclaim starts under such
conditions, it can lead to consecutive deactivation and destruction of
many kmem_caches, easily hundreds of thousands on moderately large
systems, exposing scalability issues in the current slab management
code.  This is one of the patches to address the issue.

slub uses synchronize_sched() to deactivate a memcg cache.
synchronize_sched() is an expensive and slow operation and doesn't
scale when a huge number of caches are destroyed back-to-back.  While
there used to be a simple batching mechanism, the batching was too
restricted to be helpful.

This patch implements slab_deactivate_memcg_cache_rcu_sched() which
slub can use to schedule sched RCU callback instead of performing
synchronize_sched() synchronously while holding cgroup_mutex.  While
this adds online cpus, mems and slab_mutex operations, operating on
these locks back-to-back from the same kworker, which is what's gonna
happen when there are many to deactivate, isn't expensive at all and
this gets rid of the scalability problem completely.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-by: Jay Vana <jsvana@fb.com>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/slab.h |  6 ++++++
 mm/slab.h            |  2 ++
 mm/slab_common.c     | 60 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/slub.c            | 12 +++++++----
 4 files changed, 76 insertions(+), 4 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 41c49cc..5ca8778 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -582,6 +582,12 @@ struct memcg_cache_params {
 			struct mem_cgroup *memcg;
 			struct list_head children_node;
 			struct list_head kmem_caches_node;
+
+			void (*deact_fn)(struct kmem_cache *);
+			union {
+				struct rcu_head deact_rcu_head;
+				struct work_struct deact_work;
+			};
 		};
 	};
 };
diff --git a/mm/slab.h b/mm/slab.h
index be4434e..efa0d0a 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -301,6 +301,8 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 
 extern void slab_init_memcg_params(struct kmem_cache *);
 extern void memcg_link_cache(struct kmem_cache *s);
+extern void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
+				void (*deact_fn)(struct kmem_cache *));
 
 #else /* CONFIG_MEMCG && !CONFIG_SLOB */
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index cd4c952..32610d1 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -624,6 +624,66 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	put_online_cpus();
 }
 
+static void kmemcg_deactivate_workfn(struct work_struct *work)
+{
+	struct kmem_cache *s = container_of(work, struct kmem_cache,
+					    memcg_params.deact_work);
+
+	get_online_cpus();
+	get_online_mems();
+
+	mutex_lock(&slab_mutex);
+
+	s->memcg_params.deact_fn(s);
+
+	mutex_unlock(&slab_mutex);
+
+	put_online_mems();
+	put_online_cpus();
+
+	/* done, put the ref from slab_deactivate_memcg_cache_rcu_sched() */
+	css_put(&s->memcg_params.memcg->css);
+}
+
+static void kmemcg_deactivate_rcufn(struct rcu_head *head)
+{
+	struct kmem_cache *s = container_of(head, struct kmem_cache,
+					    memcg_params.deact_rcu_head);
+
+	/*
+	 * We need to grab blocking locks.  Bounce to ->deact_work.  The
+	 * work item shares the space with the RCU head and can't be
+	 * initialized eariler.
+	 */
+	INIT_WORK(&s->memcg_params.deact_work, kmemcg_deactivate_workfn);
+	schedule_work(&s->memcg_params.deact_work);
+}
+
+/**
+ * slab_deactivate_memcg_cache_rcu_sched - schedule deactivation after a
+ *					   sched RCU grace period
+ * @s: target kmem_cache
+ * @deact_fn: deactivation function to call
+ *
+ * Schedule @deact_fn to be invoked with online cpus, mems and slab_mutex
+ * held after a sched RCU grace period.  The slab is guaranteed to stay
+ * alive until @deact_fn is finished.  This is to be used from
+ * __kmemcg_cache_deactivate().
+ */
+void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
+					   void (*deact_fn)(struct kmem_cache *))
+{
+	if (WARN_ON_ONCE(is_root_cache(s)) ||
+	    WARN_ON_ONCE(s->memcg_params.deact_fn))
+		return;
+
+	/* pin memcg so that @s doesn't get destroyed in the middle */
+	css_get(&s->memcg_params.memcg->css);
+
+	s->memcg_params.deact_fn = deact_fn;
+	call_rcu_sched(&s->memcg_params.deact_rcu_head, kmemcg_deactivate_rcufn);
+}
+
 void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 {
 	int idx;
diff --git a/mm/slub.c b/mm/slub.c
index c754ea0..184f80b 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3949,6 +3949,12 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 }
 
 #ifdef CONFIG_MEMCG
+static void kmemcg_cache_deact_after_rcu(struct kmem_cache *s)
+{
+	/* called with all the locks held after a sched RCU grace period */
+	__kmem_cache_shrink(s);
+}
+
 void __kmemcg_cache_deactivate(struct kmem_cache *s)
 {
 	/*
@@ -3960,11 +3966,9 @@ void __kmemcg_cache_deactivate(struct kmem_cache *s)
 
 	/*
 	 * s->cpu_partial is checked locklessly (see put_cpu_partial), so
-	 * we have to make sure the change is visible.
+	 * we have to make sure the change is visible before shrinking.
 	 */
-	synchronize_sched();
-
-	__kmem_cache_shrink(s);
+	slab_deactivate_memcg_cache_rcu_sched(s, kmemcg_cache_deact_after_rcu);
 }
 #endif
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
