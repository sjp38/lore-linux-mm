Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B7FF6B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 16:35:57 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id x32-v6so7894385pld.16
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 13:35:57 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j6-v6si17470786pll.54.2018.06.08.13.35.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jun 2018 13:35:54 -0700 (PDT)
Date: Fri, 8 Jun 2018 13:35:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] mm: fix race between kmem_cache destroy, create and
  deactivate
Message-Id: <20180608133552.d9839eb08f6b98ec4d0ad783@linux-foundation.org>
In-Reply-To: <20180530001204.183758-1-shakeelb@google.com>
References: <20180530001204.183758-1-shakeelb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 29 May 2018 17:12:04 -0700 Shakeel Butt <shakeelb@google.com> wrote:

> The memcg kmem cache creation and deactivation (SLUB only) is
> asynchronous. If a root kmem cache is destroyed whose memcg cache is in
> the process of creation or deactivation, the kernel may crash.
> 
> Example of one such crash:
> 	general protection fault: 0000 [#1] SMP PTI
> 	CPU: 1 PID: 1721 Comm: kworker/14:1 Not tainted 4.17.0-smp
> 	...
> 	Workqueue: memcg_kmem_cache kmemcg_deactivate_workfn
> 	RIP: 0010:has_cpu_slab
> 	...
> 	Call Trace:
> 	? on_each_cpu_cond
> 	__kmem_cache_shrink
> 	kmemcg_cache_deact_after_rcu
> 	kmemcg_deactivate_workfn
> 	process_one_work
> 	worker_thread
> 	kthread
> 	ret_from_fork+0x35/0x40
> 
> To fix this race, on root kmem cache destruction, mark the cache as
> dying and flush the workqueue used for memcg kmem cache creation and
> deactivation.

We have a distinct lack of reviewers and testers on this one.  Please.

Vladimir, v3 replaced the refcounting with workqueue flushing, as you
suggested...


From: Shakeel Butt <shakeelb@google.com>
Subject: mm: fix race between kmem_cache destroy, create and deactivate

The memcg kmem cache creation and deactivation (SLUB only) is
asynchronous.  If a root kmem cache is destroyed whose memcg cache is in
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

To fix this race, on root kmem cache destruction, mark the cache as dying
and flush the workqueue used for memcg kmem cache creation and
deactivation.

[shakeelb@google.com: add more documentation, rename fields for readability]
  Link: http://lkml.kernel.org/r/20180522201336.196994-1-shakeelb@google.com
[akpm@linux-foundation.org: fix build, per Shakeel]
[shakeelb@google.com: v3.  Instead of refcount, flush the workqueue]
  Link: http://lkml.kernel.org/r/20180530001204.183758-1-shakeelb@google.com
Link: http://lkml.kernel.org/r/20180521174116.171846-1-shakeelb@google.com
Signed-off-by: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Greg Thelen <gthelen@google.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Tejun Heo <tj@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/slab.h |    1 +
 mm/slab_common.c     |   21 ++++++++++++++++++++-
 2 files changed, 21 insertions(+), 1 deletion(-)

diff -puN include/linux/slab_def.h~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate include/linux/slab_def.h
diff -puN include/linux/slab.h~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate include/linux/slab.h
--- a/include/linux/slab.h~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate
+++ a/include/linux/slab.h
@@ -600,6 +600,7 @@ struct memcg_cache_params {
 			struct memcg_cache_array __rcu *memcg_caches;
 			struct list_head __root_caches_node;
 			struct list_head children;
+			bool dying;
 		};
 		struct {
 			struct mem_cgroup *memcg;
diff -puN include/linux/slub_def.h~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate include/linux/slub_def.h
diff -puN mm/memcontrol.c~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate mm/memcontrol.c
diff -puN mm/slab.c~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate mm/slab.c
diff -puN mm/slab_common.c~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate mm/slab_common.c
--- a/mm/slab_common.c~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate
+++ a/mm/slab_common.c
@@ -136,6 +136,7 @@ void slab_init_memcg_params(struct kmem_
 	s->memcg_params.root_cache = NULL;
 	RCU_INIT_POINTER(s->memcg_params.memcg_caches, NULL);
 	INIT_LIST_HEAD(&s->memcg_params.children);
+	s->memcg_params.dying = false;
 }
 
 static int init_memcg_params(struct kmem_cache *s,
@@ -608,7 +609,7 @@ void memcg_create_kmem_cache(struct mem_
 	 * The memory cgroup could have been offlined while the cache
 	 * creation work was pending.
 	 */
-	if (memcg->kmem_state != KMEM_ONLINE)
+	if (memcg->kmem_state != KMEM_ONLINE || root_cache->memcg_params.dying)
 		goto out_unlock;
 
 	idx = memcg_cache_id(memcg);
@@ -712,6 +713,9 @@ void slab_deactivate_memcg_cache_rcu_sch
 	    WARN_ON_ONCE(s->memcg_params.deact_fn))
 		return;
 
+	if (s->memcg_params.root_cache->memcg_params.dying)
+		return;
+
 	/* pin memcg so that @s doesn't get destroyed in the middle */
 	css_get(&s->memcg_params.memcg->css);
 
@@ -823,11 +827,24 @@ static int shutdown_memcg_caches(struct
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
@@ -845,6 +862,8 @@ void kmem_cache_destroy(struct kmem_cach
 	if (unlikely(!s))
 		return;
 
+	flush_memcg_workqueue(s);
+
 	get_online_cpus();
 	get_online_mems();
 
diff -puN mm/slab.h~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate mm/slab.h
diff -puN mm/slub.c~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate mm/slub.c
_
