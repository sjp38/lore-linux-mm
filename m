Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id A52B56B0069
	for <linux-mm@kvack.org>; Sat,  1 Oct 2016 09:56:52 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id s64so95535993lfs.1
        for <linux-mm@kvack.org>; Sat, 01 Oct 2016 06:56:52 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id o67si11661458lfg.160.2016.10.01.06.56.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Oct 2016 06:56:51 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id h96so3085561lfi.1
        for <linux-mm@kvack.org>; Sat, 01 Oct 2016 06:56:50 -0700 (PDT)
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: [PATCH 1/2] mm: memcontrol: use special workqueue for creating per-memcg caches
Date: Sat,  1 Oct 2016 16:56:47 +0300
Message-Id: <c509c51d47b387c3d8e879678aca0b5e881b4613.1475329751.git.vdavydov.dev@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Pekka Enberg <penberg@kernel.org>

Creating a lot of cgroups at the same time might stall all worker
threads with kmem cache creation works, because kmem cache creation is
done with the slab_mutex held. To prevent that from happening, let's use
a special workqueue for kmem cache creation with max in-flight work
items equal to 1.

Link: https://bugzilla.kernel.org/show_bug.cgi?id=172981
Signed-off-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Reported-by: Doug Smythies <dsmythies@telus.net>
Cc: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Pekka Enberg <penberg@kernel.org>
---
 mm/memcontrol.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4be518d4e68a..c1efe59e3a20 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2175,6 +2175,8 @@ struct memcg_kmem_cache_create_work {
 	struct work_struct work;
 };
 
+static struct workqueue_struct *memcg_kmem_cache_create_wq;
+
 static void memcg_kmem_cache_create_func(struct work_struct *w)
 {
 	struct memcg_kmem_cache_create_work *cw =
@@ -2206,7 +2208,7 @@ static void __memcg_schedule_kmem_cache_create(struct mem_cgroup *memcg,
 	cw->cachep = cachep;
 	INIT_WORK(&cw->work, memcg_kmem_cache_create_func);
 
-	schedule_work(&cw->work);
+	queue_work(memcg_kmem_cache_create_wq, &cw->work);
 }
 
 static void memcg_schedule_kmem_cache_create(struct mem_cgroup *memcg,
@@ -5794,6 +5796,17 @@ static int __init mem_cgroup_init(void)
 {
 	int cpu, node;
 
+#ifndef CONFIG_SLOB
+	/*
+	 * Kmem cache creation is mostly done with the slab_mutex held,
+	 * so use a special workqueue to avoid stalling all worker
+	 * threads in case lots of cgroups are created simultaneously.
+	 */
+	memcg_kmem_cache_create_wq =
+		alloc_workqueue("memcg_kmem_cache_create", 0, 1);
+	BUG_ON(!memcg_kmem_cache_create_wq);
+#endif
+
 	hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
 
 	for_each_possible_cpu(cpu)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
