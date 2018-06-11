Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 19B556B0005
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 15:30:37 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 39-v6so1181108ple.6
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 12:30:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b21-v6sor7258206pfd.92.2018.06.11.12.30.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Jun 2018 12:30:34 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH v4] mm: fix race between kmem_cache destroy, create and deactivate
Date: Mon, 11 Jun 2018 12:29:51 -0700
Message-Id: <20180611192951.195727-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>
Cc: Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Shakeel Butt <shakeelb@google.com>

The memcg kmem cache creation and deactivation (SLUB only) is
asynchronous. If a root kmem cache is destroyed whose memcg cache is in
the process of creation or deactivation, the kernel may crash.

Example of one such crash:
	general protection fault: 0000 [#1] SMP PTI
	CPU: 1 PID: 1721 Comm: kworker/14:1 Not tainted 4.17.0-smp
	...
	Workqueue: memcg_kmem_cache kmemcg_deactivate_workfn
	RIP: 0010:has_cpu_slab
	...
	Call Trace:
	? on_each_cpu_cond
	__kmem_cache_shrink
	kmemcg_cache_deact_after_rcu
	kmemcg_deactivate_workfn
	process_one_work
	worker_thread
	kthread
	ret_from_fork+0x35/0x40

To fix this race, on root kmem cache destruction, mark the cache as
dying and flush the workqueue used for memcg kmem cache creation and
deactivation. SLUB's memcg kmem cache deactivation also includes RCU
callback and thus make sure all previous registered RCU callbacks
have completed as well.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
Changelog since v3:
- Handle the RCU callbacks for SLUB deactivation

Changelog since v2:
- Rewrote the patch and used workqueue flushing instead of refcount

Changelog since v1:
- Added more documentation to the code
- Renamed fields to be more readable

---
 include/linux/slab.h |  1 +
 mm/slab_common.c     | 33 ++++++++++++++++++++++++++++++++-
 2 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 9ebe659bd4a5..71c5467d99c1 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -658,6 +658,7 @@ struct memcg_cache_params {
 			struct memcg_cache_array __rcu *memcg_caches;
 			struct list_head __root_caches_node;
 			struct list_head children;
+			bool dying;
 		};
 		struct {
 			struct mem_cgroup *memcg;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index b0dd9db1eb2f..890b1f04a03a 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -136,6 +136,7 @@ void slab_init_memcg_params(struct kmem_cache *s)
 	s->memcg_params.root_cache = NULL;
 	RCU_INIT_POINTER(s->memcg_params.memcg_caches, NULL);
 	INIT_LIST_HEAD(&s->memcg_params.children);
+	s->memcg_params.dying = false;
 }
 
 static int init_memcg_params(struct kmem_cache *s,
@@ -608,7 +609,7 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	 * The memory cgroup could have been offlined while the cache
 	 * creation work was pending.
 	 */
-	if (memcg->kmem_state != KMEM_ONLINE)
+	if (memcg->kmem_state != KMEM_ONLINE || root_cache->memcg_params.dying)
 		goto out_unlock;
 
 	idx = memcg_cache_id(memcg);
@@ -712,6 +713,9 @@ void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
 	    WARN_ON_ONCE(s->memcg_params.deact_fn))
 		return;
 
+	if (s->memcg_params.root_cache->memcg_params.dying)
+		return;
+
 	/* pin memcg so that @s doesn't get destroyed in the middle */
 	css_get(&s->memcg_params.memcg->css);
 
@@ -823,11 +827,36 @@ static int shutdown_memcg_caches(struct kmem_cache *s)
 		return -EBUSY;
 	return 0;
 }
+
+static void flush_memcg_workqueue(struct kmem_cache *s)
+{
+	mutex_lock(&slab_mutex);
+	s->memcg_params.dying = true;
+	mutex_unlock(&slab_mutex);
+
+	/*
+	 * SLUB deactivates the kmem_caches through call_rcu_sched. Make
+	 * sure all registered rcu callbacks have been invoked.
+	 */
+	if (IS_ENABLED(CONFIG_SLUB))
+		rcu_barrier_sched();
+
+	/*
+	 * SLAB and SLUB create memcg kmem_caches through workqueue and SLUB
+	 * deactivates the memcg kmem_caches through workqueue. Make sure all
+	 * previous workitems on workqueue are processed.
+	 */
+	flush_workqueue(memcg_kmem_cache_wq);
+}
 #else
 static inline int shutdown_memcg_caches(struct kmem_cache *s)
 {
 	return 0;
 }
+
+static inline void flush_memcg_workqueue(struct kmem_cache *s)
+{
+}
 #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
 void slab_kmem_cache_release(struct kmem_cache *s)
@@ -845,6 +874,8 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	if (unlikely(!s))
 		return;
 
+	flush_memcg_workqueue(s);
+
 	get_online_cpus();
 	get_online_mems();
 
-- 
2.18.0.rc1.242.g61856ae69a-goog
