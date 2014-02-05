Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 512446B0055
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 13:39:48 -0500 (EST)
Received: by mail-la0-f52.google.com with SMTP id c6so644140lan.39
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 10:39:47 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id e10si15546820laa.11.2014.02.05.10.39.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Feb 2014 10:39:46 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v15 13/13] memcg: reap dead memcgs upon global memory pressure
Date: Wed, 5 Feb 2014 22:39:29 +0400
Message-ID: <6bf292fd6184c23db7b11142812769aec712ed7b.1391624021.git.vdavydov@parallels.com>
In-Reply-To: <cover.1391624021.git.vdavydov@parallels.com>
References: <cover.1391624021.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dchinner@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, glommer@gmail.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Glauber Costa <glommer@openvz.org>, Anton Vorontsov <anton@enomsg.org>, John Stultz <john.stultz@linaro.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

From: Glauber Costa <glommer@openvz.org>

When we delete kmem-enabled memcgs, they can still be zombieing around
for a while. The reason is that the objects may still be alive, and we
won't be able to delete them at destruction time.

The only entry point for that, though, are the shrinkers. The shrinker
interface, however, is not exactly tailored to our needs. It could be a
little bit better by using the API Dave Chinner proposed, but it is
still not ideal since we aren't really a count-and-scan event, but more
a one-off flush-all-you-can event that would have to abuse that somehow.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Anton Vorontsov <anton@enomsg.org>
Cc: John Stultz <john.stultz@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c |   82 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 79 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index aed1456015cf..14b152f4c69b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -328,8 +328,16 @@ struct mem_cgroup {
 	/* thresholds for mem+swap usage. RCU-protected */
 	struct mem_cgroup_thresholds memsw_thresholds;
 
-	/* For oom notifier event fd */
-	struct list_head oom_notify;
+	union {
+		/* For oom notifier event fd */
+		struct list_head oom_notify;
+		/*
+		 * we can only trigger an oom event if the memcg is alive.
+		 * so we will reuse this field to hook the memcg in the list
+		 * of dead memcgs.
+		 */
+		struct list_head dead;
+	};
 
 	/*
 	 * Should we move charges of a task when a task is moved into this
@@ -6134,6 +6142,58 @@ static int mem_cgroup_oom_control_write(struct cgroup_subsys_state *css,
 }
 
 #ifdef CONFIG_MEMCG_KMEM
+static LIST_HEAD(dangling_memcgs);
+static DEFINE_MUTEX(dangling_memcgs_mutex);
+
+static void memcg_dangling_add(struct mem_cgroup *memcg)
+{
+	mutex_lock(&dangling_memcgs_mutex);
+	list_add(&memcg->dead, &dangling_memcgs);
+	mutex_unlock(&dangling_memcgs_mutex);
+}
+
+static void memcg_dangling_del(struct mem_cgroup *memcg)
+{
+	mutex_lock(&dangling_memcgs_mutex);
+	list_del(&memcg->dead);
+	mutex_unlock(&dangling_memcgs_mutex);
+}
+
+static void memcg_vmpressure_shrink_dead(void)
+{
+	struct memcg_cache_params *params, *tmp;
+	struct kmem_cache *cachep;
+	struct mem_cgroup *memcg;
+
+	mutex_lock(&dangling_memcgs_mutex);
+	list_for_each_entry(memcg, &dangling_memcgs, dead) {
+		mutex_lock(&memcg->slab_caches_mutex);
+		/* The element may go away as an indirect result of shrink */
+		list_for_each_entry_safe(params, tmp,
+					 &memcg->memcg_slab_caches, list) {
+			cachep = memcg_params_to_cache(params);
+			/*
+			 * the cpu_hotplug lock is taken in kmem_cache_create
+			 * outside the slab_caches_mutex manipulation. It will
+			 * be taken by kmem_cache_shrink to flush the cache.
+			 * So we need to drop the lock. It is all right because
+			 * the lock only protects elements moving in and out the
+			 * list.
+			 */
+			mutex_unlock(&memcg->slab_caches_mutex);
+			kmem_cache_shrink(cachep);
+			mutex_lock(&memcg->slab_caches_mutex);
+		}
+		mutex_unlock(&memcg->slab_caches_mutex);
+	}
+	mutex_unlock(&dangling_memcgs_mutex);
+}
+
+static void memcg_register_kmem_events(struct mem_cgroup *memcg)
+{
+	vmpressure_register_kernel_event(memcg, memcg_vmpressure_shrink_dead);
+}
+
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
 	int ret;
@@ -6217,6 +6277,18 @@ static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
 		css_put(&memcg->css);
 }
 #else
+static void memcg_dangling_add(struct mem_cgroup *memcg)
+{
+}
+
+static void memcg_dangling_del(struct mem_cgroup *memcg)
+{
+}
+
+static void memcg_register_kmem_events(struct mem_cgroup *memcg)
+{
+}
+
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
 	return 0;
@@ -6767,8 +6839,10 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	if (css->cgroup->id > MEM_CGROUP_ID_MAX)
 		return -ENOSPC;
 
-	if (!parent)
+	if (!parent) {
+		memcg_register_kmem_events(memcg);
 		return 0;
+	}
 
 	mutex_lock(&memcg_create_mutex);
 
@@ -6842,6 +6916,7 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	mem_cgroup_invalidate_reclaim_iterators(memcg);
 	mem_cgroup_reparent_charges(memcg);
 	mem_cgroup_destroy_all_caches(memcg);
+	memcg_dangling_add(memcg);
 	vmpressure_cleanup(&memcg->vmpressure);
 }
 
@@ -6886,6 +6961,7 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 	mem_cgroup_reparent_charges(memcg);
 
 	memcg_destroy_kmem(memcg);
+	memcg_dangling_del(memcg);
 	__mem_cgroup_free(memcg);
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
